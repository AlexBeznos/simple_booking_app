class Reservation < ActiveRecord::Base
  default_scope { order(:start_time) }

  validates :start_time, :end_time, :table, presence: true
  validates :start_time, :end_time, :overlap => { :scope => "table",
                                                  :message_content => "is already booked"}

  validate :start_time_more_than_now, if: 'start_time'
  validate :end_time_less_than_start_time, if: 'start_time && end_time'

  def start_time_more_than_now
    errors.add(:start_time, "can't be less than time now") if start_time <= Time.now
  end

  def end_time_less_than_start_time
    errors.add(:end_time, "can't be less or equel than start time") if end_time <= start_time
  end
end
