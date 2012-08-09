class Scaffold::OauthTokensController < ApplicationController
  before_filter :admin_required, :except => 'foursquare_categories'
  layout 'scaffold'
  
  def foursquare_categories
    oauth_token = OauthToken.find(:first, :conditions => ['site_token = ?', 'foursquare'])
    consumer = OauthToken.get_consumer(oauth_token.site_token)
    access_token = OAuth::AccessToken.new(consumer, oauth_token.token, oauth_token.secret)

    access_token = OAuth::AccessToken.new(consumer, oauth_token.token, oauth_token.secret)
    response = access_token.get("/v2/venues/categories?v=20110426&oauth_token=#{CGI::escape(oauth_token.token)}",{'User-Agent'=>'Bud.ge'})
    parsed_response = JSON.parse(response.body) rescue nil
    @categories = parsed_response['response']['categories']
  end

  # GET /oauth_tokens
  # GET /oauth_tokens.xml
  def index
    @oauth_tokens = OauthToken.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @oauth_tokens }
    end
  end

  # GET /oauth_tokens/1
  # GET /oauth_tokens/1.xml
  def show
    if params[:id] == 'foursquare_categories'
      foursquare_categories
      render :action => :foursquare_categories
      return
    end
    @oauth_token = OauthToken.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @oauth_token }
    end
  end

  # GET /oauth_tokens/new
  # GET /oauth_tokens/new.xml
  def new
    @oauth_token = OauthToken.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @oauth_token }
    end
  end

  # GET /oauth_tokens/1/edit
  def edit
    @oauth_token = OauthToken.find(params[:id])
  end

  # POST /oauth_tokens
  # POST /oauth_tokens.xml
  def create
    @oauth_token = OauthToken.new(params[:oauth_token])

    respond_to do |format|
      if @oauth_token.save
        format.html { redirect_to([:scaffold, @oauth_token], :notice => 'Oauth token was successfully created.') }
        format.xml  { render :xml => @oauth_token, :status => :created, :location => @oauth_token }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @oauth_token.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /oauth_tokens/1
  # PUT /oauth_tokens/1.xml
  def update
    @oauth_token = OauthToken.find(params[:id])

    respond_to do |format|
      if @oauth_token.update_attributes(params[:oauth_token])
        format.html { redirect_to([:scaffold, @oauth_token], :notice => 'Oauth token was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @oauth_token.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /oauth_tokens/1
  # DELETE /oauth_tokens/1.xml
  def destroy
    @oauth_token = OauthToken.find(params[:id])
    @oauth_token.destroy

    respond_to do |format|
      format.html { redirect_to(scaffold_oauth_tokens_url) }
      format.xml  { head :ok }
    end
  end
end
