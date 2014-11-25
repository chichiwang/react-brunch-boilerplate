# @cjsx React.DOM
'use strict'

# Stores
SiteStore = require 'components/site/store'

# Helpers and utilities
# Router = require 'flux/router'
Dispatcher = require 'dispatcher'
# BindStores = require 'util/mixins/bindstores'

Root = React.createClass
	displayName: 'Root'
	# mixins: [BindStores]
	# stores:
	# 	site: SiteStore
		# route: Router.store

	componentWillMount: ->
		console.log 'Root componentWillMount: ', SiteStore.get()

	render: ->
		# console.log 'render', @state
		<div id="Root">
			Root Element
		</div>
	

module.exports = Root
