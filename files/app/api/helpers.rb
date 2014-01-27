module API::Helpers

  AUTH_TOKEN_HEADER = "HTTP_AUTH_TOKEN"
  AUTH_TOKEN_PARAM = :auth_token

  def current_user
    auth_token = (params[AUTH_TOKEN_PARAM] || env[AUTH_TOKEN_HEADER])
    @current_user ||= User.find_by(:authentication_token => auth_token)

    if @current_user.nil?
      forbidden!
    end

    @current_user
  end

  # def sign!
    # signed_request = ApiAuth.sign!(request, Authorization.uid, Authorization.secret)
  # end

  def authenticate!
    unauthorized! unless current_user
  end

  def authenticated_as_admin!
    forbidden! unless current_user.is_admin?
  end

  def authorize!(action, subject)
    unless ability.allowed?(action, subject)
      forbidden!
    end
  end

  # error helpers

  def forbidden!
    render_api_error!('403 Forbidden', 403)
  end

  def bad_request!(attribute)
    message = ["400 (Bad request)"]
    message << "\"" + attribute.to_s + "\" not given"
    render_api_error!(message.join(' '), 400)
  end

  def not_found!(resource = nil)
    message = ["404"]
    message << resource if resource
    message << "Not Found"
    render_api_error!(message.join(' '), 404)
  end

  def unauthorized!
    render_api_error!('401 Unauthorized', 401)
  end

  def not_allowed!
    render_api_error!('Method Not Allowed', 405)
  end

  def render_api_error!(message, status)
    error!({'message' => message}, status)
  end

  private

    def ability
      @ability ||= Ability.new(current_user)
    end

end
