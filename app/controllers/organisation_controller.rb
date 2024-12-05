class OrganisationController < ApplicationController
  before_action :authenticate_user!
  # before_action :set_organisation
  # before_action :set_user, only: %i[assign_user unassign_user]

  def index
    @organisations = Organisation.all
  end

  def show
    # @users = @organisation.users
    # @projects = @organisation.projects
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(organisation_params)

    respond_to do |format|
      if @organisation.save
        format.html { redirect_to organisation_index_path, notice: 'Organisation was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit; end

  def update
    respond_to do |format|
      if @organisation.update(organisation_params)
        format.html { redirect_to organisation_path(@organisation), notice: 'Organisation was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @organisation.destroy
    redirect_to organisations_path
  end

  def assign_user
    @organisation.users << @user
    redirect_to organisation_path(@organisation)
  end

  def unassign_user
    @organisation.users.delete(@user)
    redirect_to organisation_path(@organisation)
  end

  private

  def set_organisation
    @organisation = Organisation.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def organisation_params
    params.require(:organisation).permit(:name, :description)
  end
end
