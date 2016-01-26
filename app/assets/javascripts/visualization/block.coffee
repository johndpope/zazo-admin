'use strict'

class Zazo.Visualization.Block

  constructor: (@parent) ->
    @template  = _.template @template

  show: ->
    @container = document.createElement 'div'
    @container.setAttribute 'id', @settings.element
    @parent.appendChild @container
