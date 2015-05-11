# スプライトの衝突判定動作テスト
 
require 'dxruby'
 
font = Font.new(12)
 
# 画像読み込み
base64_text = ""
DATA.each {|l| base64_text += l.chomp}
bin_data = base64_text.unpack('m')[0]
$imgs = Image.loadFromFileInMemory(bin_data).sliceTiles(8, 1)
 
# enemyshotimgs = [$imgs[3], $imgs[4], $imgs[5]]
 
# 度→ラジアン変換
def deg2rad(deg)
  return deg * Math::PI / 180.0
end
 
# ----------------------------------------
# プレイヤーキャラ
class Player < Sprite
  attr_accessor :bx, :by, :shottimer, :hit_timer, :flush_image
 
  # 初期化処理
  def initialize(x, y)
    super
    self.bx = x
    self.by = y
    self.image = $imgs[1]
    self.flush_image = $imgs[7]
    self.shottimer = 0
    self.collision = [16, 16, 4] # アタリ範囲を設定
    self.hit_timer = 0
 
    # self.offset_sync = true # DXRuby開発版でのみ使えるプロパティ
  end
 
  def update
    w, h = self.image.width, self.image.height
 
    # マウスカーソル座標を自機座標にする
    self.bx = Input.mousePosX
    self.by = Input.mousePosY
 
    xmin, ymin = 0, 0
    xmax, ymax = Window.width, Window.height
    self.bx = xmin if self.bx < xmin
    self.by = ymin if self.by < ymin
    self.bx = xmax if self.bx > xmax
    self.by = ymax if self.by > ymax
 
    if self.shottimer % 10 == 0
      # 自機ショットを発射
      [270, 30, 150].each do |i|
        spr = Shot.new(self.bx, self.by, 16, i + self.bx / 4)
        $shots.push(spr)
      end
    end
 
    self.shottimer += 1
    self.angle += 8
 
    if self.hit_timer > 0
      self.hit_timer -= 1
      self.hit_timer = 0 if self.hit_timer <= 0
    else
      self.hit_timer = 0
    end
 
    # 基準座標＋オフセット値を表示座標とする。
    # DXRuby開発版なら、self.offset_sync = true で済んでしまうのだけど、
    # 開発版は Ruby 1.8 や 1.9 に対応してないので…
    self.x = self.bx - w / 2
    self.y = self.by - h / 2
  end
 
  # 雑魚敵と当たった時に呼ばれる処理
  def hit(o)
    self.hit_timer = 4
  end
 
  def draw
    super
    if self.hit_timer > 0
      Window.drawScale(self.x, self.y, self.flush_image, 3, 3)
    end
  end
end
 
# ----------------------------------------
# プレイヤーの弾
class Shot < Sprite
  attr_accessor :bx, :by, :dx, :dy
 
  def initialize(x, y, spd, angle)
    self.bx = x
    self.by = y
    self.image = $imgs[0]
    self.dx = spd * Math.cos(deg2rad(angle))
    self.dy = spd * Math.sin(deg2rad(angle))
    self.angle = angle
    self.collision = [0, 13, 31, 18]
    self.collision_enable = true
    self.collision_sync = true
  end
 
  def update
    w, h = self.image.width, self.image.height
    self.bx += self.dx
    self.by += self.dy
 
    # 画面外に出たら自分を消滅させる
    xmin = - w / 2
    ymin = - h / 2
    xmax = Window.width + w / 2
    ymax = Window.height + h / 2
    if self.x < xmin or self.x > xmax or self.y < ymin or self.y > ymax
      self.vanish
    end
 
    self.x = self.bx - w / 2
    self.y = self.by - h / 2
  end
 
  # 敵に当たった場合に呼ばれるメソッド
  def shot(d)
    self.vanish # 自分を消滅させる
  end
end
 
# ----------------------------------------
# 雑魚敵
class Enemy < Sprite
  attr_accessor :bx, :by, :dir, :dx, :dy
  attr_accessor :hit_timer, :spd, :org_image, :flush_image
 
  def initialize(spd)
    self.org_image = $imgs[2]
    self.image = self.org_image
    self.flush_image =  $imgs[3]
 
    # DXRuby開発版でのみ利用可能。フラッシュ画像を作れる
    # self.flush_image = self.org_image.flush(C_WHITE)
 
    self.spd = spd
    self.collision = [0, 0, 31, 31]
    self.init
  end
 
  # 発生時の初期化処理
  def init
    self.bx = rand(Window.width)
    self.by = rand(Window.height)
    self.collision_enable = false
    self.collision_sync = false
    self.hit_timer = 0
    self.alpha = 0
  end
 
  # 更新処理
  def update
    w, h = self.image.width, self.image.height
 
    if self.alpha < 255
      # 出現中
      self.collision_enable = false
      self.alpha += 5
      if self.alpha >= 255
        self.alpha = 255
 
        # プレイヤーを狙った速度を決める
        ply = $players[0]
        self.dir = Math.atan2(ply.by - self.by, ply.bx - self.bx)
        self.dx = spd * Math.cos(self.dir)
        self.dy = spd * Math.sin(self.dir)
      end
    else
      # 移動中
 
      if self.hit_timer > 0
        # 弾が当たっているなら一定時間フラッシュさせる
        self.hit_timer -= 1
        self.collision_enable = false
 
        # フラッシュ時間が終わったら再発生
        self.init if self.hit_timer <= 0
      else
        # 弾は当たってない
        self.hit_timer = 0
        self.collision_enable = true
 
        # 移動
        self.bx += self.dx
        self.by += self.dy
 
        # 画面外に出たら再発生
        xmin = - w / 2
        ymin = - h / 2
        xmax = Window.width + w / 2
        ymax = Window.height + h / 2
        if self.x < xmin or self.x > xmax or self.y < ymin or self.y > ymax
          self.init
        end
      end
    end
 
    self.image = (self.hit_timer <= 0)? self.org_image : self.flush_image
 
    self.x = self.bx - w / 2
    self.y = self.by - h / 2
  end
 
  # プレイヤーの弾と当たった時に呼ばれるメソッド
  def hit(o)
    self.hit_timer = 4
  end
 
  # プレイヤーと当たった時に呼ばれるメソッド
  def shot(d)
  end
end
 
# ----------------------------------------
# メイン
 
# Input.mouseEnable = false # マウスカーソル非表示
 
srand(0)
$players = []
$shots = []
$enemys = []
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
 
    Sprite.update($players)
    Sprite.update($shots)
    Sprite.update($enemys)
 
    Sprite.clean($shots)
    Sprite.clean($enemys)
  end
 
  Sprite.draw($enemys)
  Sprite.draw($players)
  Sprite.draw($shots)
 
  l = $players.length + $shots.length + $enemys.length
  Window.drawFont(0, 0, "Sprs: " + ('[]' * l), font)
  Window.drawFont(0, 16, "PAUSE", font) if in_pause == 0
end
 
__END__
iVBORw0KGgoAAAANSUhEUgAAAQAAAAAgCAMAAADKd1bWAAAAwFBMVEV/AACg
AADAAADgAAD/HBz/cHD/qKj/xMT/4OAAwAAMdwBN/03/////Ziv/hk3/p3D/
x5OROADaLAAwMDBgYGCUlJSwsLDg4ODExMT///+goKSyAKwAAAAAAAAAAAAA
AAD/////ior/KyubAAD/////u4n/mSuacwDLy8vvdi7EUgCJBgD/Kyv/biv/
dCv/uSsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAACCWjOjAAAAHHRSTlP/////////////////////////////////
//8AF7Li1wAAA0tJREFUeJzlmd2SokAMhbVquNhdB91tcKW4USj1wkLe/+02
P40ESDN2iyNbnuJiTKYczjdJaLoXuYfSdAdK005wJ6UEMinMDwLfpsJKxhY+
X2ASIJAmRsa20q4xg0CW9QwPAt8ksv4J6jLwAoAIuvbB7zZtRQC6gZkAYPcV
iRnYhBcArQXArzE6AIjPBQDZv8anGHSKr4SAM4+3AADYOQDs5gIA/V/jeL0+
gtbrGBA0BN6iBfDfD/aPG/64OQICLAL88HAL5InpKukEBoZf478C+zIECCom
8HAL5H/FyG/UhmYAAOu/558IcBdMMQOaajdmScKfXC0wTgCnc1m6bwBn+OXi
zteg87kX1Pw3BCYEQPY/UIwgAECzTnEhqKxc+dqqm6f5N/APBGgSegGA/say
Towk0AJYfkQoQhACoCgOh8MIgaqC/AiBuob8kAAVgPb7XAIeAND/T1CXgAVA
/rOsT8ADAPrfjxBA//sRAuh/rxBwFIAtga8BpIYvQ/5/gIgAGMzpagFE6IcJ
BAGA+99bAioAm3cCsPkeACqAjeZsQyWgA9iw8PbShC8Q+P8FQgKgNKdrawc/
FUCnBFj3AoAC2KNcJQAFwHlHCUABcL5XAkVRndQOgB44VQoAXC+B2D/c344W
dLjWI/+rFRHAj4auvAVgW6AD4O7HYCErQAfQVoAOoK0ACQDWAGoHYA/AWmDx
m/QHhG9KnzGJCPAdwtCjCwQAViAEQMOQLv6u2wgUAOTfGvVuAYgZoAIQM0AF
IGbAqwFEYQBuTwHwrwG4PQUqJV/X7VOgLj0A9KPeLWAXgbAGuPnPIgSgbYi4
KZSFkGLwUgkp+XMt9AgAks8QbAA0BKABomUD4P4h+DQAvkOwr/sfgx+s0HVA
Oeof8qP+Ia/6D3wMqvpqIcQEoP55MewNoBT+NYOl8K/mhf8JF0I9AmNLYUYQ
LZdhS+GSEZS6P8o39l35xv5zlsJ3vAw1CnsZKm/S/3xYfsKXIX0/QO5/tK/D
YRsiY/aC809+HX6rDRHHrrDcAhSbIQEbIs/RdFtib78p6toWn/25wFTb4q6D
kdmfC0x1MPK/tkA+1dGY2gLdU4FBYCYApjkcVQ9Gev4HgYHd1/hHacfj/wAC
/D82nEMmSwAAAABJRU5ErkJggg==
