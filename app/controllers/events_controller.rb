class EventsController < ApplicationController
  # before_action :find_organization
  before_action :find_event, only: [:show, :edit, :update, :destroy]

  before_action :nested_student, only: [:add_student, :remove_student]
  before_action :nested_room, only: [:add_room, :remove_room]
  before_action :nested_item, only: [:add_item, :remove_item]

  before_action :nested_event, only: [:modify, :add_course, :remove_course, :add_student, :remove_student, :add_room, :remove_room, :add_item, :remove_item]

  before_action :faculty, only: [:index,:new, :edit]

  def index
    @new_event = Event.new
    if request.xhr?
      events = Event.where(organization_id: @organization.id, start: params[:start]..params[:end])
      events = events.map do |event|
        {title: event.title, start: event.start, :end => event.finish, url: "events/#{event.id}"}
      end
      render json: events
    else
      @events = Event
        .where(organization_id: @organization.id)
        .order(start: :asc)
        .paginate(page: params[:page], per_page: 15)
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.organization_id = @organization.id
    if @event.save
      redirect_to "/organizations/#{@organization.id}/events/#{@event.id}/modify"
    else
      render json: "no"
    end
  end

  def show
  end

  def modify
    available_students
    available_rooms
    available_items

    conflicting_events = Event.where("organization_id = ? AND (start BETWEEN ? AND ?) OR (finish BETWEEN ? AND ?)", @organization.id, @event.start, @event.finish, @event.start, @event.finish)

    find_busy(conflicting_events) unless conflicting_events.empty?
  end

  def available_students
    @courses = Course
      .where(organization_id: @organization.id)
      .order(title: :asc)
    @students = User
      .where(organization_id: @organization.id, is_student: true)
      .order(last_name: :asc).order(first_name: :asc)
    @students -= @event.students
  end

  def available_rooms
    @rooms = Room
      .where(organization_id: @organization.id)
      .order(title: :asc)
    @rooms -= @event.rooms
  end

  def available_items
    @items = Item
      .where(organization_id: @organization.id)
      .order(title: :asc)
    @items -= @event.items
  end

  def find_busy(conflicting_events)
    busy_students = []
    busy_rooms = []
    busy_items = []

    conflicting_events.each do |event|
      busy_students << event.students
      busy_rooms << event.rooms
      busy_items << event.items
    end

    mark_busy(@students, busy_students) unless busy_students.empty?
    mark_busy(@rooms, busy_rooms) unless busy_rooms.empty?
    mark_busy(@items, busy_items) unless busy_items.empty?
  end

  def mark_busy(full_array, busy_array)
    busy_array.flatten!.uniq!
    full_array.each do |object|
      busy_array.include?(object) ? object.busy = true : object.busy = false
    end
  end

  def edit
  end

  def update
    if @event.update_attributes(event_params)
      redirect_to organization_event_path(@organization.id, @event.id)
    else

    end
  end

  def destroy
    @event.destroy
    redirect_to(:action => 'index')
  end

  def add_course
    course = Course.where(id: params[:id]).first
    course.students.each do |student|
      p student.first_name
      @event.students << student unless @event.students.include?(student)
    end
    @event.save
    return render :'events/_scheduled_students', layout: false
    # render json: {user: @user, count: @event.students.count, event: @event.id}
  end

  # def remove_course
  #   course = Course.where(id: params[:id])
  #   course.students.each do |student|
  #     @event.courses.delete(student)
  #   end
  #   @event.save
  #   render json: {user: @user, count: @event.courses.count, event: @event.id}
  # end

  def add_student
    @event.students << @user
    @event.save
    return render :'events/_scheduled_students', layout: false
    # render json: {user: @user, count: @event.students.count, event: @event.id}
  end

  def remove_student
    @event.students.delete(@user)
    @event.save
    available_students
    return render :'events/_available_students', layout: false
    # render json: {user: @user, count: @event.students.count, event: @event.id}
  end

  def add_room
    @event.rooms << @room
    @event.save
    return render :'events/_scheduled_rooms', layout: false
    # render json: {room: @room, count: @event.rooms.count, event: @event.id}
  end

  def remove_room
    @event.rooms.delete(@room)
    @event.save
    available_rooms
    return render :'events/_available_rooms', layout: false
    # render json: {room: @room, count: @event.rooms.count, event: @event.id}
  end

  def add_item
    @event.items << @item
    @event.save
    return render :'events/_scheduled_items', layout: false
    # render json: {item: @item, count: @event.items.count, event: @event.id}
  end

  def remove_item
    @event.items.delete(@item)
    @event.save
    available_items
    return render :'events/_available_items', layout: false
    # render json: {item: @item, count: @event.items.count, event: @event.id}
  end

  def search
    phrase = params[:phrase]
    if phrase == '`'
      @events = Event
        .where(organization_id: @organization.id)
        .order(start: :asc)
        .paginate(page: 1, per_page: 15)
    else
      @events = Event
        .where("organization_id = ? AND lower(title) LIKE ?", @organization.id, "%#{params[:phrase]}%")
        .order(start: :asc)
        .paginate(page: 1, per_page: 15)
    end
    return render :'events/_all_events', layout: false
  end

  private

  def find_organization
    @organization = Organization.where(id: params[:organization_id]).first
  end

  def find_event
    @event = Event.where(id: params[:id]).first
  end

  def event_params
    params.require(:event).permit(:title, :start, :finish, :instructor_id, :organization_id)
  end

  def nested_event
    @event = Event.where(id: params[:event_id]).first
  end

  def nested_student
    @user = User.where(id: params[:id]).first
  end

  def nested_room
    @room = Room.where(id: params[:id]).first
  end

  def nested_item
    @item = Item.where(id: params[:id]).first
  end

  def faculty
    @users = User
      .where(organization_id: @organization.id, is_student: false)
      .order(last_name: :asc)
      .order(first_name: :asc)
    @faculty = @users.map do |user|
      ["#{user.first_name} #{user.last_name}", user.id]
    end
  end
end
