class Scaffold::ProgramDraftsController < ApplicationController
  # GET /program_drafts
  # GET /program_drafts.xml
  def index
    @program_drafts = ProgramDraft.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @program_drafts }
    end
  end

  # GET /program_drafts/1
  # GET /program_drafts/1.xml
  def show
    @program_draft = ProgramDraft.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program_draft }
    end
  end

  # GET /program_drafts/new
  # GET /program_drafts/new.xml
  def new
    @program_draft = ProgramDraft.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @program_draft }
    end
  end

  # GET /program_drafts/1/edit
  def edit
    @program_draft = ProgramDraft.find(params[:id])
  end

  # POST /program_drafts
  # POST /program_drafts.xml
  def create
    @program_draft = ProgramDraft.new(params[:program_draft])

    respond_to do |format|
      if @program_draft.save
        format.html { redirect_to([:scaffold, @program_draft], :notice => 'Program draft was successfully created.') }
        format.xml  { render :xml => @program_draft, :status => :created, :location => @program_draft }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @program_draft.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /program_drafts/1
  # PUT /program_drafts/1.xml
  def update
    @program_draft = ProgramDraft.find(params[:id])

    respond_to do |format|
      if @program_draft.update_attributes(params[:program_draft])
        format.html { redirect_to([:scaffold, @program_draft], :notice => 'Program draft was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program_draft.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /program_drafts/1
  # DELETE /program_drafts/1.xml
  def destroy
    @program_draft = ProgramDraft.find(params[:id])
    @program_draft.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_program_drafts_url) }
      format.xml  { head :ok }
    end
  end
end
