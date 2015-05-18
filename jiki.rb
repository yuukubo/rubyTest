# スプライトの衝突判定動作テスト
 
require 'dxruby'
 
 
# ----------------------------------------
# プレイヤーキャラ
class Player < Sprite
  attr_accessor :bx, :by, :shottimer, :hit_timer, :flush_image
 
  # 初期化処理
  def initialize(x, y)
    super
    self.bx = x
    self.by = y
    self.image = Image.load("jiki.png")
    self.flush_image = Image.load("jiki_flush.png")
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
#      Window.drawScale(self.x, self.y, self.flush_image, 3, 3)
      Window.draw(self.x, self.y, self.flush_image)
    end
  end
end
 