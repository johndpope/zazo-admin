class Mixpanel::Data::Events::ZazoSent < Mixpanel::Data::Events::Base
  def self.description
    {
      name: :zazo_sent,
      default_scope: -> { Event.video_s3_uploaded.distinct_target_id },
      user_scope_method: :with_sender,
      users_scope_method: :with_senders,
      user: -> (e) { e.data['sender_id'] },
      data: -> (e) {
        { 'target_mkey' => e.data['receiver_id'] }
      }
    }
  end
end
