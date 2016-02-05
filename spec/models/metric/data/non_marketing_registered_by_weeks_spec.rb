require 'rails_helper'

RSpec.describe Metric::Data::NonMarketingRegisteredByWeeks, type: :model do
  let(:instance) { described_class.new }

  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }
  let(:user_3) { gen_hash }

  describe '#generate' do
    subject { instance.generate }
    before do
      Timecop.travel(3.weeks.ago) do
        invite_at user_1, 5.days.from_now
        invite_at user_2, 5.days.from_now
        register_at user_1, 4.days.from_now
      end
      Timecop.travel(2.weeks.ago) do
        invite_at user_3, 5.days.from_now
      end
      Timecop.travel(1.week.ago) do
        register_at user_2, 1.day.from_now
      end
    end

    # todo: fix this spec
=begin
    it do
      expected = {
        format_datetime(3.weeks.ago.beginning_of_week) => 1,
        format_datetime(1.weeks.ago.beginning_of_week) => 1
      }
      is_expected.to eq expected
    end
=end
  end
end
