module API
  class API < Grape::API

    version 'v1', using: :path

    format :json
    helpers Helpers

    mount Resources::Greeting

  end
end
