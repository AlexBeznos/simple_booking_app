class ReservationsController < ApplicationController
  def index
    @reservations = Reservation.all
    @reservations_by_table = @reservations.group_by{ |r| r.table }
  end
end
