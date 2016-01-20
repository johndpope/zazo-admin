class Mixpanel::LegacyData::Base
  attr_reader :user, :data

  def initialize(user)
    @user = user
  end

  def prepare
    @data = prepared_data
    self
  end

  protected

  def prepared_data
    Hash.new
  end
end
