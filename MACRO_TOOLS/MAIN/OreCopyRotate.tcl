# copy and rotate multiple times.
#
# History
#   1.4.4
#     first release
#############################################################################
# namespace 定義
#############################################################################
namespace eval OreCopyRotate {
  variable win;  # 窓系
  variable select
#  variable max
}

#############################################################################
# メイン
#############################################################################
proc OreCopyRotate::main args {
  variable select
  set select(item) {elem surf line}  ;# 選択可能エンティティ
  set select(copy_id) "" ; # コピーしたエンティティ ID を格納
#  OreCopyRotate::set_max
  OreCopyRotate::gui
}

#############################################################################
# エンティティ最大値取得
#############################################################################
#proc OreCopyRotate::set_max args {
#  variable max
#  variable select
#
#  foreach i $select(item) {
#    set max($i) [ hm_entitymaxid $i 1]
#  }
#}


#############################################################################
# 窓
#############################################################################
proc OreCopyRotate::gui args {
  variable win
  variable select
  set win(name) "multipleCopy"; # toplevel name
  set win(base) ".$win(name)";
#    set win(title) "Gap creation";
#    set win(width) 300;
#    set win(height) 360;
#    set win(x) 5;
#    set win(y) 100;


  if { [ winfo exists $win(base) ] } {
    tk_messageBox -message "Window already exists." -type "ok" -icon info -title "Information";
    focus $win(base);
    return;
  }
  
  # トップレベル
  toplevel $win(base);
  # 窓はいつでも前にある
  wm attributes $win(base) -topmost 1;

  # エンティティの種類を選択
  pack [labelframe $win(base).f0 -text "選択するエンティティの種類" ]
  set select(type) [ lindex $select(item) 0]

  foreach item $select(item) {
    radiobutton $win(base).f0.rb01$item -text $item -variable OreCopyRotate::select(type) -value $item -command OreCopyRotate::reset_selected_entity
    pack $win(base).f0.rb01$item 
  }
  
  # エンティティを選択
  set select(id) {}
  pack [button $win(base).b01 -text "エンティティ選択" -command OreCopyRotate::select ]

  # 繰り返し回数
  pack [labelframe $win(base).f1 -text "繰り返し回数" ]
  set select(num) 1 ;
  pack [entry $win(base).f1.num -textvariable OreCopyRotate::select(num)]
  
# *translatemark コマンドに座標系を指定できないので男らしくあきらめた
#  # 参照する座標系
#  set select(system) 0
#  pack [button $win(base).sym -text "座標系選択" -command OreCopyRotate::system ] 

  # 向き
  set select(dir) {1 0 0} ;
  pack [labelframe $win(base).f2 -text "回転軸" ]
  pack [radiobutton $win(base).f2.rb01 -text x -variable OreCopyRotate::select(dir) -value {1 0 0} -command OreCopyRotate::reset_twonode_select]
  pack [radiobutton $win(base).f2.rb02 -text y -variable OreCopyRotate::select(dir) -value {0 1 0} -command OreCopyRotate::reset_twonode_select]
  pack [radiobutton $win(base).f2.rb03 -text z -variable OreCopyRotate::select(dir) -value {0 0 1} -command OreCopyRotate::reset_twonode_select]
  pack [button $win(base).f2.b01  -text "2点で指定" -command OreCopyRotate::twonodes_dir ]
  
  # 回転中心
  set select(baseposition) {};
  pack [labelframe $win(base).f5 -text "回転中心" ]
  pack [button $win(base).f5.b01  -text "節点" -command OreCopyRotate::basenode ]


  # 距離
  set select(distance) 0
  pack [labelframe $win(base).f3 -text "角度" ]
  pack [entry $win(base).f3.distance -textvariable OreCopyRotate::select(distance)]

  # コピーするコンポーネントの選択
  set select(comp) 0; #デフォルトはオリジナル
  pack [labelframe $win(base).f4 -text "コンポーネント" ]
  pack [radiobutton $win(base).f4.rb01 -text "カレント"    -variable OreCopyRotate::select(comp) -value 1 ]
  pack [radiobutton $win(base).f4.rb02 -text "オリジナル"  -variable OreCopyRotate::select(comp) -value 0 ]


  # 実行、やり直し、終了
  pack [button $win(base).do -text "実行" -command OreCopyRotate::do ] 
  pack [button $win(base).redo  -text "やりなおし" -command OreCopyRotate::cancel ] 
  pack [button $win(base).quit  -text "終了" -command OreCopyRotate::quit ] 
  
  # ×ボタンは OreCopyRotate::quit の動きを
  wm protocol $win(base) WM_DELETE_WINDOW OreCopyRotate::quit
}

#############################################################################
# 回転中心の節点を選択
#############################################################################
proc OreCopyRotate::basenode args {
  variable select
  variable win
  wm iconify $win(base);
  *createmarkpanel node  1 "Select a base node" 
  set node [lindex [hm_getmark node 1] 0]
  if { [llength $node] == 1  } {
    $win(base).f5.b01 configure -bg #000080 -fg #cccccc
  } else {
    $win(base).f5.b01 configure -bg lightgray  -fg black
    tk_messageBox -type ok -title エラー -icon error \
      -message "節点を選択してください。"
    wm deiconify $win(base);
    focus $win(base)
    return
  }
    set x [lindex [lindex [hm_nodevalue $node ] 0] 0]
    set y [lindex [lindex [hm_nodevalue $node ] 0] 1]
    set z [lindex [lindex [hm_nodevalue $node ] 0] 2]

  set select(baseposition) "$x $y $z"
  puts $select(baseposition)

# 窓復活
  wm deiconify $win(base);
  focus $win(base)

}
#############################################################################
# 2点で方向を作成
#############################################################################
proc OreCopyRotate::twonodes_dir args {

  variable select
  variable win

# 一旦窓を消す
  wm iconify $win(base);


  *createlistpanel node  1 "Select two nodes" 
  set nodes [hm_getlist node 1]
  *clearlist node 1
  if { [llength $nodes] == 2  } {
    $win(base).f2.b01 configure -bg #000080 -fg #cccccc
  } else {
    $win(base).f2.b01 configure -bg lightgray  -fg black
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

  set select(dir) "[ expr $x1 - $x0 ] [ expr $y1 -$y0 ] [ expr $z1 - $z0 ]"

# 窓復活
  wm deiconify $win(base);
  focus $win(base)

}
#############################################################################
# エンティティ選択
#############################################################################
proc OreCopyRotate::select args {
  variable select
  variable win

# 一旦窓を消す
  wm iconify $win(base);

 *createmarkpanel $select(type) 1 "select entitys"
  set select(id) [ hm_getmark $select(type) 1 ]
  *clearmark $select(type) 1

  if { [llength $select(id)] != 0  } {
    $win(base).b01 configure -bg #000080 -fg #cccccc
  } else {
    $win(base).b01 configure -bg lightgray  -fg black
  }

# 窓復活
  wm deiconify $win(base);
  focus $win(base)
}

#############################################################################
# 終了
#############################################################################
proc OreCopyRotate::quit args {
  variable win
  destroy $win(base)
  namespace delete [ namespace current ];
}
#############################################################################
# 実行
#############################################################################
proc OreCopyRotate::do args {
  variable win
  variable select
  # チェック
  if { [llength $select(id)] == 0 } {
    tk_messageBox -type ok -title エラー -icon error \
      -message "エンティティを選択してください。"
    return 
  }
  if { ![string is integer $select(num) ] || $select(num) <= 0 } {
    tk_messageBox -type ok -title エラー -icon error \
      -message "繰り返し回数は正の整数です"
    return 
  }
  if { ![string is double $select(distance) ] } {
    tk_messageBox -type ok -title エラー -icon error \
      -message "距離は実数です。"
  }
  if { [llength $select(baseposition)] == 0 } {
    tk_messageBox -type ok -title エラー -icon error \
      -message "回転中心を選択してください"
    return 
  }

  # 実行前の最大値を取得
  hm_completemenuoperation
  set cur_max [hm_entitymaxid $select(type) ]
  

  # 移動ベクトル作成 eval が必要
  #  eval *createvector 1 $select(dir)
  # 回転平面の作成
  eval *createplane 1 $select(dir) $select(baseposition)

  # 繰り返す
  for {set i 1} {$i <= $select(num) } {incr i} {
    # コピー
    hm_createmark $select(type) 1 "by id" $select(id)
    hm_completemenuoperation
    set firstid  [expr [hm_entitymaxid $select(type) ] +1]
    *duplicatemark $select(type) 1 $select(comp)
    *clearmark $select(type) 1 
    # 移動
    hm_completemenuoperation
    set lastid  [hm_entitymaxid $select(type) ]
    hm_createmark $select(type) 1 "by id" ${firstid}-${lastid}
    *rotatemark $select(type) 1 1 [expr double(${select(distance)})*$i] 
#    *translatemark $select(type)  1 1 [expr double(${select(distance)})*$i] 
    *clearmark $select(type) 1
  }

  # 実行後の最大値を取得
  hm_completemenuoperation
  set mod_max [hm_entitymaxid $select(type) ]
  # 実行状況の保管
  set select(last_type) $select(type)
  *createmark $select(type) 1 "by id" [expr $cur_max +1]-$mod_max
  set select(copy_id) [ hm_getmark $select(type) 1]
  # ハイライト消す
  *createmark $select(type) 1 all
  hm_highlightmark $select(type) 1 n

  # 初期化
  set select(id) ""
  set select(dir) {1 0 0}
  set select(baseposition) {};
  $win(base).b01 configure -bg lightgray  -fg black
  $win(base).f2.b01 configure -bg lightgray  -fg black
  $win(base).f5.b01 configure -bg #c0c0c0  -fg black
  
}
#############################################################################
# キャンセル
#############################################################################
proc OreCopyRotate::cancel args {
  variable select

  if { [llength $select(copy_id)] == 0 } {
    tk_messageBox -type ok -title 警告 -icon error \
      -message "やりなおせません"
    return 
  }


  # 前回コピーしたエンティティをマーク
  hm_createmark $select(last_type) 1 "by id" $select(copy_id)
  *deletemark $select(last_type) 1
  *clearmark $select(last_type) 1

  # コピー情報をクリア
  set select(copy_id) ""
  set select(last_type) ""
}

#############################################################################
# 座標系選択
#############################################################################
proc OreCopyRotate::system args {
  variable win
  variable select
  *createmarkpanel system 1 "select a system"
  set select(system) [ lindex [hm_getmark system 1] 0 ]
  if { [ lindex $select(system) ] == "" } {
    set select(system) 0
  }
  *clearmark system 1
  if { $select(system) != 0  } {
    $win(base).sym configure -bg #000080 -fg #cccccc
  } else {
    $win(base).sym configure -bg lightgray  -fg black
  }
  focus $win(base)
}

#############################################################################
# 要素選択をキャンセル
#############################################################################
proc OreCopyRotate::reset_selected_entity args {
  variable win
  variable select
#  variable max

  set select(id) ""
  $win(base).b01 configure -bg lightgray  -fg black

}

#############################################################################
# 方向用２節点をクリアー
#############################################################################
proc OreCopyRotate::reset_twonode_select args {
  variable select
  variable win
  $win(base).f2.b01 configure -bg lightgray  -fg black
}

eval OreCopyRotate::main
