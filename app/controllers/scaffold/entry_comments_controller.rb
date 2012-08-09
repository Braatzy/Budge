class Scaffold::EntryCommentsController < ApplicationController
  # GET /entry_comments
  # GET /entry_comments.xml
  def index
    @entry_comments = EntryComment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entry_comments }
    end
  end

  # GET /entry_comments/1
  # GET /entry_comments/1.xml
  def show
    @entry_comment = EntryComment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entry_comment }
    end
  end

  # GET /entry_comments/new
  # GET /entry_comments/new.xml
  def new
    @entry_comment = EntryComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @entry_comment }
    end
  end

  # GET /entry_comments/1/edit
  def edit
    @entry_comment = EntryComment.find(params[:id])
  end

  # POST /entry_comments
  # POST /entry_comments.xml
  def create
    @entry_comment = EntryComment.new(params[:entry_comment])

    respond_to do |format|
      if @entry_comment.save
        format.html { redirect_to([:scaffold, @entry_comment], :notice => 'Entry comment was successfully created.') }
        format.xml  { render :xml => @entry_comment, :status => :created, :location => @entry_comment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entry_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /entry_comments/1
  # PUT /entry_comments/1.xml
  def update
    @entry_comment = EntryComment.find(params[:id])

    respond_to do |format|
      if @entry_comment.update_attributes(params[:entry_comment])
        format.html { redirect_to([:scaffold, @entry_comment], :notice => 'Entry comment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entry_comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /entry_comments/1
  # DELETE /entry_comments/1.xml
  def destroy
    @entry_comment = EntryComment.find(params[:id])
    @entry_comment.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_entry_comments_url) }
      format.xml  { head :ok }
    end
  end
end
