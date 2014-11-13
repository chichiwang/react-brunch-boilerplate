StoreClass = require './new_class'

module.exports = StoreInstance = new StoreClass
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
		callback4: ->
			console.log 'callback 4'
	initial:
		key1: 'value1'
		key2: 2
		key3: ['key', '3']
		key4:
			foo: 'bar'

StoreInstance.registerCallback 'callback1', ->
	console.log 'callback1 override'

changeHandler = (val)->
	console.log 'change event fired!', val

StoreInstance.on('change', changeHandler)
StoreInstance.on('change:foo', changeHandler)

console.log StoreInstance