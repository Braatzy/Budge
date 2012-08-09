class Scaffold::LinkResourcesController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /link_resources
  # GET /link_resources.xml
  def index
    @link_resources = LinkResource.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @link_resources }
    end
  end

  # GET /link_resources/1
  # GET /link_resources/1.xml
  def show
    @link_resource = LinkResource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @link_resource }
    end
  end

  # GET /link_resources/new
  # GET /link_resources/new.xml
  def new
    @link_resource = LinkResource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @link_resource }
    end
  end

  # GET /link_resources/1/edit
  def edit
    @link_resource = LinkResource.find(params[:id])
  end

  # POST /link_resources
  # POST /link_resources.xml
  def create
    @link_resource = LinkResource.new(params[:link_resource])

    respond_to do |format|
      if @link_resource.save
        format.html { redirect_to([:scaffold, @link_resource], :notice => 'Link resource was successfully created.') }
        format.xml  { render :xml => @link_resource, :status => :created, :location => @link_resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @link_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /link_resources/1
  # PUT /link_resources/1.xml
  def update
    @link_resource = LinkResource.find(params[:id])

    respond_to do |format|
      if @link_resource.update_attributes(params[:link_resource])
        format.html { redirect_to([:scaffold, @link_resource], :notice => 'Link resource was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @link_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /link_resources/1
  # DELETE /link_resources/1.xml
  def destroy
    @link_resource = LinkResource.find(params[:id])
    @link_resource.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_link_resources_url) }
      format.xml  { head :ok }
    end
  end
end
