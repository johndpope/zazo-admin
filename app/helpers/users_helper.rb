module UsersHelper
  def render_event(user, event)
    render 'event', user: user, event: event
  end

  def visualize_social_graph(user, settings = {})
    query = UserVisualizationDataQuery.new user, settings
    query.execute
    data = {
      target:      (query.target).as_json,
      users:       (query.users).as_json,
      connections: (query.connections).as_json,
      settings:    (query.settings).as_json
    }
    content_tag :div, '', id: 'visualization', data: data
  end
end
