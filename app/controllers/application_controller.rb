class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:first_name, :last_name, :email, :password)}

      devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:first_name, :last_name, :email, :password, :current_password)}
    end

  around_action :switch_locale

  # This method is used to change the locale of the application using paramaters
  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # TODO: future implementation, activate this method to change the locale of the application using the browser language
  # def switch_locale(&action)
  #   logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
  #   locale = extract_locale_from_accept_language_header
  #   logger.debug "* Locale set to '#{locale}'"
  #   I18n.with_locale(locale, &action)
  # end
  
  # private
  #   def extract_locale_from_accept_language_header
  #     request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  #   end

end
