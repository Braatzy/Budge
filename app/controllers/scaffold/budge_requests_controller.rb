class Scaffold::BudgeRequestsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  # GET /budge_requests
  # GET /budge_requests.xml
  def index
    @budge_requests = BudgeRequest.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @budge_requests }
    end
  end

  # GET /budge_requests/1
  # GET /budge_requests/1.xml
  def show
    @budge_request = BudgeRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @budge_request }
    end
  end

  # GET /budge_requests/new
  # GET /budge_requests/new.xml
  def new
    @budge_request = BudgeRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @budge_request }
    end
  end

  # GET /budge_requests/1/edit
  def edit
    @budge_request = BudgeRequest.find(params[:id])
  end

  # POST /budge_requests
  # POST /budge_requests.xml
  def create
    @budge_request = BudgeRequest.new(params[:budge_request])

    respond_to do |format|
      if @budge_request.save
        format.html { redirect_to([:scaffold, @budge_request], :notice => 'Budge request was successfully created.') }
        format.xml  { render :xml => @budge_request, :status => :created, :location => @budge_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @budge_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /budge_requests/1
  # PUT /budge_requests/1.xml
  def update
    @budge_request = BudgeRequest.find(params[:id])

    respond_to do |format|
      if @budge_request.update_attributes(params[:budge_request])
        format.html { redirect_to([:scaffold, @budge_request], :notice => 'Budge request was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @budge_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /budge_requests/1
  # DELETE /budge_requests/1.xml
  def destroy
    @budge_request = BudgeRequest.find(params[:id])
    @budge_request.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_budge_requests_url) }
      format.xml  { head :ok }
    end
  end
end
