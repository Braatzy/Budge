class Scaffold::ProgramLinkResourcesController < ApplicationController
  # GET /program_link_resources
  # GET /program_link_resources.xml
  def index
    @program_link_resources = ProgramLinkResource.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @program_link_resources }
    end
  end

  # GET /program_link_resources/1
  # GET /program_link_resources/1.xml
  def show
    @program_link_resource = ProgramLinkResource.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @program_link_resource }
    end
  end

  # GET /program_link_resources/new
  # GET /program_link_resources/new.xml
  def new
    @program_link_resource = ProgramLinkResource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @program_link_resource }
    end
  end

  # GET /program_link_resources/1/edit
  def edit
    @program_link_resource = ProgramLinkResource.find(params[:id])
  end

  # POST /program_link_resources
  # POST /program_link_resources.xml
  def create
    @program_link_resource = ProgramLinkResource.new(params[:program_link_resource])

    respond_to do |format|
      if @program_link_resource.save
        format.html { redirect_to([:scaffold, @program_link_resource], :notice => 'Program link resource was successfully created.') }
        format.xml  { render :xml => @program_link_resource, :status => :created, :location => @program_link_resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @program_link_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /program_link_resources/1
  # PUT /program_link_resources/1.xml
  def update
    @program_link_resource = ProgramLinkResource.find(params[:id])

    respond_to do |format|
      if @program_link_resource.update_attributes(params[:program_link_resource])
        format.html { redirect_to([:scaffold, @program_link_resource], :notice => 'Program link resource was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @program_link_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /program_link_resources/1
  # DELETE /program_link_resources/1.xml
  def destroy
    @program_link_resource = ProgramLinkResource.find(params[:id])
    @program_link_resource.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_program_link_resources_url) }
      format.xml  { head :ok }
    end
  end
end
