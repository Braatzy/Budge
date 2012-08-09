# == Schema Information
#
# Table name: addons
#
#  id                     :integer(4)      not null, primary key
#  token                  :string(255)
#  name                   :string(255)
#  visible_at_level       :integer(4)      default(0)
#  level_credit_cost      :integer(4)      default(0)
#  dollar_cost            :decimal(6, 2)   default(0.0)
#  created_at             :datetime
#  updated_at             :datetime
#  parent_id              :integer(4)
#  purchasable            :boolean(1)      default(TRUE)
#  description            :string(255)
#  auto_unlocked_at_level :integer(4)
#

class Addon < ActiveRecord::Base
  has_many :user_addons
  has_many :users, :through => :user_addons
  acts_as_tree :foreign_key => :parent_id
  
  DATA = [{:token => :like,
           :name => "Like",
           :description => "You can heart things.",
           :parent_id => nil,
           :visible_at_level => 0,
           :auto_unlocked_at_level => 1,
           :purchasable => true,
           :level_credit_cost => 10,
           :dollar_cost => 1},
          {:token => :comment,
           :name => "Comment",
           :description => "Speak can your mind.",
           :parent_id => nil,
           :visible_at_level => 0,
           :auto_unlocked_at_level => 1,
           :purchasable => true,
           :level_credit_cost => 10,
           :dollar_cost => 1},
          {:token => :private,
           :name => "Private",
           :description => "Budges between you and the person you budge.",
           :parent_id => nil,
           :visible_at_level => 4,
           :auto_unlocked_at_level => nil,
           :purchasable => true,
           :level_credit_cost => 100,
           :dollar_cost => 100},
          {:token => :secret,
           :name => "Secret",
           :description => "Hide your identity when you budge.",
           :parent_id => nil,
           :visible_at_level => 4,
           :auto_unlocked_at_level => nil,
           :purchasable => true,
           :level_credit_cost => 100,
           :dollar_cost => 10}
           ]
  
  def self.create_or_update_add_ons
    DATA.each do |addon_data|
      addon = Addon.find_or_initialize_by_token(addon_data[:token])
      addon.update_attributes(addon_data)
    end
  end
end
