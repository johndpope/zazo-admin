class UserVisualizationDataQuery::ConnectionsAndUsersInDepthQuery
  attr_reader :users

  def initialize(user, depth)
    @user  = user
    @depth = depth
    @users = []
    @connections = []
  end

  def execute
    get_and_store_users @user.id, @user.mkey,
                        get_and_store_connections(@user.id)
    depth = @depth - 1
    while depth > 0
      accumulator.each do |user|
        get_and_store_users user[:id], user[:mkey],
                            get_and_store_connections(user[:id])
      end
      depth -= 1
    end
  end

  def connections
    @connections.each_with_object([]) do |nested, memo|
      nested.each { |c| memo << c }
    end.uniq
  end

  def stretched_users
    @users.each_with_object([]) do |pack, memo|
      memo << pack[:target]
      pack[:friends].each { |u| memo << u }
    end.uniq
  end

  private

  def get_and_store_connections(user_id)
    connections = Connection.for_user_id(user_id).includes(:creator).includes(:target)
    @connections << connections
    connections
  end

  def get_and_store_users(user_id, user_mkey, connections)
    users = get_users_ids({ id: user_id, mkey: user_mkey }, connections)
    accumulate_users users
    @users << users
  end

  def accumulate_users(ids)
    @accumulator ||= []
    @accumulator += ids[:friends]
  end

  def accumulator
    copy = @accumulator
    @accumulator = []
    copy
  end

  def get_users_ids(user_data, connections)
    users_ids = connections.each_with_object([]) do |conn, memo|
      memo << { id: conn.target_id,  mkey: conn.target.event_id }  if user_data[:id] != conn.target_id
      memo << { id: conn.creator_id, mkey: conn.creator.event_id } if user_data[:id] != conn.creator_id
    end.uniq
    {
      target: { id: user_data[:id], mkey: user_data[:mkey] },
      friends: users_ids
    }
  end
end
