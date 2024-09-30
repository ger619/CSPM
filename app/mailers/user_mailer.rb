# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: 'cspm@craftsilicon.com'

  def assignment_email(user, project, current_user)
    @user = user
    @project = project
    @current_user = current_user
    @url = project_url(@project)
    mail(to: @user.email, subject: 'You have been assigned to a new project')
  end

  def ticket_assignment_email(user, ticket, current_user)
    @user = user
    @ticket = ticket
    @current_user = current_user
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @user.email, subject: 'You have been assigned to a new ticket')
  end

  def status_update_email(user, ticket, current_user)
    @user = user
    @ticket = ticket
    @current_user = current_user
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @user.email, subject: 'Ticket status updated')
  end

  def assign_product_email(user, product, current_user)
    @user = user
    @product = product
    @current_user = current_user
    @url = product_url(@product)
    mail(to: @user.email, subject: 'You have been assigned to a new product')
  end

  def task_assignment_email(user, task, current_user)
    @user = user
    @task = task
    @current_user = current_user
    @url = product_board_task_url(@task.board.product, @task.board, @task)
    mail(to: @user.email, subject: 'You have been assigned to a new task')
  end

end
