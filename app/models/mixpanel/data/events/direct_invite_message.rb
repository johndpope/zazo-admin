class Mixpanel::Data::Events::DirectInviteMessage < Mixpanel::Data::Events::Base
  def self.description
    {
      name: :direct_invite_message,
      default_scope: -> { Event.direct_invite_messages },
      users_scope_method: :by_initiator_id,
      user: -> (e) { e.initiator_id },
      data: -> (e) {
        { 'inviter_id' => e.data['inviter_id'],
          'invitee_id' => e.data['invitee_id'],
          'messaging_platform' => e.data['messaging_platform'],
          'message_status'     => e.data['message_status'] }
      }
    }
  end
end
