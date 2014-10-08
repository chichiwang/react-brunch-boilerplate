exports.config =
	modules:
		nameCleaner: (path)->
			# Custom lookup for react components
			if (path.match(/^app\/components\/(\w)*\/index.coffee$/))
				newPath = path.replace /^app\/components\//, ''
				return newPath.replace /\/index.coffee$/, ''
			# Custom lookup for components
			if (path.match(/^app\/components\/(\w)*\//))
				return path.replace /^app\/components\//, ''
			# Default lookup
			return path.replace /^app\//, ''
	files:
		javascripts:
			joinTo:
				'javascripts/app.js': /^app/
				'javascripts/vendor.js': /^(?!app)/
		stylesheets:
			joinTo: 'stylesheets/app.css'