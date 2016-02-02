class Metric::NonMarketingInvitationsSent
  attr_reader :data, :options, :start_date, :end_date, :platforms

  def initialize(data, opts)
    @data    = data
    @options = opts

    @start_date = !options[:start_date] || options[:start_date].empty? ? 10.years.ago.to_time : Time.parse(options[:start_date])
    @end_date   = !options[:end_date] || options[:end_date].empty? ? 10.years.from_now.to_time : Time.parse(options[:end_date])

    @platforms = platforms_by_users
    [:registered, :verified, :users_who_invites, :invites, :invites_per_user_who_invites].each do |var|
      self.instance_variable_set :"@#{var}", initial_stats
    end
    calculate_results
  end

  def for_each_platform
    [:total, :ios, :android].each do |platform|
      [:limited, :not_limited].each { |key| yield key, platform }
    end
  end

  def percent_between(num, den)
    instance_numerator   = instance_variable_get :"@#{num[:type]}"
    instance_denominator = instance_variable_get :"@#{den[:type]}"
    (instance_numerator[num[:key]][num[:platform]].to_f / instance_denominator[den[:key]][den[:platform]] * 100).round 2
  end

  def registered(key, platform)
    @registered[key][platform]
  end

  def verified(key, platform)
    @verified[key][platform]
  end

  def users_who_invites(key, platform)
    @users_who_invites[key][platform]
  end

  def invites(key, platform)
    @invites[key][platform]
  end

  def invites_per_user_who_invites(key, platform)
    (@invites[key][platform].to_f / @users_who_invites[key][platform]).round 2
  end

  private

  def initial_stats
    { not_limited: { total: 0, android: 0, ios: 0 },
      limited:     { total: 0, android: 0, ios: 0 } }
  end

  def platforms_by_users
    User.where(mkey: data.map { |row| row['initiator'] }).each_with_object({}) do |user, memo|
      memo[user.mkey] = user.device_platform.to_s
    end
  end

  def platform_by_data_row(row)
    platforms[row['initiator']]
  end

  def calculate_results
    data.each do |row|
      calculate_users_by_state    row, :registered
      calculate_users_by_state    row, :verified
      calculate_users_and_invites row, 'invites_sent', :not_limited
      calculate_users_and_invites row, 'invites_sent_limited', :limited
    end
  end

  def calculate_users_by_state(row, state)
    date     = row["becoming_#{state}"]
    platform = platform_by_data_row(row)

    if date
      state_at = Time.parse(date)
      is_fits_into_dates = state_at > start_date && state_at < end_date
      instance = instance_variable_get :"@#{state}"

      instance[:not_limited][:total] += 1
      instance[:limited][:total]     += 1 if is_fits_into_dates

      if platform == 'android'
        instance[:not_limited][:android] += 1
        instance[:limited][:android]     += 1 if is_fits_into_dates
      end

      if platform == 'ios'
        instance[:not_limited][:ios] += 1
        instance[:limited][:ios]     += 1 if is_fits_into_dates
      end
    end
  end

  def calculate_users_and_invites(row, row_key, instance_key)
    invites_sent = row[row_key].to_i
    platform     = platform_by_data_row(row)

    if invites_sent > 0
      @users_who_invites[instance_key][:total]   += 1
      @users_who_invites[instance_key][:ios]     += 1 if platform == 'ios'
      @users_who_invites[instance_key][:android] += 1 if platform == 'android'

      @invites[instance_key][:total]   += invites_sent
      @invites[instance_key][:ios]     += invites_sent if platform == 'ios'
      @invites[instance_key][:android] += invites_sent if platform == 'android'
    end
  end
end
