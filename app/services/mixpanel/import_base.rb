class Mixpanel::ImportBase
  DEFAULT_TIME_FROM = 5.years.ago
  DEFAULT_TIME_TO   = 5.years.from_now

  attr_reader :tracker, :time_from, :time_to

  def initialize(params)
    @tracker = Mixpanel::Tracker.new Figaro.env.mixpanel_app_token
    @time_from = params[:time_from] || DEFAULT_TIME_FROM
    @time_to   = params[:time_to]   || DEFAULT_TIME_TO
    set_additional_params params
  end

  def do
  end

  protected

  def set_additional_params(params)
  end

  def import_user(user_mkey, data)
    p [:import_user, user_mkey]
    tracker.people.set user_mkey, data
  end

  def import_event(user_mkey, name, data)
    p [:import_event, user_mkey, name]
    tracker.import Figaro.env.mixpanel_api_key, user_mkey, name, data
  end
end
