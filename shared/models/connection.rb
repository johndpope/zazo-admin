class Connection < BaseConnection::UsersDb
  include AASM

  belongs_to :creator, class_name: 'User'
  belongs_to :target,  class_name: 'User'

  aasm column: :status do
    state :voided, initial: true
    state :established
  end

  scope :for_user_id, -> (user_id) { where ['creator_id = ? OR target_id = ?', user_id, user_id] }
  scope :between_creator_and_target, -> (creator_id, target_id) { where ['creator_id = ? AND target_id = ?', creator_id, target_id] }

  def self.live_between(user1_id, user2_id)
    between_creator_and_target(user1_id, user2_id).established + between_creator_and_target(user2_id, user1_id).established
  end

  def self.between(user1_id, user2_id)
    between_creator_and_target(user1_id, user2_id) + between_creator_and_target(user2_id, user1_id)
  end

  def active?
    return false unless established?
    Kvstore.where('key1 LIKE ?', "#{key_search(creator, target)}%").count > 0 &&
      Kvstore.where('key1 LIKE ?', "#{key_search(target, creator)}%").count > 0
  end

  def connected_user(user_id)
    creator_id == user_id ? target : creator
  end

  def event_id
    ckey
  end

  private

  def key_search(sender, receiver)
    "#{sender.mkey}-#{receiver.mkey}"
  end
end


