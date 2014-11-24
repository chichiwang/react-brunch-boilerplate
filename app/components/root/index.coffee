# @cjsx React.DOM
'use strict'

# Stores
SiteStore = require 'stores/site'

# Helpers and utilities
# Router = require 'flux/router'
# Actions = require 'actions'
Dispatcher = require 'dispatcher'
# BindStores = require 'util/mixins/bindstores'

Root = React.createClass
	displayName: 'Root'
	# mixins: [BindStores]
	stores:
		site: SiteStore
		# route: Router.store
	
	_initState: ->
		site = @state.site
		# Actions.dispatch SiteStore.SET, site

	_bindEvents: ->
		$(window).bind('resize', @_resize)
		$(window).bind('mousemove touchstart keydown', @_reprimeSite)
	_resize: ->
		minW = undefined
		minH = undefined
		winW = $(window).outerWidth()
		winH = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
		w = if minW and winW < minW then minW else winW
		h = if minH and winH < minH then minH else winH
		
		site = @state.site
		site.width = w
		site.height = h
		Actions.dispatch SiteStore.SET, site

	componentWillMount: ->
		@_initState()
		@_bindEvents()
		@_resize()

	render: ->
		console.log 'render', @state
		<div id="Root">
			Root Element
		</div>
	
	_unbindEvents: ->
		$(window).unbind('resize')
		$(window).unbind('mousemove touchstart keydown')
	componentWillUnmount: ->
		@_unbindEvents()
	

module.exports = Root
