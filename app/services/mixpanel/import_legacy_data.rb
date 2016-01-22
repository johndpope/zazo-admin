class Mixpanel::ImportLegacyData
  DEFAULT_TIME_FROM = 5.years.ago
  DEFAULT_TIME_TO   = 5.years.from_now

  attr_reader :users, :tracker, :time_from, :time_to

  def initialize(users = User.includes(:push_user).all,
                 time_from: DEFAULT_TIME_FROM, time_to: DEFAULT_TIME_TO)
    @users   = Array users
    @tracker = Mixpanel::Tracker.new Figaro.env.mixpanel_app_token
    @time_from, @time_to = [time_from, time_to]
  end

  def do
    users.map do |user|
      import_user user, Mixpanel::LegacyData::User.new(user).data
      events_data = Mixpanel::LegacyData::Events.new(user, time_from, time_to).data
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
