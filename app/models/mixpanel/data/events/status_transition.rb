class Mixpanel::Data::Events::StatusTransition < Mixpanel::Data::Events::Base
  def self.description
    {
      name: :status_transition,
      default_scope: -> { Event.status_transitions },
      user_scope_method: :by_initiator_id,
      users_scope_method: :by_initiator_id,
      user: -> (e) { e.initiator_id },
      data: -> (e) {
        { 'previous_status' => e.data['from_state'],
          'current_status'  => e.data['to_state'] }
      }
    }
  end
end
