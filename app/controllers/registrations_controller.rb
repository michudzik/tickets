class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  prepend_before_action :check_captcha, only: [:create]

  private

  def check_captcha
    return unless verify_recaptcha
  end
end
