module API::Resources
  class Greeting < Grape::API

    resource :greeting do
      desc 'Says hello'
      post do
        "hello"
      end
    end

  end
end
