class SlotsController < ApplicationController

  respond_to :html

  before_action :require_admin
  before_action :find_backing_data
  before_action :find_slot, only: [:show, :edit, :update, :destroy]

  # GET /slots
  def index
    periods = Period.includes(:slots)
    @days = periods.group_by(&:day)
  end

  # GET /slots/1
  def show
  end

  # GET /slots/new
  def new
    @slot = Slot.new(slot_params)
    @position = params[:position]
    if @slot.period.period_type == 'workshop'
      @talks = Talk.all_unassigned_tutorials
    elsif @slot.period.period_type == 'short_talk'
      @talks = Talk.all_accepted_lightning_talks
    else
      @talks = Talk.all_accepted_lightning_talks
    end
  end

  # GET /slots/1/edit
  def edit
  end

  # POST /slots
  def create
    @slot = Slot.where(slot_params).first_or_initialize
    @slot.talk_positions.build(talk_id: params[:talk_id], position: params[:position] )

    if @slot.save
      redirect_to(slots_url, notice: 'Slot was successfully created.')
    else
      render action: :new
    end
  end

  # PUT /slots/1
  def update
    if @slot.update_attributes(slot_params)
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
  def slot_params
    params.require(:slot).permit(:period_id, :room_id)
  end

  def find_slot
    @slot = Slot.find(params[:id])
    render not_found unless @slot
  end

  def find_backing_data
    @periods = Period.all
    @talks = Talk.all_accepted.sort_by(&:title)
    @rooms = Room.all
  end
end