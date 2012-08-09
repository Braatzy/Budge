class Scaffold::UserTraitsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /user_traits
  # GET /user_traits.xml
  def index
    @user_traits = UserTrait.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_traits }
    end
  end

  # GET /user_traits/1
  # GET /user_traits/1.xml
  def show
    @user_trait = UserTrait.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_trait }
    end
  end

  # GET /user_traits/new
  # GET /user_traits/new.xml
  def new
    @user_trait = UserTrait.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_trait }
    end
  end

  # GET /user_traits/1/edit
  def edit
    @user_trait = UserTrait.find(params[:id])
  end

  # POST /user_traits
  # POST /user_traits.xml
  def create
    @user_trait = UserTrait.new(params[:user_trait])

    respond_to do |format|
      if @user_trait.save
        format.html { redirect_to([:scaffold, @user_trait], :notice => 'User trait was successfully created.') }
        format.xml  { render :xml => @user_trait, :status => :created, :location => @user_trait }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_traits/1
  # PUT /user_traits/1.xml
  def update
    @user_trait = UserTrait.find(params[:id])

    respond_to do |format|
      if @user_trait.update_attributes(params[:user_trait])
        format.html { redirect_to([:scaffold, @user_trait], :notice => 'User trait was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_traits/1
  # DELETE /user_traits/1.xml
  def destroy
    @user_trait = UserTrait.find(params[:id])
    @user_trait.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_user_traits_url) }
      format.xml  { head :ok }
    end
  end
end
