class UserDecorator < Draper::Decorator
  delegate_all
  decorates_association :events

  #
  # Connected users
  #

  def connected_by_states
    initial = User::STATES.each_with_object({}) do |state, memo|
      memo[state] = []
    end
    @connected_by_state ||= object.connected_users.each_with_object(initial) do |user, memo|
      memo[user.status.to_sym] << user
    end
  end

  def connected_counts_by_states
    list = User::STATES.map do |state|
      %(#{h.status_tag(state)} <span class="badge status #{state}">#{connected_by_states[state].size}</span>)
    end.join(' | ')
    h.raw list
  end

  def connected_counts
    User::STATES.inject(0) do |memo, state|
      memo + connected_by_states[state].size
    end
  end

  #
  # Connections
  #

  def grouped_connections(merge = true)
    unless @grouped_connections
      initial = { active: [], inactive: [] }
      @grouped_connections = object.connections.each_with_object(initial) do |conn, memo|
        conn.active? ? memo[:active] << conn.decorate : memo[:inactive] << conn.decorate
      end
    end

    if merge
      sort_connections(@grouped_connections[:active]) +
        sort_connections(@grouped_connections[:inactive])
    else
      @grouped_connections
    end
  end

  def connections_counts_by_groups
    active = grouped_connections(false)[:active].size
    invitees, inviters = 0, 0
    grouped_connections.each do |conn|
      conn.creator.id == object.id ? invitees += 1 : inviters += 1
    end
    h.raw %(<span class="status active">active</span> <span class="badge">#{active}</span> |
      <span class="status invited">invited by user</span> <span class="badge">#{invitees}</span> |
      <span class="status invited">invited by friend</span> <span class="badge">#{inviters}</span>)
  end

  def connections_counts
    grouped_connections.size
  end

  private

  def sort_connections(conns)
    conns.sort_by { |c| c.creator.id <=> object.id }
  end
end
