# == Schema Information
#
# Table name: charges
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  amount             :decimal(6, 2)
#  item_name          :string(255)
#  item_id            :integer(4)
#  transaction_id     :string(255)
#  transaction_status :string(255)
#  error_message      :string(255)
#  last_four          :integer(4)
#  vault_token        :string(255)
#  subscription_id    :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Charge < ActiveRecord::Base
end
