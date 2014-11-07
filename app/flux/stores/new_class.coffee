'use strict'

# Helper Utility Methods
try Helpers = require 'util/helpers'
catch
	Helpers = {}
# Helper Utility Fallbacks
if typeof Helpers.clone isnt 'function'
	objectCreate = Object.create
	if typeof objectCreate isnt 'function'
		objectCreate = (o)->
			F = ->
			F.prototype = o
			return new F()
	Helpers.clone = (obj, _copied) ->
		# Null or Undefined
		if not obj? or typeof obj isnt 'object'
			return obj

		# Init _copied list (used internally)
		if typeof _copied is 'undefined'
			_copied = []
		else return obj if obj in _copied
		_copied.push obj

		# Native/Custom Clone Methods
		return obj.clone(true) if typeof obj.clone is 'function'
		# Array Object
		if Object::toString.call(obj) is '[object Array]'
			result = obj.slice()
			for el, idx in result
				result[idx] = @clone el, _copied
			return result
		# Date Object
		if obj instanceof Date
			return new Date(obj.getTime())
		# RegExp Object
		if obj instanceof RegExp
			flags = ''
			flags += 'g' if obj.global?
			flags += 'i' if obj.ignoreCase?
			flags += 'm' if obj.multiline?
			flags += 'y' if obj.sticky?
			return new RegExp(obj.source, flags)
		# DOM Element
		if obj.nodeType? and typeof obj.cloneNode is 'function'
			return obj.cloneNode(true)

		# Recurse
		proto = if Object.getPrototypeOf? then Object.getPrototypeOf(obj) else obj.__proto__
		proto = obj.constructor.prototype unless proto
		result = objectCreate proto
		for key, val of obj
			result[key] = @clone val, _copied
		return result
if typeof Helpers.isArray isnt 'function'
	Helpers.isArray = (obj) ->
		return true if Object::toString.call(obj) is '[object Array]'
		return false



# Static Private Methods
# Be Sure to call these methods with fn.call(this, arg1, arg2, ...) or fn.apply(this, arguments)
_init = (options)->
		# console.log '_init', options
		_validate options
		# TODO:
		# Step through actions if actions and register them
		@registerActions(options.actions) if options.actions
		@registerCallbacks(options.callbacks) if options.callbacks

		@Emitter = options.emitter
		@Dispatcher = options.dispatcher
		@Dispatcher.register (args...) ->
			_dispatcherHandler.apply(@, args)

_validate = (options) ->
	if typeof options isnt 'object'
		throw new Error "StoreClass _validate: options passed to constructor must be an object!"
	if typeof options.emitter isnt 'object'
		throw new Error "StoreClass _validate: constructor must be passed an emitter instance!"
	if typeof options.dispatcher isnt 'object'
		throw new Error "StoreClass _validate: constructor must be passed a dispatcher instance!"

_emitChanges = ->
	# TODO:
	# Emit all changes to internal value
_emitChange = (ev, val) ->
	# TODO:
	# Fire emitter with event and value

_dispatcherHandler = (args) ->
	console.log 'StoreClass _dispatcherHandler: ', args
	# TODO:
	# check against internal _actions and _callbacks to find correct callback
	# Invoke associated callbacks, passing the this context
	# If callback returns true, check for changes and emit
	# If callback returns false, don't

# TODO: METHOD GET CHANGES TO OBJ (DIFF 2 OBJS)



# StoreClass
# TODO:
# Add a history of up to 5 previous values of _value
# Add the ability to add a store to a group
#  .. Create the group if the group does not already exist
#  .. Create a global list of groups that all store instances can access
#  .. Group will allow you to listen into an entire group of stores for changes

module.exports = StoreClass = class StoreClass
	_value: undefined
	_actions: undefined # object map of actions to methods
	_actionKeys: undefined # array of action names, used as convenience by _dispatchHandler
	_callbacks: undefined # list of callbacks

	Emitter: undefined
	Dispatcher: undefined

	# Class Constructor
	# options =
	# 	actions:
	# 		"action1": "function1"
	# 		"action2": "function2"
	# 	callbacks:
	# 		"function1": Fn()
	# 		"function2": Fn()
	# 	emitter: Emitter Instance
	# 	dispatcher: Dispatcher Instance
	constructor: (options = {}) ->
		_init.call @, options

	# Registeration Methods
	registerActions: (actionsObj) ->
		# Validate actionsObj is an object
		if typeof actionsObj isnt 'object'
			throw new Error 'StoreClass registerActions: parameter passed in must be an object!'
		# Merge with internal actions list
		for key, val of actionsObj
			if actionsObj.hasOwnProperty? and not actionsObj.hasOwnProperty key
				continue
			# Validate actionObj key/value pairs
			if (typeof val isnt 'string') and (not Helpers.isArray(val))
				throw new Error 'StoreClass registerActions: property ' + key + ' must contain a string or array of strings!'
			else if (Helpers.isArray(val))
				for element in val
					if typeof element isnt 'string'
						throw new Error 'StoreClass registerActions: array property ' + key + ' must be a list of strings!'
			@registerAction key, val
		# console.log 'StoreClass registerActions: ', @_actions
		@
	registerAction: (actionName, callbackName) ->
		# console.log 'StoreClass registerAction: ', actionName, callbackName
		# Init _actions property
		@_actions = {} unless @_actions
		@_actions[actionName] = [] unless @_actions[actionName]
		# Assign callback string
		if (typeof callbackName is 'string')
			@_actions[actionName].push callbackName if !(callbackName in @_actions[actionName])
		# Assign callback array
		else if Helpers.isArray callbackName
			for name in callbackName
				if typeof name isnt 'string'
					err = 'StoreClass registerAction: every element of callback array assigned to ' + actionName + ' must be a string!'
					throw new Error err
				@_actions[actionName].push(name) if !(name in @_actions[actionName])
		# Error: not a string or array
		else
			err = 'StoreClass registerAction: callback name assigned to ' + actionName + ' must be a string or array of strings!'
			throw new Error err
		@
	registerCallbacks: (callbacksObj) ->
		# Validate callbacksObj is an object
		if typeof callbacksObj isnt 'object'
			throw new Error 'StoreClass registerCallbacks: parameter passed in must be an object!'
		# Merge with internal callbacks list
		for key, val of callbacksObj
			if callbacksObj.hasOwnProperty? and not callbacksObj.hasOwnProperty key
				continue
			if typeof val isnt 'function'
				throw new Error 'StoreClass registerCallbacks: property ' + key + ' of parameter must be a function!'
			@registerCallback key, val
		# console.log 'StoreClass registerCallbacks: ', @_callbacks
		@
	registerCallback: (callbackName, callbackFn) ->
		@_callbacks = {} unless @_callbacks
		if typeof callbackName isnt 'string'
			throw new Error 'StoreClass registerCallback: callbackName passed to this method must be a string!'
		if typeof callbackFn isnt 'function'
			throw new Error 'StoreClass registerCallback: callbackFn passed to this method must be a function!'
		@_callbacks[callbackName] = callbackFn
		@

	# Unregister Methods
	unregisterActions: (actionsObj) ->
		# TODO:
		# ...
	unregisterAction: (actionName, callbackName) ->
		# TODO:
		# If no callbackName, unregister all callbacks
	unregisterCallbacks: (callbacksObj) ->
		# TODO:
		# ...
	unregisterCallback: (name, callback) ->
		# TODO:
		# ...

	# Get Value, Bind and Unbind Change Methods
	get: (key) ->
		# TODO:
		# Retrieve value if no key
		# Parse key, return key value
		# Allow nested keys
	on: (ev, callback) ->
		# TODO:
		# Bind callbacks to events
		# events: change
		# Allow to listen to change on a specific property
		# Wrap the callback with a gate against events
		# Store wrapped callback in a list
		# Register wrapped callback with Emitter
	off: (ev, callback) ->
		# TODO:
		# Unbind callbacks from events
		# events: change
		# Allow to unbind a change listener from a specific property