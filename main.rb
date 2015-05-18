require 'dxruby'
require './jiki.rb'
require './jikibullet.rb'
require './enemy.rb'
require './enemybullet.rb' # 敵弾クラス読み込み
 
font = Font.new(12)
 
# 画像読み込み
# base64_text = ""
# DATA.each {|l| base64_text += l.chomp}
# bin_data = base64_text.unpack('m')[0]
# $imgs = Image.loadFromFileInMemory(bin_data).sliceTiles(8, 1)
# enemyshotimgs = [$imgs[3], $imgs[4], $imgs[5]]
 
# 度→ラジアン変換
def deg2rad(deg)
  return deg * Math::PI / 180.0
end
 
 
# ----------------------------------------
# メイン
 
# Input.mouseEnable = false # マウスカーソル非表示
 
srand(0)
$players = []
$shots = []
$enemys = []
$eshots = [] # 敵弾の配列。未実装で、今から勝手に実装する予定。
$players.push(Player.new(0, 0))
8.times {|i| $enemys.push(Enemy.new(2))}
 
in_pause = false
 
Window.loop do
  break if Input.keyPush?(K_ESCAPE)
 
  update_enable = false
  if in_pause
    # ポーズ中
 
    # Nキー押しで1フレーム進める
    update_enable = true if Input.keyPush?(K_N)
 
    # Pキーを押したらポーズ解除
    in_pause = false if Input.keyPush?(K_P)
  else
    # 通常処理
    in_pause = true if Input.keyPush?(K_P) # Pキーを押したらポーズ
    update_enable = true unless in_pause
  end
 
  if update_enable
    # プレイヤーの弾と雑魚敵の衝突判定
    Sprite.check($shots, $enemys)
 
    # 雑魚敵とプレイヤーの衝突判定
    Sprite.check($enemys, $players)
    # 敵弾とプレイヤーの衝突判定
    Sprite.check($eshots, $players) # 敵弾に自機が撃たれた場合はこちら。
 
    Sprite.update($players)
    Sprite.update($shots)
    Sprite.update($enemys)
    Sprite.update($eshots) # 敵弾を更新
 
    Sprite.clean($shots)
    Sprite.clean($enemys)
    Sprite.clean($eshots) # 敵弾を掃除
  end
 
  Sprite.draw($enemys)
  Sprite.draw($players)
  Sprite.draw($shots)
  Sprite.draw($eshots) # 敵弾描画
 
  l = $players.length + $shots.length + $enemys.length
  Window.drawFont(0, 0, "Sprs: " + ('[]' * l), font)
  Window.drawFont(0, 16, "PAUSE", font) if in_pause == 0
end
 