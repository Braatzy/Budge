class Scaffold::PlayerMessageResourcesController < ApplicationController
  # GET /player_message_resources
  # GET /player_message_resources.xml
  def index
    @player_message_resources = PlayerMessageResource.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @player_message_resources }
    end
  end

  # GET /player_message_resources/1
  # GET /player_message_resources/1.xml
  def show
    @player_message_resource = PlayerMessageResource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @player_message_resource }
    end
  end

  # GET /player_message_resources/new
  # GET /player_message_resources/new.xml
  def new
    @player_message_resource = PlayerMessageResource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @player_message_resource }
    end
  end

  # GET /player_message_resources/1/edit
  def edit
    @player_message_resource = PlayerMessageResource.find(params[:id])
  end

  # POST /player_message_resources
  # POST /player_message_resources.xml
  def create
    @player_message_resource = PlayerMessageResource.new(params[:player_message_resource])

    respond_to do |format|
      if @player_message_resource.save
        format.html { redirect_to([:scaffold, @player_message_resource], :notice => 'Player message resource was successfully created.') }
        format.xml  { render :xml => @player_message_resource, :status => :created, :location => @player_message_resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @player_message_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /player_message_resources/1
  # PUT /player_message_resources/1.xml
  def update
    @player_message_resource = PlayerMessageResource.find(params[:id])

    respond_to do |format|
      if @player_message_resource.update_attributes(params[:player_message_resource])
        format.html { redirect_to([:scaffold, @player_message_resource], :notice => 'Player message resource was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @player_message_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /player_message_resources/1
  # DELETE /player_message_resources/1.xml
  def destroy
    @player_message_resource = PlayerMessageResource.find(params[:id])
    @player_message_resource.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_player_message_resources_url) }
      format.xml  { head :ok }
    end
  end
end
