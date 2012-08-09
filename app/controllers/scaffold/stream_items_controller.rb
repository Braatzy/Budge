class Scaffold::StreamItemsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  # GET /stream_items
  # GET /stream_items.xml
  def index
    @stream_items = StreamItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stream_items }
    end
  end

  # GET /stream_items/1
  # GET /stream_items/1.xml
  def show
    @stream_item = StreamItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stream_item }
    end
  end

  # GET /stream_items/new
  # GET /stream_items/new.xml
  def new
    @stream_item = StreamItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stream_item }
    end
  end

  # GET /stream_items/1/edit
  def edit
    @stream_item = StreamItem.find(params[:id])
  end

  # POST /stream_items
  # POST /stream_items.xml
  def create
    @stream_item = StreamItem.new(params[:stream_item])

    respond_to do |format|
      if @stream_item.save
        format.html { redirect_to([:scaffold, @stream_item], :notice => 'Stream item was successfully created.') }
        format.xml  { render :xml => @stream_item, :status => :created, :location => @stream_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stream_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stream_items/1
  # PUT /stream_items/1.xml
  def update
    @stream_item = StreamItem.find(params[:id])

    respond_to do |format|
      if @stream_item.update_attributes(params[:stream_item])
        format.html { redirect_to([:scaffold, @stream_item], :notice => 'Stream item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stream_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stream_items/1
  # DELETE /stream_items/1.xml
  def destroy
    @stream_item = StreamItem.find(params[:id])
    @stream_item.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_stream_items_url) }
      format.xml  { head :ok }
    end
  end
end
