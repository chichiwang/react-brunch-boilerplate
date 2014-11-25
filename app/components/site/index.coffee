# Module dependencies
Store = require './store'
Actions = require './actions'
Constant = require './const'

_init = ->
	_bindAll.call @
	_resizeHandler.call @
_resizeHandler = ->
	cW = Store.get 'width'
	cH = Store.get 'height'
	w = window.innerWidth
	h = window.innerHeight
	if (w isnt cW) or (h isnt cH)
		Actions.call null, Constant.SET_DIMENSIONS, w, h
	_orientationHandler()
_orientationHandler = ->
	w = Store.get 'width'
	h = Store.get 'height'
	w = window.innerWidth if typeof w is 'undefined'
	h = window.innerHeight if typeof h is 'undefined'
	orientation = if w > h then 'landscape' else 'portrait'
	Actions.call Constant.SET_ORIENTATION, orientation

_bindAll = ->
	for evId of @_events
		_bind.call @, evId
_bind = (ev) ->
	cb = @_events[ev]
	window.addEventListener ev, cb, false
_unbindAll = ->
	for evId of @_events
		_unbind.call @, evId
_unbind = (ev) ->
	cb = @_events[cb]
	window.removeEventListener ev, cb, false

# Site Class
# A class to manage a site store which tracks site-wide events
#
# Allows user to turn on/off tracking for various site-wide events
SiteClass = class SiteClass
	_events:
		resize: _resizeHandler
		orientation: _orientationHandler

	initialize: ->
		_init.call @

	on: (ev) ->
		if typeof ev is 'undefined'
			_bindAll.call @
		else
			_bind.call @, ev
	off: (ev) ->
		if typeof ev is 'undefined'
			_unbindAll.call @
		else
			_bind.call @, ev

SiteInstance = new SiteClass
module.exports = SiteInstance