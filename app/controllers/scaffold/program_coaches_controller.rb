class Scaffold::ProgramCoachesController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /program_coaches
  # GET /program_coaches.xml
  def index
    @program_coaches = ProgramCoach.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @program_coaches }
    end
  end

  # GET /program_coaches/1
  # GET /program_coaches/1.xml
  def show
    @program_coach = ProgramCoach.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program_coach }
    end
  end

  # GET /program_coaches/new
  # GET /program_coaches/new.xml
  def new
    @program_coach = ProgramCoach.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @program_coach }
    end
  end

  # GET /program_coaches/1/edit
  def edit
    @program_coach = ProgramCoach.find(params[:id])
  end

  # POST /program_coaches
  # POST /program_coaches.xml
  def create
    @program_coach = ProgramCoach.new(params[:program_coach])

    respond_to do |format|
      if @program_coach.save
        format.html { redirect_to([:scaffold, @program_coach], :notice => 'Program coach was successfully created.') }
        format.xml  { render :xml => @program_coach, :status => :created, :location => @program_coach }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @program_coach.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /program_coaches/1
  # PUT /program_coaches/1.xml
  def update
    @program_coach = ProgramCoach.find(params[:id])

    respond_to do |format|
      if @program_coach.update_attributes(params[:program_coach])
        format.html { redirect_to([:scaffold, @program_coach], :notice => 'Program coach was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program_coach.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /program_coaches/1
  # DELETE /program_coaches/1.xml
  def destroy
    @program_coach = ProgramCoach.find(params[:id])
    @program_coach.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_program_coaches_url) }
      format.xml  { head :ok }
    end
  end
end
