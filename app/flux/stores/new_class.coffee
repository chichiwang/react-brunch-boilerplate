'use strict'

# Helper Utility Methods
try isArray = require('util/helpers').isArray
catch
	isArray = (obj) ->
		return true if Object::toString.call(obj) is '[object Array]'
		return false

# TODO:
# Store-specific (immutable) clone class
# Args: obj # Object to clone
# If obj is an object, set all properties to writable: false
# If array, copy all elements to new array - if object recurse
# If any other type of value return it


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
	# TODO: Validate options.emitter has a method .emit(action, value)
	if typeof options.dispatcher isnt 'object'
		throw new Error "StoreClass _validate: constructor must be passed a dispatcher instance!"
	# TODO: Validate options.dispatcher has a method .register(action, value)
	# See if this is even possible if the dispatcher event handler has to accept 2 args
	#   given the FB dispatcher's functionality of only passing a single value to all registered callbacks
	#
	# Arc.Dispatcher?
	# Maybe create a wrapper around the FB dispatcher class
	# It would accept 2 values, convert them into a single object and dispatch it
	# Only register a single internal callback, handle callback execution internally, mapping to actions

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
	_value: undefined # mutable internal value
	value: undefined # store-clone of _value which is set to be immutable
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
		isObject = typeof actionsObj is 'object'
		isNull = actionsObj is null
		if (not isObject) or (isArray actionsObj) or isNull
			throw new Error 'StoreClass registerActions: parameter passed in must be an object!'
		# Merge with internal actions list
		for key, val of actionsObj
			if actionsObj.hasOwnProperty? and not actionsObj.hasOwnProperty key
				continue
			# Validate actionObj key/value pairs
			if (typeof val isnt 'string') and (not isArray(val))
				throw new Error 'StoreClass registerActions: property ' + key + ' must contain a string or array of strings!'
			else if (isArray(val))
				for element in val
					if typeof element isnt 'string'
						throw new Error 'StoreClass registerActions: array property ' + key + ' must be a list of strings!'
			@registerAction key, val
		@
	registerAction: (actionName, callbackName) ->
		# Init _actions property
		@_actions = {} unless @_actions
		@_actions[actionName] = [] unless @_actions[actionName]
		# Assign callback string
		if (typeof callbackName is 'string')
			@_actions[actionName].push callbackName if !(callbackName in @_actions[actionName])
		# Assign callback array
		else if isArray callbackName
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