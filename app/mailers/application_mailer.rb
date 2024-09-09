class ApplicationMailer < ActionMailer::Base
  # default from: 'from@example.com'
  # layout 'mailer'
  default from: 'cspm@craftsilicon.com'

  def reset_password_instructions(record, token, opts = {})
    super
  end
end
