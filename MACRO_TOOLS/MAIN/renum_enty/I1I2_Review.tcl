# HWVERSION_9.0_April 2009
#------------------------------------------------------------------------------#
#  Copyright (c) 2007 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.            Update : 24/04/2009             #
#------------------------------------------------------------------------------#
option add *font { {Tahoma} 8 roman};
option add *Dialog.msg.font { {Tahoma} 8 roman};
hwt::SetAppFont -point 8 Tahoma


# Deletes name space

catch {namespace delete ::i1i2_review};

# Global Variables 

namespace eval ::i1i2_review {

    variable elem_list  "";
    variable reqt_size    "10";


    #panel title name
    set ptitle "property I review";



    #source the hwcollector.tcl for using the collector widget
    set altair_home [ hm_info -appinfo ALTAIR_HOME ];
    set col_dir [file join $altair_home "hw" "tcl" "hw" "collector" "hwcollector.tcl"];
    # On Windows, replace the forward slash with backward slash.
    if {[string equal $::tcl_platform(platform) windows]} {
        set col_dir [string map {/ \\} $col_dir];
    }
    source $col_dir;

}

# ::i1i2_review::MainWindow 

proc ::i1i2_review::MainWindow { args } {
    variable type;
    variable ptitle;
    variable pFrame;
    variable reqt_size;

    #destroy panel if it exist
    catch {destroy .g_i1i2_review_TPanel}

    #add hm panel
    set pFrame [frame .g_i1i2_review_TPanel -padx 7 -pady 7];
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


    #element button
    frame $f2.f2;
    grid rowconfigure $f2.f2 2 -weight 1;
    grid $f2.f2 -sticky nw;

    set bWidth  [hwt::DluWidth 92]
    set bHeight [hwt::DluHeight 14]


    #hm_collector widget
    Collector $f2.f2.coll entity 1 HmMarkCol \
        -types  "elements" \
        -withtype     0 \
        -withReset     1 \
        -callback ::i1i2_review::ElemEntityCollectorHandler;

    grid $f2.f2.coll -sticky news -pady 4;
    $f2.f2.coll invoke Elements;

    #size input field
    frame $f3.s;
    grid $f3.s -row 2 -column 0 -sticky nw;
    label $f3.s.lab1 -text " Size :" \
         -width 12 \
         -justify left \
         -anchor nw \
         -font [hwt::AppFont];

    grid $f3.s.lab1  -row 2 -column 0 -sticky w -padx 7;

    hwt::AddEntry $f3.s.vect_ent \
         entrywidth  15 \
         withoutPacking \
         -validate real \
         -justify right \
         -textvariable ::i1i2_review::reqt_size \
         State "normal";

    grid $f3.s.vect_ent -row 2 -column 1 -sticky nw -ipady 2 -ipadx 1;


    #review_excute button
    frame $f4.f2;
    grid rowconfigure $f4.f2 2 -weight 1;
    grid $f4.f2 -sticky nw;
    
    set bWidth  [hwt::DluWidth 92];
    set bHeight [hwt::DluHeight 14];

    set bkgClr "#4ec852";
    hwt::CanvasButton $f4.f2.disp \
            $bWidth  \
            $bHeight \
            -background $bkgClr \
            -text "I1&I2 Review" \
            -command "::i1i2_review::review_excute" \
            -relief raised;
    grid $f4.f2.disp -sticky nw;

    #delete review button
    hwt::CanvasButton $f4.f2.lab1 \
            $bWidth  \
            $bHeight \
            -background $bkgClr \
            -text "Delete Review" \
            -command "::i1i2_review::DeleteReview" \
            -relief raised;
    grid $f4.f2.lab1 -sticky nw;

    #return button
    hwt::CanvasButton $f4.f2.f \
        $bWidth \
        $bHeight \
        -background #c96341 \
        -text "return" \
        -command "::i1i2_review::OnQuit" \
        -relief raised;
    grid $f4.f2.f -sticky nw -pady 55;

    #draw hm panel
    hm_framework drawpanel $pFrame;
}

# ::i1i2_review::Exists 

proc ::i1i2_review::Exists {args} {

    if { [ winfo exists .g_i1i2_review_TPanel ] } { return 1 }
    
    return 0;
}


# ::i1i2_review::ElemEntityCollectorHandler

proc ::i1i2_review::ElemEntityCollectorHandler { args } {
    variable elem_list "";
    variable count "0"


    switch [ lindex $args 0 ] {
        "getadvselmethods"
        {
            foreach {entity} $args break
            *createmarkpanel elements 1 "Select 1d elements to review I"
            set elem_list [hm_getmark elements 1]

            return
        }
        "reset"
        {
            set elem_list "";
            *clearmark elems 1
        }
        default
        {
            # This should not do anything
            return
        }
    }
}


# i1i2_review::review_excute

proc ::i1i2_review::review_excute { args } {
    variable elem_list
    variable Nelem_list
    variable reqt_size
    variable count

	hm_markclear  elems 1



  if {$reqt_size=="0"} {
    hm_errormessage "Error: The size is 0";
    return;
  }

	#create collector "^Temp_Surf00"
	set temp_surf00 [hm_entitylist comps name]
	if {[lsearch $temp_surf00 "^Temp_Surf00"] == -1} {
		*collectorcreateonly comps "^Temp_Surf00" "" 49
	} else {
		*currentcollector comps "^Temp_Surf00"
	}


	#for selected elements
	set num_elem [llength $elem_list]
	if {$num_elem=="0"} {
		hm_errormessage "Error: No element selected.";
		return;
	} else {
		foreach eid $elem_list {
			set configId [hm_getentityvalue elems $eid "config" 0 -byid]
			if { $configId == 60 } {

				#get prop ID from elem
				if {[hm_getentityvalue elem $eid propertyid 0]=="0"} {
					hm_errormessage "Error: No property linked.";

				} else {

					set PropID [hm_getentityvalue elem $eid propertyid 0]


					#set direction of local Y axis of 1D elem
					set Y_XAxisVect [hm_getentityvalue elems $eid "localyx" 0 -byid];
					set Y_YAxisVect [hm_getentityvalue elems $eid "localyy" 0 -byid];
					set Y_ZAxisVect [hm_getentityvalue elems $eid "localyz" 0 -byid];

					#set list of local Y axis for vetor
					set YcompList [list $Y_XAxisVect $Y_YAxisVect $Y_ZAxisVect];

					#set length of elem and node ID
					set barLength  [hm_getentityvalue elems $eid "length" 0 -byid];
					set barNode1   [hm_getentityvalue elems $eid "node1.id" 0 -byid];
					set barNode2   [hm_getentityvalue elems $eid "node2.id" 0 -byid];

					#set cood of GA and GB
					set node1Val [hm_nodevalue $barNode1];
					set node2Val [hm_nodevalue $barNode2];

					#set cood of GA and GB from list index
					set xnode1 [lindex [lindex $node1Val 0] 0];
					set ynode1 [lindex [lindex $node1Val 0] 1];
					set znode1 [lindex [lindex $node1Val 0] 2];

					set xnode2 [lindex [lindex $node2Val 0] 0];
					set ynode2 [lindex [lindex $node2Val 0] 1];
					set znode2 [lindex [lindex $node2Val 0] 2];

					#x component of unit vector of local x axis
					set X_localX [expr ($xnode2 - $xnode1)/$barLength];

					#cood of midpoint between GA and GB
					set X_mid [expr ([format %f $xnode1] + [format %f $xnode2]) / 2 ]
					set y_mid [expr ([format %f $ynode1] + [format %f $ynode2]) / 2 ]
					set z_mid [expr ([format %f $znode1] + [format %f $znode2]) / 2 ];





					#create node on center of elem
					set nodeXYZ_List [list $X_mid $y_mid $z_mid];
					eval *createnode $nodeXYZ_List 0 0 0;
					set centernodeID [hm_entitymaxid nodes]
					*clearmark nodes 1;

					#XY plane from ref node
					if { $Y_YAxisVect == 0 && $Y_ZAxisVect == 0} {
						if { $Y_XAxisVect > 0 } {
							set xyPlaneNode  [list [expr $X_mid + $Y_XAxisVect] [expr $y_mid + $Y_YAxisVect] [expr $z_mid + 1] ];
						} else {
							set xyPlaneNode  [list [expr $X_mid + $Y_XAxisVect] [expr $y_mid + $Y_YAxisVect] [expr $z_mid - 1] ];
						}
					} else {
						set xyPlaneNode  [list [expr $X_mid + $Y_XAxisVect] [expr $y_mid + $Y_YAxisVect] [expr $z_mid + $Y_ZAxisVect] ];
					}

					#create temp plane node
					eval *createnode $xyPlaneNode 0 0 0;
					set xyPlanenodeID [hm_entitymaxid nodes]
					*clearmark nodes 1;


					#local X axis set
					set X_XAxisVect [expr ($xnode2 - $xnode1) ];
					set X_YAxisVect [expr ($ynode2 - $ynode1) ];
					set X_ZAxisVect [expr ($znode2 - $znode1) ];

					#create surface
					*createplane 1 $X_XAxisVect $X_YAxisVect $X_ZAxisVect $X_mid $y_mid $z_mid

					#create ^Temp_System00 
					set tempSystemcolls [hm_entitylist systemcols name]
					if {[lsearch $tempSystemcolls "^Temp_System00"] == -1} {
						*collectorcreate systemcols "^Temp_System00" "" 2
					} else {
						*currentcollector systemcols "^Temp_System00"
					}

					*systemcreate3nodes 0 $centernodeID x $barNode2 xy $xyPlanenodeID
					set tempSystemID [hm_entitymaxid systems]

					#kubetsu Pbeam and Pbar
					#set format
					#get I from property

					if {[hm_attributeindexidentifier properties $PropID 1] == 107} {
						if {[hm_attributeindexvalue prop $PropID 4] == 0} {
							set IA [format %f [hm_getentityvalue prop $PropID \$PBAR_I1 0]]
							set IB [format %f [hm_getentityvalue prop $PropID \$PBAR_I2 0]]
						} else {
							set BeamSectID [hm_attributeindexvalue prop $PropID 4]
							set IA [format %f [hm_getentityvalue beamsects $BeamSectID results_Icentroid1 0]]
							set IB [format %f [hm_getentityvalue beamsects $BeamSectID results_Icentroid0 0]]
						}
						set IAhi [expr [format %f $IA] / ([format %f $IA] + [format %f $IB])]
						set IBhi [expr [format %f $IB] / ([format %f $IA] + [format %f $IB])]
					} elseif {[hm_attributeindexidentifier properties $PropID 1] == 187 || [hm_attributeindexidentifier properties $PropID 1] == 8181 } {
						if {[hm_attributeindexvalue prop $PropID 4] == 0} {
							set IA [format %f [hm_getentityvalue prop $PropID \$PBEAM_I1a 0]]
							set IB [format %f [hm_getentityvalue prop $PropID \$PBEAM_I2a 0]]
							set IAhi [expr [format %f $IA] / ([format %f $IA] + [format %f $IB])]
							set IBhi [expr [format %f $IB] / ([format %f $IA] + [format %f $IB])]
						} else {
							set BeamSectID [hm_attributeindexvalue prop $PropID 4]
							set IA [format %f [hm_getentityvalue beamsects $BeamSectID results_Icentroid1 0]]
							set IB [format %f [hm_getentityvalue beamsects $BeamSectID results_Icentroid0 0]]
							set IAhi [expr [format %f $IA] / ([format %f $IA] + [format %f $IB])]
							set IBhi [expr [format %f $IB] / ([format %f $IA] + [format %f $IB])]
						}

					} else {
						continue
					}


					if {[expr $IA * $IB] <= 0} {

						hm_errormessage "Error: please input positive value in property I."

					} else {

						#create move1,2node on Z axis 
						set Ysize [expr $IAhi*$::i1i2_review::reqt_size]
						set Zsize [expr $IBhi*$::i1i2_review::reqt_size]
						set halfZsize [expr $Zsize / 2]
						*createmark nodes 1 $centernodeID
						*duplicatemark nodes 1 0
						set move1nodeID [hm_entitymaxid nodes]
						*createmark nodes 1 $move1nodeID
						*createvector 1 0.0000 0.0000 1.0000
						*translatemarkwithsystem nodes 1 1 $halfZsize $tempSystemID $centernodeID
						*createmark nodes 1 $centernodeID
						*duplicatemark nodes 1 0
						set move2nodeID [hm_entitymaxid nodes]
						*createmark nodes 1 $move2nodeID
						*createvector 1 0.0000 0.0000 -1.0000
						*translatemarkwithsystem nodes 1 1 $halfZsize $tempSystemID $centernodeID

						#create move3,4node on Y axis 
						*createmark nodes 1 $move1nodeID
						*duplicatemark nodes 1 0
						set move3nodeID [hm_entitymaxid nodes]
						*createmark nodes 1 $move3nodeID
						*createvector 1 0.0000 1.0000 0.0000
						*translatemarkwithsystem nodes 1 1 $Ysize $tempSystemID $centernodeID
						*createmark nodes 1 $move2nodeID
						*duplicatemark nodes 1 0
						set move4nodeID [hm_entitymaxid nodes]
						*createmark nodes 1 $move4nodeID
						*createvector 1 0.0000 1.0000 0.0000
						*translatemarkwithsystem nodes 1 1 $Ysize $tempSystemID $centernodeID
	
						*createlist nodes 1 $move1nodeID $move2nodeID $move4nodeID $move3nodeID
						*surfacesplineonnodesloop 1
	
						#size adjust
						set Irectangle [hm_entitymaxid surfs]
						set halfYsize [expr [format %f $Ysize] / 2]
						*createmark surfs 1 $Irectangle 
						*createvector 1 0.0000 -1.0000 0.0000
						*translatemarkwithsystem surfs 1 1 [format %f $halfYsize] $tempSystemID $centernodeID
	
						#cleaning
						*createmark nodes 1 $move1nodeID $move2nodeID $move4nodeID $move3nodeID $centernodeID $xyPlanenodeID
						*nodemarkcleartempmark 1

						
					}

				}
			}
		}
	}
}


# i1i2_review::DeleteReview

proc ::i1i2_review::DeleteReview { args} {

	set temp_surf00 [hm_entitylist comps name]
	if {[lsearch $temp_surf00 "^Temp_Surf00"] == -1} {
		hm_errormessage "Error: No Review Section in model."
		return
	} else {
		*createmark components 1 "^Temp_Surf00"
		*deletemark components 1
	}

	set tempSystemcolls [hm_entitylist systemcols name]
	if {[lsearch $tempSystemcolls "^Temp_System00"] == -1} {
		hm_errormessage "Error: No Review systemcols in model."
		return
	} else {
	*createmark systcols 1 "^Temp_System00"
	*deletemark systcols 1
	}


}


# i1i2_review::OnQuit

proc ::i1i2_review::OnQuit { args} {
    variable pFrame;

    #Exit panel
    hm_exitpanel
}



::i1i2_review::MainWindow

