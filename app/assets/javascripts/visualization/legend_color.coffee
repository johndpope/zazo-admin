'use strict'

class Zazo.Visualization.LegendColor extends Zazo.Visualization.Block

  template: "
    <div
      class='legend-item'
      style='background: <%= color %>'>
      <%= text %>
    </div>
  "

  settings:
    element: 'legend-info'

  show: (colors) ->
    super
    memo = ''
    for key in Object.keys colors
      memo += @template {
        text: key
        color: colors[key]
      } if key != 'else'
    @container.innerHTML = memo
