class Mixpanel::Data::Events::Base
  attr_reader :user, :users, :time_from, :time_to

  def initialize(user: nil, users: nil, time_from: nil, time_to: nil)
    @time_from, @time_to = [time_from, time_to]
    @user  = user
    @users = users unless user
  end

  def desc
    self.class.description
  end

  def scope
    @scope ||= wrap_restrictions(desc[:default_scope].call)
  end

  def data
    @data ||= events_data_by_scope
  end

  private

  def events_data_by_scope
    scope.map do |e|
      { original_event: e,
        user: desc[:user].call(e),
        data: desc[:data].call(e).merge('time' => e.triggered_at.to_i) }
    end
  end

  def wrap_restrictions(scope)
    scope = scope.since(time_from) if time_from
    scope = scope.till(time_to) if time_to
    scope = reduce_scope_by(scope, desc[:user_scope_method], user.try(:mkey))
    reduce_scope_by(scope, desc[:users_scope_method], users_mkeys)
  end

  def reduce_scope_by(scope, method, params)
    return scope unless method && params
    if respond_to?(method, true)
      send(method, scope, params)
    else
      scope.send(method, params)
    end
  end

  def users_mkeys
    users && users.map(&:mkey)
  end
end
