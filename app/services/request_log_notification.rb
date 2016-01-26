class RequestLogNotification
  include ActiveModel::Validations

  attr_reader :push_user, :date_start, :date_end
  validate :push_user_must_be_valid
  validate :device_must_be_android
  validate :start_end_date_restrictions

  def initialize(user, options = {})
    @push_user  = PushUser.find_by_mkey user.mkey
    @date_start = date_by_option options[:date_start]
    @date_end   = date_by_option options[:date_end]
  end

  def do
    valid? ? handle_response(NotificationApi.new(notification_data).mobile) : false
  end

  private

  def notification_data
    { subject: 'log_request',
      device_platform: 'android',
      device_token: push_user.push_token,
      payload: { host: payload_host,
                 type: 'log_request',
                 date_start: date_start.strftime('%m/%d/%Y'),
                 date_end:   date_end.strftime('%m/%d/%Y') } }
  end

  def handle_response(res)
    return true if res['status'] == 'success'
    errors.add :response, res.to_s
    false
  end

  def date_by_option(date)
    Time.parse date
  rescue TypeError, ArgumentError
    Time.now
  end

  def payload_host
    "#{(Rails.env.production? ? 'prod' : 'staging')}.zazoapp.com"
  end

  #
  # validations
  #

  def push_user_must_be_valid
    errors.add :push_user, 'not found by mkey' unless push_user
  end

  def device_must_be_android
    if push_user && push_user.device_platform != :android
      errors.add :push_user, 'must have android device platform'
    end
  end

  def start_end_date_restrictions
    errors.add :date_start, 'must be earlier than end_date' if date_start > date_end
    errors.add :date_end, 'should not be later than today'  if date_end > Time.now
  end
end
