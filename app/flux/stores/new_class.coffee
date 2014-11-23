'use strict'

# Helper Utility Methods
# Note: Change the require path to access the global framework object when modularizing
try isArray = require('util/helpers').isArray
catch
	isArray = (obj) ->
		return true if Object::toString.call(obj) is '[object Array]'
		return false
try clone = require('util/helpers').clone
catch
	objectCreate = Object.create
	if typeof objectCreate isnt 'function'
		objectCreate = (o) ->
			F = ->
			F.prototype = o
			return new F()
	clone = (obj, _copied) ->
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
		if isArray obj
			result = obj.slice()
			for el, idx in result
				result[idx] = clone el, _copied
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
			result[key] = clone val, _copied
		return result

# Deep diff two objects
# Return the keys diff between obj1 and obj2
# Borrowed heavily from http://stackoverflow.com/a/1144249/1161897
_diffObjects = (obj1, obj2) ->
	allArgsAreObjects = true
	for arg in arguments
		if Object::toString.call(arg) isnt '[object Object]'
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
			if Object::toString.call(x) isnt Object::toString.call(y)
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


# Static Private Methods
# Be Sure to call these methods with fn.call(this, arg1, arg2, ...) or fn.apply(this, arguments)
_init = (options)->
		# console.log '_init', options
		_validate options
		# Init values
		@_history = [] unless @_history
		if typeof options.maxHistory is 'number'
			@maxHistory = options.maxHistory
		if typeof options.initial isnt 'undefined'
			@value = options.initial
			_syncValues.call @

		@registerActions(options.actions) if options.actions
		@registerCallbacks(options.callbacks) if options.callbacks
		@on(options.events) if options.events

		@Dispatcher = options.dispatcher
		self = @
		@_dispatcherToken = @Dispatcher.register (args...) ->
			_dispatchHandler.apply self, args

# Validation Methods
_validate = (options) ->
	if Object::toString.call(options) isnt '[object Object]'
		throw new Error "StoreClass _validate: options passed to constructor must be an object!"
	if typeof options.dispatcher isnt 'object'
		throw new Error "StoreClass _validate: constructor must be passed a dispatcher instance!"
	if (typeof options.initial isnt 'undefined') and (Object::toString.call(options.initial) isnt '[object Object]')
		throw new Error "StoreClass _validate: initial property of options passed to constructor must be an object!"
	if (typeof options.events isnt 'undefined') and (Object::toString.call(options.events) isnt '[object Object]')
		throw new Error "StoreClass _validate: events property of options passed to constructor must be an object!"
	if (typeof options.maxHistory isnt 'undefined') and (typeof options.maxHistory isnt 'number')
		throw new Error "StoreClass _validate: maxHistory property must be an integer!"
	# TODO: Validate options.dispatcher has a method .register(value)
_validateActions = (fnName, actionsMap) ->
	# Validate actionsMap is an object
	isObject = Object::toString.call(actionsMap) is '[object Object]'
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
	isObject = Object::toString.call(callbacksMap) is '[object Object]'
	isNull = callbacksMap is null
	if (not isObject) or (isArray callbacksMap) or isNull
		throw new Error 'StoreClass ' + fnName + ': parameter passed in must be an object!'
	for key, val of callbacksMap
		if callbacksMap.hasOwnProperty? and not callbacksMap.hasOwnProperty key
			continue
		if typeof val isnt 'function'
			throw new Error 'StoreClass ' + fnName + ': property ' + key + ' of parameter must be a function!'
_validateBindHandlers = (fnName, ev, handler) ->
	if (typeof ev isnt 'string') and (Object::toString.call(ev) isnt '[object Object]')
		throw new Error 'StoreClass ' + fnName + '(): arguments passed in must be either (event, handler) or (eventsMap)!'
	if (typeof ev is 'string') and ((typeof handler isnt 'function') and (Object::toString.call(handler) isnt '[object Array]') and (Object::toString.call(handler) isnt '[object Object]'))
		throw new Error 'StoreClass ' + fnName + '(): second argument must be a function, array of functions, or options object!'
	# options object passed in
	if (typeof ev is 'string') and (Object::toString.call(handler) is '[object Object]')
		if (Object::toString.call(handler.context) isnt '[object Object]') or ((typeof handler.handlers isnt 'function') and (Object::toString.call(handler.handlers) isnt '[object Array]'))
			throw new Error 'StoreClass ' + fnName + '(): invalid options object passed in!'
		else if Object::toString.call(handler.handlers) is '[object Array]'
			for hl in handler.handlers
				if typeof hl isnt 'function'
					throw new Error 'StoreClass ' + fnName + '(): invalid options object passed in!'
	# array of handlers passed in
	if Object::toString.call(handler) is '[object Array]'
		for cb in handler
			if (typeof cb isnt 'function') and (Object::toString.call(cb) isnt '[object Object]')
				throw new Error 'StoreClass ' + fnName + '(): element in handler array is not a function or options object!'
			else if Object::toString.call(cb) is '[object Object]'
				if (Object::toString.call(cb.context) isnt '[object Object]') or ((typeof cb.handlers isnt 'function') and (Object::toString.call(cb.handlers) isnt '[object Array]'))
					throw new Error 'StoreClass ' + fnName + '(): invalid options object passed in!'
				else if Object::toString.call(cb.handlers) is '[object Array]'
					for hl in cb.handlers
						if typeof hl isnt 'function'
							throw new Error 'StoreClass ' + fnName + '(): invalid options object passed in!'
	# options object passed in - ignore handler parameter
	else if Object::toString.call(ev) is '[object Object]'
		for evId, cb of ev
			# callback is an options object
			if Object::toString.call(cb) is '[object Object]'
				# options object is invalid
				if (Object::toString.call(cb.context) isnt '[object Object]') and ((typeof cb.handlers isnt 'function') or (Object::toString.call(cb.handlers) isnt '[object Array]'))
					throw new Error 'StoreClass ' + fnName + '(): invalid options object!'
				# validate options array
				else if Object::toString.call(cb.handlers) is '[object Array]'
					for fn in cb.handlers
						if typeof fn isnt 'function'
							throw new Error 'StoreClass ' + fnName + '(): all handlers must be functions!'
			# callback isnt function, options object, or array of functions/options objects
			else if (typeof cb isnt 'function') and (Object::toString.call(cb) isnt '[object Array]')
				throw new Error 'StoreClass ' + fnName + '(): events map properties must contain event callback functions!'
			# callback is an array
			else if Object::toString.call(cb) is '[object Array]'
				for obj in cb
					# array element is neither function nor object
					if (typeof obj isnt 'function') and (Object::toString.call(obj) isnt '[object Object]')
						throw new Error 'StoreClass ' + fnName + '(): events map properties must contain event callback functions or options!'
					# validate options object in array
					else if Object::toString.call(obj) is '[object Object]'
						if (Object::toString.call(obj.context) isnt '[object Object]') and ((typeof obj.handlers isnt 'function') or (Object::toString.call(obj.handlers) isnt '[object Array]'))
							throw new Error 'StoreClass ' + fnName + '(): invalid options object!'
						# validate handlers in options object in array
						else if Object::toString.call(obj.handlers) is '[object Array]'
							for fn in obj.handlers
								if typeof fn isnt 'function'
									throw new Error 'StoreClass ' + fnName + '(): all handlers must be functions!'

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

# Value helper methods
_addToHistory = (val) ->
	if @_history.unshift(val) > @maxHistory
		@_history.length = @maxHistory
_syncValues = ->
	_addToHistory.call(@, @_value) if @_value
	@_value = clone @value

# Event Handler Registration/Unregistration
_bindEventHandlers = (ev, handler, context) ->
	_validateBindHandlers 'on', ev, handler
	if (typeof ev is 'string') and ((typeof handler is 'function') or (Object::toString.call(handler) is '[object Object]'))
		if typeof context isnt 'undefined'
			_bindEventHandler.call @, ev, handler, context
		else
			_bindEventHandler.call @, ev, handler
	else if (typeof ev is 'string') and (Object::toString.call(handler) is '[object Array]')
		for cb in handler
			_bindEventHandler.call @, ev, cb
	else
		for evId, cb of ev
			if Object::toString.call(cb) is '[object Array]'
				for fn in cb
					_bindEventHandler.call @, evId, fn
			else
				_bindEventHandler.call @, evId, cb
	@
_bindEventHandler = (ev, handler, context) ->
	# Validate arguments
	ev = 'change' unless ev
	if ev.indexOf('change') < 0
		console.warn 'StoreClass on(): ', @_eventHandlers
		throw new Error 'StoreClass on(): StoreClass currently only handles "change" events!'
	# Init @_eventHandlers
	@_eventHandlers = {} unless @_eventHandlers
	# Prepare event id
	evArr = ev.split ':'
	evId = ''
	for str in evArr
		evId += str if str isnt 'change'
	evId = '**' if evId is ''
	# Register handlers to the list @_eventHandlers
	@_eventHandlers[evId] = [] unless @_eventHandlers[evId]
	if @_eventHandlers[evId].indexOf(handler) >= 0
		console.warn 'StoreClass on(): handler for event ' + ev + ' already bound!'
	else if typeof context is 'undefined'
		@_eventHandlers[evId].push handler
	else
		@_eventHandlers[evId].push
			context: context
			handlers: handler
	@
_unbindEventHandlers = (ev, handler) ->
	if (typeof ev is 'string') and (Object::toString.call(handler) is '[object Array]')
		for cb in handler
			if typeof cb isnt 'function'
				throw new Error 'StoreClass off(): handlers list for ' + ev + ' may only contain functions!'
			_unbindEventHandler.call @, ev, cb
	else if (typeof ev is 'string')
		if (typeof handler isnt 'undefined') and (typeof handler isnt 'function') and (Object::toString.call(handler) isnt '[object Object]')
			throw new Error 'StoreClass off(): handler parameter must be a function or options object!'
		_unbindEventHandler.call @, ev, handler
	else if Object::toString.call(ev) is '[object Object]'
		for evId, cb of ev
			if Object::toString.call(cb) is '[object Array]'
				for fn in cb
					if typeof fn isnt 'function'
						throw new Error 'StoreClass off(): handlers list for ' + ev + ' may only contain functions!'
					_unbindEventHandler.call @, evId, fn
			else
				if typeof cb isnt 'function'
					throw new Error 'StoreClass off(): value in property ' + evId + ' must be a function!'
				_unbindEventHandler.call @, evId, cb
	else if typeof ev is 'undefined'
		for key of @_eventHandlers
			if !@_eventHandlers.hasOwnProperty key
				continue
			delete @_eventHandlers[key]
	else
		throw new Error 'StoreClass off(): invalid parameters!'
	@
_unbindEventHandler = (ev, handler) ->
	# Prepare event id
	evArr = ev.split ':'
	evId = ''
	for str in evArr
		evId += str if str isnt 'change'
	evId = '**' if evId is ''
	# Check to see handler exists
	if typeof @_eventHandlers[evId] is 'undefined'
		console.warn 'StoreClass off(): no handlers registered to the event ' + ev + '!'
		return
	# Remove handler from @_eventHandlers
	if typeof handler is 'undefined'
		@_eventHandlers[evId].length = 0
	else if @_eventHandlers[evId].indexOf(handler) >= 0
		@_eventHandlers[evId].splice @_eventHandlers[evId].indexOf(handler), 1
	else
		console.warn 'StoreClass off(): handler passed in not registered to event ' + ev
	# Cleanup
	if @_eventHandlers[evId].length is 0
		delete @_eventHandlers[evId]
	@

# Dispatch-Event Handlers
_dispatchHandler = (payload)->
	# Validate payload
	if Object::toString.call(payload) isnt '[object Object]'
		console.warn 'StoreClass _dispatchHandler expects a single object payload! Aborting...'
		return
	if typeof payload.actionId isnt 'string'
		console.warn 'StoreClass _dispatchHandler expects a string actionId in the payload! Aborting...'
		return
	if Object::toString.call(payload.value) isnt '[object Object]'
		console.warn 'StoreClass _dispatchHandler expects an object value in the payload! Aborting...'
		return
	# Fire all registered callbacks for the actionId
	{ actionId, value } = payload
	for action, callbacks of @_actions
		continue if action isnt actionId
		for callback in callbacks
			@_callbacks[callback].call(@, value) if typeof @_callbacks[callback] is 'function'
	# If @value has changed, update @_history and @_value and emit the changes
	diff = _diffObjects @value, @_value
	if diff.length > 0
		_syncValues.call @
		_emitChanges.call @, diff

# Emit Changes
_emitChanges = (changedArray) ->
	value = clone @value
	emitted = []
	handled = []
	for change in changedArray
		for ev, handlers of @_eventHandlers
			if (change.indexOf(ev) >= 0 or ev is '**') and not (ev in emitted)
				emitted.push ev
				for handler in handlers
					continue if handler in handled
					if Object::toString.call(handler) is '[object Object]'
						ctx = handler.context
						hl = handler.handlers
						if typeof hl is 'function'
							hl.call ctx, value
						else
							for h in hl
								h.call ctx, value
						handled.push handler
					else
						handler(value)
						handled.push handler

# Static Getter Methods
_get = (key, numPrev) ->
	if typeof numPrev is 'number'
		if numPrev > @maxHistory
			throw new Error 'StoreClass get: store only tracks previous ' + @maxHistory + ' values!'
		return undefined if @_history.length < numPrev
		value = clone @_history[numPrev - 1]
	else
		value = clone @value

	if not key
		return value
	else if typeof key is 'string'
		keyChain = key.split '.'
		for k in keyChain
			if Object::toString.call(value) isnt '[object Object]'
				console.warn 'Current store value: ', @value
				throw new Error 'StoreClass get: cannot find key "' + key + '" in current store value!'
			value = value[k]
		return value
	else
		throw new Error 'StoreClass get: key passed in must be a string, null, or undefined!'


# TODO:
# Create a new store helper: Arc.StoreGroup
# Create store group, add stores, etc.
# Add the ability to add a store to a group
#  .. Create the group if the group does not already exist
#  .. Create a global list of groups that all store instances can access
#  .. Group will allow you to listen into an entire group of stores for changes
#  ..
#  .. New class (check against global object: Arc.StoreGroups[group_name])
#  .. Group functionality can be executed through StoreClass through a reference @group
#  .. No direct handling of groups except through stores and the global object

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
#	events:
#		'change': changeHandler()
#		'change:key1':
#			context: this
#			handlers: [key1handler1(), key1handler2()]
#	initial:
#		key1: val1
#		key2: val2
module.exports = StoreClass = class StoreClass
	maxHistory: 5
	_history: undefined # list of up to @maxHistory previous store values
	_value: undefined # private internal value to diff changes against and push into the history array
	value: undefined # value is mutable by callback functions, then checked against internal _value
	
	_actions: undefined # object map of actions to methods
	_callbacks: undefined # list of callbacks

	_eventHandlers: undefined # object map of events to handlers

	Dispatcher: undefined
	_dispatcherToken: undefined

	_initialized: false
	_disposed: false

	constructor: (options = {}) ->
		@initialize options
	initialize: (options = {}) ->
		_init.call @, options
		@_disposed = false
		@_initialized = true

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
	get: (args...) ->
		_get.apply @, args
	getPrev: (numPrev, key) ->
		_get.call @, key, numPrev
	on: (args...) ->
		_bindEventHandlers.apply @, args
	off: (args...) ->
		_unbindEventHandlers.apply @, args

	dispose: ->
		return if @_disposed

		# Reset internal property values
		@off()
		@Dispatcher.unregister @_dispatcherToken

		props = [ '_history',
				  '_value',
				  'value',
				  '_actions',
				  '_callbacks',
				  'Dispatcher',
				  '_dispatcherToken'
		]
		this[prop] = undefined for prop in props
		@maxHistory = 5
		@_initialized = false
		@_disposed = true
		@