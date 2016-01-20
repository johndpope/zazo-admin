class Mixpanel::ImportLegacyData
  attr_reader :users, :tracker

  def initialize(users = User.all)
    @users   = Array users
    @tracker = Mixpanel::Tracker.new Figaro.env.mixpanel_app_token
  end

  def do
    users.map do |user|
      import_user user, Mixpanel::LegacyData::User.new(user).data
      events_data = Mixpanel::LegacyData::Events.new(user).data
      events_data.keys.each { |name| import_events user, name, events_data[name] }
    end
  end

  private

  def import_user(user, data)
    p [:import_user, user.mkey]
    tracker.people.set user.mkey, data
  end

  def import_events(user, name, data)
    data.each do |row|
      p [:import_events, user.mkey, name]
      tracker.import Figaro.env.mixpanel_api_key, user.mkey, name, row
    end
  end
end
