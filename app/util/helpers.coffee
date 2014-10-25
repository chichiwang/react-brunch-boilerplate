hasOwnProperty = Object::hasOwnProperty
objectCreate = Object.create
if typeof objectCreate isnt 'function'
	objectCreate = (o)->
		F = ->
		F.prototype = o
		return new F()

module.exports = Helpers =
	isEmpty: (obj) ->
		if (obj is null) or (typeof obj is 'undefined')
			return true

		return false if typeof obj is 'boolean'

		return false if obj.length > 0
		return true if obj.length is 0

		if (typeof Object.getOwnPropertyNames is 'function') and (typeof obj is "object")
			return false if Object.getOwnPropertyNames(obj).length > 0
		else
			for key in obj
				return false if hasOwnProperty.call(obj, key)
		true
	isArray: (obj) ->
		return true if Object::toString.call(obj) is '[object Array]'
		return false
	# A mix of solutions from:
	# http://stackoverflow.com/questions/122102/what-is-the-most-efficient-way-to-clone-an-object/13333781#13333781
	# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
	clone: (obj, _copied) ->
		# Null or Undefined
		if not obj? or typeof obj isnt 'object'
			return obj

		# Init _copied list (used internally)
		if typeof _copied is 'undefined'
			_copied = []
		else return obj if obj in _copied
		_copied.push obj

		# Native/Custom Clone Methods
		return obj.clone(true) if typeof obj.clone is 'function'
		# Array Object
		if Object::toString.call(obj) is '[object Array]'
			result = obj.slice()
			for el, idx in result
				result[idx] = @clone el, _copied
			return result
		# Date Object
		if obj instanceof Date
			return new Date(obj.getTime())
		# RegExp Object
		if obj instanceof RegExp
			flags = ''
			flags += 'g' if obj.global?
			flags += 'i' if obj.ignoreCase?
			flags += 'm' if obj.multiline?
			flags += 'y' if obj.sticky?
			return new RegExp(obj.source, flags)
		# DOM Element
		if obj.nodeType? and typeof obj.cloneNode is 'function'
			return obj.cloneNode(true)

		# Recurse
		proto = if Object.getPrototypeOf? then Object.getPrototypeOf(obj) else obj.__proto__
		proto = obj.constructor.prototype unless proto
		result = objectCreate proto
		for key, val of obj
			result[key] = @clone val, _copied
		return result
	merge: (destination, sources...) ->
		# TODO: Write a deep extend method
		console.log 'Helpers.merge: ', destination, sources