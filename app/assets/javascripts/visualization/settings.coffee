'use strict'

class Zazo.Visualization.Settings extends Zazo.Visualization.Block

  settings = {}

  template: "
    <select class='x-depth'>
      <option disabled>Depth</option>
      <option <%= depth == 1 ? 'selected' : '' %> value='1'>1</option>
      <option <%= depth == 2 ? 'selected' : '' %> value='2'>2</option>
      <option <%= depth == 3 ? 'selected' : '' %> value='3'>3</option>
    </select>
    <br>
    <input class='x-between' type='checkbox'
    <%= between ? 'checked' : '' %>> Between counts
  "

  settings:
    element: 'visualization-settings'

  constructor: (parent) ->
    super
    settings = JSON.parse parent.getAttribute 'data-settings'

  show: ->
    super
    @container.innerHTML = @template settings
    @initCallbacks()

  initCallbacks: ->
    for key in Object.keys settings
      element = @container.querySelectorAll(".x-#{key}")[0]
      element.onchange = ((key, element) ->
        settings[key] = element[@getKeyByElement element]
        @applySettings()
      ).bind(@, key, element)

  applySettings: ->
    params = _(Object.keys settings).reduce (memo, key) ->
      memo += "#{key}=#{settings[key]}&"
    , '?'
    window.location = window.location.href.split('?')[0] + params.slice(0, -1)

  getKeyByElement: (element) ->
    if element.type == 'checkbox'
     'checked'
    else
      'value'

  get: ->
    settings
