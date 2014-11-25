# @cjsx React.DOM
'use strict'

SiteEvents = require 'components/site'
Router = require 'arc/router'

# Initialize React's touch events
React.initializeTouchEvents(true)

initialize = ->
	Router.initialize()
	SiteEvents.initialize()

	Root = require 'components/root'
	React.initializeTouchEvents(true)
	React.renderComponent <Root />, document.getElementById('Site-Container') if Root

initialize()