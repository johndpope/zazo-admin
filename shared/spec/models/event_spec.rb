RSpec.describe Event, type: :model do
  let(:message_id) { SecureRandom.uuid }

  describe '.filter_by' do
    let(:term) { user_id }
    subject { described_class.filter_by(term).order(:triggered_at) }

    context 'dataset 1' do
      let(:user_1) { gen_hash }
      let(:user_2) { gen_hash }
      let(:video_1) { gen_video_id }
      let(:video_2) { gen_video_id }

      before do
        @user_1_activity = []
        @user_2_activity = []
        e = build(:event, :user_initialized, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        e = build(:event, :user_registered, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        e = build(:event, :user_verified, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        video_events_1 = video_flow video_data(user_1, user_2, video_1)
        @user_1_activity += video_events_1
        @user_2_activity += video_events_1
        e = build(:event, :user_initialized, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :user_invited, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :connection_established,
                  initiator_id: "1_2_#{gen_hash}")
        e.initiator = 'connection'
        e.save
        invitation = build(:event, :user_invitation_sent,
                           initiator_id: user_1,
                           target_id: user_2,
                           data: invitation_data(user_1, user_2))
        invitation.initiator = 'user'
        invitation.target = 'user'
        invitation.save
        @user_1_activity << invitation
        @user_2_activity << invitation
        e = build(:event, :user_registered, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :user_verified, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        video_events_2 = video_flow video_data(user_2, user_1, video_2)
        @user_1_activity += video_events_2
        @user_2_activity += video_events_2
      end

      context 'user_1' do
        let(:term) { user_1 }
        it { is_expected.to eq(@user_1_activity) }
      end

      context 'user_2' do
        let(:term) { user_2 }
        it { is_expected.to eq(@user_2_activity) }
      end
    end
  end
end
