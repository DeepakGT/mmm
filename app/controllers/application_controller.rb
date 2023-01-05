class ApplicationController < ActionController::Base

  include Pundit
  protect_from_forgery with: :exception

  before_action :authenticate_user!, unless: :devise_or_admin_controller? # condition due to active admin
  before_action :check_user_status, if: :user_signed_in?
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :set_time_zone, if: :user_signed_in?

  def after_sign_in_path_for(resource)
    return super unless user_signed_in?

    users_dashboard_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name invited_by mobile country wallet_number read_agreement])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name mobile])
  end

  # def transactions_action
  #   ActiveRecord::Base.transaction do
  #     yield
  #   end
  # end

  def check_user_status
    return if devise_controller?

    if current_user.inactive? && params[:controller] != 'users' && params[:action] != 'dashboard'
      redirect_to(users_dashboard_path, alert: 'You are inactive because of delay payments.')
    end
  end

  # for admin policies
  def admin_access_denied(arg)
    render status: :unauthorized, json: { error: "You are not authorized to access this resource." }
  end

  private

    def set_time_zone(&block)
      Time.use_zone(current_user.time_zone, &block)
    end

    def devise_or_admin_controller?
      devise_controller? || params[:controller] =~ /admin\/.*/
    end

  # end of private

end
