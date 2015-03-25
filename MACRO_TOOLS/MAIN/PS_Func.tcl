namespace eval ::PS::Functions {
}

##################
###            ###
###   refine   ###
###            ###
##################
proc ::PS::Functions::Refine { args } {
	
	if { "$::PS::refineArea" == "" || $::PS::refineArea <= 0.0 } {
	 	tk_messageBox -message "Refine area is invalid." -type "ok" -icon "warning" -title "Warning";
	 	return;
	}
	
	if { ![ info exists ::PS::refineCenterNodes ] || [ llength $::PS::refineCenterNodes ] == 0 } {
	 	tk_messageBox -message "Center nodes are not selected." -type "ok" -icon "warning" -title "Warning";
	 	return;
	}
	
	if { $::PS::refineMeshSize == "" || $::PS::refineMeshSize <= 0.0 } {
	 	tk_messageBox -message "Mesh size is invalid." -type "ok" -icon "warning" -title "Warning";
	 	return;
	}
	
	*entityhighlighting 0;
	hm_blockmessages 1;
	
	set refineElems "";	
	foreach nid $::PS::refineCenterNodes {
	 	set nodeValue [ join [ hm_nodevalue $nid ] ];
	 	set x [ lindex $nodeValue 0 ];
	 	set y [ lindex $nodeValue 1 ];
	 	set z [ lindex $nodeValue 2 ];
	 	*createmark elems 1 "on plane" $x $y $z 1.0 0.0 0.0 $::PS::refineArea 1 1;
		*createmark elems 2 "on plane" $x $y $z 0.0 1.0 0.0 $::PS::refineArea 1 1;
		*markintersection elems 1 elems 2;
		*createmark elems 2 "on plane" $x $y $z 0.0 0.0 1.0 $::PS::refineArea 1 1;
		*markintersection elems 1 elems 2;
		eval lappend refineElems [ hm_getmark elems 1 ]; 
	}
	
	switch $::PS::refineMeshType {
		"trias" {
			set meshType 0;
		}
		"quads" {
		 	set meshType 1;
		}
		"mixed" {
			set meshType 2;
		}
		"R-trias" {
		    set meshType 3;
		}
		"quads only" {
			set meshType 4;
		}
	}
	
	if { $::PS::adjustLayer == 0 || "$::PS::adjustLayer" == "" } {
		*setedgedensitylink 0;
		*elementorder 1;
		*setusefeatures 0;
        eval *createmark elems 1 $refineElems;
        *defaultremeshelems 1 $::PS::refineMeshSize $meshType $meshType 2 1 0 1 0 0 0 0 2 30;
        *setusefeatures 0;
	} else {
		eval *createmark elems 1 $refineElems;
		eval *createmark elems 2 $refineElems; 
	 	for { set i 0 } { $i < $::PS::adjustLayer } { incr i } {
	 		hm_appendmark elems 2 "advanced" "by adjacent"; 	
	 	}
	 	*markdifference elems 2 elems 1;
	 	set adjustElems [ hm_getmark elems 2 ];		
	 	
		# create surface from FE on refine area
        *clearmark elems 2;
        set refine_surf_start [ expr [ hm_entitymaxid surfs ] + 1 ];
		*fetosurfs 1 2 121 1000000 0.1 0;
		hm_completemenuoperation;
		set refine_surf_end [ hm_entitymaxid surfs ];
		*deletemark elems 1;
		
		set new_elem_start [ expr [ hm_entitymaxid elems ] + 1 ];
		
	    # remesh adjust area
	    eval *createmark elems 1 $adjustElems;
		*setusefeatures 0;
		*defaultremeshelems 1 $::PS::refineMeshSize 2 2 1 0 1 1 0 0 0 0 2 0;
        
        # remesh refine area
        *createmark surfs 1 ${refine_surf_start}-${refine_surf_end};
        *defaultremeshsurf 1 $::PS::refineMeshSize $meshType $meshType 1 1 1 1 1 0 0 0 0;
        *deleteelementsmode 0;
        
        hm_completemenuoperation;
        set new_elem_end [ hm_entitymaxid elems ];
        
        # equivalence
		*createmark elems 1 ${new_elem_start}-${new_elem_end};
		*equivalence elems 1 [ expr $::PS::refineMeshSize / 2.0 ] 1 0 0;
        
    	*createmark surfs 1 ${refine_surf_start}-${refine_surf_end}; 
    	*deletemark surfs 1;
    	
    	*createmark elems 1;
    	*clearmark surfs 1;
	}
	
	*entityhighlighting 1;
	hm_blockmessages 0; 
}