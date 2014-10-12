'use strict'

DispatcherClass = require 'flux/dispatcher/class'
dispatcherSingleton = dispatcherSingleton or new DispatcherClass()
dispatcherSingleton._id_ = 'DISPATCHER'

module.exports = dispatcherSingleton