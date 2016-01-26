class UserVisualizationDataQuery
  ALLOWED_SETTINGS = [:depth, :between]

  attr_reader :target, :connections, :users, :settings

  def initialize(user, settings = {})
    @user     = user
    @settings = prepare_settings settings
    @in_depth = ConnectionsAndUsersInDepthQuery.new user, @settings[:depth]
  end

  def execute
    @in_depth.execute
    @connections = serialized_connections
    @users       = serialized_users
    @target = @users.find { |u| u[:id] == @user.id }
  end

  private

  def serialized_users
    users = UsersWithConnectionCountsQuery.new(@in_depth.stretched_users).execute
    users = [@user] if users.empty?
    messages_by_month = AverageMessagesByPeriodQuery.new(users).execute
    messages_by_week  = AverageMessagesByPeriodQuery.new(users, since: Date.today - 1.week).execute
    total_messages    = AverageMessagesByPeriodQuery.new(users).total.execute
    UsersVisualizationSerializer.new(users, month: messages_by_month,
                                     week: messages_by_week, total: total_messages).serialize
  end

  def serialized_connections
    counts = []
    counts = MessagesCountBetweenUsersQuery.new(@in_depth.users).execute if @settings[:between]
    ConnectionsVisualizationSerializer.new(@in_depth.connections, counts: counts).serialize
  end

  def prepare_settings(settings)
    {
      depth: settings[:depth] ? settings[:depth].to_i : 1,
      between: settings[:between] ? ActiveRecord::Type::Boolean.new.type_cast_from_user(settings[:between]) : true
    }
  end
end
