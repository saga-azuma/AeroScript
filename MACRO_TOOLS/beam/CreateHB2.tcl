#------------------------------------------------------------------------------#
#  Copyright (c) 2011 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.                                            #
#------------------------------------------------------------------------------#
#  System :  HyperMesh Customization                                           #
#                                                                              #
#    Create  : 2011/10/17                                                      #
#    Edit    :                                                                 #
#                                                                              #
#    Version   : 1.0(For HW10 Official Release)                                #
#------------------------------------------------------------------------------#
namespace eval ::CustomHB {
variable solidID_base;
variable elem_size;
variable ObLine_rec;
variable ObLine_AxisYSt "";
variable ObLine_AxisYEnd "";
variable Offset_nodes_x;
variable Offset_nodes_y;
variable Offset_nodes_z;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::CkSelect                                                        #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to create nodes on line.										   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::CreLocation { args } {
variable solid_ID;
variable line_ID;
variable node_flg;
variable Line_num;
variable line_len;
variable node_ID;
variable elem_size;
variable MatName;

variable surf_ID;
variable nodeB_ID;

variable select_bt1;
variable select_bt2;
variable select_bt3;
variable select_bt4;

variable lineID_AxisYSt;
variable lineID_AxisYEnd;
variable ObLine_AxisYSt "";
variable ObLine_AxisYEnd "";

variable solidID_base "";
set nodeList "";
set CoordList "";
set NodePair_num 0;
set Coord_Base "";

variable Offset_nodes_x 0;
variable Offset_nodes_y 0;
variable Offset_nodes_z 0;

variable line_ID_rec;
variable ObLine_rec "";
set ObLine_AxisY "";

variable Datalist "";

::CustomHB::Highlighting "Off";
## Check Entity Infomation
	## Check the input item
	if { $solid_ID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the solid.";
		return 1;
	} elseif { $line_ID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the line.";
		return 1;
	} elseif { $node_ID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the Node A.";
		return 1;
	} elseif { $node_flg == "num" && ( $Line_num <= 0 || $Line_num == "" ) } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please enter the right number of line.";
		return 1;
	} elseif { $node_flg == "len" && ( $line_len <= 0 || $line_len == "" ) } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please enter the right length.";
		return 1;
	} elseif { $select_bt1 == 1 && $surf_ID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the surface.";
		return 1;
	} elseif { $select_bt2 == 1 && $nodeB_ID == ""  } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the Node B.";
		return 1;
	} elseif { $elem_size <= 0 || $elem_size == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please enter the right element size.";
		return 1;
	} elseif { $MatName == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the material Name.";
		return 1;
	} elseif { [lsearch [hm_entitylist materials name] $MatName] == -1 } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the right material name.";
		return 1;
	} elseif { $select_bt4 == 1 && $line_ID_rec == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the line for stress data recovery.";
		return 1;
	} elseif { $select_bt3 == 1 && ($lineID_AxisYSt == "" || $lineID_AxisYEnd == "")} {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the lines for specifying Y axis.";
		return 1;
	} else {
		::CustomHB::Change_window 1;
	}
	
set DelLines "";
#--------------------------#
#  Create file for reject  #
#--------------------------#
	::CustomHB::execute_temp 0

	if { $select_bt4 == 1 } {
		*clearmark lines 1;
		set ExistLineID [hm_entitymaxid lines];
		foreach i $line_ID_rec {
			if {[hm_getlinetype $i] != 0 } {
				*createmark lines 1 $i;
				catch {*linefromsurfedgecomp lines 1 0} res;
				*clearmark lines 1;
				set MaxLineID [hm_entitymaxid lines];
				if { $ExistLineID != $MaxLineID } {
					lappend ObLine_rec $MaxLineID;
					set ExistLineID $MaxLineID;
				} else {
					tk_messageBox -type ok -icon warning -title "Warning" -message "Can't copy the line.(Line number: $i)";
					return 1;
				}
			} else {
				lappend ObLine_rec $i
			}
		}
		eval *createmark lines 1 $ObLine_rec;
		eval *createmark lines 2 $line_ID_rec;
		*markdifference lines 1 lines 2;
		set DelLines [hm_getmark lines 1];
	}
	
	if { $select_bt3 == 1 } {
		*clearmark lines 1;
		set lineID_AxisY "$lineID_AxisYSt $lineID_AxisYEnd"
		set ExistLineID [hm_entitymaxid lines];
		foreach i $lineID_AxisY {
			if {[hm_getlinetype $i] != 0 } {
				*createmark lines 1 $i;
				catch {*linefromsurfedgecomp lines 1 0} res;
				*clearmark lines 1;
				set MaxLineID [hm_entitymaxid lines];
				if { $ExistLineID != $MaxLineID } {
					lappend ObLine_AxisY $MaxLineID;
					set ExistLineID $MaxLineID;
				} else {
					tk_messageBox -type ok -icon warning -title "Warning" -message "Can't copy the line.(Line number: $i)";
					return 1;
				}
			} else {
				lappend ObLine_AxisY $i
			}
		}
		eval *createmark lines 1 $ObLine_AxisY;
		eval *createmark lines 2 $lineID_AxisY;
		*markdifference lines 1 lines 2;
		append DelLines " [hm_getmark lines 1]";
		set ObLine_AxisYSt [lindex $ObLine_AxisY 0];
		set ObLine_AxisYEnd [lindex $ObLine_AxisY 1];
	}

	*createmark solids 1 "all";
	eval *createmark solids 2 $solid_ID;
	*markdifference solids 1 solids 2;
	set solidID_base [hm_getmark solids 1];

	set Coord_St [lindex [hm_getcoordinatesofpointsonline $line_ID 0] 0];
	set Coord_End [lindex [hm_getcoordinatesofpointsonline $line_ID 1] 0];
	set Coord_Sel [lindex [hm_nodevalue $node_ID] 0];
	
	set disVal_St [expr {sqrt(pow([lindex $Coord_St 0] - [lindex $Coord_Sel 0],2) + pow([lindex $Coord_St 1] - [lindex $Coord_Sel 1],2) + pow([lindex $Coord_St 2] - [lindex $Coord_Sel 2],2))}];
	set disVal_End [expr {sqrt(pow([lindex $Coord_End 0] - [lindex $Coord_Sel 0],2) + pow([lindex $Coord_End 1] - [lindex $Coord_Sel 1],2) + pow([lindex $Coord_End 2] - [lindex $Coord_Sel 2],2))}];
	
	if { $disVal_St <= $disVal_End } {
		set SelNode_flg 0;
		set Coord_Base $Coord_St;
	} else {
		set SelNode_flg 1;
		set Coord_Base $Coord_End;
	}
	
	if { $node_flg == "num" } {
		for { set i 1 } { $i < $Line_num} { incr i } {
			lappend CoordList [lindex [hm_getcoordinatesofpointsonline $line_ID [expr 1.0 / $Line_num * $i]] 0];
		}
	} else {
		set SelNode_flg [expr $SelNode_flg + 2];
		set LineMaxLength [hm_linelength $line_ID];
		set line_lenPlus $line_len;
		while {$line_lenPlus < $LineMaxLength} {
			lappend CoordList [hm_getlinepointsatdistance $line_ID $line_lenPlus [lindex $Coord_Base 0] [lindex $Coord_Base 1] [lindex $Coord_Base 2]];
			set line_lenPlus [expr $line_lenPlus + $line_len * 1.0];
			
		}
	}

	lappend nodeList $node_ID;

	for {set i 0} {$i < [llength $CoordList]} {incr i} {
		if { $SelNode_flg == 1 } {
			*createnode [lindex [lindex $CoordList end-$i] 0] [lindex [lindex $CoordList end-$i] 1] [lindex [lindex $CoordList end-$i] 2];
		} else {
			*createnode [lindex [lindex $CoordList $i] 0] [lindex [lindex $CoordList $i] 1] [lindex [lindex $CoordList $i] 2];
		}
		lappend nodeList [hm_entitymaxid nodes];
	}
	
	
	if { $select_bt2 == 1 } {
		lappend nodeList $nodeB_ID;
	} else {
		if { $SelNode_flg == 0 || $SelNode_flg == 2 } {
			*createnode [lindex $Coord_End 0] [lindex $Coord_End 1] [lindex $Coord_End 2];
			lappend nodeList [hm_entitymaxid nodes];
		} else {
			*createnode [lindex $Coord_St 0] [lindex $Coord_St 1] [lindex $Coord_St 2];
			lappend nodeList [hm_entitymaxid nodes];
		}
	}

	set NodePair_num [expr [llength $nodeList] - 1];
	
	for {set i 0} {$i < $NodePair_num} {incr i} {
		::CustomHB::CreBeam [lindex $nodeList $i] [lindex $nodeList [expr $i + 1]];
	}

	if { $DelLines != "" } {
		eval *createmark lines 1 $DelLines;
		*deletemark lines 1;
	}
	
set solid_ID "";
set line_ID "";
set node_ID "";
set nodeB_ID "";
*clearmark elems 1
*clearmark elems 2
*clearmark nodes 1
	
if { [catch {::CustomHB::Change_window 0} res ] } {return};
if { [catch {::CustomHB::Change_window 2} res ] } {return};
::CustomHB::Highlighting "On";
return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::CreBeam                                                         #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to create beam models.										   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::CreBeam { nodeID nodeID_end } {
variable solid_ID;
variable select_bt1;
variable surf_ID;
variable elem_size;
variable MatName;
variable solidID_base;
variable ObLine_rec;
variable ObLine_AxisYSt;
variable ObLine_AxisYEnd;
variable Datalist;
variable Offset_nodes_x;
variable Offset_nodes_y;
variable Offset_nodes_z;
set PropName "";
set Nastemplate [file join [hm_info -appinfo SPECIFIEDPATH TEMPLATES_DIR] feoutput nastran general];

	*createmark solids 1 "all";
	eval *createmark solids 2 $solidID_base;
	
	*markdifference solids 1 solids 2;
	set solidID [hm_getmark solids 1];
	
	set node_coord [lindex [hm_nodevalue $nodeID] 0];
	set node_end_coord [lindex [hm_nodevalue $nodeID_end] 0];

	catch {*collectorcreateonly vectorcols "^vec_temp" "" 5} res;
	*currentcollector vectorcols "^vec_temp"
	*vectorcreate_twonode $nodeID $nodeID_end;
	set max_vecID [hm_entitymaxid vectors];
	set NormalSurf_vec "[hm_getentityvalue vectors $max_vecID "xcomp" "0"] [hm_getentityvalue vectors $max_vecID "ycomp" "0"] [hm_getentityvalue vectors $max_vecID "zcomp" "0"] ";
	set surfID "";
	
	if { $select_bt1 == 1 && $surf_ID != "" } {
		set surfID $surf_ID;
		set surf_ID "";
	} else {
		eval *createmark solids 1 $solidID;
		*createplane 1 [lindex $NormalSurf_vec 0] [lindex $NormalSurf_vec 1] [lindex $NormalSurf_vec 2] [lindex $node_coord 0] [lindex $node_coord 1] [lindex $node_coord 2];
		*body_splitmerge_with_plane solids 1 1;

		hm_createmark surfs 1 "on plane" "$node_coord [hm_getentityvalue vectors $max_vecID "xcomp" "0"] [hm_getentityvalue vectors $max_vecID "ycomp" "0"] [hm_getentityvalue vectors $max_vecID "zcomp" "0"] 0.1 1 0";
		eval *createmark solids 1 $solidID;
		*findmark solids 1 1 1 surfs 0 2;
		*markintersection surfs 1 surfs 2;
		set surfID [hm_getmark surfs 1];
	}

	if { $surfID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Can not get the cross-sectional surface."
		return 1;
	}

	if { $ObLine_AxisYSt != "" && $ObLine_AxisYEnd != "" } {
		set Coordinfo_AxisSt [::CustomHB::Get_Nearest_point_for_Line $ObLine_AxisYSt $surfID];
		set Coordinfo_AxisEnd [::CustomHB::Get_Nearest_point_for_Line $ObLine_AxisYEnd $surfID];
		
		*createmark points 1 [lindex $Coordinfo_AxisSt 4];
		*nodecreateatpointmark 1;
		*clearmark points 1;
		set NodeID_AxisSt [hm_entitymaxid nodes 1];

		*createmark points 1 [lindex $Coordinfo_AxisEnd 4];
		*nodecreateatpointmark 1;
		*clearmark points 1;
		set NodeID_AxisEnd [hm_entitymaxid nodes 1];
		
		*vectorcreate_twonode $NodeID_AxisSt $NodeID_AxisEnd;
		set TowardAxisY_vecID [hm_entitymaxid vectors];
		eval *createmark nodes 1 "$NodeID_AxisSt $NodeID_AxisEnd";
		*nodemarkcleartempmark 1;
		*clearmark nodes 1;
		
		set dis_coord "[hm_getentityvalue vectors $TowardAxisY_vecID "xcomp" "0"] [hm_getentityvalue vectors $TowardAxisY_vecID "ycomp" "0"] [hm_getentityvalue vectors $TowardAxisY_vecID "zcomp" "0"] ";
	} else {
		if { [expr abs([format %.1f [lindex $NormalSurf_vec 1]])] == 0 } {
			set dis_coord "0 1 0"
		} else {
			set coordCk "{[expr abs([lindex $NormalSurf_vec 0])] 0} {[expr abs([lindex $NormalSurf_vec 1])] 1} {[expr abs([lindex $NormalSurf_vec 2])] 2}";
			set coordCk_xyz [lindex [lindex [lsort -index 0 $coordCk] 0] 1];
			switch $coordCk_xyz {
				0 { set dis_coord "1 0 0" }
				1 { set dis_coord "0 1 0" }
				2 { set dis_coord "0 0 1" }
			}
		}
	}

	*createmark elems 2 "all";
	if { [llength $surfID] == 1 } {
		*createmark surfaces 1 $surfID;
	} else {
		eval *createmark surfaces 1 $surfID;
	}
	*defaultremeshsurf 1 $elem_size 2 2 2 1 1 1 1 0 0 0 0;
	*createmark elems 1 "all";
	*markdifference elems 1 elems 2;
	set base_elems [hm_getmark elems 1];
	
	*createplane 1 [lindex $NormalSurf_vec 0] [lindex $NormalSurf_vec 1] [lindex $NormalSurf_vec 2] [lindex $node_coord 0] [lindex $node_coord 1] [lindex $node_coord 2];
	*createvector 1 [lindex $dis_coord 0] [lindex $dis_coord 1] [lindex $dis_coord 2];
	
	eval *createmark elems 1 $base_elems;
	set Errres "";
	catch {*beam_calculateproperties elements 1 1 1 0 0 2 1 2 1 0} Errres;
	
	if { $Errres != 1 && $Offset_nodes_x != 0 && $Offset_nodes_y != 0 && $Offset_nodes_z != 0} {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Can not calculate the second moment of area."
		set prop_id [hm_entitymaxid props];
		set PropName [hm_entityinfo name props $prop_id];
		eval *createmark elems 1 $base_elems;
		*deletemark elements 1;
	} elseif { $Errres != 1 } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Can not calculate the second moment of area."
		eval *createmark elems 1 $base_elems;
		*deletemark elements 1;
		return 1;
	} else {
		set Center_NodeID_Coord [lindex [hm_nodevalue [hm_entitymaxid nodes 1]] 0];

	#------------------------------------------------Create System
		set StrRecvCoordList "";
		if { $ObLine_rec != "" } {
			catch {*collectorcreateonly systcols "^sys_temp" "" 5} res;
			*currentcollector systcols "^sys_temp";
			set Center_NodeID [hm_entitymaxid nodes 1];
			*createmark nodes 1 $nodeID;
			*duplicatemark nodes 1 0;
			*createvector 1 [lindex $dis_coord 0] [lindex $dis_coord 1] [lindex $dis_coord 2];
			*translatemark nodes 1 1 1;
			set NodeID_xyplane [hm_getmark nodes 1];
			*clearmark nodes 1;
			
			*createmark nodes 1 $Center_NodeID;
			*systemcreate 1 0 $nodeID "x-axis" $nodeID_end "xy plane    " $NodeID_xyplane;
			
			*createmark nodes 1 $NodeID_xyplane;
			*nodemarkcleartempmark 1;
			
			set MaxSysID [hm_entitymaxid systems 1];
			
			set PointIDList_Mindis "";
			foreach i $ObLine_rec {
				set PointID_Mindis "";
				set PointID_Mindis [::CustomHB::Get_Nearest_point_for_Line $i $surfID];
				lappend PointIDList_Mindis $PointID_Mindis;
			}
			
			foreach i $PointIDList_Mindis {
				lappend StrRecvCoordList "[format %.6f [hm_ypointlocal $MaxSysID [lindex $i 0] [lindex $i 1] [lindex $i 2]]] [format %.6f [hm_zpointlocal $MaxSysID [lindex $i 0] [lindex $i 1] [lindex $i 2]]]";
			}
			*createmark systcols 1 "^sys_temp";
			*deletemark systcols 1;
		}
	#-------------------------------------------------Use HyperBeam
		set geom_tol [hm_getoption cleanup_tolerance];
		*cleanuptoleranceset 0.01
	#	*createmark surfaces 1 $surfID;
		*createplane 1 [lindex $NormalSurf_vec 0] [lindex $NormalSurf_vec 1] [lindex $NormalSurf_vec 2] [lindex $Center_NodeID_Coord 0] [lindex $Center_NodeID_Coord 1] [lindex $Center_NodeID_Coord 2];
		*createvector 1 [lindex $dis_coord 0] [lindex $dis_coord 1] [lindex $dis_coord 2];
		eval *createmark elems 1 $base_elems;
		*beamsectioncreatesolid elements 1 1 1 0 [hm_entitymaxid nodes 1] 1;
		*cleanuptoleranceset $geom_tol;
		set BeamSectid [hm_entitymaxid beamsects];

		eval *createmark elems 1 $base_elems;
		*deletemark elements 1;
	#-------------------------------------------------Cre Prop
		set CompName "";
		eval *createmark solids 1 $solid_ID;
		*findmark solids 1 1 1 comps 0 1;
		set CompName_ID [lindex [hm_getmark comps 1] 0];
		set CompName [hm_entityinfo name components $CompName_ID];
		
		set AllProp "";
		set AllProp [hm_entitylist props name];
		for {set i 1} {$i <= 10001} {incr i} {
			set PropName ${CompName}_${i};
			if { [lsearch $AllProp $PropName] == -1 } {
				break;
			} elseif { $i == 10001 } {
				tk_messageBox -type ok -icon warning -title "Warning" -message "Can not add tail number because of over the limit.";
				return 1;
			}
		}
		set CompColor "";
		set CompColor [hm_entityinfo color components $CompName];
		if { $CompColor < 1 || $CompColor == "" } {
			set CompColor 11;
		}
		*collectorcreate properties $PropName $MatName $CompColor
		*createmark properties 2 $PropName
		*dictionaryload properties 2 $Nastemplate "PBEAM"

		*createmark properties 1 "${PropName}";
		set prop_id [ hm_getmark properties 1];

		*attributeupdateentity properties $prop_id 3186 1 2 0 beamsects $BeamSectid
		*attributeupdateint properties $prop_id 3240 1 2 0 1
		*attributeupdateint properties $prop_id 44 1 0 0 0
		*attributeupdatedouble properties $prop_id 19 1 0 0 0
		
		if { $StrRecvCoordList == "" } {
			*attributeupdateint properties $prop_id 189 1 2 0 0;
		} else {
			*attributeupdateint properties $prop_id 189 1 2 0 1;
			for {set i 0} {$i < [llength $StrRecvCoordList]} {incr i} {
				*attributeupdatedouble properties $prop_id [expr 20 + $i * 2] 1 1 0 [lindex [lindex $StrRecvCoordList $i] 0];
				*attributeupdatedouble properties $prop_id [expr 21 + $i * 2] 1 1 0 [lindex [lindex $StrRecvCoordList $i] 1];
			}
		}

		*attributeupdateint properties $prop_id 190 1 2 0 0
		*attributeupdateint properties $prop_id 500 1 2 0 1
		*attributeupdatedouble properties $prop_id 36 1 0 0 0
		*attributeupdatedouble properties $prop_id 37 1 0 0 0
		*attributeupdatedouble properties $prop_id 38 1 0 0 0
		*attributeupdatedouble properties $prop_id 39 1 0 0 0
		*attributeupdatedouble properties $prop_id 42 1 0 0 0
		*attributeupdatedouble properties $prop_id 43 1 0 0 0

#-------------------------------------------------Cre Beam
		set Offset_nodes_x [expr [lindex $Center_NodeID_Coord 0] - [lindex $node_coord 0]];
		set Offset_nodes_y [expr [lindex $Center_NodeID_Coord 1] - [lindex $node_coord 1]];
		set Offset_nodes_z [expr [lindex $Center_NodeID_Coord 2] - [lindex $node_coord 2]];
	}
	*createvector 1 [lindex $dis_coord 0] [lindex $dis_coord 1] [lindex $dis_coord 2];
	
#	set Vec_val_sum [expr ([lindex $NormalSurf_vec 0] + [lindex $NormalSurf_vec 1] + [lindex $NormalSurf_vec 2]) / 3];
#	set Node_val_sum [expr ([lindex $node_end_coord 0] - [lindex $node_coord 0]) + ([lindex $node_end_coord 1] - [lindex $node_coord 1]) + ([lindex $node_end_coord 2] - [lindex $node_coord 2])];
	*barelement $nodeID $nodeID_end 1 0 0 0 0 "";
#	if { ($Vec_val_sum >= 0 && $Node_val_sum >= 0 ) || ($Vec_val_sum < 0 && $Node_val_sum < 0) } {
#		*barelement $nodeID $nodeID_end 1 0 0 0 0 "${PropName}";
#	} else {
#		*barelement $nodeID_end $nodeID 1 0 0 0 0 "${PropName}";
#	}
	set ElemID [hm_entitymaxid elems];
	*baroffset $ElemID $Offset_nodes_x $Offset_nodes_y $Offset_nodes_z $Offset_nodes_x $Offset_nodes_y $Offset_nodes_z;
#	lappend Datalist "$ElemID $PropName"
	lappend Datalist "$ElemID \"$PropName\""
	*createmark vectorcols 1 "^vec_temp";
	*deletemark vectorcols 1;

	*createmark elements 1 $ElemID;
	*numbersmark elements 1 1;

return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::UpdatePropforElem                                               #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to associate properties with nodes.							   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::UpdatePropforElem {args} {
global ary;
variable CkVal;
::CustomHB::Highlighting "Off";
	for {set i 1} {$i <= [array size CkVal]} {incr i} {
		*createmark elements 1 $ary($i,2)
		*barelementupdate 1 0 0 0 0 0 1 "$ary($i,3)";
	}
if { [catch {::CustomHB::Change_window 3} res ] } {return};
::CustomHB::Highlighting "On";
return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::Get_Nearest_point_for_Line                                      #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to search nearest point from position of line.				   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::Get_Nearest_point_for_Line { LineID SurfIds } {
set PointsList "";
set PointID_Mindis "";

	eval *createmark surfs 1 $SurfIds;
	*findmark surfs 1 1 1 points 0 1;
	set PointsList [hm_getmark points 1];
	*clearmark points 1;
	*clearmark surfs 1;
	
	foreach j $PointsList {
		set PointXYZ "";
		set PointXYZ [hm_getcoordinates points $j];
		if { [lindex [hm_findclosestpointonline [lindex $PointXYZ 0] [lindex $PointXYZ 1] [lindex $PointXYZ 2] $LineID] 3] == 0 } {
			set PointID_Mindis "${PointXYZ} [lindex [hm_findclosestpointonline [lindex $PointXYZ 0] [lindex $PointXYZ 1] [lindex $PointXYZ 2] $LineID] 3] $j";
			break;
		} elseif { $PointID_Mindis == "" } {
			set PointID_Mindis "${PointXYZ} [lindex [hm_findclosestpointonline [lindex $PointXYZ 0] [lindex $PointXYZ 1] [lindex $PointXYZ 2] $LineID] 3] $j";
		} elseif { [lindex [hm_findclosestpointonline [lindex $PointXYZ 0] [lindex $PointXYZ 1] [lindex $PointXYZ 2] $LineID] 3] < [lindex $PointID_Mindis 3] } {
			set PointID_Mindis "${PointXYZ} [lindex [hm_findclosestpointonline [lindex $PointXYZ 0] [lindex $PointXYZ 1] [lindex $PointXYZ 2] $LineID] 3] $j";
		}
	}

return $PointID_Mindis;
}
