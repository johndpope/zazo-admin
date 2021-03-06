class Metric::Data::InvitationFunnel::VerifiedSentInvitations < Metric::Data::InvitationFunnel::Base
  def generate
    data = query_first <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          triggered_at
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
      ), verified AS (
        SELECT
          events.initiator_id initiator,
          MIN(events.triggered_at) becoming_verified
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
        GROUP BY initiator_id
      ), inviters AS (
        SELECT
          events.initiator_id inviter,
          MIN(events.triggered_at) first_invitation,
          COUNT(*) invitations_count
        FROM events
          INNER JOIN invited ON events.target_id = invited.invitee
          INNER JOIN verified ON events.initiator_id = verified.initiator
        WHERE
          name @> ARRAY['user', 'invitation_sent']::VARCHAR[] AND
          EXTRACT(EPOCH FROM events.triggered_at - invited.triggered_at) < 1 AND
          events.triggered_at > '#{start_date}' AND
          events.triggered_at < '#{end_date}'
        GROUP BY inviter
      ), verified_not_inviters AS (
        SELECT
          verified.initiator,
          verified.becoming_verified
        FROM verified
          LEFT OUTER JOIN inviters ON verified.initiator = inviters.inviter
        WHERE inviters.inviter IS NULL
      ), verified_sent_invitations AS (
        SELECT
          COUNT(*) verified_sent_invitations,
          ROUND(AVG(EXTRACT(EPOCH FROM
            inviters.first_invitation -
            verified.becoming_verified) / 3600)::numeric
          ) avg_delay_in_hours
        FROM verified
          INNER JOIN inviters ON verified.initiator = inviters.inviter
      ), verified_not_invite_more_6_weeks_old AS (
        SELECT
          COUNT(*) verified_not_invite_more_6_weeks_old
        FROM verified_not_inviters
        WHERE becoming_verified < NOW() - INTERVAL '6 weeks'
      ) SELECT
          (SELECT COUNT(*) FROM verified) total_verified,
          (SELECT COUNT(*) FROM verified_not_inviters) verified_not_invite,
          (SELECT SUM(invitations_count) FROM inviters) invitations_count,
          (
            SELECT COUNT(*) FROM verified
            WHERE becoming_verified < NOW() - INTERVAL '6 weeks'
          ) total_verified_more_6_weeks_old,
          *
        FROM verified_sent_invitations
          CROSS JOIN verified_not_invite_more_6_weeks_old
    SQL
    default_if_key_nil data, :avg_delay_in_hours
  end

  def default_data
    { total_verified: 0,
      verified_sent_invitations: 0,
      invitations_count: 0,
      avg_delay_in_hours: 0,
      verified_not_invite: 0,
      total_verified_more_6_weeks_old: 0,
      verified_not_invite_more_6_weeks_old: 0 }
  end
end
