class Mailer < ActionMailer::Base
  default_url_options[:host] = (Rails.env == 'production' ? 'bud.ge' : 'budge.dev')
  default :from => "Budge <#{(Rails.env == 'production' ? '[support email address]' : '[test support email address]')}>"

  def general_notice(user = nil, message_data = Hash.new)
    
    if user.present?
      @user = user
      @to_name = message_data[:to_user_name].present? ? message_data[:to_user_name] : @user.name
      # Don't send out email from non-production unless it's someone in the beta 
      if user.email.present? # and user.email_verified?
        email_with_name = "#{@user.name} <#{@user.email}>"
      else
        email_with_name = "#{@user.name} <[test support email address]>"      
      end

    else
      @user = User.new(:name => message_data[:to_user_name],
                       :email => message_data[:to_email])
    end
    @message_data = message_data
    @message = message_data[:message]
    @pre_message = message_data[:pre_message]
    @notification_url = message_data[:notification_url]
    @render_partial = message_data[:render_partial]
    @notification_url_text = message_data[:notification_url_text]
    @suppress_notification_url = true if message_data[:suppress_notification_url]
    
    # Send it
    if message_data[:bcc].present?
      mail(:to => email_with_name, :subject => message_data[:subject], :bcc => message_data[:bcc], :from => "Budge <#{(Rails.env.production? ? '[support email address]' : '[test support email address]')}>")        
    else
      mail(:to => email_with_name, :subject => message_data[:subject], :from => "Budge <#{(Rails.env.production? ? '[support email address]' : '[test support email address]')}>")    
    end
  end  
  
  def invitation_to_program(invitation)
    @invitation = invitation
    if Rails.env.production?
      email_with_name = "#{invitation.email}"
    else
      email_with_name = "Beta Budge <[test support email address]>"
    end
    # Send it
    mail(:to => email_with_name, :bcc => "[test support email address]", :subject => "#{invitation.user.name} has invited you to play #{@invitation.program.name}!")        
  end
  
  def new_application(program_player)
    @program_player = program_player
    mail(:to => "Habit Labbers <team@habitlabs.com>", :subject => "New bud.ge application from #{program_player.user.name}!")    
  end
  
  def daily_grr(daily_grr, top_25_users)
    @daily_grr = daily_grr
    @top_25_users = top_25_users
    if Rails.env.production?
      @email = 'team@habitlabs.com'
    else
      @email = '[test support email address]'
    end
    @last_14 = DailyGrr.where('date < ? AND date >= ?', @daily_grr.date, @daily_grr.date-14.days).order(:date).reverse
    mail(:to => "Habit Labbers <#{@email}>", :from => "Budge <[company email address]>", :subject => "@_v The Daily GRRRRRR! (#{@daily_grr.date.strftime('%A %B %d')} edition)")    
  end
  
  # Mail to beta testers about simplifying site (cool drawings), and how to get a sticker
  def beta_testers_12_2011(user = nil)
    user ||= User.find_by_twitter_username('busterbenson')
    @user = user
    mail(:to => "#{@user.name} <#{@user.email}>", :from => "Budge <[support email address]>", :subject => "Thanks + what's new from Budge")        
  end
  
  def message_for_habit_labbers(subject, message, data = nil)
    if Rails.env.production? 
      email_with_name = "Budge Support <[support email address]>"
    else
      email_with_name = "Budge Support <[test support email address]>"
    end
    @message = message
    @data = data
    mail(:to => email_with_name, :from => "Budge <[support email address]>", :subject => "[system] #{subject}")        
  end
end
