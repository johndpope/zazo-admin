class Mixpanel::ImportData < Mixpanel::ImportBase
  attr_reader :users

  def do(import_users: true)
    users.map do |user|
      import_user user.mkey, Mixpanel::Data::User.new(user: user).data if import_users
      events = Mixpanel::Data::Events.new(user: user, time_from: time_from, time_to: time_to).data
      events.keys.each { |name| import_events user.mkey, name, events[name] }
    end
  end

  private

  def set_additional_params(params)
    @users = Array params[:users]
  end

  def import_events(user_mkey, name, events_data)
    events_data.each { |event_row| import_event user_mkey, name, event_row[:data] }
  end
end
