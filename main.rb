require 'dxruby'
require './jiki.rb'
require './jikibullet.rb'
require './enemy.rb'
 
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

