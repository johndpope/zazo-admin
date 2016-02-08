class PushUser < BaseConnection::UsersDb
  include EnumHandler

  define_enum :device_platform, [:ios, :android], primary: true
  define_enum :device_build, [:dev, :prod]
end
