class Mixpanel::LegacyData::Base
  attr_reader :user, :data

  def initialize(user)
    @user = user
    @data = prepared_data
  end

  protected

  def prepared_data
    Hash.new
  end
end
