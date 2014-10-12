'use strict'

SET = "SET_STORE:SITE:STATE"
REPLACE = "REPLACE_STORE:SITE:STATE"
StoresClass = require 'flux/stores/class'

siteStore = siteStore or new StoresClass
	SET: SET
	REPLACE: REPLACE
	defaultValue:
		width: undefined
		height: undefined

module.exports = siteStore