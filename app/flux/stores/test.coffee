StoreClass = require './new_class'

changeHandler1 = (val) ->
	console.log 'changeHandler1: ', val
changeHandler2 = (val) ->
	console.log 'changeHandler2: ', val

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
	events:
		'change': changeHandler1,
		'change:key1': [changeHandler1, changeHandler2]

StoreInstance.registerCallback 'callback1', ->
	console.log 'callback1 override'

# StoreInstance.on('change', changeHandler1)
# StoreInstance.on('change:foo', changeHandler2)

console.log StoreInstance