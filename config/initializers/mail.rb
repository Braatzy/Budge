if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => ENV['SENDGRID_USERNAME'],
    :password       => ENV['SENDGRID_PASSWORD'],
    :domain         => 'heroku.com'
  }
  ActionMailer::Base.delivery_method = :smtp
elsif Rails.env.development?
  c = YAML::load(File.open("#{Rails.root}/config/config.yml"))
  ActionMailer::Base.smtp_settings = {  
    :address        => c[Rails.env]['email']['server'],
    :port           => c[Rails.env]['email']['port'],
    :domain         => c[Rails.env]['email']['domain'],
    :user_name      => c[Rails.env]['email']['username'],
    :password       => c[Rails.env]['email']['password'],
    :authentication => c[Rails.env]['email']['authentication'],
    :enable_starttls_auto => false
  }
  ActionMailer::Base.delivery_method = :smtp
end