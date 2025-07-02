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

  # def create
  #   @issue = @ticket.issues.new(issue_params)
  #   @issue.project = @project
  #   @issue.user = current_user
  #   @issue.message_type ||= 'external'

  #   # Validate that content is not blank
  #   if @issue.content.blank?
  #     @issue.errors.add(:content, 'Subject cannot be blank.') # Custom validation error
  #     respond_to do |format|
  #       format.html { render :new, status: :unprocessable_entity }
  #     end
  #     return
  #   end

  #   respond_to do |format|
  #     if @issue.save
  #       send_email_notifications(@issue, current_user)
  #       current_user.add_role :creator, @issue

  #       if @issue.message_type == 'external'
  #         recipients = @ticket.users.to_a
  #         recipients << @ticket.user unless recipients.include?(@ticket.user)
  #         recipients.each do |recipient|
  #           UserMailer.issue_created_email(recipient, @issue, @project, @ticket, current_user).deliver_later
  #         end
  #       end

  #       format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully created.' }
  #     else
  #       format.html { render :new, alert: 'Issue was not created.' }
  #     end
  #   end
  # end

  # def destroy
  #   @issue.destroy
  #   redirect_to project_ticket_path(@project, @ticket)
  # end

  # def edit
  #   respond_to do |format|
  #     format.html
  #     format.turbo_stream
  #   end
  # end

  # def update
  #   if @issue.update(issue_params)
  #     send_email_notifications(@issue, current_user)
  #     format.turbo_stream
  #     redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully updated.'
  #   else
  #     format.turbo_stream { render :form_update }
  #     render :edit, status: :unprocessable_entity
  #   end
  # end

  # def create
  #   @issue = @ticket.issues.new(issue_params)
  #   @issue.project = @project
  #   @issue.user = current_user
  #   @issue.message_type ||= 'external'

  #   # Validate that content is not blank
  #   if @issue.content.blank?
  #     @issue.errors.add(:content, 'Subject cannot be blank.')
  #     respond_to do |format|
  #       format.turbo_stream { render :form_update, status: :unprocessable_entity }
  #       format.html { render :new, status: :unprocessable_entity }
  #     end
  #     return
  #   end

  #   respond_to do |format|
  #     if @issue.save
  #       send_email_notifications(@issue, current_user)
  #       current_user.add_role :creator, @issue

  #       if @issue.message_type == 'external'
  #         recipients = @ticket.users.to_a
  #         recipients << @ticket.user unless recipients.include?(@ticket.user)
  #         recipients.each do |recipient|
  #           UserMailer.issue_created_email(recipient, @issue, @project, @ticket, current_user).deliver_later
  #         end
  #       end

  #       format.turbo_stream do
  #         render turbo_stream: [
  #           turbo_stream.append('messages', partial: 'issues/issue', locals: { item: @issue }),
  #           turbo_stream.replace('new_message_form', partial: 'issues/form', 
  #                             locals: { project: @project, ticket: @ticket, issue: Issue.new })
  #         ]
  #       end
  #       format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully created.' }
  #     else
  #       format.turbo_stream { render :form_update, status: :unprocessable_entity }
  #       format.html { render :new, alert: 'Issue was not created.' }
  #     end
  #   end
  # end

#   def create
#   @issue = @ticket.issues.new(issue_params)
#   @issue.project = @project
#   @issue.user = current_user
#   @issue.message_type ||= 'external'

#   # Validate that content is not blank
#   if @issue.content.blank?
#     @issue.errors.add(:content, 'Subject cannot be blank.')
#     respond_to do |format|
#       format.turbo_stream { render :form_update, status: :unprocessable_entity }
#       format.html { render :new, status: :unprocessable_entity }
#     end
#     return
#   end

#   respond_to do |format|
#     if @issue.save
#       send_email_notifications(@issue, current_user)
#       current_user.add_role :creator, @issue

#       if @issue.message_type == 'external'
#         recipients = @ticket.users.to_a
#         recipients << @ticket.user unless recipients.include?(@ticket.user)
#         recipients.each do |recipient|
#           UserMailer.issue_created_email(recipient, @issue, @project, @ticket, current_user).deliver_later
#         end
#       end

#       format.turbo_stream do
#         render turbo_stream: [
#           turbo_stream.append(
#             "messages-list",  # Make sure this matches your messages container ID
#             partial: 'issues/message',
#             locals: { item: @issue }
#           ),
#           turbo_stream.replace(
#             "new_message_form",
#             partial: 'issues/form',
#             locals: { project: @project, ticket: @ticket, issue: Issue.new }
#           )
#         ]
#       end
#       format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully created.' }
#     else
#       format.turbo_stream { render :form_update, status: :unprocessable_entity }
#       format.html { render :new, alert: 'Issue was not created.' }
#     end
#   end
# end

def create
  @issue = @ticket.issues.new(issue_params)
  @issue.project = @project
  @issue.user = current_user
  @issue.message_type ||= 'external'

  # Validate that content is not blank
  if @issue.content.blank?
    @issue.errors.add(:content, 'Message cannot be blank.')
    respond_to do |format|
      format.turbo_stream do 
        render turbo_stream: turbo_stream.replace(
          "new_message_form",
          partial: 'issues/form',
          locals: { project: @project, ticket: @ticket, issue: @issue }
        )
      end
      format.html { render :new, status: :unprocessable_entity }
    end
    return
  end

  respond_to do |format|
    if @issue.save
      send_email_notifications(@issue, current_user)
      current_user.add_role :creator, @issue

      if @issue.message_type == 'external'
        recipients = @ticket.users.to_a
        recipients << @ticket.user unless recipients.include?(@ticket.user)
        recipients.each do |recipient|
          UserMailer.issue_created_email(recipient, @issue, @project, @ticket, current_user).deliver_later
        end
      end

      
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append(
            "messages",
            partial: 'issues/issues_table',
            locals: { item: @issue }
          ),
          turbo_stream.replace(
            "new_message_form",
            partial: 'issues/form',
            locals: { project: @project, ticket: @ticket, issue: Issue.new }
          ),
          turbo_stream.update(
            "messageFormContainer",
            html: ""
          )
        ]
      end
      format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Message was successfully created.' }
    else
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "new_message_form",
          partial: 'issues/form',
          locals: { project: @project, ticket: @ticket, issue: @issue }
        )
      end
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end
  
  def update
  respond_to do |format|
    if @issue.update(issue_params)
      send_email_notifications(@issue, current_user)

      format.turbo_stream do
        render turbo_stream: [
          # Refresh the entire messages container
          turbo_stream.replace(
            "messages-container", # This should be the ID of your messages container
            partial: 'issues/issues_table',
            # partial: 'issues/message',
            locals: { item: @issue } # Use your actual method/relation
          ),
          # Close the edit form
          turbo_stream.remove("edit-form-#{@issue.id}")
        ]
      end

      # format.turbo_stream do
      #   render turbo_stream: [
      #     # Update just the edited message by re-rendering its li element
      #     turbo_stream.replace(
      #       dom_id(@issue),
      #       partial: 'issues/message',  # This will be a new minimal partial
      #       locals: { item: @issue }
      #     ),
      #     turbo_stream.remove("edit-form-#{@issue.id}")
      #   ]
      # end

      format.html { redirect_to project_ticket_path(@project, @ticket), notice: 'Issue was successfully updated.' }
    else
      format.turbo_stream { render :form_update, status: :unprocessable_entity }
      format.html { render :edit, status: :unprocessable_entity }
    end
  end
end


def destroy
    @issue.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(dom_id(@issue))
      end
      format.html { redirect_to project_ticket_path(@project, @ticket) }
    end
  end

  private

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

  def send_email_notifications(issue, sender)
    selected_users = User.where(id: params.dig(:team, :user_ids)) # Safely fetch user IDs

    selected_users.each do |user|
      UserMailer.mention_user_in_issue(user, issue, sender, @project, @ticket).deliver_later
    end
  end

  # Permit content and attachments to be handled in the params
  def issue_params
    params.require(:issue).permit(:content, :ticket_id, :project_id, :user_id, :message_type, attachments: [])
  end
end
