StoreClass = require './new_class'

StoreInstance = new StoreClass
	emitter: require 'pubsub'
	dispatcher: require 'dispatcher'
	actions:
		action1: "callback1"
		action2: ["callback2", "callback3"]