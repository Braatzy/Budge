class Scaffold::DailyGrrsController < ApplicationController
  # GET /daily_grrs
  # GET /daily_grrs.xml
  def index
    @daily_grrs = DailyGrr.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @daily_grrs }
    end
  end

  # GET /daily_grrs/1
  # GET /daily_grrs/1.xml
  def show
    @daily_grr = DailyGrr.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @daily_grr }
    end
  end

  # GET /daily_grrs/new
  # GET /daily_grrs/new.xml
  def new
    @daily_grr = DailyGrr.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @daily_grr }
    end
  end

  # GET /daily_grrs/1/edit
  def edit
    @daily_grr = DailyGrr.find(params[:id])
  end

  # POST /daily_grrs
  # POST /daily_grrs.xml
  def create
    @daily_grr = DailyGrr.new(params[:daily_grr])

    respond_to do |format|
      if @daily_grr.save
        format.html { redirect_to([:scaffold, @daily_grr], :notice => 'Daily grr was successfully created.') }
        format.xml  { render :xml => @daily_grr, :status => :created, :location => @daily_grr }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @daily_grr.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /daily_grrs/1
  # PUT /daily_grrs/1.xml
  def update
    @daily_grr = DailyGrr.find(params[:id])

    respond_to do |format|
      if @daily_grr.update_attributes(params[:daily_grr])
        format.html { redirect_to([:scaffold, @daily_grr], :notice => 'Daily grr was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @daily_grr.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_grrs/1
  # DELETE /daily_grrs/1.xml
  def destroy
    @daily_grr = DailyGrr.find(params[:id])
    @daily_grr.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_daily_grrs_url) }
      format.xml  { head :ok }
    end
  end
end
