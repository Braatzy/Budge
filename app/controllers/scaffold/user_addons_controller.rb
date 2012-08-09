class Scaffold::UserAddonsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /user_addons
  # GET /user_addons.xml
  def index
    @user_addons = UserAddon.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_addons }
    end
  end

  # GET /user_addons/1
  # GET /user_addons/1.xml
  def show
    @user_addon = UserAddon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_addon }
    end
  end

  # GET /user_addons/new
  # GET /user_addons/new.xml
  def new
    @user_addon = UserAddon.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_addon }
    end
  end

  # GET /user_addons/1/edit
  def edit
    @user_addon = UserAddon.find(params[:id])
  end

  # POST /user_addons
  # POST /user_addons.xml
  def create
    @user_addon = UserAddon.new(params[:user_addon])

    respond_to do |format|
      if @user_addon.save
        format.html { redirect_to([:scaffold, @user_addon], :notice => 'User addon was successfully created.') }
        format.xml  { render :xml => @user_addon, :status => :created, :location => @user_addon }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_addon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_addons/1
  # PUT /user_addons/1.xml
  def update
    @user_addon = UserAddon.find(params[:id])

    respond_to do |format|
      if @user_addon.update_attributes(params[:user_addon])
        format.html { redirect_to([:scaffold, @user_addon], :notice => 'User addon was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_addon.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_addons/1
  # DELETE /user_addons/1.xml
  def destroy
    @user_addon = UserAddon.find(params[:id])
    @user_addon.destroy

    respond_to do |format|
      format.html { redirect_to([:scaffold, user_addons_url]) }
      format.xml  { head :ok }
    end
  end
end
