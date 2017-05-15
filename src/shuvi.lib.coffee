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
		# info
		@version = '1.0.0'
		@author  = 'yuki540'
		@twitter = 'https://twitter.com/eriri_jp'
		@github  = 'https://github.com/yuki540net/shuvi-lib'
		@art()

		# selector
		@id = params.id

		# video_id
		@number   = 0
		@video_id = params.video_id

		# size
		@width  = params.width
		@height = params.height

		# state
		@autoplay  = params.autoplay || true
		@_loop     = params.loop     || false
		@first     = false
		@load      = false
		@timer     = null
		@listeners = []

		# player object
		@player = null

		# 埋め込み
		@init()

	##
	# ライブラリ情報
	##
	art: ->
		console.log ''
		console.log 'shuvi-lib -> version ' + @version
		console.log '  - author:     ' + @author
		console.log '  - twitter:    ' + @twitter
		console.log '  - repository: ' + @github
		console.log ''

	##
	# scriptの埋め込み
	##
	init: ->
		script     = document.createElement 'script'
		script.src = 'https://www.youtube.com/iframe_api'
		document.head.appendChild script

		window.onYouTubeIframeAPIReady = =>
			@render()

	##
	# イベントの発火
	# @param event : イベント名
	# @param data  : データ
	##
	emit: (event, data) ->
		for listener in @listeners
			if event is listener.event
				listener.fn data

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

	##
	# 描画
	##
	render: ->
		@player   = new YT.Player @id, {
			width   : @width
			height  : @height
			videoId : @video_id[@number]
			events  : {
				onReady : @onReady
				onError : @onError
			}
		}

	##
	# 読み込み完了
	##
	onReady: (e) =>
		# 初回のみ
		if not @first
			@change @video_id[@number]
			@first = true
			return

		@load = true
		if @autoplay
			@play()
		@emit 'load', { video_id: @video_id[@number] }

	##
	# 読み込み失敗
	##
	onError: (e) =>
		@load = false

		@emit 'error', { video_id: @video_id[@number] }

	##
	# 動画の変更
	# @param video_id : 動画ID
	##
	change: (video_id) ->
		@pause()

		@load      = false
		url1       = 'https://www.youtube.com/embed/'
		url2       = '?enablejsapi=1&widgetid=1&controls=0&showinfo=0'
		iframe     = document.getElementById @id
		iframe.src = url1 + video_id + url2

		if @first
			@emit 'change', { video_id: video_id }

	##
	# プレイリストの設定
	# @param playlist: 動画IDの入った配列
	##
	setPlaylist: (playlist) ->
		@video_id = playlist
		@number   = 0
		@change @video_id[@number]
		return true

	##
	# 次の動画
	##
	next: ->
		if (@video_id.length - 1) <= @number
			@number = 0
		else 
			@number += 1

		@change @video_id[@number]
		return true

	##
	# 前の動画
	##
	back: ->
		if 0 >= @number
			@number = @video_id.length - 1
		else 
			@number -= 1

		@change @video_id[@number]
		return true

	##
	# プレイリスト内の指定の動画を選択
	# @param num : プレイリスト番号
	##
	select: (num) ->
		num = parseInt num

		if (@video_id.length - 1) >= num and 0 <= num
			@number = num
			@change @video_id[@number]
			return true
		else 
			return false

	##
	# 再生
	# @return bool
	##	
	play: ->
		if not @load
			return false

		# 再生
		@player.playVideo()
		@emit 'play', { video_id: @video_id[@number] }

		# 再生監視
		@timer = setInterval =>
			duration = @duration()
			current  = @current()

			# 再生終了
			if duration <= current
				@emit 'end', { video_id: @video_id[@number] }

				# ループ
				if @_loop
					@seek 0

				# 次の動画
				else
					if (@video_id.length - 1) <= @number
						@number = 0
					else
						@number += 1

					@change @video_id[@number]

			# シーク
			@emit 'seek', {
				video_id : @video_id[@number]
				current  : current 
				duration : duration
				per      : current / duration
			}
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
		@emit 'pause', { video_id: @video_id[@number] }
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
			video_id : @video_id[@number]
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