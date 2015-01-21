class SlotsController < ApplicationController

  respond_to :html

  before_filter :require_admin

  # GET /slots
  # GET /slots.xml
  def index
    periods = Period.all(include: :slots)

    @days = periods.group_by(&:day)

    respond_with @days
  end

  # GET /slots/1
  # GET /slots/1.xml
  def show
    @slot = Slot.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @slot }
    end
  end

  # GET /slots/new
  # GET /slots/new.xml
  def new
    @slot = Slot.new

    create_backing_data

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @slot }
    end
  end

  # GET /slots/1/edit
  def edit

    @slot = Slot.find(params[:id])

    create_backing_data()
  end

  # POST /slots
  # POST /slots.xml
  def create

    @slot = Slot.new :room => params[:slot][:room], :period_id => params[:slot][:period], :talk_id => params[:slot][:talk]
    create_backing_data()

    respond_to do |format|
      if @slot.save
        format.html { redirect_to(slots_url, :notice => 'Slot was successfully created.') }
        format.xml  { render :xml => @slot, :status => :created, :location => @slot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /slots/1
  # PUT /slots/1.xml
  def update
    @slot = Slot.find(params[:id])
    create_backing_data

    respond_to do |format|
      if @slot.update_attributes(params[:slot])
        format.html { redirect_to(@slot, :notice => 'Slot was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.xml
  def destroy
    @slot = Slot.find(params[:id])
    @slot.destroy

    respond_to do |format|
      format.html { redirect_to(slots_url) }
      format.xml  { head :ok }
    end
  end


  private
  def create_backing_data
    @periods = Period.all
    @talks = Talk.all_accepted_tutorials

    @rooms = [["KP10", "KP10"], ["KP11", "KP11"], ["Sydneshaugen", "Sydneshaugen"], ["Muséplass", "Muséplass"], ["Strangehagen", "Strangehagen"], ["Dragefjellet", "Dragefjellet"], ["Teatergaten", "Teatergaten"], ["Hødden", "Hødden"], ["Galgebakken", "Galgebakken"], ["Tårnplass", "Tårnplass"]]
  end
end