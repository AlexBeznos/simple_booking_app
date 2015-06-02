class Reservation < ActiveRecord::Base
  default_scope { order(:start_time) }
  scope :time_enters, lambda { |time| where('start_time <= :time and end_time >= :time', {:time => time}) }

  validates :start_time, :end_time, :table, presence: true

  validate :start_time_more_than_now, if: 'start_time'
  validate :end_time_less_than_start_time, if: 'start_time && end_time'
  validate :start_time_enters, if: 'start_time && end_time'
  validate :end_time_enters, if: 'start_time && end_time'
  validate :full_overlap, if: 'start_time && end_time'

  private
    def start_time_more_than_now
      errors.add(:start_time, I18n.t('validations.less_or_equel', time: 'time now')) if start_time <= Time.now
    end

    def end_time_less_than_start_time
      errors.add(:end_time, I18n.t('validations.less_or_equel', time: 'start time')) if end_time <= start_time
    end

    def start_time_enters
      @reservations = Reservation.where(table: table)
      reservations_with_time_enterence = @reservations.time_enters(start_time)
      reservations_with_time_enterence.delete(self)

      if reservations_with_time_enterence.any?
        puts 'start_time_enters'
        errors.add(:start_time, I18n.t('validations.already_booked'))
      end
    end

    def end_time_enters
      @reservations = Reservation.where(table: table) unless defined?(@reservations)
      reservations_with_time_enterence = @reservations.time_enters(end_time)
      reservations_with_time_enterence.delete(self)

      if reservations_with_time_enterence.any?
        puts 'end_time_enters'
        errors.add(:end_time, I18n.t('validations.already_booked'))
      end
    end

    def full_overlap
      @reservations = Reservation.where(table: table) unless defined?(@reservations)
      full_overlap = @reservations.where('start_time >= ? and end_time <= ?', start_time, end_time)
      full_overlap.delete(self)

      if full_overlap.any?
        puts 'full_overlap'
        errors.add(:start_time, I18n.t('validations.already_booked'))
        errors.add(:end_time, I18n.t('validations.already_booked'))
      end
    end

end
