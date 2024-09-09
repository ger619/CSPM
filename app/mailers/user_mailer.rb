# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def assignment_email(user, project)
    @user = user
    @project = project
    @url = project_url(@project)
    mail(to: @user.email, subject: 'You have been assigned to a new project')
  end

  def ticket_assignment_email(user, ticket)
    @user = user
    @ticket = ticket
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @user.email, subject: 'You have been assigned to a new ticket')
  end
end
