class ChartController < ApplicationController
  layout 'app'
  before_filter :authenticate_user!
  def index        
    chart_begin=Time.now.utc-40.day
    rolling_avg_days = 10
    
    @program_player = current_user.program_players.where(:program_id => 20).first
        
    #if user isn't in Weigh Everyday (id=20) - redirect to /play
    if @program_player.nil?
      flash[:message] = "Alas, the snail is only charting weight for now."
      redirect_to :controller=>:play
    else
      weigh_trait = Trait.where(:verb => 'weigh in').first
      users_weight_trait=UserTrait.where(:trait_id => weigh_trait.id, :user_id => current_user.id).first
      if users_weight_trait.nil?
        checkins=[]
      else
        checkins=Checkin.where(:user_trait_id=>users_weight_trait.id, :duplicate => false, :amount_decimal=> 2..1000, :created_at=>chart_begin..(Time.now.midnight+1.day) ).order("created_at").select('created_at,amount_decimal,amount_units')
      end
      
      @units=checkins.last.amount_units
  
      times=checkins.map{|c| c.created_at}
      weights=checkins.map{|c| c.amount_decimal}
      margin_weight=weights.max*0.02
      margin_weight_no_data= 10
      margin_time=1.5.day
      @range_time=[checkins.first.created_at-margin_time, checkins.last.created_at+margin_time]
      if (@range_time[1]-@range_time[0]) < 1.week
        @range_time[0]=@range_time[1]-1.week
      end
      @range_time=@range_time.map{|t| Chart.t2s(t)}
      @range_weight=weights.length>1 ? [weights.min-margin_weight,weights.max+margin_weight] : [weights[0]-margin_weight_no_data,weights[0]+margin_weight_no_data]
      @true_weight=Chart.moving_average(times.zip(weights),rolling_avg_days)
      @lines = Chart.break_into_line_segments(@true_weight)
      @weights=times.map{|t| Chart.t2s(t)}.zip(weights)
      @todays_true_weight,@todays_direction=Chart.get_current_weight_direction(@weights.last[1], @true_weight.last[1])
    
    end
  end
end
