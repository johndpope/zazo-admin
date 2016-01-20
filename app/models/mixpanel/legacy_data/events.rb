class Mixpanel::LegacyData::Events < Mixpanel::LegacyData::Base
  def prepared_data
    { status_transitions: status_transition_events,
      zazo_sent: zazo_sent_events,
      invites: invite_events }
  end

  private

  def status_transition_events
    user.status_transition_events.map do |e|

    end
  end

  def zazo_sent_events
    user.zazo_sent_events.map do |e|

    end
  end

  def invite_events
    user.invite_events.map do |e|

    end
  end
end
