'use strict'

module.exports = Util = 
  clone: (obj) ->
    return obj  if null is obj or "object" isnt typeof obj
    copy = obj.constructor()
    for attr of obj
      copy[attr] = obj[attr]  if obj.hasOwnProperty(attr)
    copy