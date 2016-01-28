class ConnectionsVisualizationSerializer < PackSerializer
  ATTRIBUTES = [:creator_id, :target_id, :outgoing_count, :incoming_count]

  private

  def member_outgoing_count(conn)
    get_outgoing_or_incoming_count conn, :outgoing
  end

  def member_incoming_count(conn)
    get_outgoing_or_incoming_count conn, :incoming
  end

  def get_outgoing_or_incoming_count(conn, key)
    order = %w(sender receiver)
    order.reverse! if key == :incoming
    result = @options[:counts].find do |r|
      r[order.first] == conn.creator.event_id &&
      r[order.last]  == conn.target.event_id
    end
    result ? result['count'].to_i : 0
  end
end
