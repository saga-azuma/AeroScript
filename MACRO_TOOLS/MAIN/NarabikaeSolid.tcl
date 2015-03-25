#############################################################################
# hexa の節点を並び変えて、要素座標系を変えるマクロ
# - z軸（直線) と xパス（曲線) を指定できる
# proc main　から開始
#############################################################################
#############################################################################
#history:
# 2012.04.18
# - 外部ファイルに書き出してから、上書き読み込みすることに。
# -- 汎用化は遠のいた
# - 読み込みと同時に起動するように
#
# 2011.11.09
# - ループに入る前に節点マークを作っておくことに変更。ちらちら防止。
#
#
#############################################################################
# namespace 定義
#############################################################################
namespace eval NarabikaeSolid {
  variable win;  # 窓系
  variable val;  # このマクロ内で使われる変数
}

#############################################################################
# メインというか、窓を作る前の前処理
#############################################################################
proc NarabikaeSolid::main args {
  # ソルバーチェック
  # どのソルバでも大丈夫だとは思うけど、とりあえず bulk のみ
  switch [hm_getsolver] {
    nastran {}
    optistruct {}
    default {tk_messageBox -message "[hm_getsolver] に未対応"; return;}
  }
  NarabikaeSolid::gui
}

#############################################################################
# 窓
#############################################################################
proc NarabikaeSolid::gui args {
  variable win; 
  variable val
  set win(name) "narabikaesolid"; # toplevel name
  set win(base) ".$win(name)";

  # もう窓が起動していたら return
  if { [ winfo exists $win(base) ] } {
    tk_messageBox -message "すでに起動しています" -type "ok" -icon info -title "Information";
    focus $win(base);
    return;
  }
  
  # トップレベル
  toplevel $win(base);
  # 窓はいつでも前にある
  wm attributes $win(base) -topmost 1;

  # 要素選択窓
  set val(selected_elems) {}; #選択要素は selected_elems に格納
  pack [button $win(base).b01 -text "要素" -bg #e6e664 -command NarabikaeSolid::elemselect ]

  # z軸ベクトルを選択
  set val(z_vector) {1 0 0} ; # z_vector が基準 z ベクトル
  pack [labelframe $win(base).f2 -text "Z 軸方向" ]
  pack [radiobutton $win(base).f2.rb01 -text x -variable NarabikaeSolid::val(z_vector) -value {1 0 0} -command NarabikaeSolid::reset_twonode_select]
  pack [radiobutton $win(base).f2.rb02 -text y -variable NarabikaeSolid::val(z_vector) -value {0 1 0} -command NarabikaeSolid::reset_twonode_select]
  pack [radiobutton $win(base).f2.rb03 -text z -variable NarabikaeSolid::val(z_vector) -value {0 0 1} -command NarabikaeSolid::reset_twonode_select]
  pack [button $win(base).f2.b01 -bg yellow -text "2点で指定" -command NarabikaeSolid::twonodes_dir ]
    
  # x軸パスを選択
  set val(x_path_type) nodes ;# x軸パスのラインタイプ
  set val(x_path_nodes) {} ; #x軸パスの節点 id
  pack [labelframe $win(base).f3 -text "X 軸パスカーブ" ]
  pack [radiobutton $win(base).f3.rb01 -text "節点" -variable NarabikaeSolid::val(x_path_type) -value nodes -command NarabikaeSolid::x_path_reset]
  pack [radiobutton $win(base).f3.rb02 -text "ライン" -variable NarabikaeSolid::val(x_path_type) -value line -command NarabikaeSolid::x_path_reset]
  pack [button $win(base).f3.b01 -bg #e6e664 -text $NarabikaeSolid::val(x_path_type) -command NarabikaeSolid::select_x_path ]

  # 実行
  pack [button $win(base).do  -text "実行" -command NarabikaeSolid::do ] 

  # 終了
  pack [button $win(base).quit  -text "終了" -command NarabikaeSolid::quit ] 
  
  # ×ボタンは NarabikaeSolid::quit の動きを
  wm protocol $win(base) WM_DELETE_WINDOW NarabikaeSolid::quit
}
#############################################################################
# 実行#
#############################################################################
proc NarabikaeSolid::do args {
  variable val;
  variable win;
  #
  # 要素、ラインが選択されてるかチェック
  if {[llength $val(selected_elems)] == 0} {
    tk_messageBox -message "要素を選んでください"
    return
  }
  if { [llength $val(x_path_nodes) ] == 0} {
    tk_messageBox -message "X 軸用節点パスかラインを選んでください"
    return
  }
  # 一旦窓を消す
  wm iconify $win(base);

  # node mark 2 にはパス以外の節点になってるはず
  eval *createmark node 1 $val(x_path_nodes) 
  *createmark node 2 all
  *markdifference node 2 node 1

  set val(deck) [open "___narabikaesolid.fem" w]

  foreach i $val(selected_elems) {
    switch [hm_getentityvalue elem $i config 0] {
      208 { NarabikaeSolid::hexa $i}
      default { continue }
    }
  }

  close $val(deck)

  *feinputpreserveincludefiles
  *createstringarray 5 "OptiStruct " " " "ASSIGNPROP_BYHMCOMMENTS" "BEAMSECTCOLS_SKIP " "BEAMSECTS_SKIP "
  *feinputwithdata2 "#optistruct\\optistruct" "___narabikaesolid.fem" 1 0 0 0 0 1 5 1 0

  *clearmark node 1
  *clearmark node 2
  #
  # 選択項目を空に
  set val(x_path_nodes) {};
  set val(z_vector)  {};
  set val(selected_elems) {};
  # ボタンを黄色に
  $win(base).b01 configure -bg #e6e664 
  $win(base).f2.b01 configure -bg #e6e664 
  $win(base).f3.b01 configure -bg #e6e664;
  # 念のため
  *clearmark node 1
  *clearmark node 2
  *clearmark elem 1
  *clearmark line 1
  # 窓復活
  wm deiconify $win(base);
  focus $win(base)

  return
}
#############################################################################
# hexa
# 引数 id は要素番号
#############################################################################
proc NarabikaeSolid::hexa id {
  variable val;
  variable win;

  # PID 取得
  set pid [hm_getentityvalue elem $id propertyid 0]

  # 要素中心座標を取得
  set xcenter [hm_getentityvalue elem $id centerx 0]
  set ycenter [hm_getentityvalue elem $id centery 0]
  set zcenter [hm_getentityvalue elem $id centerz 0]
  #


  # X ベクトルの最初の節点
  # 検索しない節点マーク 2
  set firstnode [ hm_getclosestnode $xcenter $ycenter $zcenter 0 2]

  # firstnode をマーク２に追加して2番目に近い node を検索
  *appendmark node 2 "by id" $firstnode

  # X ベクトルの終わりの節点
  set secondnode [ hm_getclosestnode $xcenter $ycenter $zcenter 0 2]
  # 次のループのためにマーク2 から firstnode を削除
  hm_markremove node 2 $firstnode

  # ベクトル計算. 長さは１
  # x1 とかは使い捨て変数
  set x1 [eval lindex [hm_nodevalue $firstnode] 0]
  set y1 [eval lindex [hm_nodevalue $firstnode] 1]
  set z1 [eval lindex [hm_nodevalue $firstnode] 2]
  set x2 [eval lindex [hm_nodevalue $secondnode] 0]
  set y2 [eval lindex [hm_nodevalue $secondnode] 1]
  set z2 [eval lindex [hm_nodevalue $secondnode] 2]
  set x_vect [commonmath::MakeUnitVect "$x2 $y2 $z2" "$x1 $y1 $z1"] ; # x_vect が基準 x ベクトル
  
  # 要素座標系の計算
  set elemnodes [hm_nodelist $id]
  # g1 - g8 に節点番号
  set g1 [lindex $elemnodes 0]
  set g2 [lindex $elemnodes 1]
  set g3 [lindex $elemnodes 2]
  set g4 [lindex $elemnodes 3]
  set g5 [lindex $elemnodes 4]
  set g6 [lindex $elemnodes 5]
  set g7 [lindex $elemnodes 6]
  set g8 [lindex $elemnodes 7]
  #
  # x1234 は g1, g2, g3, g4 の中心の x座標
  # v1234 は g1, g2, g3, g4 の中心座標
  set v1234 [NarabikaeSolid::center_4nodes $g1 $g2 $g3 $g4]  
  set v5678 [NarabikaeSolid::center_4nodes $g5 $g6 $g7 $g8] 
  set v1485 [NarabikaeSolid::center_4nodes $g1 $g4 $g8 $g5] 
  set v2376 [NarabikaeSolid::center_4nodes $g2 $g3 $g7 $g6] 
  set v1265 [NarabikaeSolid::center_4nodes $g1 $g2 $g6 $g5] 
  set v3487 [NarabikaeSolid::center_4nodes $g3 $g4 $g8 $g7] 
  
  # vx1, vy1, vz1 は並び替え前の座標軸ベクトル
  # r1 は並び替え前の基準ベクトル
  # vz1 x r1 = vy1
  # vy1 x vz1 = vx1
  # パターン0
  set vz1 [commonmath::MakeUnitVect $v5678 $v1234 ]
  set r1  [commonmath::MakeUnitVect $v2376 $v1485 ]
  set vy1 [commonmath::unitrotate $vz1 $r1]
  set vx1 [commonmath::unitrotate $vy1 $vz1]

  # 5148 - 6237 に並び替える
  # パターン1
  set vz2 [commonmath::MakeUnitVect $v2376 $v1485 ]
  set r2  [commonmath::MakeUnitVect $v1234 $v5678 ]
  set vy2 [commonmath::unitrotate $vz2 $r2]
  set vx2 [commonmath::unitrotate $vy2 $vz2]
  #
  # 5621 - 8734 に並び替える
  # パターン2
  set vz3 [commonmath::MakeUnitVect $v3487 $v1265 ]
  set r3  [commonmath::MakeUnitVect $v2376 $v1485 ]
  set vy3 [commonmath::unitrotate $vz3 $r3]
  set vx3 [commonmath::unitrotate $vy3 $vz3]
  # 4123 - 8567 に並び替える
  # パターン3
  set vz4 [commonmath::MakeUnitVect $v5678 $v1234 ]
  set r4  [commonmath::MakeUnitVect $v1265 $v3487 ]
  set vy4 [commonmath::unitrotate $vz4 $r4]
  set vx4 [commonmath::unitrotate $vy4 $vz4]
  # 8514 - 7623 に並び替える
  # パターン4
  set vz5 [commonmath::MakeUnitVect $v2376 $v1485 ]
  set r5  [commonmath::MakeUnitVect $v1265 $v3487 ]
  set vy5 [commonmath::unitrotate $vz5 $r5]
  set vx5 [commonmath::unitrotate $vy5 $vz5]
  # 1562 - 4873 に並び替える
  # パターン5
  set vz6 [commonmath::MakeUnitVect $v3487 $v1265 ]
  set r6  [commonmath::MakeUnitVect $v5678 $v1234 ]
  set vy6 [commonmath::unitrotate $vz6 $r6]
  set vx6 [commonmath::unitrotate $vy6 $vz6]

  # |vz1 dot val(z_vector)| + |vx1 dot x_vect| の計算
  # ぴったり一緒なら 2 になるはず
  # パターン0 の計算結果は p1
  set p1 [expr abs([commonmath::dot $vx1 $x_vect]) + abs([commonmath::dot $vz1 $val(z_vector)])]
  set p2 [expr abs([commonmath::dot $vx2 $x_vect]) + abs([commonmath::dot $vz2 $val(z_vector)])]
  set p3 [expr abs([commonmath::dot $vx3 $x_vect]) + abs([commonmath::dot $vz3 $val(z_vector)])]
  set p4 [expr abs([commonmath::dot $vx4 $x_vect]) + abs([commonmath::dot $vz4 $val(z_vector)])]
  set p5 [expr abs([commonmath::dot $vx5 $x_vect]) + abs([commonmath::dot $vz5 $val(z_vector)])]
  set p6 [expr abs([commonmath::dot $vx6 $x_vect]) + abs([commonmath::dot $vz6 $val(z_vector)])]

  # 最大値を探すしてパターンを決定
  set a "$p1 $p2 $p3 $p4 $p5 $p6"
  set pattern [lsearch $a [lindex [lsort -real -decreasing $a] 0]]

  switch $pattern {
    0 {  }
    1 { set nodeorder "$g5, $g1, $g4, $g8, $g6, $g2,\n, $g3, $g7" }
    2 { set nodeorder "$g5, $g6, $g2, $g1, $g8, $g7,\n, $g3, $g4" }
    3 { set nodeorder "$g4, $g1, $g2, $g3, $g8, $g5,\n, $g6, $g7" }
    4 { set nodeorder "$g8, $g5, $g1, $g4, $g7, $g6,\n, $g2, $g3" }
    5 { set nodeorder "$g1, $g5, $g6, $g2, $g4, $g8,\n, $g7, $g3" }
  }
#    1 { *createlist node 1 $g5 $g1 $g4 $g8 $g6 $g2 $g3 $g7; }
#    2 { *createlist node 1 $g5 $g6 $g2 $g1 $g8 $g7 $g3 $g4; }
#    3 { *createlist node 1 $g4 $g1 $g2 $g3 $g8 $g5 $g6 $g7; }
#    4 { *createlist node 1 $g8 $g5 $g1 $g4 $g7 $g6 $g2 $g3; }
#    5 { *createlist node 1 $g1 $g5 $g6 $g2 $g4 $g8 $g7 $g3; }

  if {$pattern != 0} {
    puts $val(deck) "chexa, $id, $pid, $nodeorder"
#    *createelement 208 1 1 0
#    *createmark elem 1 $id
#    *deletemark elem 1
#    *createmark elem 1 -1
#    *renumbersolverid elem 1 $id 1 0 0 0 0 0
  }
  return
}
#############################################################################
# 4 節点の平均座標を計算
#############################################################################
proc NarabikaeSolid::center_4nodes {n1 n2 n3 n4} {
  set x1 [eval lindex [hm_nodevalue $n1] 0]
  set y1 [eval lindex [hm_nodevalue $n1] 1]
  set z1 [eval lindex [hm_nodevalue $n1] 2]
  set x2 [eval lindex [hm_nodevalue $n2] 0]
  set y2 [eval lindex [hm_nodevalue $n2] 1]
  set z2 [eval lindex [hm_nodevalue $n2] 2]
  set x3 [eval lindex [hm_nodevalue $n3] 0]
  set y3 [eval lindex [hm_nodevalue $n3] 1]
  set z3 [eval lindex [hm_nodevalue $n3] 2]
  set x4 [eval lindex [hm_nodevalue $n4] 0]
  set y4 [eval lindex [hm_nodevalue $n4] 1]
  set z4 [eval lindex [hm_nodevalue $n4] 2]
  set x [expr ($x1+$x2+$x3+$x4)/4.0]
  set y [expr ($y1+$y2+$y3+$y4)/4.0]
  set z [expr ($z1+$z2+$z3+$z4)/4.0]
  return "$x $y $z"
}

#############################################################################
# Xパスの種類を変えたら、いろいろリセット
#############################################################################
proc NarabikaeSolid::x_path_reset args {
  variable val;
  variable win;
  $win(base).f3.b01 configure -text $NarabikaeSolid::val(x_path_type) -bg #e6e664
  set val(x_path_nodes) {} ; #x軸パスの節点 id
  return
}

#############################################################################
# Xパス節点を選択
#############################################################################
proc NarabikaeSolid::select_x_path_nodes args {
  variable val;
  variable win;

  # 一旦窓を消す
  wm iconify $win(base);

  # 節点を選択
  *createlistpanel node 1 "select path nodes"
  set val(x_path_nodes) [hm_getlist node 1]  ; #x軸パスの節点 id
  *clearmark node 1

  if { [llength $val(x_path_nodes)] < 2 } {
    $win(base).f3.b01 configure -bg #e6e664;
    tk_messageBox -message "節点を 2つ以上選択してください"
    # 窓復活
    wm deiconify $win(base);
    focus $win(base)
    return
  } else {
    $win(base).f3.b01 configure -bg #6e82dc;
  }

  # 窓復活
  wm deiconify $win(base);
  focus $win(base)

  return
}
#############################################################################
# Xパス line を選択
#############################################################################
proc NarabikaeSolid::select_x_path_line args {
  variable val;
  variable win;

  # 一旦窓を消す
  wm iconify $win(base);

  # 節点を選択
  *createmarkpanel line 1 "select a line"
  set val(x_line) [hm_getmark line 1] 
  if { [llength $val(x_line)] != 1 } {
    $win(base).f3.b01 configure -bg #e6e664;
    tk_messageBox -message "ラインを 1つ選択してください"
    # 窓復活
    wm deiconify $win(base);
    focus $win(base)
    return
  } else {
    $win(base).f3.b01 configure -bg #6e82dc;
  }

  # ラインの上に節点を作って、その節点をパスにする
  set firstnode [expr [hm_entitymaxid node]+1]
  *nodecreateonlines lines 1 1000
  *clearmark line 1
  set lastnode [hm_entitymaxid node ]
  *createmark node 1 "by id" ${firstnode}-${lastnode}
  set val(x_path_nodes) [hm_getmark node 1] ; #x軸パスの節点 id
  *clearmark node 1

  # 窓復活
  wm deiconify $win(base);
  focus $win(base)

  return
}
#############################################################################
# Xパスを選択
#############################################################################
proc NarabikaeSolid::select_x_path args {
  variable val;
  variable win;

  switch $val(x_path_type) {
    nodes { NarabikaeSolid::select_x_path_nodes }
    line  { NarabikaeSolid::select_x_path_line }
  }
}

#############################################################################
# ２節点を選んでベクトルを決定
#############################################################################
proc NarabikaeSolid::twonodes_dir args {
  variable win
  variable val
  
  # 一旦窓を消す
  wm iconify $win(base);

  *createlistpanel node  1 "Select two nodes" 
  set nodes [hm_getlist node 1]
  *clearlist node 1
  if { [llength $nodes] == 2  } {
    $win(base).f2.b01 configure -bg #60c0c0 
  } else {
    $win(base).f2.b01 configure -bg #e6e664 
    tk_messageBox -type ok -title エラー -icon error \
      -message "２節点を選択してください。"
    wm deiconify $win(base);
    focus $win(base)
    return
  }
  for {set i 0} {$i <= 1} {incr i} {
    set x$i [lindex [lindex [hm_nodevalue [lindex $nodes $i ] ] 0] 0]
    set y$i [lindex [lindex [hm_nodevalue [lindex $nodes $i ] ] 0] 1]
    set z$i [lindex [lindex [hm_nodevalue [lindex $nodes $i ] ] 0] 2]
  }

  set vectx [expr $x1 - $x0 ]
  set vecty [expr $y1 - $y0 ]
  set vectz [expr $z1 - $z0 ]
  set vectlength [expr sqrt($vectx **2 +$vecty **2 +$vectz **2)]

  # z_vector は大きさ 1 のベクトル
  set val(z_vector) "[ expr $vectx / $vectlength ] [ expr $vecty / $vectlength ] [ expr $vectz / $vectlength ] "

# 窓復活
  wm deiconify $win(base);
  focus $win(base)

}
#############################################################################
# z 軸ベクトルを決める２節点選択ボタンを黄色に
#############################################################################
proc NarabikaeSolid::reset_twonode_select args {
  variable win
  variable val
  $win(base).f2.b01 configure -bg yellow 
}
#############################################################################
# 要素選択
#############################################################################
proc NarabikaeSolid::elemselect args {
#{{{
  variable val
  variable win
  set val(selected_elems) {} ;# 選択要素
  
  # 一旦窓を消す
  wm iconify $win(base);

  # 要素選択パネル
  *createmarkpanel elem 1 "select elems."
  # 窓復活
  wm deiconify $win(base);
  focus $win(base)
  # 選択した節点を selected_elems に
  set val(selected_elems) [hm_getmark elem 1]
  *clearmark elem 1

  # 要素が選ばれているか調べる
  if {[llength $val(selected_elems)] == 0} {
    # メッセージ
    tk_messageBox -message "要素を１つ以上選んでください。" -icon error
    # ボタンの色を黄色
    $win(base).b01 configure -bg #e6e664 
    # 終了
    return;
  } 

  # ボタンをブルーに
  $win(base).b01 configure -bg #60c0c0
  return
}
#}}}
#############################################################################
# 終了
#############################################################################
proc NarabikaeSolid::quit args { 
  variable win
  destroy $win(base)
  namespace delete [ namespace current ];
}


################################################
# 良く使いそうな数学演算
# オリジナルは commonmath.tcl
###############################################
namespace eval commonmath {
}

##########################################
# make a unit-length vector by using 2 vectors of coordinates.
# return (vect2 - vect1)/|vect2 - vect1|
# vect1 and vect2 is like {1 2 3}
##########################################
proc commonmath::MakeUnitVect {vect1 vect2 } {
  set x1 [lindex $vect1 0]
  set y1 [lindex $vect1 1]
  set z1 [lindex $vect1 2]
  set x2 [lindex $vect2 0]
  set y2 [lindex $vect2 1]
  set z2 [lindex $vect2 2]
  set vx [expr $x2 - $x1 ]
  set vy [expr $y2 - $y1 ]
  set vz [expr $z2 - $z1 ]
  set length [expr sqrt( $vx ** 2 + $vy **2 + $vz **2)]
  set uvx [expr $vx / $length]
  set uvy [expr $vy / $length]
  set uvz [expr $vz / $length]
  set univ "$uvx $uvy $uvz"
  return $univ
}

##########################################
# vector rotation
# return vect1 rot vect2 /|vect1 rot vect2| as { 1 2 3}
# vect1 and vect2 is like {1 2 3}
##########################################
proc commonmath::unitrotate {vect1 vect2} {
  set x1 [lindex $vect1 0]
  set y1 [lindex $vect1 1]
  set z1 [lindex $vect1 2]
  set x2 [lindex $vect2 0]
  set y2 [lindex $vect2 1]
  set z2 [lindex $vect2 2]
  set vx [expr $y1 * $z2 - $z1 * $y2] 
  set vy [expr $z1 * $x2 - $x1 * $z2] 
  set vz [expr $x1 * $y2 - $y1 * $x2] 
  set length [expr sqrt( $vx ** 2 + $vy **2 + $vz **2)]
  set uvx [expr $vx / $length]
  set uvy [expr $vy / $length]
  set uvz [expr $vz / $length]
  set univ "$uvx $uvy $uvz"
  return $univ
}

##############################################
# vector dot
# return vect1 dot vect2 as single value.
# vect1 and vect 2 is like {1 2 3}
# ############################################
proc commonmath::dot {vect1 vect2} {
  set x1 [lindex $vect1 0]
  set y1 [lindex $vect1 1]
  set z1 [lindex $vect1 2]
  set x2 [lindex $vect2 0]
  set y2 [lindex $vect2 1]
  set z2 [lindex $vect2 2]
  set value [expr $x1 *$x2 + $y1 * $y2 + $z1 * $z2]
  return $value
}


NarabikaeSolid::main
