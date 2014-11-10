'use strict'

# Helper Utility Methods
try isArray = require('util/helpers').isArray
catch
	isArray = (obj) ->
		return true if Object::toString.call(obj) is '[object Array]'
		return false

# TODO:
# Store-specific (immutable) clone method
# Args: obj # Object to clone
# If obj is an object, set all properties to writable: false
# If array, copy all elements to new array - if object recurse
# If any other type of value return it


# Static Private Methods
# Be Sure to call these methods with fn.call(this, arg1, arg2, ...) or fn.apply(this, arguments)
_validate = (options) ->
	if typeof options isnt 'object'
		throw new Error "StoreClass _validate: options passed to constructor must be an object!"
	if typeof options.dispatcher isnt 'object'
		throw new Error "StoreClass _validate: constructor must be passed a dispatcher instance!"
	# TODO: Validate options.dispatcher has a method .register(value)
_validateActions = (fnName, actionsMap) ->
	# Validate actionsMap is an object
	isObject = typeof actionsMap is 'object'
	isNull = actionsMap is null
	if (not isObject) or (isArray actionsMap) or isNull
		throw new Error 'StoreClass ' + fnName + ': parameter passed in must be an object!'
	# Validate actionsMap properties
	for key, val of actionsMap
		if actionsMap.hasOwnProperty? and not actionsMap.hasOwnProperty key
			continue
		# Validate actionObj key/value pairs
		if (typeof val isnt 'string') and (typeof val isnt 'undefined') and (not isArray val)
			throw new Error 'StoreClass registerActions: property ' + key + ' must contain a string or array of strings!'
		else if (isArray val)
			for element in val
				if typeof element isnt 'string'
					throw new Error 'StoreClass registerActions: array property ' + key + ' must be a list of strings!'
_validateCallbacks = (fnName, callbacksMap) ->
	# Validate callbacksMap is an object
	isObject = typeof callbacksMap is 'object'
	isNull = callbacksMap is null
	if (not isObject) or (isArray callbacksMap) or isNull
		throw new Error 'StoreClass ' + fnName + ': parameter passed in must be an object!'
	for key, val of callbacksMap
		if callbacksMap.hasOwnProperty? and not callbacksMap.hasOwnProperty key
			continue
		if typeof val isnt 'function'
			throw new Error 'StoreClass ' + fnName + ': property ' + key + ' of parameter must be a function!'

_init = (options)->
		# console.log '_init', options
		_validate options
		# TODO:
		# Step through actions if actions and register them
		@registerActions(options.actions) if options.actions
		@registerCallbacks(options.callbacks) if options.callbacks

		@Emitter = options.emitter
		@Dispatcher = options.dispatcher
		# @Dispatcher.register (args...) ->
		# 	_dispatcherHandler.apply(@, args)

_removeCallbackFromAction = (actionId, callbackId) ->
	if @_actions[actionId].indexOf(callbackId) < 0
		console.warn 'StoreClass unregisterAction: no callback ' + callbackId + ' registered to action ' + actionId + '!'
		return false
	else
		@_actions[actionId].splice(@_actions[actionId].indexOf(callbackId), 1)
		return true
_cleanActionsAndCallbacks = ->
	# To be called on unregister of actions or callbacks
	# Iterate through all registered callback names, make sure all callback functions still exist
	# Remove any callback functions no longer registered to any actions
	#
	# Iterate through registered actions, make sure all callback names still exist in callbacks list
	# Remove any callback names from registered actions that no longer link to callbacks
_cleanupCallbacks = ->
	callbacks = []
	for callback of @_callbacks
		callbackReferenced = false
		for action, cbs of @_actions
			callbackReferenced = true if cbs.indexOf(callback) >= 0
		delete @_callbacks[callback] if !callbackReferenced
# _cleanupActions = ->
# 	callbacks = []
# 	for callback of @_callbacks
# 		callbackReferenced = false
# 		for action, cbs of @_actions
# 			callbackReferenced = true if cbs.indexOf(callback) >= 0
# 		callbacks.push(callback) if !callbackReferenced

# TODO:
# Emit changes just cycles through store callbacks and fires them off
# No need for an emitter utility/instance
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
	_callbacks: undefined # list of callbacks

	# Remove this: use .hasOwnProperty on _actions instead
	_actionKeys: undefined # array of action names, used as convenience by _dispatchHandler

	Dispatcher: undefined

	# Class Constructor
	# options =
	# 	actions:
	# 		"action1": "function1"
	# 		"action2": "function2"
	# 	callbacks:
	# 		"function1": Fn()
	# 		"function2": Fn()
	# 	dispatcher: Dispatcher Instance
	constructor: (options = {}) ->
		_init.call @, options

	# Registration Methods
	registerActions: (actionsMap) ->
		_validateActions 'registerActions', actionsMap
		# Merge with internal actions list
		for key, val of actionsMap
			if typeof val is 'undefined'
				throw new Error 'StoreClass registerActions: property ' + key + ' must be a string or array of strings!'
			@registerAction key, val
		@
	registerAction: (actionId, callbackId) ->
		if typeof actionId isnt 'string'
			throw new Error 'StoreClass registerAction: first argument (actionId) must be a string!'
		if (typeof callbackId isnt 'string') and (!isArray callbackId)
			throw new Error 'StoreClass registerAction: second argument (callbackId) must be a string or an array of strings!'
		# Init _actions property
		@_actions = {} unless @_actions
		@_actions[actionId] = [] unless @_actions[actionId]
		# Assign callback string(s)
		if (typeof callbackId is 'string')
			if callbackId is '*'
				throw new Error 'StoreClass registerAction: invalid callback id assigned to action ' + actionId + '!'
			@_actions[actionId].push callbackId if !(callbackId in @_actions[actionId])
		else if isArray callbackId
			for name in callbackId
				if typeof name isnt 'string'
					throw new Error 'StoreClass registerAction: every element of callback array assigned to ' + actionId + ' must be a string!'
				@_actions[actionId].push(name) if !(name in @_actions[actionId])
		@
	registerCallbacks: (callbacksMap) ->
		_validateCallbacks 'registerCallbacks', callbacksMap
		# Merge with internal callbacks list
		for key, val of callbacksMap
			if callbacksMap.hasOwnProperty? and not callbacksMap.hasOwnProperty key
				continue
			@registerCallback key, val
		@
	registerCallback: (callbackId, callbackFn) ->
		@_callbacks = {} unless @_callbacks
		if typeof callbackId isnt 'string'
			throw new Error 'StoreClass registerCallback: callbackId passed to this method must be a string!'
		if typeof callbackFn isnt 'function'
			throw new Error 'StoreClass registerCallback: callbackFn passed to this method must be a function!'
		@_callbacks[callbackId] = callbackFn
		@

	# Unregistration Methods
	unregisterActions: (actionsMap) ->
		_validateActions 'unregisterActions', actionsMap
		# Remove from internal actions list
		for key, val of actionsMap
			@unregisterAction key, val
		@
	unregisterAction: (actionId, callbackId) ->
		if typeof actionId isnt 'string'
			throw new Error 'StoreClass unegisterAction: first argument (actionId) must be a string!'
		if typeof @_actions is 'undefined'
			throw new Error 'StoreClass unregisterAction: there are no currently defined actions!'
		else if typeof @_actions[actionId] is 'undefined'
			throw new Error 'StoreClass unregisterAction: there are no callbacks registered to action ' + actionId + '!'
		# Remove callback string(s)
		callbacksRemoved = []
		if (typeof callbackId is 'string') and (callbackId isnt '*')
			_removeCallbackFromAction.call @, actionId, callbackId
			callbacksRemoved.push callbackId
		else if isArray callbackId
			for name in callbackId
				callbacksRemoved.push(name) if _removeCallbackFromAction.call(@, actionId, name)
		else if (typeof callbackId is 'undefined') or (callbackId is '*')
			callbacksRemoved = @_actions[actionId].concat()
			@_actions[actionId].length = 0
		else
			throw new Error 'StoreClass unregisterAction: optional second argument callbackId must be a string or array of strings!'
		delete @_actions[actionId] if @_actions[actionId].length is 0
		_cleanupCallbacks.call @
		@
	unregisterCallbacks: (callbacksList) ->
		if not isArray callbacksList
			throw new Error 'StoreClass unregisterCallbacks: parameter passed in must be an array of callback ids or functions!'
		# Remove from internal callbacks list
		for cb in callbacksList
			if (typeof cb isnt 'string') and (typeof cb isnt 'function')
				throw new Error 'StoreClass unregisterCallbacks: list of callbacks to unregister must only contain string ids and functions!'
			@unregisterCallback cb
		@
	unregisterCallback: (callback) ->
		if typeof @_callbacks is 'undefined'
			throw new Error 'StoreClass unregisterCallback: there are no currently defined callbacks!'
		if typeof callback is 'string'
			if typeof @_callbacks[callback] is 'undefined'
				console.warn 'StoreClass unregisterCallback: there is no callback with the id ' + callback + '!'
			else
				delete @_callbacks[callback]
		else if typeof callback is 'function'
			found = false
			keys = []
			for key, val of @_callbacks
				if callback is val
					found = true
					keys.push key
			if not found
				console.warn 'StoreClass unregisterCallback: function passed in does not match any registered callbacks!'
			else
				for key in keys
					delete @_callbacks[key]
		else
			throw new Error 'StoreClass unregisterCallback: parameter passed in must be a callback id string or a function!'
			# TODO: Call action/callback cleanup method
		@

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