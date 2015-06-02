require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_presence_of(:table) }

    describe 'uncorrect start time' do
      let(:reservation) { build(:reservation, start_time: Time.now - 1.hour, end_time: Time.now + 1.hour) }

      it 'should arise start time validation error' do
        expect {reservation.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: Start time can't be less or equel to time now")
      end
    end

    describe 'end time <= start time' do
      start_time = Time.now + 1.hour
      let(:reservation) { build(:reservation, start_time: start_time, end_time: start_time - 1.hour) }

      it 'should arise end time validation error' do
        expect {reservation.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: End time can't be less or equel to start time")
      end
    end

    describe '#create action' do
      describe 'time overlap' do
        start_time = Time.now + 1.hour

        it 'should raise start time validation error because of start time entrance' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = build(:reservation, start_time: reservation.start_time + 30.minutes, end_time: reservation.end_time + 1.hours, table: 1)
          reservation_2.save

          expect(reservation_2.errors.messages).to include(:start_time => ["is already booked"])
          expect(reservation_2.errors.messages).not_to include(:end_time => ["is already booked"])
        end

        it 'should raise start time validation error because of end time entrance' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = build(:reservation, start_time: reservation.start_time - 30.seconds, end_time: reservation.end_time - 30.seconds, table: 1)

          expect {reservation_2.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: End time is already booked")
        end

        it 'should raise full entrance error' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = build(:reservation, start_time: reservation.start_time + 30.seconds, end_time: reservation.end_time - 30.seconds, table: 1)
          reservation_2.save

          expect(reservation_2.errors.messages).to  include(:start_time, :end_time)
        end

        it 'should raise full entrance error with around time reservation' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = build(:reservation, start_time: reservation.start_time - 30.seconds, end_time: reservation.end_time + 30.seconds, table: 1)
          reservation_2.save

          expect(reservation_2.errors.messages).to  include(:start_time, :end_time)
        end


        it 'should not raise any errors because of different tables' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = build(:reservation, start_time: reservation.start_time + 30.seconds, end_time: reservation.end_time + 30.seconds, table: 2)

          reservation_2.save!
          expect(reservation_2.errors.empty?).to  eq true
        end
      end
    end

    describe '#update action' do
      describe 'time overlap' do
        start_time = Time.now + 1.hour

        it 'should raise start time validation error because of start time entrance' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = create(:reservation, start_time: start_time + 2.hours, end_time: start_time + 5.hours, table: 1)

          reservation_2.update(start_time: start_time + 30.seconds)

          expect(reservation_2.errors.messages).to  include(:start_time => ["is already booked"])
          expect(reservation_2.errors.messages).not_to  include(:end_time => ["is already booked"])
        end

        it 'should raise start time validation error because of end time entrance' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = create(:reservation, start_time: start_time + 3.hours, end_time: start_time + 5.hours, table: 1)

          reservation_2.update(start_time: start_time - 30.seconds, end_time: reservation.end_time - 30.seconds)

          expect(reservation_2.errors.messages).to  include(:end_time => ["is already booked"])
          expect(reservation_2.errors.messages).not_to  include(:start_time => ["is already booked"])
        end

        it 'should raise full entrance error' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = create(:reservation, start_time: start_time + 2.hours, end_time: start_time + 5.hours, table: 1)
          reservation_2.update(start_time: reservation.start_time + 30.seconds, end_time: reservation.end_time - 30.seconds)

          expect(reservation_2.errors.messages).to  include(:start_time, :end_time)
        end

        it 'should raise full entrance error with around time reservation' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = build(:reservation, start_time: start_time + 2.hours, end_time: start_time + 5.hours, table: 1)
          reservation_2.update(start_time: reservation.start_time - 30.seconds, end_time: reservation.end_time + 30.seconds)

          expect(reservation_2.errors.messages).to  include(:start_time, :end_time)
        end


        it 'should not raise any errors because of different tables' do
          reservation = create(:reservation, start_time: start_time, end_time: start_time + 1.hour, table: 1)
          reservation_2 = create(:reservation, start_time: start_time + 3.hours, end_time: start_time + 5.hours, table: 2)
          reservation_2.update(start_time: reservation.start_time + 30.seconds, end_time: reservation.end_time + 30.seconds)

          expect(reservation_2.errors.empty?).to  eq true
        end
      end
    end
  end
end
