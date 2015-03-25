# HWVERSION_9.0_February 13 2009
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
catch {namespace delete ::BAR_ELEM_COORD_DISPLAY};
#------------------------------------------------------------------------------#
# Global Variables                                                             #
#------------------------------------------------------------------------------#
namespace eval ::BAR_ELEM_COORD_DISPLAY {
    
    variable orient_Coll
    variable EntityList "";
    variable color       "";
    variable vect_size   "";
    variable system_size "";
    variable DrawCoord    0;
    variable ShouldDraw   0;
    variable eList_xdirnP "";
    variable eList_xdirnN "";
    variable vectorSizeType;
    variable vectorSizeEntry;
    variable coordView_add_elems "";
    variable vectorsListInPostvDirn "";
    variable vectorsListInNegtvDirn "";
    variable ref_Adjust_Element  "";
    variable updatedEntityList   "";
    variable type       coordinates;
    variable axisType    singleAxis;
    variable axisTypeList {"singleAxis" "threeAxes"}
    variable elems_hidden   "false"
    variable ref_elem_selected "false";
    variable vectorSizeTypes {"Uniform" "Magnitude %"}

    #panel title name
    set title "1d elements coordinate control";
    
    variable PElemsReverse $eList_xdirnP;
    variable NElemsReverse $eList_xdirnN;


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
# ::BAR_ELEM_COORD_DISPLAY::MainWindow                                         #
# purpose: to create main dialog                                               #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::MainWindow { args } {
    variable type;
    variable title;
    variable axisType;
    variable panelFrame;
    variable orient_Coll;
    variable axisTypeList;
    variable vectorSizeType;
    variable vectorSizeEntry;
    variable vectorSizeTypes;


    #Remove vector callbacks
    catch {::BAR_ELEM_COORD_DISPLAY::UnsetVectorsCallbacks}
    ::BAR_ELEM_COORD_DISPLAY::SetVectorsCallbacks

    #Initialize the settings to the HM database
    ::BAR_ELEM_COORD_DISPLAY::InitializeVectors

    #specify no message
    hm_errormessage "";
    
    #show all elements
    Show_all_elems

    #destroy panel if it exist
    catch {destroy .g_barcoordisplay_TPanel}

    #add hm panel
    set panelFrame [frame .g_barcoordisplay_TPanel -padx 7 -pady 7];
    hm_framework addpanel $panelFrame $title;

    #Create Frames in new panel
    set f1  [frame $panelFrame.f1];
    set f2  [frame $panelFrame.f2];
    set f3  [frame $panelFrame.f3];
    set sp  [frame $panelFrame.sp -bd 2 -relief groove -width 2];
    set f4  [frame $panelFrame.f4];
    set f5  [frame $panelFrame.f5];

    grid rowconfigure  $panelFrame 0 -weight 1;
    grid rowconfigure  $f1    5 -weight 1;
    grid rowconfigure  $f2    0 -weight 1;
    grid rowconfigure  $f3    1 -weight 1;
    grid rowconfigure  $f4    5 -weight 1;
    grid rowconfigure  $f5    7 -weight 1;
    grid columnconfigure $panelFrame 5 -weight 1;

    grid $f1  -row 0 -column 0 -sticky news;
    grid $f2  -row 0 -column 1 -sticky news -padx 7;
    grid $f3  -row 0 -column 2 -sticky news;
    grid $sp  -row 0 -column 3 -sticky ns   -padx 7;
    grid $f4  -row 0 -column 4 -sticky nws;
    grid $f5  -row 0 -column 6 -sticky nws;

    # frame 1
    label $f1.lab -text "1d Elements:";
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

    #hm_collector widget
    Collector $f2.f2.coll entity 1 HmMarkCol \
        -types  "Elements" \
        -withtype     0 \
        -withReset     1 \
        -callback ::BAR_ELEM_COORD_DISPLAY::MultiEntityCollectorHandler;

    grid $f2.f2.coll -sticky news -pady 4;
    $f2.f2.coll invoke Elements;

    frame $f2.f2.n;
    grid rowconfigure $f2.f2.n 2 -weight 1;
    set ::BAR_ELEM_COORD_DISPLAY::c2 $f2.f2.n.c2;

    frame $f2.f2.f;
    grid rowconfigure $f2.f2.f 2 -weight 1;
    grid $f2.f2.f -sticky nw -pady 4;

    label $f2.f2.f.lab -text "Orientation:";
    grid $f2.f2.f.lab -sticky nw -pady 4;

    set orient_Coll [Collector $f2.f2.f.c3 entity 1 HmMarkCol \
        -types  "Element" \
        -withtype     0 \
        -withReset     1 \
        -callback ::BAR_ELEM_COORD_DISPLAY::SingleEntityCollectorHandler];

    grid $f2.f2.f.c3 -sticky news;
    # frame 3
    frame $f3.t;
    grid $f3.t -sticky nw -padx 7;

    label $f3.t.lab -text "Display Axis:";
    grid $f3.t.lab -row 0 -column 0 -sticky news;

    set str {"1-Axis" "3-Axes"}
    set index 0;
    foreach rb $axisTypeList {
        radiobutton $f3.t.rb$rb \
            -text [lindex $str $index] \
            -value $rb\
            -takefocus 1 \
            -command "::BAR_ELEM_COORD_DISPLAY::OnSetaxisType" \
            -variable ::BAR_ELEM_COORD_DISPLAY::axisType;
        grid $f3.t.rb$rb -row [expr $index+1] -column 0 -sticky nw -padx 7 -pady 4;

        incr index;
    }

    grid configure $f3.t.rbsingleAxis -pady 4;

    # frame 4
    label $f4.lab -text "Display options:";
    grid $f4.lab -row 0 -column 0 -sticky nw;

    label $f4.lab2 -text "Color:";
    grid $f4.lab2 -row 1 -column 0 -sticky nw -padx 7 -pady 4;

    hwt::CanvasButton $f4.c 11 11 \
        -background #ff0000 \
        -command "::BAR_ELEM_COORD_DISPLAY::SetColor $f4.c";
    grid $f4.c -row 1 -column 0 -sticky nw -padx 89 -pady 4;

    frame $f4.b;
    grid $f4.b -row 2 -column 0 -sticky nw;
    #Vector size
    label $f4.b.lab3 -text "Vector size:"\
         -width 12 \
         -justify left \
         -anchor nw \
         -font [hwt::AppFont];
    grid $f4.b.lab3  -row 2 -column 0 -sticky w -padx 7;

    #vector_size_type
    set vectorSizeEntry [ hwt::AddEntry $f4.b.vect_size  \
        -text "$vectorSizeType" \
        -entryWidth 15 \
        -listProc whenPressed ::BAR_ELEM_COORD_DISPLAY::Toggle_Vect_Size \
        -iconName small_updownarrow \
        withoutPacking \
        asButton];

    grid $f4.b.vect_size -row 2 -column 1 -sticky nws -ipady 2 -ipadx 1;

    #vector size entry box
    hwt::AddEntry $f4.b.vect_ent \
         entrywidth  15 \
         withoutPacking \
         -validate real \
         -justify right \
         -textvariable ::BAR_ELEM_COORD_DISPLAY::vect_size \
         -afterFunc ::BAR_ELEM_COORD_DISPLAY::UpdateVectorsSize \
         State "normal";

    grid $f4.b.vect_ent -row 2 -column 2 -sticky nw -ipady 2 -ipadx 1;

    frame $f4.s;
    #System size
    label $f4.s.lab3 -text "System size:" \
         -width 12 \
         -justify left \
         -anchor nw \
         -font [hwt::AppFont];

    grid $f4.s.lab3  -row 2 -column 0 -sticky w -padx 7;

    #system size entry box
    hwt::AddEntry $f4.s.system_ent \
         entrywidth  15 \
         withoutPacking \
         -validate real \
         -justify right \
         -textvariable ::BAR_ELEM_COORD_DISPLAY::system_size \
         -afterFunc ::BAR_ELEM_COORD_DISPLAY::OnUpdateSystemSize \
         State "normal";

    grid $f4.s.system_ent -row 2 -column 1 -sticky nw -ipady 2 -ipadx 1;

    #frame 5
    frame $f5.f2;
    grid rowconfigure $f5.f2 2 -weight 1;
    grid $f5.f2 -sticky nw;
    
    set bWidth  [hwt::DluWidth 92];
    set bHeight [hwt::DluHeight 14];

    set bkgClr "#4ec852";
    #frame $f5.f2
    hwt::CanvasButton $f5.f2.disp \
            $bWidth  \
            $bHeight \
            -background $bkgClr \
            -text "Display" \
            -command "::BAR_ELEM_COORD_DISPLAY::OnDisplayCoordinateSystem" \
            -relief raised;
    grid $f5.f2.disp -sticky nw;

    #adjust button
    hwt::CanvasButton $f5.f2.lab1 \
            $bWidth  \
            $bHeight \
            -background $bkgClr \
            -text "Adjust" \
            -command "::BAR_ELEM_COORD_DISPLAY::OnAdjust" \
            -relief raised;
    grid $f5.f2.lab1 -sticky nw;

    #reverse button
    hwt::CanvasButton $f5.f2.ent1 \
        $bWidth \
        $bHeight \
        -background $bkgClr \
        -text "Reverse" \
        -command "::BAR_ELEM_COORD_DISPLAY::OnReverse" \
        -relief raised;

    grid $f5.f2.ent1 -sticky news;

    #Reject button
    hwt::CanvasButton $f5.f2.reject $bWidth $bHeight \
        -background $bkgClr \
        -text "Reject" \
        -command ::BAR_ELEM_COORD_DISPLAY::OnReject \
        -relief raised \
        -font [hwt::AppFont];

    grid $f5.f2.reject -sticky news;

    #return button
    hwt::CanvasButton $f5.f2.f \
        $bWidth \
        $bHeight \
        -background #c96341 \
        -text "return" \
        -command "::BAR_ELEM_COORD_DISPLAY::OnQuit" \
        -relief raised;
    grid $f5.f2.f -sticky nw;

    #toggle vector
    ::BAR_ELEM_COORD_DISPLAY::Toggle_Vect_Size 1
    
    #draw hm panel
    hm_framework drawpanel $panelFrame;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::Exists                                             #
# This function checks whether edit element created panel exists or not.       #
# Return    : 0 : not exists , 1 : exists                                      #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::Exists {args} {

    if { [ winfo exists .g_barcoordisplay_TPanel ] } { return 1 }

    return 0;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::MultiEntityCollectorHandler                        #
# Handler for the Collector                                                    #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::MultiEntityCollectorHandler { args } {
    variable eList_xdirnP "";
    variable eList_xdirnN "";
    variable SelectedElemsList   "";
    variable coordView_add_elems "";
    variable vectorsListInPostvDirn  "";
    variable vectorsListInNegtvDirn  "";
    

    #clear elements
    ::BAR_ELEM_COORD_DISPLAY::clear_elems

    #Check for current template
    if {[hm_info templatecodename] != "nastran"}  {
        #Load nastran template
        ::BAR_ELEM_COORD_DISPLAY::LoadNastranTemplate;
    }

    switch [ lindex $args 0 ] {
        "getadvselmethods"
        {
            foreach {entity} $args break
            #clear temp nodes
            ::BAR_ELEM_COORD_DISPLAY::ClearTempNodes

            *createmarkpanel elements 1 "Select 1d elements to control coordinate"
            set n_elemlist [hm_getmark elements 1];

            if {$n_elemlist != 0} {

                set n_noofelems [llength $n_elemlist];

                if {$n_noofelems > 0} {

                    foreach eid $n_elemlist {
                        set configId [hm_getentityvalue elems $eid "config" 0 -byid];
                        if { $configId == 60 || $configId == 61 || $configId == 21 \
                             || $configId == 70 || $configId == 2 || $configId == 3} {
                            
                            #collect element list
                            lappend SelectedElemsList $eid;
                        }
                    }

                    #seperate vector in their respective dirn
                    set edirnLst [::BAR_ELEM_COORD_DISPLAY::SeperateCoordBasedOnDirn $SelectedElemsList]
                    set vectorsListInPostvDirn  [lindex $edirnLst 0];
                    set vectorsListInNegtvDirn  [lindex $edirnLst 1];
                    set eList_xdirnP [::BAR_ELEM_COORD_DISPLAY::CreateElementList $vectorsListInPostvDirn];
                    set eList_xdirnN [::BAR_ELEM_COORD_DISPLAY::CreateElementList $vectorsListInNegtvDirn];
                }
            }

            set coordView_add_elems [concat $eList_xdirnP $eList_xdirnN];
            hm_markclear elements 1;

            ::BAR_ELEM_COORD_DISPLAY::OnDisplayCoordinateSystem
            #::BAR_ELEM_COORD_DISPLAY::ClearTempNodes

            return
        }
        "reset"
        {
            #clear elem selection
            set eList_xdirnP "";
            set eList_xdirnN "";
            set coordView_add_elems "";
            *clearmark elements 1

            #clear temp nodes
            ::BAR_ELEM_COORD_DISPLAY::ClearTempNodes
        }
        default
        {
            # This should not do anything
            return
        }
    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SingleEntityCollectorHandler                       #
# Handler for the Collector                                                    #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SingleEntityCollectorHandler { args } {
    variable ref_Adjust_Element;
    variable ref_elem_selected;
    variable vectorsListInPostvDirn;
    variable vectorsListInNegtvDirn;

    #clear elements
    ::BAR_ELEM_COORD_DISPLAY::clear_elems

    #Check for current template
    if {[hm_info templatecodename] != "nastran"}  {
        #Load nastran template
        ::BAR_ELEM_COORD_DISPLAY::LoadNastranTemplate;
    }

    switch [ lindex $args 0 ] {
        "getadvselmethods"
        {
            foreach {entity} $args break
            set lst_elem "";
            hm_markclear elems 1
            *createentitypanel elems "select reference element for coordinate control"
            set lst_elem [hm_info lastselectedentity elems]

            if {$lst_elem != 0} {
                set n_noofelems [llength $lst_elem];
                if {$n_noofelems > 0} {
                    foreach eid $lst_elem {
                        set configId [hm_getentityvalue elems $eid "config" 0 -byid];
                        if { $configId == 60 || $configId == 61 || $configId == 21 || $configId == 70 || $configId == 2 || $configId == 3} {

                            if {$configId == 60 } {
                                
                                #components of local y axis of bar
                                set X_YAxisVect [hm_getentityvalue elems $eid "localyx" 0 -byid];
                                set Y_YAxisVect [hm_getentityvalue elems $eid "localyy" 0 -byid];
                                set Z_YAxisVect [hm_getentityvalue elems $eid "localyz" 0 -byid];
                            }
                            
                            #beam's node1 and node2
                            set barNode1   [hm_getentityvalue elems $eid "node1.id" 0 -byid];
                            set barNode2   [hm_getentityvalue elems $eid "node2.id" 0 -byid];

                            #Element centriod
                            set Ecentr  [hm_entityinfo centroid elems $eid];
                            
                            #coord component of vector/system origin node
                            set cntrX [lindex $Ecentr 0];
                            set cntrY [lindex $Ecentr 1];
                            set cntrZ [lindex $Ecentr 2];
                            
                            #create temp origin node for system or vector
                            set Midnode [::BAR_ELEM_COORD_DISPLAY::CreateNodeInHyperMesh $Ecentr];

                            #xy plane reference node coordinate
                            if { $configId == 60} {
                                
                                if { $Y_YAxisVect == 0 && $Z_YAxisVect == 0} {
                                    if { $X_YAxisVect > 0 } {
                                        set xyPlaneNode  [list [expr $cntrX + $X_YAxisVect] [expr $cntrY + $Y_YAxisVect] [expr $cntrZ + 1] ];
                                    } else {
                                        set xyPlaneNode  [list [expr $cntrX + $X_YAxisVect] [expr $cntrY + $Y_YAxisVect] [expr $cntrZ - 1] ];
                                    }
                                } else {
                                    set xyPlaneNode  [list [expr $cntrX + $X_YAxisVect] [expr $cntrY + $Y_YAxisVect] [expr $cntrZ + $Z_YAxisVect] ];
                                }

                                set xyPlaneNodeRef [::BAR_ELEM_COORD_DISPLAY::CreateNodeInHyperMesh $xyPlaneNode];

                            } elseif {$configId == 61 || $configId == 21 || $configId == 70 || $configId == 2 || $configId == 3} {

                                set xyPlaneNodeRef "N/A";
                            }

                            #make sure reference element is selected for
                            # the list of elements displayed with vectors/systems
                            set idx "";
                            set ref_Adjust_Element "";
                            if {[llength $vectorsListInPostvDirn] != 0} {
                                set idx [lsearch -exact $vectorsListInPostvDirn $eid];
                                if {$idx != -1 } {
                                    set ref_Adjust_Element "P $eid $Midnode $barNode2 $xyPlaneNodeRef";
                                }
                            }
                            
                            if {[llength $vectorsListInNegtvDirn] != 0} {
                                set idx [lsearch -exact $vectorsListInNegtvDirn $eid];
                                if {$idx != -1 } {
                                    set ref_Adjust_Element "N $eid $Midnode $barNode2 $xyPlaneNodeRef";
                                }
                            }

                            #make sure reference elem is selected
                            if {$ref_Adjust_Element != "" } {
                                set ref_elem_selected "true";
                            } else {
                                hm_errormessage "select orientation element from the elems displayed with coordinate."
                                hm_highlightentity elems 0 n;
                                return;
                            }
                        }
                    }
                }
            }

            #hm_highlightentity elems 0 n
            return
        }
        "reset"
        {
            set ref_Adjust_Element "";
            set ref_elem_selected false;
            hm_highlightentity elems 0 n
        }
        default
        {
            # This should not do anything
            return
        }
    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::CreateElementList                                  #
# purpose: to separete elements based on dirn and create list                  #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::CreateElementList {n_elemlist args } {

    
    set eList_xdirn "";

    foreach eid $n_elemlist {
        
        set configId [hm_getentityvalue elems $eid "config" 0 -byid];
        
        if { $configId == 60 || $configId == 61 || $configId == 21 || $configId == 70 || $configId == 2 || $configId == 3} {
            
            if {$configId == 60 } {
                #components of local y axis of bar
                set X_YAxisVect [hm_getentityvalue elems $eid "localyx" 0 -byid];
                set Y_YAxisVect [hm_getentityvalue elems $eid "localyy" 0 -byid];
                set Z_YAxisVect [hm_getentityvalue elems $eid "localyz" 0 -byid];
            }

            #element node1 and node2
            set barNode1  [hm_getentityvalue elems $eid "node1.id" 0 -byid];
            set barNode2  [hm_getentityvalue elems $eid "node2.id" 0 -byid];

            #Element centroid
            set Ecentr  [hm_entityinfo centroid elems $eid];
            
            #coord component of vector/system origin node
            set cntrX [lindex $Ecentr 0];
            set cntrY [lindex $Ecentr 1];
            set cntrZ [lindex $Ecentr 2];
            
            #create temp origin node for system or vector
            set Midnode [::BAR_ELEM_COORD_DISPLAY::CreateNodeInHyperMesh $Ecentr];
            
            #create temp node for system xy plane reference
            if { $configId == 60} {
                if { $Y_YAxisVect == 0 && $Z_YAxisVect == 0} {
                    if { $X_YAxisVect > 0 } {
                        set xyPlaneNode  [list [expr $cntrX + $X_YAxisVect] [expr $cntrY + $Y_YAxisVect] [expr $cntrZ + 1] ];
                    } else {
                        set xyPlaneNode  [list [expr $cntrX + $X_YAxisVect] [expr $cntrY + $Y_YAxisVect] [expr $cntrZ - 1] ];
                    }
                } else {
                    set xyPlaneNode [list [expr $cntrX + $X_YAxisVect] [expr $cntrY + $Y_YAxisVect] [expr $cntrZ + $Z_YAxisVect] ];
                }
                set xyPlaneNodeRef [::BAR_ELEM_COORD_DISPLAY::CreateNodeInHyperMesh $xyPlaneNode];
            } elseif {$configId == 61 || $configId == 21 || $configId == 70 || $configId == 2 || $configId == 3} {
                set xyPlaneNodeRef "N/A";
            }

            lappend eList_xdirn "$eid $Midnode $barNode2 $xyPlaneNodeRef";
        }
    }

    return $eList_xdirn;

}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SeperateCoordBasedOnDirn                           #
# purpose: to separete elements based on                                       #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SeperateCoordBasedOnDirn {eList args } {

    
    #return if no list of elems are given
    if {[llength $eList] == 0 } {return }

    set postv "";
    set negtv "";

    #pair nodes for beam element
    for {set k 0 } {$k <=  [expr [llength $eList] - 1 ]} {incr k } {
        set eCurn [lindex $eList $k];
        set eNext [lindex $eList [expr $k + 1 ] ];
        if {$eNext == "" } {break };

        set eCurnNode1  [hm_getentityvalue elems $eCurn "node1.id" 0 -byid];
        set eCurnNode2  [hm_getentityvalue elems $eCurn "node2.id" 0 -byid];
        set eNextNode1  [hm_getentityvalue elems $eNext "node1.id" 0 -byid];
        set eNextNode2  [hm_getentityvalue elems $eNext "node2.id" 0 -byid];

        if {$eCurnNode2 == $eNextNode1 } {
            lappend postv $eCurn;
            lappend postv $eNext;
        } elseif { $eCurnNode2 == $eNextNode2 } {
            lappend postv $eCurn;
            lappend negtv $eNext;
        } elseif {$eCurnNode1 == $eNextNode1 } {
            lappend negtv $eCurn;
            lappend postv $eNext;
        } elseif {$eCurnNode1 == $eNextNode2 } {
            lappend negtv $eCurn;
            lappend negtv $eNext;
        }

    }

    #make uniques
    set postv [lsort -unique $postv];
    set negtv [lsort -unique $negtv];
    
    #append postv & negtv into list group
    set lstgrp "";
    lappend  lstgrp $postv;
    lappend  lstgrp $negtv;


    return $lstgrp;

}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::OnSetaxisType                                      #
# purpose: to set type                                                         #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::OnSetaxisType { args } {

    variable axisType;


    set f .g_barcoordisplay_TPanel.f2;

    if { $axisType == "threeAxes" } {

        grid remove .g_barcoordisplay_TPanel.f4.b;
        grid .g_barcoordisplay_TPanel.f4.s -row 2 -column 0 -sticky nw;

        #Remove vector callbacks and initialize system callbacks
        catch {::BAR_ELEM_COORD_DISPLAY::UnsetVectorsCallbacks}
        catch {::BAR_ELEM_COORD_DISPLAY::UnsetSystemsCallbacks}
        ::BAR_ELEM_COORD_DISPLAY::SetSystemsCallbacks

        #Initialize the settings to the HM database
        ::BAR_ELEM_COORD_DISPLAY::SystemsInitialize

        catch {*displaycollector systcols on "Syst2" 1 1}

    } else {

        grid remove .g_barcoordisplay_TPanel.f4.s;
        grid .g_barcoordisplay_TPanel.f4.b -row 2 -column 0 -sticky nw;

        #Remove system callbacks and initialize vector callbacks
        catch {::BAR_ELEM_COORD_DISPLAY::UnsetSystemsCallbacks}
        catch {::BAR_ELEM_COORD_DISPLAY::UnsetVectorsCallbacks}
        ::BAR_ELEM_COORD_DISPLAY::SetVectorsCallbacks

        #Initialize the settings to the HM database
        ::BAR_ELEM_COORD_DISPLAY::InitializeVectors;

       catch {*displaycollector vectorcols on "Vect2" 1 1}
    }

    #unhide active coordinates
    ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState $axisType "unhide";

    ::BAR_ELEM_COORD_DISPLAY::ApplyHide $axisType;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::ApplyHide                                          #
# purpose: to set type                                                         #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::ApplyHide { type args } {

    variable axisTypeList
    set idx [lsearch -exact $axisTypeList $type];
    if {$idx == "1"} {
        set axsType "singleAxis";
    } else {
        set axsType "threeAxes";
    }

    #Hide not active coordinates
    ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState "$axsType" "hide";
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::OnQuit                                             #
# stop operation and exit hm panel                                             #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::OnQuit { args} {
    variable panelFrame;
    variable ref_Adjust_Element;
    variable ref_elem_selected;

    hm_blockmessages 0;

    #reset highlight
    reset_highlight

    #Remove coordinate callback settings
    ::BAR_ELEM_COORD_DISPLAY::UnsetCallbacks;

    #Remove coordinates system
    foreach coordType {singleAxis threeAxes } {
        ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState "$coordType" "delete";
    }

    #clear temp nodes
    ::BAR_ELEM_COORD_DISPLAY::ClearTempNodes
    hm_highlightentity elems 0 n
    set ref_Adjust_Element "";
    set ref_elem_selected false;

    #Exit panel
    hm_exitpanel
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::clear_elems                                        #
# purpose: to clear element selection                                          #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::clear_elems {args} {

    catch {hm_markclear elems 1 };
    reset_highlight

}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::GetNastranTemplatePath                             #
# Gets the nastran template path                                               #
# Return template path                                                         #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::GetNastranTemplatePath {args} {

    set nasTemplatePath [hm_info -appinfo SPECIFIEDPATH TEMPLATES_DIR];
    set nasTemplatePath [file join $nasTemplatePath feoutput nastran general];

    return $nasTemplatePath;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::LoadNastranTemplate                                #
# load nastran template                                                        #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::LoadNastranTemplate {args} {

    set nasTemplatePath [GetNastranTemplatePath];

    #load template
    *templatefileset $nasTemplatePath;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::reset_highlight                                    #
# purpose: to reset element highlighting                                       #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::reset_highlight {args} {

   #Reset highlighting
   hm_highlightmark elems 1 n
   hm_markclear elems 1 0
   hm_markclear elems 1 1
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::Show_all_elems                                     #
# purpose: to mask displayed elements                                          #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::Show_all_elems {args} {

    variable elems_hidden;

    if { $elems_hidden == false } {
        *createmark elems 1 advanced all
        if { [ llength [ hm_getmark elems 1 ] ] != 0 } {
            *unmaskmark elems 1
            *clearmark elems 1
            *plot
            set elems_hidden true;
        }
    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SetColor                                           #
# purpose: to apply coordinate or system color                                 #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SetColor { win } {
    variable color;
    variable axisType;

    #color value
    set color [::post::colordialog::BuildDialog $win];
    if { $color == 1 } {
        return;
    } else {
        set frm ".g_barcoordisplay_TPanel.f4.c";
        $frm configure -background [lindex $color 1];
    }

    #apply vector/syst coordinate color
    ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinateColor $axisType [expr [lindex $color 0] + 1];

    variable axisTypeList
    set idx [lsearch -exact $axisTypeList $axisType];
    if {$idx == "1"} {
        set axsType "singleAxis";
    } else {
        set axsType "threeAxes";
    }
    
    #update color of hiden coordinate
    if {[::BAR_ELEM_COORD_DISPLAY::CheckForCoordinates $axsType] == "true" } {
        ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinateColor $axsType [expr [lindex $color 0] + 1];

        #Hide coordinates
        ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState "$axsType" "hide";
    }
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinateColor                             #
# Purpose: to update vector/system coordinate color                           #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinateColor { coordType value args } {

    set entityTyp "";
    if {$coordType == "threeAxes" } {
        set entityTyp "systcols";
    } else {
        set entityTyp "vectorcols";
    }

    #update coordinate color
    *clearmark $entityTyp 1
    *retainmarkselections 1
    hm_createmark $entityTyp 1 advanced all
    if {[llength [hm_getmark $entityTyp 1] ] > 0} {
        *colormark $entityTyp 1 $value
    }
    *retainmarkselections 0
    *plot
    *clearmark $entityTyp 1
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SplitHMCommand                                    #
# HM * commands are passed into callbacks as strings.  For some reason,       #
# sometimes they seem to end up broken into strange lists and have to be      #
# merged into single strings. Splits a *command string received from a        #
# callback function into its parts                                            #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SplitHMCommand { args } {

   #Make sure the command is a single string.
   set command [ eval MergeHMCommand $args ];

   #Get command name.
   set openParen [ string first "(" $command ] ; ## )
   set commandName [ string range $command 0 [ expr { $openParen - 1 } ] ];

   lappend result $commandName;

   #Parse the args inside parenthesis.
   set index [ expr { $openParen + 1 } ];
   set startArg $index;
   set char [ string index $command $index ];

   while { 1 } {
      # Bug fix:
      if { $char==")" } { break }
      # End bug fix

      if { ($index == $startArg) && ($char == "\"") } {
         #If the first char of the argument is a quote, this is a quoted arg.
         #Parse to close quote.

         #Starting quote should not be part of name.
         incr startArg;

         while { 2 } {
            incr index;
            set char [ string index $command $index ];

            #Another quote.
            #Make sure it is the closing quote by checking if next char is a comma.
            if { $char == "\"" } {
               set char [ string index $command [ expr { $index + 1 } ] ];

               #If hit a sequence of quote,comma_or_closeparen, completed an arg.
               if { ($char == ",") || ($char == ")") } {
                  lappend result [ string range $command $startArg [ expr { $index - 1 } ] ];
                  #If hit a comma, go on to next arg.
                  #Otherwise, let the outer loop hit the close parenthesis and exit.
                  if { $char == "," } {
                     incr index 2;
                     set startArg $index;
                  }
                  set char [ string index $command $index ];

                  break;
               }
            }
         }
      } else {
         #Non quoted argument.  Continue.
         incr index;
         set char [ string index $command $index ];

         #Got to a comma or a closing quote.  Complete arg.
         if { ($char == ",") || ($char == ")") } {
            #Get arg.
            lappend result [ string range $command $startArg [ expr { $index - 1 } ] ];
            incr index;

            if { $char == "," } {
               #Do next arg.
               set startArg $index;
               set char [ string index $command $index ];
               continue;
            } else {
               #Done with args inside parenthesis.  But there may be more beyond.
               break;
            }
         }
      }
   }

   #Parse the args outside the parenthesis.
   #Get args.
   set trailingArgs [ string range $command $index end ];

   #Parse args.  These are quoted and space separated, so can be treated as a list.
   if { ! [ string is space $trailingArgs ] } {
      foreach arg $trailingArgs {
         lappend result $arg;
      }
   }

   set result;
}

#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::MergeHMCommand                                    #
# Purpose: to merge HM command                                                #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::MergeHMCommand { args } {
   if { [ llength $args ] == 1 } {
      set command [ lindex $args 0 ];
   } else {
      set command [ join $args ];
   }
   set command;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UnsetCallbacks                                    #
# Purpose: to unset all callbacks                                             #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::UnsetCallbacks { args } {

    #unset all callbacks
    catch {::BAR_ELEM_COORD_DISPLAY::UnsetSystemsCallbacks}
    catch {::BAR_ELEM_COORD_DISPLAY::UnsetVectorsCallbacks}
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::InitializeVectors                                 #
# Purpose: to initialize vector size value                                    #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::InitializeVectors { args } {

    #get vector value
    ::BAR_ELEM_COORD_DISPLAY::GetVectorsSize
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SetVectorsCallbacks                               #
# Purpose: to define vector callbacks                                         #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SetVectorsCallbacks { args } {

    #add vector settings callbacks
    AddCallback *vectordrawoptions ::BAR_ELEM_COORD_DISPLAY::Vectors_RefreshHMCB;
    AddCallback *readfile          ::BAR_ELEM_COORD_DISPLAY::InitializeVectors;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UnsetVectorsCallbacks                             #
# Purpose: to remove vector callbacks                                         #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::UnsetVectorsCallbacks { args } {

    #Remove vector settings callbacks
    RemoveCallback *vectordrawoptions ::BAR_ELEM_COORD_DISPLAY::Vectors_RefreshHMCB;
    RemoveCallback *readfile          ::BAR_ELEM_COORD_DISPLAY::InitializeVectors;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::Vectors_RefreshHMCB                               #
# Purpose: to refresh vector size value                                       #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::Vectors_RefreshHMCB { args } {

    #update
    set cmd [SplitHMCommand $args]

    if {[lindex $cmd 0] == "*vectordrawoptions"} {
        ::BAR_ELEM_COORD_DISPLAY::GetVectorsSize
        ::BAR_ELEM_COORD_DISPLAY::Toggle_Vect_Size 1
    }
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::GetVectorsSize                                    #
# Purpose to get the size of a vector                                         #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::GetVectorsSize { args } {
    variable vect_size
    variable vect_size_Unf
    variable vect_size_Mag
    variable vectorSizeTypes
    variable vectorSizeType
    
    
    ::BAR_ELEM_COORD_DISPLAY::UnsetVectorsCallbacks

    #get vector size value
    set vectorSizeType [lindex $vectorSizeTypes [hm_getvectoroption vectorsize_type] ]
    set vect_size_Unf  [expr 1. * [hm_getvectoroption vectorsize_uniform] ]
    set vect_size_Mag  [expr 100. * [hm_getvectoroption vectorsize_magnitude] ]

    if { $vectorSizeType == [lindex $vectorSizeTypes 0] } {
        set vect_size $vect_size_Unf;
    } else {
        set vect_size $vect_size_Mag;
    }
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::Toggle_Vect_Size                                  #
# Purpose: to set proper entry                                                #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::Toggle_Vect_Size { args } {
    variable vect_size
    variable vect_size_Unf
    variable vect_size_Mag
    variable vectorSizeEntry
    variable vectorSizeTypes
    variable vectorSizeType

    if {$vect_size <= 0} {
        ::BAR_ELEM_COORD_DISPLAY::GetSize;
    }

    if {$args == ""} {
        if {$vectorSizeType == [lindex $vectorSizeTypes 0]}  {
            set vectorSizeType "[lindex $vectorSizeTypes 1]"
            hwt::EntryInsert $vectorSizeEntry "$vectorSizeType"
            set vect_size_Unf [expr 1. * $vect_size]
            set vect_size [expr 1. * $vect_size_Mag]
        } else {
            set vectorSizeType "[lindex $vectorSizeTypes 0]"
            hwt::EntryInsert $vectorSizeEntry "$vectorSizeType"
            set vect_size_Mag [expr 1. * $vect_size]
            set vect_size  [expr 1. * $vect_size_Unf]
        }
        ::BAR_ELEM_COORD_DISPLAY::UpdateVectorsSize
    } else {
        hwt::EntryInsert $vectorSizeEntry "$vectorSizeType"
    }
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UpdateVectorsSize                                #
# Purpose: to update vector size settings                                     #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::UpdateVectorsSize { args } {
    variable vect_size;
    variable vect_size_Unf;
    variable vect_size_Mag;
    variable vectorSizeTypes;
    variable vectorSizeType;


    if {$vect_size <= 0} {
       hm_errormessage "Value must be greater than 0."
       ::BAR_ELEM_COORD_DISPLAY::GetVectorsSize
       ::BAR_ELEM_COORD_DISPLAY::Toggle_Vect_Size 1
       return
    }

    set vect_size  [expr 1. * $vect_size];
    set vect_size_Mag [expr 1. * $vect_size_Mag];
    set vect_size_Unf [expr 1. * $vect_size_Unf];

    if {$vectorSizeType == [lindex $vectorSizeTypes 0]} {
        *vectordrawoptions $vect_size 0 [expr $vect_size_Mag/100.]
        *plot
    } else {
        *vectordrawoptions $vect_size_Unf 1 [expr $vect_size/100.]
        *plot
    }
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SystemsInitialize                                 #
# Purpose: to initializes system settings                                     #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SystemsInitialize { args } {

    #initialize system setting
    ::BAR_ELEM_COORD_DISPLAY::GetSystemsSize
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SetSystemsCallbacks                               #
# Purpose: to define system callbacks                                         #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SetSystemsCallbacks { args } {

    #add system settings callbacks
    AddCallback *systemsize     ::BAR_ELEM_COORD_DISPLAY::Systems_RefreshHMCB;
    AddCallback *readfile       ::BAR_ELEM_COORD_DISPLAY::SystemsInitialize;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UnsetSystemsCallbacks                             #
# Purpose: to remove system callbacks                                         #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::UnsetSystemsCallbacks { args } {

    #Remove system settings
    RemoveCallback *systemsize     ::BAR_ELEM_COORD_DISPLAY::Systems_RefreshHMCB;
    RemoveCallback *readfile       ::BAR_ELEM_COORD_DISPLAY::SystemsInitialize;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::Systems_RefreshHMCB                               #
# Purpose: to run the correct callbacks for HM commands                       #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::Systems_RefreshHMCB { args } {

    #update
    set cmd [SplitHMCommand $args]
    if {[lindex $cmd 0] == "*systemsize"} {
        ::BAR_ELEM_COORD_DISPLAY::GetSystemsSize
    }
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::GetSystemsSize                                    #
# Purpose: to get system size setting                                         #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::GetSystemsSize { args } {

    variable system_size

    set system_size [expr 1. * [hm_getsystemoption systsize_uniform 1] ];
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::OnUpdateSystemSize                                #
# Purpose: to update system size setting                                      #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::OnUpdateSystemSize { args } {
    variable system_size

    if {$system_size <= 0} {
        hm_errormessage "Value must be greater than 0."
        ::BAR_ELEM_COORD_DISPLAY::GetSystemsSize
        return
    }

    set system_size [expr 1. * $system_size]

    *systemsize $system_size
    *plot
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::Switch1DElememnts                                  #
# Purpose : to switch the order of 1d elements                                 #
# Args    : element id                                                         #
# Returns : none                                                               #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::Switch1DElememnts { eList args } {

    if {$eList == ""} { return }
    
    #switch the order of 1D element
    foreach elemId $eList {
        hm_markclear elems 1;
        *entityhighlighting 0
        eval *createmark elems 1 $elemId;
        *entityhighlighting 1
        *element1dswitch 1;
        hm_markclear elems 1;
    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::CreateCollector                                    #
# Purpose : to create vector collector                                         #
# Args    : Args    : vector collector name and color                          #
# Returns : none                                                               #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::CreateCollector { type optn n_color } {

    set Coll_Name "";
    if { $type == "threeAxes"} {
        set Coll_Name "Syst2";
        *collectorcreate systcols "$Coll_Name" "" $n_color;
        *currentcollector systcols "$Coll_Name";
        if { $optn == 0 } {
            *displaycollector systcols on "$Coll_Name" 1 1
        } else {
            *displaycollector systcols off "$Coll_Name" 1 1
        }
    } else {
        set Coll_Name "Vect2";
        *collectorcreate vectorcols "$Coll_Name" "" $n_color;
        *currentcollector vectorcols "$Coll_Name";
        if { $optn == 0 } {
            *displaycollector vectorcols on "$Coll_Name" 1 1
        } else {
            *displaycollector vectorcols off "$Coll_Name" 1 1
        }

    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::CreateNodeInHyperMesh                              #
# Purpose : To get beam elements by by property id                             #
# Args    : Args    : lst_nodeXYZ - list of node x y z coordinates             #
# Returns : node id                                                            #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::CreateNodeInHyperMesh {nodeXYZ_List} {

    if {$nodeXYZ_List == ""} { return }

    *clearmark nodes 1;
    eval *createnode $nodeXYZ_List 0 0 0;
    *createmark nodes 1 -1;
    set nNodeId [hm_getmark nodes 1];
    *clearmark nodes 1;

    return $nNodeId;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState                         #
# Purpose : to manupilate coordinate systems visibility                        #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState { type optn args} {

    set entityTyp "";

    if { $type == "threeAxes"} {
        set entityTyp systems;
    } else {
        set entityTyp vectors;
    }

    *clearmark $entityTyp 1
    *entityhighlighting 0
    hm_createmark $entityTyp 1 advanced all
    *entityhighlighting 1
    if {[llength [hm_getmark $entityTyp 1] ] > 0} {
        if {$optn == "hide" } {
            *maskmark $entityTyp 1
        } elseif {$optn == "unhide" } {
            *unmaskmark $entityTyp 1
        } elseif {$optn == "delete" } {
            *deletemark $entityTyp 1
        }
    }
    *clearmark $entityTyp 1
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::GetAllCollectorNamesByType                         #
# Purpose : Get the names of all the collectors by type in the model           #
# Args    : collector type                                                     #
# Returns : list of all the collector by type present in the model.            #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::GetAllCollectorNamesByType { args } {

    variable axisType;

    set colType "";
    #get list of vector/system collector names
    if { $axisType == "threeAxes"} {
        set colType systcols;
    } else {
        set colType vectorcols;
    }

    *entityhighlighting 0
    *clearmark $colType 1;
    *createmark $colType 1 "all";
    *entityhighlighting 0
    set collectorList [hm_getmark $colType 1];
    set numPropColls  [llength $collectorList];
    set lst_propColl "";

    for { set j 0 } { $j < $numPropColls } { incr j } {
        set propID [ lindex $collectorList $j ];
        set propCollName [hm_getcollectorname $colType $propID];
        lappend lst_propColl $propCollName;
    }

    return $lst_propColl;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::DeleteCollector                                    #
# Purpose : Delete Collector in HM                                             #
# Args    : str_type - collector type                                          #
#           str_name - collector name                                          #
# Returns :  none                                                              #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::DeleteCollector { type args } {
    #variable axisType;

    set str_type "";
    set str_name "";

    if { $type == "threeAxes" } {
        set str_type systcols;
        set str_name "Syst2";
    } else {
        set str_type vectorcols;
        set str_name "Vect2";
    }
    
    #delete mark entity
    *clearmark $str_type 1;
    *entityhighlighting 0
    *createmark $str_type 1 "$str_name";
    *entityhighlighting 1
	if {[hm_marklength $str_type 1] != 0} {
	    *deletemark $str_type 1;
    }
    *clearmark $str_type 1;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate                             #
# purpose: to display element coordinate system                               #                                                             #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate { coordType opn n_elemlist } {
    variable color;
    variable vect_size;
    variable coordSize;
    variable colorList;
    variable system_size;
    variable axisTypeList;
    

    #return if no elems are selected
    if {[llength $n_elemlist] == 0 } {return}
    
    #initialize
    set XCordVLst "";
    set coordSize "";
    
    #get color
    set colorFrame .g_barcoordisplay_TPanel.f4.c;
    set bkGColor [$colorFrame cget -background];
    set crid     [lsearch $colorList $bkGColor];
    set color    [expr $crid + 1];

    if { $coordType == "threeAxes" } {
        set Coll_Name "Syst2";
        if {$system_size <= 0} {
            hm_errormessage "Value must be greater than 0."
            ::BAR_ELEM_COORD_DISPLAY::GetSystemsSize;
        }
        set coordSize $system_size;

    } else {
        set Coll_Name "Vect2";
        if {$vect_size <= 0} {
            hm_errormessage "Value must be greater than 0."
            ::BAR_ELEM_COORD_DISPLAY::GetVectorsSize
        }
        set coordSize $vect_size;
        set coordSize [expr $coordSize/100.];
    }

    # Get the list of collectors by type in HM
    set lst_Cols [::BAR_ELEM_COORD_DISPLAY::GetAllCollectorNamesByType];
    if {[lsearch $lst_Cols $Coll_Name] != -1} {
        #delete a collector if already exists.
        ::BAR_ELEM_COORD_DISPLAY::DeleteCollector $coordType;
    }

    #create new collector
    ::BAR_ELEM_COORD_DISPLAY::CreateCollector $coordType $opn $color;

    #display coordinates for bar elements
    foreach item $n_elemlist {
        set ElementID    [lindex $item 0];
        set originNodeID [lindex $item 1];
        set EndNodeID    [lindex $item 2];
        set PlaneNodeID  [lindex $item 3];
        if {$coordType == "threeAxes" } {
            lappend XCordVLst "$originNodeID $EndNodeID $PlaneNodeID";
        } else {
            lappend XCordVLst "$originNodeID $EndNodeID";
        }
    }

    #Display coordinate systems
    ::BAR_ELEM_COORD_DISPLAY::SetCoordinateOption $coordType $coordSize $XCordVLst $color;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::SetCoordinateOption                               #
# Purpose to set coordinate options                                           #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::SetCoordinateOption {optn val idList n_color args } {

    
    if { $optn == "threeAxes" } {

        set Coll_Name "Syst2";
        
        hm_markclear systcols 1
        foreach item $idList {
            if {[ llength $item] != 0 } {
                set originNode  [lindex $item 0];
                set XCoordnode  [lindex $item 1];
                set xyPlanenode [lindex $item 2];
                if {$xyPlanenode != "N/A" } {
                    catch {*systemcreate 1 0 $originNode "x-axis" $XCoordnode "xy plane" $xyPlanenode;}
                }
            }
        }

        *systemsize $val
        *retainmarkselections 1
        *createmark systcols 1  "$Coll_Name"
        *colormark systcols 1 $n_color
        *retainmarkselections 0
        hm_markclear systcols 1

    } else {

        set Coll_Name "Vect2";

        hm_markclear vectorcols 1
        *vectorlabel 0
        *vectordrawoptions 10 1 $val
        foreach item $idList {
            if {[ llength $item] != 0 } {
                set originNode  [lindex $item 0];
                set XCoordnode  [lindex $item 1];
                catch {*vectorcreate_twonode $originNode $XCoordnode}

            }
        }
        *retainmarkselections 1
        *createmark vectors 1
        *createmark vectors 1 -1
        *createmark vectors 1 "$Coll_Name"
        *colormark vectors 1 $n_color
        *retainmarkselections 0
        hm_markclear vectorcols 1

        #update vector size
        ::BAR_ELEM_COORD_DISPLAY::UpdateVectorsSize
    }
    
    #specify no message
    hm_errormessage "";
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::ClearTempNodes                                    #
# Purpose to clear temp nodes                                                 #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::ClearTempNodes {args } {

    #clear temp nodes
    hm_markclear nodes 1;
    *createmark nodes 1 "displayed";
    ##*nodemarkcleartempmark 1;
    *nodecleartempmark
    hm_markclear nodes 1;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::AdjustBeamOrientation                              #
# Purpose : to adjust beam orientation                                         #
# Args    : coordinate type                                                    #
# Returns : none                                                               #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::AdjustBeamOrientation { coordType args } {
    variable DrawCoord;
    variable ShouldDraw;
    variable eList_xdirnP;
    variable eList_xdirnN;
    variable EntityList;
    variable ref_Adjust_Element;
    variable updatedEntityList;
    variable PElemsReverse $eList_xdirnP;
    variable NElemsReverse $eList_xdirnN;


    set adjust 0;
    set RefNodeDirn "";
    #Make sure element orientation is selected
    set orient "";
    if {$ref_Adjust_Element == "" } {
        hm_errormessage "orientation element is not selected for GA_GB adjustment."
        return;
    } else {
        set ElemNode2     [hm_getentityvalue elems [lindex $ref_Adjust_Element 1] "node2.id" 0 -byid];
        set prevElemNode2 [lindex $ref_Adjust_Element 3];
        if {$prevElemNode2 == $ElemNode2 } {
            set RefNodeDirn [lindex $ref_Adjust_Element 0 ];
        } else {
            if {[lindex $ref_Adjust_Element 0 ] == "P" } {
                set RefNodeDirn "N";
            } else {
                set RefNodeDirn "P";
            }
        }
        set orient "{[lindex $ref_Adjust_Element 1] [lindex $ref_Adjust_Element 2] $ElemNode2 [lindex $ref_Adjust_Element 4]}";
    }

    set Nentity "";
    set Pentity "";
    set adjustVal   "";
    set OriginalVal "";
    #check bar element orientation (negative dirn local x)
    foreach item1 $eList_xdirnN {
        if {[ llength $item1] != 0 } {
            set neid    [lindex $item1 0];
            set nmidVal [lindex $item1 1];
            set nendVal [lindex $item1 2];
            set nnwNode2 [hm_getentityvalue elems $neid "node2.id" 0 -byid];
            set nplnVal [lindex $item1 3];
        
            if {$nendVal == $nnwNode2 } {
                #get list of elems info
                lappend Nentity "$neid $nmidVal $nendVal $nplnVal";
            } else {
                lappend Pentity "$neid $nmidVal $nnwNode2 $nplnVal";
            }
        }
    }

    #check bar element orientation (positive dirn local x)
    foreach item2 $eList_xdirnP {
        if {[ llength $item2] != 0 } {
            set peid    [lindex $item2 0];
            set pmidVal [lindex $item2 1];
            set pendVal [lindex $item2 2];
            set pnwNode2 [hm_getentityvalue elems $peid "node2.id" 0 -byid];
            set pplnVal [lindex $item2 3];
        
            if {$pendVal == $pnwNode2 } {
                #get list of elems info
                lappend Pentity "$peid $pmidVal $pendVal $pplnVal";
            } else {
                lappend Nentity "$peid $pmidVal $pnwNode2 $pplnVal";
            }
        }
    }

    #switch orientation of bar elems
    if { $RefNodeDirn == "P" } {

        foreach itm1 $Nentity {
            set eid    [lindex $itm1 0];
            set midVal [lindex $itm1 1];
            set endVal [lindex $itm1 2];
            set plnVal [lindex $itm1 3];
            
            #switch elements
            ::BAR_ELEM_COORD_DISPLAY::Switch1DElememnts $eid;
            
            #get node 2 after switching
            set barNode1 [hm_getentityvalue elems $eid "node1.id" 0 -byid];
            set newVal   [hm_getentityvalue elems $eid "node2.id" 0 -byid];
            
            #get list of elems info
            lappend adjustVal "$eid $midVal $newVal $plnVal";
        }
        
        #set OriginalVal $eList_xdirnP;
        set OriginalVal $Pentity;
        set adjust 1;

    } else {

         foreach itm2 $Pentity {
            set eid2    [lindex $itm2 0];
            set midVal2 [lindex $itm2 1];
            set endVal2 [lindex $itm2 2];
            set plnVal2 [lindex $itm2 3];

            #switch elements
            ::BAR_ELEM_COORD_DISPLAY::Switch1DElememnts $eid2;
            
            set barNode21 [hm_getentityvalue elems $eid2 "node1.id" 0 -byid];
            set newVal2   [hm_getentityvalue elems $eid2 "node2.id" 0 -byid];
            
            #get node 2 after switching element
            lappend adjustVal "$eid2 $midVal2 $newVal2 $plnVal2";
        }
        
        #set OriginalVal $eList_xdirnN;
        set OriginalVal $Nentity;

        set adjust 1;
    }

    #Display coordinates of all selected elements
    set EntityList [concat $adjustVal $OriginalVal $orient];
    set updatedEntityList [concat $adjustVal $OriginalVal];

    if {$adjust } {
        ::BAR_ELEM_COORD_DISPLAY::DeleteCollector $coordType;
        ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate $coordType 0 $EntityList;
        set DrawCoord 1;
    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::ReverseBeamOrientation                             #
# Purpose : to reverse beam orientation                                        #
# Args    : coordinate type                                                    #
# Returns : none                                                               #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::ReverseBeamOrientation { coordType state args } {
    variable DrawCoord;
    variable coordView_add_elems;
    variable ref_Adjust_Element;
    

    #switch elements
    set idList "";
    set reverse 0;

    if {[llength $coordView_add_elems] > 0} {
        set Update_elems_input [UpdateEntityOrientList $coordView_add_elems ]
        foreach itm $Update_elems_input {
            lappend idList [lindex $itm 0];
        }

        #check wheather orientation element exists in selected list
        #before switching
        set eList "";
        set ORNT   0;
        if {$DrawCoord } {
            set ch [lsearch -exact $idList [lindex $ref_Adjust_Element 1] ];
            if {$ch == -1 } {
                set eList [concat $idList [lindex $ref_Adjust_Element 1] ];
                set ORNT 1;
            } else {
                set eList $idList;
            }
        } else {
            set eList $idList;
        }

        #switch selected elements
        ::BAR_ELEM_COORD_DISPLAY::Switch1DElememnts $eList;

        if {$ORNT } {
            set eNode2 [hm_getentityvalue elems [lindex $ref_Adjust_Element 1] "node2.id" 0 -byid];
            set orientElem "{[lindex $ref_Adjust_Element 1] [lindex $ref_Adjust_Element 2] $eNode2 [lindex $ref_Adjust_Element 4]}";
            set Update_elems_input [UpdateEntityOrientList [concat $coordView_add_elems $orientElem]]
        } else {
            set Update_elems_input [UpdateEntityOrientList $coordView_add_elems]
        }

        set reverse 1;

    }

    #Reverse vectors/systems
    if {$reverse } {
        ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate $coordType $state $Update_elems_input;
    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UpdateEntityOrientList                             #
# Purpose : to get updated element orientation                                 #
# Args    : entList: entity list                                               #
# Returns : none                                                               #
#------------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::UpdateEntityOrientList { entList args } {


    set elemLst "";
    #get element node 2 after switching
    foreach itm $entList {
        if {[ llength $itm] != 0 } {
            set elemId  [lindex $itm 0];
            set midNid  [lindex $itm 1];
            set endNode [hm_getentityvalue elems $elemId "node2.id" 0 -byid];
            set planeNodeId [lindex $itm 3];
            set lst "$elemId $midNid $endNode $planeNodeId";
            lappend elemLst $lst;
        }
    }

    return $elemLst;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::CheckForCoordinates                                #
# purpose: to check whether vector or system coordinates are displayed or not  #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::CheckForCoordinates { coordType args } {

    set entityTyp "";
    set coordInfo "false";

    if {$coordType == "threeAxes" } {
        set entityTyp "systs";
    } else {
        set entityTyp "vectors";
    }

    *clearmark $entityTyp 1
    #hm_createmark $entityTyp 1 advanced displayed
    *entityhighlighting 0
    hm_createmark $entityTyp 1 advanced all
    *entityhighlighting 1
    if {[llength [hm_getmark $entityTyp 1] ] > 0  } {
        set coordInfo true;
    }
    *clearmark $entityTyp 1

    return $coordInfo;
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::OnAdjust                                           #
# Adjust 1d elements' GA_GB                                                    #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::OnAdjust {args} {
    variable axisType;
    variable orient_Coll;
    variable ref_elem_selected;

    #invoke orientation elem collector
    $orient_Coll invoke Elements;

    #Adjust GA_GB of selected elems
    if {$ref_elem_selected == "true" } {
        ::BAR_ELEM_COORD_DISPLAY::AdjustBeamOrientation $axisType;
        
        variable EntityList;
        ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinates $axisType $EntityList;

        set ref_Adjust_Element "";

        #clear orientation node highlighting
        hm_highlightentity elems 0 n
    }
    
    set ref_Adjust_Element "";
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::OnDisplayCoordinateSystem                         #
# purpose: to display element coordinate system                               #                                                             #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::OnDisplayCoordinateSystem { args } {
    variable axisType;
    variable ShouldDraw;
    variable updatedEntityList;
    variable coordView_add_elems;

    if { [llength [lindex $coordView_add_elems 0] ] == 0 } {return}

    #updated element orientation
    set Update_elems_input [UpdateEntityOrientList $coordView_add_elems]

    ::BAR_ELEM_COORD_DISPLAY::DeleteCollector $axisType;
    #display bar element coordinate system
    if { $Update_elems_input != "" } {
        ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate $axisType 0 $Update_elems_input;
        
        ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinates $axisType $Update_elems_input
        set ShouldDraw 1;
    } elseif {[llength $coordView_add_elems] > 0} {
        ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate $axisType 0 $coordView_add_elems;
        
        ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinates $axisType $coordView_add_elems
        set ShouldDraw 1;
    }  else {
        hm_errormessage "1d element is not selected."
        ::BAR_ELEM_COORD_DISPLAY::clear_elems
        return;
    }
}
#------------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::OnReverse                                          #
# purpose: to reverese elements orientation                                    #
# -----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::OnReverse { args} {
    variable axisType;
    variable DrawCoord;
    variable coordView_add_elems;
#    variable ref_Adjust_Element;

#    set orientElem "";
#    if {$DrawCoord } {
#        set orientElem "{[lindex $ref_Adjust_Element 1] [lindex $ref_Adjust_Element 2] [lindex $ref_Adjust_Element 3] [lindex $ref_Adjust_Element 4]}";
#    }

    if {$coordView_add_elems == ""} { return }

    #check for coordinates
    set coordinateInfo [CheckForCoordinates $axisType];

    if {$coordinateInfo != "false" } {
        ::BAR_ELEM_COORD_DISPLAY::DeleteCollector $axisType;
        #Reverese elements orientation
        ::BAR_ELEM_COORD_DISPLAY::ReverseBeamOrientation $axisType 0;
    }

    #updated element orientation
#    set Update_elems_input [UpdateEntityOrientList [concat $coordView_add_elems $orientElem]];
    set Update_elems_input [UpdateEntityOrientList $coordView_add_elems];

    #update coordinates
    ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinates $axisType $Update_elems_input;
    
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinateColor                             #
# Purpose: to update vector/system coordinate color                           #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::OnReject { args } {
    variable axisType;
    variable DrawCoord;
    variable ShouldDraw;
    variable PElemsReverse;
    variable NElemsReverse;
    variable ref_Adjust_Element;

    #delete coordinate if required
    if {$ShouldDraw} {
        ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState $axisType "delete";
        set ShouldDraw 0;
    }

    #return if there is no change
    if {!$DrawCoord} {return}

    set reject 0;
    set adjust 0;
    set orient "";
    set adjustVal  "";
    set OriginalVal "";

    #Check for the orientation of reference element
    set orient "{[lindex $ref_Adjust_Element 1] [lindex $ref_Adjust_Element 2] [lindex $ref_Adjust_Element 3] [lindex $ref_Adjust_Element 4]}";

    #switch orientation of bar elems
    if { [lindex $ref_Adjust_Element 0 ] == "P" } {
        set eid "";
        foreach itm1 $NElemsReverse {
            lappend eid [lindex $itm1 0];
        }

        #switch elements
        ::BAR_ELEM_COORD_DISPLAY::Switch1DElememnts $eid;
        set reject 1;

    } else {
        set eid2 "";
        foreach itm2 $PElemsReverse {
            lappend eid2  [lindex $itm2 0];
        }

        #switch elements
        ::BAR_ELEM_COORD_DISPLAY::Switch1DElememnts $eid2;
        set reject 1;
    }

    set elemList [concat $NElemsReverse $PElemsReverse $orient];
    #Display coordinates in their original orientation
    if {$reject} {
        #display previous state
        ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate $axisType 0 $elemList;
        set DrawCoord 0;
    }

    #update coordinates
    ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinates $axisType $elemList;
}
#-----------------------------------------------------------------------------#
# ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinates                                 #
# Purpose: to update coordinate systems                                       #
#-----------------------------------------------------------------------------#
proc ::BAR_ELEM_COORD_DISPLAY::UpdateCoordinates { type elemIdList args } {
    variable axisTypeList;

    set idx [lsearch -exact $axisTypeList $type];
    if {$idx == "1"} {
        set axsType "singleAxis";
    } else {
        set axsType "threeAxes";
    }

    ::BAR_ELEM_COORD_DISPLAY::DeleteCollector $axsType;
    ::BAR_ELEM_COORD_DISPLAY::DisplayBeamCoordinate $axsType 1 $elemIdList;

    #Hide coordinates
    ::BAR_ELEM_COORD_DISPLAY::CoordinatesVisibilityState "$axsType" "hide";
}