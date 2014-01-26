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

gem "puma"
gem 'slim-rails'
gem 'devise'
gem "cancan"
gem "rolify", "~> 3.2.0"
gem 'figaro'
gem "zurb-foundation"
gem 'foreigner'
gem 'immigrant'
gem 'grape'
gem 'api-auth'

gem_group :development do
  gem 'zeus'
  gem 'cheat'
  gem "pry"
  gem "pry-doc"
  gem "pry-rails"
  gem "pry-debugger"
  gem "foreman"
  gem "better_errors"
  gem 'binding_of_caller'
end

gem_group :development, :test do
  gem "rspec-rails"
  gem 'faker'
  gem "meta_request"
  gem "awesome_print"
end

gem_group :test do
  gem 'json_spec'
  gem 'email_spec'
  gem "factory_girl_rails"
  gem "capybara"
  gem "shoulda-matchers"
  gem "database_cleaner"
  gem "launchy"
end

# Run bundler
run "bundle install --without production --path vendor/bundle"

# Copy config and initializers files
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/config/initializers/reload_api.rb', 'config/initializers/reload_api.rb'
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/zeus.json', 'zeus.json'
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/custom_plan.rb', 'custom_plan.rb'
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/Vagrantfile', 'Vagrantfile'

# We have to add the .gitignore before install figaro
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/gitignore.txt', '.gitignore'
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/rspec.txt', '.rspec'


## Front-end Framework
generate 'foundation:install'
remove_file 'app/assets/stylesheets/application.css'
copy_from 'https://raw.github.com/jcarley/rails-template/master/files/application.css.scss', 'app/assets/stylesheets/application.css.scss'

## Figaro ENV configurations
generate 'figaro:install'

### AUTHORIZATION ###
generate 'model User first_name last_name email'
generate 'devise:install'
generate 'devise User'
generate 'cancan:ability'
generate 'rolify:role Role User'

### Testing ###
generate 'rspec:install'
run 'rm -rf test/' # Removing test folder (not needed for RSpec)

inject_into_file 'config/application.rb', :after => "Rails::Application\n" do <<-'RUBY'

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: true,
        request_specs: true
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end

    # config.paths.add "#{Rails.root}/app/api", glob: "**/*.rb"
    # config.autoload_paths += %W(#{config.root}/lib)

RUBY
end

# Clean-up
%w{
  README.rdoc
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

create_file 'README.md', ''
append_file 'README.md' do <<-README
Add your application description here
README
end

run ''

git :init
git :add => '. -A'
git :commit => "-a -m 'Initial commit'"

