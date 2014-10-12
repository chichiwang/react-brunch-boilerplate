'use strict'

ActionsClass = require 'flux/actions/class'

emitterSingleton = emitterSingleton or new ActionsClass require 'pubsub'
module.exports = emitterSingleton