class Scaffold::VisitStatsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  # GET /visit_stats
  # GET /visit_stats.xml
  def index
    @visit_stats = VisitStat.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @visit_stats }
    end
  end

  # GET /visit_stats/1
  # GET /visit_stats/1.xml
  def show
    @visit_stat = VisitStat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @visit_stat }
    end
  end

  # GET /visit_stats/new
  # GET /visit_stats/new.xml
  def new
    @visit_stat = VisitStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @visit_stat }
    end
  end

  # GET /visit_stats/1/edit
  def edit
    @visit_stat = VisitStat.find(params[:id])
  end

  # POST /visit_stats
  # POST /visit_stats.xml
  def create
    @visit_stat = VisitStat.new(params[:visit_stat])

    respond_to do |format|
      if @visit_stat.save
        format.html { redirect_to([:scaffold, @visit_stat], :notice => 'Visit stat was successfully created.') }
        format.xml  { render :xml => @visit_stat, :status => :created, :location => @visit_stat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @visit_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /visit_stats/1
  # PUT /visit_stats/1.xml
  def update
    @visit_stat = VisitStat.find(params[:id])

    respond_to do |format|
      if @visit_stat.update_attributes(params[:visit_stat])
        format.html { redirect_to([:scaffold, @visit_stat], :notice => 'Visit stat was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @visit_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /visit_stats/1
  # DELETE /visit_stats/1.xml
  def destroy
    @visit_stat = VisitStat.find(params[:id])
    @visit_stat.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_visit_stats_url) }
      format.xml  { head :ok }
    end
  end
end
