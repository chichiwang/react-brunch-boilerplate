ns = require 'util/namespace'

declaredRoutes =
	'': ->
		console.log 'Default Router: Home'
	'/test': ->
		console.log 'Default Router: Test'

ns.routes = ns.routes or {}

module.exports = (passedRoutes)->
	routes = passedRoutes or declaredRoutes
	if not _.isEmpty(passedRoutes)
		return ns.routes.router = Router(routes).init('/')
	else
		return ns.routes.router = ns.router or Router(routes).init('/')