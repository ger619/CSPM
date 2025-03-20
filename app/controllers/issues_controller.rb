class IssuesController < ApplicationController
  before_action :set_project
  before_action :set_ticket
  before_action :set_issue, only: %i[show destroy edit update]
  load_and_authorize_resource

  def index
    @issues = @ticket.issues
  end

  def show; end

  def new
    @issue = @ticket.issues.new
  end

  def create
    @issue = @ticket.issues.new(issue_params)
    @issue.project = @project
    @issue.user = current_user
    @issue.message_type ||= 'external'

    # Validate that content is not blank
    if @issue.content.blank?
      @issue.errors.add(:content, 'Subject cannot be blank.') # Custom validation error
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @issue.save
        notify_mentioned_users(@issue)
        current_user.add_role :creator, @issue

        if @issue.message_type == 'external'
          recipients = @ticket.users.to_a
          recipients << @ticket.user unless recipients.include?(@ticket.user)
          recipients.each do |recipient|
            UserMailer.issue_created_email(recipient, @issue, @project, @ticket).deliver_later
          end
        end

        format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully created.' }
      else
        format.html { render :new, alert: 'Issue was not created.' }
      end
    end
  end

  def destroy
    @issue.destroy
    redirect_to project_ticket_path(@project, @ticket)
  end

  def edit; end

  def update
    if @issue.update(issue_params)
      notify_mentioned_users(@issue)
      redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def notify_mentioned_users(comment)
    mentioned_users = extract_mentioned_users(comment.content)
    mentioned_users.each do |user|
      UserMailer.mention_notification(user, comment).deliver_later
    end
  end

  def extract_mentioned_users(content)
    usernames = content.to_plain_text.scan(/@([\w\s]+)/).flatten # Convert to plain text
    User.where("CONCAT(first_name, ' ', last_name) IN (?)", usernames)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_ticket
    @ticket = @project.tickets.find(params[:ticket_id])
  end

  def set_issue
    @issue = @ticket.issues.find(params[:id])
  end

  # Permit content and attachments to be handled in the params
  def issue_params
    params.require(:issue).permit(:content, :ticket_id, :project_id, :user_id, :message_type, attachments: [])
  end
end
