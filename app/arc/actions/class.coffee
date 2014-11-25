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

try clone = require('util/helpers').clone
catch
	objectCreate = Object.create
	if type(objectCreate) isnt 'function'
		objectCreate = (o) ->
			F = ->
			F.prototype = o
			return new F()
	clone = (obj, _copied) ->
		# Null or Undefined
		if not obj? or type(obj) isnt 'object'
			return obj

		# Init _copied list (used internally)
		if type(_copied) is 'undefined'
			_copied = []
		else return obj if obj in _copied
		_copied.push obj

		# Native/Custom Clone Methods
		return obj.clone(true) if type(obj.clone) is 'function'
		# Array Object
		if type(obj) is 'array'
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
		if obj.nodeType? and type(obj.cloneNode) is 'function'
			return obj.cloneNode(true)

		# Recurse
		proto = if Object.getPrototypeOf? then Object.getPrototypeOf(obj) else obj.__proto__
		proto = obj.constructor.prototype unless proto
		result = objectCreate proto
		for key, val of obj
			result[key] = clone val, _copied
		return result

# Static Private Methods
# Be Sure to call these methods with fn.call(this, arg1, arg2, ...) or fn.apply(this, arguments)
_init = (options) ->
	# console.log '_init', options
	_validate options
	@Dispatcher = options.dispatcher
	if type(options.actions) is 'object'
		@register options.actions

# Validation Methods
_validate = (options) ->
	if type(options) isnt 'object'
		throw new Error 'ActionClass _validate: options passed to constructor must be an object!'
	if type(options.dispatcher) isnt 'object'
		throw new Error 'ActionClass _validate: constructor must be passed a dispatcher instance!'
	if type(options.dispatcher.dispatch) isnt 'function'
		throw new Error 'ActionClass _validate: dispatcher passed in must have a method "dispatch"!'
	if (type(options.actions) isnt 'undefined') and (type(options.actions) isnt 'object')
		throw new Error 'ActionClass _validate: actions property passed into options must be an object map!'

# Static methods
_register = (actionId, val) ->
	if (type(actionId) isnt 'string') and (type(actionId) isnt 'object')
		throw new Error 'ActionClass register: invalid arguments passed to register() method!'
	if type(actionId) is 'object'
		for id, v of actionId
			_registerAction.call @, id, v
	else if type(actionId) is 'string'
		_registerAction.call @, actionId, val
	@
_registerAction = (actionId, val) ->
	@_actions = {} unless @_actions
	if @_actions.hasOwnProperty? and @_actions.hasOwnProperty actionId
		console.warn 'ActionClass register: action "' + actionId + '" already exists! Overwriting...'
	@_actions[actionId] = val
_unregister = (actionIds...) ->
	for actionId in actionIds
		if type(actionId) isnt 'string'
			throw new Error 'ActionClass unregister: invalid arguments passed to unregister() method!'
		if @_actions.hasOwnProperty? and !@_actions.hasOwnProperty actionId
			console.warn 'ActionClass unregister: action "' + actionId + '" does not exist! Skipping...'
		else if @_actions.hasOwnProperty? and @_actions.hasOwnProperty actionId
			@_actions[actionId] = null
			delete @_actions[actionId]
	@

_call = (context, actionId, args...) ->
	if type(actionId) isnt 'string' and type(context) isnt 'string'
		throw new Error 'ActionClass call: illegal arguments! call() method expects arguments (context, actionId, arguments).'
	if type(context) is 'string' and args.length is 0
		args = actionId
		actionId = context
		context = undefined
	if @_actions.hasOwnProperty? and !@_actions.hasOwnProperty actionId
		throw new Error 'ActionClass call: there is no action "' + actionId + '"!'
	if type(@_actions[actionId]) is 'function'
		if type(context) isnt 'undefined' and type(context) isnt 'null'
			val = @_actions[actionId].apply context, args
		else if type(args) is 'array'
			val = @_actions[actionId](args...)
		else
			val = @_actions[actionId](args)
	else val = @_actions[actionId]
	payload = {}
	payload.actionId = clone actionId
	payload.value = clone val
	@Dispatcher.dispatch payload

_dispose = ->
	return if @_disposed
	# Reset internal property values
	props = [
		'_actions',
		'Dispatcher'
	]
	this[prop] = undefined for prop in props
	@_initialized = false
	@_disposed = true
	@

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

	_actions: undefined

	Dispatcher: undefined

	constructor: (options = {}) ->
		@initialize options
	initialize: (options = {}) ->
		_init.call @, options
		@_disposed = false
		@_initialized = true
		@

	register: (args...) ->
		_register.apply @, args
	unregister: (args...) ->
		_unregister.apply @, args

	call: (args...) ->
		_call.apply @, args

	dispose: ->
		_dispose.call @