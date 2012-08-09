class Scaffold::TrackedActionsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /tracked_actions
  # GET /tracked_actions.xml
  def index
    @tracked_actions = TrackedAction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tracked_actions }
    end
  end

  # GET /tracked_actions/1
  # GET /tracked_actions/1.xml
  def show
    @tracked_action = TrackedAction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tracked_action }
    end
  end

  # GET /tracked_actions/new
  # GET /tracked_actions/new.xml
  def new
    @tracked_action = TrackedAction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tracked_action }
    end
  end

  # GET /tracked_actions/1/edit
  def edit
    @tracked_action = TrackedAction.find(params[:id])
  end

  # POST /tracked_actions
  # POST /tracked_actions.xml
  def create
    @tracked_action = TrackedAction.new(params[:tracked_action])

    respond_to do |format|
      if @tracked_action.save
        format.html { redirect_to([:scaffold, @tracked_action], :notice => 'TrackedAction was successfully created.') }
        format.xml  { render :xml => @tracked_action, :status => :created, :location => @tracked_action }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tracked_action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tracked_actions/1
  # PUT /tracked_actions/1.xml
  def update
    @tracked_action = TrackedAction.find(params[:id])

    respond_to do |format|
      if @tracked_action.update_attributes(params[:tracked_action])
        format.html { redirect_to([:scaffold, @tracked_action], :notice => 'TrackedAction was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tracked_action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tracked_actions/1
  # DELETE /tracked_actions/1.xml
  def destroy
    @tracked_action = TrackedAction.find(params[:id])
    @tracked_action.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_tracked_actions_url) }
      format.xml  { head :ok }
    end
  end
end
