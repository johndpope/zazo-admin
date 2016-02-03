class Metric::Data::UserActivity < Metric::Data::Base
  def self.allowed_attributes
    { user_id: {} }
  end

  def generate
    Event.filter_by(user_id).order(:triggered_at)
  end
end
