require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_presence_of(:table) }

    describe 'uncorrect start time' do
      let(:reservation) { build(:reservation, start_time: Time.now - 1.hour) }

      it 'should arise start time validation error' do
        expect {reservation.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: Start time can't be less than time now")
      end
    end

    describe 'end time <= start time' do
      start_time = Time.now + 1.hour
      let(:reservation) { build(:reservation, start_time: start_time, end_time: start_time - 1.hour) }

      it 'should arise end time validation error' do
        expect {reservation.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: End time can't be less or equel than start time")
      end
    end

    describe 'time overlap' do
      start_time = Time.now + 1.hour

      it 'should raise start time validation error because of start time entrance' do
        reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
        reservation_2 = build(:reservation, start_time: reservation.start_time + 30.seconds, end_time: reservation.end_time + 30.minutes, table: 1)

        expect {reservation_2.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: Start time is already booked")
      end

      it 'should raise start time validation error because of end time entrance' do
        reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
        reservation_2 = build(:reservation, start_time: reservation.start_time - 30.seconds, end_time: reservation.end_time - 30.seconds, table: 1)

        expect {reservation_2.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: Start time is already booked")
      end


      it 'should not raise any errors because of different tables' do
        reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
        reservation_2 = build(:reservation, start_time: reservation.start_time + 30.seconds, end_time: reservation.end_time + 30.seconds, table: 2)

        reservation_2.save!
        expect(reservation_2.errors.empty?).to  eq true
      end
    end
  end
end
