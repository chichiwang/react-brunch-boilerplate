exports.config =
	modules:
		nameCleaner: (path)->
			# Default lookup
			return path.replace /^app\//, ''
	files:
		javascripts:
			joinTo:
				'javascripts/app.js': /^app/
				'javascripts/vendor.js': /^(?!app)/
		stylesheets:
			joinTo: 'stylesheets/app.css'