class Scaffold::UserNagModesController < ApplicationController
  layout 'scaffold'
  before_filter :admin_required
   
  # GET /user_nag_modes
  # GET /user_nag_modes.xml
  def index
    @user_nag_modes = UserNagMode.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_nag_modes }
    end
  end

  # GET /user_nag_modes/1
  # GET /user_nag_modes/1.xml
  def show
    @user_nag_mode = UserNagMode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_nag_mode }
    end
  end

  # GET /user_nag_modes/new
  # GET /user_nag_modes/new.xml
  def new
    @user_nag_mode = UserNagMode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_nag_mode }
    end
  end

  # GET /user_nag_modes/1/edit
  def edit
    @user_nag_mode = UserNagMode.find(params[:id])
  end

  # POST /user_nag_modes
  # POST /user_nag_modes.xml
  def create
    @user_nag_mode = UserNagMode.new(params[:user_nag_mode])

    respond_to do |format|
      if @user_nag_mode.save
        format.html { redirect_to([:scaffold, @user_nag_mode], :notice => 'User nag mode was successfully created.') }
        format.xml  { render :xml => @user_nag_mode, :status => :created, :location => @user_nag_mode }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_nag_mode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_nag_modes/1
  # PUT /user_nag_modes/1.xml
  def update
    @user_nag_mode = UserNagMode.find(params[:id])

    respond_to do |format|
      if @user_nag_mode.update_attributes(params[:user_nag_mode])
        format.html { redirect_to([:scaffold, @user_nag_mode], :notice => 'User nag mode was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_nag_mode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_nag_modes/1
  # DELETE /user_nag_modes/1.xml
  def destroy
    @user_nag_mode = UserNagMode.find(params[:id])
    @user_nag_mode.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_user_nag_modes_url) }
      format.xml  { head :ok }
    end
  end
end
