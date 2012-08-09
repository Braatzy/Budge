class InviteController < ApplicationController
  layout 'app'
  before_filter :authenticate_user!

  def index
    @program_players = current_user.program_players.order('num_invites_available desc').select{|p|p.program.present? and p.program.featured?}
    
    @following = current_user.relationships
    @followed_by = current_user.followed_by_relationships   
    @referred_by = @following.where(:referred_signup => true).first
    @referred = @followed_by.where(:referred_signup => true)
  end
  
  def program
    @program = Program.find params[:id]
    @program_player = current_user.program_players.where(:program_id => @program.id).first
    if @program_player.blank?
      redirect_to :controller => :play, :action => :index
    end
  end
  
  def send_invitations
    @program = Program.find params[:id]
    raise "No program." unless @program.present?

    # See if this is their free game
    @has_program = @program.has_been_purchased_by?(current_user)
      
    # Figure out if they can invite people
    if @has_program
      @program_player = current_user.program_players.where(:program_id => @program).first
      if params[:program_player].present? 
        @program_player.update_attributes(:testimonial => params[:program_player][:testimonial])
      end

      @invites_to_give = @program_player.num_invites_available
      @invites_sent = Array.new
      if params[:invite].present? and @invites_to_give >= params[:invite].size
        params[:invite].each do |key, email|
          if email.present? and email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
            invitation = Invitation.create({:user_id => current_user.id,
                                            :program_id => @program.id,
                                            :program_player_id => @program_player.id,
                                            :email => email,
                                            :message => params[:program_player][:testimonial]})
            Mailer.invitation_to_program(invitation).deliver
            @invites_sent << invitation
          else
            logger.warn "#{key}: #{email} is invalid"
          end
        end
      end
      if @invites_sent.size == 0
        flash[:message] = "No invitations were sent."
      elsif @invites_sent.size == 1
        flash[:message] = "Your invitation was sent."      
      else
        flash[:message] = "#{@invites_sent.size} invitations were sent."      
      end
      @program_player.update_attributes(:num_invites_sent => @program_player.num_invites_sent+@invites_sent.size,
                                        :num_invites_available => @program_player.num_invites_available-@invites_sent.size)
    end
    redirect_to :controller => :invite, :action => :index
  end

end
