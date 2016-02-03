class Metric::Data::InvitationFunnel < Metric::Data::Base
  DATA_SUBCLASSES = [
    :verified_sent_invitations,
    :average_invitations_count,
    :invited_to_registered,
    :registered_to_verified,
    :verified_to_active
  ]

  def self.allowed_attributes
    { start_date: { default: 10.years.ago.to_time,      validate: validate_date_string },
      end_date:   { default: 10.years.from_now.to_time, validate: validate_date_string } }
  end

  def generate
    DATA_SUBCLASSES.each_with_object({}) do |metric, memo|
      klass = "Metric::Data::InvitationFunnel::#{metric.to_s.camelize}".constantize
      memo[metric] = klass.new(start_date, end_date).generate
    end
  end
end
