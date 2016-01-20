class Mixpanel::ImportLegacyData
  attr_reader :users

  def initialize(users = User.all)
    @users = users
  end

  def do

  end

  def data
    users.map do |user|
      user_data = Mixpanel::LegacyData::User.new(user).prepare.data
    end
  end
end
