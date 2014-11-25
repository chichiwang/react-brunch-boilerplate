# Module dependencies
StoreClass = require 'flux/store/class'
Dispatcher = require 'dispatcher'
Constant = require './const'

# Dispatch handlers
setDimensions = (val) ->
	@value.width = val.width
	@value.height = val.height
setOrientation = (val) ->
	@value.orientation = val

# Prep actions callbacks
actionsCallbacks = {}
actionsCallbacks[Constant.SET_DIMENSIONS] = setDimensions
actionsCallbacks[Constant.SET_ORIENTATION] = setOrientation

# Instantiate store class
SiteStore = new StoreClass
	dispatcher: Dispatcher
	actions: actionsCallbacks
	initial:
		width: undefined
		height: undefined
		orientation: undefined

module.exports = SiteStore