class Scaffold::PlayerStepsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /player_steps
  # GET /player_steps.xml
  def index
    @player_steps = PlayerStep.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @player_steps }
    end
  end

  # GET /player_steps/1
  # GET /player_steps/1.xml
  def show
    @player_step = PlayerStep.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @player_step }
    end
  end

  # GET /player_steps/new
  # GET /player_steps/new.xml
  def new
    @player_step = PlayerStep.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @player_step }
    end
  end

  # GET /player_steps/1/edit
  def edit
    @player_step = PlayerStep.find(params[:id])
  end

  # POST /player_steps
  # POST /player_steps.xml
  def create
    @player_step = PlayerStep.new(params[:player_step])

    respond_to do |format|
      if @player_step.save
        format.html { redirect_to([:scaffold, @player_step], :notice => 'Player step was successfully created.') }
        format.xml  { render :xml => @player_step, :status => :created, :location => @player_step }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @player_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /player_steps/1
  # PUT /player_steps/1.xml
  def update
    @player_step = PlayerStep.find(params[:id])

    respond_to do |format|
      if @player_step.update_attributes(params[:player_step])
        format.html { redirect_to([:scaffold, @player_step], :notice => 'Player step was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @player_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /player_steps/1
  # DELETE /player_steps/1.xml
  def destroy
    @player_step = PlayerStep.find(params[:id])
    @player_step.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_player_steps_url) }
      format.xml  { head :ok }
    end
  end
end
