# HWVERSION_9.0_February 25 2009
#------------------------------------------------------------------------------#
#  Copyright (c) 2007 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.            Update : 13/02/2009             #
#------------------------------------------------------------------------------#
# history
# 1.4.4
#   If users invoke this script before exitting their current panel, users
#   cannot select nodes and go to infinite loop. Fixed.
#
option add *font { {Tahoma} 8 roman};
option add *Dialog.msg.font { {Tahoma} 8 roman};
hwt::SetAppFont -point 8 Tahoma
hm_exitpanel
hm_exitpanel

#------------------------------------------------------------------------------#
# Deletes name space                                                           #
#------------------------------------------------------------------------------#
catch {namespace delete ::SHELL_ELEM_COORD_DISPLAY};
#------------------------------------------------------------------------------#
# Global Variables                                                             #
#------------------------------------------------------------------------------#
namespace eval ::SHELL_ELEM_COORD_DISPLAY {

    variable color      "";
    variable node_list  "";
    variable vectorSize "";
    variable elem_list "";

    #panel title name
    set ptitle "Shell elements coordinate control";

    #source color pallette dialog
    set hm_scriptsdir [hm_info -appinfo SPECIFIEDPATH hm_scripts_dir];
    SourceFile "$hm_scriptsdir/postColorDialog.tcl";

    #source the hwcollector.tcl for using the collector widget
    set altair_home [ hm_info -appinfo ALTAIR_HOME ];
    set col_dir [file join $altair_home "hw" "tcl" "hw" "collector" "hwcollector.tcl"];
    # On Windows, replace the forward slash with backward slash.
    if {[string equal $::tcl_platform(platform) windows]} {
        set col_dir [string map {/ \\} $col_dir];
    }
    source $col_dir;

    #get color list
    variable colorList "";
    foreach colr [hm_winfo entitycolors] {
        set colr [eval format #%02x%02x%02x $colr];
        lappend colorList $colr;
    }
}
#------------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::MainWindow                                       #
# purpose: to create main dialog                                               #
# -----------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::MainWindow { args } {
    variable type;
    variable ptitle;
    variable vectorSize "0.0"; 
    variable cor_size;


    #destroy panel if it exist
    catch {destroy .g_shellElemsCoordControl_TPanel}

    #add hm panel
    set pFrame [frame .g_shellElemsCoordControl_TPanel -padx 7 -pady 7];
    hm_framework addpanel $pFrame $ptitle;

    #Create Frames in new panel
    set f1  [frame $pFrame.f1];
    set f2  [frame $pFrame.f2];
    set sp  [frame $pFrame.sp -bd 2 -relief groove -width 2];
    set f3  [frame $pFrame.f3];
    set f4  [frame $pFrame.f4];

    grid rowconfigure  $pFrame 0 -weight 1;
    grid rowconfigure  $f1     5 -weight 1;
    grid rowconfigure  $f2     0 -weight 1;
    grid rowconfigure  $f3     5 -weight 1;
    grid rowconfigure  $f4     7 -weight 1;
    grid columnconfigure $pFrame 5 -weight 1;

    grid $f1  -row 0 -column 0 -sticky news;
    grid $f2  -row 0 -column 1 -sticky news -padx 7;
    grid $sp  -row 0 -column 3 -sticky ns   -padx 7;
    grid $f3  -row 0 -column 4 -sticky nws;
    grid $f4  -row 0 -column 6 -sticky nws;

    # frame 1
    label $f1.lab -text "Shell Elements:";
    grid $f1.lab -row 0 -column 0 -sticky nws;

    label $f1.coordCntrl -text "Coordinate Control:";
    grid $f1.coordCntrl -column 0 -sticky nw -padx 7 -pady 2;

    #frame 2
    frame $f2.f2;
    grid rowconfigure $f2.f2 2 -weight 1;
    grid $f2.f2 -sticky nw;

    set bWidth  [hwt::DluWidth 92]
    set bHeight [hwt::DluHeight 14]

    #frame $f2.f2
    label $f2.f2.lab1 -text "Select Elements:";
    grid $f2.f2.lab1 -sticky nw;

    #hm_collector widget: elemement select
    Collector $f2.f2.coll entity 1 HmMarkCol \
        -types  "elements" \
        -withtype     0 \
        -withReset     1 \
        -callback ::SHELL_ELEM_COORD_DISPLAY::ElementEntityCollectorHandler;

    grid $f2.f2.coll -sticky news -pady 4;
    $f2.f2.coll invoke Elements;

    frame $f2.f2.n;
    grid rowconfigure $f2.f2.n 2 -weight 1;
    set ::SHELL_ELEM_COORD_DISPLAY::c2 $f2.f2.n.c2;

    frame $f2.f2.f;
    grid rowconfigure $f2.f2.f 2 -weight 1;
    grid $f2.f2.f -sticky nw -pady 4;

    label $f2.f2.f.lab -text "Select nodes:";
    grid $f2.f2.f.lab -sticky nw -pady 4;

    #hm_collector widget: node select
    Collector $f2.f2.f.c3 entity 1 HmMarkCol \
        -types  "nodes" \
        -withtype     0 \
        -withReset     1 \
        -callback ::SHELL_ELEM_COORD_DISPLAY::NodeEntityCollectorHandler;

    grid $f2.f2.f.c3 -sticky news;

    # frame 3
    label $f3.lab -text "Display options:";
    grid $f3.lab -row 0 -column 0 -sticky nw;

    label $f3.lab2 -text "Color:";
    grid $f3.lab2 -row 1 -column 0 -sticky nw -padx 7 -pady 4;

    hwt::CanvasButton $f3.c 11 11 \
        -background white \
        -command "::SHELL_ELEM_COORD_DISPLAY::SetColor $f3.c";
    grid $f3.c -row 1 -column 0 -sticky nw -padx 89 -pady 4;


    frame $f3.s;
    grid $f3.s -row 2 -column 0 -sticky nw;
    #vector size
    label $f3.s.lab3 -text "Coord size:" \
         -width 12 \
         -justify left \
         -anchor nw \
         -font [hwt::AppFont];

    grid $f3.s.lab3  -row 2 -column 0 -sticky w -padx 7;

    #vector size entry box
    set cor_size [hwt::AddEntry $f3.s.vect_ent \
         entrywidth  15 \
         withoutPacking \
         -validate real \
         -justify right \
         -textvariable ::SHELL_ELEM_COORD_DISPLAY::vectorSize \
         -afterFunc ::SHELL_ELEM_COORD_DISPLAY::OnUpdateVector_Size \
         State "normal"];

    grid $cor_size -row 2 -column 1 -sticky nw -ipady 2 -ipadx 1;

    #frame 4
    frame $f4.f2;
    grid rowconfigure $f4.f2 2 -weight 1;
    grid $f4.f2 -sticky nw;
    
    set bWidth  [hwt::DluWidth 92];
    set bHeight [hwt::DluHeight 14];

    set bkgClr "#4ec852";
    #frame $f4.f2
    hwt::CanvasButton $f4.f2.disp \
            $bWidth  \
            $bHeight \
            -background $bkgClr \
            -text "display" \
            -command "::SHELL_ELEM_COORD_DISPLAY::OnDisplay" \
            -relief raised;
    grid $f4.f2.disp -sticky nw;

    #adjust button
    hwt::CanvasButton $f4.f2.lab1 \
            $bWidth  \
            $bHeight \
            -background $bkgClr \
            -text "adjust" \
            -command "::SHELL_ELEM_COORD_DISPLAY::OnAdjust" \
            -relief raised;
    grid $f4.f2.lab1 -sticky nw;

    #return button
    hwt::CanvasButton $f4.f2.f \
        $bWidth \
        $bHeight \
        -background #c96341 \
        -text "return" \
        -command "::SHELL_ELEM_COORD_DISPLAY::OnQuit" \
        -relief raised;
    grid $f4.f2.f -sticky nw -pady 55;

    #draw hm panel
    hm_framework drawpanel $pFrame;
}
#------------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::Exists                                           #
# This function checks whether edit element created panel exists or not.       #
# Return    : 0 : not exists , 1 : exists                                      #
#------------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::Exists {args} {

    if { [ winfo exists .g_shellElemsCoordControl_TPanel ] } { return 1 }
    return 0;
}
#------------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::ElementEntityCollectorHandler                    #
# Handler for the Collector                                                    #
# -----------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::ElementEntityCollectorHandler { args } {
    variable elem_list "";
    variable size_ave;
    variable vectorSize;
    set n_elemlist "";

    switch [ lindex $args 0 ] {
        "getadvselmethods"
        {
            foreach {entity} $args break
            #hm_markclear elements 1
            *createmarkpanel elements 1 "Select shell elements to control coordinate"
            set element_list [hm_getmark elements 1]
            foreach eid $element_list {
               if {[hm_getentityvalue elem $eid config 0] == "104"} {lappend elem_list $eid}
            }
            hm_markclear elements 1
            eval *createmark elements 1 $elem_list
            hm_highlightmark elems 1 l
            set size_ave [hm_getaverageelemsize 1]
            set size_ave [expr $size_ave * 0.5]
            set vectorSize $size_ave

            return
        }
        "reset"
        {
            set elem_list "";
            *clearmark elements 1
        }
        default
        {
            # This should not do anything
            return
        }
    }
}
#------------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::NodeEntityCollectorHandler                       #
# Handler for the Collector                                                    #
# -----------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::NodeEntityCollectorHandler { args } {

    variable node_list "";
    variable ref_elem_selected;

    switch [ lindex $args 0 ] {
        "getadvselmethods"
        {
#            foreach {entity} $args break
            *createlistpanel nodes 2 "Select two nodes for Axis-1 direction."
            set node_list [hm_getlist nodes 2]
            if {[llength $node_list] != "2"} {
               tk_messageBox -message "Select two nodes.";
#               ::SHELL_ELEM_COORD_DISPLAY::NodeEntityCollectorHandler "getadvselmethods"
            } 
            hm_highlightlist node 2 l
            return
        }
        "reset"
        {
            set node_list ""
            set ref_elem_selected false
            *clearmark elems 1
        }
        default
        {
            # This should not do anything
            return
        }
    }
}

#------------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::SetColor                                         #
# purpose: to apply coordinate or system color                                 #
#------------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::SetColor { win } {
    variable color;
    variable col;

    #color value
    set color [::post::colordialog::BuildDialog $win];

    if { $color == 1 } {
        return;
    } else {
        set frm ".g_shellElemsCoordControl_TPanel.f3.c";
        $frm configure -background [lindex $color 1];
        set cre_sys [*createmark systcols 1 "00system00_temp"]#
        set col [lindex $color 0]
        catch {*colormark systcols 1 [expr $col + 1]}
        *clearmark systcols 1
    }
}
#-----------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::OnUpdateVector_Size                             #
# Purpose: to specify vector size                                             #
#-----------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::OnUpdateVector_Size { args } {
    variable vectorSize;
    variable cor_size;

    *systemsize $vectorSize
    *plot
}
#-----------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::OnDisplay                                       #
#                                                                             #
#-----------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::OnDisplay { args } {
    variable elem_list;
    variable size_ave;
    variable col;

    set num_ele [llength $elem_list]
    if {$num_ele == "0"} { 
       hm_errormessage "Error: No element selected.";
#      tk_messageBox -message "No element selected";
      return;
    }

    #Check the systemcols name of "00system00_temp".
    if {[hm_entityinfo exist systemcols "00system00_temp"]==1} {
      hm_markclear systemcols 1
      *createmark systemcols 1 "00system00_temp"
      *deletemark systemcols 1
    }
    set color_id "2"
    catch {if {$col != ""} {set color_id [expr $col + 1]};}
      *collectorcreate systemcols "00system00_temp" "" $color_id
      *currentcollector systemcols "00system00_temp"
    

    foreach el $elem_list {

   	set bb   [hm_getentityvalue elem $el node2.id 0]
	set cc   [hm_getentityvalue elem $el node3.id 0]
 	set cent [hm_entityinfo centroid element $el]

  	#set bbv(0) [hm_getentityvalue node $bb x 0 ]
  	#set bbv(1) [hm_getentityvalue node $bb y 0 ]
  	#set bbv(2) [hm_getentityvalue node $bb z 0 ]
  	#set ccv(0) [hm_getentityvalue node $cc x 0 ]
  	#set ccv(1) [hm_getentityvalue node $cc y 0 ]
  	#set ccv(2) [hm_getentityvalue node $cc z 0 ]
    # Fukuoka modified. If a node sees a ref. system, it returns its local
    # coordinate.  Global coordinate is needed.
    set bbv(0) [eval lindex [hm_nodevalue $bb] 0]
    set bbv(1) [eval lindex [hm_nodevalue $bb] 1]
    set bbv(2) [eval lindex [hm_nodevalue $bb] 2]
    set ccv(0) [eval lindex [hm_nodevalue $cc] 0]
    set ccv(1) [eval lindex [hm_nodevalue $cc] 1]
    set ccv(2) [eval lindex [hm_nodevalue $cc] 2]
	set aav(0) [lindex $cent 0]
     	set aav(1) [lindex $cent 1]
    	set aav(2) [lindex $cent 2]

	for {set i 0} {$i < 3} {incr i} {
          set v1($i)  [expr $bbv($i) - $aav($i)]
          set v2($i)  [expr $ccv($i) - $aav($i)]
          set v11($i) [expr $v1($i) * $v1($i)]
          set v22($i) [expr $v2($i) * $v2($i)]
    	}
       	set vv1 [expr sqrt($v11(0)+$v11(1)+$v11(2))]
     	set vv2 [expr sqrt($v22(0)+$v22(1)+$v22(2))]

	for {set i 0} {$i < 3} {incr i} {
          set rv1($i)  [expr $v1($i) / $vv1]
          set rv2($i)  [expr $v2($i) / $vv2]
          set Tv($i)   [expr $rv1($i) + $rv2($i)]
          set Tval($i) [expr $aav($i) + $Tv($i)]
        }

        *createnode [lindex $cent 0] [lindex $cent 1] [lindex $cent 2]
        set cNode [hm_entitymaxid node 1]
        *createnode $Tval(0) $Tval(1) $Tval(2) 
        set vNode [hm_entitymaxid node 1]

	*createmark nodes 1 $cNode
        *systemcreate 1 0 $cNode "x-axis" $vNode "xy plane" $cc
        *systemsize $size_ave
        *nodecleartempmark
    }
    hm_highlightmark elems 1 n
    set elem_list ""

}

#------------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::OnAdjust                                         #
#                                                                              #
# -----------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::OnAdjust {args} {
    variable elem_list;
    variable node_list;

  if {[llength $elem_list]==0} {
    hm_errormessage "Error: No element selected.";
    return;
  }
  if {[llength $node_list]==0} {
    hm_errormessage "Error: No node selected.";
    return;
  }


#Calculate nodes vector and size.
  set xyz1 [lindex [hm_nodevalue [lindex $node_list 0]] 0]
  set xyz2 [lindex [hm_nodevalue [lindex $node_list 1]] 0]
  for {set i 0} {$i < 3} {incr i} {
     set Bvec($i) [eval expr [lindex $xyz2 $i] - [lindex $xyz1 $i]]
  }
  #set Bvec_s [expr sqrt($Bvec(0)*$Bvec(0) + $Bvec(1)*$Bvec(1) + $Bvec(2)*$Bvec(2))]

#Check the origin node and No1 axis node.
  for {set i 0} {$i < [llength $elem_list]} {incr i} {

    set elemid  [lindex $elem_list $i]
    set compid  [hm_getentityvalue elems $elemid collector.id 0]
    set compname [hm_getcollectorname comps $compid]
    set current [hm_info currentcomponent]
    set node(0) [hm_getentityvalue elems $elemid node1.id 0]
    set node(1) [hm_getentityvalue elems $elemid node2.id 0]
    set node(2) [hm_getentityvalue elems $elemid node3.id 0]
    set node(3) [hm_getentityvalue elems $elemid node4.id 0]

    for {set j 0} {$j < 4} {incr j} {
        set nodex($j) [hm_getentityvalue node $node($j) globalx 0]
        set nodey($j) [hm_getentityvalue node $node($j) globaly 0]
        set nodez($j) [hm_getentityvalue node $node($j) globalz 0]
    }

#Caluculate each node's vector. (ex: node1 - node0)

    for {set j 0} {$j < 4} {incr j} {
      if {$j < 3} {
        set id_1 [expr $j + 1]
      } else {
        set id_1 "0"
      }
      set vx($j) [expr $nodex($id_1) - $nodex($j)] 
      set vy($j) [expr $nodey($id_1) - $nodey($j)] 
      set vz($j) [expr $nodez($id_1) - $nodez($j)] 
    }
#Calculate the diffrence between Base vector and each node's vector

    for {set j 0} {$j < 4} {incr j} {
      set dvx [expr $Bvec(0) - $vx($j)]
      set dvy [expr $Bvec(1) - $vy($j)]
      set dvz [expr $Bvec(2) - $vz($j)]
      set vec_size [expr sqrt($dvx*$dvx + $dvy*$dvy + $dvz*$dvz)]
      #set vec_dif  [expr $Bvec_s - $vec_size]

    #puts "$j $vec_size"

      if {$j == 0} {
        set min_id 0;
        set min_val [expr abs($vec_size)];
      } else {
        if {abs($vec_size) < abs($min_val)} {
          set min_id $j;
          set min_val [expr abs($vec_size)];
        }
      }
    }
    #puts "Res $min_id $min_val"

#If the "min_id != 0", it should be changed 

    if {$min_id != "0"} {
      if {$min_id == "1"} {
        *createlist node 1 $node(1) $node(2) $node(3) $node(0)
      } elseif {$min_id == "2"} {
        *createlist node 1 $node(2) $node(3) $node(0) $node(1)
      } elseif {$min_id == "3"} {
        *createlist node 1 $node(3) $node(0) $node(1) $node(2)
      }

      eval *currentcollector components $compname
      *createelement 104 1 1 0

      *clearmark elem 1
      *createmark elem 1 $elemid
      *deletemark elem 1

      *createmark elem 1 [hm_entitymaxid elem 1]
      *renumbersolverid elements 1 $elemid 1 0 0 0 0 0
    }

  }
  eval *currentcollector components $current
  hm_highlightlist node 2 n
  ::SHELL_ELEM_COORD_DISPLAY::OnDisplay;

}

#------------------------------------------------------------------------------#
# ::SHELL_ELEM_COORD_DISPLAY::OnQuit                                           #
# stop operation and exit hm panel                                             #
# -----------------------------------------------------------------------------#
proc ::SHELL_ELEM_COORD_DISPLAY::OnQuit { args} {
    variable pFrame;

    if {[hm_entityinfo exist systemcols "00system00_temp"]==1} {
      hm_markclear systemcols 1
      *createmark systemcols 1 "00system00_temp"
      *deletemark systemcols 1
    }

    #Exit panel
    hm_exitpanel
}

