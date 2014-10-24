'use strict'

# Static Private Methods
# Be Sure to call these methods with fn.call(this) or fn.apply(this, arguments)

_emitChange = (ev, val)->
	# TODO:
	# Fire emitter with event and value

_dispatcherHandler = (args)->
	console.log '_dispatcherHandler', args
	# TODO:
	# ...

StoreClass = class StoreClass
	value: undefined
	actions: undefined # object map of actions to methods
	callbacks: undefined # list of callbacks
	Emitter: undefined
	Dispatcher: undefined

	constructor: (options)->
		# TODO:
		# Determine options
		# Validate options
		# Store options
		# Bind Events

	_init: ->
		# TODO:
		# ...
		@Dispatcher.register (args...)->
			_dispatcherHandler.apply(@, args)

	registerCallbacks: (callbacks)->
		# callbacks = object
		# key = name, val = fn
		# TODO:
		# For key in callback
		# @registerCallback(key, callback[key])
	registerCallback: (name, callback)->
		# TODO:
		# Push an object { name: name, fn: callback } into @callbacks arrays

	get: (key)->
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