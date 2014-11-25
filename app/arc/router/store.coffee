'use strict'

# Module dependencies
StoreClass = require 'arc/store/class'
Dispatcher = require 'dispatcher'
Constant = require './const'

# Dispatch handlers
setValue = (v) ->
	@value = v

# Prep actions callbacks
actionsCallbacks = {}
actionsCallbacks[Constant.SET_VALUE] = setValue

# Instantiate store class
RouterStore = new StoreClass
	dispatcher: Dispatcher
	actions: actionsCallbacks
	initial:
		routeId: undefined
		path: undefined
		prevState: undefined
		curState: undefined
		transition: undefined
		transitioned: true

module.exports = RouterStore