module BaseConnection
  class UsersDb < ActiveRecord::Base
    self.abstract_class = true

    after_initialize :readonly! unless Rails.env.test?
  end
end
