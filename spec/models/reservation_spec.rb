require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_presence_of(:table) }

    context 'uncorrect start time' do
      let(:reservation) { build(:reservation, start_time: Time.now - 1.hour) }

      it 'should arise start time validation error' do
        expect {reservation.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: Start time can't be less than time now")
      end
    end

    context 'end time <= start time' do
      start_time = Time.now + 1.hour
      let(:reservation) { build(:reservation, start_time: start_time, end_time: start_time - 1.hour) }

      it 'should arise end time validation error' do
        expect {reservation.save!}.to  raise_error(ActiveRecord::RecordInvalid,"Validation failed: End time can't be less or equel than start time")
      end
    end
  end
end
