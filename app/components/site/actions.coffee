# Module dependencies
ActionsClass = require 'arc/actions/class'
Dispatcher = require 'dispatcher'
Constant = require './const'

# Action handlers
setDimensions = (width, height) ->
	return {
		width: width
		height: height
	}
setOrientation = (orientation) ->
	return orientation

# Prep actionsOptions
actionsOptions = {}
actionsOptions[Constant.SET_DIMENSIONS] = setDimensions
actionsOptions[Constant.SET_ORIENTATION] = setOrientation

# Instantiate actions class
SiteActions = new ActionsClass
	dispatcher: Dispatcher
	actions: actionsOptions

module.exports = SiteActions