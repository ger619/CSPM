class ApplicationMailer < ActionMailer::Base
  # default from: 'from@example.com'
  # layout 'mailer'
  default from: 'my_email@gmail.com'

  def reset_password_instructions(record, token, opts = {})
    super
  end
end
