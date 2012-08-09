# == Schema Information
#
# Table name: pack_traits
#
#  id         :integer(4)      not null, primary key
#  trait_id   :integer(4)      not null
#  pack_id    :integer(4)      not null
#  level      :integer(4)      default(1)
#  position   :integer(4)      default(1000)
#  created_at :datetime
#  updated_at :datetime
#

class PackTrait < ActiveRecord::Base
    belongs_to :pack
    belongs_to :trait

    after_create :increment_counters
    after_destroy :decrement_counters

    def increment_counters
        self.pack.update_attributes({:num_traits => self.pack.traits.size}) if self.pack
    end
    
    def decrement_counters
        self.pack.update_attributes({:num_traits => self.pack.traits.size}) if self.pack
    end

end
