# == Schema Information
#
# Table name: foursquare_categories
#
#  id                 :integer(4)      not null, primary key
#  category_id        :string(255)
#  name               :string(255)
#  plural_name        :string(255)
#  icon               :string(255)
#  parent_id          :string(255)
#  parent_category_id :string(255)
#  num_children       :integer(4)      default(0)
#  level_deep         :integer(4)      default(1)
#  created_at         :datetime
#  updated_at         :datetime
#  trait_token        :string(255)
#

class FoursquareCategory < ActiveRecord::Base
  belongs_to :trait, :foreign_key => :trait_token, :primary_key => :token
  
  acts_as_tree 
  
  def self.foursquare_category_traits
    FoursquareCategory.select(:trait_token).where('trait_token is not null').group('trait_token').map{|f|f.trait}.uniq
  end
  
  def self.reload_categories_from_foursquare
    oauth_token = OauthToken.find(:first, :conditions => ['site_token = ?', 'foursquare'])
    consumer = OauthToken.get_consumer(oauth_token.site_token)
    access_token = OAuth::AccessToken.new(consumer, oauth_token.token, oauth_token.secret)

    access_token = OAuth::AccessToken.new(consumer, oauth_token.token, oauth_token.secret)
    response = access_token.get("/v2/venues/categories?v=20110426&oauth_token=#{CGI::escape(oauth_token.token)}",{'User-Agent'=>'Bud.ge'})
    parsed_response = JSON.parse(response.body) rescue nil

    @categories = parsed_response['response']['categories']
    @categories.each do |category_1|
      @level = 1
      foursquare_category = FoursquareCategory.find_or_initialize_by_category_id(category_1['id'])
      foursquare_category.update_attributes({:name => category_1['name'],
                                             :plural_name => category_1['pluralName'],
                                             :parent_id => nil,
                                             :parent_category_id => nil,
                                             :icon => category_1['icon'],
                                             :num_children => (category_1['categories'].present? ? category_1['categories'].size : 0),
                                             :level_deep => @level})
                                             
      if category_1['categories'].present?
        category_1['categories'].each do |category_2|
          @level = 2
          foursquare_category_2 = FoursquareCategory.find_or_initialize_by_category_id(category_2['id'])
          foursquare_category_2.update_attributes({:name => category_2['name'],
                                                   :plural_name => category_2['pluralName'],
                                                   :parent_id => foursquare_category.id,
                                                   :parent_category_id => foursquare_category.category_id,
                                                   :icon => category_2['icon'],
                                                   :num_children => (category_2['categories'].present? ? category_2['categories'].size : 0),
                                                   :level_deep => @level})

          if category_2['categories'].present?
            category_2['categories'].each do |category_3|
              @level = 3
              foursquare_category_3 = FoursquareCategory.find_or_initialize_by_category_id(category_3['id'])
              foursquare_category_3.update_attributes({:name => category_3['name'],
                                                       :plural_name => category_3['pluralName'],
                                                       :parent_id => foursquare_category_2.id,
                                                       :parent_category_id => foursquare_category_2.category_id,
                                                       :icon => category_3['icon'],
                                                       :num_children => (category_3['categories'].present? ? category_3['categories'].size : 0),
                                                       :level_deep => @level})

              
            end
          end
          
        end
      end
    end
  end
end
