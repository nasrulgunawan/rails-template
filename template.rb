# Add Gem

gem 'bootstrap'
gem 'n-ui', git: 'http://hi.n-ui.git'
gem 'font-awesome-sass', '~> 5.15.1'
gem 'jquery-rails'
gem 'pagy'
gem 'pundit' if yes?("Add Pundit?")

authentication = ask("Which authentication system do you want? caas or devise?")

if authentication === 'devise'
  gem 'devise'

  model = ask("What the devise user model name?")

  after_bundle do
    run "spring stop"

    rails_command 'generate devise:install'
    rails_command "generate devise #{model}"
  end
elsif authentication === 'caas'
  gem 'rack-cas'
  
  after_bundle do
    run "spring stop"

    rails_command 'generate cas_session_store_migration'

    environment "config.rack_cas.server_url = 'http://cas-staging.example.com/'", env: 'development'
    environment "config.rack_cas.server_url = 'https://cas-production.example.com/'", env: 'production'
  end
end

if yes?("Add Mailpy (Send mail through HTTP APIs)?")
  gem 'mailpy'

  after_bundle do
    environment "config.action_mailer.delivery_method = :mailpy", env: 'development'
    environment "config.action_mailer.mailpy_settings = { endpoint: ENV['MAILER_API_ENDPOINT'], token: ENV['MAILER_API_KEY_OR_AUTH_TOKEN'] }", env: 'development'
    
    environment "config.action_mailer.delivery_method = :mailpy", env: 'production'
    environment "config.action_mailer.mailpy_settings = { endpoint: ENV['MAILER_API_ENDPOINT'], token: ENV['MAILER_API_KEY_OR_AUTH_TOKEN'] }", env: 'production'
  end
end

gem_group :development do
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-rvm'
  gem 'capistrano3-puma'
  gem 'capistrano-rails'
  gem 'capistrano-rails-db'
  gem 'capistrano-rails-console'
  gem 'capistrano-upload-config'
  gem 'sshkit-sudo'
end

environment "config.action_mailer.default_url_options = { host: 'http://localhost:3000' }", env: 'development'

production_host = ask("What the production domain that you want to propose ?")
environment "config.action_mailer.default_url_options = { host: 'https://#{production_host}' }", env: 'production'

after_bundle do
  run 'cap install'
end