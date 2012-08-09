class CoachController < ApplicationController
  layout 'app'
  before_filter :authenticate_user!, :coach_required
  
  def index
    @player_buckets = ProgramPlayer.player_buckets_for_coach(current_user)  
  end
  
  def save_coach_flag
    @program_player = ProgramPlayer.find params[:id]
    
    if current_user.id == @program_player.coach_user_id
      @program_player.update_attributes(:coach_flag => params[:coach_flag])
    end
    respond_to do |format|
      format.js
    end
  end
end
