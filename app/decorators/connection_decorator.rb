class ConnectionDecorator < Draper::Decorator
  delegate_all

  def direction_arrow(user_id)
    object.creator.id == user_id ? '<- (target)' : '-> (creator)'
  end

  def friend_info(user_id)
    connected_user = object.connected_user(user_id)
    h.link_to "#{connected_user.name} (#{connected_user.mobile_number})", connected_user
  end

  def status(user)
    new_status = object.active? ? :active : user.status
    h.status_tag new_status
  end
end
