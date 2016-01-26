class UserVisualizationDataQuery::MessagesCountBetweenUsersQuery
  def initialize(users_packs)
    @users = prepare_users users_packs
  end

  def execute
    EventsApi.new.metric_data :messages_count_between_users,
                              users_ids: @users
  end

  private

  def prepare_users(packs)
    packs.each_with_object({}) do |user_pack, memo|
      friends = user_pack[:friends].map { |f| f[:mkey] }
      memo[user_pack[:target][:mkey]] = friends
    end
  end
end
