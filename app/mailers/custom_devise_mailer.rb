class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'

  def invitation_instructions(record, token, opts = {})
    @token = token
    @resource = record

    if record.has_role?(:ceo)
      opts[:from] = 'fokwarodassd@craftsilicon.com'
      opts[:subject] = 'Your Support Portal Access (TrackIt)'
      opts[:bcc] = 'fokwarosadds@craftsilicon.com'
      mail(opts.merge(to: record.email)) do |format|
        format.html { render 'devise/mailer/invitation_ceo' }
      end
    else
      opts[:from] = 'cspmdsads@craftsilicon.com'
      opts[:subject] = 'Your Support Portal Access (TrackIt)'
      super
    end
  end
end
