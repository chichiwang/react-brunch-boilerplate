'use strict'

# Helper Utility Methods
try isArray = require('util/helpers').isArray
catch
	isArray = (obj) ->
		return true if Object::toString.call(obj) is '[object Array]'
		return false

# Deep diff two objects
# Return the keys diff between obj1 and obj2
# Borrowed heavily from http://stackoverflow.com/a/1144249/1161897
# TODO: store must check against each diff returned to see if the chain exists in the full chain string
_diffObjects = (obj1, obj2) ->
	allArgsAreObjects = true
	for arg in arguments
		if !(Object::toString.call(arg) is '[object Object]')
			allArgsAreObjects = false
	if (not allArgsAreObjects) or (arguments.length isnt 2)
		throw new Error 'StoreClass _diffObjects: must be passed 2 objects to diff'

	leftChain = []
	rightChain = []
	keysChanged = []
	currKeyChain = []
	keyChain = ""

	updateKeyChain = ->
		keyChain = currKeyChain.join '.'
	addToKeysChanged = (key) ->
		updateKeyChain()
		if typeof key is 'string'
			if keyChain.length > 0
				keysChanged.push keyChain + '.' + key
			else
				keysChanged.push key
		else if typeof key is 'undefined'
			keysChanged.push keyChain if keyChain.length > 0

	compare = (x, y) ->
		# NaN === NaN returns false
		# isNan(undefined) returns true
		# isNaN will throw an error on objects created via Object.create()
		try xNaN = isNaN(x)
		catch
			xNaN = false
		try yNaN = isNaN(y)
		catch
			yNaN = false
		if xNaN and yNaN and (typeof x is 'number') and (typeof y is 'number')
			return true
		# Compare primitives and functions
		# Check if both arguments link to the same object
		# Especially useful on step when comparing prototypes
		return true if x is y
		# Works in case when functions are created in constructor.
		# Comparing dates is a common scenario. Another built-ins?
		# We can even handle functions passed across iframes
		bothFns = typeof x is 'function' and typeof y is 'function'
		bothDates = x instanceof Date and y instanceof Date
		bothRegExp = x instanceof RegExp and y instanceof RegExp
		bothStrs = x instanceof String and y instanceof String
		bothNums = x instanceof Number and y instanceof Number
		if bothFns or bothDates or bothRegExp or bothStrs or bothNums
			if not (Object::toString.call(x) is Object::toString.call(y))
				addToKeysChanged()
				return false
			else
				return true
		# At last checking prototypes as good a we can
		if not (x instanceof Object and y instanceof Object)
			addToKeysChanged()
			return false
		if x.isPrototypeOf(y) or y.isPrototypeOf(x)
			addToKeysChanged()	
			return false
		if x.constructor isnt y.constructor
			addToKeysChanged()
			return false
		if x.prototype isnt y.prototype
			addToKeysChanged()
			return false
		# Check for infinitive linking loops
		if (leftChain.indexOf(x) > -1) or (rightChain.indexOf(y) > -1)
			console.warn 'StoreClass _diffObjects: self reference found in object - aborting diff!'
			addToKeysChanged()
			return false
		# Quick checking of one object beeing a subset of another
		# todo: cache the structure of arguments[0] for performance
		for p of y
			if y.hasOwnProperty(p) isnt x.hasOwnProperty(p)
				addToKeysChanged p
			else if typeof y[p] isnt typeof x[p]
				addToKeysChanged p
		for p of x
			if y.hasOwnProperty(p) isnt x.hasOwnProperty(p)
				addToKeysChanged p
				return false
			else if typeof y[p] isnt typeof x[p]
				addToKeysChanged p
				return false
			switch typeof x[p]
				when 'object', 'function'
					leftChain.push x
					rightChain.push y
					currKeyChain.push p
					compare(x[p], y[p])
					leftChain.pop()
					rightChain.pop()
					currKeyChain.pop()
				else
					if x[p] isnt y[p]
						addToKeysChanged p
		return true

	compare(obj1, obj2)
	return keysChanged

# TODO:
# Store-specific (immutable) clone method
# Args: obj # Object to clone
# If obj is an object, set all properties to writable: false
# If array, copy all elements to new array - if object recurse
# If any other type of value return it


# Static Private Methods
# Be Sure to call these methods with fn.call(this, arg1, arg2, ...) or fn.apply(this, arguments)
_init = (options)->
		# console.log '_init', options
		_validate options
		@_history = [] unless @_history
		@registerActions(options.actions) if options.actions
		@registerCallbacks(options.callbacks) if options.callbacks

		@Dispatcher = options.dispatcher
		# TODO: Initialize dispatch handler and callback management
		# @Dispatcher.register (args...) ->
		# 	_dispatcherHandler.apply(@, args)

# Validation Methods
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

# Registration/Unregistration Helpers
_removeCallbackFromAction = (actionId, callbackId) ->
	if @_actions[actionId].indexOf(callbackId) < 0
		console.warn 'StoreClass unregisterAction: no callback ' + callbackId + ' registered to action ' + actionId + '!'
		return false
	else
		@_actions[actionId].splice(@_actions[actionId].indexOf(callbackId), 1)
		return true
_cleanupCallbacks = ->
	callbacks = []
	for callback of @_callbacks
		callbackReferenced = false
		for action, cbs of @_actions
			callbackReferenced = true if cbs.indexOf(callback) >= 0
		delete @_callbacks[callback] if !callbackReferenced
	callbacks
_cleanupActions = ->
	callbacks = []
	for action, cbs of @_actions
		for cb in cbs
			callbacks.push(cb) if !@_callbacks.hasOwnProperty(cb)
	for callback in callbacks
		for action, cbs of @_actions
			cbs.splice(cbs.indexOf(callback), 1) if cbs.indexOf(callback) >= 0
			delete @_actions[action] if cbs.length is 0
	callbacks

# Static Registration Methods
_registerActions = (actionsMap) ->
	_validateActions 'registerActions', actionsMap
	# Merge with internal actions list
	for key, val of actionsMap
		if typeof val is 'undefined'
			throw new Error 'StoreClass registerActions: property ' + key + ' must be a string or array of strings!'
		@registerAction key, val
	@
_registerAction = (actionId, callbackId) ->
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
_registerCallbacks = (callbacksMap) ->
	_validateCallbacks 'registerCallbacks', callbacksMap
	# Merge with internal callbacks list
	for key, val of callbacksMap
		if callbacksMap.hasOwnProperty? and not callbacksMap.hasOwnProperty key
			continue
		@registerCallback key, val
	@
_registerCallback = (callbackId, callbackFn) ->
	@_callbacks = {} unless @_callbacks
	if typeof callbackId isnt 'string'
		throw new Error 'StoreClass registerCallback: callbackId passed to this method must be a string!'
	if typeof callbackFn isnt 'function'
		throw new Error 'StoreClass registerCallback: callbackFn passed to this method must be a function!'
	@_callbacks[callbackId] = callbackFn
	@

# Static Unregistration Methods
_unregisterActions = (actionsMap) ->
	_validateActions 'unregisterActions', actionsMap
	# Remove from internal actions list
	for key, val of actionsMap
		@unregisterAction key, val
	@
_unregisterAction = (actionId, callbackId) ->
	if typeof actionId isnt 'string'
		throw new Error 'StoreClass unegisterAction: first argument (actionId) must be a string!'
	if typeof @_actions is 'undefined'
		throw new Error 'StoreClass unregisterAction: there are no currently defined actions!'
	else if typeof @_actions[actionId] is 'undefined'
		throw new Error 'StoreClass unregisterAction: there are no callbacks registered to action ' + actionId + '!'
	# Remove callback string(s)
	callbacksRemoved = false
	if (typeof callbackId is 'string') and (callbackId isnt '*')
		callbacksRemoved = _removeCallbackFromAction.call(@, actionId, callbackId)
	else if isArray callbackId
		for name in callbackId
			callbacksRemoved = true if _removeCallbackFromAction.call(@, actionId, name)
	else if (typeof callbackId is 'undefined') or (callbackId is '*')
		callbacksRemoved = true if @_actions[actionId].length > 0
		@_actions[actionId].length = 0
	else
		throw new Error 'StoreClass unregisterAction: optional second argument callbackId must be a string or array of strings!'
	delete @_actions[actionId] if @_actions[actionId].length is 0
	_cleanupCallbacks.call(@) if callbacksRemoved
	@
_unregisterCallbacks = (callbacksList) ->
	if not isArray callbacksList
		throw new Error 'StoreClass unregisterCallbacks: parameter passed in must be an array of callback ids or functions!'
	# Remove from internal callbacks list
	for cb in callbacksList
		if (typeof cb isnt 'string') and (typeof cb isnt 'function')
			throw new Error 'StoreClass unregisterCallbacks: list of callbacks to unregister must only contain string ids and functions!'
		@unregisterCallback cb
	@
_unregisterCallback = (callback) ->
	if typeof @_callbacks is 'undefined'
		throw new Error 'StoreClass unregisterCallback: there are no currently defined callbacks!'
	callbackRemoved = false
	if typeof callback is 'string'
		if typeof @_callbacks[callback] is 'undefined'
			console.warn 'StoreClass unregisterCallback: there is no callback with the id ' + callback + '!'
		else
			delete @_callbacks[callback]
			callbackRemoved = true
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
				callbackRemoved = true
	else
		throw new Error 'StoreClass unregisterCallback: parameter passed in must be a callback id string or a function!'
	_cleanupActions.call(@) if callbackRemoved
	@

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

# StoreClass
# Class Constructor
# options =
# 	actions:
# 		"action1": "function1"
# 		"action2": "function2"
# 	callbacks:
# 		"function1": Fn()
# 		"function2": Fn()
# 	dispatcher: Dispatcher Instance
module.exports = StoreClass = class StoreClass
	# TODO:
	# Add a history of up to 5 previous values of _value
	# Add the ability to add a store to a group
	#  .. Create the group if the group does not already exist
	#  .. Create a global list of groups that all store instances can access
	#  .. Group will allow you to listen into an entire group of stores for changes

	# TODO: Enforce _value/value must be an object [object Object]
	_history: undefined # list of up to 5 previous store values (immutable)
	_value: undefined # private internal value to diff changes against and push into the history array
	value: undefined # value is mutable by callback functions, then checked against internal _value
	
	_actions: undefined # object map of actions to methods
	_callbacks: undefined # list of callbacks
	# Remove this: use .hasOwnProperty on _actions instead
	_actionKeys: undefined # array of action names, used as convenience by _dispatchHandler

	Dispatcher: undefined

	constructor: (options = {}) ->
		_init.call @, options

	# Public Registration Methods
	registerActions: (args...) ->
		_registerActions.apply @, args
	registerAction: (args...) ->
		_registerAction.apply @, args
	registerCallbacks: (args...) ->
		_registerCallbacks.apply @, args
	registerCallback: (args...) ->
		_registerCallback.apply @, args
	# Unregistration Methods
	unregisterActions: (args...) ->
		_unregisterActions.apply @, args
	unregisterAction: (args...) ->
		_unregisterAction.apply @, args
	unregisterCallbacks: (args...) ->
		_unregisterCallbacks.apply @, args
	unregisterCallback: (args...) ->
		_unregisterCallback.apply @, args

	# Get Value, Bind and Unbind Change Methods
	get: (key, numPrev) ->
		# TODO:
		# Retrieve value if no key (undefined)
		# Parse key, return key value
		# Allow nested keys
		# numPrev is optional and will indicate how far back in history to retrieve the key
	getPrev: (numPrev, key) ->
		# TODO:
		# Call @get(key, numPrev)
		# Convenience method when retrieving previous values
		# (easier argument ordering - key can be optional in this instance)
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