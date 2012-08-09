c = YAML::load(File.open("#{Rails.root}/config/config.yml"))
if false and Rails.env.development?
  # See http://railscasts.com/episodes/206-action-mailer-in-rails-3
  # Mail.register_interceptor(DevelopmentMailInterceptor) 
end

ActionMailer::Base.default_url_options[:host] = c[Rails.env]['general']['domain']
