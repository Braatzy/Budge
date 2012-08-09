require 'grape'

module BudgeAPI
  module Entities
    class User < Grape::Entity 
      expose :id, :name, :email, :twitter_username
    end
  end
end
