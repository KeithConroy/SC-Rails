class RoomsController < ApplicationController
  include EventsHelper
  include RoomHeatmap

  def index
    @new_room = Room.new
    @rooms = Room.list(@organization.id, params[:page])
      .where(organization_id: @organization.id)
      .order(title: :asc)
      .paginate(page: params[:page], per_page: 15)

    render :'rooms/_all_rooms', layout: false if request.xhr?
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    @room.organization_id = @organization.id
    if @room.save
      redirect_to organization_room_path(@organization.id, @room.id)
    else
      render json: @room.errors.full_messages, status: 400
    end
  end

  def show
    begin
      @room = find_room
      @events = @room.events
        .where('start > ?', DateTime.now)
        .paginate(page: 1, per_page: 10)
    rescue => e
      render file: 'public/404.html', status: 404
    end
  end

  def edit
    begin
      @room = find_room
    rescue => e
      render file: 'public/404.html', status: 404
    end
  end

  def update
    begin
      @room = find_room
      if @room.update_attributes(room_params)
        redirect_to organization_room_path(@organization.id, @room.id)
      else
        render json: @room.errors.full_messages, status: 400
      end
    rescue => e
      render file: 'public/404.html', status: 404
    end
  end

  def destroy
    begin
      @room = find_room
      @room.destroy
      redirect_to(action: 'index')
    rescue => e
      render file: 'public/404.html', status: 404
    end
  end

  def search
    @rooms = Room
      .search(@organization.id, params[:phrase])
      .paginate(page: 1, per_page: 15)
    render :'rooms/_all_rooms', layout: false
  end

  private

  def find_room
    authorize_resource(Room.where(id: params[:id]).first)
  end

  def room_params
    params.require(:room).permit(:title, :number, :building, :description)
  end
end
