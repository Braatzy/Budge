class Scaffold::LocationContextsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /location_contexts
  # GET /location_contexts.xml
  def index
    @location_contexts = LocationContext.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @location_contexts }
    end
  end

  # GET /location_contexts/1
  # GET /location_contexts/1.xml
  def show
    @location_context = LocationContext.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location_context }
    end
  end

  # GET /location_contexts/new
  # GET /location_contexts/new.xml
  def new
    @location_context = LocationContext.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location_context }
    end
  end

  # GET /location_contexts/1/edit
  def edit
    @location_context = LocationContext.find(params[:id])
  end

  # POST /location_contexts
  # POST /location_contexts.xml
  def create
    @location_context = LocationContext.new(params[:location_context])

    respond_to do |format|
      if @location_context.save
        format.html { redirect_to([:scaffold, @location_context], :notice => 'Location context was successfully created.') }
        format.xml  { render :xml => @location_context, :status => :created, :location => @location_context }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location_context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /location_contexts/1
  # PUT /location_contexts/1.xml
  def update
    @location_context = LocationContext.find(params[:id])

    respond_to do |format|
      if @location_context.update_attributes(params[:location_context])
        format.html { redirect_to([:scaffold, @location_context], :notice => 'Location context was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location_context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /location_contexts/1
  # DELETE /location_contexts/1.xml
  def destroy
    @location_context = LocationContext.find(params[:id])
    @location_context.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_location_contexts_url) }
      format.xml  { head :ok }
    end
  end
end
