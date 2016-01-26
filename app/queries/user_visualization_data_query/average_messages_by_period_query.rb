class UserVisualizationDataQuery::AverageMessagesByPeriodQuery
  DEFAULT_SINCE  = Date.today - 1.month
  DEFAULT_PERIOD = 'day'

  def initialize(users, options = {})
    @users  = users
    @period = options[:period] || DEFAULT_PERIOD
    @since  = options[:since]  || DEFAULT_SINCE
  end

  def total
    @since = DateTime.strptime '0', '%s'
    self
  end

  def execute
    selected = select_users
    return {} if selected.empty?
    data = EventsApi.new.metric_data :messages_count_by_period,
                                     users_ids: selected,
                                     group_by:  @period,
                                     since:     @since
    calculate_for_each_user data
  end

  private

  def select_users
    @users.select(&:verified?).map(&:mkey)
  end

  def calculate_for_each_user(data)
    data.keys.each_with_object({}) do |mkey, memo|
      total, average = calculate_total_and_average data[mkey]
      memo[mkey] = { total: total, average: average }
    end
  end

  def calculate_total_and_average(data)
    total, average = 0, 0
    if data.size > 0
      data.keys.each { |date| total += data[date] }
      days_between = (Date.today - Date.parse(data.keys.first)).round
      average = (total.to_f / days_between).round 2
    end
    [total, average]
  end
end
