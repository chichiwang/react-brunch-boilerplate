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

# Static Private Methods
# Be Sure to call these methods with fn.call(this) or fn.apply(this, arguments)
_validate = (options) ->
	# options =
	# 	actions:
	# 		"action1": "function1"
	# 		"action2": "function2"
	# 	callbacks:
	# 		"function1": Fn()
	# 		"function2": Fn()
	# 	emitter: Emitter Instance
	# 	dispatcher: Dispatcher Instance
	if typeof options isnt 'object'
		throw new Error "StoreClass _validate: options passed to constructor must be an object!"
	if typeof emitter isnt 'object'
		throw new Error "StoreClass _validate: constructor must be passed an emitter!"
	if typeof dispatcher isnt 'object'
		throw new Error "StoreClass _validate: constructor must be passed a dispatcher!"

_emitChange = (ev, val) ->
	# TODO:
	# Fire emitter with event and value

_dispatcherHandler = (args) ->
	console.log '_dispatcherHandler', args
	# TODO:
	# ...

# TODO: METHOD DIFF OBJECTS

# StoreClass
# TODO:
# Add a history of up to 5 previous values of _value
# Add the ability to add a store to a group
#  .. Create the group if the group does not already exist
#  .. Create a global list of groups that all store instances can access
#  .. Group will allow you to listen into an entire group of stores for changes

module.exports = StoreClass = class StoreClass
	_value: undefined
	_callbacks: undefined # list of callbacks

	actions: undefined # object map of actions to methods

	Emitter: undefined
	Dispatcher: undefined

	constructor: (options = {}) ->
		_validate(options);
		# TODO:
		# Store options
		# Bind Events

	_init: ->
		# TODO:
		# ...
		@Dispatcher.register (args...) ->
			_dispatcherHandler.apply(@, args)

	registerCallbacks: (callbacks) ->
		# callbacks = object
		# key = name, val = fn
		# TODO:
		# For key in callback
		# @registerCallback(key, callback[key])
	registerCallback: (name, callback) ->
		# TODO:
		# Push an object { name: name, fn: callback } into @callbacks arrays

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