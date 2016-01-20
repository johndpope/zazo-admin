module User::UserEventHelpers
  def referrer
    Event.by_name(%w(user invited)).where(initiator_id: mkey).empty? ? 'marketing' : 'invite'
  end

  def status_transitions_events
    Event.status_transitions mkey
  end

  def messages_sent_events
    Event.messages_sent mkey
  end

  def invites_events
    Event.invites mkey
  end
end
