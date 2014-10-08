'use strict'

changeEmitter = require 'emitter'
AppActions = require 'actions'

Store = class Store
	value: undefined
	emitter: undefined
	appActions: undefined
	SET: undefined
	REPLACE: undefined
	storeID: undefined

	# Public API
	get: (key)->
		if typeof key is 'undefined'
			return _.cloneDeep @value
		else
			return _.cloneDeep @value[key]
	onChange: (callback) ->
		@emitter.register @storeID, callback
	offChange: (token) ->
		if _.isUndefined(token)
			throw new Error 'Store offChange(token): Must pass offChange method a token'
		@emitter.unregister token

	# Change triggered by dispatcher
	_emitChange: (val) ->
		@emitter.dispatch @storeID, val
	# Merge method of setting a value
	_set: (k, v)->
		# console.log '_set', k, v
		if typeof k is 'undefined'
			if not _.isEqual @value, v
				@value = _.merge @value, v
				@_emitChange @value
		else if _.isObject(v) and not _.isArray(v) and not _.isEqual(@value[k], v)
			@value[k] = _.merge @value[k], v
			@_emitChange @value
		else if not _.isEqual(@value[k], v)
			@value[k] = v
			@_emitChange @value

	# Replace method of setting a value
	_replace: (k, v) ->
		# console.log '_replace', k, v
		if typeof k is 'undefined'
			if not _.isEqual(@value, v)
				@value = v
				@_emitChange @value
		else if not _.isEqual(@value[k], v)
			@value[k] = v
			@_emitChange @value
	_actionHandler: (type, payload)=>
		method = if type is "set" then '_set' else '_replace'
		this[method] payload.key, payload.value
	_bindActions: ->
		self = this
		@appActions.register @SET, (payload)->
			self._actionHandler 'set', payload
		@appActions.register @REPLACE, (payload)->
			self._actionHandler 'replace', payload

	bindAction: (action, callback)->
		wrappedCallback = =>
			changed = callback.apply @, arguments
			if _.isBoolean changed
				@_emitChange @value if changed is true
			else
				@_emitChange @value
		@appActions.register action, wrappedCallback

	# Constructor Helpers
	_validateSET: (SET)->
		if _.isUndefined(SET)
			throw new Error 'Store Constructor: parameter "SET" must be passed in'
		if _.isEmpty(SET)
			throw new Error 'Store Constructor: parameter "SET" can not be empty'
		SET
	_validateREPLACE: (REPLACE)->
		if _.isUndefined(REPLACE)
			throw new Error 'Store Constructor: parameter "REPLACE" must be passed in'
		if _.isEmpty(REPLACE)
			throw new Error 'Store Constructor: parameter "REPLACE" can not be empty'
		REPLACE
	_storeOptions: (options)->
		{SET, REPLACE, defaultValue, appActions, emitter} = options
		
		@SET = @_validateSET(SET)
		@REPLACE = @_validateREPLACE(REPLACE)
		@value = defaultValue or {}
		@appActions = appActions or AppActions
		@emitter = emitter or changeEmitter
		k1 = Math.floor(Math.random() * 899) + 100
		d = new Date
		k2 = Math.floor(Math.random() * 899) + 100
		@storeID = ''+k1+(d.getTime())+k2

	constructor: (options)->
		@_storeOptions(options)
		@_bindActions()

module.exports = Store
