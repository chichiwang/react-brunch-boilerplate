StoreClass = require './class'

changeHandler0 = (val) ->
	console.log 'changeHandler0: ', val, @
changeHandler1 = (val) ->
	console.log 'changeHandler1: ', val, @
changeHandler2 = (val) ->
	console.log 'changeHandler2: ', val, @
changeHandler3 = (val) ->
	console.log 'changeHandler3: ', val, @
changeHandler4 = (val) ->
	console.log 'changeHandler4: ', val, @

callback1 = ->
	console.log 'callback1', arguments
callback2 = (v)->
	console.log 'callback2', v
	@value = v
callback3 = ->
	console.log 'callback3', arguments
callback4 = ->
	console.log 'callback 4', arguments

module.exports = StoreInstance = new StoreClass
	dispatcher: require 'dispatcher'
	actions:
		action1: [callback1, callback4]
		action2: callback2
	initial:
		key1: 'value1'
		key2: 2
		key3: ['key', '3']
		key4:
			foo: 'bar'
	events:
		'change': changeHandler0,
		'change:key1':
			context: { ctx: 'test context 1' }
			handlers: [changeHandler0, changeHandler1]
		'change:key2': [{
			context: { ctx: 'test context 2' },
			handlers: changeHandler2
		},
		changeHandler2
		]
		'change:key4':
			context: { ctx: 'test context 3' }
			handlers: changeHandler4

StoreInstance.ch1 = changeHandler1
StoreInstance.ch2 = changeHandler2
StoreInstance.cb1 = callback1
StoreInstance.cb2 = callback2

StoreInstance.on 'change:key4', [changeHandler0, changeHandler4], { ctx: 'test context +4' }

# StoreInstance.on('change', changeHandler1)
# StoreInstance.on('change:key1', [changeHandler1, changeHandler2])

StoreInstance.Dispatcher.dispatch
	actionId: 'action2'
	value:
		key1: 'value1'
		key2: 2
		key3: ['key', '3']
		key4:
			foo: 'bar'
			bar: 'baz'

console.log StoreInstance