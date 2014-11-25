# @cjsx React.DOM
'use strict'

SiteEvents = require 'components/site'
Root = require 'components/root'

# Initialize React's touch events
React.initializeTouchEvents(true)

initialize = ->
	_initRouter()
	SiteEvents.initialize()

	React.initializeTouchEvents(true)
	React.renderComponent <Root />, document.getElementById('Site-Container') if Root

_initRouter = ->
	require 'arc/router'

initialize()