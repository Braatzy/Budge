# == Schema Information
#
# Table name: packs
#
#  id                 :integer(4)      not null, primary key
#  num_traits         :integer(4)      default(0)
#  launched           :boolean(1)      default(FALSE)
#  public             :boolean(1)      default(FALSE)
#  requires_unlocking :boolean(1)      default(TRUE)
#  do_name            :string(255)
#  description        :text
#  token              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  dont_name          :string(255)
#  name               :string(255)
#  position           :integer(4)      default(1000)
#

class Pack < ActiveRecord::Base
    has_many :pack_traits, :dependent => :destroy
    has_many :traits, :through => :pack_traits, 
             :select => "pack_traits.position,pack_traits.level,traits.*"

    def pack_name 
      if name.present?
        return name
      else
        return "#{self.do_name} / #{self.dont_name}"
      end
    end
end
