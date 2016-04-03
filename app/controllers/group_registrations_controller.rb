class GroupRegistrationsController < ApplicationController

  def new
    @group_registration = GroupRegistrationForm.new
  end

  def create
    @group_registration = GroupRegistrationForm.new(params[:group_registration_form])
    if @group_registration.save
      render action: 'confirmation'
    else
      render action: 'new'
    end
  end
end
