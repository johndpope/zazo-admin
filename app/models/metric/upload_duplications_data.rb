class Metric::UploadDuplicationsData
  attr_reader :data, :options

  def initialize(data, options)
    @data    = data
    @options = options
    prepare_device_platforms
  end

  def device_platform(user)
    @platforms[user] || ''
  end

  private

  def prepare_device_platforms
    @platforms = User.where(mkey: data.map { |row| row['sender_id'] }).each_with_object({}) do |user, memo|
      memo[user.mkey] = user.device_platform.to_s
    end
  end
end
