# app/mailers/custom_devise_mailer.rb
class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def invitation_instructions(record, token, opts = {})
    @token = token
    @resource = record

    if record.has_role?(:ceo)
      mail(to: record.email, subject: 'Your Support Snapshot Portal Access (TaskBridge)') do |format|
        format.html { render 'devise/mailer/invitation_ceo' }
      end
    else
      super
    end
  end
end
