# shuvi-lib
shuvi-libは、YouTube IFrame Player APIをゆるふわにラッピングしたライブラリです。

![shuvi-lib](./__sample__/shuvi-lib.jpg)

- shuvi-libについての紹介ページ
  - [Qiita - ]()
  - [はてなブログ - ]()
- 開発者
  - yuki540
  - [Twitter - @eriri_jp](https://twitter.com/eriri_jp)
  - [HP - yuki540.com](http://yuki540.com)

## Download
shuvi-libの使う方法はいくつかあります。

一つ目は、[GitHubページ](https://github.com/yuki540net/shuvi-lib)からダウンロードして自分のプロジェクトに置き、使う方法。

二つ目は、shuvi-libはnpm上で公開されているので、

```
npm install shuvi-lib
```

のようにnpmコマンドを使ってプロジェクトに取り込む方法。

三つ目は、私、yuki540のサーバー経由でネットワーク越しにプロジェクトに取り込む方法です。

```javascript
<script src="api.yuki540.com/shuvi-lib/v0.0.1/shuvi.lib-js">
```

## Usage
shuvi-libを使えば、YouTube IFrame Player APIをより簡単に操作することが可能です。

shuvi.lib.jsを取り込み、下記のようにパラメータを渡し、newすれば、すぐにプレイヤーの操作が可能になります。

```javascript:demo.js
let shuvi = new Shuvi({
  video_id : 'fQN2WC_Acpg', // 動画ID
  id       : 'player',      // 要素のID
  width    : 500,           // 画面の幅
  height   : 300            // 画面の高さ
})
```

## Methods
shuvi-libは、できるだけシンプルでわかりやすいメソッド名にしています。

#### イベントリスナの追加
shuvi.on(event, fn)
- [param]event: イベント名
- [param]fn: コールバック関数

#### 動画の変更
shuvi.change(video_id)
- [param]video_id: 動画ID

#### 再生
shuvi.play()

#### 停止
shuvi.pause()

#### ループの有無
shuvi.loop(bool)
- [param]bool: trueの場合、ループ有。falseの場合、ループ無。

デフォルトは、ループ無です。

#### 再生位置の移動
shuvi.seek(per)
- [param]per: 0~1の数値

#### 動画の総時間
duration = shuvi.duration()
- [return]duration: 動画の総時間

#### 現在の再生時間
current = shuvi.current()
- [return]current: 現在の再生時間

#### 動画の読み込み状況
buffer = shuvi.buffer()
- [return]buffer: 動画の読み込み具合（0~1）

#### 音量の取得
volume = getVolume()
- [return]volume: 0~1の値

#### 音量の設定
shuvi.setVolume(volume)
- [param]volume: 0~1の値

#### サイズの変更
shuvi.resize(width, height)
- [param]width: 画面の幅
- [param]height: 画面の高さ

#### 動画URLから動画IDの取得
video_id = getId(url)
- [param]url: YouTubeの動画URL
- [return]video_id: 動画ID

## Events
shuvi-libは、プレイヤーの動作ごと挙動をイベントとして呼び出されます。

- load
  - 動画の起動読み込み終了時に呼び出されます。
- error
  - 動画の読み込み・再生の失敗時に呼び出されます。
- change
  - 動画の変更時に呼び出されます。
  - 初回の動画の時には、発火されません。
- play
  - 動画再生時に呼び出されます。
- pause
  - 動作停止時に呼び出されます。
- seek
  - 動画の再生時間が変更されるたびに呼び出されます。
- end
  - 動画の再生が終了時に呼び出されます。

## Lisence
このライブラリは、MIT Lisenceのもとで公開されています。