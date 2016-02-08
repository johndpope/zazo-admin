class NotificationApi < BaseApi
  version     1
  base_uri    Figaro.env.notification_api_base_url
  digest_auth Settings.app_name_key, Figaro.env.notification_api_token

  raise_errors false

  mapper mobile:  { action: :post, prefix: 'notifications/mobile' },
         default: { action: :get,  prefix: '' }
end
