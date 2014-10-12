'use strict'

ActionsClass = require 'flux/actions/class'

actionsSingleton = actionsSingleton or new ActionsClass require 'dispatcher'
module.exports = actionsSingleton