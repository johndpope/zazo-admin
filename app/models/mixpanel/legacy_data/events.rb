class Mixpanel::LegacyData::Events < Mixpanel::LegacyData::Base
  attr_reader :time_from, :time_to

  def initialize(user, time_from, time_to)
    @time_from, @time_to = [time_from, time_to]
    super user
  end

  private

  def prepared_data
    { status_transition: status_transition_events,
      zazo_sent: zazo_sent_events,
      invite: invite_events }
  end

  def status_transition_events
    wrap_time_restrictions(user.status_transition_events).map do |e|
      { 'previous_status' => e.data['from_state'],
        'current_status'  => e.data['to_state'] }.merge time(e)
    end
  end

  def zazo_sent_events
    wrap_time_restrictions(user.zazo_sent_events).map do |e|
      { 'target_mkey' => e.data['receiver_id'] }.merge time(e)
    end
  end

  def invite_events
    wrap_time_restrictions(user.invite_events).map do |e|
      { 'target_mkey' => e.target_id }.merge time(e)
    end
  end

  def wrap_time_restrictions(scope)
    scope.since(time_from).till(time_to)
  end

  # common event attributes

  def time(event)
    { 'time' => event.triggered_at.to_i }
  end
end
