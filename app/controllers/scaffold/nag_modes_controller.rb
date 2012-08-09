class Scaffold::NagModesController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /nag_modes
  # GET /nag_modes.xml
  def index
    @nag_modes = NagMode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nag_modes }
    end
  end

  # GET /nag_modes/1
  # GET /nag_modes/1.xml
  def show
    @nag_mode = NagMode.find(params[:id])
    redirect_to :action => :edit
    return

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nag_mode }
    end
  end

  # GET /nag_modes/new
  # GET /nag_modes/new.xml
  def new
    @nag_mode = NagMode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nag_mode }
    end
  end

  # GET /nag_modes/1/edit
  def edit
    @nag_mode = NagMode.find(params[:id])
    if !@nag_mode.new_record?
      @nag_mode_prompt = NagModePrompt.new(:nag_mode_id => @nag_mode.id)
    end
  end

  # POST /nag_modes
  # POST /nag_modes.xml
  def create
    @nag_mode = NagMode.new(params[:nag_mode])

    respond_to do |format|
      if @nag_mode.save
        format.html { redirect_to([:scaffold, @nag_mode], :notice => 'Nag mode was successfully created.') }
        format.xml  { render :xml => @nag_mode, :status => :created, :location => @nag_mode }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nag_mode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nag_modes/1
  # PUT /nag_modes/1.xml
  def update
    @nag_mode = NagMode.find(params[:id])

    respond_to do |format|
      if @nag_mode.update_attributes(params[:nag_mode])
        format.html { redirect_to([:scaffold, @nag_mode], :notice => 'Nag mode was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nag_mode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /nag_modes/1
  # DELETE /nag_modes/1.xml
  def destroy
    @nag_mode = NagMode.find(params[:id])
    @nag_mode.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_nag_modes_url) }
      format.xml  { head :ok }
    end
  end
end
