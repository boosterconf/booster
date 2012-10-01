class NametagsController < ApplicationController

  before_filter :require_admin

  def index
    @registrations = Registration.all(:include => :user, :order => "users.name, users.created_at DESC")

    prawnto :prawn => {
        :page_layout => :portrait,
        :page_size => 'A6',
        :margin=>0 }
  end

  def show
    @registration = Registration.find(params[:id])

    prawnto :prawn => {
          :page_layout => :portrait,
          :page_size => 'A6',
          :margin => 0 }
  end

end