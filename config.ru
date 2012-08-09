# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require "budge_api/api"

# run Rack::Cascade.new([
  # BudgeAPI::API,
  # Budge::Application
  # ])
run Budge::Application
