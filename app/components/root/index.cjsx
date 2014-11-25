# @cjsx React.DOM
'use strict'

# Stores
SiteStore = require 'components/site/store'

# Helpers and utilities
Router = require 'arc/router'
Dispatcher = require 'dispatcher'
SyncState = require 'util/mixins/syncstate'

Root = React.createClass
	displayName: 'Root'
	mixins: [SyncState]
	stores:
		site: SiteStore
		route: Router.store

	render: ->
		console.log 'render', @state
		<div id="Root">
			Root Element
		</div>
	

module.exports = Root