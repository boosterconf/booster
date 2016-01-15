class SlotsController < ApplicationController

  respond_to :html

  before_filter :require_admin
  before_filter :find_backing_data
  before_filter :find_slot, only: [:show, :edit, :update, :destroy]

  # GET /slots
  def index
    periods = Period.all(include: { slots: [:talk, :room] } )
    @days = periods.group_by(&:day)
  end

  # GET /slots/1
  def show
  end

  # GET /slots/new
  def new
    #@talks = Talk.all_unassigned_tutorials

    @slot = Slot.new(params[:slot])
  end

  # GET /slots/1/edit
  def edit
  end

  # POST /slots
  def create
    @slot = Slot.new(params[:slot])

    if @slot.save
      redirect_to(slots_url, notice: 'Slot was successfully created.')
    else
      render action: :new
    end
  end

  # PUT /slots/1
  def update
    if @slot.update_attributes(params[:slot])
      redirect_to(@slot, notice: 'Slot was successfully updated.')
    else
      render action: :edit
    end
  end

  # DELETE /slots/1
  def destroy
    @slot.destroy
    redirect_to(slots_url, notice: 'Slot was successfully deleted.')
  end

  private
  def find_slot
    @slot = Slot.find(params[:id])
    render not_found unless @slot
  end

  def find_backing_data
    @periods = Period.all
    @talks = Talk.all_accepted
    @rooms = Room.all
  end
end