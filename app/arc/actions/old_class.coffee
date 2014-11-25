appDispatcher = require 'dispatcher'

module.exports = class Actions
	dispatcher: undefined

	constructor: (dispatcher = appDispatcher)->
		@dispatcher = dispatcher

	dispatch: (id, val)->
		v = _.cloneDeep val
		@dispatcher.dispatch
			id: id
			value: v

	register: (action, callback, context)->
		if action
			cb1 = (payload)->
				return undefined if payload.id isnt action
				if context
					callback.call(context, payload)
				else
					callback(payload)
			return @dispatcher.register cb1
		else if context
			cb2 = (payload)->
				callback.call(context, payload)
			return @dispatcher.register cb2
		else
			cb3 = callback
			return @dispatcher.register cb3
	unregister: (token)->
		@dispatcher.unregister token