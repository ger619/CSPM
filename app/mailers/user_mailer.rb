# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: 'cspm@craftsilicon.com'
  # From Project Controller
  def assignment_email(user, project, current_user, assigned_user)
    @user = user
    @project = project
    @current_user = current_user
    @assigned_user = assigned_user
    @url = project_url(@project)
    mail(to: @user.email, subject: 'Support Desk Assignment')
  end

  # From Ticket Controller
  def ticket_assignment_email(user, ticket, current_user, assigned_user)
    @user = user
    @ticket = ticket
    @current_user = current_user
    @assigned_user = assigned_user
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @user.email, subject: 'Ticket Assignment')
  end

  # From Ticket Controller

  def status_update_email(user, ticket, current_user)
    @user = user
    @ticket = ticket
    @current_user = current_user
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @user.email, subject: 'Ticket status updated')
  end

  # From Product Controller

  def assign_product_email(user, product, current_user, assigned_user)
    @user = user
    @product = product
    @current_user = current_user
    @assigned_user = assigned_user
    @url = product_url(@product)
    mail(to: @user.email, subject: 'Project Assignment')
  end

  # From Task Controller
  def task_assignment_email(user, task, current_user, assigned_user)
    @user = user
    @task = task
    @current_user = current_user
    @assigned_user = assigned_user
    @url = product_board_task_url(@task.board.product, @task.board, @task)
    mail(to: @user.email, subject: 'You have been assigned to a new task')
  end

  def add_state_email(user, task, current_user)
    @user = user
    @task = task
    @current_user = current_user
    @url = product_board_task_url(@task.board.product, @task.board, @task)
    mail(to: @user.email, subject: 'Task State Updated')
  end

  def new_comment_emails
    @comment = params[:comment]
    @user = User.where(id: params[:user_ids])
    @user.each do |user|
      mail(to: user.email, subject: 'New Comment')
    end
  end

  def new_comment_email(user, comment, current_user)
    @user = user
    @comment = comment
    @current_user = current_user
    mail(to: @user.email, subject: 'New Comment')
  end
end
