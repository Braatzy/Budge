require 'factory_girl'

Factory.define :user do |u|
  u.name 'Doctor Who'
  u.email 'doctor@tardis.com'
  u.password 'badwolf'
end
