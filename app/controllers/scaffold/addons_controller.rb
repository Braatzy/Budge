class Scaffold::AddonsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /addons
  # GET /addons.xml
  def index
    @addons = Addon.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @addons }
    end
  end

  # GET /addons/1
  # GET /addons/1.xml
  def show
    @addon = Addon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @addon }
    end
  end

  # GET /addons/new
  # GET /addons/new.xml
  def new
    @addon = Addon.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @addon }
    end
  end

  # GET /addons/1/edit
  def edit
    @addon = Addon.find(params[:id])
  end

  # POST /addons
  # POST /addons.xml
  def create
    @addon = Addon.new(params[:addon])

    respond_to do |format|
      if @addon.save
        format.html { redirect_to([:scaffold, @addon], :notice => 'Addon was successfully created.') }
        format.xml  { render :xml => @addon, :status => :created, :location => @addon }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @addon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /addons/1
  # PUT /addons/1.xml
  def update
    @addon = Addon.find(params[:id])

    respond_to do |format|
      if @addon.update_attributes(params[:addon])
        format.html { redirect_to([:scaffold, @addon], :notice => 'Addon was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @addon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /addons/1
  # DELETE /addons/1.xml
  def destroy
    @addon = Addon.find(params[:id])
    @addon.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_addons_url) }
      format.xml  { head :ok }
    end
  end
end
