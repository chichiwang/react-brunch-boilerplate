'use strict'

# Module dependencies
StoreClass = require 'arc/store/class'
Dispatcher = require 'dispatcher'
Const = require './const'

# Dispatch handlers
setDimensions = (val) ->
	@value.width = val.width
	@value.height = val.height
setOrientation = (val) ->
	@value.orientation = val

# Instantiate store class
SiteStore = new StoreClass
	dispatcher: Dispatcher
	initial:
		width: undefined
		height: undefined
		orientation: undefined

# Register handlers to store
SiteStore.registerAction Const.SET_DIMENSIONS, setDimensions
SiteStore.registerAction Const.SET_ORIENTATION, setOrientation

module.exports = SiteStore