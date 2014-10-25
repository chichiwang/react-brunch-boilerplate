StoreClass = require './new_class'

StoreInstance = new StoreClass
	emitter: require 'pubsub'
	dispatcher: require 'dispatcher'

StoreInstance.registerActions
	action1: "callback1"
	action2: "callback2"