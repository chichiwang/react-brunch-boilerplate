'use strict'

SET = "SET_STORE:ROUTER:STATE"
REPLACE = "REPLACE_STORE:ROUTER:STATE"
ns = require 'util/namespace'
StoresClass = require 'flux/stores/class'

ns.store = ns.store or {}
ns.store.router = ns.store.router or {}
ns.store.router.state = ns.store.router.state or new StoresClass
	SET: SET
	REPLACE: REPLACE
	defaultValue:
		page: undefined
		path: undefined

module.exports = ns.store.router.state