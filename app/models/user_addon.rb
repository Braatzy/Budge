# == Schema Information
#
# Table name: user_addons
#
#  id                  :integer(4)      not null, primary key
#  user_id             :integer(4)
#  addon_id            :integer(4)
#  level_credits_spent :integer(4)      default(0)
#  dollars_spent       :integer(10)     default(0)
#  activated           :boolean(1)      default(TRUE)
#  created_at          :datetime
#  updated_at          :datetime
#  num_owned           :integer(4)      default(1)
#  given_to            :text
#  given_by            :text
#

class UserAddon < ActiveRecord::Base
  belongs_to :user
  belongs_to :addon
  after_save :update_user_cache
  after_create :post_to_stream
  serialize :given_to, :given_by
  
  def update_user_cache
    self.user.update_addon_cache
  end
  
  def post_to_stream
    # Lastly, create stream items
    stream_item = StreamItem.find_or_initialize_by_user_id_and_item_type_and_related_id(self.user_id,
                                                                                        'system_addon_unlocked', 
                                                                                        "#{self.addon_id}")
    stream_item.update_attributes({:text => "#{self.user.name} unlocked #{self.addon.name.pluralize}!",
                                   :private => false})                          
  end
end
