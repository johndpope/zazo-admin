'use strict'

class Zazo.Visualization.Calculate

  store = {}

  normalizeValue: (val, storeKey, min, max) ->
    return min unless store[storeKey]
    val / store[storeKey] * (max - min) + min

  findCollectionMax: (collection, storeKey, calculateMax) ->
    store[storeKey] = _(collection).reduce (max, value) ->
      current = calculateMax value
      if current > max then current else max
    , 0
