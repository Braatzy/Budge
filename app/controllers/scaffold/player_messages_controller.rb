class Scaffold::PlayerMessagesController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /player_messages
  # GET /player_messages.xml
  def index
    @player_messages = PlayerMessage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @player_messages }
    end
  end

  # GET /player_messages/1
  # GET /player_messages/1.xml
  def show
    @player_message = PlayerMessage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @player_message }
    end
  end

  # GET /player_messages/new
  # GET /player_messages/new.xml
  def new
    @player_message = PlayerMessage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @player_message }
    end
  end

  # GET /player_messages/1/edit
  def edit
    @player_message = PlayerMessage.find(params[:id])
  end

  # POST /player_messages
  # POST /player_messages.xml
  def create
    @player_message = PlayerMessage.new(params[:player_message])

    respond_to do |format|
      if @player_message.save
        format.html { redirect_to([:scaffold, @player_message], :notice => 'Player message was successfully created.') }
        format.xml  { render :xml => @player_message, :status => :created, :location => @player_message }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @player_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /player_messages/1
  # PUT /player_messages/1.xml
  def update
    @player_message = PlayerMessage.find(params[:id])

    respond_to do |format|
      if @player_message.update_attributes(params[:player_message])
        format.html { redirect_to([:scaffold, @player_message], :notice => 'Player message was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @player_message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /player_messages/1
  # DELETE /player_messages/1.xml
  def destroy
    @player_message = PlayerMessage.find(params[:id])
    @player_message.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_player_messages_url) }
      format.xml  { head :ok }
    end
  end
end
