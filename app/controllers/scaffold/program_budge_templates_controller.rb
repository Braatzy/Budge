class Scaffold::ProgramBudgeTemplatesController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /program_budge_templates
  # GET /program_budge_templates.xml
  def index
    @program_budge_templates = ProgramBudgeTemplate.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @program_budge_templates }
    end
  end

  # GET /program_budge_templates/1
  # GET /program_budge_templates/1.xml
  def show
    @program_budge_template = ProgramBudgeTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program_budge_template }
    end
  end

  # GET /program_budge_templates/new
  # GET /program_budge_templates/new.xml
  def new
    @program_budge_template = ProgramBudgeTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @program_budge_template }
    end
  end

  # GET /program_budge_templates/1/edit
  def edit
    @program_budge_template = ProgramBudgeTemplate.find(params[:id])
  end

  # POST /program_budge_templates
  # POST /program_budge_templates.xml
  def create
    @program_budge_template = ProgramBudgeTemplate.new(params[:program_budge_template])

    respond_to do |format|
      if @program_budge_template.save
        format.html { redirect_to([:scaffold, @program_budge_template], :notice => 'Program budge template was successfully created.') }
        format.xml  { render :xml => @program_budge_template, :status => :created, :location => @program_budge_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @program_budge_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /program_budge_templates/1
  # PUT /program_budge_templates/1.xml
  def update
    @program_budge_template = ProgramBudgeTemplate.find(params[:id])

    respond_to do |format|
      if @program_budge_template.update_attributes(params[:program_budge_template])
        format.html { redirect_to([:scaffold, @program_budge_template], :notice => 'Program budge template was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program_budge_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /program_budge_templates/1
  # DELETE /program_budge_templates/1.xml
  def destroy
    @program_budge_template = ProgramBudgeTemplate.find(params[:id])
    @program_budge_template.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_program_budge_templates_url) }
      format.xml  { head :ok }
    end
  end
end
