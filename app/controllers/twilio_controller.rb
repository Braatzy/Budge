class TwilioController < ApplicationController

  protect_from_forgery :except => [:sms, :robocall] 

  # Incoming SMS message
  # Parameters: {"FromState"=>"WA", "ToState"=>"WA", "AccountSid"=>"ACdea0fb266d9c82e83254c40f7e7ea11f", "Body"=>"Hello Twilio", "SmsMessageSid"=>"SM1216c246f6a6e9dfcd264867a060022a", "FromCity"=>"SEATTLE", "From"=>"+12063559718", "SmsStatus"=>"received", "To"=>"+12064384546", "FromCountry"=>"US", "FromZip"=>"98122", "ToCity"=>"SEATTLE", "ToZip"=>"98503", "ToCountry"=>"US", "SmsSid"=>"SM1216c246f6a6e9dfcd264867a060022a", "ApiVersion"=>"2010-04-01"}
  
  # {"FromState"=>"WA", "ToState"=>"WA", "AccountSid"=>"ACdea0fb266d9c82e83254c40f7e7ea11f", "Body"=>"Y", "SmsMessageSid"=>"SMce8fb62cf8e2c41c85a284f738428d7c", "FromCity"=>"SEATTLE", "From"=>"+12063559718", "action"=>"sms", "SmsStatus"=>"received", "To"=>"+12064384546", "FromCountry"=>"US", "FromZip"=>"98122", "ToCity"=>"SEATTLE", "controller"=>"twilio", "ToZip"=>"98503", "ToCountry"=>"US", "SmsSid"=>"SMce8fb62cf8e2c41c85a284f738428d7c", "ApiVersion"=>"2010-04-01"}
  def sms
    phone_normalized = params['From'].gsub(/\D/, "")
    user = User.where(:phone_normalized => phone_normalized).order('last_logged_in DESC').first
    if user.present?
      if params['Body'].downcase.strip == 'stop' 
        user.update_attribute(:contact_by_sms_pref => 0)
        TrackedAction.add(:turned_off_sms_reminders, user)
        TwilioApi.send_text(user.phone, "Text message reminders have been turned off. If you change your mind, you can turn them on again: http://#{DOMAIN}/settings")

      elsif params['Body'].downcase.strip == 'y' 
      
        if !user.phone_verified?         
          # If this is the first time that they've verified their phone, give them 10 level up credits
          level_up_credits = 0
          if TrackedAction.find(:first, :conditions => ['token = ? AND user_id = ?', 'verified_phone', user.id]).blank?
            level_up_credits = 10
          end
          user.update_attributes({:phone_verified => true, 
                                   :level_up_credits => user.level_up_credits+level_up_credits,
                                   :total_level_up_credits_earned => user.total_level_up_credits_earned+level_up_credits})
          TrackedAction.add(:verified_phone, user)
          TwilioApi.send_text(user.phone, "Thank you, #{user.name}! Add this number to your contacts, and come visit us at http://#{DOMAIN}")    
        else
          TrackedAction.add(:verified_phone, user)
          TwilioApi.send_text(user.phone, "Thank you, #{user.name}! Add this number to your contacts, and come visit us at http://#{DOMAIN}")
         
        end
        
      elsif user.phone_verified?

        if params['Body'].present?
          @results = Checkin.parse_text_checkin(params['Body'])
        end
        
        # Array of each trait that was checked in to, with checkin objects
        @checkin_results = Array.new
    
        # Go through the results, and check in to each one as necessary
        if @results.present? 
          @results.each do |result|
            trait = result[:trait]
            next unless trait
            if trait.answer_type == ':text'
              checkin_hash = {:raw_text => params['Body'],
                              :amount_text => result[:text],
                              :amount_decimal => 1,
                              :checkin_via => 'sms'}
            else
              checkin_hash = {:raw_text => params['Body'],
                              :amount_decimal => result[:quantity],
                              :checkin_via => 'sms'}
            end
            checkin_result = {:trait => trait,        
                              :checkins => trait.save_checkins_for_user(user, checkin_hash)}
            @checkin_results << checkin_result
          end
        end

        if @checkin_results.blank?
          # Send to Buster for troubleshooting...
          if buster = User.find_by_twitter_username('busterbenson') and user != buster
            TwilioApi.send_text(User.find_by_twitter_username('busterbenson').phone, "#{user.name} attempted: #{params['Body']}")
          end
          
          # Eventually I can be smarter about creating a player_message from this...
          TwilioApi.send_text(user.phone, "Shoot, I wasn't quite able to understand that. Brush up on your Budge-ese here: http://bud.ge/help/checkin")
        
        else
          p "CHECKED IN: #{@checkin_results.map{|c|c.inspect}.join(', ')}"
        end
      end
    else
      TwilioApi.send_text(phone_normalized, "Start playing Budge right here! http://bud.ge/beta/sms?p=#{phone_normalized}&s=#{(phone_normalized.to_i/32).to_s(32)}}")    
    end
    
    render :text => "", :layout => false
  end
  
  def robocall
    if current_user
      user = current_user
    else
      phone_normalized = params['Called'].gsub(/\D/, "") if params['Called']
      user = User.where(:phone_normalized => phone_normalized).order('last_logged_in DESC').first
    end
  
    if user.present?
      if params[:id] == 'launch_demo_woman'
        @xml = Twilio::TwiML::Response.new do |r|
          r.Pause
          r.Pause
          r.Say "Hello April! This is Budge.", :voice => 'woman', :language => 'en'
          r.Pause
          r.Say "I'm calling to nag you about push up animal", :voice => 'woman', :language => 'en'
          r.Pause
          r.Say "I'm not angry that you haven't done your pushups yet today. Just disappointed.", :voice => 'woman', :language => 'en'
          r.Pause
          r.Say "If you'd like to make up for it, please come on stage right now and do some push ups for everyone here at Launch!", :voice => 'woman', :language => 'en'
        end

      elsif params[:id] == 'launch_demo_man'
        @xml = Twilio::TwiML::Response.new do |r|
          r.Pause
          r.Pause
          r.Say "Hello April! This is Budge.", :voice => 'man', :language => 'en'
          r.Pause
          r.Say "I'm calling to nag you about push up animal", :voice => 'man', :language => 'en'
          r.Pause
          r.Say "I'm not angry that you haven't done your pushups yet today. Just disappointed.", :voice => 'man', :language => 'en'
          r.Pause
          r.Say "If you'd like to make up for it, please come on stage right now and do some push ups for everyone here at Launch!", :voice => 'man', :language => 'en'
        end
      
      elsif params[:id] == 'nag_mode' and user.nag_mode_is_on?
        nag_mode_prompt = NagModePrompt.find(params[:id2])
        user_nag_mode = user.user_nag_mode
        program_player = user_nag_mode.program_player
        user.contact_them(:sms, :robocall_nag_followup, nag_mode_prompt)

        @xml = Twilio::TwiML::Response.new do |r|
          r.Say "Hello there, #{user.first_name}. This is Budge.", :voice => 'woman', :language => 'en'
          r.Say "I'm calling to nag you about #{program_player.program.name}", :voice => 'woman', :language => 'en'
          r.Say nag_mode_prompt.parsed_message(:user => user, :user_nag_mode => user_nag_mode), :voice => 'woman', :language => 'en'
          r.Pause
          r.Say "I'll send you a text. Bye!", :voice => 'woman', :language => 'en'          
        end

      else
        @xml = Twilio::TwiML::Response.new do |r|
          r.Say "Hello there, #{user.first_name}", :voice => 'woman', :language => 'en'
        end      
      end
    
    else
      @xml = Twilio::TwiML::Response.new do |r|
        r.Say "My sincere apologies. this is a wrong number. Good bye!", :voice => 'woman'
      end
    end
    render :xml => @xml.text, :layout => false
  end
end
