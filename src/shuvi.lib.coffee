##
#
# shuvi-lib
# YouTube IFrame Player APIをゆるふわにラッピングしたライブラリ
#
# @author     yuki540
# @package    Shuvi
# @twitter    @eriri_jp
# @repository https://github.com/yuki540net/shuvi-lib
# @license    MIT license
#
##
class Shuvi
	constructor: (params) ->
		@version = '1.0.5'
		@art()

		# selector
		@id = params.id

		# video_id
		@video_id = params.video_id

		# size
		@width  = params.width
		@height = params.height

		# state
		@autoplay  = params.autoplay
		@_loop     = params.loop

		if @autoplay is undefined
			@autoplay = true

		if @_loop is undefined
			@_loop = false
		
		@first     = false
		@load      = false
		@timer     = null
		@listeners = []

		# player object
		@player = null
		window.onYouTubeIframeAPIReady = =>
			@render()

		# 埋め込み
		@init()

	##
	# ライブラリ情報
	##
	art: ->
		console.log ''
		console.log 'shuvi-lib -> version ' + @version
		console.log ''

		return true

	##
	# scriptの埋め込み
	##
	init: ->
		script     = document.createElement 'script'
		script.src = 'https://www.youtube.com/iframe_api'
		document.head.appendChild script

		return true

	##
	# イベントの発火
	# @param event : イベント名
	# @param data  : データ
	##
	emit: (event, data) ->
		for listener in @listeners
			if event is listener.event
				listener.fn data

		return true

	##
	# イベントリスナの追加
	# @param event : イベント名
	# @param fn    : コールバック関数
	##
	on: (event, fn) ->
		@listeners.push {
			event : event
			fn    : fn
		}
		return true

	##
	# 描画
	##
	render: ->
		@player   = new YT.Player @id, {
			width   : @width
			height  : @height
			videoId : @video_id
			events  : {
				onReady : @onReady
				onError : @onError
			}
		}
		return true

	##
	# 読み込み完了
	##
	onReady: (e) =>
		# 初回のみ
		if not @first
			@change @video_id
			@first = true
			return

		@load = true
		if @autoplay
			@play()
		@emit 'load', { video_id: @video_id }

	##
	# 読み込み失敗
	##
	onError: (e) =>
		@load = false
		@emit 'error', { video_id: @video_id }

	##
	# 動画の変更
	# @param video_id : 動画ID
	##
	change: (video_id) ->
		@pause()

		@video_id  = video_id
		@load      = false
		url1       = 'https://www.youtube.com/embed/'
		url2       = '?enablejsapi=1&widgetid=1&controls=0&showinfo=0'
		iframe     = document.getElementById @id
		iframe.src = url1 + @video_id + url2

		if @first
			@emit 'change', { video_id: @video_id }

	##
	# 現在、設定しいる動画IDを取得
	# @return video_id : 動画ID
	##
	getVideoID: ->
		return @video_id

	##
	# 再生
	# @return bool
	##	
	play: ->
		if not @load
			return false

		# 再生
		@player.playVideo()
		@emit 'play', { video_id: @video_id }

		# 再生監視
		@timer = setInterval =>
			duration = @duration()
			current  = @current()
			@emit 'seek', {
				video_id : @video_id[@number]
				current  : current 
				duration : duration
				per      : current / duration
			}

			# 再生終了
			if duration <= current
				@emit 'end', { video_id: @video_id }

				if @_loop
					@seek 0
				else 
					@pause()
		, 100

		return true

	##
	# 停止
	# @return bool
	##
	pause: ->
		if not @load
			return false
		
		@player.pauseVideo()
		@emit 'pause', { video_id: @video_id }
		clearInterval @timer
		return true

	##
	# ループ
	# @param bool : true or false
	##
	loop: (bool) ->
		if bool is true
			@_loop = true
		else
			@_loop = false

		return true

	##
	# 移動
	# @param per : 0~1
	##
	seek: (per) ->
		if not @load
			return false

		duration = @duration()
		current  = duration * per

		@player.seekTo current
		@emit 'seek', {
			video_id : @video_id
			current  : current 
			duration : duration
			per      : current / duration
		}
		return true

	##
	# 動画時間
	# @return duration
	##
	duration: ->
		return @player.getDuration()

	##
	# 現在時間
	# @return current
	##
	current: ->
		return @player.getCurrentTime()

	##
	# 読み込み状況
	# @return buffer
	##
	buffer: ->
		return @player.getVideoLoadedFraction()

	##
	# 音量の取得
	# @return volume
	##
	getVolume: ->
		return @player.getVolume() / 100

	##
	# 音量の設定
	# @param volume : 0~1
	##
	setVolume: (volume) ->
		if not @load
			return false

		@player.setVolume volume * 100
		return true

	##
	# サイズ変更
	# @param width  : 幅
	# @param height : 高さ
	##
	resize: (width, height) ->
		@width  = width
		@height = height
		@player.setSize @width, @height

		@emit 'resize', {
			width  : @width
			height : @height
		}
		return true

	##
	# 動画IDの取得
	# @param url : URL
	# @return video_id
	##
	getId: (url) ->
		match = url.match /v=.*/
		if not match
			return false

		match    = match[0].split '&'
		video_id = match[0].replace /^v=/, ''

		return video_id

try 
	module.exports = Shuvi
catch