class BuildController < ApplicationController

  VALID_CODES = {'techcrunch'  => true, 
                 'lifehacker'  => true, 
                 'venturebeat' => true, 
                 'ilovebudge'  => true,
                 'iamawesome'  => true,
                 'icanchange'  => true,
                 'geekwire'    => true}
                 
  CURRENT_CONTEST = "Invent Our Next Program!"
  CONTEST_TOKEN = 'techcrunch'
  
  def index
    @current_contest = CURRENT_CONTEST
    if session[:builder].present?
      @can_add_suggestions = true
    end
    @suggestions = Suggestion.where(:active => true, :contest_token => CONTEST_TOKEN).order('num_play_votes DESC').paginate(:per_page => 20, :page => 1)
  end
  
  def code
    if params[:contest].present? and params[:contest][:code].present?
      contest_code = params[:contest][:code]
      if VALID_CODES[contest_code]
        session[:builder] = true
      end
    end
    if !session[:builder]
      flash[:message] = "That code didn't work. Try again?"
    end
    redirect_to :action => :index
  end
  
  def suggest
    if request.post? and params[:suggestion][:title].present? and params[:suggestion][:email].present?
      params[:suggestion][:contest_token] = CONTEST_TOKEN
      if current_user.present?
        params[:suggestion][:user_id] = current_user.id
        params[:suggestion_vote][:user_id] = current_user.id
        params[:suggestion_vote][:email] = params[:suggestion][:email]
      end
      suggestion = Suggestion.create(params[:suggestion])
      suggestion_vote = SuggestionVote.create({:suggestion_id => suggestion.id})
      
      suggestion_vote.update_attributes(params[:suggestion_vote])
      redirect_to :controller => :build, :action => :suggestion, :id => suggestion.id, :added => 1
    end
  end
  
  def suggestion
    @current_contest = CURRENT_CONTEST
    params[:back] = "/build"
    @suggestion = Suggestion.find params[:id]
    @num_would_play = @suggestion.suggestion_votes.where(:would_play => true).count
    @num_would_build = @suggestion.suggestion_votes.where(:would_build => true).count  
    if params[:added]
      @added = true
    end  
  end
  
  def more_suggestions
    @suggestions = Suggestion.where(:active => true, :contest_token => CONTEST_TOKEN).order('num_play_votes DESC').paginate(:per_page => 20, :page => params[:page])    
    respond_to do |format|
      format.js
    end
  end
  
  def vote_play
    @suggestion = Suggestion.find params[:id]
    @suggestion_vote = SuggestionVote.where(:suggestion_id => @suggestion.id, :user_id => current_user.id).first
    if @suggestion_vote
      if @suggestion_vote.would_play?
        @suggestion_vote.update_attributes(:would_play => false)
      else
        @suggestion_vote.update_attributes(:would_play => true)      
      end
    else
      @suggestion_vote = SuggestionVote.create({:suggestion_id => @suggestion.id,
                             :user_id => current_user.id,
                             :email => current_user.email,
                             :would_play => true})
    end
    @suggestion_vote.reload
    @suggestion.reload
    render :action => :voted
  end
  
  def vote_build
    @suggestion = Suggestion.find params[:id]
    @suggestion_vote = SuggestionVote.where(:suggestion_id => @suggestion.id, :user_id => current_user.id).first
    if @suggestion_vote
      if @suggestion_vote.would_build?
        @suggestion_vote.update_attributes(:would_build => false)
      else
        @suggestion_vote.update_attributes(:would_build => true)      
      end
    else
      @suggestion_vote = SuggestionVote.create({:suggestion_id => @suggestion.id,
                             :user_id => current_user.id,
                             :email => current_user.email,
                             :would_build => true})
    end
    @suggestion_vote.reload
    @suggestion.reload
    render :action => :voted
  end
  
  def delete_suggestion
    @suggestion = Suggestion.find params[:id]
    if current_user and current_user.admin?
      if @suggestion.active?
        @suggestion.update_attributes(:active => false)
      else
        @suggestion.update_attributes(:active => true)
      end
    end
    redirect_to :action => :suggestion, :id => @suggestion.id
  end
end
