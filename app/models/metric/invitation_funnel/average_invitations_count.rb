class Metric::InvitationFunnel::AverageInvitationsCount
  TYPE = :week_base

  attr_reader :data

  def initialize(data)
    @data = data
  end
end
