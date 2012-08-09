class DashController < ApplicationController
  before_filter :admin_required
  before_filter :authenticate_user!
  protect_from_forgery :except => [:parse_text]
  layout 'dash'
  
  def index
    @user_count={}
    @user_count[:all]=User.find(:all).count
    users_in_beta=User.where(:in_beta=>true)
    @user_count[:beta]=users_in_beta.count
    @cohorts = User.select("cohort_tag, count(*) as count").where('cohort_tag is not null').group(:cohort_tag)
    
    @beta_user_state_counts=User.get_state_counts_on_cohort(users_in_beta)
    @program_count={}
    @program_count[:store]=Program.where(:featured=>true).length
    @program_count[:dev]=Program.where(:featured=>false).length
    @program_count[:draft]=ProgramDraft.count
    @programs_active=Program.where(:featured=>true).includes(:program_players).order('total_players DESC')
    
    @states_per_program=Hash.new
    #@programs_active.each do |program|
      #@states_per_program[program.id]=ProgramPlayer.get_state_counts_on_cohort(program.program_players)
    #end
    
  end

  def users
    @users = User.includes(:program_players).order('created_at DESC') #.page(params[:page]).per(500).order('created_at DESC')
    @beta_user_state_counts = User.get_state_counts_on_cohort(@users.where(:in_beta=>true))
  end
  
  def update_user_states_now
    ProgramPlayer.update_last_checked_in_for_all_players
    User.update_state_for_all_users
    redirect_to '/dash/users'
  end

  def user
    
    @user = User.find(params[:id])
    @program_players = @user.get_program_players
    
    @referred_by = @user.relationships.where(:referred_signup => true).first
    @referred = @user.followed_by_relationships.where(:referred_signup => true)
    
    
    start_time=30.days.ago
    @player_messages = @user.get_messages(start_time)
    @player_messages_info = @user.get_messages_info(@player_messages)
    
    @budges = @user.get_level_attempts(start_time)
    @budges_info=@user.get_level_attempts_info(@budges)
    
    @checkins=@user.get_checkins(start_time)
    @checkins_info = @user.get_checkins_info(@checkins)
    
    @range_time=[start_time,DateTime.now+7.day]
  end
  
  def programs
    @programs = Program.where(:featured => true).order('name')
    @archived_programs = Program.where(:featured => false).order('name')
  end

  def program
    @program = Program.find(params[:id])
    @leaders = @program.leaderboard
    behavior_values=@leaders.map{|l| l.score}
    @behavior_historgram = Leader.create_histogram(behavior_values) #[20,25,30,22,10,0,0,0,0,0,50]
    @behavior_stdev=Leader.get_stdev(behavior_values)

    @program_budges = @program.program_budges.reorder(:level)
    @program_budges_status = @program.get_program_budges_status
    @aggregate_status=PlayerBudge.get_aggregate_status(@program_budges_status)
    @aggregate_status['completed program']=@program.num_completed
    
    @program_trait_stats=@program.get_trait_statistics
    trait=@program.leaderboard_trait
    @program_trait_name=(trait.noun.nil? ? trait.verb : trait.verb+' '+trait.noun).pluralize
    if @program_trait_name=='do pushups'
      @program_trait_name='pushups done'
    elsif @program_trait_name=='drink alcoholic drinks'
      @program_trait_name='alcoholic drinks had'
    elsif @program_trait_name=='meditates'
      @program_trait_name='minutes meditated'
    elsif @program_trait_name=='share meals'
      @program_trait_name='meals shared'
    end
  end
  
  USER_STATUSES=['no programs', 'no actions', 'engaged', 'snoozing', 'scheduled', 'off-wagon', 'long-lost']
  USER_STATUS_COLORS=['636363','969696','31a354','74c476','c7e9c0','fd8d3c','e6550d']
  USER_STATUS_DESCRIPTIONS={
    'no programs'=>'a user has not enroled in any programs',
    'no actions'=>'a user has not checked in any actions',
    'engaged'=>'a user has checked in within the past 3 days', 
    'snoozing'=>'a user is currently paused in all of their programs',
    'scheduled'=>'a user is scheduled to start each of their programs within the next two weeks',
    'off-wagon'=>'a user has not checked in within the 3 days (but has checked in in the past month)',
    'long-lost'=>'a user has not checked in within the last 30 days'
  }

  def metrics
    start_date=Date.new(2011,11,01)
    #use the latest date to pick out most recent per-cohort stats
    latest_date=Metric.where(:status_key=>'users',:cohort=>'all').order(:date).last.date 
    
    cohort_acquisition=Metric.where(:status_key=>'users',:date=>latest_date).order(:cohort).select{|m| m.cohort!='all' and not m.cohort.starts_with?('program')}
    #pull out the cohorts for use in later queries
    cohorts=cohort_acquisition.map{|m| m.cohort}
    #get the acquisition for each cohort
    activation=Metric.where({:cohort=>cohorts,:status_key=>'activated',:date=>latest_date}).select('cohort, number')
    @cohort_activation=cohort_acquisition.map do |m|
      c=activation.select{|a| a.cohort==m.cohort}
      {'cohort'=>m.cohort, 'acquired'=>m.number, 'activated'=>c.size==1 ? c.first.number : 0}
    end
    
    #get the user states for each cohort
    @user_statuses=USER_STATUSES
    @user_status_colors=USER_STATUS_COLORS
    @status_desc=USER_STATUS_DESCRIPTIONS
    retention=Metric.where({:cohort=>cohorts,:date=>latest_date}).where({:status_key=>@user_statuses }).order(:cohort).select( 'cohort, number, status_key').group_by(&:cohort)
    blank_statuses=ActiveSupport::OrderedHash.new
    @user_statuses.each{|s| blank_statuses[s]=0}
    @retention=retention.map do |cohort,metric|
      s=ActiveSupport::OrderedHash.new
      s['cohort']=cohort
      s.update(blank_statuses)
      metric.each{|m| s[m.status_key]=m.number}
      s
    end
        
    #get daily revenue
    @dailygrr=DailyGrr.where(:date=>start_date .. latest_date).select('date,revenue')
  end

  def metrics_aggregate
    start_date=Date.new(2011,11,01)
    user_acquisition=Metric.where(:status_key=>'users',:cohort=>'all').where("date>=?",start_date).select('date, number')
    user_activation =Metric.where(:status_key=>'activated',:cohort=>'all').where("date>=?",start_date).select('date, number')
    latest_date=user_acquisition.map{|m| m.date}.max
    
    #join the activated and acquired users by date
    @users_activated=user_acquisition.map do |m| 
      a=user_activation.select{|a| a.date==m.date}
      {'date'=>m.date, 'acquired'=>m.number,'activated'=> a.size==1 ? a.first.number : 0}
    end
    
    @user_statuses=USER_STATUSES
    @user_status_colors=USER_STATUS_COLORS
    @status_desc=USER_STATUS_DESCRIPTIONS
    retention=Metric.where(:cohort=>'all').where({:status_key=>@user_statuses }).order(:date).select( 'date, number, status_key').group_by(&:date)
    blank_statuses=ActiveSupport::OrderedHash.new
    @user_statuses.each{|s| blank_statuses[s]=0}
    @retention=retention.map do |date,metric|
      s=ActiveSupport::OrderedHash.new
      s['date']=date
      s.update(blank_statuses)
      metric.each{|m| s[m.status_key]=m.number}
      s
    end
    
    #get visitation stats from DailyGRR table
    @dailygrr=DailyGrr.where(:date=>start_date .. latest_date).select('date,logins_1day,logins_7day,revenue,total_users').map do |m|
      next if m.total_users==0
      {:date=>m.date,
       :logins_1day=>m.logins_1day*1.0/(m.total_users*1.0),
       :logins_7day=>m.logins_7day*1.0/(m.total_users*1.0),
       :logins_1day_raw=>m.logins_1day, 
       :logins_7day_raw=>m.logins_7day,
       :revenue=>m.revenue,
       :net_revenue=>0
       }
   end
   @dailygrr.reject!{|m| m.nil?}
   @dailygrr.each_with_index{|m,i| m[:net_revenue]=m[:revenue]+(i==0 ? 0 : @dailygrr[i-1][:net_revenue]) }
  end

  def metrics_raw
    @metrics=Metric.find(:all)
  end
  
  def god_view
    actions= params[:id].present? ? TrackedAction.joins(:user).where('users.id'=>params[:id]) : TrackedAction
    # @tracked_actions = actions.page(params[:page]).per(500).order('id DESC')
    @tracked_actions= actions.paginate(:page => params[:page], :per_page => 1000, :order => 'id DESC')
    @tracked_actions_grouped=@tracked_actions.group_by{|action| [action.created_at.strftime('%Y-%m-%d %H:%M'), action.user]}
  end

  def nudges
    @user_nudges=User.where('next_nudge_at >= ?',7.days.ago).order(:next_nudge_at).reverse.each
  end
  def messages
    if params[:id].present? 
      @messages=PlayerMessage.where('to_user_id'=>params[:id]).order('deliver_at DESC')
      @user=User.find(params[:id])
    else
      @messages=PlayerMessage.page(params[:page]).per(500).order('deliver_at DESC')
    end
    @messages_paginated=!params[:id].present?
  end
  def delete_player_message
    PlayerMessage.find(params[:id]).destroy
    redirect_to :action => :messages
  end
  def edit_player_message
    @message=PlayerMessage.find(params[:id])
  end

  def other
    @dynos_in_use = request.headers['HTTP_X_HEROKU_DYNOS_IN_USE']
    @queue_wait_time = request.headers['HTTP_X_HEROKU_QUEUE_WAIT_TIME']
    @dynos_queue_depth = request.headers['HTTP_X_HEROKU_QUEUE_DEPTH']
    
  end




  def edit_program
    @program = params[:id].present? ? (Program.find params[:id]) : Program.new
    @program_budges = @program.program_budges
    
    max_program_budge = @program.program_budges.present? ? @program.program_budges.last.position : 0
    next_program_budge = max_program_budge+1
    
    @new_program_budge = ProgramBudge.new({:program_id => @program.id,
                                         :position => next_program_budge,
                                         :level => (@program.program_budges.blank? ? 1 : (@program.program_budges.maximum(:level).to_i+1))})
  end


  def visit_stats
    @days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    @hours = ['midnight', '1am', '2am', '3am', '4am', '5am', '6am', '7am', '8am', '9am', '10am', '11am',
              'noon', '1pm', '2pm', '3pm', '4pm', '5pm', '6pm', '7pm', '8pm', '9pm', '10pm', '11pm', 'midnight']
  
    @global_day_and_hour = VisitStat.where('constrained_by = ?', 'global_day_and_hour')
    @global_hour = VisitStat.where('constrained_by = ?', 'global_hour')
    
    @global_weights = {:day => Hash.new, :hour => Hash.new}
    @global_day_and_hour.each do |visit_stat|
      @global_weights[:day][visit_stat.constrained_by_id1] ||= Hash.new
      @global_weights[:day][visit_stat.constrained_by_id1][visit_stat.constrained_by_id2] = visit_stat
    end
    @global_hour.each do |visit_stat|
      @global_weights[:hour][visit_stat.constrained_by_id1] = visit_stat
    end
  end
  
  def effective_notifications
    @programs = Program.where(:featured => true)
    if params[:id]
      @player_message_id_to_notification = Hash.new

      @program = Program.find params[:id]
      @player_messages = @program.player_messages
      @notifications = Notification.where(:for_object => 'player_message').where('for_id in (?)', @player_messages.map{|pm|pm.id})
      @notifications.map{|n|@player_message_id_to_notification[n.for_id] = n}

      @hour_stats = Hash.new
      @player_messages.each do |player_message|
        if @player_message_id_to_notification[player_message.id].present?
          n = @player_message_id_to_notification[player_message.id]
          if n.delivered?          
            @hour_stats[n.delivered_hour_of_day] ||= {
                :delivered => 0,
                :responded => 0,
                :not_responded => 0,
                :responded_10 => 0,
                :responded_60 => 0,
                :responded_180 => 0,
                :responded_1440 => 0,
                :responded_later => 0}
            @hour_stats[n.delivered_hour_of_day][:delivered] += 1
            if n.responded?
              @hour_stats[n.delivered_hour_of_day][:responded] += 1
              if n.responded_minutes <= 10
                @hour_stats[n.delivered_hour_of_day][:responded_10] += 1            
              elsif n.responded_minutes <= 60
                @hour_stats[n.delivered_hour_of_day][:responded_60] += 1                          
              elsif n.responded_minutes <= 180
                @hour_stats[n.delivered_hour_of_day][:responded_180] += 1                          
              elsif n.responded_minutes <= 1440
                @hour_stats[n.delivered_hour_of_day][:responded_1440] += 1                          
              elsif n.responded_minutes > 1440
                @hour_stats[n.delivered_hour_of_day][:responded_later] += 1                          
              end
            else
              @hour_stats[n.delivered_hour_of_day][:not_responded] += 1            
            end
          end
        end
      end
    end
  end

  def share_messages
    @entries = Entry.page(params[:page]).per(500).where('message_type <> ?', 'comment').includes(:user).order('created_at DESC')
    # @entries = Notification.where(:for_object=>'entry')
    # ARG - it would be good to join these tables and show #clicks,#signups from a shared message
  end
  def conversations
    @player_messages = PlayerMessage.page(params[:page]).per(200).order('created_at DESC')
  end
  def links
    # select for_object, for_id, sum(total_clicks) as sum_clicks, count(*) as sum_notifications from notifications group by for_object, for_id;
    if params[:for_object].present?
      @notifications = Notification.paginate :page => params[:page], :per_page => 50, 
                          :conditions => ['responded = ? AND for_object = ? AND for_id = ?', 
                                          true, params[:for_object], params[:for_id]], :order => 'updated_at DESC'
    
    else
      if not params[:page] or params[:page].to_i == 1
        # ARG - ideally i'd get rid of this raw sql and add who posted the message and what it was. 
        # it would also be good to see clicks in the last 30 days. 
        @best_notifications = Notification.find_by_sql("select for_object, user_id, created_at, for_id, sum(total_clicks) as sum_clicks, count(*) as sum_notifications, num_signups from notifications group by for_object, for_id").select{|n| n.sum_clicks.to_i>0}
        # @best_notifications = Notification.group(:for_object,:for_id).having("sum(total_clicks)>0")
         #.select{|n| n.for_object=='entry'}
      end
        
      @notifications = Notification.paginate :page => params[:page], :per_page => 50, 
                          :conditions => ['responded = ?', true], :order => 'updated_at DESC'
    end
  end

  def email_list
    hominid = Hominid::API.new('997a1a2c74199653dc13192be21d3569-us4')
    # p hominid.lists['data'].first()['member_count']
    list_started='2012-01-11 03:00:00'
    @per_page=2000
    @page_number=params[:page].present? ? params[:page] : 0
    #http://apidocs.mailchimp.com/api/1.3/listmembers.func.php
    #(string apikey, string id, string status, string since, int start, int limit)
    list=hominid.list_members('6479125e3f','subscribed',list_started,@page_number,2000)
    @email_list=list['data'].reverse
    @total=list['total']
  end

  #------------------------------------------------------------------------------------------------
  #Action-based methods
  #------------------------------------------------------------------------------------------------
  
  def toggle_in_beta
    @user = User.find params[:id]
    if @user == current_user
      raise "You can't change yourself."
    elsif @user.in_beta?
      @user.update_attributes(:in_beta => false)
    else
      @user.update_attributes(:in_beta => true)
    end
    redirect_to :action => :user, :id => @user.id
  end

  def edit_program_budge
    @program_budge = params[:id].present? ? (ProgramBudge.find params[:id]) : ProgramBudge.new
    @program = @program_budge.program
    @auto_message = AutoMessage.new(:program_id => @program.id, 
                                    :program_budge_id => (@program_budge.new_record? ? nil : @program_budge.id),
                                    :deliver_via => PlayerMessage::BEST,
                                    :status => AutoMessage::PUBLISH_STATUS_LIVE)
  end
  
  def reorder_budges
    @program = Program.find params[:id]
    @program.program_budges.each do |program_budge|
      program_budge.update_attributes({:position => params['program_budge'].index(program_budge.id.to_s) + 1})    
    end
    render :nothing => true
  end
  
  def save_program
    @program = params[:id].present? ? (Program.find params[:id]) : Program.new
    @program.attributes = params[:program]
    @program.attributes = {:user_id => current_user.id} unless @program.user.present?
    @program.save
    redirect_to :action => :edit_program, :id => @program.id
  end
  
  def save_program_budge
    @program = Program.find params[:program_id]
    if params[:id]
      @program_budge = ProgramBudge.find params[:id]
    elsif params[:program_budge].present? and params[:program_budge][:id].present?
      @program_budge = ProgramBudge.find params[:program_budge][:id]
    else
      @program_budge = ProgramBudge.new({:program_id => @program.id})
    end

    @program_budge.attributes = params[:program_budge]
    @program_budge.attributes = {:num_action_templates => @program_budge.program_action_templates.size}      
    @program_budge.save
    redirect_to :controller => :dash, :action => :edit_program_budge, :id => @program_budge.id
  end
  
  def save_program_budge_auto_message
    @program = Program.find params[:program_id]
    @program_budge = ProgramBudge.find params[:program_budge_id]
    raise "Invalid budge" unless @program.present? and @program_budge.present? and @program.id == @program_budge.program_id
    
    if params[:id]
      @auto_message = AutoMessage.find params[:id]
    else
      @auto_message = AutoMessage.new({:program_id => @program.id,
                            :program_budge_id => @program_budge.id,
                            :user_id => current_user.id,
                            :position => (@program_budge.auto_messages.present? ? @program_budge.auto_messages.last.position+1 : 1)})
    end
    
    @text = params[:auto_message_content]
    urls = LinkResource.convert_text_to_link_resources(@text)
    @text = LinkResource.replace_links_with_link_resource_urls(@text, urls)
    
    # Determine the primary trigger for this auto_message
    auto_message_deliver_trigger = nil
    if params[:auto_message_day_number].present?
      auto_message_deliver_trigger = 0    
    elsif params[:auto_message_trigger_trait_id].present?
      auto_message_deliver_trigger = 2
    end
 
    @auto_message.attributes = {:content => @text,
                          :auto_message_type => params[:auto_message_type],
                          :status => params[:auto_message_status],
                          :deliver_via => params[:auto_message_deliver_via],
                          :deliver_trigger => auto_message_deliver_trigger,
                          :day_number => params[:auto_message_day_number],
                          :hour => params[:auto_message_hour],
                          :trigger_trait_id => params[:auto_message_trigger_trait_id],
                          :delivery_window => params[:auto_message_delivery_window],
                          :include_link => params[:auto_message_include_link]}

    # Reset some variables if this is a particular kind of auto_message
    if @auto_message.auto_message_type == 1
      @auto_message.day_number = 0
      @auto_message.position = 0  
    end
                            
    @auto_message.save!
    @auto_messages = @program_budge.auto_messages.reload
    respond_to do |format|
      format.js
    end    
  end
  
  def edit_auto_message
    @auto_message = AutoMessage.find params[:id]
    @program_budge = @auto_message.program_budge
    @program = @auto_message.program
  end
  def delete_auto_message
    @auto_message = AutoMessage.find params[:id]
    @auto_message.update_attributes(:active => false)
    redirect_to :action => :edit_program_budge, :id => @auto_message.program_budge_id
  end
  
  def delete_program_budge
    @program = Program.find params[:program_id]
    @program_budge = params[:id].present? ? (ProgramBudge.find params[:id]) : ProgramBudge.new({:program_id => @program.id})
    @program_budge.update_attributes(:active => false)
    redirect_to :controller => :dash, :action => :edit_program, :id => @program.id      
  end
  
  def add_program_link_resource
    @program = Program.find params[:id]
    @normalized_url = LinkResource.normalize_url(params[:program_link_resource][:url])
    # Create a link_resource for this url if it doesn't exist already
    @link_resource = LinkResource.find_or_create_by_url(@normalized_url)
    
    unless @program_link_resource = @program.program_link_resources.where(:link_resource_id => @link_resource.id).first
      @program_link_resource = ProgramLinkResource.create({:link_resource_id => @link_resource.id,
                                            :program_id => @program.id,
                                            :user_id => current_user.id,
                                            :importance => params[:program_link_resource][:importance]})
    end
    redirect_to :action => :edit_program, :id => @program.id
  end
  def save_link_resource
    @link_resource = LinkResource.find params[:id]
    @link_resource.update_attributes(params[:link_resource])
    redirect_to :action => :link_resource, :id => @link_resource.id
  end    
  def delete_program_link_resource
    @program = Program.find params[:id]  
    if @program_link_resource = ProgramLinkResource.find(params[:program_link_resource_id])
      @program_link_resource.destroy
    end
    redirect_to :action => :edit_program, :id => @program.id
  end
  
  def reorder_budges
    @program = Program.find params[:id]
    @program.program_budges.each do |program_budge|
      program_budge.update_attributes({:position => params['program_budge'].index(program_budge.id.to_s) + 1})    
    end
    render :nothing => true
  end


  def edit_action_template
    @program_action_template = ProgramActionTemplate.find params[:id]
    @program_budge = @program_action_template.program_budge
    @program = @program_action_template.program
    @noajax_submit = true
  end
  def delete_action_template
    @program_action_template = ProgramActionTemplate.find params[:id]
    @program_action_template.update_attributes(:active => false)
    respond_to do |format|
      format.js
    end    
  end  
  def add_action_template_to_budge
    @program = Program.find params[:program_id]
    @program_budge = params[:program_budge_id].present? ? ProgramBudge.find(params[:program_budge_id]) : ProgramBudge.new
    @program_action_template = params[:program_action_template_id].present? ? ProgramActionTemplate.find(params[:program_action_template_id]) : ProgramActionTemplate.new
    @do_or_dont = params[:do_or_dont].to_sym
    @trait = Trait.find params[:trait_id]

    # If the budge hasn't been saved yet, save the budge as well
    if @program_budge.new_record?
      last_position = @program.program_budges.present? ? @program.program_budges.last.position : 0
      @program_budge.attributes = {:program_id => @program.id, :position => (last_position+1)}
      @program_budge.save
      @update_program_budge_info = true
    end 

    @budge_name = @trait.name_with_formatting(@do_or_dont, params[:custom_text], params[:trait_quantity])
    
    @max_position = @program_budge.program_action_templates.present? ? @program_budge.program_action_templates.last.position : 0
    
    @program_action_template.attributes = {:program_id => @program.id,
                                           :program_budge_id => @program_budge.id,
                                           :trait_id => @trait.id,
                                           :custom_text => params[:custom_text],
                                           :name => @budge_name,
                                           :completion_requirement_type => params[:completion_requirement_type],
                                           :completion_requirement_number => params[:quantity],
                                           :do => (@do_or_dont == :do ? true : false),
                                           :daily_question => params[:daily_question],
                                           :wording => params[:wording],
                                           :position => @max_position+1,
                                           :day_number => (params[:day_number].present? ? params[:day_number] : 0)}
    @program_action_template.save
    
    respond_to do |format|
      format.js
    end
  end
  def select_trait_for_action
    @program = Program.find params[:program_id]
    @program_budge = ProgramBudge.find(params[:program_budge_id])
    @is_do = params[:is_do] == 'true' ? true : false
    @trait = Trait.find params[:trait_id]
    @program_action_template = ProgramActionTemplate.new(:trait_id => @trait.id, :program_id => @program.id, :program_budge_id => @program_budge.id)
    respond_to do |format|
      format.js
    end    
  end
end
