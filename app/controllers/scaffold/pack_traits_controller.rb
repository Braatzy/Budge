class Scaffold::PackTraitsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'

  # GET /pack_traits
  # GET /pack_traits.xml
  def index
    @pack_traits = PackTrait.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pack_traits }
    end
  end

  # GET /pack_traits/1
  # GET /pack_traits/1.xml
  def show
    @pack_trait = PackTrait.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pack_trait }
    end
  end

  # GET /pack_traits/new
  # GET /pack_traits/new.xml
  def new
    @pack_trait = PackTrait.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pack_trait }
    end
  end

  # GET /pack_traits/1/edit
  def edit
    @pack_trait = PackTrait.find(params[:id])
  end

  # POST /pack_traits
  # POST /pack_traits.xml
  def create
    @pack_trait = PackTrait.new(params[:pack_trait])

    respond_to do |format|
      if @pack_trait.save
        format.html { redirect_to([:scaffold, @pack_trait], :notice => 'Pack trait was successfully created.') }
        format.xml  { render :xml => @pack_trait, :status => :created, :location => @pack_trait }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pack_trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pack_traits/1
  # PUT /pack_traits/1.xml
  def update
    @pack_trait = PackTrait.find(params[:id])

    respond_to do |format|
      if @pack_trait.update_attributes(params[:pack_trait])
        format.html { redirect_to([:scaffold, @pack_trait], :notice => 'Pack trait was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pack_trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pack_traits/1
  # DELETE /pack_traits/1.xml
  def destroy
    @pack_trait = PackTrait.find(params[:id])
    @pack_trait.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_pack_traits_url) }
      format.xml  { head :ok }
    end
  end
end
