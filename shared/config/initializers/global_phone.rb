require 'global_phone'

GlobalPhone.db_path = Rails.root.join('shared/db/global_phone.json')
GlobalPhone.default_territory_name = :us
