class Metric::Data::UsersStatus < Metric::Data::Base
  def generate
    User.group(:status).count
  end
end
