rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file("#{Rails.root}/config/resque.yml")
Resque.redis = resque_config[rails_env]
