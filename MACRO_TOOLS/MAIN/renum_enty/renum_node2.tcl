# HWVERSION_9.0_February 25 2009
#------------------------------------------------------------------------------#
#  Copyright (c) 2007 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.            Update : 13/02/2009             #
#------------------------------------------------------------------------------#
option add *font { {Tahoma} 8 roman};
option add *Dialog.msg.font { {Tahoma} 8 roman};
hwt::SetAppFont -point 8 Tahoma

#------------------------------------------------------------------------------#
# Deletes name space                                                           #
#------------------------------------------------------------------------------#
catch {namespace delete ::Renum_nodes};
#------------------------------------------------------------------------------#
# Global Variables                                                             #
#------------------------------------------------------------------------------#
namespace eval ::Renum_nodes {

    variable node_list  "";
    variable startid    "0";
    variable incremen   "1";

    #panel title name
    set ptitle "Renumber elements control";



    #source the hwcollector.tcl for using the collector widget
    set altair_home [ hm_info -appinfo ALTAIR_HOME ];
    set col_dir [file join $altair_home "hw" "tcl" "hw" "collector" "hwcollector.tcl"];
    # On Windows, replace the forward slash with backward slash.
    if {[string equal $::tcl_platform(platform) windows]} {
        set col_dir [string map {/ \\} $col_dir];
    }
    source $col_dir;

}
#------------------------------------------------------------------------------#
# ::Renum_nodes::MainWindow                                                    #
# purpose: to create main dialog                                               #
# -----------------------------------------------------------------------------#
proc ::Renum_nodes::MainWindow { args } {
    variable type;
    variable ptitle;
    variable pFrame;
    variable startid;
    variable incremen;


    #destroy panel if it exist
    catch {destroy .g_renum_nodes_TPanel}

    #add hm panel
    set pFrame [frame .g_renum_nodes_TPanel -padx 7 -pady 7];
    hm_framework addpanel $pFrame $ptitle;

    #Create Frames in new panel
    set f1  [frame $pFrame.f1];
    set f2  [frame $pFrame.f2];
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
    grid $f3  -row 0 -column 4 -sticky nws;
    grid $f4  -row 0 -column 6 -sticky nws;


    #frame 2
    frame $f2.f2;
    grid rowconfigure $f2.f2 2 -weight 1;
    grid $f2.f2 -sticky nw;

    set bWidth  [hwt::DluWidth 92]
    set bHeight [hwt::DluHeight 14]


    #hm_collector widget
    Collector $f2.f2.coll entity 1 HmMarkCol \
        -types  "nodes" \
        -withtype     0 \
        -withReset     1 \
        -callback ::Renum_nodes::NodeEntityCollectorHandler;

    grid $f2.f2.coll -sticky news -pady 4;
    $f2.f2.coll invoke Elements;

    # frame 3

    frame $f3.s;
    grid $f3.s -row 2 -column 0 -sticky nw;
    #
    label $f3.s.lab1 -text "Start ID:" \
         -width 12 \
         -justify left \
         -anchor nw \
         -font [hwt::AppFont];

    grid $f3.s.lab1  -row 2 -column 0 -sticky w -padx 7;

    #
    hwt::AddEntry $f3.s.vect_ent \
         entrywidth  15 \
         withoutPacking \
         -validate real \
         -justify right \
         -textvariable ::Renum_nodes::startid \
         State "normal";

    grid $f3.s.vect_ent -row 2 -column 1 -sticky nw -ipady 2 -ipadx 1;

    frame $f3.s2;
    grid $f3.s2 -row 4 -column 0 -sticky nw;
    #
    label $f3.s2.lab2 -text "Increment:" \
         -width 12 \
         -justify left \
         -anchor nw \
         -font [hwt::AppFont];

    grid $f3.s2.lab2  -row 2 -column 0 -sticky w -padx 7;

    #
    hwt::AddEntry $f3.s2.inc_ent \
         entrywidth  15 \
         withoutPacking \
         -validate real \
         -justify right \
         -textvariable ::Renum_nodes::incremen \
         State "normal";

    grid $f3.s2.inc_ent -row 2 -column 1 -sticky nw -ipady 2 -ipadx 1;

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
            -text "renumber" \
            -command "::Renum_nodes::OnRenumber" \
            -relief raised;
    grid $f4.f2.disp -sticky nw;

    #reject button
    hwt::CanvasButton $f4.f2.lab1 \
            $bWidth  \
            $bHeight \
            -background $bkgClr \
            -text "reject" \
            -command "::Renum_nodes::OnReject" \
            -relief raised;
    grid $f4.f2.lab1 -sticky nw;

    #return button
    hwt::CanvasButton $f4.f2.f \
        $bWidth \
        $bHeight \
        -background #c96341 \
        -text "return" \
        -command "::Renum_nodes::OnQuit" \
        -relief raised;
    grid $f4.f2.f -sticky nw -pady 55;

    #draw hm panel
    hm_framework drawpanel $pFrame;
}
#------------------------------------------------------------------------------#
# ::Renumber_nodes::Exists                                                     #
# This function checks whether edit element created panel exists or not.       #
# Return    : 0 : not exists , 1 : exists                                      #
#------------------------------------------------------------------------------#
proc ::Renum_nodes::Exists {args} {

    if { [ winfo exists .g_renum_nodes_TPanel ] } { return 1 }
    
    return 0;
}
#------------------------------------------------------------------------------#
# ::Renum_nodes::NodeEntityCollectorHandler                                    #
# Handler for the Collector                                                    #
# -----------------------------------------------------------------------------#
proc ::Renum_nodes::NodeEntityCollectorHandler { args } {
    variable node_list "";
    variable count "0"


    switch [ lindex $args 0 ] {
        "getadvselmethods"
        {
            foreach {entity} $args break
            *createlistpanel nodes 1 "Select nodes for renumber"
            set node_list [hm_getlist node 1]
            hm_highlightlist nodes 1 l
            #hm_markclear  nodes 1

            return
        }
        "reset"
        {
            set node_list "";
            *clearmark nodes 1
            hm_highlightlist nodes 1 n
        }
        default
        {
            # This should not do anything
            return
        }
    }
}


#-----------------------------------------------------------------------------#
# Renum_nodes::OnRenumber                                                     #
# Purpose: to execute renumber                                                #
#-----------------------------------------------------------------------------#
proc ::Renum_nodes::OnRenumber { args } {
    variable node_list
    variable Nnode_list
    variable startid
    variable incremen
    variable count

  set num_node [llength $node_list]
  if {$num_node=="0"} {
    hm_errormessage "Error: No node selected.";
    return;
  }
  if {$startid=="0"} {
    hm_errormessage "Error: The start id is 0";
    return;
  }
  if {$incremen=="0"} {
    hm_errormessage "Error: The increment number is 0";
    return;
  }

#Check ID's
    set err_list ""
    set SSid $startid

    for {set j 0} {$j < $num_node} {incr j} {
        set stat [hm_entityinfo exist node $SSid]
        if {$stat=="1"} {lappend err_list $SSid}
        eval set SSid [expr $SSid + $incremen]
    }
    if {[llength $err_list] != "0"} {
        tk_messageBox -type ok -message "The number that you specified already exists. Please check it. \n $err_list";
        return;
    }

#Change ID
    set Newid $startid
    set Nnode_list ""
    *clearlist node 1

    for {set i 0} {$i < $num_node} {incr i} {
        set node_no [lindex $node_list $i]
        *clearmark node 1
        eval *createmark node 1 $node_no
        *renumbersolverid nodes 1 $Newid 1 0 0 0 0 0
        eval *createmark node 1 $Newid
        *numbersmark node 1 1
        lappend Nnode_list $Newid
        eval set Newid [expr $Newid + $incremen]
    }
  set count "1"
}

#------------------------------------------------------------------------------#
# Renum_nodes::OnReject                                                        #
# Purpose: to reject renumbering                                               #
# -----------------------------------------------------------------------------#
proc ::Renum_nodes::OnReject {args} {
    variable node_list
    variable Nnode_list
    variable startid
    variable incremen
    variable count

    set num_node [llength $node_list]
    if {$count == "1"} {
      for {set i 0} {$i < $num_node} {incr i} {
        set Nnode_no [lindex $Nnode_list $i]
        set node_no [lindex $node_list $i]
        *clearmark node 1
        eval *createmark node 1 $Nnode_no
        *renumbersolverid nodes 1 $node_no 1 0 0 0 0 0
      }
    } else {
      hm_errormessage "Error: No reject operation";
    }
  set count "0"
}
#------------------------------------------------------------------------------#
# Renum_nodes::OnQuit                                                          #
# stop operation and exit hm panel                                             #
# -----------------------------------------------------------------------------#
proc ::Renum_nodes::OnQuit { args} {
    variable pFrame;

    #Exit panel
    hm_exitpanel
}

#End
::Renum_nodes::MainWindow

