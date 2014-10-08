'use strict'

# Create/Retrieve a window level object
# Encapsulates all app data under a single namespace
namespace = 'App'
globals = if _.isUndefined(window) then global else window

wrapper = globals[namespace] or { key: namespace }
globals[namespace] = wrapper

module.exports = wrapper
module.app = wrapper