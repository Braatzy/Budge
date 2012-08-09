class Scaffold::UserCommentsController < ApplicationController
  # GET /user_comments
  # GET /user_comments.xml
  def index
    @user_comments = UserComment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_comments }
    end
  end

  # GET /user_comments/1
  # GET /user_comments/1.xml
  def show
    @user_comment = UserComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_comment }
    end
  end

  # GET /user_comments/new
  # GET /user_comments/new.xml
  def new
    @user_comment = UserComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_comment }
    end
  end

  # GET /user_comments/1/edit
  def edit
    @user_comment = UserComment.find(params[:id])
  end

  # POST /user_comments
  # POST /user_comments.xml
  def create
    @user_comment = UserComment.new(params[:user_comment])

    respond_to do |format|
      if @user_comment.save
        format.html { redirect_to([:scaffold, @user_comment], :notice => 'User comment was successfully created.') }
        format.xml  { render :xml => @user_comment, :status => :created, :location => @user_comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_comments/1
  # PUT /user_comments/1.xml
  def update
    @user_comment = UserComment.find(params[:id])

    respond_to do |format|
      if @user_comment.update_attributes(params[:user_comment])
        format.html { redirect_to([:scaffold, @user_comment], :notice => 'User comment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_comments/1
  # DELETE /user_comments/1.xml
  def destroy
    @user_comment = UserComment.find(params[:id])
    @user_comment.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_user_comments_url) }
      format.xml  { head :ok }
    end
  end
end
