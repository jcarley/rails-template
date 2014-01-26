require 'zeus/rails'

class CustomPlan < Zeus::Rails

  # def my_custom_command
  #  # see https://github.com/burke/zeus/blob/master/docs/ruby/modifying.md
  # end

  # def test_helper
    # Dir["#{Rails.root}/app/api/**/*.rb"].each { |file| require file }
    # super
  # end

end

Zeus.plan = CustomPlan.new
