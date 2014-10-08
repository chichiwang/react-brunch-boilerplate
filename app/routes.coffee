'use strict'

module.exports = RouterConfig = 
  initial: '!/'
  defaultTransition: 'fade'
  paths:
    '!/': 
      routeId:'home'
    '!/home': 
      routeId:'home'
    '**':
      routeId: '404'
      path: '/404.html'