require 'hominid'
class WaitingRoomController < ApplicationController
  layout 'homepage'
  before_filter :authenticate_user!, :except => [:index, :application, :switch_to_mobile, :request_invite]
  
  def index
    @show_waiting_msg=false
    if current_user 
      redirect_to :controller => :stream, :action => :index
      return
    else
      redirect_to :controller => :store, :action => :index, :host => SECURE_DOMAIN, :protocol => 'https://'      
    end
  end
  
  def switch_to_mobile
    if current_user and current_user.phone_verified?
      if params[:sent] == '1'
        @text_sent = true      
      
      elsif params[:resend] == '1'
        code = TwilioApi.send_text(current_user.phone_normalized, "#{current_user.name}, come visit Budge! http://#{DOMAIN}#{params[:redirect_to]}")  
        redirect_to :action => :switch_to_mobile, :sent => 1, :redirect_to => params[:redirect_to]
      
      else
        @ask_to_send_text = true
      end
      
    elsif request.post? and params[:user] and params[:user][:phone]
      if current_user
        current_user.update_attributes({:phone => params[:user][:phone]})
        current_user.normalize_phone_number
        current_user.send_phone_verification = true
        @text_sent = true      
        code = TwilioApi.send_text(current_user.phone_normalized, "#{current_user.name}, come visit Budge! http://#{DOMAIN}#{params[:redirect_to]}")  
      else
        @normalized_phone = User.normalize_phone_number(params[:user][:phone])
        code = TwilioApi.send_text(params[:user][:phone], "Hello! Come visit Budge! http://#{DOMAIN}#{params[:redirect_to]}")  
      end
      redirect_to :action => :switch_to_mobile, :sent => 1
    end
  end
  
  def application
    if params[:id]
      @program = Program.find_by_token params[:id]
      if current_user
        @program_player = current_user.program_players.where(:program_id => @program.id, :active => true).first
      end
    elsif current_user
      @program_player = current_user.program_players.where('program_id IS NULL AND active = ?', true).first   
    end
    @program_player ||= ProgramPlayer.new
  end

  def apply
    if current_user 
      @program = Program.find params[:id] if params[:id].present?
      
      # Get a program player for this guy
      if @program 
        @program_player = current_user.program_players.where(:program_id => @program.id, :active => true).first || ProgramPlayer.new
      else
        @program_player = current_user.program_players.where(['program_id IS NULL AND active = ?', true]).first || ProgramPlayer.new      
      end
      
      if @program and @program.new_record?
        @send_new_application_email = true
      end

      # Time zone
      if params[:time_zone] and current_user.time_zone != params[:time_zone]
        level_up_credits = TrackedAction.user_has_token(current_user, :verified_time_zone) ? 0 : 5
        current_user.update_attributes({:time_zone => params[:time_zone],
                                  :level_up_credits => current_user.level_up_credits+level_up_credits,
                                  :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
        TrackedAction.add(:verified_time_zone, current_user)
      end
      
      # Email
      if params[:email] and current_user.email != params[:email]
        level_up_credits = TrackedAction.user_has_token(current_user, :added_email) ? 0 : 5
        current_user.update_attributes({:email => params[:email],
                                  :level_up_credits => current_user.level_up_credits+level_up_credits,
                                  :total_level_up_credits_earned => current_user.total_level_up_credits_earned+level_up_credits})
        TrackedAction.add(:added_emailtime_zone, current_user)
      end

      # Phone number      
      if params[:phone] and params[:phone] != "0"
        current_user.update_attributes({:phone => params[:phone]})
        current_user.normalize_phone_number
        TwilioApi.send_text(current_user.phone, "Hello, #{current_user.name}! To verify your phone number for Budge, reply with 'Y'.")  
      end
      
      # Set the program player up
      @program_player.attributes = {:program_id => (@program.present? ? @program.id : nil),
                                    :required_answer_1 => params[:required_answer_1],
                                    :required_answer_2 => params[:required_answer_2],
                                    :optional_answer_1 => params[:optional_answer_1],
                                    :optional_answer_2 => params[:optional_answer_2],
                                    :wants_to_change => params[:wants_to_change],
                                    :how_badly => params[:how_badly],
                                    :success_statement => params[:success_statement],
                                    :user_id => current_user.id,
                                    :needs_to_play_at => Time.now.utc,
                                    :coach_user_id => params[:coach_user_id]}
      TrackedAction.add(:applied_to_budge_program, current_user)

      # Save the application
      if @program_player.save
        Mailer.new_application(@program_player).deliver
        @kissmetrics[:record] << {:name => 'Activated'}
        # Save simpleGeo context
        if params[:latitude].present? and params[:longitude].present?
          location_context = LocationContext.find_or_initialize_by_context_about_and_context_id('program_player', @program_player.id)
          location_context.update_attributes({:user_id => current_user.id,
                                              :latitude => params[:latitude],
                                              :longitude => params[:longitude]})
                                             
          p "SIMPLEGEO : metro: #{location_context.population_density}, temperature: #{location_context.temperature_f}, weather: #{location_context.weather_conditions}"
        end
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  def unapply
    @program_player = ProgramPlayer.find params[:id]
    if current_user == @program_player.user
      # Assumes that all actions here end the program
      # Does not affect the outcome_token of that player_step, as there might still be open budges on it.
      @player_step = @program_player.player_step
      if @player_step.present?
        @player_step.update_attributes({:response_token => 'CAN',
                                        :response_id => nil,
                                        :response_sorted_by => 'player'})
      end
      @program_player.update_attributes({:active => false})
    end
    redirect_to :action => :index
  end

  def request_invite
    email=params[:invitation][:email]
    if email.present? and email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      hominid = Hominid::API.new('997a1a2c74199653dc13192be21d3569-us4')
      output = hominid.list_subscribe('6479125e3f', email, {'FNAME' => '', 'LNAME' => ''}, 'html', true, true, true, false)
      redirect_to :action=>:index, :invited => 1
    else
      redirect_to :action=>:index, :failed => 1
    end
  end
  
end
