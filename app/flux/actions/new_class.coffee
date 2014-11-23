'use strict'

# Static Private Methods
# Be Sure to call these methods with fn.call(this, arg1, arg2, ...) or fn.apply(this, arguments)
_init = (options) ->
	console.log '_init', options

# Validation Methods
_validate = (options) ->
	# ...

# Action Class
# Class Constructor
# options =
# 	dispatcher: Dispatcher Instance
# 	actions:
# 		action1: action1Handler
# 		action2: action2Value

# TODO:
# handlers must return a value
module.exports = ActionClass = class ActionClass

	_initialized: false
	_disposed: false

	Dispatcher: undefined

	constructor: (options = {}) ->
		@initialize options
	initialize: (options = {}) ->
		_init.call @, options
		@_disposed = false
		@_initialized = true

	register: (actionId, val) ->
		# ...
	unregister: (actionId) ->
		# ...

	dispose: ->
		# ...