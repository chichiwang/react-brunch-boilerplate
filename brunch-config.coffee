exports.config =
	plugins:
		react:
			autoIncludeCommentBlock: yes
	files:
		javascripts:
			joinTo:
				'javascripts/app.js': /^app/
				'javascripts/vendor.js': /^(?!app)/
			order:
				before: [
					'bower_components/react/react.js'
				]
		stylesheets:
			joinTo: 'stylesheets/app.css'