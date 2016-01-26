class UserVisualizationDataQuery::UsersWithConnectionCountsQuery
  def initialize(users_ids)
    @users_ids = users_ids.map { |u| u[:id] }
  end

  def execute
    query = <<-SQL
      SELECT users.*, COUNT(connections.id) AS connection_counts
      FROM users
      INNER JOIN connections ON
        users.id = connections.target_id OR
        users.id = connections.creator_id
      WHERE users.id IN ?
      GROUP BY users.id
    SQL
    User.find_by_sql [query, @users_ids]
  end
end
