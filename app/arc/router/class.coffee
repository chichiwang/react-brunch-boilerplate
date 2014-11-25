'use strict'

# Router Module Dependencies:
# FlatIron Director, Javascript State Machine, Arc Helpers
DirectorRouter = window.Router
StateMachine = window.StateMachine
clone = require('util/helpers').clone
type = require('util/helpers').type

# Module Component dependencies
try RouterConfig = require 'routes'
catch
	RouterConfig = undefined
Actions = require './actions'
RouterStore = require './store'
Constant = require './const'

transitionsEnabled = true

_validateOptions = (options) ->
	if type(options) isnt 'object'
		throw new Error 'Router _validateOptions: argument passed into constructor must be an options object!'
	if type(options.history) isnt 'undefined' and type(options.history) isnt 'boolean'
		throw new Error 'Router _validateOptions: history property in config must be boolean'
	if type(options.transitions) isnt 'undefined' and type(options.transitions) isnt 'boolean'
		throw new Error 'Router _validateOptions: transitions property in config must be boolean'
	if type(options.paths) is 'undefined'
		throw new Error 'Router _validateOptions: paths property in config must be defined'
	if type(options.paths) isnt 'object'
		throw new Error 'Router _validateOptions: paths property in config must be an object'
	for path of options.paths
		if typeof options.paths[path] isnt 'object'
			throw new Error 'Router _validateOptions: path parameters must be an object'
		if typeof options.paths[path].routeId isnt 'string'
			throw new Error 'Router _validateOptions: path objects must contain a string property "routeId"'

_isTransitioned = (from) ->
	if from is 'initialState'
		return true
	else
		return false

_getFSMEvents = (paths) ->
	_routeHash = {}
	events = []
	for route, routeOptions of paths
		continue if _routeHash[routeOptions.routeId]
		_routeHash[routeOptions.routeId] = true
		events.push 
			name: 'go' + routeOptions.routeId
			from: ['*']
			to: routeOptions.routeId
	events

lastState = undefined
_FSMCallback = (route, routeOptions, transitioned, defaultTransition, routerHistory) ->
	return (event, from, to, msg) ->
		actionOptions =
			path: '#'+route
			prevState: from
			curState: to
			transition: if routeOptions.transition then routeOptions.transition else defaultTransition
			transitioned: if transitioned then true else _isTransitioned(from)
		overrideableKeys = ['path']
		if msg 
			for k, v of msg
				if typeof actionOptions[k] isnt 'undefined' and not k in overrideableKeys
					throw new Error('Router _FSMCallback: Route placeholder "' + k + '" conflicts with already defined store property.' + v)
				actionOptions[k] = v
		storeState = RouterStore.get()
		delete storeState.transitioned
		newState = clone actionOptions
		delete newState.transitioned
		if !_.isEqual(newState, storeState) and !_.isEqual(newState, lastState)
			lastState = newState
			routerHistory[1] = routerHistory[0]
			routerHistory[0] = storeState

		# console.log '_FSMCallback', actionOptions
		Actions.dispatch RouterStore.SET, actionOptions


_FSMCallbacks = (paths, defaultTransition, routerHistory) ->
	_routeHash = {}
	callbacks = {}
	for route, routeOptions of paths
		continue if _routeHash[routeOptions.routeId]
		_routeHash[routeOptions.routeId] = true
		key = 'onbeforego' + routeOptions.routeId
		callbacks[key] = _FSMCallback route, routeOptions, false, defaultTransition, routerHistory
		key = 'on' + routeOptions.routeId
		callbacks[key] = _FSMCallback route, routeOptions, true, defaultTransition, routerHistory

	if typeof callbacks.onleavestate isnt 'undefined'
		throw new Error('Router _FSMCallbacks: "leavestate" is a reserved router id.')
	callbacks.onleavestate = (event, from, to, msg) ->
		return StateMachine.ASYNC if from isnt 'none' and transitionsEnabled

	callbacks

_FSM = (options, routerHistory) ->
	fsmOptions = 
		initial: 'initialState'
		events: _getFSMEvents(options.paths)
		callbacks: _FSMCallbacks(options.paths, options.defaultTransition, routerHistory)
	fsmOptions.events.push
		name: 'godefault'
		from: [ '*' ]
		to: 'default'
	StateMachine.create fsmOptions

_directorCallback = (params, routeParams, stateMethod, FSM) ->
	return -> 
			# console.log '_directorCallback', stateMethod
			for param, idx in routeParams
				params[param] = arguments[idx]
			FSM.transition?() if transitionsEnabled
			FSM[stateMethod](params)

_directorConfig = (options, FSM) ->
	config = {}
	for route, routeOptions of options.paths
		continue if route is '**'
		stateMethod = 'go' + routeOptions.routeId
		params = {}
		for key of routeOptions
			if routeOptions.hasOwnProperty(key)
				params[key] = routeOptions[key]

		routeString = route.split '/'
		routeParams = []
		for val, idx in routeString
			routeParams.push val.slice(1) if val.indexOf(':') is 0

		config[route] = _directorCallback(params, routeParams, stateMethod, FSM)
	config

_directorDefault = (router, routeObj, FSM) ->
	FSM.onbeforegodefault = (event, from, to, msg) ->
		routeObj.prevState = from
		routeObj.curState = to
		Actions.dispatch RouterStore.SET, routeObj
	router.notfound = ->
		FSM.transition?() if transitionsEnabled
		FSM.godefault()

module.exports = class Router
	_history: [{}, {}]
	hasInit: false
	defaults:
		initial: '/'
		history: false
		transitions: true

	constructor: (options) ->
		options = RouterConfig unless options
		@options = options

	initialize: (options) ->
		options = @options unless options
		if @hasInit
			throw new Error 'Router: Router has already been initialized!'
			return false
		@hasInit = true

		# Prep options
		_validateOptions options
		options = clone options
		options.initial = @defaults.initial if options.hasOwnProperty? and !options.hasOwnProperty('initial')
		options.history = @defaults.history if options.hasOwnProperty? and !options.hasOwnProperty('history')
		options.transitions = @defaults.transitions if options.hasOwnProperty? and !options.hasOwnProperty('transitions')
		@options = options

		transitionsEnabled = options.transitions

		console.log 'Router initialize: ', options

		# Set up FSM
		# TODO: remove router history feature
		@FSM = _FSM options, @_history
		# console.log 'Router init:', @FSM

		# # Make Router Store public
		# @store = RouterStore

		# # Instantiate Director, init Director
		# directorConfig = _directorConfig options, @FSM
		# @router = new DirectorRouter directorConfig
		# @router.configure({ html5history: options.history })
		# $(document).ready =>
		# 	# console.log 'Router init'
		# 	@router.init(options.initial)
		# 	_directorDefault(@router, options.paths['**'], @FSM) if options.paths['**']
		# # console.log 'Router init:', @router

	transition: ->
		@FSM.transition?() if transitionsEnabled

	history: (stepsBack) ->
		stepsBack = stepsBack || 1
		if stepsBack > 2
			throw new Error('Router history: Router only holds the two most recent entries of history.')
		@_history[stepsBack - 1]