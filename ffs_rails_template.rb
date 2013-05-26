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

gem "puma", "~> 2.0.1"
gem "mongoid", "~> 3.1.4"
gem 'bson', '~> 1.8.0'
gem 'bson_ext', '~> 1.8.0'
gem 'slim-rails', '~> 1.1.1'
gem "cancan", "~> 1.6.10"
gem "rolify", ">= 3.2.0"
gem "draper", '~> 1.2.1'
gem 'figaro'
gem "backbone-on-rails", "~> 1.0.0.0"

gem_group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem "compass-rails", ">= 1.0.3"
  gem "zurb-foundation", "~> 4.1.6"
end

gem_group :development, :test do
  gem "foreman", '~> 0.60.2'
  gem "rspec-rails", "~> 2.13.2"
  gem 'rb-inotify', :require => false if RUBY_PLATFORM =~ /linux/i
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'growl', '1.0.3', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'meta_request', '0.2.1'
  gem "better_errors"
  gem 'pry', '0.9.10'
  gem 'pry-doc'
  gem 'pry-rails', '~> 0.2.2'
  gem 'pry-debugger'
  gem 'awesome_print'
end

gem_group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem "capybara"
  gem 'shoulda-matchers'
  gem "database_cleaner", "~> 1.0.1"
  gem "mongoid-rspec", "~> 1.8.2"
  gem "launchy", ">= 2.1.2"
  gem 'vcr', '~> 2.3.0'
  gem 'webmock'
end

# Run bundler
run "bundle install --binstubs --without production --path vendor/bundle"

# We have to add the .gitignore before install figaro
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/gitignore.txt', '.gitignore'
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/Procfile', 'Procfile'

## Front-end Framework
generate 'foundation:install'
remove_file 'app/assets/stylesheets/application.css'
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/application.css.scss', 'app/assets/stylesheets/application.css.scss'
generate 'backbone:install'

## Figaro ENV configurations
generate 'figaro:install'

### AUTHORIZATION ###
generate 'model User first_name last_name email'
generate 'cancan:ability'
generate 'rolify:role Role User mongoid'

### Testing ###
generate 'rspec:install'
run 'rm -rf test/' # Removing test folder (not needed for RSpec)

inject_into_file 'config/application.rb', :after => "Rails::Application\n" do <<-RUBY
    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl
      g.view_specs false
      g.helper_specs false
    end

RUBY
end

# configure RSpec to use matchers from the mongoid-rspec gem
create_file 'spec/support/mongoid.rb' do
  <<-RUBY
RSpec.configure do |config|
  config.include Mongoid::Matchers
end
  RUBY
end

# Clean-up
%w{
  README
  doc/README_FOR_APP
  public/index.html
  app/assets/images/rails.png
}.each { |file| remove_file file }

# remove commented lines and multiple blank lines from Gemfile
# thanks to https://github.com/perfectline/template-bucket/blob/master/cleanup.rb
gsub_file 'Gemfile', /#.*\n/, "\n"
gsub_file 'Gemfile', /\n^\s*\n/, "\n"
# remove commented lines and multiple blank lines from config/routes.rb
gsub_file 'config/routes.rb', /  #.*\n/, "\n"
gsub_file 'config/routes.rb', /\n^\s*\n/, "\n"

git :init
git :add => '. -A'
git :commit => "-a -m 'Initial commit'"

