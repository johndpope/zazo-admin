module User::UserEventHelpers
  def event_id
    mkey
  end

  def referrer
    events_as_initiator.by_name(%w(user invited)).empty? ? 'marketing' : 'invite'
  end

  def status_transition_events
    events_as_initiator.status_transitions
  end

  def zazo_sent_events
    event_as_sender.video_s3_uploaded
  end

  def invite_events
    events_as_initiator.invites
  end

  def events(page = 1)
    Event.page(page).filter_by(event_id).order triggered_at: :desc
  end
end
