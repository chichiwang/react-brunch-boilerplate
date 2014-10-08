# [React Mixin] Bind Stores
# Bind stores in a declarative manner to a React Component

StoreClass = require 'flux/stores/class'

module.exports =
	_stores: undefined
	getInitialState: ->
		return undefined if _.isUndefined @stores
		@_stores = @_validateStores @stores
		@_stores = @_bindStores @_stores, @_syncWithStores
		@_getStateFromStores()

	_syncWithStores: ->
		val = @_getStateFromStores()
		@setState val
	_bindStores: (stores, callback)->
		callback = callback or @_syncWithStores
		stores = _.map stores, (val)->
			val.token = val.instance.onChange callback
			return val
		stores
	_getStateFromStores: ->
		val = undefined
		if (@_stores.length > 1) or @_stores[0].key isnt '_singlestore_'
			val = {}
			for store in @_stores
				val[store.key] = store.instance.get()
		else
			val = @_stores[0].instance.get()
		val

	_unbindStores: (stores)->
		for store in stores
			store.instance.offChange store.token

	_validateStores: (stores)->
		if stores instanceof StoreClass
			storesArr = [{
				key: '_singlestore_',
				instance: stores
			}]
		else if _.isArray(stores)
			throw new Error 'Component: stores property is currently not accepting arrays. Thank you.'
		else if _.isObject(stores)
			storesArr = []
			for key, val of stores
				storesArr.push
					key: key
					instance: val
		if _.isUndefined(stores)
			throw new Error 'Compoent: Uh oh. Something\'s wrong with the stores property'
		storesArr

	componentWillUnmount: ->
		@_unbindStores(@_stores)