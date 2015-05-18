# スプライトの衝突判定動作テスト
 
require 'dxruby'
 
 
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
 