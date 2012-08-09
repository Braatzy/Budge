# == Schema Information
#
# Table name: oauth_tokens
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  site_token             :string(255)
#  site_name              :string(255)
#  token                  :string(255)
#  secret                 :string(255)
#  remote_name            :string(255)
#  remote_username        :string(255)
#  remote_user_id         :string(255)
#  cached_user_info       :text
#  cached_datetime        :datetime
#  working                :boolean(1)      default(TRUE)
#  created_at             :datetime
#  updated_at             :datetime
#  post_pref_on           :boolean(1)      default(FALSE)
#  friend_id_hash         :text
#  friend_id_hash_updated :datetime
#  latest_dm_id           :string(255)
#  primary_token          :boolean(1)      default(TRUE)
#

require "rexml/document"
require 'digest/md5'
require 'open-uri'

class OauthToken < ActiveRecord::Base
    belongs_to :user
    after_create :delay_update_twitter_score
    serialize :cached_user_info
    serialize :friend_id_hash
    
    APPROVE_FOR_BETA = {'busteroverload' => true,
                        'senecando' => true,
                        'stultiloquent' => true,
                        'marihuertas' => true,
                        'erinmcgovney' => true,
                        'folktrash' => true,
                        'fullcontacttmcg' => true,
                        'futileboy' => true,
                        'tannerc' => true,
                        'haikugirl' => true,
                        'octavekitten' => true,
                        'anewthought' => true,
                        'robbymet' => true,
                        'pymander' => true,
                        'katherinesmith' => true,
                        'jillcorral' => true,
                        'rach_ka' => true,
                        'joebez' => true,
                        'alicetiara' => true,
                        'jeremymeyers' => true,
                        'tannerc' => true,
                        'jackcheng' => true,
                        'irondavy' => true,
                        'adamgreenhall'=>true,
                        'budge_april'=>true,
                        'nikobenson'=>true}
    
    def self.budge_token(site_token = 'twitter')
      if Rails.env == 'production'
        if site_token == 'twitter'
          OauthToken.find_by_site_token_and_remote_username(site_token, 'budge')
        elsif site_token == 'twitter_coach'
          OauthToken.find_by_site_token_and_remote_username(site_token, 'budge')
        elsif site_token == 'facebook'
          OauthToken.find_by_site_token_and_remote_user_id(site_token, '100003064498641')              
        end
      else
        if site_token == 'twitter'
          OauthToken.find_by_site_token_and_remote_username(site_token, 'busterbudge')      
        elsif site_token == 'twitter_coach'
          OauthToken.find_by_site_token_and_remote_username(site_token, 'busterbudge')      
        elsif site_token == 'facebook'
          OauthToken.find_by_site_token_and_remote_user_id(site_token, '100003064498641')              
        end
      end
    end

    def self.create_flickr_api_sig(secret, api_key, perms)
        string = "#{secret}api_key#{api_key}perms#{perms}"
        return Digest::MD5.hexdigest(string)
    end

    def self.create_flickr_digest(secret, params)
        string = secret
        params.sort.each do |param, value|
            string += "#{param}#{value}"
        end
        return Digest::MD5.hexdigest(string)
    end
            
    def self.get_oauth_info(site_token)
        o = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
        return o[Rails.env][site_token]    
    end
    
    def self.get_consumer(site_token, alternate_site = nil)
        o = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
        oauth_info = o[Rails.env][site_token]
        site = alternate_site || oauth_info['site']
        consumer = OAuth::Consumer.new(oauth_info['consumer_key'], 
                                       oauth_info['consumer_secret'], 
                                       {:site => site})
        return consumer    
    end
    
    def self.get_request_token(site_token)
        o = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
        oauth_info = o[Rails.env][site_token]
        consumer = OAuth::Consumer.new(oauth_info['consumer_key'], 
                                       oauth_info['consumer_secret'], 
                                       {:site => oauth_info['site']})
        return consumer.get_request_token(:oauth_callback => oauth_info['callback'])
    end
    
    def get_user_info
        case self.site_token
          when 'facebook'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            if !self.cached_user_info or self.cached_datetime+7.days < Time.zone.now or !self.user
                response = access_token.get("/me?access_token=#{CGI::escape(self.token)}", 
                                            {'User-Agent'=>'Bud.ge'})

                self.cached_user_info = JSON.parse(response.body) rescue nil
                self.cached_datetime = Time.zone.now
                self.post_pref_on = true
                self.save

                # Create an account if they don't have one yet
                self.update_user_info

                # Get their facebook username if they have one
                self.user.update_attributes({:facebook_username => self.remote_username})
            end
            return self.cached_user_info 

          when 'foursquare'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            if !self.cached_user_info or self.cached_datetime+7.days > Time.zone.now
                response = access_token.get("/v2/users/self?oauth_token=#{self.token}", 
                                            {'User-Agent'=>'Bud.ge'})
                
                self.cached_user_info = JSON.parse(response.body) rescue nil
                self.cached_datetime = Time.zone.now

                if self.cached_user_info['response'].present? and self.cached_user_info['response']['user'].present?
                  self.remote_name = "#{self.cached_user_info['response']['user']['firstName']} #{self.cached_user_info['response']['user']['lastName']}"
                  self.remote_user_id = self.cached_user_info['response']['user']['id']
                end
                self.post_pref_on = true
                self.save
                
                # We can grab their phone number here if we want
                if !self.user.phone_verified? and self.cached_user_info['response'].present? and 
                  self.cached_user_info['response']['user'].present? and self.cached_user_info['response']['user']['contact'].present? and 
                  self.cached_user_info['response']['user']['contact']['phone'].present? then
                    self.user.phone = self.cached_user_info['response']['user']['contact']['phone']
                    self.user.normalize_phone_number
                    self.user.phone_verified = true
                    self.user.save
                end
                return self.cached_user_info
            else
                return self.cached_user_info
            end

          when 'twitter'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            if !self.cached_user_info or self.cached_datetime+7.days > Time.now.utc or !self.user
                response = access_token.get("/1/users/show.json?screen_name=#{self.remote_username}", 
                                            {'User-Agent'=>'Bud.ge'})

                self.cached_user_info = JSON.parse(response.body) rescue nil
                self.cached_datetime = Time.zone.now
                self.post_pref_on = true
                self.save

                # Create an account if they don't have one yet
                self.update_user_info

                # We can grab their phone number here if we want
                if self.primary_token? and self.user.present? and self.user.twitter_username != self.remote_username
                  self.user.update_attributes({:twitter_username => self.remote_username})
                end
                return self.cached_user_info
            else
                return self.cached_user_info
            end

          when 'tumblr'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            if !self.cached_user_info or self.cached_datetime+7.days > Time.zone.now
                response = access_token.get("/api/authenticate", 
                                            {'User-Agent'=>'Bud.ge'})

                self.cached_user_info = response.body
                self.cached_datetime = Time.zone.now
                self.save
                return self.cached_user_info
            else
                return self.cached_user_info
            end

          when 'fitbit'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
            
            # Not implemented yet on Fitbit's side
            return self.cached_user_info
            
            if !self.cached_user_info or self.cached_datetime+7.days > Time.zone.now
                # This is incorrect
                response = access_token.get("/1/user.json", 
                                            {'User-Agent'=>'Bud.ge'})
                self.cached_user_info = response.body
                self.cached_datetime = Time.zone.now
                self.save
                return self.cached_user_info
            else
                return self.cached_user_info
            end
            
          when 'flickr'
            consumer = OauthToken.get_consumer(self.site_token)
        
            if !self.cached_user_info or self.cached_datetime+7.days > Time.zone.now
                parsed_json = OauthToken.flickr_method('flickr.people.getInfo', {'user_id' => self.remote_user_id})

                self.cached_user_info = parsed_json
                self.cached_datetime = Time.zone.now
                self.save
                return self.cached_user_info
            else
                return self.cached_user_info
            end          
                    
        else
            return self.cached_user_info
        end
    end
    
    # Facebook and Twitter-only, for now.  Updates general user info
    def update_user_info
      return unless self.primary_token?
      
      if self.site_token == 'twitter'
        # Cached some basic info from Facebook
        if !self.cached_user_info.blank?
            self.update_attributes({:remote_name => self.cached_user_info['name']})
        else
            self.cached_user_info = Hash.new
        end
        # Create a new user if they haven't logged in before
        new_user = User.find_or_initialize_by_twitter_username(self.remote_username)
        
        # Profile photo
        new_user.photo = open("http://api.twitter.com/1/users/profile_image/#{self.remote_username}?size=original") rescue nil
        
        new_user.update_attributes({:in_beta => true,
                                    :name => self.remote_name,
                                    :time_zone => (new_user.time_zone || self.cached_user_info['time_zone'])})

        logger.warn "new Twitter user: #{new_user.errors.inspect}"                       
        
        if self.user.blank? 
            self.update_attributes({:user_id => new_user.id})
            TrackedAction.add(:signed_up, new_user)        
            TrackedAction.add(:connected_to_third_party_site, new_user)
            TrackedAction.add(:connected_to_twitter, new_user)            
        end
      
      elsif self.site_token == 'facebook'
        # Cached some basic info from Facebook
        if !self.cached_user_info.blank?
            self.update_attributes({:remote_name => self.cached_user_info['name'],
                                    :remote_user_id => self.cached_user_info['id'],
                                    :remote_username => self.cached_user_info['username']})
        else
            self.cached_user_info = Hash.new
        end
        
        # Create a new user if they haven't logged in before
        new_user = User.find_or_create_by_facebook_uid(self.remote_user_id)

        # Parse the birthday, if it exists
        birthday = Date.parse(self.cached_user_info['birthday']) rescue nil
        if birthday
            new_user.birthday_day = birthday.day
            new_user.birthday_month = birthday.month
            new_user.birthday_year = birthday.year
        end
        
        # Parse the time zone, if it exists
        if !self.cached_user_info['timezone'].blank?
            offset_seconds = self.cached_user_info['timezone'].to_i * 60 * 60
            tz = ActiveSupport::TimeZone.all.find do |z| 
                ((z.now.dst? && z.utc_offset == offset_seconds-3600) || 
                (!z.now.dst? && z.utc_offset == offset_seconds)) && 
                !["Arizona","Chihuahua","Mazatlan"].include?(z.name)
            end
            tz = ActiveSupport::TimeZone["UTC"] unless tz
            new_user.time_zone = tz.name if tz
        end

        # Profile photo
        unless new_user.photo?
            new_user.photo = open("http://graph.facebook.com/#{self.remote_username.blank? ? self.remote_user_id : self.remote_username}/picture?type=large")
        end
        
        new_user.update_attributes({:name => self.remote_name,
                                    :email => self.cached_user_info['email'],
                                    :email_verified => true,
                                    :relationship_status => self.cached_user_info['relationship_status'],
                                    :gender => self.cached_user_info['gender']})
        
        logger.warn "new user: #{new_user.errors.inspect}"                       
        
        if self.user.blank? 
            self.update_attributes({:user_id => new_user.id})
            TrackedAction.add(:signed_up, new_user)        
            TrackedAction.add(:connected_to_third_party_site, new_user)
            TrackedAction.add(:connected_to_facebook, new_user)

            # Grab all of their user budges
            UserBudge.where(:post_to_twitter => true, :remote_user_id => self.remote_user_id, :user_id => nil).each do |user_budge|
              user_budge.update_attributes({:user_id => new_user.id})
            end
        end
        return true
      end
    end
    
    def self.update_twitter_scores
      OauthToken.where(:site_token => 'twitter').select([:remote_user_id,:remote_username]).each_slice(5) do |oauth_tokens|
        usernames = oauth_tokens.map{|ot|ot.remote_username}
        OauthToken.get_klout_and_twitter_scores(usernames)  
      end
    end
    
    def delay_update_twitter_score
      self.delay.update_twitter_score
    end
    
    # Cut and paste from the self.update_twitter_scores stuff
    def update_twitter_score
      return unless self.site_token == 'twitter'

      usernames = [self.remote_username]
      begin
        OauthToken.get_klout_and_twitter_scores(usernames)     
      rescue 
        p "skipping klout and twitter scores"
      end
    end

    def self.get_klout_and_twitter_scores(usernames)
      @tweet_stat_data = Hash.new

      # Get access token for this 
      oauth_info = OauthToken.get_oauth_info('twitter')
      token_oauth_token = OauthToken.budge_token
      
      # KLOUT
      uri = URI.parse("http://api.klout.com/1/users/show.json?key=#{oauth_info['klout_key']}&users=#{usernames.join(',')}")
      p "Klout: #{uri.request_uri}"
      http = Net::HTTP.new(uri.host, uri.port)  
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      parsed_response = JSON.parse(response.body) rescue nil
      p "Klout: #{parsed_response.inspect}"
      
      if parsed_response.present? and parsed_response['users'].present?
        parsed_response['users'].each do |klout_user|
          next unless klout_user['score'].present? and klout_user['score']['kscore'].to_i > 0
          @tweet_stat_data[klout_user['twitter_screen_name']] ||= Hash.new
          @tweet_stat_data[klout_user['twitter_screen_name']].merge!({
            :twitter_screen_name => klout_user['twitter_screen_name'],
            :twitter_id => klout_user['twitter_id'],
            :klout_score => klout_user['score']['kscore'],     
            :klout_slope => klout_user['score']['slope'],
            :klout_amplification_score => klout_user['score']['amplification_score'],
            :klout_network_score => klout_user['score']['network_score'],
            :klout_true_reach => klout_user['score']['true_reach'],
            :klout_class_id => klout_user['score']['kclass_id'],
            :klout_class_name => klout_user['score']['kclass'],
            :klout_delta_1day => klout_user['score']['delta_1day'],
            :klout_delta_5day => klout_user['score']['delta_5day']})
        end
      end
      
      # Twitter stats
      consumer = OauthToken.get_consumer('twitter')
      access_token = OAuth::AccessToken.new(consumer, token_oauth_token.token, token_oauth_token.secret)
      response = access_token.get("/1/users/lookup.json?screen_name=#{usernames.join(',')}", 
                                  {'User-Agent'=>'Bud.ge'})

      parsed_twitter_json = JSON.parse(response.body) rescue nil
      p "Twitter: #{parsed_twitter_json.inspect}"

      if parsed_twitter_json.present? 
        parsed_twitter_json.each do |twitter_user|
          @tweet_stat_data[twitter_user['screen_name']] ||= Hash.new
          @tweet_stat_data[twitter_user['screen_name']].merge!({
            :twitter_screen_name => twitter_user['screen_name'],
            :twitter_id => twitter_user['id'],
            :num_followers => twitter_user['followers_count'],
            :num_following => twitter_user['friends_count'],
            :num_tweets => twitter_user['statuses_count']
          })
        end
      end
      
      @date = Time.now.utc.to_date
      @tweet_stat_data.each do |twitter_screen_name, data|
        @twitter_score = TwitterScore.find_or_initialize_by_date_and_twitter_id(@date, data[:twitter_id])
        if data[:klout_score].to_i > 0
          @twitter_score.attributes = data
          @twitter_score.save
        end
      end
      return @tweet_stat_data
    end

    def make_budge_follow_me
      budge_oauth = OauthToken.budge_token
      
      consumer = OauthToken.get_consumer('twitter')
      access_token = OAuth::AccessToken.new(consumer, budge_oauth.token, budge_oauth.secret)
      response = access_token.post("/1/friendships/create.json?screen_name=#{self.remote_username}&user_id=#{self.remote_user_id}&follow=false", 
                                  {'User-Agent'=>'Bud.ge'})

      parsed_twitter_json = JSON.parse(response.body) rescue nil
      if parsed_twitter_json.present? 
        logger.warn "response to follow request: #{parsed_twitter_json.inspect}"      
        return true
      else
        return false
      end
    end

    def can_dm_username(twitter_username)
      # Twitter stats
      consumer = OauthToken.get_consumer('twitter')
      access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
      response = access_token.get("/1/friendships/show.json?target_screen_name=#{twitter_username}", 
                                  {'User-Agent'=>'Bud.ge'})

      parsed_twitter_json = JSON.parse(response.body) rescue nil
      #p "Twitter: #{parsed_twitter_json.inspect}"
      if parsed_twitter_json['relationship'].present? and 
         parsed_twitter_json['relationship']['source'].present? and 
         parsed_twitter_json['relationship']['source']['can_dm'] == true
        return parsed_twitter_json['relationship']
      else
        return false
      end
    end

    def info_about_username(username)
      # Twitter stats
      consumer = OauthToken.get_consumer('twitter')
      access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
      response = access_token.get("/1/users/show.json?screen_name=#{username}", 
                                  {'User-Agent'=>'Bud.ge'})

      parsed_twitter_json = JSON.parse(response.body) rescue nil
      return parsed_twitter_json
    end
    
    def get_twitter_search(query, since_tweet_id = 0, results_per_page = 100)
      @tweet_stat_data = Hash.new

      @correspondence_data = {:tweets => [], :max_tweet_id => since_tweet_id, :to_geo => nil, :from_geo => nil}
      
      # Twitter stats
      # q=from:jensmccabe%20@busterbenson&result_type=recent&since_id=0
      uri = URI.parse("http://search.twitter.com/search.json?q=#{URI.encode(query)}&result_type=recent&since_id=#{since_tweet_id.present? ? since_tweet_id : 0}&rpp=#{results_per_page}&include_entities=1")
      p uri.request_uri

      # logger.warn uri.inspect
      http = Net::HTTP.new(uri.host, uri.port)  
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      parsed_twitter_json = JSON.parse(response.body) rescue nil
      p parsed_twitter_json.inspect
      if parsed_twitter_json.present? 
        parsed_twitter_json['results'].reverse.each do |result|
        
          from_user = User.find_by_twitter_username(result['from_user']) rescue nil
          to_user = User.find_by_twitter_username(result['to_user']) rescue nil
          message = {:from_user_id => (from_user.present? ? from_user.id : nil),
                     :from_remote_user => (from_user.present? ? from_user.twitter_username : nil),
                     :to_user_id => (to_user.present? ? to_user.id : nil),
                     :to_remote_user => (to_user.present? ? to_user.twitter_username : nil),
                     :content => result['text'],
                     :delivered_via => PlayerMessage::TWEET,
                     :remote_post_id => result['id_str'],
                     :message_data => result,
                     :delivered => true,
                     :deliver_at => Time.parse(result['created_at']).utc,
                     :private => false}
          @correspondence_data[:tweets] << message
          @correspondence_data[:from_geo] ||= result['geo'] if result['geo'].present?
        end
        @correspondence_data[:max_tweet_id] = parsed_twitter_json['max_id']
      end
      @correspondence_data[:tweets] = @correspondence_data[:tweets].sort_by{|m|m[:deliver_at]}
      return @correspondence_data    
    end

    # Disabled for now since friend coaching is going away
    # def self.get_twitter_correspondence(from_username, to_username, since_tweet_id = 0)
    #   return []
    # end
    
    # Only used to and from coaches with twitter_coach oauth set up
    def get_twitter_coach_dms_to(results_per_page = 100)
      @tweet_stat_data = Hash.new

      @dm_tweets = {:tweets => [], :max_tweet_id => (self.latest_dm_id.present? ? self.latest_dm_id.to_i : 0), :to_geo => nil, :from_geo => nil}
      
      # DMs to this coach
      consumer = OauthToken.get_consumer('twitter_coach')
      access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
      # count can be up to 200, I believe
      response = access_token.get("/1/direct_messages.json?count=#{results_per_page}&include_entities=true&skip_status=true", 
                                  {'User-Agent'=>'Bud.ge'})

      to_parsed_twitter_json = JSON.parse(response.body) rescue nil
      if to_parsed_twitter_json.present? 
        if to_parsed_twitter_json.include?('error')
          p to_parsed_twitter_json['error'].inspect
        else
          to_parsed_twitter_json.each do |result|
            p result.inspect
            sender_screen_name = result['sender_screen_name'] || result['screen_name']
            from_user = OauthToken.find_by_site_token_and_remote_username('twitter', "#{sender_screen_name}")
            next unless from_user.present?
            message = {:from_user_id => from_user.user_id,
                       :from_remote_user => from_user.remote_username,
                       :to_user_id => self.user_id,
                       :to_remote_user => self.remote_username,
                       :content => result['text'],
                       :delivered_via => PlayerMessage::TWEET_DM,
                       :remote_post_id => result['id_str'],
                       :message_data => result,
                       :delivered => true,
                       :deliver_at => Time.parse(result['created_at']).utc,
                       :to_coach => true,
                       :from_coach => false,
                       :private => true}
            @dm_tweets[:tweets] << message
            @dm_tweets[:max_tweet_id] = message['id'].to_i if message['id'].to_i > @dm_tweets[:max_tweet_id].to_i
          end
        end
      end

      @dm_tweets[:tweets] = @dm_tweets[:tweets].sort_by{|m|m[:deliver_at]}

      return @dm_tweets
    end

    def get_twitter_coach_dms_from(results_per_page = 100)
      @tweet_stat_data = Hash.new

      @dm_tweets = {:tweets => [], :max_tweet_id => (self.latest_dm_id.present? ? self.latest_dm_id.to_i : 0), :to_geo => nil, :from_geo => nil}
      
      # DMs to this coach
      consumer = OauthToken.get_consumer('twitter_coach')
      access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)

      # DMs from this coach
      response = access_token.get("/1/direct_messages/sent.json?count=200&include_entities=true&skip_status=true", 
                                  {'User-Agent'=>'Bud.ge'})

      parsed_twitter_json = JSON.parse(response.body) rescue nil
      if parsed_twitter_json.present? 
        if parsed_twitter_json.include?('error')
          p parsed_twitter_json['error'].inspect
        else
          parsed_twitter_json.reverse.each do |result|
            to_user = OauthToken.find_by_site_token_and_remote_username('twitter', "#{result['recipient_screen_name']}")
            next unless to_user.present?
            message = {:from_user_id => self.user_id,
                       :from_remote_user => self.remote_username,
                       :to_user_id => to_user.user_id,
                       :to_remote_user => to_user.remote_username,
                       :content => result['text'],
                       :delivered_via => PlayerMessage::TWEET_DM,
                       :remote_post_id => result['id_str'],
                       :message_data => result,
                       :delivered => true,
                       :deliver_at => Time.parse(result['created_at']).utc,
                       :to_coach => false,
                       :from_coach => true,
                       :private => true}
            @dm_tweets[:tweets] << message
            @dm_tweets[:max_tweet_id] = message['id'].to_i if message['id'].to_i > @dm_tweets[:max_tweet_id].to_i
          end
        end
      end

      @dm_tweets[:tweets] = @dm_tweets[:tweets].sort_by{|m|m[:deliver_at]}

      return @dm_tweets
    end
    
    def self.get_tweets_for_checkin_parsing
      budge_token = OauthToken.budge_token('twitter_coach')
      @tweets_mentioning_budge_hashtag = budge_token.get_twitter_search("#budge", 0, 20)
      @dms_to_budge = budge_token.get_twitter_coach_dms_to(20)
      #if @dms_to_budge[:max_tweet_id].present? and @dms_to_budge[:max_tweet_id].to_i > budge_token.latest_dm_id
        #budge_token.update_attributes(:latest_dm_id => @dms_to_budge[:max_tweet_id])
      #end
      
      p "hashtag: #{@tweets_mentioning_budge_hashtag[:tweets].size}"
      p "dm budge: #{@dms_to_budge[:tweets].size}"

      @unique_tweet_ids = Hash.new
      @all_unique_tweets = Array.new
      if @tweets_mentioning_budge_hashtag.present? and @tweets_mentioning_budge_hashtag[:tweets].present?
        @tweets_mentioning_budge_hashtag[:tweets].each do |tweet|
          next unless tweet[:from_user_id].present? # Only collect tweets from Budge users
          next unless tweet[:message_data]['entities']['hashtags'].select{|h|h['text'].downcase == 'budge'}.size > 0
          unless @unique_tweet_ids[tweet[:remote_post_id]].present?
            @unique_tweet_ids[tweet[:remote_post_id]] = true
            @all_unique_tweets << tweet
          end
        end
      end

      if @dms_to_budge.present? and @dms_to_budge[:tweets].present?
        @dms_to_budge[:tweets].each do |tweet|
          next unless tweet[:from_user_id].present? # Only collect tweets from Budge users
          unless @unique_tweet_ids[tweet[:remote_post_id]].present?
            @unique_tweet_ids[tweet[:remote_post_id]] = true
            @all_unique_tweets << tweet
          end
        end
      end
     
      @checkin_results = Array.new
      if @all_unique_tweets.present?
        @all_unique_tweets.sort_by{|t|t[:deliver_at]}.each do |tweet|
          # Check for an existing checkin with this tweet id (only save a tweet once)
          checkin_via = (tweet[:private] ? 'twitter_dm' : 'twitter')
          existing_checkin = Checkin.where(:checkin_via => checkin_via, :remote_id => tweet[:remote_post_id].to_s).first
          next if existing_checkin.present?

          if tweet[:private]
            p "dm from #{tweet[:from_remote_user]}: #{tweet[:content]}"          
            parse_text = tweet[:content]
          else
            p "#{tweet[:from_remote_user]}: #{tweet[:content]}"
            parse_text = tweet[:content].gsub(/\#budge/,'')
          end
          if results = Checkin.parse_text_checkin(parse_text) and results.present?
            p " - pre: #{parse_text}"
            p " - post: #{Checkin.parse_text_checkin(parse_text).inspect}"

            # Only use the first result...
            result = results.first
            trait = result[:trait]
            
            if trait.present? 
              if trait.answer_type == ':text'
                checkin_hash = {:raw_text => tweet[:content],
                                :amount_text => result[:text],
                                :amount_decimal => 1,
                                :checkin_via => checkin_via,
                                :remote_id => tweet[:remote_post_id]}
              else
                checkin_hash = {:raw_text => tweet[:content],
                                :amount_decimal => result[:quantity],
                                :checkin_via => checkin_via,
                                :remote_id => tweet[:remote_post_id]}
                checkin_result = {:trait => trait,        
                                  :checkins => trait.save_checkins_for_user(User.find(tweet[:from_user_id]), checkin_hash)}              
              end
              checkin_result = {:trait => trait,        
                                :checkins => trait.save_checkins_for_user(User.find(tweet[:from_user_id]), checkin_hash)}                
              @checkin_results << checkin_result
            end
          end
        end
      end
      return @checkin_results
    end
    
    # This is only needed once for the entire app.  Awesome, right?
    def self.subscribe_to_facebook_realtime_updates
    
      # First, get a special access token for this particular kind of request
      oauth_info = OauthToken.get_oauth_info('facebook')
      uri = URI.parse("https://graph.facebook.com/oauth/access_token")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      new_params = {:client_id => oauth_info['consumer_key'],
                    :client_secret => oauth_info['consumer_secret'],
                    :grant_type => 'client_credentials'}
      
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(new_params)
      response = http.request(request)
      
      # Here it is!
      special_access_token = response.body.split('=')[1]
      
      uri = URI.parse("https://graph.facebook.com/#{oauth_info['consumer_key']}/subscriptions")
      sub_params = {:access_token => special_access_token,
                    :object => 'user',
                    :fields => 'name,picture,email,checkins',
                    :callback_url => oauth_info['subscription_callback'],
                    :verify_token => "1234"}
      
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(sub_params)
      response = http.request(request)

    end
    
    # https://api.facebook.com/method/fql.query?query=SELECT%20name,online_presence%20FROM%20user%20where%20uid%20=%20500528646
    def is_online?
    
    end
    
    # https://api.foursquare.com/v2/venues/search    
    def nearby_places(latitude, longitude, q = '')
      return nil unless self.site_token == 'foursquare'
      consumer = OauthToken.get_consumer(self.site_token)
      access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
      response = access_token.get("/v2/venues/search?oauth_token=#{self.token}&ll=#{latitude},#{longitude}&query=#{CGI::escape(q)}&limit=50&v=20110609", 
                                  {'User-Agent'=>'Bud.ge'})
      parsed_response = JSON.parse(response.body) rescue nil
      @results = Hash.new
      
      # Old, deprecated version (delete eventually)
      if parsed_response['response']['groups'].present?
        parsed_response['response']['groups'].each do |group|
            @results[group['type']] = {:name => group['name'],
                                       :items => Array.new}
            group['items'].each do |item|
                item['category'] = (item['categories'].present? ? item['categories'].select{|i|i['primary'] == true}.first : '')
                @results[group['type']][:items] << item
            end
        end        
        
      # New version as of 2011-06-09
      elsif parsed_response['response']['venues'].present?
        @results["results"] = {:name => "results",
                               :items => Array.new}
        parsed_response['response']['venues'].each do |venue|
          venue['category'] = (venue['categories'].present? ? venue['categories'].select{|i|i['primary'] == true}.first : '')
          @results['results'][:items] << venue
        end              
      end
      return @results
    end

    # https://api.foursquare.com/v2/venues/search    
    def self.nearby_places(latitude, longitude, q = '')
      # First, get a special access token for this particular kind of request
      oauth_info = OauthToken.get_oauth_info('foursquare')
      uri = URI.parse("#{oauth_info['site']}/v2/venues/search?client_id=#{oauth_info['consumer_key']}&client_secret=#{oauth_info['consumer_secret']}&ll=#{latitude},#{longitude}&query=#{CGI::escape(q)}&limit=50&v=20110609")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)

      parsed_response = JSON.parse(response.body) rescue nil
      @results = Hash.new
      
      # New version as of 2011-06-09
      if parsed_response['response']['venues'].present?
        @results["results"] = {:name => "results",
                               :items => Array.new}
        parsed_response['response']['venues'].each do |venue|
          venue['category'] = (venue['categories'].present? ? venue['categories'].select{|i|i['primary'] == true}.first : '')
          @results['results'][:items] << venue
        end              
      end
      return @results
    end
    
    # http://api.simplegeo.com/1.0/context/{lat},{lon}.json    
    # SimpleGeo::Client info: https://github.com/simplegeo/simplegeo-ruby/blob/master/spec/client_spec.rb
    def self.simplegeo_context(latitude, longitude)
        o = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
        oauth_info = o[Rails.env]['simplegeo']
        SimpleGeo::Client.set_credentials(oauth_info['consumer_key'], oauth_info['consumer_secret'])
        context_info = SimpleGeo::Client.get_context(latitude,longitude)
        # logger.warn "context_info: #{context_info.inspect}"
        return context_info
    end
    
    # Post to the respective network (Facebook, Twitter, Foursquare, etc)
    # The options hash needs:
    # :okay_to_post (overrides private_beta flag)
    # :for_object
    # :for_id
    # :message
    # :name (facebook)
    # :caption (facebook)
    # :latitude
    # :longitude
    # :foursquare_place_id (foursquare)
    def broadcast_to_network(options = Hash.new)
      return false unless options[:for_object].present? and options[:for_id].present?
      consumer = OauthToken.get_consumer(self.site_token)
      access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)

      # Create a notification object
      unless notification = Notification.find_by_for_object_and_for_id(options[:for_object], options[:for_id])
        notification = Notification.create({
                        :user_id => nil,
                        :delivered_via => self.site_token,
                        :message_style_token => 'user_generated',
                        :message_data => {:data => options},
                        :for_object => options[:for_object],
                        :from_user_id => self.user_id,
                        :from_system => false,
                        :for_id => options[:for_id],
                        :delivered_immediately => true,
                        :broadcast => true,
                        :remote_site_token => self.site_token})
      end
      options[:notification_url] = notification.url
      time_now = Time.now
      time_in_user_time_zone = time_now.in_time_zone(self.user.time_zone_or_default)
  
      case self.site_token
        when 'facebook'
          new_params = {:access_token => self.token}
          new_params.merge!({:message => options[:message], 
                             :link => options[:notification_url],
                             :name => options[:name],
                             :caption => options[:caption],
                             :description => '',
                             :actions => "{'name': 'View on Budge', 'link': '#{options[:notification_url]}'}", 
                             :source => ""})

          if (!Rails.env.production? or PRIVATE_BETA) and !options[:okay_to_post]
            # Dont' post to Facebook!
          else
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
            response = access_token.post("/#{self.remote_user_id}/feed", new_params, {'User-Agent'=>'Bud.ge'})
            parsed_response = JSON.parse(response.body) rescue nil
          end
          if parsed_response.present? and parsed_response['id'].present?
            # Mark this notification as delivered.
            notification.update_attributes({:delivered => true,
                                            :delivered_at => time_now.utc,
                                            :delivered_hour_of_day => time_in_user_time_zone.hour,
                                            :delivered_day_of_week => time_in_user_time_zone.wday,
                                            :delivered_week_of_year => time_in_user_time_zone.strftime('%W').to_i,
                                            :delivered_immediately => true,
                                            :delivered_off_hours => self.user.is_off_hours?,
                                            :remote_post_id => parsed_response['id']})
            return parsed_response['id']
          end
        
        when 'twitter'
          if (!Rails.env.production? or PRIVATE_BETA) and !options[:okay_to_post]
              # Dont' post to Twitter!
          else
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
            response = access_token.post("/1/statuses/update.json",
                                         {:oauth_token => CGI::escape(self.token),
                                          :trim_user => 1,
                                          :status => (options[:message]+' '+options[:notification_url]),
                                          :lat => options[:latitude],
                                          :lon => options[:longitude],
                                          :include_entities => 1}, 
                                         {'User-Agent'=>'Bud.ge'})
            parsed_response = JSON.parse(response.body) rescue nil
            # logger.warn "parsed response: #{parsed_response.inspect}"
            p "parsed response: #{parsed_response.inspect}"
          end
          if parsed_response.present?
            # Mark this notification as delivered.
            notification.update_attributes({:delivered => true,
                                            :delivered_at => time_now.utc,
                                            :delivered_hour_of_day => time_in_user_time_zone.hour,
                                            :delivered_day_of_week => time_in_user_time_zone.wday,
                                            :delivered_week_of_year => time_in_user_time_zone.strftime('%W').to_i,
                                            :delivered_immediately => true,
                                            :delivered_off_hours => self.user.is_off_hours?,
                                            :remote_post_id => parsed_response['id_str']})
            return parsed_response['id_str']                           
          end            

        when 'foursquare'
          if (!Rails.env.production? or PRIVATE_BETA) and !options[:okay_to_post]
            # Dont' post to Foursquare!
          else
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
            response = access_token.post("/v2/checkins/add",
                                         {:oauth_token => CGI::escape(self.token),
                                          :venueId => options[:foursquare_place_id],
                                          :shout => (options[:message]+' ('+rand(1000).to_s+') '+options[:notification_url]),
                                          :ll => "#{options[:latitude]},#{options[:longitude]}",
                                          :broadcast => 'public'}, 
                                         {'User-Agent'=>'Bud.ge'})
            parsed_response = JSON.parse(response.body) rescue nil
          end
          if parsed_response.present? and parsed_response['response']['id'].present?
            # Mark this notification as delivered.
            notification.update_attributes({:delivered => true,
                                            :delivered_at => time_now.utc,
                                            :delivered_hour_of_day => time_in_user_time_zone.hour,
                                            :delivered_day_of_week => time_in_user_time_zone.wday,
                                            :delivered_week_of_year => time_in_user_time_zone.strftime('%W').to_i,
                                            :delivered_immediately => true,
                                            :delivered_off_hours => self.user.is_off_hours?,
                                            :remote_post_id => parsed_response['response']['id']})
            return parse_response['response']['id']
          end            
      end    
      return false
    end
    
    def dm_followers(number_to_invite = 1, send_invites = false)
      case self.site_token
        when 'twitter'
          consumer = OauthToken.get_consumer(self.site_token)
          access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
      
          cursor = -1
          @twitter_follower_ids = Hash.new(false)
          while (cursor != 0) 
            response = access_token.get("/1/followers/ids.json?cursor=#{cursor}", 
                                        {'User-Agent'=>'Bud.ge'})
            parsed_response = JSON.parse(response.body) rescue nil

            if parsed_response.present? and parsed_response['ids']
              if parsed_response['ids'].blank?
                cursor = 0
              else
                parsed_response['ids'].each do |twitter_user_id|
                  oauth_token = OauthToken.where(:site_token => 'twitter', :primary_token => true, :remote_user_id => twitter_user_id.to_s).select{|ua|ua.user.present? and !ua.user.in_beta? and !ua.user.invited_to_beta?}.first
                  if oauth_token.present? and !@twitter_follower_ids[twitter_user_id].present?
                    @twitter_follower_ids[twitter_user_id] = oauth_token
                  end
                end
                cursor = parsed_response['next_cursor']
              end
            else
              cursor = 0
            end
          end
      end
      if send_invites and @twitter_follower_ids.present?
        @twitter_follower_ids.sort_by{|id,ot|ot.created_at}[0..(number_to_invite-1)].each do |twitter_user_id, oauth_token|
          if oauth_token.user.contact_them(:dm_tweet, :invite_to_beta_cohort, 'launch')
            oauth_token.make_budge_follow_me
            oauth_token.user.update_attributes(:invited_to_beta => true)
          end
        end
      else
        p "About to invite #{@twitter_follower_ids.size}: #{@twitter_follower_ids.map{|id, ua|ua.user.twitter_username}.join(', ')}"
      end
    end
    
    def get_friends
        case self.site_token
          when 'twitter'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            cursor = -1
            @twitter_friend_screen_names = Hash.new(false)
            while (cursor != 0) 
                response = access_token.get("/1/statuses/friends.json?cursor=#{cursor}", 
                                            {'User-Agent'=>'Bud.ge'})
                parsed_response = JSON.parse(response.body) rescue nil

                if parsed_response.present? and parsed_response['users']
                    if parsed_response['users'].blank?
                        cursor = 0
                    else
                        parsed_response['users'].each do |user|
                            @twitter_friend_screen_names[user['screen_name']] = true
                        end
                        cursor = parsed_response['next_cursor']
                    end
                else
                    cursor = 0
                end
            end
            self.update_attributes({:friend_id_hash => @twitter_friend_screen_names,
                                    :friend_id_hash_updated => Time.now.utc})
            if !@twitter_friend_screen_names.keys.blank?
                @twitter_friends_oauth = OauthToken.where(['site_token = ? AND remote_username IN (?)', 'twitter', 
                                                           @twitter_friend_screen_names.keys]).includes(:user)
                return @twitter_friends_oauth.map{|ot|ot.user}
            else
                return []
            end
          when 'facebook'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            response = access_token.get("/me/friends?access_token=#{CGI::escape(self.token)}", 
                                        {'User-Agent'=>'Bud.ge'})

            parsed_response = JSON.parse(response.body) rescue nil
            if parsed_response.present? and parsed_response['data'].present?  
                @facebook_friend_ids = {}
                parsed_response["data"].each do |facebook_friend|
                    @facebook_friend_ids[facebook_friend['id']] = true
                end
                if !@facebook_friend_ids.blank?
                    self.update_attributes({:friend_id_hash => @facebook_friend_ids,
                                            :friend_id_hash_updated => Time.now.utc})
                    @facebook_friends_oauth = OauthToken.where(['site_token = ? AND remote_user_id IN (?)', 'facebook', 
                                                                @facebook_friend_ids.keys]).includes(:user)
                    return @facebook_friends_oauth.map{|ot|ot.user}
                else
                    return []
                end
            else
                return []
            end

          when 'foursquare'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret) rescue nil
            return [] unless access_token.present?
        
            response = access_token.get("/v2/users/#{self.remote_user_id}/friends?oauth_token=#{CGI::escape(self.token)}", 
                                        {'User-Agent'=>'Bud.ge'})
            parsed_response = JSON.parse(response.body) rescue nil

            if parsed_response and parsed_response['response']['friends'].present?
                @foursquare_friend_ids = {}
                parsed_response['response']['friends']['items'].each do |foursquare_friend|
                    @foursquare_friend_ids[foursquare_friend['id']] = true
                end
                if !@foursquare_friend_ids.blank?
                    self.update_attributes({:friend_id_hash => @foursquare_friend_ids,
                                            :friend_id_hash_updated => Time.now.utc})

                    @foursquare_friend_oauth = OauthToken.where(['site_token = ? AND remote_user_id IN (?)', 'foursquare', @foursquare_friend_ids.keys]).includes(:user)
                    return @foursquare_friend_oauth.map{|ot|ot.user}
                else
                    return []
                end
            else
                return []
            end
        end    
    end
    
    def search_friends(query)
      case self.site_token
        when 'facebook'
          consumer = OauthToken.get_consumer(self.site_token)
          access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
      
          response = access_token.get("/search?access_token=#{CGI::escape(self.token)}&type=user&q=#{CGI::escape(query)}&limit=1000", 
                                      {'User-Agent'=>'Bud.ge'})

          parsed_response = JSON.parse(response.body) rescue nil
          if parsed_response and parsed_response['data'].present?  
            @facebook_friends = []
            parsed_response["data"].each do |facebook_friend|
              next unless self.friend_id_hash.present? and self.friend_id_hash[facebook_friend['id']] == true
              @facebook_friends << {:id => facebook_friend['id'],
                                    :name => facebook_friend['name']}
            end
            return @facebook_friends
          else
              return []
          end
          
        when 'twitter'
          consumer = OauthToken.get_consumer(self.site_token)
          access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
      
          @twitter_friends = []
          response = access_token.get("/1/users/search.json?q=#{CGI::escape(query)}", 
                                      {'User-Agent'=>'Bud.ge'})
          parsed_response = JSON.parse(response.body) rescue nil
          if parsed_response.present?
            parsed_response.each do |user|
                next unless self.friend_id_hash.present? and self.friend_id_hash[user['screen_name']] == true
                @twitter_friends << {:id => user['id'],
                                     :name => user['screen_name']}
            end
            return @twitter_friends
          else
            return []
          end          
      end
    end
    
    def read_stream
        case self.site_token
          when 'twitter'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            response = access_token.get("/statuses/user_timeline.json", 
                                        {'User-Agent'=>'Bud.ge'})
          
          when 'tumblr'
            consumer = OauthToken.get_consumer(self.site_token, "http://#{self.remote_username}.tumblr.com")
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            response = access_token.get("/api/read", 
                                        {'User-Agent'=>'Bud.ge'})

          when 'facebook'
            consumer = OauthToken.get_consumer(self.site_token)
            access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
            response = access_token.get("/me/feed?access_token=#{CGI::escape(self.token)}", 
                                        {'User-Agent'=>'Bud.ge'})
        end
    end

    # action = award or revoke
    BADGE_NAME_TO_ID = {'yellow' => '4c9bd0375d12199c992049ca', 
                        'orange' => '4c9bd03a5d12199c9c2049ca', 
                        'green' => '4c9bd03e5d12199ca02049ca', 
                        'purple' => '4c9bd0415d12199ca62049ca'}
                        
    def foursquare_award_badge(badge_name, action = 'award')
        raise "This isn't a foursquare token" unless self.site_token == 'foursquare'

        oauth_info = OauthToken.get_oauth_info('foursquare')
        consumer = OauthToken.get_consumer(self.site_token, "https://api.foursquare.com")
        access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
        
        path = "/v2/badge/#{BADGE_NAME_TO_ID[badge_name]}/#{action}?oauth_token=#{CGI::escape(self.secret)}"
        response = access_token.post(path, {'User-Agent'=>'Bud.ge'})
        
        # {\"meta\":{\"code\":200},\"response\":{\"id\":221,\"name\":\"HM Yellow\",\"icon\":\"http://foursquare.com/img/badge/filename.png\",\"description\":\"HM Yellow -- TBD\"}}
        # has badge: {\"response\"=>{}, \"meta\"=>{\"code\"=>400, \"message\"=>\"user_has_badge\"}}
        return JSON.parse(response.body) rescue nil   
    end
    
    def self.flickr_method(method, params = {})
        oauth_info = OauthToken.get_oauth_info('flickr')
        params.merge!({'api_key' => oauth_info['consumer_key'],
                       'method'  => method,
                       'format'  => 'json'})
                       
        digest = OauthToken.create_flickr_digest(oauth_info['consumer_secret'], params)
        params[:api_sig] = digest

        uri = URI.parse("http://api.flickr.com/services/rest/")
        http = Net::HTTP.new(uri.host, uri.port)

        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data(params)
        response = http.request(request)

        if response.body.match(/jsonFlickrApi/)
            json = response.body.scan(/jsonFlickrApi\((.*)\)$/).flatten.to_s
            parsed_json = JSON.parse(json)
        else
            parsed_json = JSON.parse(response.body)            
        end

        return parsed_json
    end
    
    # BODY: "{\"activities\":[],\"summary\":{\"activeScore\":218,\"caloriesOut\":2603,\"distances\":[{\"activity\":\"total\",\"distance\":0}],\"fairlyActiveMinutes\":33,\"lightlyActiveMinutes\":40,\"sedentaryMinutes\":1358,\"steps\":2282,\"veryActiveMinutes\":9}}"
    
    def self.fitbit_stats_for_user_and_date(user, date)
        begin
            fitbit_oauth_token = user.oauth_tokens.find(:first, :conditions => ['site_token = ?', 'fitbit'])
            # logger.warn fitbit_oauth_token.inspect
            return nil unless fitbit_oauth_token
    
            oauth_info = OauthToken.get_oauth_info('fitbit')
            consumer = OauthToken.get_consumer(fitbit_oauth_token.site_token)
            access_token = OAuth::AccessToken.new(consumer, fitbit_oauth_token.token, fitbit_oauth_token.secret)
            path = "/1/user/-/activities/date/#{date}.json"
            response = access_token.post(path, {'User-Agent'=>'Bud.ge'})
            parsed_json = JSON.parse(response.body)                
        rescue => e
            return nil
        end
        return parsed_json
    end
    
    ### Delayed Jobs ###
    
    # Autofollo friends on this network.  If they're already in the system, don't flip the invisible flag
    def autofollow_friends
      friends = self.get_friends || []
      p "found #{friends.size} #{self.site_token} friends for #{self.user.name}"
      return [] unless friends.present?
      new_relationships = []
      
      friends.each do |fuser|
        next unless fuser
        relationship = Relationship.where(['user_id = ? AND followed_user_id = ?',
                                           self.user_id, fuser.id]).first
        if relationship
          relationship.attributes = {:found_on_other_network => true}
            
        else
          relationship = Relationship.new({:user_id => self.user_id,
                               :followed_user_id => fuser.id,
                               :found_on_other_network => true,
                               :read => false, 
                               :invisible => false,
                               :auto => true})
        end
        relationship.from ||= self.site_token
        if self.site_token == 'facebook'
          relationship.facebook_friends = true
        elsif self.site_token == 'twitter'
          relationship.twitter_friends = true
        elsif self.site_token == 'foursquare'
          relationship.foursquare_friends = true                    
        end
        if relationship.save
          new_relationships << relationship
        end
      end
      return new_relationships           
    end
    
    def self.autofollow_friends(oauth_token_id)
      OauthToken.find(oauth_token_id).autofollow_friends rescue nil
    end
        
    # https://graph.facebook.com/me/YOUR_NAMESPACE:cook?recipe=OBJECT_URL&access_token=ACCESS_TOKEN
    def save_graph_action(og_object, og_action, og_url)
      return false unless self.site_token == 'facebook'

      consumer = OauthToken.get_consumer(self.site_token)
      access_token = OAuth::AccessToken.new(consumer, self.token, self.secret)
  
      response = access_token.post("/me/#{OPEN_GRAPH_NS}:#{og_action}?#{og_object}=#{og_url}&access_token=#{CGI::escape(self.token)}", 
                                   {'User-Agent'=>'Bud.ge'})

      parsed_response = JSON.parse(response.body) rescue nil
      p parsed_response.inspect
    end
end
