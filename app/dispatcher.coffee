'use strict'

ns = require 'util/namespace'
DispatcherClass = require 'flux/dispatcher/class'

ns.dispatcher = ns.dispatcher or new DispatcherClass()
ns.dispatcher._id_ = 'DISPATCHER'
module.exports = ns.dispatcher