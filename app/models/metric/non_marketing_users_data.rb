class Metric::NonMarketingUsersData
  VERIFIED_DATE_FROM = '2015-11-04'

  attr_reader :data, :options
  attr_reader :total_invites, :invites_date_limited,
              :nmv, :nmr, :nmv_more_then_zero_invites, :app_link_clicks

  def initialize(data, opts)
    @data    = data
    @options = {}
    @options[:start_date] = !opts[:start_date] || opts[:start_date].empty? ? "01/09/2005" : opts[:start_date]
    @options[:end_date]   = !opts[:end_date]   || opts[:end_date].empty?   ? "01/09/2025" : opts[:end_date]

    @total_invites        = initial_stats android_after_verified_date: 0
    @invites_date_limited = initial_stats android_after_verified_date: 0

    @nmv = initial_stats
    @nmr = initial_stats
    @nmv_more_then_zero_invites = initial_stats
    @app_link_clicks = { all: 0, date_limited: 0 }

    calculate_results
  end

  def nmv_more_then_zero_invites_from_nmv(platform)
    (nmv_more_then_zero_invites[:all][platform].to_f / nmv[:date_limited][platform]).round(4)
  end

  def total_invites_from_nmv_more_then_zero_invites(platform)
    (total_invites[:all][platform].to_f / nmv_more_then_zero_invites[:date_limited][platform]).round(4)
  end

  def click_store_link_from_total_invites
    (app_link_clicks[:all].to_f / total_invites[:date_limited][:android_after_verified_date]).round(4)
  end

  def nmr_from_total_invites
    (nmr[:all][:total].to_f / total_invites[:date_limited][:total]).round(4)
  end

  def nmv_from_nmr(platform)
    (nmv[:all][platform].to_f / nmr[:date_limited][platform]).round(4)
  end

  private

  def initial_stats(merge_with = {})
    { all:          { total: 0, android: 0, ios: 0 }.merge(merge_with),
      date_limited: { total: 0, android: 0, ios: 0 }.merge(merge_with) }
  end

  def users_with_platform
    User.where(mkey: data.map { |row| row['inviter'] }).each_with_object({}) do |user, memo|
      memo[user.mkey] = user.device_platform.to_s
    end
  end

  def calculate_results
    users = users_with_platform
    data.each do |row|
      platform = users[row['inviter']]
      invites              = row['not_limited_invites_sent'].to_i
      invites_date_limited = row['date_limited_invites_sent'].to_i

      @total_invites[:all][:total]          += invites
      @total_invites[:date_limited][:total] += invites_date_limited
      if platform == 'android'
        @total_invites[:all][:android]          += invites
        @total_invites[:date_limited][:android] += invites_date_limited
      end
      if platform == 'ios'
        @total_invites[:all][:ios]          += invites
        @total_invites[:date_limited][:ios] += invites_date_limited
      end

      if row['becoming_verified']
        @nmv[:all][:total]   += 1
        @nmv[:all][:android] += 1 if platform == 'android'
        @nmv[:all][:ios]     += 1 if platform == 'ios'

        if Time.parse(row['becoming_verified']) < Time.parse(options[:end_date])
          @nmv[:date_limited][:total]   += 1
          @nmv[:date_limited][:android] += 1 if platform == 'android'
          @nmv[:date_limited][:ios]     += 1 if platform == 'ios'
        end

        if invites > 0
          @nmv_more_then_zero_invites[:all][:total]   += 1
          @nmv_more_then_zero_invites[:all][:android] += 1 if platform == 'android'
          @nmv_more_then_zero_invites[:all][:ios]     += 1 if platform == 'ios'

          if Time.parse(row['becoming_verified']) < Time.parse(options[:end_date])
            @nmv_more_then_zero_invites[:date_limited][:total]   += 1
            @nmv_more_then_zero_invites[:date_limited][:android] += 1 if platform == 'android'
            @nmv_more_then_zero_invites[:date_limited][:ios]     += 1 if platform == 'ios'
          end
        end

        if platform == 'android' && Time.parse(row['becoming_verified']) >= Time.parse(VERIFIED_DATE_FROM)
          @total_invites[:all][:android_after_verified_date]          += invites
          @total_invites[:date_limited][:android_after_verified_date] += invites_date_limited
          @app_link_clicks[:all]          += row['app_link_clicks_not_limited'].to_i
          @app_link_clicks[:date_limited] += row['app_link_clicks_date_limited'].to_i
        end
      end

      if row['becoming_registered']
        @nmr[:all][:total]   += 1
        @nmr[:all][:android] += 1 if platform == 'android'
        @nmr[:all][:ios]     += 1 if platform == 'ios'

        if Time.parse(row['becoming_registered']) < Time.parse(options[:end_date])
          @nmr[:date_limited][:total]   += 1
          @nmr[:date_limited][:android] += 1 if platform == 'android'
          @nmr[:date_limited][:ios]     += 1 if platform == 'ios'
        end
      end
    end
  end
end
