require 'grape'

module BudgeAPI
  module Entities
    class Entry < Grape::Entity 
      expose :id
      expose :user_name do |object, options| 
        object.user.name
      end
      expose :user_photo do |object, options|
        object.user.photo(:tiny)
      end
      expose :statement do |object, options|
        object.statement
      end
    end
  end
end
