class Mixpanel::LegacyData::User < Mixpanel::LegacyData::Base
  def prepared_data
    { '$id'              => user.id,
      '$mkey'            => user.mkey,
      '$first_name'      => user.first_name,
      '$last_name'       => user.last_name,
      '$mobile_phone'    => user.mobile_number,
      '$country_code'    => user.country,
      '$client_platform' => user.client_platform,
      '$referrer'        => user.referrer,
      '$created_at'      => user.created_at,
      '$connections'     => user.connections.count }
  end
end
