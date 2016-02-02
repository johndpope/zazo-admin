class Metric::Data::UploadDuplicationsData < Metric::Data::Base
  def self.allowed_attributes
    { senders: { default: nil, transform: -> (a) { Array.wrap a } } }
  end

  def generate
    run_raw_query_on_events(query)
  end

  protected

  def query
    <<-SQL
      SELECT
        data->>'sender_id' sender_id,
        target_id,
        COUNT(*) count,
        MIN(triggered_at) first_triggered_at,
        MAX(triggered_at) last_triggered_at,
        data->>'client_platform' client_platform,
        data->>'client_version' client_version
      FROM events
      WHERE name = '{video,s3,uploaded}' AND #{restrictions} AND
            (raw_params->'s3'->'object'->>'size')::NUMERIC > 0
      GROUP BY sender_id, target_id, client_platform, client_version
      HAVING COUNT(*) > 1
      ORDER BY last_triggered_at DESC
    SQL
  end

  def restrictions
    if senders && senders.kind_of?(Array)
      senders_as_string = senders.inject('') { |acc, val| acc + "'#{val}'," }[0...-1]
      "data->>'sender_id' IN (#{senders_as_string})"
    else
      'true'
    end
  end
end
