#============================
#Warranty and Disclaimer
#============================
#Custom macros are is not part of the official HyperWorks installation.
#These tools do not pass any automated QA process.
#These tools are provided without warranty - the Altair Software License Agreement (in particular §6) applies.
#The update of the tools to upcoming versions of HyperWorks is not mandatory.
#The support and maintenance of these tools is not obligatory.
# VERSION 27.07.2012


namespace eval orientElems {

###swap the comment to create vectors instead of plotels.
    variable type element ;
#   variable type "vector"

    variable xScale 0.65 ; # scale factor for x relative to element size
    variable yScale 0.7 ; # scale for y in relation to x
    variable zScale 0.4 ; # scale for z in relation to x

    variable orientationType
    variable tabname "OrientElements"
    variable main
    variable orientationElement
    if {[info exist orientationElement]==0} {
      set orientationElement 0
    }

    if {[info exist orientationType]==0} {
      set orientationType ""
    }

    namespace eval math {
      proc ADD {x y} {
        if {[llength $y] == 1} {
          foreach X $x {
            lappend res [expr {$X + $y} ]
          }
        } else {
          foreach X $x Y $y {
            lappend res [expr {$X + $Y} ]
          }
        }
        return $res
      }

      proc SUB {x y} {
        if {[llength $y] == 1} {
          foreach X $x {
            lappend res [expr {$X - $y} ]
          }
        } else {
          foreach X $x Y $y {
            lappend res [expr {$X - $Y} ]
          }
        }
        return $res
      }

      proc DOT {x y} {
       set sum 0
        foreach X $x Y $y {
          set sum [expr {$sum + 1.0 * $X * $Y}]
        }
        return $sum
      }

      proc NORM {x {unit "dummy"}} {
      # 2. Param = Einheitsvekor, Return=Laenge
      upvar $unit res
         set n [expr {sqrt([DOT $x $x])}]
         if {$n == 0} {
           set res $x
         } else {
           set res [DIV $x $n]
         }
         return $n
      }

      proc DIV {x y } {
        foreach X $x {
          lappend res [expr {1.0 * $X / $y} ]
        }
        return $res
      }

      proc MUL {x y} {
        foreach X $x {
          lappend res [expr {1.0 * $X * $y }]
        }
        return $res
      }


      proc CROSS {x y} {
       foreach {ax ay az} $x {}
       foreach {bx by bz} $y {}
       return [list  [expr {$ay * $bz - $az * $by}] \
                     [expr {$az * $bx - $ax * $bz}] \
                     [expr {$ax * $by - $ay * $bx}] ]
      }
    }


  proc createSystems {{what ""} {tempType "none"}} {
    variable orientationElement
    variable reverseText
    variable type
    variable xScale
    variable yScale
    variable zScale
    variable requestingElement
    if {[info exist requestingElement] && $requestingElement == 1} {
      if {[tk_messageBox -message "There seems to be another element selection waiting to be submitted!\nTo continue might cause instable behavor!\nContinue anyway?" -type yesno]=="no"} {
        return
      }
    }
    set requestingElement 1
    if {$what ==""} {
      set orientationType ""
      *createmarkpanel elements 1 "Select elements"
      foreach e [hm_getmark elements 1] {
        set cfg [hm_getentityvalue elements $e config 0]
        if {$cfg == 208 || $cfg == 220} {
          set orientationType "Solid"
          break
        } elseif {$cfg == 104 || $cfg == 108} {
          set orientationType "Shell"
          break
        }
      }
      if {$orientationType==""} {
        set requestingElement 0
        return
      }
    } else {
      if {$tempType == "none"} {
        variable orientationType
      } else {
        set orientationType $tempType
      }
      if {$what =="one" || $what== "attached" || $what == ""} {
        if {$orientationElement==0 || $what == ""} {
          *createmarkpanel elements 1 "Select elements"
        } else {
          *createmark elements 1 $orientationElement
        }
        if {$what=="attached"} {
          *appendmark elements 1 "by attached"
        }
      } else {
        upvar $what eList
        eval *createmark elements 1 $eList
      }
    }
    if {$orientationType =="Shell"} {
      *createmark elements 2 "by config" 104 108
    } else {
      *createmark elements 2 "by config" 208 220
    }
    set requestingElement 0

    *markintersection elements 1 elements 2
    set allE [hm_getmark elements 1]
    if {[hm_marklength elements 1]==0} {
      return
    }
#    set vecSize [expr $xScale * [hm_getentityvalue elements [lindex $allE 0] shortestside 0]]
    lappend header "*filetype(ASCII)" "*version(10.0build60)"
    foreach e $allE {
      lappend header "*node(${e}0,[join [set centerArr($e) [hm_entityinfo centroid elements $e]] ","],0,0,0,0,0)"
    }
    *findmark elements 1 1 0 nodes 0 1
    foreach n [hm_getmark nodes 1] {
      set coordArr($n) [lindex [hm_nodevalue $n] 0]
    }
    if {$type == "vector"} {
      *createmark vectorcols 1 "^X" "^Y" "^Z"
      if {[hm_marklength vectorcols 1]>0} {
        *deletemark vectorcols 1
      }
      set VX [list "*vectorcollector(1,\"^X\",[hm_getdisplaycolor 18])"]
      set VY [list "*vectorcollector(2,\"^Y\",[hm_getdisplaycolor 19])"]
      set VZ [list "*vectorcollector(3,\"^Z\",[hm_getdisplaycolor 20])"]
    } else {
      *createmark comps 1 "^X" "^Y" "^Z"
      if {[hm_marklength comps 1]>0} {
        *deletemark comps 1
      }
      set VX [list "*component(1,\"^X\",0,[hm_getdisplaycolor 18],0)"]
      set VY [list "*component(2,\"^Y\",0,[hm_getdisplaycolor 19],0)"]
      set VZ [list "*component(3,\"^Z\",0,[hm_getdisplaycolor 20],0)"]
    }


    foreach e $allE {
      set vecSize [expr $xScale * [hm_getentityvalue elements $e shortestside 0]]
      set YSize [expr $vecSize * $yScale]
      set ZSize [expr $vecSize * $zScale]
      if {$orientationType =="Shell"} {
        foreach {n1 n2 n3 n4} [hm_nodelist $e] break
        math::NORM [math::SUB $coordArr($n3) $coordArr($n1)] w1
        math::NORM [math::SUB $coordArr($n2) $coordArr($n4)] w2
        math::NORM [math::ADD $w1 $w2] X
        math::NORM [math::CROSS $w2 $w1] Z
        math::NORM [math::CROSS $Z $X] Y
      } else {
        foreach {n1 n2 n3 n4 n5 n6 n7 n8} [hm_nodelist $e] break
        set e67 [math::ADD $coordArr($n6) $coordArr($n7)]
        set e58 [math::ADD $coordArr($n5) $coordArr($n8)]
        set e23 [math::ADD $coordArr($n2) $coordArr($n3)]
        set e14 [math::ADD $coordArr($n1) $coordArr($n4)]
        set dz [math::SUB [math::ADD $e58 $e67] [math::ADD $e14 $e23]]
        set dx [math::SUB [math::ADD $e23 $e67] [math::ADD $e14 $e58]]
        math::NORM [math::CROSS $dz $dx] Y
        math::NORM [math::CROSS $Y $dz] X
        math::NORM $dz Z
      }
      if {$type=="vector"} {
        lappend VX "*vectorentity(${e}1,0,${e}0,0,[join $X ","],$vecSize)"
        lappend VY "*vectorentity(${e}2,0,${e}0,0,[join $Y ","],$YSize)"
        lappend VZ "*vectorentity(${e}3,0,${e}0,0,[join $Z ","],$ZSize)"
      } else {
        lappend header "*node(${e}1,[join [math::ADD $centerArr($e) [math::MUL $X $vecSize]] ","],0,0,0,0,0)"
        lappend header "*node(${e}2,[join [math::ADD $centerArr($e) [math::MUL $Y $YSize]] ","],0,0,0,0,0)"
        lappend header "*node(${e}3,[join [math::ADD $centerArr($e) [math::MUL $Z $ZSize]] ","],0,0,0,0,0)"
        lappend VX "*plotel(${e}1,1,${e}0,${e}1)"
        lappend VY "*plotel(${e}2,1,${e}0,${e}2)"
        lappend VZ "*plotel(${e}3,1,${e}0,${e}3)"
      }
    }
    set oF [open "_vec.hmasc" w]
    puts $oF [join $header \n]
    puts $oF [join $VX \n]
    puts $oF [join $VY \n]
    puts $oF [join $VZ \n]
    close $oF
    catch {*removeview "_orient"}
    *saveviewmask "_orient" 1
    hm_blockmessages 1
    hm_blockredraw 1
    *createstringarray 0
    *feinputwithdata2 "#hmascii\\hmascii" "_vec.hmasc" 0 0 0 0 0 1 0 1 0
    hm_blockmessages 0
    hm_blockredraw 0
    *clearmark nodes 1
    *clearmark elements 1
    *clearmark elements 2
    *vectorlabel 0
    file delete _vec.hmasc
    *restoreviewmask "_orient" 1
    *setdisplayattributes 0 0
  }

   proc setOriElem {} {
    variable orientationElement
    variable orientationType
    variable reverseText
    variable requestingElement
    if {[info exist requestingElement] && $requestingElement == 1} {
      if {[tk_messageBox -message "There seems to be another element selection waiting to be submitted!\nTo continue might cause instable behavor!\nContinue anyway?" -type yesno]=="no"} {
        return
      }
    }
    set requestingElement 1
    *createentitypanel elements 1 "Select orientation element"
    set selElem [hm_info lastselectedentity elements]
    set requestingElement 0
    if {$selElem==0} {
      set orientationType ""
      return
    }
    set cfg [hm_getentityvalue elements $selElem config 0]
    switch $cfg {
      108 - 104 {
        set orientationElement $selElem
        set orientationType "Shell"
        set reverseText "Reverse normal"
        createSystems one
      }
      220 - 208 {
        set orientationElement $selElem
        set orientationType "Solid"
        set reverseText "Turn downwards (z->x)"
        createSystems one
      }
    }
    return
  }

  proc turnOriElem {{what "left"}} {
    variable orientationElement
    variable orientationType

    if {$orientationType==""} {
      return
    }
    if {$orientationType=="Shell"} {
      switch $what {
        "left" {
           *element2Dshiftnodes $orientationElement  1 3 0 0 0
        }
        "right" {
           *element2Dshiftnodes $orientationElement  1 1 0 0 0
        }
        "normal" {
          *createmark elements 1 $orientationElement
          #foreach {n3 n2 n1} [lrange [hm_nodelist $orientationElement] 1 3] break
           eval *element2Dshiftnodes $orientationElement 4 0 [hm_getentityvalue elements $orientationElement node4.id 0] 0 0
        }
      }
    } else {
      switch $what {
        "left" {
           *element3Dshiftnodes $orientationElement  1 1 0 0 0 0
        }
        "right" {
           *element3Dshiftnodes $orientationElement  1 3 0 0 0 0
        }
        "normal" {
           *element3Dshiftnodes $orientationElement  1 52 0 0 0 0
        }
      }
    }
    createSystems one
  }

  proc clearSystems {} {
    variable type
    if {$type== "vector"} {
      *createmark vectorcols 1 "^X" "^Y" "^Z"
      if {[hm_marklength vectorcols 1]>0} {
        *deletemark vectorcols 1
      }
    } else {
      *createmark comps 1 "^X" "^Y" "^Z"
      if {[hm_marklength comps 1]>0} {
        *deletemark comps 1
      }
    }
  }

  proc DestroyPanel {} {
      variable tabname
      variable main
      hm_framework removetab $tabname
      destroy $main
      clearSystems
  }

  proc orientMesh {{what ""}} {
    variable orientationElement
    variable orientationType
    variable requestingElement
    if {[info exist requestingElement] && $requestingElement == 1} {
      if {[tk_messageBox -message "There seems to be another element selection waiting to be submitted!\nTo continue might cause instable behavor!\nContinue anyway?" -type yesno]=="no"} {
        return
      }
    }
    set requestingElement 1
    if {$orientationType==""} {
      return
    }
    if {$what =="attached"} {
      *createmark elements 1 $orientationElement
      *appendmark elements 1 "by attached"
    } else {
      *createmarkpanel elements 1 "Select Elements to orientate"
      if {[hm_marklength elements 1]==0} {
        set requestingElement 0
        return
      }
    }
    set requestingElement 0
    if {$orientationType == "Shell"} {
      *createmark elements 2 "by config" 104 108
    } else {
      *createmark elements 2 "by config" 208 220
    }
    *markintersection elements 1 elements 2
     set oElems [hm_getmark elements 1]
     if {[llength $oElems]>0} {
       *createmark elements 2 $orientationElement
       if {$orientationType == "Shell"} {
         *element2Dalign 1 2 1
       } else {
         *element3Dalign 1 2 1
       }
       createSystems oElems
     }
  }

  proc CreatePanel {} {
      variable tabname
      variable main
      variable debug
      variable reverseText
      variable orientationElement
      variable orientationType
      set pady 3
      set ns "[namespace current]::"
      set tablist [ hm_framework getalltabs ]
      if { [ lsearch $tablist $tabname ] > -1 } {
        DestroyPanel
      }
      if {[winfo exist .orientQuad]} {
        destroy .orientQuad
      }

      set main [ frame .orientQuad ]
      hm_framework addtab $tabname $main

      label $main.spaceHead
      pack $main.spaceHead

      set oElem [hwt::LabeledFrame $main.oElem   " Arrange orientation element" topPad 2\
                                 -side    top \
                                 -anchor  nw \
                                 -padx    1 \
                                 -pady    $pady \
                                 -justify left \
                                 -expand  0]

      set nButton  [button $oElem.nButton \
             -bg yellow \
             -activebackground yellow \
             -command "${ns}setOriElem" \
             -text "Define orientation Element" \
             -font [hwt::AppFont]]
      set cwButton  [button $oElem.cwButton \
             -command "${ns}turnOriElem right" \
             -text "Turn clockwise" \
             -font [hwt::AppFont]]
      set acwButton  [button $oElem.acwButton \
             -command "${ns}turnOriElem left" \
             -text "Turn anti-clockwise" \
             -font [hwt::AppFont]]

      if {$orientationType == "" || $orientationType == "Shell"} {
        set reverseText "Reverse normal"
      } else {
        set reverseText "Turn downwards (z->x)"
      }
      set nrmButton  [button $oElem.nrmbutton \
             -command "${ns}turnOriElem normal" \
             -textvariable ${ns}reverseText \
             -font [hwt::AppFont]]

      set aButton  [button $oElem.abutton \
             -command "${ns}orientMesh attached" \
             -text "Orient attached mesh" \
             -font [hwt::AppFont]]
      set oButton  [button $oElem.obutton \
             -command "${ns}orientMesh" \
             -text "Orient Selection" \
             -font [hwt::AppFont]]
      set sButton  [button $oElem.sbutton \
             -command "${ns}createSystems" \
             -text "Show Systems" \
             -font [hwt::AppFont]]
      set cButton  [button $oElem.cbutton \
             -command "${ns}clearSystems" \
             -text "Delete Systems" \
             -font [hwt::AppFont]]
      set tLabel [label $oElem.tLabel -textvariable [namespace current]::orientationElement -font [hwt::AppFont]]
      set tType  [label $oElem.tType  -textvariable [namespace current]::orientationType -font [hwt::AppFont]]


      grid columnconfigure $oElem 0 -weight 1 -uniform A
      grid columnconfigure $oElem 1 -weight 1 -uniform A
      grid columnconfigure $oElem 2 -weight 1 -uniform A
      grid columnconfigure $oElem 3 -weight 1 -uniform A
      grid $nButton    -row 0 -column 0 -padx 4 -pady 5 -sticky we -columnspan 2
      grid $tLabel     -row 0 -column 3 -padx 4 -pady 2 -sticky w
      grid $tType      -row 0 -column 2 -padx 4 -pady 2 -sticky e

      grid $aButton    -row 3 -column 2 -padx 4 -pady 2 -sticky we -columnspan 2
      grid $oButton    -row 4 -column 2 -padx 4 -pady 2 -sticky we -columnspan 2

      grid $cwButton   -row 3 -column 0 -padx 4 -pady 2 -sticky we -columnspan 2
      grid $acwButton  -row 4 -column 0 -padx 4 -pady 2 -sticky we -columnspan 2
      grid $nrmButton  -row 5 -column 0 -padx 4 -pady 2 -sticky we -columnspan 2

      grid $sButton    -row 6 -column 0 -padx 4 -pady 2 -sticky we -columnspan 2
      grid $cButton    -row 6 -column 2 -padx 4 -pady 5 -sticky we -columnspan 2

      if {0==1} {
        set shButton  [button $main.shbutton \
             -command "${ns}shuffleShellElements" \
             -text "Shuffle Shells" \
             -font [hwt::AppFont]]
        pack $shButton -side top
        set shSButton  [button $main.shSbutton \
             -command "${ns}shuffleSolidElements" \
             -text "Shuffle Solids" \
             -font [hwt::AppFont]]
        pack $shSButton -side top
      }
  }


  proc shuffleShellElements {} {
    *createmark elements 1 "by config" 104  108
    set eL [hm_getmark elements 1]
    foreach e $eL {
      set shift [expr $e % 4]
      if {$shift} {
        *element2Dshiftnodes $e 1 $shift 0 0 0
      }
      if {[expr {$e & 8}]} {
        lappend reverse $e
      }
    }
    if {[info exist reverse]} {
      eval *createmark elements 1 reverse
      *normalsreverse elements 1 0
      *normalsoff
    }
    *createmark elements 1 "by config" 104 108
    createSystems eL Shell
  }
  proc shuffleSolidElements {} {
    *createmark elements 1 "by config" 208 220
    set eL [hm_getmark elements 1]
    foreach e $eL {
      set shift [expr $e % 4]
      set face [expr ($e / 4) % 6 -1]
      if {$face + $shift > 2} {
        *element3Dshiftnodes $e 1 ${face}$shift 0 0 0 0
      }
    }
    *createmark elements 1 "by config" 208  220
    createSystems eL Solid
  }

}
orientElems::CreatePanel
