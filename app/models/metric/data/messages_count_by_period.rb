class Metric::Data::MessagesCountByPeriod < Metric::Data::Base
  include Metric::Data::Shared::GroupableByTimeFrame

  def self.allowed_attributes
    { users_ids: { transform: -> (a) { Array a } },
      since: {},
      group_by: { optional: true } }
  end

  def generate
    results(%w(video s3 uploaded)).each_with_object({}) do |value, memo|
      memo[value['sender']] ||= {}
      memo[value['sender']]["#{value['period']} UTC"] = value['count'].to_i
    end
  end

  protected

  def results(events)
    sql = <<-SQL
      SELECT
        data->>'sender_id' as sender,
        DATE_TRUNC(?, triggered_at) as period,
        COUNT(DISTINCT data->>'video_filename')
      FROM events
      WHERE data->>'sender_id' IN (?)
      AND triggered_at > ?
      AND name = ARRAY[?]::varchar[]
      GROUP BY period, sender
      ORDER BY sender, period
    SQL
    sql = Event.send :sanitize_sql_array,
                     [sql, group_by, users_ids, since, events]
    Event.connection.select_all sql
  end
end
