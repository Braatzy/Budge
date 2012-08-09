class Scaffold::UserBudgesController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  # GET /user_budges
  # GET /user_budges.xml
  def index
    @user_budges = UserBudge.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_budges }
    end
  end

  # GET /user_budges/1
  # GET /user_budges/1.xml
  def show
    @user_budge = UserBudge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_budge }
    end
  end

  # GET /user_budges/new
  # GET /user_budges/new.xml
  def new
    @user_budge = UserBudge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_budge }
    end
  end

  # GET /user_budges/1/edit
  def edit
    @user_budge = UserBudge.find(params[:id])
  end

  # POST /user_budges
  # POST /user_budges.xml
  def create
    @user_budge = UserBudge.new(params[:user_budge])

    respond_to do |format|
      if @user_budge.save
        format.html { redirect_to([:scaffold, @user_budge], :notice => 'User budge was successfully created.') }
        format.xml  { render :xml => @user_budge, :status => :created, :location => @user_budge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_budge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_budges/1
  # PUT /user_budges/1.xml
  def update
    @user_budge = UserBudge.find(params[:id])

    respond_to do |format|
      if @user_budge.update_attributes(params[:user_budge])
        format.html { redirect_to([:scaffold, @user_budge], :notice => 'User budge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_budge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_budges/1
  # DELETE /user_budges/1.xml
  def destroy
    @user_budge = UserBudge.find(params[:id])
    @user_budge.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_user_budges_url) }
      format.xml  { head :ok }
    end
  end
end
