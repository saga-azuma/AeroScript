############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
### Split Quad4 element by selected split pattern ##########
### Version5 Split with 1D, Undo ###
### Version6 Add split pattern ###

###Type2-Ver5### Split with 1D, Undo with Organize #########
proc ::SplitType2 {args} {
	### variable ###
	variable 1dsplitcheck;	#1D Check box#
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#

	### Selected element ###
	set elemid [hm_getmark elems 1];

	### Start Block and Stop Draw ###
	*entityhighlighting 0;
	hm_blockmessages 1;
	hm_blockerrormessages 1;
	hm_blockredraw 1;

	### Get view project ###
	set centroid [hm_entityinfo centroid elems $elemid];
	set project [eval hm_viewproject $centroid];
	set wx [winfo pointerx .];
	set wy [winfo pointery .];
	set hmx [hm_winfo graphicx];
	set hmy [hm_winfo graphicy];
	set unproject [hm_viewunproject [expr $wx - $hmx] [expr $wy - $hmy] [lindex $project end]];
	#eval *createnode $unproject;

	if {[hm_getentityvalue elems $elemid config 0] == "104"} {
		### Get nodes ###
		set nodelist [hm_nodelist $elemid];
		set n1 [lindex $nodelist 0];
		set n2 [lindex $nodelist 1];
		set n3 [lindex $nodelist 2];
		set n4 [lindex $nodelist 3];

		### Create undo comp ###
		if {[hm_entityinfo exist comps "^SplitUndo" -byname] == "0"} {
			set currentcomp [hm_info currentcomponent];
			*collectorcreateonly components "^SplitUndo" "" 11;
			*currentcollector components $currentcomp;
		}
		*displaycollectorwithfilter components "off" "^SplitUndo" 1 0;

		### 2d Undo info ###
		lappend 2dUndoList $elemid;
		dict set 2dUndoInfo $elemid compinfo [hm_getentityvalue elems $elemid collector.name 1];

		### Find nearest node ###
		eval *createmark nodes 1 $nodelist;
		set nearestnode [lindex [eval hm_measureshortestdistance2 $unproject nodes 1 0 0] 4];
		if {$nearestnode == $n1} {
			set na $n1;
			set nb $n4;
			set nc $n2;
			set splittype 130;
		} elseif {$nearestnode == $n2} {
			set na $n2;
			set nb $n1;
			set nc $n3;
			set splittype 10;
		} elseif {$nearestnode == $n3} {
			set na $n3;
			set nb $n2;
			set nc $n4;
			set splittype 40;
		} elseif {$nearestnode == $n4} {
			set na $n4;
			set nb $n3;
			set nc $n1;
			set splittype 160;
		}
		if {$1dsplitcheck == "0"} {				### Split Quad 4 w/o 1D ###
			### Organize the 2d shell to undo comp ###
			*createmark elems 1 $elemid;
			*duplicatemark elems 1 0;
			set elemid2 [hm_latestentityid elems];
			*createmark elems 1 $elemid;
			*movemark elems 1 "^SplitUndo";

			hm_entityrecorder elems on;
			*createmark elems 1 $elemid2;
			*createarray 1 $splittype;
			*elementmarksplit 1 1 1;
			hm_entityrecorder elems off;
			dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];
		} elseif {$1dsplitcheck == "1"} {			### Split Quad4 with 1D ###
			### Get 1D elemid of split edges ###
			set 1dElems "";
			*createmark elems 1 $elemid;
			hm_appendmark elems 1 "advanced" "by adjacent";
			foreach adjelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $adjelemid config 0] == "60"} {
					set adjnodelist [hm_nodelist $adjelemid];
					if {[lsearch $adjnodelist $na] != "-1" && [lsearch $adjnodelist $nb] != "-1"} {
						lappend 1dElems $adjelemid;
						dict lappend 1dUndoList $elemid $adjelemid;
						dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
					} elseif {[lsearch $adjnodelist $na] != "-1" && [lsearch $adjnodelist $nc] != "-1"} {
						lappend 1dElems $adjelemid;
						dict lappend 1dUndoList $elemid $adjelemid;
						dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
					}
				}
			}
			### Organize the 1d and 2d to undo comp ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $elemid $1dElems;
			*duplicatemark elems 1 0;
			hm_entityrecorder elems off;
			set copylist [hm_entityrecorder elems ids];
			eval *createmark elems 1 $elemid $1dElems;
			*movemark elems 1 "^SplitUndo";

			### Set array ###
			set array "";
			eval *createmark elems 1 $copylist;
			foreach arelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $arelemid config 0] == "60"} {
					append array "2 ";
				} else {
					append array "$splittype ";
				}
			}

			### Split quad4 with 1d ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $copylist;
			eval *createarray [llength $array] $array;
			*elementmarksplitwith1D 1 1 [llength $array];
			hm_entityrecorder elems off;
			dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];

		}
	} else {
		hm_errormessage "This script is support only Quad4 element";
	}

	### Stop Block and Start Draw ###
	*entityhighlighting 1;
	hm_blockmessages 0;
	hm_blockerrormessages 0;
	hm_blockredraw 0;

	### Clear mark and list ###
	hm_markclearall 1;
	*clearlist nodes 1;
}
### Exec type2 ###
proc ::ExecType2Split {args} {
	hm_framework registerproc ::SplitType2 graphics_selection_changed;
	*createmarkpanel elems 1 "Select split elements";
	hm_framework unregisterproc ::SplitType2 graphics_selection_changed;
}



############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
###Type3-Ver5### Split with 1D, Undo with Organize #########
proc ::SplitType3 {args} {
	### variable ###
	variable 1dsplitcheck;	#1D Check box#
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#

	foreach elemid [hm_getmark elmes 1] {
		if {[hm_getentityvalue elems $elemid config 0] == "104"} {

			### Get node info ###
			set nodelist [hm_nodelist $elemid];
			set n1 [lindex $nodelist 0];
			set n2 [lindex $nodelist 1];
			set n3 [lindex $nodelist 2];
			set n4 [lindex $nodelist 3];

			### Create undo comp ###
			if {[hm_entityinfo exist comps "^SplitUndo" -byname] == "0"} {
				set currentcomp [hm_info currentcomponent];
				*collectorcreateonly components "^SplitUndo" "" 11;
				*currentcollector components $currentcomp;
			}
			*displaycollectorwithfilter components "off" "^SplitUndo" 1 0;

			### 2d Undo info ###
			lappend 2dUndoList $elemid;
			dict set 2dUndoInfo $elemid compinfo [hm_getentityvalue elems $elemid collector.name 1];

			### Get 1D info ###
			set 1dElems "";
			if {$1dsplitcheck == "1"} {
				*createmark elems 1 $elemid;
				hm_appendmark elems 1 "advanced" "by adjacent";
				foreach adjelemid [hm_getmark elems 1] {
					if {[hm_getentityvalue elems $adjelemid config 0] == "60"} {
						set adjnodelist [hm_nodelist $adjelemid];
						if {[lsearch $adjnodelist $n1] != "-1" && [lsearch $adjnodelist $n2] != "-1"} {
							lappend 1dElems $adjelemid;
							dict lappend 1dUndoList $elemid $adjelemid;
							dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
						} elseif {[lsearch $adjnodelist $n2] != "-1" && [lsearch $adjnodelist $n3] != "-1"} {
							lappend 1dElems $adjelemid;
							dict lappend 1dUndoList $elemid $adjelemid;
							dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
						} elseif {[lsearch $adjnodelist $n3] != "-1" && [lsearch $adjnodelist $n4] != "-1"} {
							lappend 1dElems $adjelemid;
							dict lappend 1dUndoList $elemid $adjelemid;
							dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
						} elseif {[lsearch $adjnodelist $n4] != "-1" && [lsearch $adjnodelist $n1] != "-1"} {
							lappend 1dElems $adjelemid;
							dict lappend 1dUndoList $elemid $adjelemid;
							dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
						}
					}
				}
			}
			### Organize the 1d and 2d to undo comp ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $elemid $1dElems;
			*duplicatemark elems 1 0;
			hm_entityrecorder elems off;
			set copylist [hm_entityrecorder elems ids];
			eval *createmark elems 1 $elemid $1dElems;
			*movemark elems 1 "^SplitUndo";

			### Split quad4 with 1d ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $copylist;
			if {$1dsplitcheck == "0"} {
				*splitelements 1 1;
			} elseif {$1dsplitcheck == "1"} {
				*splitelementswith1D 0 1;
			}
			hm_entityrecorder elems off;
			dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];
		}
	}
	hm_markclearall 1;
}
### Exec type3 ###
proc ::ExecType3Split {args} {
	hm_framework registerproc ::SplitType3 graphics_selection_changed;
	*createmarkpanel elems 1 "Select split elements";
	hm_framework unregisterproc ::SplitType3 graphics_selection_changed;
}



############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
###Type4-Ver5### Split with 1D, Undo with Organize #########
proc ::SplitType4 {args} {
	### variable ###
	variable 1dsplitcheck;	#1D Check box#
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#

	### Selected element ###
	set elemid [hm_getmark elems 1];

	### Start Block and Stop Draw ###
	*entityhighlighting 0;
	hm_blockmessages 1;
	hm_blockerrormessages 1;
	hm_blockredraw 1;

	### Get view project ###
	set centroid [hm_entityinfo centroid elems $elemid];
	set project [eval hm_viewproject $centroid];
	set wx [winfo pointerx .];
	set wy [winfo pointery .];
	set hmx [hm_winfo graphicx];
	set hmy [hm_winfo graphicy];
	set unproject [hm_viewunproject [expr $wx - $hmx] [expr $wy - $hmy] [lindex $project end]];
	#eval *createnode $unproject;

	if {[hm_getentityvalue elems $elemid config 0] == "104"} {

		### Get nodes ###
		set nodelist [hm_nodelist $elemid];
		set n1 [lindex $nodelist 0];
		set n2 [lindex $nodelist 1];
		set n3 [lindex $nodelist 2];
		set n4 [lindex $nodelist 3];

		### Create undo comp ###
		if {[hm_entityinfo exist comps "^SplitUndo" -byname] == "0"} {
			set currentcomp [hm_info currentcomponent];
			*collectorcreateonly components "^SplitUndo" "" 11;
			if {$currentcomp != ""} {
				*currentcollector components $currentcomp;
			}
		}
		### Hide UndoComp ###
		*displaycollectorwithfilter components "off" "^SplitUndo" 1 0;

		### 2d Undo info ###
		lappend 2dUndoList $elemid;
		dict set 2dUndoInfo $elemid compinfo [hm_getentityvalue elems $elemid collector.name 1];

		### Create line for each edges ###
		#edge1#
		*createlist nodes 1 $n1 $n2;
		*linecreatefromnodes 1 0 150 5 179;
		set edge1 [hm_latestentityid lines];
		#edge2#
		*createlist nodes 1 $n2 $n3;
		*linecreatefromnodes 1 0 150 5 179;
		set edge2 [hm_latestentityid lines];
		#edge3#
		*createlist nodes 1 $n3 $n4;
		*linecreatefromnodes 1 0 150 5 179;
		set edge3 [hm_latestentityid lines];
		#edge4#
		*createlist nodes 1 $n4 $n1;
		*linecreatefromnodes 1 0 150 5 179;
		set edge4 [hm_latestentityid lines];

		### Find nearest edge ###
		set edgelist "$edge1 $edge2 $edge3 $edge4";
		eval *createmark lines 1 $edgelist;
		set nearestedge [lindex [eval hm_measureshortestdistance2 $unproject lines 1 0 0] 4];
		if {$nearestedge == $edge1} {
			set na $n1;
			set nb $n2;
			set nodelist "\$n2n \$n3n \$n4n \$n1n";
			set length [expr [lindex [hm_getdistance nodes $n1 $n2 0] 0]/3.0];
		} elseif {$nearestedge == $edge2} {
			set na $n2;
			set nb $n3;
			set nodelist "\$n3n \$n4n \$n1n \$n2n";
			set length [expr [lindex [hm_getdistance nodes $n2 $n3 0] 0]/3.0];
		} elseif {$nearestedge == $edge3} {
			set na $n3;
			set nb $n4;
			set nodelist "\$n4n \$n1n \$n2n \$n3n";
			set length [expr [lindex [hm_getdistance nodes $n3 $n4 0] 0]/3.0];
		} elseif {$nearestedge == $edge4} {
			set na $n4;
			set nb $n1;
			set nodelist "\$n1n \$n2n \$n3n \$n4n";
			set length [expr [lindex [hm_getdistance nodes $n4 $n1 0] 0]/3.0];
		}

		### Get 1D elem of split edge ###
		set 1dElems "";
		if {$1dsplitcheck == "1"} {
			set 1dElems "";
			*createmark elems 1 $elemid;
			hm_appendmark elems 1 "advanced" "by adjacent";
			foreach adjelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $adjelemid config 0] == "60"} {
					set adjnodelist [hm_nodelist $adjelemid];
					if {[lsearch $adjnodelist $na] != "-1" && [lsearch $adjnodelist $nb] != "-1"} {
						lappend 1dElems $adjelemid;
						dict lappend 1dUndoList $elemid $adjelemid;
						dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
					}
				}
			}
		}

		### Detach elems ###
		eval *createmark elems 1 $elemid $1dElems;
		*detachelements 1 0;

		### Organize the 1d and 2d to undo comp ###
		hm_entityrecorder elems on;
		eval *createmark elems 1 $elemid $1dElems;
		*duplicatemark elems 1 0;
		hm_entityrecorder elems off;
		set copylist [hm_entityrecorder elems ids];
		eval *createmark elems 1 $elemid $1dElems;
		*movemark elems 1 "^SplitUndo";

		foreach copyid $copylist {
			if {[hm_getentityvalue elems $copyid config 0] == "104"} {
				set elem2id $copyid;
			}
		}
		set nodelist2 [hm_nodelist $elem2id];
		set n1n [lindex $nodelist2 0];
		set n2n [lindex $nodelist2 1];
		set n3n [lindex $nodelist2 2];
		set n4n [lindex $nodelist2 3];

		### Drag elems ###
		*surfacemode 3;
		hm_entityrecorder elems on;
		eval *createlist nodes 1 $nodelist;
		*createvector 1 0 0 1;
		*dragnodestoformsurface 1 1 1;
		*hmmeshdrag 1;
		*storemeshtodatabase 0;
		hm_entityrecorder elems off;
		set dragedelems [hm_entityrecorder elems ids];
		*ameshclearsurface;

		### Split elem with/without 1D ###
		hm_entityrecorder elems on;
		if {$1dsplitcheck == "0"} {
			eval *createmark elems 1 $copylist;
			*refineelementsbysize 1 $length;
		} elseif {$1dsplitcheck == "1"} {
			eval *createmark elems 1 $copylist;
			*refineelementsbysizewith1D 1 $length;
		}
		hm_entityrecorder elems off;
		dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];

		### Delete droged elems ###
		eval *createmark elems 1 $dragedelems;
		*deletemark elems 1;

		### Replace nodes ###
		*replacenodes $n1n $n1 1 0;
		*replacenodes $n2n $n2 1 0;
		*replacenodes $n3n $n3 1 0;
		*replacenodes $n4n $n4 1 0;

		### Delete lines ###
		eval *createmark lines 1 $edgelist;
		*deletemark lines 1;
	} else {
		hm_errormessage "This script is support only Quad4 element";
	}

	### Stop Block and Start Draw ###
	*entityhighlighting 1;
	hm_blockmessages 0;
	hm_blockerrormessages 0;
	hm_blockredraw 0;

	### Clear mark and list ###
	hm_markclearall 1;
	*clearlist nodes 1;
}
### Exec type4 ###
proc ::ExecType4Split {args} {
	hm_framework registerproc ::SplitType4 graphics_selection_changed;
	*createmarkpanel elems 1 "Select split elements";
	hm_framework unregisterproc ::SplitType4 graphics_selection_changed;
}



###Type5-Ver5### Split with 1D, Undo with Organize #########
proc ::SplitType5 {args} {
	### variable ###
	variable 1dsplitcheck;	#1D Check box#
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#

	### Selected element ###
	set elemid [hm_getmark elems 1];

	### Start Block and Stop Draw ###
	*entityhighlighting 0;
	hm_blockmessages 1;
	hm_blockerrormessages 1;
	hm_blockredraw 1;

	### Get view project ###
	set centroid [hm_entityinfo centroid elems $elemid];
	set project [eval hm_viewproject $centroid];
	set wx [winfo pointerx .];
	set wy [winfo pointery .];
	set hmx [hm_winfo graphicx];
	set hmy [hm_winfo graphicy];
	set unproject [hm_viewunproject [expr $wx - $hmx] [expr $wy - $hmy] [lindex $project end]];
	#eval *createnode $unproject;

	if {[hm_getentityvalue elems $elemid config 0] == "104"} {
		### Get nodes ###
		set nodelist [hm_nodelist $elemid];
		set n1 [lindex $nodelist 0];
		set n2 [lindex $nodelist 1];
		set n3 [lindex $nodelist 2];
		set n4 [lindex $nodelist 3];

		### Create undo comp ###
		if {[hm_entityinfo exist comps "^SplitUndo" -byname] == "0"} {
			set currentcomp [hm_info currentcomponent];
			*collectorcreateonly components "^SplitUndo" "" 11;
			*currentcollector components $currentcomp;
		}
		*displaycollectorwithfilter components "off" "^SplitUndo" 1 0;

		### 2d Undo info ###
		lappend 2dUndoList $elemid;
		dict set 2dUndoInfo $elemid compinfo [hm_getentityvalue elems $elemid collector.name 1];

		### Create line for each edges ###
		#edge1#
		*createlist nodes 1 $n1 $n2;
		*linecreatefromnodes 1 0 150 5 179;
		set edge1 [hm_latestentityid lines];
		#edge2#
		*createlist nodes 1 $n2 $n3;
		*linecreatefromnodes 1 0 150 5 179;
		set edge2 [hm_latestentityid lines];
		#edge3#
		*createlist nodes 1 $n3 $n4;
		*linecreatefromnodes 1 0 150 5 179;
		set edge3 [hm_latestentityid lines];
		#edge4#
		*createlist nodes 1 $n4 $n1;
		*linecreatefromnodes 1 0 150 5 179;
		set edge4 [hm_latestentityid lines];

		### Find nearest edge ###
		set edgelist "$edge1 $edge2 $edge3 $edge4";
		eval *createmark lines 1 $edgelist;
		set nearestedge [lindex [eval hm_measureshortestdistance2 $unproject lines 1 0 0] 4];

		### Find nearest node ###
		eval *createmark nodes 1 $nodelist;
		set nearestnode [lindex [eval hm_measureshortestdistance2 $unproject nodes 1 0 0] 4];
		if {$nearestedge == $edge1 && $nearestnode == $n1} {
			set na $n1;
			set nb $n2;
			set splittype 66;
		} elseif {$nearestedge == $edge1 && $nearestnode == $n2} {
			set na $n1;
			set nb $n2;
			set splittype 18;
		} elseif {$nearestedge == $edge2 && $nearestnode == $n2} {
			set na $n2;
			set nb $n3;
			set splittype 9;
		} elseif {$nearestedge == $edge2 && $nearestnode == $n3} {
			set na $n2;
			set nb $n3;
			set splittype 72;
		} elseif {$nearestedge == $edge3 && $nearestnode == $n3} {
			set na $n3;
			set nb $n4;
			set splittype 36;
		} elseif {$nearestedge == $edge3 && $nearestnode == $n4} {
			set na $n3;
			set nb $n4;
			set splittype 33;
		} elseif {$nearestedge == $edge4 && $nearestnode == $n4} {
			set na $n4;
			set nb $n1;
			set splittype 144;
		} elseif {$nearestedge == $edge4 && $nearestnode == $n1} {
			set na $n4;
			set nb $n1;
			set splittype 132;
		}

		if {$1dsplitcheck == "0"} {				### Split Quad 4 w/o 1D ###
			### Organize the 2d shell to undo comp ###
			*createmark elems 1 $elemid;
			*duplicatemark elems 1 0;
			set elemid2 [hm_latestentityid elems];
			*createmark elems 1 $elemid;
			*movemark elems 1 "^SplitUndo";

			hm_entityrecorder elems on;
			*createmark elems 1 $elemid2;
			*createarray 1 $splittype;
			*elementmarksplit 1 1 1;
			hm_entityrecorder elems off;
			dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];
		} elseif {$1dsplitcheck == "1"} {			### Split Quad4 with 1D ###

			### Get 1D elemid of split edges ###
			set 1dElems "";
			*createmark elems 1 $elemid;
			hm_appendmark elems 1 "advanced" "by adjacent";
			foreach adjelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $adjelemid config 0] == "60"} {
					set adjnodelist [hm_nodelist $adjelemid];
					if {[lsearch $adjnodelist $na] != "-1" && [lsearch $adjnodelist $nb] != "-1"} {
						lappend 1dElems $adjelemid;
						dict lappend 1dUndoList $elemid $adjelemid;
						dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
					}
				}
			}
			### Organize the 1d and 2d to undo comp ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $elemid $1dElems;
			*duplicatemark elems 1 0;
			hm_entityrecorder elems off;
			set copylist [hm_entityrecorder elems ids];
			eval *createmark elems 1 $elemid $1dElems;
			*movemark elems 1 "^SplitUndo";

			### Set array ###
			set array "";
			eval *createmark elems 1 $copylist;
			foreach arelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $arelemid config 0] == "60"} {
					append array "2 ";
				} else {
					append array "$splittype ";
				}
			}

			### Split quad4 with 1d ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $copylist;
			eval *createarray [llength $array] $array;
			*elementmarksplitwith1D 1 1 [llength $array];
			hm_entityrecorder elems off;
			dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];

		}
		### Delete lines ###
		eval *createmark lines 1 $edgelist;
		*deletemark lines 1;
	} else {
		hm_errormessage "This script is support only Quad4 element";
	}

	### Stop Block and Start Draw ###
	*entityhighlighting 1;
	hm_blockmessages 0;
	hm_blockerrormessages 0;
	hm_blockredraw 0;

	### Clear mark and list ###
	hm_markclearall 1;
	*clearlist nodes 1;
}
### Exec type5 ###
proc ::ExecType5Split {args} {
	hm_framework registerproc ::SplitType5 graphics_selection_changed;
	*createmarkpanel elems 1 "Select split elements";
	hm_framework unregisterproc ::SplitType5 graphics_selection_changed;
}



############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
###Type1-Ver5### Split with 1D, Undo with Organize #########
proc ::SplitType1 {args} {
	### variable ###
	variable 1dsplitcheck;	#1D Check box#
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#

	### Selected element ###
	set elemid [hm_getmark elems 1];

	### Start Block and Stop Draw ###
	*entityhighlighting 0;
	hm_blockmessages 1;
	hm_blockerrormessages 1;
	hm_blockredraw 1;

	### Get view project ###
	set centroid [hm_entityinfo centroid elems $elemid];
	set project [eval hm_viewproject $centroid];
	set wx [winfo pointerx .];
	set wy [winfo pointery .];
	set hmx [hm_winfo graphicx];
	set hmy [hm_winfo graphicy];
	set unproject [hm_viewunproject [expr $wx - $hmx] [expr $wy - $hmy] [lindex $project end]];
	#eval *createnode $unproject;

	if {[hm_getentityvalue elems $elemid config 0] == "104"} {

		### Get nodes ###
		set nodelist [hm_nodelist $elemid];
		set n1 [lindex $nodelist 0];
		set n2 [lindex $nodelist 1];
		set n3 [lindex $nodelist 2];
		set n4 [lindex $nodelist 3];

		### Create undo comp ###
		if {[hm_entityinfo exist comps "^SplitUndo" -byname] == "0"} {
			set currentcomp [hm_info currentcomponent];
			*collectorcreateonly components "^SplitUndo" "" 11;
			if {$currentcomp != ""} {
				*currentcollector components $currentcomp;
			}
		}
		### Hide UndoComp ###
		*displaycollectorwithfilter components "off" "^SplitUndo" 1 0;

		### 2d Undo info ###
		lappend 2dUndoList $elemid;
		dict set 2dUndoInfo $elemid compinfo [hm_getentityvalue elems $elemid collector.name 1];

		### Create line for each edges ###
		#edge1#
		*createlist nodes 1 $n1 $n2;
		*linecreatefromnodes 1 0 150 5 179;
		set edge1 [hm_latestentityid lines];
		#edge2#
		*createlist nodes 1 $n2 $n3;
		*linecreatefromnodes 1 0 150 5 179;
		set edge2 [hm_latestentityid lines];
		#edge3#
		*createlist nodes 1 $n3 $n4;
		*linecreatefromnodes 1 0 150 5 179;
		set edge3 [hm_latestentityid lines];
		#edge4#
		*createlist nodes 1 $n4 $n1;
		*linecreatefromnodes 1 0 150 5 179;
		set edge4 [hm_latestentityid lines];

		### Find nearest edge ###
		set edgelist "$edge1 $edge2 $edge3 $edge4";
		eval *createmark lines 1 $edgelist;
		set nearestedge [lindex [eval hm_measureshortestdistance2 $unproject lines 1 0 0] 4];
		if {$nearestedge == $edge1 || $nearestedge == $edge3} {
			set na $n1;
			set nb $n2;
			set nc $n3;
			set nd $n4;
			set splittype 34;
		} elseif {$nearestedge == $edge2 || $nearestedge == $edge4} {
			set na $n2;
			set nb $n3;
			set nc $n4;
			set nd $n1;
			set splittype 136;
		}

		### Get 1D elem of split edge ###
		set 1dElems "";
		if {$1dsplitcheck == "0"} {
			### Organize the 2d shell to undo comp ###
			*createmark elems 1 $elemid;
			*duplicatemark elems 1 0;
			set elemid2 [hm_latestentityid elems];
			*createmark elems 1 $elemid;
			*movemark elems 1 "^SplitUndo";

			hm_entityrecorder elems on;
			*createmark elems 1 $elemid2;
			*createarray 1 $splittype;
			*elementmarksplit 1 1 1;

			hm_entityrecorder elems off;
			dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];
		} elseif {$1dsplitcheck == "1"} {
			*createmark elems 1 $elemid;
			hm_appendmark elems 1 "advanced" "by adjacent";
			foreach adjelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $adjelemid config 0] == "60"} {
					set adjnodelist [hm_nodelist $adjelemid];
					if {[lsearch $adjnodelist $na] != "-1" && [lsearch $adjnodelist $nb] != "-1"} {
						lappend 1dElems $adjelemid;
						dict lappend 1dUndoList $elemid $adjelemid;
						dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
					} elseif {[lsearch $adjnodelist $nc] != "-1" && [lsearch $adjnodelist $nd] != "-1"} {
						lappend 1dElems $adjelemid;
						dict lappend 1dUndoList $elemid $adjelemid;
						dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
					}
				}
			}

			### Organize the 1d and 2d to undo comp ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $elemid $1dElems;
			*duplicatemark elems 1 0;
			hm_entityrecorder elems off;
			set copylist [hm_entityrecorder elems ids];
			eval *createmark elems 1 $elemid $1dElems;
			*movemark elems 1 "^SplitUndo";

			### Set array ###
			set array "";
			eval *createmark elems 1 $copylist;
			foreach arelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $arelemid config 0] == "60"} {
					append array "2 ";
				} else {
					append array "$splittype ";
				}
			}

			### Split quad4 with 1d ###
			hm_entityrecorder elems on;
			eval *createmark elems 1 $copylist;
			eval *createarray [llength $array] $array;
			*elementmarksplitwith1D 1 1 [llength $array];
			hm_entityrecorder elems off;
			dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];
		}

		### Delete lines ###
		eval *createmark lines 1 $edgelist;
		*deletemark lines 1;
	} else {
		hm_errormessage "This script is support only Quad4 element";
	}

	### Stop Block and Start Draw ###
	*entityhighlighting 1;
	hm_blockmessages 0;
	hm_blockerrormessages 0;
	hm_blockredraw 0;

	### Clear mark and list ###
	hm_markclearall 1;
	*clearlist nodes 1;
}
### Exec type4 ###
proc ::ExecType1Split {args} {
	hm_framework registerproc ::SplitType1 graphics_selection_changed;
	*createmarkpanel elems 1 "Select split elements";
	hm_framework unregisterproc ::SplitType1 graphics_selection_changed;
}



############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
###TypeY-Ver5### Split with 1D, Undo with Organize, ManualSplit###
proc ::SplitTypeY {args} {
	### variable ###
	variable Associates;
	variable 1dsplitcheck;	#1D Check box#
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#

	### Selected element ###
	set elemid [hm_getmark elems 1];

	### Start Block and Stop Draw ###
	*entityhighlighting 0;
	hm_blockmessages 1;
	hm_blockerrormessages 1;
	hm_blockredraw 1;

	### Get view project ###
	set centroid [hm_entityinfo centroid elems $elemid];
	set project [eval hm_viewproject $centroid];
	set wx [winfo pointerx .];
	set wy [winfo pointery .];
	set hmx [hm_winfo graphicx];
	set hmy [hm_winfo graphicy];
	set unproject [hm_viewunproject [expr $wx - $hmx] [expr $wy - $hmy] [lindex $project end]];
	#eval *createnode $unproject;

	if {[hm_getentityvalue elems $elemid config 0] == "104"} {
		### Current component to elem comp ###
		set currentcomp [hm_info currentcomponent];
		*currentcollector components [hm_getentityvalue elems $elemid collector.name 1];

		### Get nodes ###
		set nodelist [hm_nodelist $elemid];
		set n1 [lindex $nodelist 0];
		set n2 [lindex $nodelist 1];
		set n3 [lindex $nodelist 2];
		set n4 [lindex $nodelist 3];

		### Create undo comp ###
		if {[hm_entityinfo exist comps "^SplitUndo" -byname] == "0"} {
			set currentcomp [hm_info currentcomponent];
			*collectorcreateonly components "^SplitUndo" "" 11;
			*currentcollector components $currentcomp;
		}
		*displaycollectorwithfilter components "off" "^SplitUndo" 1 0;

		### 2d Undo info ###
		lappend 2dUndoList $elemid;
		dict set 2dUndoInfo $elemid compinfo [hm_getentityvalue elems $elemid collector.name 1];

		### Create line for each edges ###
		#edge1#
		*createlist nodes 1 $n1 $n2;
		*linecreatefromnodes 1 0 150 5 179;
		set edge1 [hm_latestentityid lines];
		#edge2#
		*createlist nodes 1 $n2 $n3;
		*linecreatefromnodes 1 0 150 5 179;
		set edge2 [hm_latestentityid lines];
		#edge3#
		*createlist nodes 1 $n3 $n4;
		*linecreatefromnodes 1 0 150 5 179;
		set edge3 [hm_latestentityid lines];
		#edge4#
		*createlist nodes 1 $n4 $n1;
		*linecreatefromnodes 1 0 150 5 179;
		set edge4 [hm_latestentityid lines];

		### Find nearest edge ###
		set edgelist "$edge1 $edge2 $edge3 $edge4";
		eval *createmark lines 1 $edgelist;
		set nearestedge [lindex [eval hm_measureshortestdistance2 $unproject lines 1 0 0] 4];
		if {$nearestedge == $edge1} {
			set na $n1;
			set nb $n2;
			set nodelist1 "\$m1 $n2 $n3 \$c1";
			set nodelist2 "$n3 $n4 \$c1";
			set nodelist3 "\$m1 \$c1 $n4 $n1";
		} elseif {$nearestedge == $edge2} {
			set na $n2;
			set nb $n3;
			set nodelist1 "\$m1 $n3 $n4 \$c1";
			set nodelist2 "$n4 $n1 \$c1";
			set nodelist3 "\$m1 \$c1 $n1 $n2";
		} elseif {$nearestedge == $edge3} {
			set na $n3;
			set nb $n4;
			set nodelist1 "\$m1 $n4 $n1 \$c1";
			set nodelist2 "$n1 $n2 \$c1";
			set nodelist3 "\$m1 \$c1 $n2 $n3";
		} elseif {$nearestedge == $edge4} {
			set na $n4;
			set nb $n1;
			set nodelist1 "\$m1 $n1 $n2 \$c1";
			set nodelist2 "$n2 $n3 \$c1";
			set nodelist3 "\$m1 \$c1 $n3 $n4";
		}

		### Create mid positoion nodes ###
		*createlist nodes 1 $na $nb;
		*createnodesbetweennodelist 1 1 0 0;
		set m1 [hm_latestentityid nodes 0];
		eval *createnode $centroid;
		set c1 [hm_latestentityid nodes 0];

		### Record start ###
		hm_entityrecorder elems on;
		### Create element 1 ###
		eval *createlist nodes 1 $nodelist1;
		*createelement 104 1 1 1;
		### Create element 2 ###
		eval *createlist nodes 1 $nodelist2;
		*createelement 103 1 1 1;
		### Create element 3 ###
		eval *createlist nodes 1 $nodelist3;
		*createelement 104 1 1 1;

		### With 1D ###
		set 1dElems "";
		if {$1dsplitcheck == "1"} {
			### Get 1D elemid of split edges ###
			set 1dElems "";
			*createmark elems 1 $elemid;
			hm_appendmark elems 1 "advanced" "by adjacent";
			foreach adjelemid [hm_getmark elems 1] {
				if {[hm_getentityvalue elems $adjelemid config 0] == "60"} {
					set adjnodelist [hm_nodelist $adjelemid];
					if {[lsearch $adjnodelist $na] != "-1" && [lsearch $adjnodelist $nb] != "-1"} {
						lappend 1dElems $adjelemid;
						dict lappend 1dUndoList $elemid $adjelemid;
						dict set 1dUndoInfo $elemid $adjelemid compinfo [hm_getentityvalue elems $adjelemid collector.name 1];
						*createmark elems 1 $adjelemid;
						*duplicatemark elems 1 0;
						#split 1D 1#
						*createmark elems 1 [hm_latestentityid elems];
						*createarray 1 2;
						*elementmarksplitwith1D 1 1 1;
						*replacenodes [hm_latestentityid nodes] $m1 1 0;
					}
				}
			}
		}
		hm_entityrecorder elems off;
		dict set UndoDelList $elemid delelemid [hm_entityrecorder elems ids];

		### Organize ###
		*createmark elems 1 $elemid $1dElems;
		*movemark elems 1 "^SplitUndo";

		### Delete lines, nodes ###
		eval *createmark lines 1 $edgelist;
		*deletemark lines 1;
		eval *createmark nodes 1 $m1 $c1;
		*nodemarkcleartempmark 1;

		### Associate nodes ###
		set surfid [hm_getentityvalue nodes $n1 surfaceid 0];
		if {$surfid != "0"} {
			dict lappend Associates surflist $surfid;
			dict lappend Associates $surfid $m1 $c1 $n1 $n2 $n3 $n4;
		}

		### Current component to original ###
		*currentcollector components $currentcomp;
	} else {
		hm_errormessage "This script is support only Quad4 element";
	}

	### Stop Block and Start Draw ###
	*entityhighlighting 1;
	hm_blockmessages 0;
	hm_blockerrormessages 0;
	hm_blockredraw 0;

	### Clear mark and list ###
	hm_markclearall 1;
	*clearlist nodes 1;
}
### Exec typeY ###
proc ::ExecTypeYSplit {args} {
	hm_framework registerproc ::SplitTypeY graphics_selection_changed;
	*createmarkpanel elems 1 "Select split elements";
	hm_framework unregisterproc ::SplitTypeY graphics_selection_changed;
}

############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
## Undo ###
proc ::UndoProc {args} {
	### variable ###
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#

	### Undo using hmascii ###
	if {[llength $2dUndoList] == "0"} {
		tk_messageBox -message "Undo可能な要素が見つかりません";
	} else {
		### Write to file ###
		set shellid [lindex $2dUndoList end];
		*createmark elems 1 $shellid;
		*movemark elems 1 [dict get $2dUndoInfo $shellid compinfo];
		if {[dict exists $1dUndoList $shellid] == "1"} {
			foreach 1did [dict get $1dUndoList $shellid] {
				*createmark elems 1 $1did;
				*movemark elems 1 [dict get $1dUndoInfo $shellid $1did compinfo];
			}
		}

		### Delete elemets ###
		hm_createmark elems 1 [dict get $UndoDelList $shellid delelemid];
		catch {*deletemark elems 1};

		### Remove last from Undolist ###
		set 2dUndoList [lreplace $2dUndoList end end];
	}

	### Clear mark and list ###
	hm_markclearall 1;
	*clearlist nodes 1;
}


############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
## Combine ###
proc ::CombineProc {args} {
	hm_pushpanelitem "edit element" combine;
	hm_callpanel "edit element";
}

############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############################################################
### Quit ###
proc ::QuitProc {args} {
	### Associate nodes to surfaces ###
	variable Associates;
	if {[llength [dict get $Associates surflist]] != "0"} {
		foreach surfid [lsort -unique [dict get $Associates surflist]] {
			set nodelist [dict get $Associates $surfid];
			eval *createmark nodes 1 $nodelist;
			*nodesassociatetogeometry 1 surfaces $surfid 0.01;
		}
	}
	unset Associates;

	### Unset variable ###
	variable 1dUndoList;	#dict list#
	variable 2dUndoList;	#list#
	variable 1dUndoInfo;	#dict set#
	variable 2dUndoInfo;	#dict set#
	variable UndoDelList;	#dict set#
	unset 1dUndoList;
	unset 2dUndoList
	unset 1dUndoInfo
	unset 2dUndoInfo
	unset UndoDelList

	### Delete undo comps ###
	if {[hm_entityinfo exist comps "^SplitUndo"] == "1"} {
		*createmark comps 1 "^SplitUndo";
		*deletemark comps 1;
	}

	### Stop Block and Start Draw ###
	*entityhighlighting 1;
	hm_blockmessages 0;
	hm_blockerrormessages 0;
	hm_blockredraw 0;

	### Destroy GUI ###
	set a [destroy .splitGUI];
}

############################## For GUI ##############################
proc ::SplitGUI {imagedir} {
	### create dict ###
	variable Associates [dict create];
	dict set Associates surflist "";

	### for Undo ###
	variable 1dUndoList [dict create];
	variable 2dUndoList;
	set 2dUndoList "";
	variable 1dUndoInfo [dict create];
	variable 2dUndoInfo [dict create];
	variable UndoDelList [dict create];

	### for split1d ###
	variable 1dsplitcheck;

	### Base window ###
	set w ".splitGUI";
	toplevel $w
	wm title $w "split v6 J";
	wm geometry $w "190x450";
	wm resizable $w 0 0;
	::hwt::KeepOnTop $w;

	### Label ###
	label $w\.selection		-text "分割タイプを選択";
	label $w\.selmethod		-text "分割するエッジ付近をピック";

	### Create image ###
	image create photo type2image -file "$imagedir\/type2.png";
	image create photo type3image -file "$imagedir\/type3.png";
	image create photo type4image -file "$imagedir\/type4.png";
	image create photo type5image -file "$imagedir\/type5.png";
	image create photo type1image -file "$imagedir\/type1.png";
	image create photo typeYimage -file "$imagedir\/typeY.png";
#	image create photo combineimg -file "$imagedir\/Combine.png";

	### Split type Button ###
	# Split 2 button #
	button $w.type2exec		-image type2image \
					-command {hm_setpanelproc ::ExecType2Split}

	# Split 3 button #
	button $w.type3exec		-image type3image \
					-command {hm_setpanelproc ::ExecType3Split}

	# Split 4 button #
	button $w.type4exec		-image type4image \
					-command {hm_setpanelproc ::ExecType4Split}

	# Split 5 button #
	button $w.type5exec		-image type5image \
					-command {hm_setpanelproc ::ExecType5Split}

	# Split 6 button #
	button $w.type1exec		-image type1image \
					-command {hm_setpanelproc ::ExecType1Split}

	# Split Y button #
	button $w.typeYexec		-image typeYimage \
					-command {hm_setpanelproc ::ExecTypeYSplit}

	# 1d-split check button #
	checkbutton $w.1dsplit		-text "1D要素も同時に分割" \
					-font {{MS Sans Serif} 10 bold} \
					-variable 1dsplitcheck;

	# Undo button #
	button $w.undo			-text "Undo" \
					-font {{MS Sans Serif} 11 normal roman} \
					-width 20 \
					-height 2 \
					-background blue \
					-foreground yellow \
					-command {::UndoProc}

	# Comnbine button #
	button $w.combine		-text "Combineパネル" \
					-font {{MS Sans Serif} 11 normal roman} \
					-width 20 \
					-height 2 \
					-background green \
					-command {hm_pushpanelitem "edit element" combine; ;hm_setpanelproc ::CombineProc}

	#button $w.combine -image combineimg \
					#-command {hm_pushpanelitem "edit element" combine; ;hm_setpanelproc ::CombineProc}

	# Quit button #
        button $w\.quit                 -text "終了" \
                                        -width 13 \
					-background red \
					-foreground white \
                                        -command {hm_setpanelproc ::QuitProc}

	#Place#
	place $w\.selection		-relx 0.05	-y 10	-anchor w;

	place $w.type2exec		-relx 0.05	-y 60	-anchor w;
	place $w.type4exec		-relx 0.50	-y 60	-anchor w;

	place $w.type3exec		-relx 0.05	-y 150	-anchor w;
	place $w.typeYexec		-relx 0.50	-y 150	-anchor w;

	place $w.type5exec		-relx 0.05	-y 240	-anchor w;
	place $w.type1exec		-relx 0.50	-y 240	-anchor w;

	place $w\.selmethod		-relx 0.05	-y 292	-anchor w;

	place $w.1dsplit		-relx 0.05	-y 313	-anchor w;

	place $w\.undo   		-relx 0.05	-y 350	-anchor w;
	place $w\.combine		-relx 0.05	-y 395	-anchor w;
	place $w\.quit   		-relx 0.49	-y 430	-anchor w;
}

set imagedir [file dirname [info script]];
::SplitGUI $imagedir
