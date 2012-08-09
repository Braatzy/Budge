class HomeController < ApplicationController
    skip_before_filter :redirect_to_https, :theming, :check_for_logged_in, :private_beta, :only => [:manifest]
    before_filter :authenticate_user!, :except => [:flag_for_beta, :index, :manifest, :support, :become_supporter, :decline_supporter, :invitation, :tour, :migrate_user]
    layout 'app'
    
    def index
      if current_user
        redirect_to :controller => :stream, :action => :index
      else
        redirect_to :controller => :home, :action => :tour
      end
    end
    
    def tour
    
    end
    
    def flag_for_beta
      if current_user 
        if current_user.officially_started_at.blank? or current_user.cohort_tag.blank?
          current_user.update_attributes(:officially_started_at => Time.now.utc, 
                                   :cohort_tag => (current_user.cohort_tag.present? ? current_user.cohort_tag : params[:id]))
        end
        redirect_to :controller => :play, :action => :index
      else
        session[:flag_for_beta] = true
        if params[:id].present?
          session[:flag_for_cohort] = params[:id]
        end
        # See twilio_controller.rb for details on how this gets set (for new people signing up through sms)
        if params[:p] and params[:s] and ((params[:p].to_i/32).to_s(32) == params[:s])
          session[:verified_phone] = params[:p]
        end
        redirect_to :controller => :waiting_room, :login => 1
      end
    end
    
    # Invitations
    def invitation
      @invitation = Invitation.find_by_token params[:id]
      if @invitation and !@invitation.visited?
        @invitation.update_attributes(:visited => true)
        @invitation.program_player.update_invite_counts
      end
      if current_user
        cookies[:u] = {:value => '', :expires => Time.at(0), :domain => COOKIE_DOMAIN}
        cookies[:u] = {:value => '', :expires => Time.at(0), :domain => DOMAIN}
        cookies.delete :u
        cookies.delete :u, :domain => ".beta#{COOKIE_DOMAIN}"
        cookies.delete :u, :domain => COOKIE_DOMAIN
      end
      redirect_to :controller => :stream, :action => :view_notification, :id => @invitation.notification.short_id
    end

    # Supporters
    def support
      @supporter = Supporter.find params[:id]
      @program = @supporter.program
      @program_player = @supporter.program_player
    end

    def become_supporter
      @supporter = Supporter.find params[:id]
      if current_user 
        if @supporter.user_twitter_username == current_user.twitter_username
          @supporter.update_attributes({:active => true, :user_id => current_user.id})
          flash[:message] = "Click on #{@supporter.program_player.user.name} to get started!"
          redirect_to :controller => :play
        else
          flash[:message] = "You aren't logged in to the right account."
          redirect_to :controller => :play          
        end
      else
        redirect_to :controller => :oauth, :action => :twitter, :redirect_to => "/home/become_supporter/#{@supporter.id}"
      end
    end
    
    def decline_supporter
      @supporter = Supporter.find params[:id]
      flash[:message] = "Thanks anyway!"      
      redirect_to :controller => :play
    end
    
    def cancel_supporter
      @supporter = Supporter.find params[:id]
      if @supporter.program_player.user == current_user or @supporter.user == current_user
        @supporter.update_attributes(:active => false)
      end
      flash[:message] = "Canceled your coach."      
      redirect_to :controller => :profile, :action => :user_info, :id => :coaches
    end
    
    def force_mobile_toggle
      if session[:force_web_layout].present?
        session[:force_web_layout] = nil
      else
        session[:force_web_layout] = true      
      end
      redirect_to :controller => :home, :action => :index
    end
        
    def load_foursquare_places
      @latitude = params[:latitude]
      @longitude = params[:longitude]
      @query = params[:q] || ''
      if @foursquare = current_user.oauth_for_site_token('foursquare')
        @foursquare_places = @foursquare.nearby_places(@latitude, @longitude, @query)
        respond_to do |format|
          format.js
        end        
      end
      if current_user and @latitude and @longitude
        location_context = LocationContext.create({:context_about => 'register_location',
                                                   :user_id => current_user.id,
                                                   :latitude => @latitude,
                                                   :longitude => @longitude})
        # logger.warn "SIMPLEGEO : metro: #{@location_context.population_density}, temperature: #{@location_context.temperature_f}, weather: #{@location_context.weather_conditions}, place_name: #{@location_context.place_name}, guess: #{@location_context.foursquare_guess}"
      end
    end
    
    # Location stored on first page request, or when needed using @request_location
    def store_location
      if current_user and params[:longitude].present? and params[:latitude].present?
        #@location_context = LocationContext.create({:context_about => 'register_location',
        #                                           :user_id => current_user.id,
        #                                           :latitude => params[:latitude],
        #                                           :longitude => params[:longitude]})
        # logger.warn "SIMPLEGEO : metro: #{@location_context.population_density}, temperature: #{@location_context.temperature_f}, weather: #{@location_context.weather_conditions}, place_name: #{@location_context.place_name}, guess: #{@location_context.foursquare_guess}"
      end
      render :text => 'saved location.'
    end
                
    def reset_account
      if !@user.admin?
        current_user.close_account_and_destroy_everything
      end
      redirect_to :action => :logout    
    end

    def logout
      cookies[:u] = {:value => '', :expires => Time.at(0), :domain => COOKIE_DOMAIN}
      cookies[:u] = {:value => '', :expires => Time.at(0), :domain => DOMAIN}
      cookies.delete :u
      cookies.delete :u, :domain => ".beta#{COOKIE_DOMAIN}"
      cookies.delete :u, :domain => COOKIE_DOMAIN
      TrackedAction.add(:logged_out, current_user) if current_user
      redirect_to destroy_user_session_path
    end
    
    # For unsupported mobile browsers
    def unsupported
    
    end
    
    def migrate_user
      if @_user and params[:user].present? and params[:user][:email].present? and params[:user][:password].present?
        @_user.email = params[:user][:email]
        @_user.password = params[:user][:password]
        begin 
          @_user.save!
          sign_in(:user, @_user) 
          redirect_to request.referer 
          return
        rescue => e          
          flash[:message] = e.message
        end
      end
      redirect_to :controller => :sessions, :action => :new
    end

end
