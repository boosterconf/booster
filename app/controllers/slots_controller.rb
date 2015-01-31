class SlotsController < ApplicationController

  respond_to :html

  before_filter :require_admin
  before_filter :find_backing_data #, only: [:new, :edit]

  # GET /slots
  # GET /slots.xml
  def index
    periods = Period.all(include: :slots)

    @days = periods.group_by(&:day)
    @rooms = Room.all.sort_by(&:capacity).reverse

    respond_with @days
  end

  # GET /slots/1
  # GET /slots/1.xml
  def show
    @slot = Slot.find(params[:id])
    respond_with @slot
  end

  # GET /slots/new
  # GET /slots/new.xml
  def new
    @slot = Slot.new(params[:slot])
    respond_with @slot
  end

  # GET /slots/1/edit
  def edit
    @slot = Slot.find(params[:id])
  end

  # POST /slots
  # POST /slots.xml
  def create
    @slot = Slot.new(params[:slot])

    if @slot.save
      redirect_to(slots_url, notice: 'Slot was successfully created.')
    else
      render action: :new
    end
  end

  # PUT /slots/1
  # PUT /slots/1.xml
  def update
    @slot = Slot.find(params[:id])
    if @slot.update_attributes(params[:slot])
      redirect_to(@slot, :notice => 'Slot was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.xml
  def destroy
    @slot = Slot.find(params[:id])
    @slot.destroy

    redirect_to(slots_url, notice: 'Slot was successfully deleted.')
  end

  private
  def find_backing_data
    @periods = Period.all
    @talks = Talk.all_accepted_tutorials
    @rooms = Room.all
  end
end