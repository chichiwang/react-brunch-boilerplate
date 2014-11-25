'use strict'

module.exports = RouterConfig = 
	initial: '!/'
	defaultTransition: 'fade'
	paths:
		'!/': 
			routeId: 'home'
		'!/home': 
			routeId: 'home'
		'!/test':
			routeId: 'test'
		'**':
			routeId: '404'
			path: '/404.html'