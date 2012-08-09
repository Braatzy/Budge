# Load the rails application
require File.expand_path('../application', __FILE__)

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '3.0.1' unless defined? RAILS_GEM_VERSION

# Initialize the rails application
Budge::Application.initialize!

# Globals
OAUTH = YAML::load(File.open("#{Rails.root}/config/oauth.yml"))
c = YAML::load(File.open("#{Rails.root}/config/config.yml"))
CONTACT_RECIPIENT = c[Rails.env]['general']['contact_recipient']
DOMAIN = c[Rails.env]['general']['domain']
SECURE_DOMAIN = c[Rails.env]['general']['secure_domain']
COOKIE_DOMAIN = c[Rails.env]['general']['cookie_domain']
OPEN_GRAPH_NS = OAUTH[Rails.env]['facebook']['open_graph_namespace']
PRIVATE_BETA = false

# Braintree processing
BRAINTREE = c[Rails.env]['braintree']
Braintree::Configuration.environment = BRAINTREE['environment']
Braintree::Configuration.merchant_id = BRAINTREE['merchant_id']
Braintree::Configuration.public_key = BRAINTREE['public_key']
Braintree::Configuration.private_key = BRAINTREE['private_key']


