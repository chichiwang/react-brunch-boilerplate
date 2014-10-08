'use strict'

ns = require 'util/namespace'
ActionsClass = require 'flux/actions/class'

ns.actions = ns.actions or new ActionsClass require 'dispatcher'
module.exports = ns.actions