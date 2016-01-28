module User::UserInfoHelpers
  def name
    [first_name, last_name].join(' ')
  end

  def app?
    device_platform.present?
  end

  def country
    Phonelib.parse(mobile_number).country || :undefined
  end

  def client_platform
    push_user.device_platform rescue device_platform
  end

  def info
    "#{name}[#{id}]"
  end
end
