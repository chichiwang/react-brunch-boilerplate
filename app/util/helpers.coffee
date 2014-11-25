'use strict'

# [method] isEmpty
# Checks if a variable is empty
hasOwnProperty = Object::hasOwnProperty
_isEmtpy = (obj) ->
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

# [method] type
# A stricter, less error-prone type detection method
# Borrowed from:
# http://arcturo.github.io/library/coffeescript/07_the_bad_parts.html
classToType = do ->
	objectMap = {}
	for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
		objectMap["[object " + name + "]"] = name.toLowerCase()
	objectMap
_type = (obj) ->
	return 'undefined' if typeof obj is 'undefined'
	strType = Object::toString.call(obj)
	classToType[strType] or "object"

# [method] clone
# A mix of solutions from:
# http://stackoverflow.com/questions/122102/what-is-the-most-efficient-way-to-clone-an-object/13333781#13333781
# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
objectCreate = Object.create
if typeof objectCreate isnt 'function'
	objectCreate = (o) ->
		F = ->
		F.prototype = o
		return new F()
_clone = (obj, _copied) ->
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
	if type(obj) is 'array'
		result = obj.slice()
		for el, idx in result
			result[idx] = clone el, _copied
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
		result[key] = clone val, _copied
	return result

# [method] documentReady
# Executes a function on document ready
# Borrowed from:
# http://stackoverflow.com/a/9899701/1161897
readyList = []
readyFired = false
readyBound = false
_ready = ->
	return if readyFired
	readyFired = true
	for listItem in readyList
		context = if listItem.hasOwnProperty? and listItem.hasOwnProperty('ctx') then listItem.ctx else window
		listItem.fn.call context
	readyList = []
_documentReady = (callback, context) ->
	# if ready has already fired, then just schedule the callback
	# to fire asynchronously, but right away
	if readyFired
		setTimeout ->
			callback.call context
		, 1
	# else add the function and context to the list
	else
		listItem = {}
		listItem.fn = callback
		listItem.ctx = context if type(context) isnt undefined
		readyList.push listItem
	# if document already ready to go, schedule the ready function to run
	if document.readyState is 'complete'
		setTimeout _ready, 1
	# if document isn't ready and the ready event listeners haven't been bound
	else if not readyBound
		if document.addEventListener
			# first choice is DOMContentLoaded event
			document.addEventListener "DOMContentLoaded", _ready, false
			# backup is window load event
			window.addEventListener "load", _ready, false
		readyBound = true


# Bundle helper methods for export
Helpers =
	isEmpty: (args...) ->
		_isEmtpy.apply @, args
	type: (args...) ->
		_type.apply @, args
	
	clone: (args...) ->
		_clone.apply @, args
	documentReady: (args...) ->
		_documentReady.apply @, args

type = Helpers.type
clone = Helpers.clone

module.exports = Helpers