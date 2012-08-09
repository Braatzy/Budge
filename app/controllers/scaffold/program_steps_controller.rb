class Scaffold::ProgramStepsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /program_steps
  # GET /program_steps.xml
  def index
    @program_steps = ProgramStep.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @program_steps }
    end
  end

  # GET /program_steps/1
  # GET /program_steps/1.xml
  def show
    @program_step = ProgramStep.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program_step }
    end
  end

  # GET /program_steps/new
  # GET /program_steps/new.xml
  def new
    @program_step = ProgramStep.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @program_step }
    end
  end

  # GET /program_steps/1/edit
  def edit
    @program_step = ProgramStep.find(params[:id])
  end

  # POST /program_steps
  # POST /program_steps.xml
  def create
    @program_step = ProgramStep.new(params[:program_step])

    respond_to do |format|
      if @program_step.save
        format.html { redirect_to([:scaffold, @program_step], :notice => 'Program step was successfully created.') }
        format.xml  { render :xml => @program_step, :status => :created, :location => @program_step }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @program_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /program_steps/1
  # PUT /program_steps/1.xml
  def update
    @program_step = ProgramStep.find(params[:id])

    respond_to do |format|
      if @program_step.update_attributes(params[:program_step])
        format.html { redirect_to([:scaffold, @program_step], :notice => 'Program step was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program_step.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /program_steps/1
  # DELETE /program_steps/1.xml
  def destroy
    @program_step = ProgramStep.find(params[:id])
    @program_step.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_program_steps_url) }
      format.xml  { head :ok }
    end
  end
end
