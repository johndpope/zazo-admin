class Mixpanel::LegacyData::User < Mixpanel::LegacyData::Base
  def prepared_data
    { '$id'         => user.id,
      '$mkey'       => user.mkey,
      '$first_name' => user.first_name,
      '$last_name'  => user.last_name,
      '$country'    => user.country,
      '$referrer'   => user.referrer }
  end
end
