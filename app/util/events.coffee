#Input strings

inputEvents =
	# Mouse-and-Touch Events
	all:
		click  : 'click'
		blur   : 'blur'
		focus  : 'focus'
		resize : 'resize'
		scroll : 'scroll'
		over   : 'mouseover'
		out    : 'mouseout'
		change : 'change'
		orientationchange : 'orientationchange'
		transitionend: 'transitionend msTransitionEnd webkitTransitionEnd'
		animationend: 'animationend MSAnimationEnd webkitAnimationEnd'
		hashchange: 'hashchange'

	# Media events
	media:
		end : 'ended'
		play	 : 'play'
		pause	 : 'pause'
		setmute  : 'mute'

	actions:
		routechange: 'APP:ROUTECHANGE' # Dispatch when route changes
		primesite: 'SITE:PRIME' # Dispatch when you want to prime the site for transitions

module.exports = inputEvents
