class Scaffold::FoursquareCategoriesController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  # GET /foursquare_categories
  # GET /foursquare_categories.xml
  def index
    @foursquare_categories = FoursquareCategory.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @foursquare_categories }
    end
  end

  # GET /foursquare_categories/1
  # GET /foursquare_categories/1.xml
  def show
    @foursquare_category = FoursquareCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @foursquare_category }
    end
  end

  # GET /foursquare_categories/new
  # GET /foursquare_categories/new.xml
  def new
    @foursquare_category = FoursquareCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @foursquare_category }
    end
  end

  # GET /foursquare_categories/1/edit
  def edit
    @foursquare_category = FoursquareCategory.find(params[:id])
  end

  # POST /foursquare_categories
  # POST /foursquare_categories.xml
  def create
    @foursquare_category = FoursquareCategory.new(params[:foursquare_category])

    respond_to do |format|
      if @foursquare_category.save
        format.html { redirect_to([:scaffold, @foursquare_category], :notice => 'Foursquare category was successfully created.') }
        format.xml  { render :xml => @foursquare_category, :status => :created, :location => @foursquare_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @foursquare_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /foursquare_categories/1
  # PUT /foursquare_categories/1.xml
  def update
    @foursquare_category = FoursquareCategory.find(params[:id])

    respond_to do |format|
      if @foursquare_category.update_attributes(params[:foursquare_category])
        format.html { redirect_to([:scaffold, @foursquare_category], :notice => 'Foursquare category was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @foursquare_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /foursquare_categories/1
  # DELETE /foursquare_categories/1.xml
  def destroy
    @foursquare_category = FoursquareCategory.find(params[:id])
    @foursquare_category.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_foursquare_categories_url) }
      format.xml  { head :ok }
    end
  end
end
