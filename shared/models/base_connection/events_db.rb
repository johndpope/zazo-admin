module BaseConnection
  class EventsDb < ActiveRecord::Base
    self.abstract_class = true

    establish_connection :"events_db_#{Rails.env}"

    after_initialize :readonly! unless Rails.env.test?
  end
end
