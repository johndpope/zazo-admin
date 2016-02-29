class Mixpanel::ImportUsers < Mixpanel::ImportBase
  attr_reader :users

  def do
    users.map { |u| import_user u.mkey, Mixpanel::Data::User.new(user: u).data }
  end

  private

  def set_additional_params(params)
    @users = Array params[:users]
  end

  def import_events(user_mkey, name, events_data)
    events_data.each { |event_row| import_event user_mkey, name, event_row[:data] }
  end
end
