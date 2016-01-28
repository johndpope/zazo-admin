RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe '.find_by_raw_mobile_number' do
    let(:mobile_number) { '+1 650-111-0000' }
    subject { described_class.find_by_raw_mobile_number(mobile_number) }

    context 'when record not exists' do
      it { is_expected.to be_nil }
    end

    context 'when record already exists' do
      let!(:user) { create(:user, mobile_number: mobile_number) }
      it { is_expected.to eq(user) }
    end
  end

  describe '.search' do
    subject { described_class.search(query) }
    let!(:user1) { create(:user, first_name: 'Alex', last_name: 'Smith') }
    let!(:user2) { create(:user, first_name: 'Serhii', last_name: 'Ulianytskyi') }
    let!(:user3) do
      create(:user, first_name: 'Ivan', last_name: 'Ivanov',
                    mobile_number: '+380939523746')
    end

    context 'Alex' do
      let(:query) { 'Alex' }
      it { is_expected.to eq([user1]) }
    end

    context 'alex' do
      let(:query) { 'alex' }
      it { is_expected.to eq([user1]) }
    end

    context 'Ulian' do
      let(:query) { 'Ulian' }
      it { is_expected.to eq([user2]) }
    end

    context 'ulian' do
      let(:query) { 'ulian' }
      it { is_expected.to eq([user2]) }
    end

    context '+380939523746' do
      let(:query) { '+380939523746' }
      it { is_expected.to eq([user3]) }
    end

    context 'empty string' do
      let(:query) { '' }
      it { is_expected.to eq([user1, user2, user3]) }
    end

    context 'nil' do
      let(:query) {}
      it { is_expected.to eq([user1, user2, user3]) }
    end
  end

  describe '#name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Smith') }
    subject { user.name }
    it { is_expected.to eq('John Smith') }
  end

  describe '#info' do
    let(:user) { create(:user) }
    subject { user.info }
    it { is_expected.to eq("#{user.name}[#{user.id}]") }
  end

  describe '#active_connections' do
    let(:video_id) { '1426622544176' }
    let(:user) { create(:user) }
    subject { user.active_connections }

    context 'when is no connections for user' do
      it { is_expected.to eq([]) }
    end

    context 'when 1 connection as a creator' do
      let!(:connection) { create(:established_connection, creator: user) }

      context 'and 1 ongoing video' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }

        it { is_expected.to eq([]) }
      end

      context 'and 1 incoming video' do
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }

        it { is_expected.to eq([]) }
      end

      context 'and ongoing & incoming videos' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }

        it { is_expected.to eq([connection]) }
      end
    end

    context 'when 1 connection as a target' do
      let!(:connection) { create(:established_connection, target: user) }

      context 'and 1 ongoing video' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }

        it { is_expected.to eq([]) }
      end

      context 'and 1 incoming video' do
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }

        it { is_expected.to eq([]) }
      end

      context 'and ongoing & incoming videos' do
        before { Kvstore.add_id_key(connection.creator, connection.target, video_id) }
        before { Kvstore.add_id_key(connection.target, connection.creator, video_id) }

        it { is_expected.to eq([connection]) }
      end
    end

    context 'when 1 connection as a creator & 1 as a target' do
      let!(:connection1) { create(:established_connection, creator: user) }
      let!(:connection2) { create(:established_connection, target: user) }

      context 'for first connection' do
        context 'and 1 ongoing video' do
          before { Kvstore.add_id_key(connection1.creator, connection1.target, video_id) }

          it { is_expected.to eq([]) }
        end

        context 'and 1 incoming video' do
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }

          it { is_expected.to eq([]) }
        end

        context 'and ongoing & incoming videos' do
          before { Kvstore.add_id_key(connection1.creator, connection1.target, video_id) }
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }

          it { is_expected.to eq([connection1]) }
        end

        context 'and ongoing status & incoming videos' do
          before { Kvstore.add_status_key(connection1.creator, connection1.target, video_id, :downloaded) }
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }

          it { is_expected.to eq([connection1]) }
        end
      end

      context 'for both connections' do
        context 'and ongoing & incoming videos' do
          before { Kvstore.add_id_key(connection1.creator, connection1.target, video_id) }
          before { Kvstore.add_id_key(connection2.creator, connection2.target, video_id) }
          before { Kvstore.add_id_key(connection1.target, connection1.creator, video_id) }
          before { Kvstore.add_id_key(connection2.target, connection2.creator, video_id) }

          it { is_expected.to eq([connection1, connection2]) }
        end
      end
    end
  end

  describe '#connected_user_ids' do
    let(:instance) { create(:user) }
    let!(:other) { create(:established_connection, creator: instance).target }
    subject { instance.connected_user_ids }

    it { is_expected.to eq([other.id]) }
  end
end
