# Module dependencies
ActionsClass = require 'arc/actions/class'
Dispatcher = require 'dispatcher'
Constant = require './const'

# Action handlers
setValue = (v) ->
	return v

# Prep actionsOptions
actionsOptions = {}
actionsOptions[Constant.SET_VALUE] = setValue

# Instantiate actions class
SiteActions = new ActionsClass
	dispatcher: Dispatcher
	actions: actionsOptions

module.exports = SiteActions