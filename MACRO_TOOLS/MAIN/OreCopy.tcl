#
# History:
#   2010.06.01: ver-1.0.1
#     ・カレントとオリジナルの挙動が逆だったのを修正
#     ・"全て取り消し" を一回だけのやり直しに変更
#     ・hm_entitymaxid の直前に hm_completemenuoperation を追加
#
#   2010.05.31: ver-1.0.0
#     ・社内配布
#
#   2014.01.16 
#     ・Run Tcl/Tk scriptでいきなり動くように最後に OreCopy::main 追加
#     ・script exchange 登録用に英語の GUI を作成
#    
#
#############################################################################
# namespace 定義
#############################################################################
namespace eval OreCopy {
  variable win;  # 窓系
  variable select;
  variable mes;
}

#############################################################################
# メイン
#############################################################################
proc OreCopy::main args {
  variable select
  variable mes;
  set select(item) {elem surf line}  ;# 選択可能エンティティ
  set select(copy_id) "" ; # コピーしたエンティティ ID を格納
#  OreCopy::set_max

  set langfile _OreLang
  set workingdir [hm_info -appinfo CURRENTWORKINGDIR]
  if { [file exist $workingdir/$langfile] ==0 } {
    set select(lang) [hm_getstring {Select GUI Language} {日本語: ja, English: en}]
    switch $select(lang) {
      ja {}
      en {}
      default {set select(lang) en}
    }
    set f [open $workingdir/$langfile w]
    puts $f $select(lang)
    close $f
  }
  set f [open $workingdir/$langfile r]
  set select(lang) [gets $f]
  close $f
  OreCopy::message
  OreCopy::gui
}

####################
# Messages
#############
proc OreCopy::message args {
  variable select;
  variable mes;
  switch $select(lang) {
    ja {
      set mes(1) "スクリプトがすでに起動しています"
      set mes(2) "選択するエンティティの種類"
      set mes(3) "エンティティ選択"
      set mes(4)  "繰り返し回数"
      set mes(5) "向き"
      set mes(6)  "2点で指定"
      set mes(7) "距離"
      set mes(8)  "コンポーネント"
      set mes(9) "カレント"
      set mes(10) "オリジナル"
      set mes(11) "実行"
      set mes(12) "やりなおし"
      set mes(13) "終了"
      set mes(14) "エラー"
      set mes(15) "２節点を選択してください。"
      set mes(16) "エンティティを選択してください。"
      set mes(17) "繰り返し回数は正の整数です"
      set mes(18) "距離は実数です。"
      set mes(19) "警告"
      set mes(20) "やりなおせません"
    } 
    en {
      set mes(1) "This script has already been running."
      set mes(2) "Entity Type"
      set mes(3) "Select entity"
      set mes(4)  "Repeat times"
      set mes(5) "Direction"
      set mes(6) "By 2 nodes"
      set mes(7) "Distance"
      set mes(8) "Component"
      set mes(9) "Current"
      set mes(10) "Original"
      set mes(11) "Do"
      set mes(12) "Reject"
      set mes(13) "Quit"
      set mes(14) "Error"
      set mes(15) "Please select two nodes."
      set mes(16) "Please select entities."
      set mes(17) "Please input positive integra for repeat times."
      set mes(18) "Please input real number for distance."
      set mes(19) "Warning"
      set mes(20) "You cannot reject."
    }
  }
}


#############################################################################
# 窓
#############################################################################
proc OreCopy::gui args {
  variable win
  variable select
  variable mes;
  set win(name) "multipleCopy"; # toplevel name
  set win(base) ".$win(name)";
#    set win(title) "Gap creation";
#    set win(width) 300;
#    set win(height) 360;
#    set win(x) 5;
#    set win(y) 100;


  if { [ winfo exists $win(base) ] } {
    tk_messageBox -message $mes(1) -type "ok" -icon info -title "Information";
    focus $win(base);
    return;
  }
  
  # トップレベル
  toplevel $win(base);
  # 窓はいつでも前にある
  wm attributes $win(base) -topmost 1;

  # エンティティの種類を選択
  pack [labelframe $win(base).f0 -text $mes(2) ]
  set select(type) [ lindex $select(item) 0]

  foreach item $select(item) {
    radiobutton $win(base).f0.rb01$item -text $item -variable OreCopy::select(type) -value $item -command OreCopy::reset_selected_entity
    pack $win(base).f0.rb01$item 
  }
  
  # エンティティを選択
  set select(id) {}
  pack [button $win(base).b01 -text $mes(3) -command OreCopy::select ]

  # 繰り返し回数
  pack [labelframe $win(base).f1 -text $mes(4) ]
  set select(num) 1 ;
  pack [entry $win(base).f1.num -textvariable OreCopy::select(num)]
  
# *translatemark コマンドに座標系を指定できないので男らしくあきらめた
#  # 参照する座標系
#  set select(system) 0
#  pack [button $win(base).sym -text "座標系選択" -command OreCopy::system ] 

  # 向き
  set select(dir) {1 0 0} ;
  pack [labelframe $win(base).f2 -text $mes(5) ]
  pack [radiobutton $win(base).f2.rb01 -text x -variable OreCopy::select(dir) -value {1 0 0} -command OreCopy::reset_twonode_select]
  pack [radiobutton $win(base).f2.rb02 -text y -variable OreCopy::select(dir) -value {0 1 0} -command OreCopy::reset_twonode_select]
  pack [radiobutton $win(base).f2.rb03 -text z -variable OreCopy::select(dir) -value {0 0 1} -command OreCopy::reset_twonode_select]
  pack [button $win(base).f2.b01  -text $mes(6) -command OreCopy::twonodes_dir ]
  

  # 距離
  set select(distance) 0
  pack [labelframe $win(base).f3 -text $mes(7) ]
  pack [entry $win(base).f3.distance -textvariable OreCopy::select(distance)]

  # コピーするコンポーネントの選択
  set select(comp) 0; #デフォルトはオリジナル
  pack [labelframe $win(base).f4 -text $mes(8) ]
  pack [radiobutton $win(base).f4.rb01 -text $mes(9)    -variable OreCopy::select(comp) -value 1 ]
  pack [radiobutton $win(base).f4.rb02 -text $mes(10)  -variable OreCopy::select(comp) -value 0 ]


  # 実行、やり直し、終了
  pack [button $win(base).do -text $mes(11) -command OreCopy::do ] 
  pack [button $win(base).redo  -text $mes(12) -command OreCopy::cancel ] 
  pack [button $win(base).quit  -text $mes(13) -command OreCopy::quit ] 
  
  # ×ボタンは OreCopy::quit の動きを
  wm protocol $win(base) WM_DELETE_WINDOW OreCopy::quit
}

#############################################################################
# 2点で方向を作成
#############################################################################
proc OreCopy::twonodes_dir args {

  variable select
  variable win
  variable mes;

# 一旦窓を消す
  wm iconify $win(base);

  *createlistpanel node  1 "Select two nodes" 
  set nodes [hm_getlist node 1]
  *clearlist node 1
  if { [llength $nodes] == 2  } {
    $win(base).f2.b01 configure -bg #000080 -fg #cccccc
  } else {
    $win(base).f2.b01 configure -bg lightgray  -fg black
    tk_messageBox -type ok -title $mes(14) -icon error \
      -message $mes(15)
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
proc OreCopy::select args {
  variable select
  variable win
  variable mes;

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
proc OreCopy::quit args {
  variable win
  variable mes;
  destroy $win(base)
  namespace delete [ namespace current ];
}
#############################################################################
# 実行
#############################################################################
proc OreCopy::do args {
  variable win
  variable select
  variable mes;
  # チェック
  if { [llength $select(id)] == 0 } {
    tk_messageBox -type ok -title $mes(14) -icon error \
      -message $mes(16)
    return 
  }
  if { ![string is integer $select(num) ] || $select(num) <= 0 } {
    tk_messageBox -type ok -title $mes(14) -icon error \
      -message $mes(17)
    return 
  }
  if { ![string is double $select(distance) ] } {
    tk_messageBox -type ok -title $mes(14) -icon error \
      -message $mes(18)
  }

  # 実行前の最大値を取得
  hm_completemenuoperation
  set cur_max [hm_entitymaxid $select(type) ]
  

  # 移動ベクトル作成 eval が必要
  eval *createvector 1 $select(dir)


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
    *translatemark $select(type)  1 1 [expr double(${select(distance)})*$i] 
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
  $win(base).b01 configure -bg lightgray  -fg black
  $win(base).f2.b01 configure -bg lightgray  -fg black

  
  
}
#############################################################################
# キャンセル
#############################################################################
proc OreCopy::cancel args {
  variable select
  variable mes;

  if { [llength $select(copy_id)] == 0 } {
    tk_messageBox -type ok -title $mes(19) -icon error \
      -message $mes(20)
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
proc OreCopy::system args {
  variable win
  variable select
  variable mes;

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
proc OreCopy::reset_selected_entity args {
  variable win
  variable select
  variable mes;

  set select(id) ""
  $win(base).b01 configure -bg lightgray  -fg black

}

#############################################################################
# 方向用２節点をクリアー
#############################################################################
proc OreCopy::reset_twonode_select args {
  variable select
  variable win
  variable mes;

  $win(base).f2.b01 configure -bg lightgray  -fg black
}


OreCopy::main
