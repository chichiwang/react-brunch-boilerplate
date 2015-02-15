# @cjsx React.DOM
'use strict'

SiteEvents = require 'components/site'

# Initialize React's touch events
React.initializeTouchEvents(true)

initialize = ->
	SiteEvents.initialize()

	React.initializeTouchEvents(true)
	require 'components/root'
	# React.render <Root />, document.getElementById('Site-Container') if Root

initialize()