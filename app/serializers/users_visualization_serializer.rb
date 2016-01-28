class UsersVisualizationSerializer < PackSerializer
  ATTRIBUTES = [:id, :name, :mobile_number, :status, :device_platform,
                :connection_counts, :total_messages, :messages_by_last_month,
                :messages_by_last_week, :average_messages_per_day]

  private

  def member_device_platform(user)
    user.device_platform.nil? ? '' : user.device_platform[0]
  end

  def member_connection_counts(user)
    user.respond_to?(:connection_counts) ? user.connection_counts : 0
  end

  def member_status(user)
    get_total_or_average_messages(user, :month, :total) > 0 ? 'active' : user.status
  end

  def member_total_messages(user)
    get_total_or_average_messages user, :total, :total
  end

  def member_messages_by_last_month(user)
    get_total_or_average_messages user, :month, :total
  end

  def member_messages_by_last_week(user)
    get_total_or_average_messages user, :week, :total
  end

  def member_average_messages_per_day(user)
    get_total_or_average_messages user, :month, :average
  end

  def get_total_or_average_messages(user, period, key)
    @options && @options[period] && @options[period][user.mkey] && @options[period][user.mkey][key] || 0
  end
end
