class PeriodsController < ApplicationController

  before_action :require_admin

  respond_to :html

  def index
    @periods = Period.order(:day, :start_time)
  end

  def new
    @period = Period.new
  end

  def edit
    @period = Period.find(params[:id])
  end

  def create
    @period = Period.new(period_params)

    if @period.save
      redirect_to(periods_url, notice: 'Period was successfully created.')
    else
      render action: :new
    end
  end

  def update
    @period = Period.find(params[:id])

      if @period.update_attributes(period_params)
        redirect_to(periods_url, notice: 'Period was successfully updated.')
      else
        render action: :edit
    end
  end

  def destroy
    @period = Period.find(params[:id])
    @period.destroy

    redirect_to(periods_url)
  end

  private
  def period_params
    params.require(:period).permit(:start_time, :end_time, :day, :period_type)
  end

end