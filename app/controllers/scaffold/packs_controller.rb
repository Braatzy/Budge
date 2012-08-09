class Scaffold::PacksController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  def add_trait_to_pack
    if request.post?
        @pack = Pack.find(params[:id])
        @trait = Trait.find(params[:trait_id])
        unless @pack.traits.include?(@trait)
            @pack.pack_traits.create({:trait_id => @trait.id,
                                         :level => params[:level]})
        end
        respond_to do |format|
          format.js
        end
    end
  end

  def remove_trait_from_pack
    if request.post?
        @pack = Pack.find(params[:id])
        @trait = Trait.find(params[:trait_id])
        if @pack.traits.include?(@trait)
            @pack.pack_traits.find(:first, :conditions => ['trait_id = ?', @trait.id]).destroy # .destroy destroys the trait model (not good)
        end
        respond_to do |format|
          format.js
        end
    end
  end
  
  # GET /packs
  # GET /packs.xml
  def index
    @packs = Pack.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @packs }
    end
  end

  # GET /packs/1
  # GET /packs/1.xml
  def show
    @pack = Pack.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pack }
    end
  end

  # GET /packs/new
  # GET /packs/new.xml
  def new
    @pack = Pack.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pack }
    end
  end

  # GET /packs/1/edit
  def edit
    @pack = Pack.find(params[:id])
  end

  # POST /packs
  # POST /packs.xml
  def create
    @pack = Pack.new(params[:pack])

    respond_to do |format|
      if @pack.save
        format.html { redirect_to([:scaffold, @pack], :notice => 'Pack was successfully created.') }
        format.xml  { render :xml => @pack, :status => :created, :location => @pack }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pack.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /packs/1
  # PUT /packs/1.xml
  def update
    @pack = Pack.find(params[:id])

    respond_to do |format|
      if @pack.update_attributes(params[:pack])
        format.html { redirect_to([:scaffold, @pack], :notice => 'Pack was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pack.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /packs/1
  # DELETE /packs/1.xml
  def destroy
    @pack = Pack.find(params[:id])
    @pack.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_packs_url) }
      format.xml  { head :ok }
    end
  end
end
