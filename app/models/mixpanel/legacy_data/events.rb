class Mixpanel::LegacyData::Events < Mixpanel::LegacyData::Base
  def prepared_data
    { status_transition: status_transition_events,
      zazo_sent: zazo_sent_events,
      invite: invite_events }
  end

  private

  def status_transition_events
    user.status_transition_events.map do |e|
      { 'previous_status' => e.data['from_state'],
        'current_status'  => e.data['to_state'] }.merge time(e)
    end
  end

  def zazo_sent_events
    user.zazo_sent_events.map do |e|
      { 'target_mkey' => e.data['receiver_id'] }.merge time(e)
    end
  end

  def invite_events
    user.invite_events.map do |e|
      { 'target_mkey' => e.target_id }.merge time(e)
    end
  end

  # common event attributes

  def time(event)
    { 'time' => event.triggered_at.to_i }
  end
end
