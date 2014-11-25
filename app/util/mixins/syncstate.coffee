'use strict'
# [React Mixin] Sync State
# Listen to all declared stores
# Update state when any store changes

# Mixin Dependencies:
# Arc Stores, Arc Helpers
# Note: Change the require path to access the global framework object when modularizing
try StoreClass = require 'arc/store/class'
catch
	throw new Error '[mixin] Sync State: Build must contain Arc Store to use this mixin!'
try type = require('util/helpers').type
catch
	throw new Error '[mixin] Sync State: Build must contain Arc Helpers to use this mixin!'

# Static private methods
_getInitialState = ->
	return null if type(@stores) is 'undefined'
	@_validateStores()
	@_stores = @_getStoreArray @stores
	@_bindStores @_stores
	@_getStateFromStores()

__validateStores = ->
	stores = @stores
	if (type(stores) is 'object') and !(stores instanceof StoreClass)
		for key, val of stores
			continue if stores.hasOwnProperty? and !stores.hasOwnProperty(key)
			if !(val instanceof StoreClass)
				throw new Error '[mixin] Sync State: Invalid value in this.stores property "' + key + '"!'
	else if !(stores instanceof StoreClass)
		throw new Error '[mixin] Sync State: Invalid value this.stores!'
__getStoreArray = (stores) ->
	if stores instanceof StoreClass
		storesArr = [{
			key: undefined
			instance: stores
		}]
	else if type(stores) is 'object'
		storesArr = []
		for key, val of stores
			continue if stores.hasOwnProperty? and !stores.hasOwnProperty(key)
			storesArr.push
				key: key
				instance: val
	storesArr

__bindStores = (stores, callback) ->
	callback = @_syncWithStores unless callback
	for store in stores
		store.instance.on 'change', callback, @
__unbindStores = ->
	for store in stores
			store.instance.off()

__syncWithStores = ->
	val = @_getStateFromStores()
	@setState val
__getStateFromStores = ->
	val = undefined
	if (@_stores.length > 1) or (type(@_stores[0].key) isnt 'undefined')
		val = {}
		for store in @_stores
			val[store.key] = store.instance.get()
	else
		val = @_stores[0].instance.get()
	val

# Expects a property "stores"
# options object that defines the format of this.state
# this.stores =
# 	key1: store_instance1
# 	key2: store_instance2
#
# This will result in this.state being updated
# every time store_instance1 or store_instance2 fire a change event
# this.state ===
# 	key1: store_instance1 value
# 	key2: store_instance2 value
module.exports =
	_stores: undefined
	getInitialState: ->
		_getInitialState.call @

	_validateStores: ->
		__validateStores.call @
	_getStoreArray: (stores) ->
		__getStoreArray.call @, stores
	_bindStores: (stores, callback) ->
		__bindStores.call @, stores, callback
	_syncWithStores: ->
		__syncWithStores.call @
	_getStateFromStores: ->
		__getStateFromStores.call @

	_unbindStores: (stores) ->
		__unbindStores stores
	componentWillUnmount: ->
		@_unbindStores @_stores