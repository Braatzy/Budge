class Scaffold::TwitterScoresController < ApplicationController
  # GET /twitter_scores
  # GET /twitter_scores.xml
  def index
    @twitter_scores = TwitterScore.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @twitter_scores }
    end
  end

  # GET /twitter_scores/1
  # GET /twitter_scores/1.xml
  def show
    @twitter_score = TwitterScore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @twitter_score }
    end
  end

  # GET /twitter_scores/new
  # GET /twitter_scores/new.xml
  def new
    @twitter_score = TwitterScore.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @twitter_score }
    end
  end

  # GET /twitter_scores/1/edit
  def edit
    @twitter_score = TwitterScore.find(params[:id])
  end

  # POST /twitter_scores
  # POST /twitter_scores.xml
  def create
    @twitter_score = TwitterScore.new(params[:twitter_score])

    respond_to do |format|
      if @twitter_score.save
        format.html { redirect_to([:scaffold, @twitter_score], :notice => 'Twitter score was successfully created.') }
        format.xml  { render :xml => @twitter_score, :status => :created, :location => @twitter_score }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @twitter_score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /twitter_scores/1
  # PUT /twitter_scores/1.xml
  def update
    @twitter_score = TwitterScore.find(params[:id])

    respond_to do |format|
      if @twitter_score.update_attributes(params[:twitter_score])
        format.html { redirect_to([:scaffold, @twitter_score], :notice => 'Twitter score was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @twitter_score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_scores/1
  # DELETE /twitter_scores/1.xml
  def destroy
    @twitter_score = TwitterScore.find(params[:id])
    @twitter_score.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_twitter_scores_url) }
      format.xml  { head :ok }
    end
  end
end
