class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def invitation_instructions(record, token, opts = {})
    @token = token
    @resource = record

    # opts[:from] = record.has_role?(:ceo) ? 'cspm@craftsilicon.com' : 'fokwaro@craftsilicon.com'
    opts[:from] = record.has_role?(:ceo) ? 'cspm12@craftsilicon.com' : 'cspm@craftsilicon.com'
    opts[:subject] = 'Your Support Portal Access (TaskBridge)'
    # opts[:bcc] = 'fokwaro@craftsilicon.com'

    if record.has_role?(:ceo)
      mail(opts.merge(to: record.email)) do |format|
        format.html { render 'devise/mailer/invitation_ceo' }
      end
    else
      super
    end
  end
end
