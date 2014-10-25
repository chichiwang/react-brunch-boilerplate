hasOwnProperty = Object::hasOwnProperty

module.exports = Helpers =
	isEmpty: (obj) ->
		if (obj is null) or (typeof obj is 'undefined')
			return true

		if typeof obj is 'boolean'
			return !obj

		return false if obj.length > 0
		return true if obj.length is 0

		if (typeof Object.getOwnPropertyNames is 'function') and (typeof obj is "object")
			return false if Object.getOwnPropertyNames(obj).length > 0
		else
			for key in obj
				return false if hasOwnProperty.call(obj, key)
		true