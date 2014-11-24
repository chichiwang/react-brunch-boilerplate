'use strict'

# Helper Utility Methods
# Note: Change the require path to access the global framework object when modularizing
try type = require('util/helpers').type
catch
	classToType = do ->
		objectMap = {}
		for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
			objectMap["[object " + name + "]"] = name.toLowerCase()
		objectMap
	type = (obj) ->
			return 'undefined' if typeof obj is 'undefined'
			strType = Object::toString.call(obj)
			classToType[strType] or "object"

# Static Private Methods
# Be Sure to call these methods with fn.call(this, arg1, arg2, ...) or fn.apply(this, arguments)
_init = (options) ->
	console.log '_init', options
	_validate options

# Validation Methods
_validate = (options) ->
	if type(options) isnt 'object'
		throw new Error 'ActionClass _validate: options passed to constructor must be an object!'
	if type(options.dispatcher) isnt 'object'
		throw new Error 'ActionClass _validate: constructor must be passed a dispatcher instance!'
	if type(options.dispatcher.register) isnt 'function'
		throw new Error 'ActionClass _validate: dispatcher passed in must have a method "register"!'

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

	call: (actionId, args...) ->
		# ...

	dispose: ->
		# ...