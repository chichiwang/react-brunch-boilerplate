'use strict'

DispatcherClass = require 'flux/dispatcher/class'

pubsubSingleton = pubsubSingleton or new DispatcherClass()
pubsubSingleton._id_ = 'PUBSUB'
module.exports = pubsubSingleton