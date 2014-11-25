# Module dependencies
ActionsClass = require 'arc/actions/class'
Dispatcher = require 'dispatcher'
Const = require './const'

# Action methods
setValue = (v) ->
	return v

# Instantiate actions class
RouterActions = new ActionsClass
	dispatcher: Dispatcher
# Register action methods
RouterActions.register Const.SET_VALUE, setValue

module.exports = RouterActions