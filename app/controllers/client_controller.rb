class ClientController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]
  load_and_authorize_resource

  def index
    @client = Client.all
    # @client = if params[:query].present?

    # @issue = if params[:query].present?
    #           @ticket.issues.left_joins(:rich_text_body).where('action_text_rich_texts.body ILIKE ?',
    #                                                            "%#{params[:query]}%")
    #
    #         else
    #           @ticket.issues.with_rich_text_body.order('created_at DESC')
    #         end
    # @per_page = 10
    # @page = (params[:page] || 1).to_i
    # @total_pages = (@issue.count / @per_page.to_f).ceil
    # @issue = @issue.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @client.user_id = current_user.id

    respond_to do |format|
      if current_user.has_role?(:admin) || current_user.has_role?('project_manager')
        if @client.save
          current_user.add_role :creator, @client
          format.html { redirect_to client_path(@client), notice: 'Client was successfully created.' }
        else
          format.html { render :new, status: :unprocessable_entity }
        end
      else
        format.html do
          render :new, status: :unprocessable_entity, notice: 'You are not authorized to create a client.'
        end
      end
    end
  end

  def show; end

  def edit; end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Client was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: 'Client was successfully destroyed.'
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone, :address, :client_contact_person,
                                   :client_contact_person_phone, :client_contact_person_email)
  end
end
