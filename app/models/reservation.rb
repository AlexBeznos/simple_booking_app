class Reservation < ActiveRecord::Base
  validates :start_time, :end_time, :table, presence: true
end
