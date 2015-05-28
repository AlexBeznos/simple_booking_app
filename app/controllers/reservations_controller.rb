class ReservationsController < ApplicationController
  before_action :find_reservation, except: [:index, :new, :create]
  def index
    @reservations = Reservation.all
    @reservations_by_table = @reservations.group_by{ |r| r.table }.sort_by {|key, value| key}
  end

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(reservation_params)

    if @reservation.save
      redirect_to reservations_path, :notice => 'Reservation created!'
    else
      render :action => :new
    end
  end

  def edit
  end

  def update
    if @reservation.update(reservation_params)
      redirect_to reservations_path, :notice => 'Reservation updated!'
    else
      render :action => :new
    end
  end

  def destroy
    @reservation.destroy
    redirect_to root_path, :notice => 'Reservation destroyed!'
  end

  private
    def find_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(:start_time, :end_time, :table)
    end
end
