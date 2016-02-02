class Metric::InvitationConversionData
  attr_reader :data, :options, :start_date, :end_date

  def initialize(data, opts)
    @data    = data
    @options = opts

    @start_date = !options[:start_date] || options[:start_date].empty? ? 10.years.ago.to_time : Time.parse(options[:start_date])
    @end_date   = !options[:end_date] || options[:end_date].empty? ? 10.years.from_now.to_time : Time.parse(options[:end_date])

    [:invited, :registered, :store_clicks, :store_clicks_unique].each do |var|
      self.instance_variable_set :"@#{var}", initial_stats
    end
    calculate_results
  end

  def for_each_key
    [:limited, :not_limited].each { |key| yield key }
  end

  def percent_from_invited(type, key)
    instance_numerator   = instance_variable_get :"@#{type}"
    (instance_numerator[key].to_f / invited(key) * 100).round 2
  end

  def invited(key)
    @invited[key]
  end

  def registered(key)
    @registered[key]
  end

  def store_clicks(key)
    @store_clicks[key]
  end

  def store_clicks_unique(key)
    @store_clicks_unique[key]
  end

  private

  def initial_stats
    { not_limited: 0,
      limited:     0 }
  end

  def calculate_results
    data.each do |row|
      calculate_users_by_state row, :invited
      calculate_users_by_state row, :registered
      calculate_store_clicks   row
    end
  end

  def calculate_users_by_state(row, state)
    date = row["#{state}_at"]
    if date
      state_at = Time.parse(date)
      instance = instance_variable_get :"@#{state}"
      instance[:not_limited] += 1

      if state == :registered
        invited_at = Time.parse row['invited_at']
        instance[:limited] += 1 if state_at   > start_date && state_at   < end_date &&
                                   invited_at > start_date && invited_at < end_date
      else
        instance[:limited] += 1 if state_at > start_date && state_at < end_date
      end
    end
  end

  def calculate_store_clicks(row)
    clicks_not_limited  = row['clicks_not_limited'].to_i
    clicks_date_limited = row['clicks_date_limited'].to_i

    @store_clicks[:not_limited] += clicks_not_limited
    @store_clicks[:limited]     += clicks_date_limited
    @store_clicks_unique[:not_limited] += 1 if clicks_not_limited > 0
    @store_clicks_unique[:limited]     += 1 if clicks_date_limited > 0
  end
end
