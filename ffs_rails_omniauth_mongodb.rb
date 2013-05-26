
def copy_from(source, destination)
  begin
    remove_file destination
    get source, destination
  rescue OpenURI::HTTPError
    puts "Unable to obtain #{source}"
  end
end

initializer 'generators.rb', <<-RUBY
Rails.application.config.generators do |g|
end
RUBY

gem "mongoid", ">= 3.0.5"
gem 'bson', '~> 1.8.0'
gem 'bson_ext', '~> 1.8.0'
gem "omniauth-twitter"
gem "cancan",             "~> 1.6.8"
gem "rolify",             ">= 3.2.0"
gem "draper",             "~> 0.17.0"
gem 'slim-rails',         '~> 1.0.3'
gem 'figaro'

gem_group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem "compass-rails", ">= 1.0.3"
  gem "zurb-foundation", "~> 3.2.3"
end

grem_group :development, :test do
  gem 'zeus'
  gem "foreman", '~> 0.60.2'
  gem 'guard-zeus'
  gem 'rspec-rails',        '>= 2.11.0'
  gem 'factory_girl_rails', '>= 4.0.0'
  gem 'pry', '0.9.10'
  gem 'pry-doc'
  gem 'pry-rails', '~> 0.2.2'
  gem 'pry-debugger'
  gem 'awesome_print'
end

grem_group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner',   '>= 0.8.0'
  gem 'capybara',           '>= 1.1.2'
  gem "mongoid-rspec", ">= 1.4.6"
end

# Run bundler
run "bundle install --binstubs --without production --path vender/bundle"

## Front-end Framework
generate 'foundation:install' if prefer :frontend, 'foundation'

## Figaro ENV configurations
generate 'figaro:install'

### AUTHORIZATION ###
generate 'cancan:ability'
generate 'rolify:role Role User mongoid'
# correct the generation of rolify 3.1 with mongoid
# the call to `rolify` should be *after* the inclusion of mongoid
# (see https://github.com/EppO/rolify/issues/61)
# This isn't needed for rolify>=3.2.0.beta4, but should cause no harm
gsub_file 'app/models/user.rb',
  /^\s*(rolify.*?)$\s*(include Mongoid::Document.*?)$/,
  "  \\2\n  extend Rolify\n  \\1\n"

repo = 'https://raw.github.com/RailsApps/rails-composer/master/files/'
copy_from_repo 'app/controllers/application_controller-omniauth.rb', :prefs => 'omniauth'

inject_into_file 'app/controllers/application_controller.rb', :before => "\nend" do <<-RUBY
\n
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
RUBY


filename = 'app/controllers/sessions_controller.rb'
copy_from_repo filename, :repo => 'https://raw.github.com/RailsApps/rails3-mongoid-omniauth/master/'
gsub_file filename, /twitter/, prefs[:omniauth_provider] unless prefer :omniauth_provider, 'twitter'
if prefer :authorization, 'cancan'
  inject_into_file filename, "    user.add_role :admin if User.count == 1 # make the first user an admin\n", :after => "session[:user_id] = user.id\n"
end

copy_from_repo 'app/assets/stylesheets/application.css.scss'
insert_into_file 'app/assets/stylesheets/application.css.scss', " *= require foundation_and_overrides\n", :after => "require_self\n"

run 'rm -rf test/' # Removing test folder (not needed for RSpec)


inject_into_file 'config/application.rb', :after => "Rails::Application\n" do <<-RUBY

  # don't generate RSpec tests for views and helpers
  config.generators do |g|
    #{"g.test_framework :rspec" if prefer :fixtures, 'none'}
    #{"g.test_framework :rspec, fixture: true" unless prefer :fixtures, 'none'}
    #{"g.fixture_replacement :factory_girl" if prefer :fixtures, 'factory_girl'}
    #{"g.fixture_replacement :machinist" if prefer :fixtures, 'machinist'}
    #{"g.fixture_replacement :fabrication" if prefer :fixtures, 'fabrication'}
    g.view_specs false
    g.helper_specs false
  end

RUBY

# remove ActiveRecord artifacts
gsub_file 'spec/spec_helper.rb', /config.fixture_path/, '# config.fixture_path'
gsub_file 'spec/spec_helper.rb', /config.use_transactional_fixtures/, '# config.use_transactional_fixtures'
# remove either possible occurrence of "require rails/test_unit/railtie"
gsub_file 'config/application.rb', /require 'rails\/test_unit\/railtie'/, '# require "rails/test_unit/railtie"'
gsub_file 'config/application.rb', /require "rails\/test_unit\/railtie"/, '# require "rails/test_unit/railtie"'
# configure RSpec to use matchers from the mongoid-rspec gem
create_file 'spec/support/mongoid.rb' do
  <<-RUBY
  RSpec.configure do |config|
    config.include Mongoid::Matchers
  end
  RUBY

# Clean-up
# remove commented lines and multiple blank lines from Gemfile
# thanks to https://github.com/perfectline/template-bucket/blob/master/cleanup.rb
gsub_file 'Gemfile', /#.*\n/, "\n"
gsub_file 'Gemfile', /\n^\s*\n/, "\n"
# remove commented lines and multiple blank lines from config/routes.rb
gsub_file 'config/routes.rb', /  #.*\n/, "\n"
gsub_file 'config/routes.rb', /\n^\s*\n/, "\n"

%w{
  README
  doc/README_FOR_APP
  public/index.html
  app/assets/images/rails.png
}.each { |file| remove_file file }

copy_from 'https://raw.github.com/RailsApps/rails-composer/master/files/gitignore.txt', '.gitignore'
git :init
git :add => '. -A'
git :commit => "-a -m 'Initial commit'"


