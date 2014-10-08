'use strict'

ns = require 'util/namespace'
DispatcherClass = require 'flux/dispatcher/class'

ns.pubsub = ns.pubsub or new DispatcherClass()
ns.pubsub._id_ = 'PUBSUB'
module.exports = ns.pubsub