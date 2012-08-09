class Scaffold::PlayerNotesController < ApplicationController
  # GET /player_notes
  # GET /player_notes.xml
  def index
    @player_notes = PlayerNote.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @player_notes }
    end
  end

  # GET /player_notes/1
  # GET /player_notes/1.xml
  def show
    @player_note = PlayerNote.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @player_note }
    end
  end

  # GET /player_notes/new
  # GET /player_notes/new.xml
  def new
    @player_note = PlayerNote.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @player_note }
    end
  end

  # GET /player_notes/1/edit
  def edit
    @player_note = PlayerNote.find(params[:id])
  end

  # POST /player_notes
  # POST /player_notes.xml
  def create
    @player_note = PlayerNote.new(params[:player_note])

    respond_to do |format|
      if @player_note.save
        format.html { redirect_to([:scaffold, @player_note], :notice => 'Player note was successfully created.') }
        format.xml  { render :xml => @player_note, :status => :created, :location => @player_note }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @player_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /player_notes/1
  # PUT /player_notes/1.xml
  def update
    @player_note = PlayerNote.find(params[:id])

    respond_to do |format|
      if @player_note.update_attributes(params[:player_note])
        format.html { redirect_to([:scaffold, @player_note], :notice => 'Player note was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @player_note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /player_notes/1
  # DELETE /player_notes/1.xml
  def destroy
    @player_note = PlayerNote.find(params[:id])
    @player_note.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_player_notes_url) }
      format.xml  { head :ok }
    end
  end
end
