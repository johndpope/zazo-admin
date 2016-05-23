class User < BaseConnection::UsersDb
  include EnumHandler
  include AASM
  include UserInfoHelpers
  include UserConnectionHelpers
  include UserEventHelpers
  extend  UserScopeMethods

  serialize :emails, Array

  has_many :connections_as_creator, class_name: 'Connection', foreign_key: :creator_id
  has_many :connections_as_target,  class_name: 'Connection', foreign_key: :target_id
  has_one  :push_user, primary_key: :mkey, foreign_key: :mkey

  has_many :events_as_initiator, class_name: 'Event', primary_key: :mkey, foreign_key: :initiator_id
  has_many :events_as_target,    class_name: 'Event', primary_key: :mkey, foreign_key: :target_id

  def event_as_sender
    Event.with_sender(mkey)
  end

  def event_as_receiver
    Event.with_receiver(mkey)
  end

  define_enum :device_platform, [:ios, :android]

  aasm column: :status do
    state :initialized, initial: true
    state :invited
    state :registered
    state :failed_to_register
    state :verified
  end
end
