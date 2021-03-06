class OrganizationsController < ApplicationController
  skip_before_action :authenticate_user!, :authorize_faculty, only: [:new]

  def index
  end

  def new
    raise Errors::Forbidden if current_user
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      @admin = User.create_admin(
        @organization.id,
        organization_params[:subdomain],
        organization_params[:email]
      )
      redirect_to organization_path(@organization.id)
    else
      render json: @organization.errors.full_messages, status: 400
    end
  end

  def show
    @event = Event.new
    @todays_events = Event.today(@organization.id)
  end

  def edit
  end

  def update
    if @organization.update_attributes(organization_params)
      redirect_to @organization
    else
      render json: @organization.errors.full_messages, status: 400
    end
  end

  def destroy
    @organization.destroy
    sign_out current_user
    redirect_to 'home#index', as: :unauthenticated_root
  end

  def community
  end

  private

  def organization_params
    params.require(:organization).permit(:title, :subdomain, :time_zone, :email)
  end
end
