class EventsController < ApplicationController
  before_action :find_organization
  before_action :find_event, only: [:show, :edit, :update, :destroy]

  before_action :related_student, only: [:add_student, :remove_student]
  before_action :related_room, only: [:add_room, :remove_room]
  before_action :related_item, only: [:add_item, :remove_item]

  before_action :related_event, only: [:add_course, :remove_course, :add_student, :remove_student, :add_room, :remove_room, :add_item, :remove_item]

  before_action :faculty, only: [:new, :edit]

  def index
    if request.xhr?
      events = Event.where(organization_id: @organization.id, start: params[:start]..params[:end])
      events = events.map do |event|
        {title: event.title, start: event.start, :end => event.end, url: "events/#{event.id}"}
      end
      render json: events
    else
      @events = Event.where(organization_id: @organization.id).order(start: :asc)
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.organization_id = @organization.id
    if @event.save
      redirect_to organization_event_path(@organization.id, @event.id)
    else
      render json: "no"
    end
  end

  def show
    @courses = Course.where(organization_id: @organization.id).order(title: :asc)
    @students = User.where(organization_id: @organization.id, is_student: true)
      .order(last_name: :asc).order(first_name: :asc)
    @students -= @event.students

    @rooms = Room.where(organization_id: @organization.id).order(title: :asc)
    @rooms -= @event.rooms
    @items = Item.where(organization_id: @organization.id).order(title: :asc)
    @items -= @event.items

    conflicting_events = Event.where('organization_id = ? AND start BETWEEN ? AND ? OR end BETWEEN ? AND ?', @organization.id, @event.start, @event.end, @event.start, @event.end)

    find_busy(conflicting_events) unless conflicting_events.empty?
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
    render json: {user: @user, count: @event.students.count, event: @event.id}
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
    render json: {user: @user, count: @event.students.count, event: @event.id}
  end

  def remove_student
    @event.students.delete(@user)
    @event.save
    render json: {user: @user, count: @event.students.count, event: @event.id}
  end

  def add_room
    @event.rooms << @room
    @event.save
    render json: {room: @room, count: @event.rooms.count, event: @event.id}
  end

  def remove_room
    @event.rooms.delete(@room)
    @event.save
    render json: {room: @room, count: @event.rooms.count, event: @event.id}
  end

  def add_item
    @event.items << @item
    @event.save
    render json: {item: @item, count: @event.items.count, event: @event.id}
  end

  def remove_item
    @event.items.delete(@item)
    @event.save
    render json: {item: @item, count: @event.items.count, event: @event.id}
  end

  private

  def find_organization
    @organization = Organization.where(id: params[:organization_id]).first
  end

  def find_event
    @event = Event.where(id: params[:id]).first
  end

  def event_params
    params.require(:event).permit(:title, :start, :end, :instructor_id, :organization_id)
  end

  def related_event
    @event = Event.where(id: params[:event_id]).first
  end

  def related_student
    @user = User.where(id: params[:id]).first
  end

  def related_room
    @room = Room.where(id: params[:id]).first
  end

  def related_item
    @item = Item.where(id: params[:id]).first
  end

  def faculty
    @users = User.where(organization_id: @organization.id, is_student: false).order(last_name: :asc).order(first_name: :asc)
    @faculty = @users.map do |user|
      ["#{user.first_name} #{user.last_name}", user.id]
    end
  end
end
