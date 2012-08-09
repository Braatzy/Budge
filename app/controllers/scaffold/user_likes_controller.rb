class Scaffold::UserLikesController < ApplicationController
  # GET /user_likes
  # GET /user_likes.xml
  def index
    @user_likes = UserLike.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_likes }
    end
  end

  # GET /user_likes/1
  # GET /user_likes/1.xml
  def show
    @user_like = UserLike.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_like }
    end
  end

  # GET /user_likes/new
  # GET /user_likes/new.xml
  def new
    @user_like = UserLike.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_like }
    end
  end

  # GET /user_likes/1/edit
  def edit
    @user_like = UserLike.find(params[:id])
  end

  # POST /user_likes
  # POST /user_likes.xml
  def create
    @user_like = UserLike.new(params[:user_like])

    respond_to do |format|
      if @user_like.save
        format.html { redirect_to([:scaffold, @user_like], :notice => 'User like was successfully created.') }
        format.xml  { render :xml => @user_like, :status => :created, :location => @user_like }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_like.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_likes/1
  # PUT /user_likes/1.xml
  def update
    @user_like = UserLike.find(params[:id])

    respond_to do |format|
      if @user_like.update_attributes(params[:user_like])
        format.html { redirect_to([:scaffold, @user_like], :notice => 'User like was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_like.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_likes/1
  # DELETE /user_likes/1.xml
  def destroy
    @user_like = UserLike.find(params[:id])
    @user_like.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_user_likes_url) }
      format.xml  { head :ok }
    end
  end
end
