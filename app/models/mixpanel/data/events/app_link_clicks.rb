class Mixpanel::Data::Events::AppLinkClicks < Mixpanel::Data::Events::Base
  def self.description
    {
      name: :app_link_click,
      default_scope: -> { Event.app_link_clicks },
      users_scope_method: :by_specific_inviters,
      user: -> (e) {
        e.data['link_key'] == 'c' ?
          e.data['connection_creator_mkey'] : e.data['inviter_mkey']
      },
      data: -> (e) {
        base = { 'link_key' => e.data['link_key'],
                 'platform' => e.data['platform'] }
        if e.data['link_key'] == 'c'
          base.merge 'inviter_mkey' => e.data['connection_creator_mkey'],
                     'target_mkey'  => e.data['connection_target_mkey']
        else
          base.merge 'inviter_mkey' => e.data['inviter_mkey']
        end
      }
    }
  end

  private

  def by_specific_inviters(scope, mkeys)
    condition = <<-SQL
      (data->>'link_key' = 'l' AND data->>'inviter_mkey' IN (?)) OR
      (data->>'link_key' = 'c' AND data->>'connection_creator_mkey' IN (?))
    SQL
    scope.where condition, mkeys, mkeys
  end
end
