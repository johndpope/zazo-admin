class Metric::Data::UsersDevicePlatform < Metric::Data::Base
  def generate
    User.group(:device_platform).count
  end
end
