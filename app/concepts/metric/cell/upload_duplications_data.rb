class Metric::Cell::UploadDuplicationsData < Metric::Cell
  after_initialize :preparation

  def device_platform(user)
    @platforms[user] || ''
  end

  #
  # preparation
  #

  def preparation
    users = User.where(mkey: data(senders: options[:senders]).map { |row| row['sender_id'] })
    @platforms = users.each_with_object({}) { |user, memo| memo[user.mkey] = user.device_platform.to_s }
  end
end
