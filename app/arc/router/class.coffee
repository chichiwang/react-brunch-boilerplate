'use strict'

DirectorRouter = window.Router
RouterConfig = require 'routes'
StateMachine = window.StateMachine
RouterStore = require './store'
Actions = require 'actions'
Util = require './util'

transitionsEnabled = true

_validateOptions = (options) ->
  if typeof options.history isnt 'undefined' and typeof options.history isnt 'boolean'
    throw new Error 'Router _validateOptions: history property in config must be boolean'
  if typeof options.transitions isnt 'undefined' and typeof options.transitions isnt 'boolean'
    throw new Error 'Router _validateOptions: transitions property in config must be boolean'
  if typeof options.paths is 'undefined'
    throw new Error 'Router _validateOptions: paths property in config must be defined'
  if typeof options.paths isnt 'object'
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
    storeState = Util.clone RouterStore.get()
    delete storeState.transitioned
    newState = Util.clone actionOptions
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

  constructor: (options = RouterConfig) ->
    @init options if !@hasInit
    @options = options

  init: (options) ->
    if @hasInit
      throw new Error 'Router: Router has already been initialized!'
      return false
    @hasInit = true

    # Options
    _validateOptions options
    options = _.merge @defaults, options
    transitionsEnabled = options.transitions

    # Set up FSM
    @FSM = _FSM options, @_history
    # console.log 'Router init:', @FSM

    # Make Router Store public
    @store = RouterStore

    # Instantiate Director, init Director
    directorConfig = _directorConfig options, @FSM
    @router = new DirectorRouter directorConfig
    @router.configure({ html5history: options.history })
    $(document).ready =>
      # console.log 'Router init'
      @router.init(options.initial)
      _directorDefault(@router, options.paths['**'], @FSM) if options.paths['**']
    # console.log 'Router init:', @router

  transition: ->
    @FSM.transition?() if transitionsEnabled

  history: (stepsBack) ->
    stepsBack = stepsBack || 1
    if stepsBack > 2
      throw new Error('Router history: Router only holds the two most recent entries of history.')
    @_history[stepsBack - 1]

