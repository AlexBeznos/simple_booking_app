class Reservation < ActiveRecord::Base
  default_scope { order(:start_time) }
  scope :time_enters, lambda { |time| where('start_time <= :time and end_time >= :time', {:time => time}) }

  validates :start_time, :end_time, :table, presence: true

  validate :start_time_more_than_now, if: 'start_time'
  validate :end_time_less_than_start_time, if: 'start_time && end_time'
  validate :start_time_entrance, if: 'start_time && end_time'
  validate :end_time_entrance, if: 'start_time && end_time'
  validate :full_overlap, if: 'start_time && end_time'

  protected
    def add_entrance_error(reservations, time)
      reservations_with_time_entrance = reservations.time_enters(time)
      reservations_with_time_entrance.delete(self)

      if reservations_with_time_entrance.any?
        yield
      end
    end

  private
    def start_time_more_than_now
      errors.add(:start_time, I18n.t('validations.less_or_equel', time: 'time now')) if start_time <= Time.now
    end

    def end_time_less_than_start_time
      errors.add(:end_time, I18n.t('validations.less_or_equel', time: 'start time')) if end_time <= start_time
    end

    def start_time_entrance
      @reservations = Reservation.where(table: table)

      self.add_entrance_error(@reservations, start_time) do
        errors.add(:start_time, I18n.t('validations.already_booked'))
      end
    end

    def end_time_entrance
      @reservations = Reservation.where(table: table) unless defined?(@reservations)

      add_entrance_error(@reservations, end_time) do
        errors.add(:end_time, I18n.t('validations.already_booked'))
      end
    end

    def full_overlap
      @reservations = Reservation.where(table: table) unless defined?(@reservations)
      full_overlap = @reservations.where('start_time >= ? and end_time <= ?', start_time, end_time)
      full_overlap.delete(self)

      if full_overlap.any?
        errors.add(:start_time, I18n.t('validations.already_booked'))
        errors.add(:end_time, I18n.t('validations.already_booked'))
      end
    end

end
