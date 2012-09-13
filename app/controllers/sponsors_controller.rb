class SponsorsController < ApplicationController
  # GET /sponsors
  # GET /sponsors.json
  def index
    @sponsors = Sponsor.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sponsors }
    end
  end

  # GET /sponsors/1
  # GET /sponsors/1.json
  def show
    @sponsor = Sponsor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sponsor }
    end
  end

  # GET /sponsors/new
  # GET /sponsors/new.json
  def new
    @users = User.all_organizers
    @sponsor = Sponsor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sponsor }
    end
  end

  # GET /sponsors/1/edit
  def edit
    @users = User.all_organizers
    @sponsor = Sponsor.find(params[:id])
  end

  # POST /sponsors
  # POST /sponsors.json
  def create
    @sponsor = Sponsor.new(params[:sponsor])

    respond_to do |format|
      if @sponsor.save
        format.html { redirect_to @sponsor, notice: 'Sponsor was successfully created.' }
        format.json { render json: @sponsor, status: :created, location: @sponsor }
      else
        format.html { render action: "new" }
        format.json { render json: @sponsor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sponsors/1
  # PUT /sponsors/1.json
  def update
    @sponsor = Sponsor.find(params[:id])

    respond_to do |format|
      if @sponsor.update_attributes(params[:sponsor])
        format.html { redirect_to @sponsor, notice: 'Sponsor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sponsor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sponsors/1
  # DELETE /sponsors/1.json
  def destroy
    @sponsor = Sponsor.find(params[:id])
    @sponsor.destroy

    respond_to do |format|
      format.html { redirect_to sponsors_url }
      format.json { head :no_content }
    end
  end

    # POST /sponsors/1/email
  def email
    @sponsor = Sponsor.find(params[:id])
    if @sponsor.is_ready_for_email?
      #RootsMailer.deliver_initial_sponsor_mail(@sponsor)
      @sponsor.status = 'contacted'
      @sponsor.last_contacted_at = Time.now.to_datetime
      @sponsor.save
      redirect_to(sponsors_path, :notice => 'Email was sent and sponsor status set to \'Contacted\'.')
    else
      flash[:error] = 'No email sent: must have status suggested and responsible set'
      redirect_to sponsors_path
    end
  end
end
