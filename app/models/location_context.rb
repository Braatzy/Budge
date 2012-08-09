# == Schema Information
#
# Table name: location_contexts
#
#  id                     :integer(4)      not null, primary key
#  user_id                :integer(4)
#  context_about          :string(255)
#  context_id             :integer(4)
#  latitude               :decimal(15, 10)
#  longitude              :decimal(15, 10)
#  population_density     :integer(4)      default(0)
#  temperature_f          :integer(4)
#  weather_conditions     :string(255)
#  simplegeo_context      :text
#  foursquare_place_id    :string(255)
#  foursquare_category_id :string(255)
#  foursquare_checkin_id  :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  foursquare_context     :text
#  foursquare_guess       :boolean(1)      default(FALSE)
#  place_name             :string(255)
#  possible_duplicate     :boolean(1)      default(FALSE)
#

class LocationContext < ActiveRecord::Base
  belongs_to :user
  belongs_to :foursquare_category, :primary_key => :category_id
  serialize :simplegeo_context
  serialize :foursquare_context
  before_save :load_simplegeo_context, :load_foursquare_context, :check_if_possible_duplicate
  after_save :update_last_location_for_user
  
  def load_simplegeo_context
    return if self.simplegeo_context.present?
    simplegeo_context = OauthToken.simplegeo_context(self.latitude, self.longitude)
    self.attributes = {:population_density => (simplegeo_context[:demographics][:population_density] rescue nil),
                       :temperature_f => (simplegeo_context[:weather][:temperature].gsub(/\D/,'') rescue nil),
                       :weather_conditions => (simplegeo_context[:weather][:conditions] rescue nil),
                       :simplegeo_context => simplegeo_context}
  end
  
  
  # Example result for foursquare_guess
  # {"name"=>"Habit Labs HQ (healthmonth.com)", "category"=>{"name"=>"Tech Startup", "parents"=>["Homes, Work, Others", "Offices"], "primary"=>true, "icon"=>"https://foursquare.com/img/categories/building/default.png", "id"=>"4bf58dd8d48988d125941735", "pluralName"=>"Tech Startups"}, "hereNow"=>{"count"=>0}, "location"=>{"city"=>"Seattle", "address"=>"2101 9th Avenue Suite #205", "country"=>"USA", "lng"=>-122.337268, "crossStreet"=>"btwn Lenora & Whole Foods", "postalCode"=>"98121", "lat"=>47.617274, "distance"=>51, "state"=>"WA"}, "todos"=>{"count"=>0}, "stats"=>{"checkinsCount"=>22, "usersCount"=>3}, "url"=>"http://habitlabs.com", "contact"=>{"twitter"=>"habitlabs"}, "id"=>"4dc992f71f6e4f316a840ba6", "verified"=>true, "categories"=>[{"name"=>"Tech Startup", "parents"=>["Homes, Work, Others", "Offices"], "primary"=>true, "icon"=>"https://foursquare.com/img/categories/building/default.png", "id"=>"4bf58dd8d48988d125941735", "pluralName"=>"Tech Startups"}
  def load_foursquare_context
    return if self.foursquare_place_id.present? or self.foursquare_context.present? or self.user_id.blank?
    foursquare_oauth = self.user.oauth_for_site_token(:foursquare)
    if foursquare_oauth.present?    
      foursquare_context = foursquare_oauth.nearby_places(self.latitude, self.longitude)
    else
      foursquare_context = OauthToken.nearby_places(self.latitude, self.longitude)    
    end
    
    if foursquare_context.present? and foursquare_context['results'].present? and foursquare_context['results'][:items].present?
      foursquare_guess = foursquare_context['results'][:items].first
      self.attributes = {:foursquare_context => foursquare_guess,
                         :foursquare_guess => true,
                         :place_name => foursquare_guess['name'],
                         :foursquare_place_id => foursquare_guess['id'],
                         :foursquare_category_id => (foursquare_guess['category'].present? ? foursquare_guess['category']['id'] : nil)}
    end
  end
  
  # If they're at the same place as last time, let's keep track.
  def check_if_possible_duplicate
    return unless self.foursquare_place_id.present?
    last_time = LocationContext.where(:user_id => self.user_id).order('created_at DESC').limit(1)
    if last_time.present? and last_time.first.foursquare_place_id == self.foursquare_place_id and last_time.first.created_at > Time.zone.now-3.hours
      self.possible_duplicate = true
    end
  end
  
  def update_last_location_for_user
    if self.user.present?
      self.user.update_attributes({:last_latitude => self.latitude,
                                   :last_longitude => self.longitude,
                                   :last_location_context_id => self.id,
                                   :lat_long_updated_at => Time.now.utc})
    end
  end
  
end
