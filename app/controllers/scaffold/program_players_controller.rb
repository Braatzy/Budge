class Scaffold::ProgramPlayersController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /program_players
  # GET /program_players.xml
  def index
    @program_players = ProgramPlayer.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @program_players }
    end
  end

  # GET /program_players/1
  # GET /program_players/1.xml
  def show
    @program_player = ProgramPlayer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program_player }
    end
  end

  # GET /program_players/new
  # GET /program_players/new.xml
  def new
    @program_player = ProgramPlayer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @program_player }
    end
  end

  # GET /program_players/1/edit
  def edit
    @program_player = ProgramPlayer.find(params[:id])
  end

  # POST /program_players
  # POST /program_players.xml
  def create
    @program_player = ProgramPlayer.new(params[:program_player])

    respond_to do |format|
      if @program_player.save
        format.html { redirect_to([:scaffold, @program_player], :notice => 'Program player was successfully created.') }
        format.xml  { render :xml => @program_player, :status => :created, :location => @program_player }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @program_player.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /program_players/1
  # PUT /program_players/1.xml
  def update
    @program_player = ProgramPlayer.find(params[:id])

    respond_to do |format|
      if @program_player.update_attributes(params[:program_player])
        format.html { redirect_to([:scaffold, @program_player], :notice => 'Program player was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program_player.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /program_players/1
  # DELETE /program_players/1.xml
  def destroy
    @program_player = ProgramPlayer.find(params[:id])
    @program_player.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_program_players_url) }
      format.xml  { head :ok }
    end
  end
end
