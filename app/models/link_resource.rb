# == Schema Information
#
# Table name: link_resources
#
#  id                 :integer(4)      not null, primary key
#  url                :string(255)
#  bitly_url          :string(255)
#  bitly_hash         :string(255)
#  bitly_stats        :text
#  url_title          :string(255)
#  domain             :string(255)
#  description        :text
#  link_type          :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer(4)
#

require 'uri'
require 'hpricot'
require 'open-uri'

class LinkResource < ActiveRecord::Base
    # From http://docs.heroku.com/s3
    has_attached_file :photo, 
      :styles => {:large => "800x800>", 
                  :medium => "300x300>", 
                  :small => "100x100#", 
                  :tiny => "85x85#"},
      :storage => :s3, 
      :s3_credentials => "#{Rails.root}/config/s3.yml", 
      :path => "/:class/:attachment/:id/:style_:basename.:extension",
      :url => "/:class/:attachment/:id/:style_:basename.:extension",
      :bucket => 'budge_production'

  has_many :player_message_resources
  has_many :player_messages, :through => :player_message_resources
  before_create :get_bitly_url
  after_create :get_page_title
  serialize :bitly_stats
  
  def get_bitly_url
    o = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
    original = "#{self.url}"
    original.gsub!(/[.,!?]$/,'')
    normalized = LinkResource.normalize_url(original)
    logger.warn "ORIGINAL: #{original}, NORMALIZED: #{normalized} #{CGI::escape(normalized)}"
    url_data = {:original => original.to_s, :normalized => normalized.to_s, :domain => URI::parse(normalized).host}
    
    self.domain = url_data[:domain]
    normalized = LinkResource.normalize_url(self.url)
  
    bitly_url = "http://api.bitly.com/v3/shorten?login=#{o[Rails.env]['bitly']['username']}&apiKey=#{o[Rails.env]['bitly']['api_key']}&format=json&longUrl=#{CGI::escape(normalized)}&domain=bit.ly"
    uri = URI.parse(bitly_url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    parsed_json = JSON.parse(response.body)

    if parsed_json.present? and parsed_json['status_code'] == 200 and parsed_json['data']['url'].present?
      self.bitly_url = parsed_json['data']['url']
      self.bitly_hash = parsed_json['data']['hash']
    end
  end
  
  def get_page_title
    return true if self.url_title.present?
    return false unless self.url.present?
    
    begin
      doc=Hpricot(open(self.url))
      self.url_title =(doc/"title").inner_text
      self.url_title.gsub(/\s+/,' ').strip!
      self.save
    rescue => e
      logger.warn e.message
    end
  end
  
  def name
    if self.url_title.present?
      return self.url_title
    else
      return "(unknown title)"
    end
  end
  
  def self.normalize_url(link)
    return link.gsub(/[.,!?]$/,'').gsub(/([^\/])(\?)/,'\1/\2').to_s
  end
  
  # Take text and return a list of urls attached to bitly and link resources
  def self.convert_text_to_link_resources(text)
    urls = []
    
    o = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
    protocols = %w[http https ftp]; 
    
    protocols.map{|pr| URI::extract(text, pr) }.flatten.compact.each do |uri|
      next if uri.match(/^http:\/\/#{DOMAIN}/) 
      original = uri
      original.gsub!(/[.,!?]$/,'')
      normalized = self.normalize_url(original)
      logger.warn "ORIGINAL: #{original}, NORMALIZED: #{normalized} #{CGI::escape(normalized)}"
      url_data = {:original => original.to_s, :normalized => normalized.to_s, :domain => URI::parse(uri).host}
      
      # Create a link_resource for this url
      link_resource = LinkResource.find_or_initialize_by_url(url_data[:normalized])
      link_resource.domain = url_data[:domain]
      
      # If it needs a bit.ly, get one
      if link_resource.bitly_url.blank?
        bitly_url = "http://api.bitly.com/v3/shorten?login=#{o[Rails.env]['bitly']['username']}&apiKey=#{o[Rails.env]['bitly']['api_key']}&format=json&longUrl=#{CGI::escape(normalized)}&domain=bit.ly"
        uri = URI.parse(bitly_url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        parsed_json = JSON.parse(response.body)
  
        if parsed_json.present? and parsed_json['status_code'] == 200 and parsed_json['data']['url'].present?
          link_resource.bitly_url = parsed_json['data']['url']
          link_resource.bitly_hash = parsed_json['data']['hash']
        end
      end
      
      link_resource.save
      url_data[:link_resource] = link_resource      
      urls << url_data 
    end
    
    return urls  
  end
  
  ### USED FOR PLAYER MESSAGES - START ###
  # Turn text with urls into text with real shortened budge links
  def self.convert_link_resources_to_notifications(text, urls, from_user, to_user, delivered_via, for_object)
    return text unless urls.present? and from_user.present? and to_user.present?
    
    urls.each do |url_data|
      # If it needs to be turned into a Notification, do that
      notification = Notification.create({
                      :user_id => to_user.id,
                      :delivered_via => delivered_via,
                      :message_style_token => 'generic',
                      :message_data => {:data => url_data[:link_resource]},
                      :from_user_id => from_user.id,
                      :from_system => false,
                      :for_object => for_object,
                      :for_id => url_data[:link_resource].id, # it's for the link_resource, not the player_message? 
                      :delivered_immediately => false,
                      :expected_response => true})

      # Figure out what we're gonna replace the url with
      url_data[:replacement] = notification.url.present? ? notification.url : (url_data[:link_resource].bitly_url.present? ? url_data[:link_resource].bitly_url : url_data[:normalized])

      text.gsub!("#{url_data[:original]}","#{url_data[:replacement]}")
    end
    return text
  end
  
  ### USED FOR AUTO MESSAGES - START ###
  # Turn text with urls into text with stub links to link_resource_ids
  def self.replace_links_with_link_resource_urls(text, urls)
    return text unless urls.present? 
    
    urls.each do |url_data|
      if url_data[:link_resource].present?
        url_data[:replacement] = "http://#{DOMAIN}/lr/#{url_data[:link_resource].id}"
        text.gsub!("#{url_data[:original]}","#{url_data[:replacement]}")
      end
    end
    
    return text
  end
  
  # Take text and return a list of urls attached to bitly and link resources
  # Text should have already been treated with self.replace_links_with_link_resource_urls above (no bare links!)
  def self.convert_auto_message_into_player_message_text(auto_message, player_budge)
    o = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
    protocols = %w[http https]; 
    
    text = auto_message.content
    protocols.map{|pr| URI::extract(text, pr) }.flatten.compact.each do |uri|
      if uri.match(/^http:\/\/#{DOMAIN}\/lr\/(\d+)/) 
        link_resource_id = $1
        link_resource = LinkResource.find(link_resource_id)
        if link_resource.present?
          # If it needs to be turned into a Notification, do that
          notification = Notification.create({
                          :user_id => player_budge.program_player.user_id,
                          :delivered_via => auto_message.deliver_via,
                          :message_style_token => 'generic',
                          :message_data => {:data => link_resource},
                          :from_system => true,
                          :for_object => 'send_link_resource',
                          :for_id => link_resource.id, # it's for the link_resource, not the player_message? 
                          :delivered_immediately => false,
                          :expected_response => true})
    
          text.gsub!("http://#{DOMAIN}/lr/#{link_resource.id}","#{notification.url}")        
        end
      end      
    end
    
    return text  
  end

  
end
