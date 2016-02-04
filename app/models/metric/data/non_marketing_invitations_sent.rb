class Metric::Data::NonMarketingInvitationsSent < Metric::Data::Base
  def self.allowed_attributes
    { start_date: { default: 10.years.ago.to_time,      validate: { before: string_contains_date? }, transform: string_to_time },
      end_date:   { default: 10.years.from_now.to_time, validate: { before: string_contains_date? }, transform: string_to_time } }
  end

  def generate
    run_raw_query_on_events(query)
  end

  protected

  def query
    <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          triggered_at
        FROM events
        WHERE name = '{user,invited}'
      ), non_marketing_registered AS (
        SELECT
          events.initiator_id      initiator,
          MIN(events.triggered_at) becoming_registered
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name = '{user,registered}'
        GROUP BY initiator_id
      ), all_verified AS (
        SELECT
          events.initiator_id      initiator,
          MIN(events.triggered_at) becoming_verified
        FROM events
        WHERE name = '{user,verified}'
        GROUP BY initiator_id
      ), invites AS (
        SELECT
          initiator_id         inviter,
          target_id            invitee,
          invited.triggered_at invited_at
        FROM events
          INNER JOIN invited ON events.target_id = invited.invitee
        WHERE
          name = '{user,invitation_sent}' AND
          EXTRACT(EPOCH FROM events.triggered_at - invited.triggered_at) < 1
        GROUP BY inviter, target_id, invited.triggered_at
      ), invites_sent_limited AS (
        SELECT
          inviter,
          COUNT(DISTINCT invitee) "count"
        FROM invites
        WHERE invited_at > '#{start_date}' AND
              invited_at < '#{end_date}'
        GROUP BY inviter
      ), invites_sent AS (
        SELECT
          inviter,
          COUNT(DISTINCT invitee) "count"
        FROM invites
        GROUP BY inviter
      ) SELECT
          non_marketing_registered.initiator,
          becoming_registered,
          becoming_verified,
          COALESCE(invites_sent.count, 0) invites_sent,
          COALESCE(invites_sent_limited.count, 0) invites_sent_limited
        FROM non_marketing_registered
          LEFT OUTER JOIN all_verified
            ON all_verified.initiator = non_marketing_registered.initiator
          LEFT OUTER JOIN invites_sent
            ON invites_sent.inviter = non_marketing_registered.initiator
          LEFT OUTER JOIN invites_sent_limited
            ON invites_sent_limited.inviter = non_marketing_registered.initiator
    SQL
  end
end
