require 'grape'

module BudgeAPI
  module Entities
    class Program < Grape::Entity 
      expose :id, :name, :description, :price
    end
  end
end
