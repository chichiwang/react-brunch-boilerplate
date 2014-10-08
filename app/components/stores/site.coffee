'use strict'

SET = "SET_STORE:SITE:STATE"
REPLACE = "REPLACE_STORE:SITE:STATE"
ns = require 'util/namespace'
StoresClass = require 'flux/stores/class'

ns.store = ns.store or {}
ns.store.site = ns.store.site or {}
ns.store.site.state = ns.store.site.state or new StoresClass
	SET: SET
	REPLACE: REPLACE
	defaultValue:
		width: undefined
		height: undefined

module.exports = ns.store.site.state