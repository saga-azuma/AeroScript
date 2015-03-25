###########################################################
###                                                     ###
###   This macro provides a function for gap creation   ###
###                                                     ###
###########################################################
namespace eval _GAP_CREATION {
    variable win;
    variable selectionMethods;
    variable gapMenu;
    
    set selectionMethods {All "by Parts" "by Nodes"};
    set s_method "All";
    set gapMenu {"euclidean distance" "Dx" "Dy" "Dz" "user value"};
    set colorIndex 2;
}

################
###          ###
###   Init   ###
###          ###
################
proc ::_GAP_CREATION::Init { args } {  
    set ::_GAP_CREATION::selectedNodes "";
    set ::_GAP_CREATION::initialState "open";
    set ::_GAP_CREATION::openID "high";
    set ::_GAP_CREATION::analysisCS "uy";
    set ::_GAP_CREATION::createdComp "";
}

##############################################
###                                        ###
###   MainPanel                            ###
###   This procedure creates main window   ###
###                                        ###
##############################################
proc ::_GAP_CREATION::MainPanel { args } {
    variable win;
    
    set win(name) "gapCreation";
    set win(base) ".$win(name)";
    set win(title) "Gap creation";
    set win(width) 300;
    set win(height) 390;
    set win(x) 5;
    set win(y) 100;
    
    if { [ winfo exists $win(base) ] } {
        tk_messageBox -message "Window already exists." -type "ok" -icon info -title "Information";
        focus $win(base);
        return;
    }
    
    toplevel $win(base);
    wm geometry $win(base) $win(width)x$win(height)+$win(x)+$win(y);
    wm title $win(base) "$win(title)";
    wm protocol $win(base)  WM_DELETE_WINDOW ::_GAP_CREATION::Close;
    wm attributes $win(base) -topmost 1;
    
    set x1 7;
    set y1 10;
    label $win(base).lblGapGroup -text "gap group:";
    entry $win(base).entGapGroup -textvariable ::_GAP_CREATION::gapCompName -width 25;
    button $win(base).btnGapGroup -text "..." -width 4 -borderwidth 1 -command { ::_GAP_CREATION::SelectGapGroup };
    button $win(base).btnGroupColor -bg "#FFFFFF" -activebackground "#FFFFFF" -width 4 -relief flat;
    bind $win(base).btnGroupColor <ButtonRelease-1> { ::_GAP_CREATION::SetGroupColor %X %Y }; 
    place $win(base).lblGapGroup -x $x1 -y $y1;
    place $win(base).entGapGroup -x [ expr $x1 + 60 ] -y [ expr $y1 - 3 ] -height 24;
    place $win(base).btnGapGroup -x [ expr $x1 + 217 ] -y [ expr $y1 - 3 ] -height 24;
    place $win(base).btnGroupColor -x [ expr $x1 + 250 ] -y [ expr $y1 - 3 ] -height 24;
    
    set y2 [ expr $y1 + 30 ];
    set ::_GAP_CREATION::t_y2 [ expr $y2 - 3 ];
    label $win(base).lblSelectionMethod -text "selection method:";
    AddEntry $win(base).entSelectionMethod \
        text [ lindex $::_GAP_CREATION::selectionMethods 0 ] \
        entryWidth 8 \
        listVar fromPopDown \
        noTyping ::_GAP_CREATION::selectionMethods \
        state normal \
        withoutPacking \
        textvariable ::_GAP_CREATION::s_method \
        selectionFunc { ::_GAP_CREATION::SwitchMethod };
    place $win(base).lblSelectionMethod -x $x1 -y $y2;
    place $win(base).entSelectionMethod -x [ expr $x1 + 90 ] -y [ expr $y2 - 3 ] -height 24;
    
    set y3 [ expr $y2 + 30 ];
    frame $win(base).sp1 -height 2 -relief groove -borderwidth 2;
    place $win(base).sp1 -x 5 -y $y3 -width [ expr $win(width) - 10 ];
    
    set y4 [ expr $y3 + 8 ];
    label $win(base).lblInitialState -text "initial status (DMIG CDSHUT)";
    place $win(base).lblInitialState -x $x1 -y $y4;
    
    set x2 [ expr $x1 + 10 ];
    set y5 [ expr $y4 + 20 ];
    radiobutton $win(base).rbShut -text "shut" -variable ::_GAP_CREATION::initialState -value "shut";
    radiobutton $win(base).rbOpen -text "open" -variable ::_GAP_CREATION::initialState -value "open";
    place $win(base).rbShut -x $x2 -y $y5;
    place $win(base).rbOpen -x [ expr $x2 + 55 ] -y $y5;
    
    set y6 [ expr $y5 + 20 ];
    label $win(base).lblGapDistance -text "gap opening distance";
    place $win(base).lblGapDistance -x $x1 -y $y6;
    
    set y7 [ expr $y6 + 20 ];
    AddEntry $win(base).entGapMenu \
        text [ lindex $_GAP_CREATION::gapMenu 0 ] \
        entryWidth 16 \
        listVar fromPopDown \
        noTyping ::_GAP_CREATION::gapMenu \
        state normal \
        withoutPacking \
        textvariable ::_GAP_CREATION::distanceMethod \
        selectionFunc { ::_GAP_CREATION::SwitchDistanceMethod };
    AddEntry $win(base).entGapValue -textvariable ::_GAP_CREATION::gapValue -validate real -width 10 -state disabled;
    place $win(base).entGapMenu -x $x2 -y $y7 -height 24;
    place $win(base).entGapValue -x [ expr $x2 + 120 ] -y $y7 -height 24;
    
    set y8 [ expr $y7 + 30 ];
    label $win(base).lblNodeProxTol -text "Node Proximity Tolerance";
    place $win(base).lblNodeProxTol -x $x1 -y $y8;
    
    set y9 [ expr $y8 + 20 ];
    label $win(base).lblNodeProxTolMess -text "If coinc. Node, then opening node is:";
    place $win(base).lblNodeProxTolMess -x $x2 -y $y9;
    
    set y10 [ expr $y9 + 20 ];
    radiobutton $win(base).rbHigherID -text "higher ID" -variable ::_GAP_CREATION::openID -value "high";
    radiobutton $win(base).rbLowerID -text "lower ID" -variable ::_GAP_CREATION::openID -value "low";
    place $win(base).rbHigherID -x $x2 -y $y10;
    place $win(base).rbLowerID -x [ expr $x2 + 90 ] -y $y10;
    
    set y11 [ expr $y10 + 23 ];
    label $win(base).lblNodeGapTol -text "Create gap if nodes closer than:";
    AddEntry $win(base).entNodeGapTol -textvariable ::_GAP_CREATION::nodeGapTol -validate real;
    place $win(base).lblNodeGapTol -x $x2 -y $y11;
    place $win(base).entNodeGapTol -x [ expr $x2 + 155 ] -y [ expr $y11 - 3 ] -width 100 -height 24;
    
    set y12 [ expr $y11 + 23 ];
    label $win(base).lblNodesInGap -text "Nodes in Gap";
    place $win(base).lblNodesInGap -x $x1 -y $y12;
    
    set y13 [ expr $y12 + 20 ];
    label $win(base).lblNodesInGapMess -text "Gap direction(Analysis C.S.)";
    place $win(base).lblNodesInGapMess -x $x2 -y $y13;
    
    set y14 [ expr $y13 + 20 ];
    radiobutton $win(base).rbAnalysisUx -text "Ux" -variable ::_GAP_CREATION::analysisCS -value "ux";
    radiobutton $win(base).rbAnalysisUy -text "Uy" -variable ::_GAP_CREATION::analysisCS -value "uy";
    radiobutton $win(base).rbAnalysisUz -text "Uz" -variable ::_GAP_CREATION::analysisCS -value "uz";
    place $win(base).rbAnalysisUx -x $x2 -y $y14;
    place $win(base).rbAnalysisUy -x [ expr $x2 + 40 ] -y $y14;
    place $win(base).rbAnalysisUz -x [ expr $x2 + 80 ] -y $y14;      

    set y17 [ expr $y14 + 30 ]
    set ::_GAP_CREATION::nodestid [expr [hm_entitymaxid nodes] + 1];
    label $win(base).lblNodeStartID -text "Spoint start ID:";
    AddEntry $win(base).entNodeStartID -textvariable ::_GAP_CREATION::nodestid -validate integer;
    button $win(base).btnDef -text "Default" -width 8 -relief raised -borderwidth 1 -command { ::_GAP_CREATION::ChgDefault };
    place $win(base).lblNodeStartID -x $x1 -y $y17;
    place $win(base).entNodeStartID -x [ expr $x1 + 80 ] -y [ expr $y17 - 3 ] -width 100 -height 24;
    place $win(base).btnDef -x [ expr $x1 + 190 ] -y [ expr $y17 - 3 ] -height 24;
    
    set y15 [ expr $y17 + 30 ]
    frame $win(base).sp2 -height 2 -relief groove -borderwidth 2;
    place $win(base).sp2 -x 5 -y $y15 -width [ expr $win(width) - 10 ];
    
    set y16 [ expr $win(height) - 30 ];
    button $win(base).btnCreate -text "create" -width 8 -relief raised -borderwidth 1 -command { ::_GAP_CREATION::CreateGap };
    button $win(base).btnReject -text "reject" -width 8 -relief raised -borderwidth 1 -command { ::_GAP_CREATION::Reject };
    button $win(base).btnExport -text "export" -width 8 -relief raised -borderwidth 1 -command { ::_GAP_CREATION::Export };
    button $win(base).btnClose -text "close" -width 8 -relief raised -borderwidth 1 -command { ::_GAP_CREATION::Close }; 
    place $win(base).btnCreate -x $x1 -y $y16 -height 24;
    place $win(base).btnReject -x [ expr $x1 + 57 ] -y $y16 -height 24;
    place $win(base).btnExport -x [ expr $win(width) - 120 ] -y $y16 -height 24;
    place $win(base).btnClose -x [ expr $win(width) - 63 ] -y $y16 -height 24;
        
    ::_GAP_CREATION::Init;
     
    focus $win(base);
}

##############################################################
###                                                        ###
###   Close                                                ###
###   This procedure deletes window and terminates macro   ###
###                                                        ###
##############################################################
proc ::_GAP_CREATION::Close { args } {
    variable win;
    
    if { [ file exists "gapElem.txt" ] } {
        set answer [ tk_messageBox -message "Delete gap elements?" -type yesno -icon question -title "Confirmation" ];
        if { $answer == "yes" } {
            ::_GAP_CREATION::DeleteGap;
            if { [ llength $::_GAP_CREATION::createdComp ] != 0 } {
                eval *createmark comps 1 $::_GAP_CREATION::createdComp;
                *deletemark comps 1;
                *clearmark comps 1; 
            }    
        }
        file delete -force "gapElem.txt"; 
    }
    
    destroy $win(base);
    namespace delete [ namespace current ];
}

##############################################################
###                                                        ###
###   Change Default                                       ###
###                                                        ###
##############################################################
proc ::_GAP_CREATION::ChgDefault { args } {
	set ::_GAP_CREATION::nodestid [expr [hm_entitymaxid nodes] + 1];
}
#####################
###               ###
###   DeleteGap   ###
###               ###
#####################
proc ::_GAP_CREATION::DeleteGap { args } {
    variable win;
    
    set fp [ open "gapElem.txt" "r" ];
    *entityhighlighting 0;
    hm_blockmessages 1;
    while { ![ eof $fp ] } {
        gets $fp str;
        eval *createmark elems 1 $str;
        if { [ hm_marklength elems 1 ] != 0 } {
            *deletemark elems 1;
        }
    }
    *clearmark elems 1;
    *entityhighlighting 1;
    hm_blockmessages 0;
    close $fp;
}

######################################################################
###                                                                ###
###   SwitchMethod                                                 ###
###   This procedure provides needed method for entity selection   ###
###                                                                ###
######################################################################
proc ::_GAP_CREATION::SwitchMethod { args } {
    variable win;
    
    set x1 170;
    set y1 $::_GAP_CREATION::t_y2; 
    switch $::_GAP_CREATION::s_method {
        "All" {
            if { [ winfo exists $win(base).btnEntitySelect ] } {
                destroy $win(base).btnEntitySelect;
            }
        }
        "by Parts" {
            if { ![ winfo exists $win(base).btnEntitySelect ] } {
                button $win(base).btnEntitySelect -text "elems" -bg "#E6E664" -activebackground "#E6E664" -width 8 -borderwidth 1 -command { ::_GAP_CREATION::EntitySelect };
                place $win(base).btnEntitySelect -x $x1 -y $y1 -height 23;
            } else {
                $win(base).btnEntitySelect configure -text "elems";
            }
        }
        "by Nodes" {
            if { ![ winfo exists $win(base).btnEntitySelect ] } {
                button $win(base).btnEntitySelect -text "nodes" -bg "#E6E664" -activebackground "#E6E664" -width 8 -borderwidth 1  -command { ::_GAP_CREATION::EntitySelect };
                place $win(base).btnEntitySelect -x $x1 -y $y1 -height 23;
            } else {
                $win(base).btnEntitySelect configure -text "nodes";
            }
        }
    }
}

##########################
###                    ###
###   SelectGapGroup   ###
###                    ###
##########################
proc ::_GAP_CREATION::SelectGapGroup { args } {
    variable win;
    
    wm withdraw $win(base);
    *createmarkpanel comps 1 "select component for gap";
    if { [ hm_marklength comps 1 ] != 0 } {
        set ::_GAP_CREATION::gapCompName [ hm_entityinfo name comps [ hm_getmark comps 1 ] ];
    }
    *clearmark comps 1;
    wm deiconify $win(base);
    
}

###################################################
###                                             ###
###   SetGroupColor                             ###
###   Define component color for gap elements   ###
###                                             ###
###################################################
proc ::_GAP_CREATION::SetGroupColor { args } {
    variable win;
    
    set x [ lindex $args 0 ];
    set y [ lindex $args 1 ]; 
    set returnValue [ ColorDialog $win(base) -window_x $x -window_y $y ];
    set ::_GAP_CREATION::colorIndex [ expr [ lindex $returnValue 0 ] + 1 ];
    set colorValue [ lindex $returnValue 1 ];
    $win(base).btnGroupColor configure -bg "$colorValue" -activebackground "$colorValue";
}

########################################################
###                                                  ###
###   EntitySelect                                   ###
###   This procedure select nodes for gap creation   ###
###                                                  ###
########################################################
proc ::_GAP_CREATION::EntitySelect { args } {
    variable win;
    
    wm withdraw $win(base);
    
    switch $::_GAP_CREATION::s_method {
        "by Parts" {
            *createmarkpanel elems 1 "Select elements belonging to parts";
            *entityhighlighting 0;
            hm_blockmessages 1;
            hm_appendmark elems 1 "advanced" "by attached";
            *clearmark nodes 1;
            *findmark elems 1 1 1 nodes 0 1;
            *entityhighlighting 1;
            hm_blockmessages 0;
        }
        "by Nodes" {
            *createmarkpanel nodes 1 "Select nodes for gap creation";
        }
    }
    if { [ hm_marklength nodes 1 ] != 0 } {
        set ::_GAP_CREATION::selectedNodes [ hm_getmark nodes 1 ];
    }

    wm deiconify $win(base);
}

############################################
###                                      ###
###   SwitchDistanceMethod               ###
###   Enable or disable distance entry   ###
###                                      ###
############################################
proc ::_GAP_CREATION::SwitchDistanceMethod { args } {
    variable win;
    
    set x [ lindex [ place configure $win(base).entGapValue -x ] end ];
    set y [ lindex [ place configure $win(base).entGapValue -y ] end ];
    destroy $win(base).entGapValue;
    switch $::_GAP_CREATION::distanceMethod {
        "user value" {
            AddEntry $win(base).entGapValue -textvariable ::_GAP_CREATION::gapValue -validate real -width 10 -state normal;    
        }
        default {
            AddEntry $win(base).entGapValue -textvariable ::_GAP_CREATION::gapValue -validate real -width 10 -state disabled;
        }
    }
    place $win(base).entGapValue -x $x -y $y;    
}

##################
###            ###
###   Export   ###
###            ###
##################
proc ::_GAP_CREATION::Export { args } {
    variable win;
    
    if { ${::_GAP_CREATION::nodestid} <= 0 || ${::_GAP_CREATION::nodestid} == "" } {
        tk_messageBox -message "Spoint startID is wrong." -type ok -icon warning -title "Information";
        return;
    }
    
    if { ![ file exists "gapElem.txt" ] } {
        tk_messageBox -message "No gap was created." -type ok -icon warning -title "Information";
        return;
    }
    
    set savefile [ tk_getSaveFile ];
    if { [ file tail $savefile ] == "gapElem.txt" } {
        tk_messageBox -message "Please select other file." -type ok -icon info -title "Information";
        return;
    }
    
    set fp [ open "$savefile" "w" ];
    
    puts $fp "\$Linear Gap Input:";
    puts $fp "PARAM   CDITER  50";
    puts $fp "PARAM   CDPCH   YES";
    puts $fp "PARAM   CDPRT   NO";
    
    switch $::_GAP_CREATION::analysisCS {
        "ux" {
            set dof 1;
        }
        "uy" {
            set dof 2;
        }
        "uz" {
            set dof 3;
        }
    }
    
    if { $::_GAP_CREATION::distanceMethod == "user value" } {
        set openingGap $::_GAP_CREATION::gapValue;
        if { [ string length $openingGap ] > 8 } {
            set stList [ split "$openingGap" "." ];
            set intLength [ string length [ lindex $stList 0 ] ];
            set fltLength [ expr 7 - $intLength ];
            set openingGap [ format "%.${fltLength}f" $openingGap ];
        } else {
            while { [ string length "$openingGap" ] < 8 } {
                set openingGap "$openingGap ";
            } 
        }
    } 
    
    set outputID ${::_GAP_CREATION::nodestid};
    
    set gfp [ open "gapElem.txt" "r" ];
    set id1List "";
    set nodePair "";
    while { ![ eof $gfp ] } {
        gets $gfp str;
        if { [ llength $str ] != 0 } {
            foreach eid $str {
                if { [ hm_entityinfo exist elems $eid ] } {
                    set nodeList [ lsort -increasing -integer [ hm_nodelist $eid ] ];
                    if { $::_GAP_CREATION::openID == "low" } {
                        set n1 [ lindex $nodeList 0 ];
                        set n2 [ lindex $nodeList 1 ];
                    } else {
                        set n1 [ lindex $nodeList 1 ];
                        set n2 [ lindex $nodeList 0 ];
                    }
                    set n_pair [ list $n1 $n2 ];
                    if { [ lsearch $nodePair $n_pair ] == -1 } {
                        lappend nodePair [ list $n1 $n2 ];
                    } else {
                        continue;
                    }
                    
                    switch $::_GAP_CREATION::distanceMethod {
                        "euclidean distance" {
                            set x1 [ hm_getentityvalue nodes $n1 globalx 0 ];
                            set y1 [ hm_getentityvalue nodes $n1 globaly 0 ];
                            set z1 [ hm_getentityvalue nodes $n1 globalz 0 ];
                            set x2 [ hm_getentityvalue nodes $n2 globalx 0 ];
                            set y2 [ hm_getentityvalue nodes $n2 globaly 0 ];
                            set z2 [ hm_getentityvalue nodes $n2 globalz 0 ];
                            set openingGap [ format "%.6f" [ expr sqrt(pow(${x2} - ${x1}, 2) + pow(${y2} - ${y1}, 2) + pow(${z2} - ${z1}, 2)) ] ];
                        }
                        "Dx" {
                            set x1 [ hm_getentityvalue nodes $n1 globalx 0 ];
                            set x2 [ hm_getentityvalue nodes $n2 globalx 0 ];
                            set openingGap [ format "%.6f" [ expr abs(${x2} - ${x1}) ] ];    
                        }
                        "Dy" {
                            set y1 [ hm_getentityvalue nodes $n1 globaly 0 ];
                            set y2 [ hm_getentityvalue nodes $n2 globaly 0 ];
                            set openingGap [ format "%.6f" [ expr abs(${y2} - ${y1}) ] ];    
                        }
                        "Dz" {
                            set z1 [ hm_getentityvalue nodes $n1 globalz 0 ];
                            set z2 [ hm_getentityvalue nodes $n2 globalz 0 ];
                            set openingGap [ format "%.6f" [ expr abs(${z2} - ${z1}) ] ];
                        }
                    }
                    if { $::_GAP_CREATION::distanceMethod != "user value" } {
                        if { [ string length $openingGap ] > 8 } {
                            set stList [ split "$openingGap" "." ];
                            set intLength [ string length [ lindex $stList 0 ] ];
                            set fltLength [ expr 7 - $intLength ];
                            set openingGap [ format "%.${fltLength}f" $openingGap ];
                        } else {
                            while { [ string length "$openingGap" ] < 8 } {
                                set openingGap "$openingGap ";
                            }
                        }
                    }
                    set id1 $outputID;
                    set id2 [ expr $outputID + 1 ];
                    while { [ string length "$id1" ] < 8 } {
                        set id1 "$id1 ";
                    }
                    lappend id1List $id1;
                    while { [ string length "$id2" ] < 8 } {
                        set id2 "$id2 ";
                    }
                    puts $fp "\$gap between grid $n1 dof $dof and grid $n2 dof $dof init opening = $openingGap";
                    puts $fp "SPOINT  ${id1}${id2}";
                    puts $fp "SUPORT  ${id1}";
                    puts $fp "SPC     101106  ${id2}0       $openingGap";
                    
                    while { [ string length "$n1" ] < 8 } {
                        set n1 "$n1 ";
                    }
                    while { [ string length "$n2" ] < 8 } {
                        set n2 "$n2 ";
                    }
                    puts $fp "MPC     101106  ${n1}${dof}       1.      ${n2}${dof}       -1.";
                    puts $fp "                ${id1}0       1.      ${id2}0       -1."; 
                    incr outputID 2; 
                }
            }
        }
    }
    close $gfp;
    
    if { $::_GAP_CREATION::initialState == "open" } { 
        puts $fp "DMIG    CDSHUT  0       9       1       0                       1";
        puts -nonewline $fp "DMIG    CDSHUT  1       0       ";
        set index 0;
        foreach id1 $id1List {
            puts -nonewline $fp "        ${id1}0       0.      ";
            if { [ expr $index % 2 ] == 0 } {
                puts $fp "";
            }
            incr index;
        } 
    }  
    
    close $fp;
    
    focus $win(base);
}

##################
###            ###
###   Reject   ###
###            ###
##################
proc ::_GAP_CREATION::Reject { args } {
    variable win;
    
    *entityhighlighting 0;
    hm_blockmessages 1;
    
    if { [ llength $::_GAP_CREATION::newGap ] != 0 } {
        eval *createmark elems 1 $::_GAP_CREATION::newGap;
        catch { *deletemark elems 1 };
        *clearmark elems 1;
    }
    
    *entityhighlighting 1;
    hm_blockmessages 0;
}

######################################
###                                ###
###   split nodes group by parts   ###
###                                ###
######################################
proc ::_GAP_CREATION::SplitNodesByParts { args } {
    variable win;
    
    if { [ info exists ::_GAP_CREATION::nodeGroup ] } {
        unset ::_GAP_CREATION::nodeGroup;
    }
    set ::_GAP_CREATION::nNodeGroup 0; 
    while { [ llength $::_GAP_CREATION::selectedNodes ] != 0 } {
        incr ::_GAP_CREATION::nNodeGroup; 
        set delegate [ lindex $::_GAP_CREATION::selectedNodes 0 ];
        *createmark nodes 1 $delegate;
        *clearmark elems 1;
        *findmark nodes 1 1 1 elems 0 1;
        hm_appendmark elems 1 "advanced" "by attached";
        *clearmark nodes 1;
        *findmark elems 1 1 1 nodes 0 1;
        eval *createmark nodes 2 $::_GAP_CREATION::selectedNodes;
        *markintersection nodes 1 nodes 2;
        set ::_GAP_CREATION::nodeGroup(${::_GAP_CREATION::nNodeGroup}) [ hm_getmark nodes 1 ]; 
        *markdifference nodes 2 nodes 1;
        set ::_GAP_CREATION::selectedNodes [ hm_getmark nodes 2 ];  
    }
    
}

#####################
###               ###
###   CreateGap   ###
###               ###
#####################
proc ::_GAP_CREATION::CreateGap { args } {
    variable win;
    
    # parameter check                         
    set mess "";
    if { "$::_GAP_CREATION::gapCompName" == "" } {
        set mess "Gap group name is invalid.";
    }
    if { "$::_GAP_CREATION::nodeGapTol" == "" || $::_GAP_CREATION::nodeGapTol < 0.0 } {
        set mess "Gap tolerance is invalid.";    
    }
    if { "$::_GAP_CREATION::s_method" == "by Parts" || "$::_GAP_CREATION::s_method" == "by Nodes" } { 
        if { [ llength $::_GAP_CREATION::selectedNodes ] == 0 } {
            set mess "Parts or nodes are not selected.";
        }
    }
    if { "$mess" != "" } {
        tk_messageBox -message "$mess" -type ok -icon warning -title "ERROR";
        return;
    }
    
    *entityhighlighting 0;
    hm_blockmessages 1;
    
    set currentcomp [ hm_info currentcomponent ];
    set newGapStart [ expr [ hm_entitymaxid elems ] + 1 ];
    
    if { [ hm_entityinfo exist comps "$::_GAP_CREATION::gapCompName" ] } {
        *currentcollector compos "$::_GAP_CREATION::gapCompName";
    } else {
        *collectorcreateonly comps "$::_GAP_CREATION::gapCompName" "" $::_GAP_CREATION::colorIndex;
        lappend ::_GAP_CREATION::createdComp "$::_GAP_CREATION::gapCompName"; 
    } 
    
    if { "$::_GAP_CREATION::s_method" == "All" } {
        *createmark nodes 1 "all";
        set ::_GAP_CREATION::selectedNodes [ hm_getmark nodes 1 ];
    }
    
    ::_GAP_CREATION::SplitNodesByParts;    
    
    *elementtype 70 1;
    for { set i 1 } { $i <= $::_GAP_CREATION::nNodeGroup } { incr i } {
        set candidate "";
        for { set j 1 } { $j <= $::_GAP_CREATION::nNodeGroup } { incr j } {
            if { $i == $j } {
                eval *createmark nodes 1 $::_GAP_CREATION::nodeGroup(${j});
            } else {
                eval lappend candidate $::_GAP_CREATION::nodeGroup(${j});
            } 
        }
        eval *createmark nodes 2 $candidate;
        *clearmark elems 1;
        *findmark nodes 2 1 1 elems 0 1;  
        foreach nid $::_GAP_CREATION::nodeGroup(${i}) {
            set nodeValue [ lindex [ hm_nodevalue $nid ] 0 ];
            set x [ lindex $nodeValue 0 ];
            set y [ lindex $nodeValue 1 ];
            set z [ lindex $nodeValue 2 ];
            set c_nid [ hm_getclosestnode $x $y $z 1 1 ];
            set c_nodeValue [ lindex [ hm_nodevalue $c_nid ] 0 ];
            set cx [ lindex $c_nodeValue 0 ];
            set cy [ lindex $c_nodeValue 1 ];
            set cz [ lindex $c_nodeValue 2 ];
            set dis [ expr sqrt(pow(${cx} - ${x}, 2) + pow(${cy} - ${y}, 2) + pow(${cz} - ${z}, 2)) ];
            if { $dis <= $::_GAP_CREATION::nodeGapTol } {
                *gapelement $nid $c_nid "" 0;
            }
        }
    }
    
    hm_completemenuoperation;
    set newGapEnd [ hm_entitymaxid elems ];
    *createmark elems 1 ${newGapStart}-${newGapEnd};
    set ::_GAP_CREATION::newGap [ hm_getmark elems 1 ];
    
    # store new gap element id to text file
    set fp [ open "gapElem.txt" "a" ];
    puts $fp "$::_GAP_CREATION::newGap";
    close $fp;  
    
    *clearmark nodes 1;
    *clearmark nodes 2;
    *clearmark elems 1;
    *clearmark elems 2;
    
    if { "$currentcomp" != "" } {
        *currentcollector compos "$currentcomp";
    }
    
    *entityhighlighting 1;
    hm_blockmessages 0;
} 

_GAP_CREATION::MainPanel
