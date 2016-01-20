class User < BaseConnection::UsersDb
  include UserInfoHelpers
  include UserConnectionHelpers
  include UserEventHelpers

  has_many :connections_as_creator, class_name: 'Connection', foreign_key: :creator_id
  has_many :connections_as_target,  class_name: 'Connection', foreign_key: :target_id
  has_one  :push_user, primary_key: :mkey, foreign_key: :mkey
end
