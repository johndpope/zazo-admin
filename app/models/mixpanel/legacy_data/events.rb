class Mixpanel::LegacyData::Events
  attr_reader :data, :user, :time_from, :time_to

  def initialize(user: nil, time_from: nil, time_to: nil)
    @time_from, @time_to = [time_from, time_to]
    @user = user
    @data = prepared_data
  end

  private

  def prepared_data
    { status_transition: status_transition_events,
      zazo_sent:         zazo_sent_events,
      invite:            invite_events }
  end

  def status_transition_events
    wrap_restrictions(Event.status_transitions, :by_initiator_id).map do |e|
      { original_event: e,
        data: { 'previous_status' => e.data['from_state'],
                'current_status'  => e.data['to_state'] }.merge(time e) }
    end
  end

  def zazo_sent_events
    wrap_restrictions(Event.video_s3_uploaded, :with_sender).map do |e|
      { original_event: e,
        data: { 'target_mkey' => e.data['receiver_id'] }.merge(time e) }
    end
  end

  def invite_events
    wrap_restrictions(Event.invites, :by_initiator_id).map do |e|
      { original_event: e,
        data: { 'target_mkey' => e.target_id }.merge(time e) }
    end
  end

  def wrap_restrictions(scope, mkey_scope_method)
    scope = scope.since time_from if time_from
    scope = scope.till time_to if time_to
    scope = scope.send mkey_scope_method, user.mkey if user
    scope
  end

  # common event attributes

  def time(event)
    { 'time' => event.triggered_at.to_i }
  end
end
