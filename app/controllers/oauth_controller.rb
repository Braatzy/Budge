require "rexml/document"
require 'net/http'
require 'net/https'
require 'uri'
require "open-uri"

class OauthController < ApplicationController
  protect_from_forgery :except => [:foursquare_push, :facebook_subs_callback, :withings_update_remote]
  
  def delete_token
    oauth_token = OauthToken.find params[:id]
    if oauth_token and oauth_token.user == current_user
      oauth_token.destroy
    end
    redirect_to :back
  end
  
  def duplicate_users
    oauth_token = OauthToken.find params[:id]
    render :text => "You already have an account that's connected to this #{oauth_token.site_name} account. We'll need to merge accounts, but that isn't possible yet. Contact buster@habitlabs.com with a good story and I'll try to fix this for you."
  end
  
  
  ## Facebook is special because it is the authentication AND the first 3rd party service
  def facebook
    oauth_info = OauthToken.get_oauth_info('facebook')
    session[:redirect_after_oauth] = params[:redirect_to] ? params[:redirect_to] : nil
    redirect_to "https://graph.facebook.com/oauth/authorize?client_id=#{oauth_info['consumer_key']}"+
                "&redirect_uri=#{oauth_info['callback']}"+
                "&scope=read_stream,publish_stream,publish_actions,offline_access,user_likes,user_status,"+
                "user_birthday,user_relationships,user_relationship_details,"+
                "email,user_checkins,sms,user_online_presence"+
                "&display=touch"
  end

  # They authenticated via Facebook
  def facebook_callback
    if params[:error_reason]
      redirect_to :controller => :home, :action => :index
      return
    end
    oauth_info = OauthToken.get_oauth_info('facebook')
    uri = URI.parse("https://graph.facebook.com/oauth/access_token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    new_params = {:client_id => oauth_info['consumer_key'],
                  :client_secret => oauth_info['consumer_secret'],
                  :redirect_uri => oauth_info['callback'],
                  :code => params[:code]}
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(new_params)
    response = http.request(request)
    
    fields = response.body.split('=')
    access_token = fields[1]

    oauth_token = OauthToken.find_by_token_and_site_token(access_token,'facebook')
    
    if current_user and oauth_token.present? and oauth_token.user and current_user != oauth_token.user
      redirect_to :controller => :oauth, :action => :duplicate_users, :id => oauth_token.id
      return
    end

    # Create the Oauth token
    if oauth_token
      oauth_token.update_attributes({:site_token => 'facebook',
                         :site_name => "Facebook",
                         :token => access_token})  
      oauth_token.get_user_info
    else
      oauth_token = OauthToken.create({:user_id => (current_user ? current_user.id : nil),
                         :site_token => 'facebook',
                         :site_name => "Facebook",
                         :token => access_token})  
      oauth_token.get_user_info
      
      TrackedAction.add(:connected_to_third_party_site, oauth_token.user)
      TrackedAction.add(:connected_to_facebook, oauth_token.user)
      oauth_token.user.give_level_up_credits(10)
    end

    OauthToken.delay.autofollow_friends(oauth_token.id)

    flash[:authenticated_facebook] = 1
    if !session[:redirect_after_oauth].blank?
      redirect_to session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
    else
      redirect_to :controller => :home, :action => :index
    end
  end    
  
  # Recieve updates to users from Facebook.
  # http://developers.facebook.com/docs/api/realtime/
  def facebook_subs_callback
    if request.get? and params['hub.mode'] == 'subscribe'
      render :text => params['hub.challenge']
    elsif request.post?
      # What happens when more than one record has changed?
      # {"entry"=>[{"changed_fields"=>["picture"], 
      #             "time"=>1302394571, 
      #             "id"=>"500528646", 
      #             "uid"=>"500528646"}], 
      # "object"=>"user"}
      if params['object'] and params['object'] == 'user'
        params['entry'].each do |person_info|
          if !person_info['uid'].blank? 
            if person_info.include?('name') or person_info.include?('picture') or person_info.include?('email')
              OauthToken.find_by_remote_user_id_and_site_token(person_info['uid'], 'facebook').update_user_info
            elsif person_info.include?('checkins')
              # They checked in somewhere
            end
          end
        end
      end
      render :text => 'subscription callback processed'
    end
  end

  def foursquare
    if params[:code].present?
      foursquare_callback        
    else
      oauth_info = OauthToken.get_oauth_info('foursquare')
      session[:redirect_after_oauth] = params[:redirect_to] ? params[:redirect_to] : nil
      #request_token = OauthToken.get_request_token('foursquare')    
      #session[:request_token] = request_token.token
      #session[:request_token_secret] = request_token.secret        

      redirect_to "https://foursquare.com/oauth2/authenticate?client_id=#{oauth_info['consumer_key']}"+
                  "&redirect_uri=#{oauth_info['callback']}"+
                  "&response_type=code"
    end
  end

  def foursquare_callback
    oauth_info = OauthToken.get_oauth_info('foursquare')
    uri = URI.parse("https://foursquare.com/oauth2/access_token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    new_params = {:client_id => oauth_info['consumer_key'],
                  :client_secret => oauth_info['consumer_secret'],
                  :redirect_uri => oauth_info['callback'],
                  :grant_type => 'authorization_code',
                  :code => params[:code]}
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(new_params)
    response = http.request(request)
    
    logger.warn response.body
    fields = JSON.parse(response.body)
    
    access_token = fields['access_token']

    oauth_token = OauthToken.find_by_site_token_and_user_id('foursquare', current_user.id)
    
    if current_user and oauth_token.present? and current_user != oauth_token.user
      redirect_to :controller => :oauth_controller, :action => :duplicate_users, :id => oauth_token.id
      return
    end

    # Create the Oauth token
    if oauth_token
      oauth_token.update_attributes({:site_token => 'foursquare',
                         :site_name => "Foursquare",
                         :token => access_token})  
      oauth_token.get_user_info
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'foursquare',
                         :site_name => "Foursquare",
                         :token => access_token})  
      oauth_token.get_user_info
      TrackedAction.add(:connected_to_third_party_site, current_user)
      TrackedAction.add(:connected_to_foursquare, current_user)
      current_user.give_level_up_credits(10)
    end
    
    OauthToken.delay.autofollow_friends(oauth_token.id)
    
    if !session[:redirect_after_oauth].blank?
      redirect_to session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
    else
      redirect_to :controller => :home, :action => :index
    end
  end

  # Example params
  # {"checkin"=>{"timeZone"=>"America/Los_Angeles", "shout"=>"Not really here. Just testing API stuff. But you should go. Meet Kellianne's brother!", "id"=>"4dfd875662846d918b983f24", "type"=>"checkin", "createdAt"=>1308460886,   
      # "venue"=>{"name"=>"Vito's", "location"=>{"city"=>"Seattle", "address"=>"927 9th Avenue", "country"=>"USA", "lng"=>-122.327485084534, "crossStreet"=>"at Madison", "postalCode"=>"98104", "lat"=>47.6082462871061, "state"=>"WA"}, "todos"=>{"count"=>0}, "stats"=>{"checkinsCount"=>757, "usersCount"=>367}, "contact"=>{"phone"=>"2063974053"}, "id"=>"40b13b00f964a52036f71ee3", "verified"=>false, "categories"=>[{"name"=>"Lounge", "parents"=>["Nightlife Spots"], "primary"=>true, "icon"=>"https://foursquare.com/img/categories/nightlife/lounge.png", "id"=>"4bf58dd8d48988d121941735", "pluralName"=>"Lounges"}, {"name"=>"Dive Bar", "parents"=>["Nightlife Spots"], "icon"=>"https://foursquare.com/img/categories/nightlife/default.png", "id"=>"4bf58dd8d48988d118941735", "pluralName"=>"Dive Bars"}, {"name"=>"Italian Restaurant", "parents"=>["Food"], "icon"=>"https://foursquare.com/img/categories/food/default.png", "id"=>"4bf58dd8d48988d110941735", "pluralName"=>"Italian Restaurants"}]}}, 
  #  "user"=>{"photo"=>"https://playfoursquare.s3.amazonaws.com/userpix_thumbs/237_1234293541.jpg", "homeCity"=>"Seattle, WA", "lastName"=>"Benson", "relationship"=>"self", "gender"=>"male", "id"=>"237", "firstName"=>"Buster"}}

  def foursquare_push
    parsed_json = JSON.parse(params[:checkin])
    logger.warn parsed_json.inspect

    logger.warn "lat: #{parsed_json['venue']['location']['lat']}, long: #{parsed_json['venue']['location']['lng']}"
    foursquare_oauths = OauthToken.where(:site_token => 'foursquare', :remote_user_id => parsed_json['user']['id'])
    
    if foursquare_oauths.present?
      latitude = parsed_json['venue']['location']['lat']
      longitude = parsed_json['venue']['location']['lng']
      foursquare_categories = parsed_json['venue']['categories'].select{|c|c['primary'].present?}.map{|c|c['id']}
    
      foursquare_oauths.each do |foursquare_oauth|
        LocationContext.create({:user_id => foursquare_oauth.user_id,
                                :context_about => 'foursquare_checkin',
                                :context_id => nil, # Stored in foursquare_checkin_id instead (no need to duplicate)
                                :latitude => latitude,
                                :longitude => longitude,
                                :place_name => parsed_json['venue']['name'],
                                :foursquare_checkin_id => parsed_json['id'],
                                :foursquare_place_id => parsed_json['venue']['id'],
                                :foursquare_category_id => (foursquare_categories.present? ? foursquare_categories.first : nil),
                                :foursquare_context => parsed_json,
                                :foursquare_guess => false})
        TrackedAction.add(:checked_in_on_foursquare, foursquare_oauth.user)
        
        # See if any of the categories apply to traits, update visit counts for the applicable traits (if they exist)
        if foursquare_categories.present?
          foursquare_categories.each do |foursquare_category_id|
            foursquare_category = FoursquareCategory.where(:category_id => foursquare_category_id).first
            if foursquare_category.present? and foursquare_category.trait_token.present?
            
              # Get trait associated with this foursquare category, if there is one
              trait = foursquare_category.trait
              next unless trait.present?
              user_trait = UserTrait.find_or_create_by_trait_id_and_user_id(trait.id, foursquare_oauth.user_id)
              next unless user_trait.present?
              
              time_in_time_zone = Time.now.in_time_zone(foursquare_oauth.user.time_zone_or_default)
              checkins = user_trait.save_new_data({:user_id => user_trait.user_id,
                                                   :did_action => true,
                                                   :date => time_in_time_zone.to_date,
                                                   :is_player => true,
                                                   :user_trait_id => user_trait.id,
                                                   :trait_id => trait.id,
                                                   :latitude => latitude,
                                                   :longitude => longitude,
                                                   :checkin_datetime => time_in_time_zone,
                                                   :amount_decimal => 1,
                                                   :comment => nil,
                                                   :checkin_via => 'foursquare',
                                                   :remote_id => parsed_json['id']})
              logger.warn "check ins: #{checkins.inspect}"
            end
          end
        end

      end
    end
    render :text => "Thanks, friend."
  end
  
  def twitter
    request_token = OauthToken.get_request_token('twitter')
    session[:redirect_after_oauth] = params[:redirect_to] ? params[:redirect_to] : nil
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret        
    redirect_to request_token.authorize_url    
  end

  def twitter_callback
    consumer = OauthToken.get_consumer('twitter')

    request_token = OAuth::RequestToken.new(consumer,
                                            session[:request_token],
                                            session[:request_token_secret])

    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])   


    if @_user 
      primary_twitter_oauth = @_user.oauth_for_site_token('twitter')
      if primary_twitter_oauth and primary_twitter_oauth.remote_username != access_token.params[:screen_name]
        oauth_token = OauthToken.new({:user_id => @_user.id,
                                      :remote_username => access_token.params[:screen_name],
                                      :site_token => 'twitter',
                                      :primary_token => false})

      elsif primary_twitter_oauth.present?
        oauth_token = primary_twitter_oauth
      end
    else
      oauth_token = OauthToken.find_by_remote_username_and_site_token_and_primary_token(access_token.params[:screen_name], 'twitter', true)
    end
    
    if session[:via_notification].present?
      p "session[:via_notification] = #{session[:via_notification]}"
      notification = Notification.find session[:via_notification] rescue nil
    end
    if oauth_token
      oauth_token.update_attributes({:site_token => 'twitter',
                         :site_name => "Twitter",
                         :token => access_token.token,
                         :secret => access_token.secret,
                         :remote_username => access_token.params[:screen_name],
                         :remote_user_id => access_token.params[:user_id]})  
      oauth_token.get_user_info      
    else
      oauth_token = OauthToken.create({:user_id => (@_user ? @_user.id : nil),
                         :site_token => 'twitter',
                         :site_name => "Twitter",
                         :token => access_token.token,
                         :secret => access_token.secret,
                         :remote_username => access_token.params[:screen_name],
                         :remote_user_id => access_token.params[:user_id]})  
      oauth_token.get_user_info
      
      # First time signing up
      @kissmetrics[:record] << {:name => 'Signed Up'}
      begin 
        oauth_token.delay.make_budge_follow_me
      rescue 
        p 'budge follow failed, skipping'
      end
      TrackedAction.add(:connected_to_third_party_site, oauth_token.user)
      TrackedAction.add(:connected_to_twitter, oauth_token.user)
      oauth_token.user.give_level_up_credits(10)
      
      # Mark that this user was referred by this notification
      if oauth_token.primary_token? and session[:via_notification].present?
        notification = Notification.find session[:via_notification] rescue nil
        if notification.present?
          p "found notification = #{notification.id}"
          notification.update_attributes(:num_signups => notification.num_signups+1)
          if notification.from_user.present?
            TrackedAction.add(:referred_by_notification, oauth_token.user)
            relationship = oauth_token.user.follow_user(notification.from_user, read = false, invisible = false, auto = true)
            relationship.update_attributes({:referred_signup => true, 
                                            :referred_signup_via => "notification:#{notification.id}"})

          end
        end
      end
    end

    # Add them to the beta if they aren't in it yet
    if notification.present? and oauth_token.primary_token? and notification.for_object == 'invitation_to_program'
      invitation = Invitation.find notification.for_id
      if invitation and !invitation.signed_up?
        # Mark this as a successful invitation, and give both users some dollars credit
        invitation.update_attributes(:signed_up => true, 
                                     :invited_user_id => oauth_token.user.id)
        oauth_token.user.update_attributes(:in_beta => true, 
                                           :dollars_credit => invitation.user.dollars_credit+User::DOLLARS_CREDIT_FOR_BEING_INVITED,
                                           :officially_started_at => Time.now.utc)
        invitation.program_player.update_invite_counts
        
        # Notify the invitee that their invitation was successful
        invitation.user.contact_them(:email, :invitation_to_program_success, invitation)
      end
      session[:via_notification] = nil
    end
    
    if session[:flag_for_beta] and !oauth_token.user.in_beta?
      user_attributes = {:in_beta => true, 
                         :officially_started_at => (oauth_token.user.officially_started_at.present? ? oauth_token.user.officially_started_at : Time.now.utc),
                         :cohort_tag => (oauth_token.user.cohort_tag.present? ? oauth_token.user.cohort_tag : session[:flag_for_cohort])}
      # For people signing up through sms
      if session[:verified_phone].present?
        user_attributes[:phone] = session[:verified_phone]
        user_attributes[:phone_verified] = true
      end
    
      oauth_token.user.update_attributes(user_attributes)    
    end

    # Log them in
    if !@_user 
      if oauth_token.user.present?
        user = oauth_token.user
        cookies[:u] = {:value => "#{user.id}|t|#{user.twitter_username}", 
                       :expires => 1.year.from_now, 
                       :domain => COOKIE_DOMAIN}
        TrackedAction.add(:logged_in, user) 
        if user.email.present? and user.encrypted_password.present?
          sign_in(:user, user)
        end
        p cookies.inspect
      else
        flash[:alert] = "Create an account with your email and password first."
      end
    end
    
    if oauth_token.primary_token? 
      OauthToken.delay.autofollow_friends(oauth_token.id)
    end
    
    flash[:authenticated_twitter] = 1
    if !session[:redirect_after_oauth].blank?
      redirect_to session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
    else
      redirect_to :controller => :home, :action => :index
    end
  end

  def twitter_coach
    if current_user and current_user.coach?
      request_token = OauthToken.get_request_token('twitter_coach')
      session[:redirect_after_oauth] = params[:redirect_to] ? params[:redirect_to] : nil
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret        
      redirect_to request_token.authorize_url    
    else
      raise "error"
      redirect_to :action => :twitter
    end
  end

  def twitter_coach_callback
    raise "Only logged in coaches can authenticate this way." if !current_user or !current_user.coach?  

    consumer = OauthToken.get_consumer('twitter_coach')

    request_token = OAuth::RequestToken.new(consumer,
                                            session[:request_token],
                                            session[:request_token_secret])

    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])   


    primary_twitter_oauth = current_user.oauth_for_site_token('twitter_coach')
    if primary_twitter_oauth and primary_twitter_oauth.remote_username != access_token.params[:screen_name]
      oauth_token = OauthToken.new({:user_id => current_user.id,
                                    :remote_username => access_token.params[:screen_name],
                                    :site_token => 'twitter_coach',
                                    :primary_token => false})

    elsif primary_twitter_oauth.present?
      oauth_token = primary_twitter_oauth
    end

    if oauth_token
      oauth_token.update_attributes({:site_token => 'twitter_coach',
                         :site_name => "Twitter Coach",
                         :token => access_token.token,
                         :secret => access_token.secret,
                         :remote_username => access_token.params[:screen_name],
                         :remote_user_id => access_token.params[:user_id]})  
      oauth_token.get_user_info      
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'twitter_coach',
                         :site_name => "Twitter Coach",
                         :token => access_token.token,
                         :secret => access_token.secret,
                         :remote_username => access_token.params[:screen_name],
                         :remote_user_id => access_token.params[:user_id]})  
      oauth_token.get_user_info
      
      # First time signing up
      if !oauth_token.user.present?
        redirect_to :controller => :users, :action => :sign_up
        return
      else
        @kissmetrics[:record] << {:name => 'Authenticated a Twitter account for coaching'}
        TrackedAction.add(:connected_to_third_party_site, oauth_token.user)
        TrackedAction.add(:connected_to_twitter_coach, oauth_token.user)      
      end
    end

    flash[:authenticated_twitter] = 1
    if !session[:redirect_after_oauth].blank?
      redirect_to session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
    else
      redirect_to :controller => :home, :action => :index
    end
  end


  # https://runkeeper.com/apps/authorize
  # https://runkeeper.com/apps/token
  def runkeeper
    oauth_info = OauthToken.get_oauth_info('runkeeper')
    redirect_to "https://runkeeper.com/apps/authorize?client_id=#{oauth_info['consumer_key']}"+
                "&redirect_uri=#{oauth_info['callback']}"+
                "&response_type=code"
  end

  def runkeeper_callback
    oauth_info = OauthToken.get_oauth_info('runkeeper')
    uri = URI.parse("https://runkeeper.com/apps/token")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    new_params = {:client_id => oauth_info['consumer_key'],
                  :client_secret => oauth_info['consumer_secret'],
                  :redirect_uri => oauth_info['callback'],
                  :grant_type => 'authorization_code',
                  :code => params[:code]}
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(new_params)
    response = http.request(request)
    
    logger.warn response.body
    fields = JSON.parse(response.body)

    access_token = fields['access_token']

    oauth_token = OauthToken.find_by_site_token_and_user_id('runkeeper', current_user.id)
    
    if current_user and oauth_token.present? and current_user != oauth_token.user
      redirect_to :controller => :oauth_controller, :action => :duplicate_users, :id => oauth_token.id
      return
    end

    # Create the Oauth token
    if oauth_token
      oauth_token.update_attributes({:site_token => 'runkeeper',
                         :site_name => "RunKeeper",
                         :token => access_token})  
      oauth_token.get_user_info
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'runkeeper',
                         :site_name => "RunKeeper",
                         :token => access_token})  
      oauth_token.get_user_info
      TrackedAction.add(:connected_to_third_party_site, current_user)
      TrackedAction.add(:connected_to_runkeeper, current_user)
      current_user.give_level_up_credits(10)
    end
    
    if !session[:redirect_after_oauth].blank?
      redirect_to session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
    else
      redirect_to :controller => :play, :action => :index
    end
  end

  def openpaths
    oauth_info = OauthToken.get_oauth_info('openpaths')
    session[:redirect_after_oauth] = params[:redirect_to] ? params[:redirect_to] : nil
    redirect_to "https://openpaths.cc/api/1?client_id=#{oauth_info['consumer_key']}"+
                "&redirect_uri=#{oauth_info['callback']}"
  end

  def openpaths_callback
    oauth_info = OauthToken.get_oauth_info('openpaths')
    uri = URI.parse("https://openpaths.cc/api/1")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    new_params = {:client_id => oauth_info['consumer_key'],
                  :client_secret => oauth_info['consumer_secret'],
                  :redirect_uri => oauth_info['callback'],
                  :grant_type => 'authorization_code',
                  :code => params[:code]}
    
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(new_params)
    response = http.request(request)
    
    logger.warn response.body
    fields = JSON.parse(response.body)
    
    access_token = fields['access_token']

    oauth_token = OauthToken.find_by_site_token_and_user_id('foursquare', current_user.id)
    
    if current_user and oauth_token.present? and current_user != oauth_token.user
      redirect_to :controller => :oauth_controller, :action => :duplicate_users, :id => oauth_token.id
      return
    end

    # Create the Oauth token
    if oauth_token
      oauth_token.update_attributes({:site_token => 'foursquare',
                         :site_name => "Foursquare",
                         :token => access_token})  
      oauth_token.get_user_info
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'foursquare',
                         :site_name => "Foursquare",
                         :token => access_token})  
      oauth_token.get_user_info
      TrackedAction.add(:connected_to_third_party_site, current_user)
      TrackedAction.add(:connected_to_foursquare, current_user)
      current_user.give_level_up_credits(10)
    end
    
    OauthToken.delay.autofollow_friends(oauth_token.id)
    
    if !session[:redirect_after_oauth].blank?
      redirect_to session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
    else
      redirect_to :controller => :home, :action => :index
    end
  end

  ##### NOT IMPLEMENTED YET #####


  def tumblr
    request_token = OauthToken.get_request_token('tumblr')
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret        
    redirect_to request_token.authorize_url    
  end
  
  def tumblr
    if params[:oauth_token]
      tumblr_callback        
    else
      request_token = OauthToken.get_request_token('tumblr')    
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret        
      redirect_to request_token.authorize_url    
    end
  end
  
  def tumblr_callback
    consumer = OauthToken.get_consumer('tumblr')

    request_token = OAuth::RequestToken.new(consumer,
                                            session[:request_token],
                                            session[:request_token_secret])

    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])   
    oauth_token = OauthToken.find_by_token_and_site_token(access_token.token,'tumblr')

    if oauth_token
      oauth_token.update_attributes({:user_id => current_user.id,
                         :site_token => 'tumblr',
                         :site_name => "Tumblr",
                         :token => access_token.token,
                         :secret => access_token.secret})  
      oauth_token.get_user_info
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'tumblr',
                         :site_name => "Tumblr",
                         :token => access_token.token,
                         :secret => access_token.secret})  
      oauth_token.get_user_info
    end
    
    if !oauth_token.cached_user_info.blank?
      parsed_xml = REXML::Document.new(oauth_token.cached_user_info)
      if parsed_xml.elements['//tumblr/tumblelog']
          
        parsed_xml.elements.each('//tumblr/tumblelog') do |tag|
          if tag.attributes['is-primary'] and tag.attributes['is-primary'] == 'yes'
            TrackedAction.add(:connected_to_third_party_site, current_user)
            TrackedAction.add(:connected_to_tumblr, current_user)
            flash[:mixpanel] = {:name => "Connected 3rd party account", :identify => false, :properties => {:site => 'Tumblr'}}
            oauth_token.update_attributes({:remote_name => tag.attributes['title'],
                                           :remote_username => tag.attributes['name']})
          end
        end
      end
    end
    
    redirect_to :controller => :users, :action => :edit
  end
  
  def fitbit
    request_token = OauthToken.get_request_token('fitbit')
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret        
    redirect_to request_token.authorize_url    
  end

  def fitbit_callback
    consumer = OauthToken.get_consumer('fitbit')

    request_token = OAuth::RequestToken.new(consumer,
                                            session[:request_token],
                                            session[:request_token_secret])

    access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])   
    oauth_token = OauthToken.find_by_user_id_and_site_token(current_user.id,'fitbit')
            
    if oauth_token
      oauth_token.update_attributes({:user_id => current_user.id,
                         :site_token => 'fitbit',
                         :site_name => "Fitbit",
                         :token => access_token.token,
                         :secret => access_token.secret,
                         :remote_user_id => access_token.params[:encoded_user_id]
                         })  
      oauth_token.get_user_info
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'fitbit',
                         :site_name => "Fitbit",
                         :token => access_token.token,
                         :secret => access_token.secret,
                         :remote_user_id => access_token.params[:encoded_user_id]})
      oauth_token.get_user_info
    end
            
    if !session[:redirect_after_oauth].blank?
      redirect_to session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
    else
      redirect_to :controller => :play, :action => :index
    end
  end
  
  def withings
    # If they've submitted their Withings credentials
    if params[:user].present? and params[:user][:withings_email]
      uri = URI.parse("http://wbsapi.withings.net/once?action=get")
      http = Net::HTTP.new(uri.host, uri.port)
      
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      parsed_json = JSON.parse(response.body)

      unless parsed_json['body']['once']
        flash[:error] = "There was a problem contacting the Withings API. Please try again later."
        redirect_to :action => :withings
        return
      end
      
      # Create the withings key: email:md5password:once
      withings_hash = Digest::MD5.hexdigest("#{params[:user][:withings_email]}:#{Digest::MD5.hexdigest(params[:user][:withings_password])}:#{parsed_json['body']['once']}")

      uri = URI.parse("http://wbsapi.withings.net/account")
      
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({:action => 'getuserslist',
                             :email => params[:user][:withings_email],
                             :hash => withings_hash})
      response = http.request(request)
      parsed_json = JSON.parse(response.body)
      logger.warn "WITHINGS: #{parsed_json['body'].inspect}"
      
      if parsed_json['body'] and parsed_json['body']['users'].size == 1
        wi_user = parsed_json['body']['users'].first
        current_user.update_attributes({:withings_username => wi_user["shortname"],
                                  :withings_user_id => wi_user["id"], 
                                  :withings_public_key => wi_user["publickey"]})
        current_user.backfill_withings
        current_user.subscribe_withings

        if session[:redirect_after_oauth]
          redirect_to session[:redirect_after_oauth]
          session[:redirect_after_oauth] = nil
          return
        else
          redirect_to :controller => :play, :action => :index
          return
        end
      elsif parsed_json['body'] and parsed_json['body']['users'].size > 1
        @withings_accounts = parsed_json['body']['users']
        render :action => 'withings_choose_account', :layout => 'app'
        return
      else
        flash[:error] = "There was a problem finding your account. Please try again."
        redirect_to :action => :withings
        return
      end
      
    # If they've chosen a particular user account to use
    elsif params[:user].present? and params[:user][:withings_username]
      wi_username, wi_user, wi_pass = params[:user][:withings_username].split(/\:/)
      current_user.update_attributes({:withings_username => wi_username,
                                :withings_user_id => wi_user, 
                                :withings_public_key => wi_pass})
      
      current_user.backfill_withings
      current_user.subscribe_withings

      if session[:redirect_after_oauth]
        redirect_to session[:redirect_after_oauth]
        session[:redirect_after_oauth] = nil
        return
      else
        redirect_to :controller => :play, :action => :index
        return
      end

    # If we need their Withings credentials
    else
      session[:redirect_after_oauth] = params[:redirect_to] ? params[:redirect_to] : nil      
    end

    render :layout => 'app'
  end
   
  # Processing OauthController#withings_update_remote (for 88.190.12.15 at 2011-01-06 11:20:05) [POST]
  # Parameters: {"enddate"=>"1294332511", "action"=>"withings_update_remote", "id"=>"1", "userid"=>"41595", "controller"=>"users", "startdate"=>"1294332510"}
  def withings_update_remote
    @user = User.where(:id => params[:id], :withings_user_id => params[:userid]).first
    if @user.present?
      @user.backfill_withings(params[:startdate], params[:enddate], true)
    end
    render :text => "updated weight via withings"  
  end
  
  def flickr
    oauth_info = OauthToken.get_oauth_info('flickr')
    api_sig = OauthToken.create_flickr_api_sig(oauth_info['consumer_secret'], oauth_info['consumer_key'], 'delete')
    redirect_to "http://flickr.com/services/auth/?api_key=#{oauth_info['consumer_key']}&perms=delete&api_sig=#{api_sig}"
  end
  
  def flickr_callback
    parsed_json = OauthToken.flickr_method('flickr.auth.getToken', {'frob' => params[:frob]})

    access_token = parsed_json['auth']['token']['_content'] rescue nil
    
    raise "Error getting access_token token" unless access_token
    
    oauth_token = OauthToken.find_by_token_and_site_token(access_token,'flickr')
    
    if oauth_token
      oauth_token.update_attributes({:user_id => current_user.id,
                         :site_token => 'flickr',
                         :site_name => "Flickr",
                         :token => access_token,
                         :remote_name => parsed_json['auth']['user']['fullname'],
                         :remote_username => parsed_json['auth']['user']['username'],
                         :remote_user_id => parsed_json['auth']['user']['nsid']})  
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'flickr',
                         :site_name => "Flickr",
                         :token => access_token,
                         :remote_name => parsed_json['auth']['user']['fullname'],
                         :remote_username => parsed_json['auth']['user']['username'],
                         :remote_user_id => parsed_json['auth']['user']['nsid']})  
    end
    oauth_token.get_user_info
    
    TrackedAction.add(:connected_to_third_party_site, current_user)
    TrackedAction.add(:connected_to_flickr, current_user)
    flash[:mixpanel] = {:name => "Connected 3rd party account", :identify => false, :properties => {:site => 'Flickr'}}
    redirect_to :controller => :users, :action => :edit
  end
  
  # https://www.google.com/accounts/AuthSubRequest?scope=http%3A%2F%2Fwww.google.com%2Fcalendar%2Ffeeds%2F&session=1&secure=0&next=http%3A%2F%2Fbeta.healthmonth.com%2Foauth%2Fgoogle_contacts_callback
  def google_contacts
    oauth_info = OauthToken.get_oauth_info('google_contacts')

    redirect_to "https://www.google.com/accounts/AuthSubRequest?scope=http%3A%2F%2Fwww.google.com%2Fcalendar%2Ffeeds%2F&session=1&secure=0&next=http%3A%2F%2Fbeta.healthmonth.com%2Foauth%2Fgoogle_contacts_callback"        
  end
  
  def google_contacts_callback
    access_token = params[:token]
    oauth_token = OauthToken.find_by_token_and_site_token(access_token,'google_contacts')
    
    if oauth_token
      oauth_token.update_attributes({:user_id => current_user.id,
                         :site_token => 'google_contacts',
                         :site_name => "Google Contacts",
                         :token => access_token})  
    else
      oauth_token = OauthToken.create({:user_id => current_user.id,
                         :site_token => 'google_contacts',
                         :site_name => "Google Contacts",
                         :token => access_token})  
    end
    oauth_token.get_user_info
    redirect_to :controller => :users, :action => :edit
  end
    
end
