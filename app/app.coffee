# @cjsx React.DOM
'use strict'

# For the React Chrome extension to work:
# * Add React to the top-level namespace.
# * Enable 3rd party cookies.
# * Don't use the webpack-dev-server (the iframe gets in the way).
# window.React = React

device = require 'util/device'

Actions = require 'actions'
ACTION = "INITIALIZED:APP"

Root = require 'root'

# Remove Sizzle's cache (memory management)
$.expr.cacheLength = 1
# Initialize React's touch events
React.initializeTouchEvents(true)

initialize = ->
	_initRouter()
	_checkDeprecated()
	React.initializeTouchEvents(true)
	React.renderComponent <Root />, document.getElementById('Site-Container') if Root
	# Actions.dispatch ACTION

_initRouter = ->
	require 'flux/router'
_redirect = ->
	window.location.href = "deprecated.html"
	false
_checkDeprecated = ->
	if device.is('ie') and device.get('ieVersion').major < 10
		_redirect()
	else if device.is('firefox') and device.get('ffVersion') < 30
		_redirect()
	else if device.is('chrome') and device.get('chromeVersion') < 35
		_redirect()
	else if device.is('safari') and device.get('safariVersion') < 7
		_redirect()

initialize()