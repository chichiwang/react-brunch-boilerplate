# @cjsx React.DOM
'use strict'

# Stores
SiteStore = require 'components/site/store'

# Helpers and utilities
SyncState = require 'util/mixins/syncstate'

# Routing
Router = window.ReactRouter
{ DefaultRoute, Link, Route, RouteHandler, Redirect } = Router

# Child views
Home = require 'components/home'

Root = React.createClass
	displayName: 'Root'
	mixins: [SyncState]
	stores:
		site: SiteStore

	render: ->
		console.log 'render', @state
		<div id="Root">
			<RouteHandler />
		</div>

# Route Definitions
routes = (
	<Route name="app" path="/" handler={Root} >
		<Route name="home" handler={Home} />
		<Redirect from="/" to="home" />
	</Route>
)
Router.run routes, (Handler) ->
	React.render <Handler />, document.getElementById('Site-Container')

# Successfully required in
module.exports = true