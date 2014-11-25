'use strict'

# Module dependencies
StoreClass = require 'arc/store/class'
Dispatcher = require 'dispatcher'
Const = require './const'

# Dispatch handlers
setValue = (v) ->
	@value = v

# Instantiate store class
RouterStore = new StoreClass
	dispatcher: Dispatcher
	initial:
		routeId: undefined
		path: undefined
		prevState: undefined
		curState: undefined
		transition: undefined
		transitioned: true

# Register action handlers
RouterStore.registerAction Const.SET_VALUE, setValue

module.exports = RouterStore