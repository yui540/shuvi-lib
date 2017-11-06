import { EventEmitter } from 'events';

export default class Shuvi extends EventEmitter {
  constructor(params) {
    super();

    this.video_id = params.video_id;
    this.width = params.width;
    this.height = params.height;
    this._ele = params.ele;
    this._player = null;
    this._autoplay = (params.autoplay === undefined) ? false : params.autoplay;
    this._loop = (params.loop === undefined) ? false : params.loop;
    this._load = false;
    this._timer = null;

    window.onYouTubeIframeAPIReady = () => {
      this.render();
    }

    this.mountScriptTag();
  }

  /**
   * scriptタグのマウント
   */
  mountScriptTag() {
    const script = document.createElement('script');
    script.src = 'https://www.youtube.com/iframe_api';
    document.head.appendChild(script);
  }

  /**
   * 描画
   */
  render() {
    this._player = new YT.Player(this._ele, {
      width: this.width,
      height: this.height,
      videoId: this.video_id,
      events: {
        onReady: this.onReady.bind(this),
        onError: this.onError.bind(this)
      }
    })
  }

  /**
   * 読み込み完了
   */
  onReady() {
    this._load = true;
    this.resize(this.width, this.height);
    this.emit('ready', { video_id: this.video_id });
  }

  /**
   * 読み込み失敗
   */
  onError() {
    this.load = false;
    this.emit('error', { video_id: this.video_id });
  }

  /**
   * 動画の変更
   * @param video_id : 動画ID
   */
  changeVideo(video_id) {
    
  }

  /**
   * 画面をリサイズ
   * @param width  : 幅
   * @param height : 高さ
   */
  resize(width, height) {
    this.width = width;
    this.height = height;
    
    this.emit('resize', {
      width: this.width,
      height: this.height
    });
      
    this._player.setSize(this.width, this.height);
  }

  /**
   * 再生
   */
  play() {
    if(!this.load) return false;
    
    this._player.playVideo();
    this.emit('play');
    
    this.timer = setInterval(() => {
      let duration = this.getDuration();
      let current_time = this.getCurrentTime();

      this.emit('seek', {
        video_id: this.video_id,
        current_time: current_time,
        duration: duration,
        per: current_time / duration
      });

      if(duration <= current_time) {
        this.emit('end', { video_id: this.video_id });

        if(this._loop) this.seek(0);
        else this.pause();
      }
    }, 100);
  }

  /**
   * 停止
   */
  pause() {
    if(!this.load) return false;

    this._player.pauseVideo();
    this.emit('pause');
    clearInterval(this.timer);
  }

  /**
   * ループ
   * @param bool : true or false
   */
  loop(bool) {
    this._loop = bool === true;
  }

  /**
   * 再生位置の移動
   * @param per : 0 ~ 1
   */
  seek(per) {
    if(!this.load) return false;

    let duration = this.getDuration();
    let current_time = duration * per;

    this._player.seekTo(current_time);
    this.emit('seek', {
      video_id: this.video_id,
      current_time: current_time,
      duration: duration,
      per: current_time / duration
    });
  }

  /**
   * 動画時間の取得
   * @return duration
   */
  getDuration() {
    return this._player.getDuration();
  }

  /**
   * 現在の再生時間を取得
   * @return current_time
   */
  getCurrentTime() {
    return this._player.getCurrentTime();
  }

  /**
   * 読み込みバッファの取得
   * @return buffer
   */
  getVideoLoadedFraction() {
    return this._player.getVideoLoadedFraction();
  }

  /**
   * 音量の取得
   * @return volume
   */
  getVolume() {
    return this._player.getVolume() / 100;
  }

  /**
   * 音量の設定
   * @param volume : 0 ~ 100
   */
  setVolume(volume) {
    this._player.setVolume(volume);
  }

  /**
   * 動画URLから動画IDの取得
   * @param url : 動画URL
   * @return video_id
   */
  static getVideoId(url) {
    const match = url.match(/v=(.+)/);
    if(!match || !match[1]) return false;

    const video_id = match[1].split('&')[0];
    return video_id;
  }
}

window.Shuvi = Shuvi
