class EventsController < ApplicationController
  layout 'events', except: :show
  # GET /events
  # GET /events.json
  def index
    @events = Event.all
    # search for events that the current user is attending
    @attendance_keys = []
    @cancelled_keys = []
    if current_user && current_user.name && current_user.name[/Guest/]
      user = current_user
      user.state = nil
      user.save!
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @events }
      end
    elsif current_user
      user = current_user
      user.visits += 1
      user.save!
      UserEvent.find(:all, conditions: {user_id: current_user.id}).each do |link|
        if link.status != "false"
          @attendance_keys << link.event_id
        else
          @cancelled_keys << link.event_id
        end
      end
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @events }
      end
    else
      redirect_to "/login"
    end

  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
    render layout: false
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @user = User.find_by_name(params[:event][:user_id])
    @event = @user.events.create(params[:event].except(:user_id))
    @event.user_id = @user.id

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
end
