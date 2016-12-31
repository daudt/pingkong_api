Rails.configuration.to_prepare do
  DeviseTokenAuth::RegistrationsController.class_eval do
    def render_create_success
      render json: UserSerializer.new(User.new(resource_data))
    end
  end
end