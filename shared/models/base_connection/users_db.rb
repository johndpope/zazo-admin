module BaseConnection
  class UsersDb < ActiveRecord::Base
    self.abstract_class = true

    after_initialize :readonly!
  end
end
