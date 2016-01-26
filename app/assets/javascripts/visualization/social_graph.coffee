'use strict'

class Zazo.Visualization.SocialGraph

  container = undefined
  network   = undefined
  nodes     = undefined
  edges     = undefined
  userInfo  = undefined
  calculate = undefined
  settings  = undefined
  data      = {}

  options   =
    nodes:
      shape: 'dot'
    edges:
      font:
        strokeColor: '#AEAEAE'
        size: 10
      color:
        color: '#AEAEAE'

  tmp =
    maxMsgCount: 0

  settings:
    element: 'visualization'
    maxEdgeWidth: 10
    minEdgeWidth: 1
    maxNodeSize:  50
    minNodeSize:  20
    statusColor:
      initialized: '#EA9999'
      invited:     '#EA9999'
      registered:  '#FFE599'
      verified:    '#6D9EEB'
      active:      '#93C47D'
      else:        '#C7C7C7'

  constructor: ->

  init: ->
    container = document.getElementById @settings.element
    calculate = new Zazo.Visualization.Calculate()
    settings  = new Zazo.Visualization.Settings container

    data =
      target:      JSON.parse container.getAttribute 'data-target'
      users:       JSON.parse container.getAttribute 'data-users'
      connections: JSON.parse container.getAttribute 'data-connections'

    @buildNodes()
    @buildEdges()
    @buildNetwork()
    @initEvents()
    @showBlocks()

  showBlocks: ->
    userInfo = new Zazo.Visualization.UserInfo container
    legend = new Zazo.Visualization.LegendColor container

    settings.show()
    userInfo.show()
    legend.show @settings.statusColor

  buildNodes: ->
    calculate.findCollectionMax data.users, 'users', (user) ->
      user.average_messages_per_day

    nodes = new vis.DataSet _(data.users).map (user) =>
      id: user.id
      label: @getLabelByUser user
      size:  @calculateNodeSize user
      color: @colorByStatus user

  buildEdges: ->
    calculate.findCollectionMax data.connections, 'connections', (conn) ->
      conn.incoming_count + conn.outgoing_count

    prepare = []
    _(data.connections).each (conn) =>
      if conn.creator_id != conn.target_id
        prepare.push @paramsByConnection conn
    edges = new vis.DataSet prepare

  buildNetwork: ->
    network = new vis.Network container, {
      nodes: nodes
      edges: edges
    }, options

  initEvents: ->
    network.on 'select', (e) =>
      if e.nodes.length == 1
        userInfo.showUser @getUserById(e.nodes[0]), e.pointer.DOM
      else
        userInfo.hide()

    network.on 'hold', (e) =>
      userInfo.hide()
      if e.nodes.length == 1
        @visualizeAnotherUser e.nodes[0]

  colorByStatus: (user) ->
    color = @settings.statusColor[user.status]
    color = @settings.statusColor.else unless color
    border: 'black'
    background: color

  paramsByConnection: (conn) ->
    totalMessages = conn.incoming_count + conn.outgoing_count

    from: conn.creator_id
    to: conn.target_id
    label: if settings.get().between then totalMessages else ''

    width: @calculateEdgeWidth totalMessages

  calculateEdgeWidth: (totalMessages) ->
    calculate.normalizeValue totalMessages,
      'connections', @settings.minEdgeWidth, @settings.maxEdgeWidth

  calculateNodeSize: (user) ->
    calculate.normalizeValue user.average_messages_per_day,
      'users', @settings.minNodeSize, @settings.maxNodeSize

  getUserById: (id) ->
    _(data.users).find (u) -> u.id == parseInt id

  getLabelByUser: (user) ->
    "#{user.name}\n
    #{user.device_platform}
    cc:#{user.connection_counts}
    mt:#{user.total_messages}
    mm:#{user.messages_by_last_month}
    mw:#{user.messages_by_last_week}"


  visualizeAnotherUser: (userId) ->
    href = window.location.href.split('?')[0]
    window.location = href.replace /\/[0-9]+\//, "/#{userId}/"
