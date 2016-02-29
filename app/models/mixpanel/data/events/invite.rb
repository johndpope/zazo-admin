class Mixpanel::Data::Events::Invite < Mixpanel::Data::Events::Base
  def self.description
    {
      name: :invite,
      default_scope: -> { Event.invites },
      user_scope_method: :by_initiator_id,
      users_scope_method: :by_initiator_id,
      user: -> (e) { e.initiator_id },
      data: -> (e) {
        { 'target_mkey' => e.target_id }
      }
    }
  end
end
