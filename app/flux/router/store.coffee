'use strict'

SET = "SET_STORE:ROUTER:STATE"
REPLACE = "REPLACE_STORE:ROUTER:STATE"
StoresClass = require 'flux/stores/class'

routerStore = routerStore or new StoresClass
	SET: SET
	REPLACE: REPLACE
	defaultValue:
		routeId: undefined
		path: undefined
		prevState: undefined
		curState: undefined
		transition: undefined
		transitioned: true

module.exports = routerStore