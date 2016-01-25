class Mixpanel::Data::Events
  EVENTS_DESCRIPTIONS = [
    {
      name: :status_transition,
      default_scope: -> { Event.status_transitions },
      user_scope_method: :by_initiator_id,
      data: -> (e) {
        { 'previous_status' => e.data['from_state'],
          'current_status'  => e.data['to_state'] }
      }
    }, {
      name: :zazo_sent,
      default_scope: -> { Event.video_s3_uploaded.distinct_target_id },
      user_scope_method: :with_sender,
      data: -> (e) {
        { 'target_mkey' => e.data['receiver_id'] }
      }
    }, {
      name: :invite,
      default_scope: -> { Event.invites },
      user_scope_method: :by_initiator_id,
      data: -> (e) {
        { 'target_mkey' => e.target_id }
      }
    }
  ]

  attr_reader :data, :user, :time_from, :time_to

  def initialize(user: nil, time_from: nil, time_to: nil)
    @time_from, @time_to = [time_from, time_to]
    @user = user
    @data = prepared_data
  end

  private

  def prepared_data
    EVENTS_DESCRIPTIONS.each_with_object({}) do |desc, memo|
      memo[desc[:name]] = event_data_by_desc desc
    end
  end

  def event_data_by_desc(desc)
    wrap_restrictions(desc[:default_scope].call, desc[:user_scope_method]).map do |e|
      { original_event: e,
        data: desc[:data].call(e).merge('time' => e.triggered_at.to_i) }
    end
  end

  def wrap_restrictions(scope, user_scope_method)
    scope = scope.since time_from if time_from
    scope = scope.till time_to if time_to
    scope = scope.send user_scope_method, user.mkey if user
    scope
  end
end
