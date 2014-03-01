class TimeslotsController < ApplicationController
  # GET /timeslots
  # GET /timeslots.json
  def index
    @timeslots = Timeslot.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @timeslots }
    end
  end

  # GET /timeslots/1
  # GET /timeslots/1.json
  def show
    @timeslot = Timeslot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @timeslot }
    end
  end

  # GET /timeslots/new
  # GET /timeslots/new.json
  def new
    @timeslot = Timeslot.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @timeslot }
    end
  end

  # GET /timeslots/1/edit
  def edit
    @timeslot = Timeslot.find(params[:id])
  end

  # POST /timeslots
  # POST /timeslots.json
  def create
    @timeslot = Timeslot.new(params[:timeslot])

    respond_to do |format|
      if @timeslot.save
        format.html { redirect_to @timeslot, notice: 'Timeslot was successfully created.' }
        format.json { render json: @timeslot, status: :created, location: @timeslot }
      else
        format.html { render action: "new" }
        format.json { render json: @timeslot.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /timeslots/1
  # PUT /timeslots/1.json
  def update
    @timeslot = Timeslot.find(params[:id])

    respond_to do |format|
      if @timeslot.update_attributes(params[:timeslot])
        format.html { redirect_to @timeslot, notice: 'Timeslot was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @timeslot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /timeslots/1
  # DELETE /timeslots/1.json
  def destroy
    @timeslot = Timeslot.find(params[:id])
    @timeslot.destroy

    respond_to do |format|
      format.html { redirect_to timeslots_url }
      format.json { head :no_content }
    end
  end
end
