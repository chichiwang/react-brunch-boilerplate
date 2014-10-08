#User Device Detections
detections =
	useragent : navigator.userAgent
	#UA detections
	ios : if navigator.userAgent.match(/(iPad|iPhone|iPod)/g) then true else false
	ios7 : if navigator.userAgent.match(/(iPad|iPhone);.*CPU.*OS 7_\d/i) then true else false
	ios7safari : !!navigator.userAgent.match(/(iPad|iPhone|iPod touch);.*CPU.*OS 7_\d/i)
	android : if navigator.userAgent.match(/Android/i) then true else false
	windows_desktop : (navigator.userAgent.match(/Windows/gi) or navigator.userAgent.match(/MSIE/gi)) and not(navigator.userAgent.match(/Touch/gi)) or false
	ieVersion : undefined #Defined in initialize()
	ie : undefined #Defined in initialize()
	ie10 : undefined #Defined in initialize()
	firefox : (navigator.userAgent.toLowerCase().indexOf('firefox') > -1)
	ffVersion: undefined
	chrome: (navigator.userAgent.lastIndexOf('Chrome/') > 0)
	chromeVersion: undefined
	safari: (navigator.userAgent.lastIndexOf('Safari/') > 0)
	safariVersion: undefined
	phone : do(a = navigator.userAgent||navigator.vendor||window.opera) -> (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(a)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4)))
	#Feature detections
	touch : undefined #Defined in initialize()
	retina : if (window.devicePixelRatio > 1) then true else false
	transitions : undefined #Defined in initialize()
	html5video : if (document.createElement('video').canPlayType) then true else false
	html5audio : if (document.createElement('audio').canPlayType) then true else false
	mp4 : undefined #Defined in initialize()
	webm : undefined #Defined in initialize()
	ogg: undefined #Defined in initialize()
	history: !!(window.history && history.pushState)
	standalone: !!window.navigator.standalone

#Custom initialize to prepare properties that are dependent on other properties
class Device
	set: (key, val)->
		@values[key] = val
	get: (key)->
		@values[key]
	constructor: (values)->
		@values = _.cloneDeep values
		@initialize()
	initialize: ->
		@prepareDetections()
		@prepareAbstractions()
	prepareDetections: ->
		#Set is_touch
		@set('touch', do =>
			touchstart = `'ontouchstart' in document.documentElement`
			(window.navigator.msMaxTouchPoints or touchstart) and not @get('windows_desktop')
		)
		#set transitions
		@set('transitions', do ->
			b = document.body || document.documentElement
			s = b.style
			p = 'transition'
			return true if typeof s[p] == 'string'
			v = ['Moz', 'Webkit', 'Khtml', 'O', 'ms']
			p = p.charAt(0).toUpperCase() + p.substr(1)
			for prefix in v
				return true if (typeof s[prefix + p] is 'string')
			false
		)
		#Set ieVersion
		@set('ieVersion', do ->
			agent = navigator.userAgent
			reg = /MSIE\s?(\d+)(?:\.(\d+))?/i
			matches = agent.match(reg)
			return { major: matches[1], minor: matches[2] } if (matches != null)
			{ major: "-1", minor: "-1" }
		)
		#Set ffVersion
		@set('ffVersion', do->
			agent = navigator.userAgent
			ff = (/Firefox[\/\s](\d+\.\d+)/.test(agent))
			ffV = Number(RegExp.$1)
			return -1 if ff is false
			ffV
		)
		#Set chromeVersion
		@set('chromeVersion', do->
			agent = navigator.userAgent
			Number agent.substr(agent.lastIndexOf('Chrome/') + 7, 2)
		)
		#Set safariVersion
		@set('safariVersion', do ->
			agent = navigator.userAgent
			Number agent.substr(agent.lastIndexOf('Version/') + 8, 2)
		)
		#Set ie
		@set('ie', do => (Number @get('ieVersion').major) > -1 )
		#Set ie10
		@set('ie10', do => (Number @get('ieVersion').major) is 10 )
		#Set mp4
		@set('mp4', do => @canPlayVideo('mp4') )
		#Set webm
		@set('webm', do => @canPlayVideo('webm') )
		#Set ogg
		@set('ogg', do => @canPlayVideo('ogg') )
	canPlayVideo: (type) ->
		vid = document.createElement('video')
		return false if !@get('html5video')
		"" isnt vid.canPlayType('video/' + type)
	prepareAbstractions: ->
		deviceDetections =
			ios : @get 'ios'
			ios7 : @get 'ios7'
			ios7safari : @get 'ios7safari'
			android : @get 'android'
			windows_desktop : @get 'windows_desktop'
			ie : @get 'ie'
			ie10 : @get 'ie10'
			firefox : @get 'firefox'
			chrome: @get 'chrome'
			safari: @get 'safari'
			phone : @get 'phone'

		featureDetections =
			touch : @get 'touch'
			retina : @get 'retina'
			transitions : @get 'transitions'
			html5video : @get 'html5video'
			html5audio : @get 'html5audio'
			mp4 : @get 'mp4'
			webm : @get 'webm'
			ogg : @get 'ogg'
			history : @get 'history'
			standalone : @get 'standalone'

		@set 'is' ,deviceDetections
		@set 'supports' ,featureDetections
	is: (device) ->
		deviceDetections = @get 'is'
		if typeof deviceDetections[device] isnt 'undefined'
			return deviceDetections[device]
		null
	supports: (feature) ->
		featureDetections = @get 'supports'
		if typeof featureDetections[feature] isnt 'undefined'
			return featureDetections[feature]
		null

#Export the object as a require module
module.exports = new Device detections