#############################################################################
# namespace 定義
#############################################################################
namespace eval Nonsecion2SquareSection {
  variable win;  # 窓系
  variable var;  # このマクロ内で使われる変数
  variable mes;
  
  set var(beamcol) "_nosec2square" ; #Beam collector name

  set var(lang) ja; 
  set var(lang) en; # 日本語GUI 使いたいならコメントアウト

  switch $var(lang) {
    ja {
      set mes(1) "に未対応"
      set mes(2) "プロパティを選択してください"
      set mes(3) "プロパティが選択されていません"
      set mes(4) "Z 軸方向"
      set mes(5) "2点で指定"
      set mes(6) "X 軸パスカーブ"
      set mes(7) "節点"
      set mes(8) "ライン"
      set mes(9) "実行"
      set mes(10) "終了"
      set mes(11) "要素を選んでください"
      set mes(12) "X 軸用節点パスかラインを選んでください"
      set mes(13) "節点を 2つ以上選択してください"
      set mes(14) "ラインを 1つ選択してください"
      set mes(15) "２節点を選択してください。"
      set mes(16) "要素を１つ以上選んでください。"
    } 
    en {
      set mes(1) "??? You can't use the solver."
      set mes(2) "Select properties."
      set mes(3) "You have to select properties."
      set mes(4) "Z-dirction"
      set mes(5) "Two nodes vector"
      set mes(6) "X-dir. path curve"
      set mes(7) "nodes"
      set mes(8) "a line"
      set mes(9) "do"
      set mes(10) "quit"
      set mes(11) "You should select some elements."
      set mes(12) "You should select some nodes or a line to determin X-direction."
      set mes(13) "You should select more than two nodes."
      set mes(14) "You should select a line."
      set mes(15) "You should select two nodes."
      set mes(16) "You should select more than one elems."
    }
  }
}

#############################################################################
# main
#############################################################################
proc Nonsecion2SquareSection::main args {
  variable mes;
  variable var;

  # solver check
  # only Nastran type.
  switch [hm_getsolver] {
    nastran {}
    optistruct {}
    default {tk_messageBox -message "[hm_getsolver] $mes(1)"; return;}
  }

  # property select.
  *createmarkpanel prop 1 $mes(2)
  set var(prop) [hm_getmark prop 1]
  *clearmark prop 1

  if { $var(prop) == "" } {
    hm_errormessage $mes(3)
  }

  if { [catch {*collectorcreateonly beamsectcols $var(beamcol) "" 5} ] } {}

  # roop of selected props.
  foreach var(pid) $var(prop) {
    set var(card) [hm_getcardimagename props $var(pid)]
    switch $var(card) {
      PBEAM { Nonsecion2SquareSection::pbeam }
      PBAR  { Nonsecion2SquareSection::pbar }
      default {continue}
    }
  }


}

proc Nonsecion2SquareSection::pbeam args {
  variable mes;
  variable var;
  
  # check it has a beamsection or not.
  if { [ hm_getentityvalue prop $var(pid) \$BeamSecA 0] != 0 } {return}

  # get ineatia
  # I don't use area. There are two unknown vars but three equations.
  # I have to remove one of the equations.
#  set area [ hm_getentityvalue prop $var(pid) \$PBEAM_Aa 0 ]
  set i1a  [ hm_getentityvalue prop $var(pid) \$PBEAM_I1a 0 ]
  set i2a  [ hm_getentityvalue prop $var(pid) \$PBEAM_I2a 0 ]
  if {$i1a == 0} {return}
  if {$i2a ==0} {return}

  set var(h) [expr ( 12**2 * $i1a**3 / $i2a)**(1.0/8.0)   ]
  set var(b) [expr ( 12**2 * $i2a**3 / $i1a)**(1.0/8.0)   ]

  Nonsecion2SquareSection::beam
  return
}

proc Nonsecion2SquareSection::pbar args {
  variable mes;
  variable var;
  
  # check it has a beamsection or not.
  if { [ hm_getentityvalue prop $var(pid) \$BeamSec 0] != 0 } {return}

  # get ineatia
  # I don't use area. There are two unknown vars but three equations.
  # I have to remove one of the equations.
#  set area [ hm_getentityvalue prop $var(pid) \$PBAR_A 0 ]
  set i1a  [ hm_getentityvalue prop $var(pid) \$PBAR_I1 0 ]
  set i2a  [ hm_getentityvalue prop $var(pid) \$PBAR_I2 0 ]
  if {$i1a == 0} {return}
  if {$i2a ==0} {return}

  set var(h) [expr ( 12**2 * $i1a**3 / $i2a)**(1.0/8.0)   ]
  set var(b) [expr ( 12**2 * $i2a**3 / $i1a)**(1.0/8.0)   ]
  
  Nonsecion2SquareSection::beam
  return
}



proc Nonsecion2SquareSection::beam args {
  variable mes;
  variable var;


  *currentcollector beamsectcols $var(beamcol)

  # This makes 10x10 rectangular beam
  *beamsectioncreatestandardsolver 10 0 HMTube 0 
  
  set maxbeamsecid [ hm_entitymaxid beamsects ]
  set maxbeamcolid [ hm_entitymaxid beamsectcols ]

  *beamsectionsetdataroot $maxbeamsecid $maxbeamcolid  0 2 7 1 0 1 1 0 0 0 0 

  *createdoublearray 6 $var(h) 10 10 $var(b) 10 10
  *beamsectionsetdatastandard  1  6  $maxbeamsecid  10  0  HMTube  

  # assign to the prop.
  switch $var(card) {
    PBEAM { set third 3186 }
    PBAR  { set third 3179 }
  }
  *attributeupdateentity prop $var(pid) $third 1 2 0 beamsects $maxbeamsecid
  
  return
}

Nonsecion2SquareSection::main
