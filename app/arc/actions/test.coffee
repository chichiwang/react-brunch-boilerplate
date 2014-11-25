ActionClass = require './class'

setStore = (v) ->
	return v

module.exports = ActionInstance = new ActionClass
	dispatcher: require 'dispatcher'
	actions:
		SET_STORE: setStore
		RESET_STORE:
			initialized: false
			page: 1

_dispatchListener = (payload) ->
	console.log 'Test dispatched: ', payload

ActionInstance.Dispatcher.register _dispatchListener

console.log 'Test ActionInstance: ', ActionInstance