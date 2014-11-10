StoreClass = require './new_class'

module.exports = StoreInstance = new StoreClass
	emitter: require 'pubsub'
	dispatcher: require 'dispatcher'
	actions:
		action1: "callback1"
		action2: ["callback2", "callback3"]
	callbacks:
		callback1: ->
			console.log 'callback1'
		callback2: ->
			console.log 'callback2'
		callback3: ->
			console.log 'callback3'

StoreInstance.registerCallback 'callback1', ->
	console.log 'callback1 override'

console.log StoreInstance