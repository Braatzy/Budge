class Scaffold::NagModePromptsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  # GET /nag_mode_prompts
  # GET /nag_mode_prompts.xml
  def index
    @nag_mode_prompts = NagModePrompt.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nag_mode_prompts }
    end
  end

  # GET /nag_mode_prompts/1
  # GET /nag_mode_prompts/1.xml
  def show
    @nag_mode_prompt = NagModePrompt.find(params[:id])
    redirect_to :action => :edit
    return

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nag_mode_prompt }
    end
  end

  # GET /nag_mode_prompts/new
  # GET /nag_mode_prompts/new.xml
  def new
    @nag_mode_prompt = NagModePrompt.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nag_mode_prompt }
    end
  end

  # GET /nag_mode_prompts/1/edit
  def edit
    @nag_mode_prompt = NagModePrompt.find(params[:id])
  end

  # POST /nag_mode_prompts
  # POST /nag_mode_prompts.xml
  def create
    @nag_mode_prompt = NagModePrompt.new(params[:nag_mode_prompt])

    respond_to do |format|
      if @nag_mode_prompt.save
        format.html { redirect_to([:scaffold, @nag_mode_prompt.nag_mode], :notice => 'Nag mode prompt was successfully created.') }
        format.xml  { render :xml => @nag_mode_prompt, :status => :created, :location => @nag_mode_prompt }
      else
        logger.warn @nag_mode_prompt.inspect
        format.html { render :action => "new" }
        format.xml  { render :xml => @nag_mode_prompt.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /nag_mode_prompts/1
  # PUT /nag_mode_prompts/1.xml
  def update
    @nag_mode_prompt = NagModePrompt.find(params[:id])
    respond_to do |format|
      if @nag_mode_prompt.update_attributes(params[:nag_mode_prompt])
        format.html { redirect_to([:scaffold, @nag_mode_prompt.nag_mode], :notice => 'Nag mode prompt was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nag_mode_prompt.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /nag_mode_prompts/1
  # DELETE /nag_mode_prompts/1.xml
  def destroy
    @nag_mode_prompt = NagModePrompt.find(params[:id])
    @nag_mode_prompt.destroy

    respond_to do |format|
      format.html { redirect_to([:scaffold, @nag_mode_prompt.nag_mode]) }
      format.xml  { head :ok }
    end
  end
end
