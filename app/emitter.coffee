'use strict'

ns = require 'util/namespace'
ActionsClass = require 'flux/actions/class'

ns.changeEmitter = ns.changeEmitter or new ActionsClass require 'pubsub'
module.exports = ns.changeEmitter