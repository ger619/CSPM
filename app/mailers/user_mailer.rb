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

  def mention_notification(user, comment)
    @user = user
    @comment = comment
    mail(to: @user.email, subject: 'You were mentioned in a comment')
  end
  # From Ticket Controller create

  def create_ticket_email(ticket, current_user, assigned_user)
    @ticket = ticket
    @current_user = current_user
    @assigned_user = assigned_user
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @assigned_user.email, subject: "A new ticket has been created with Ticket ID #{@ticket.unique_id}.")
  end

  # From Ticket Controller create
  def ticket_assignment_email(user, project, ticket, current_user, assigned_user)
    @user = user
    @ticket = ticket
    @current_user = current_user
    @project = project
    @assigned_user = assigned_user
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @user.email, subject: "Ticket assigned with Ticket ID #{@ticket.unique_id}.")
  end

  # From Ticket Controller

  def status_update_email(user, ticket, current_user)
    @user = user
    @ticket = ticket
    @current_user = current_user
    @url = project_ticket_url(@ticket.project, @ticket)
    mail(to: @user.email, subject: "Status update for Ticket #{@ticket.unique_id}.")
  end

  # From Product Controller

  def assign_product_email(user, product, current_user, assigned_user)
    @user = user
    @product = product
    @current_user = current_user
    @assigned_user = assigned_user
    @url = product_url(@product)
    mail(to: @user.email, subject: 'Product Assignment')
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

  def new_comment_email(user, comment, current_user)
    @user = user
    @comment = comment
    @current_user = current_user
    @url = project_ticket_url(@comment.ticket.project, @comment.ticket)
    mail(to: @user.email, subject: 'Root Cause Analysis ')
  end

  def bug_mailer(user, bug, current_user, assigned_user)
    @user = user
    @bug = bug
    @current_user = current_user
    @assigned_user = assigned_user
    @url = product_bug_url(@bug.product, @bug)
    mail(to: @user.email, subject: 'Bug Assignment')
  end
end
