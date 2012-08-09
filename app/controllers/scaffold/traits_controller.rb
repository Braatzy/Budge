require 'csv'
require 'fastercsv' if Rails.env.development?

class Scaffold::TraitsController < ApplicationController
  before_filter :admin_required
  layout 'scaffold'
  
  # 0 admin action 
  # 1 verb
  # 2 noun
  # 3 do_name
  # 4 dont_name
  # 5 answer_type
  # 6 token
  # 7 primary_pack_token
  # 8 parent_trait_token
  # 9 setup_required? 
  # 10 daily_question
  # 11 article
  # 12 past_template - template to use in stream for action just completed
  # 13 hashtag - to pull from twitter
  def import_traits
    if request.post?
      if Rails.env.production?
        @file = CSV.parse(params[:file].read)
      else
        @file = FasterCSV.parse(params[:file].read)
      end
      
      @file.each do |row|

        next unless row.present? and row[5].present?
        next if row[0] == 'action' # for the top header row
        
        trait = Trait.find_or_initialize_by_token(row[6])
        parent_trait = Trait.find_by_token(row[8]) rescue nil
        parent_trait_id = parent_trait.id if parent_trait
        trait.attributes = {:verb => row[1],
                            :noun  => row[2],
                            :do_name => row[3],
                            :dont_name => row[4],
                            :answer_type => row[5],
                            :primary_pack_token => row[7],
                            :parent_trait_id => parent_trait_id,
                            :setup_required => row[9],
                            :daily_question => row[10],
                            :article => row[11],
                            :past_template => row[12],
                            :hashtag => row[13]}

        if row[0].present? and row[0] == 'delete'
          PackTrait.destroy_all(:trait_id => trait.id)
          trait.destroy
        else                            
          if trait.save and trait.primary_pack_token.present?
            logger.warn "SUCCESS TRAIT: #{trait.inspect}"
            pack = Pack.find_or_create_by_token(trait.primary_pack_token)
            unless pack.traits.include?(trait)
                pack.pack_traits.create({:trait_id => trait.id})
            end
          else
            logger.warn "FAIL TRAIT: #{trait.inspect}"          
          end
        end
      end      
    end
    redirect_to :action => :index
  end
  
  def trait_tenses
    @traits = Trait.find(:all)
  end

  def trait_statements
    @traits = Trait.find(:all)
  end
  
  # GET /traits
  # GET /traits.xml
  def index
    @traits = Trait.all
    @trait_action_object_hash = Trait.action_object_hash
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @traits }
    end
  end

  # GET /traits/1
  # GET /traits/1.xml
  def show
    @trait = Trait.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trait }
    end
  end

  # GET /traits/new
  # GET /traits/new.xml
  def new
    @trait = Trait.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trait }
    end
  end

  # GET /traits/1/edit
  def edit
    @trait = Trait.find(params[:id])
  end

  # POST /traits
  # POST /traits.xml
  def create
    @trait = Trait.new(params[:trait])

    respond_to do |format|
      if @trait.save
        format.html { redirect_to([:scaffold, @trait], :notice => 'Trait was successfully created.') }
        format.xml  { render :xml => @trait, :status => :created, :location => @trait }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /traits/1
  # PUT /traits/1.xml
  def update
    @trait = Trait.find(params[:id])

    respond_to do |format|
      if @trait.update_attributes(params[:trait])
        format.html { redirect_to([:scaffold, @trait], :notice => 'Trait was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trait.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /traits/1
  # DELETE /traits/1.xml
  def destroy
    @trait = Trait.find(params[:id])
    @trait.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_traits_url) }
      format.xml  { head :ok }
    end
  end
end
