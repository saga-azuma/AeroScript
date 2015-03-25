##############################################
# history:
# 2011.11.29 
#   - stay on top.
#
source MACRO_TOOLS/MAIN/PS_Func.tcl;

toplevel .demo;
wm geometry .demo 260x200;
wm attributes .demo -topmost 1;

label .demo.lblCenter -text "center";
button .demo.btnCenter -text "node" -bg "#E6E664" -activebackground "#E6E664" -width 8 -command { CelectRifineCenter };
label .demo.lblArea -text "area";
entry .demo.entArea -width 8 -textvariable ::PS::refineArea;
button .demo.btnPreview -text "review" -width 8 -command { Preview };
button .demo.btnReset -text "reset" -width 8 -command { Reset };
label .demo.lblSize -text "size";
entry .demo.entSize -width 8 -textvariable ::PS::refineMeshSize;
label .demo.lblType -text "type"
set typeList [ list "quads" "trias" "mixed" "R-trias" "quads only" ]; 
AddEntry .demo.entType entrywidth 10 textvariable ::PS::refineMeshType listVar fromPopDown noTyping typeList withoutPacking;
label .demo.lblLayer -text "layer";
entry .demo.entLayer -width 8 -textvariable ::PS::adjustLayer;
button .demo.btnRefine -text "refine" -width 8 -bg "#60C060" -activebackground "#60C060" -command { ::PS::Functions::Refine };  

place .demo.lblCenter -x 5 -y 8;
place .demo.btnCenter -x 60 -y 5 -height 23;
place .demo.lblArea -x 5 -y 38;
place .demo.entArea -x 60 -y 35 -height 23;
place .demo.btnPreview -x 115 -y 35 -height 23;
place .demo.btnReset -x 172 -y 35 -height 23;
place .demo.lblSize -x 5 -y 68;
place .demo.entSize -x 60 -y 65 -height 23;
place .demo.lblType -x 5 -y 98;
place .demo.entType -x 60 -y 95;
place .demo.lblLayer -x 5 -y 128;
place .demo.entLayer -x 60 -y 125 -height 23;
place .demo.btnRefine -x 5 -y 158 -height 23;

proc CelectRifineCenter { args } {

	*createmarkpanel nodes 1 "select center nodes for refine";
	if { [ hm_marklength nodes 1 ] != 0 } {
	 	set ::PS::refineCenterNodes [ hm_getmark nodes 1 ];
	}
	*clearmark nodes 1;

}

proc Preview { args } {

	if { "$::PS::refineArea" == "" || $::PS::refineArea <= 0.0 } {
	 	tk_messageBox -message "Refine area is invalid." -type "ok" -icon "warning" -title "Warning";
	 	return;
	}

	if { ![ info exists ::PS::refineCenterNodes ] || [ llength $::PS::refineCenterNodes ] == 0 } {
	 	tk_messageBox -message "Center nodes are not selected." -type "ok" -icon "warning" -title "Warning";
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
	
	*entityhighlighting 1;
	hm_blockmessages 0;
	
	eval *createmark elems 1 $refineElems;
	hm_highlightmark elems 1 high;
	
}

proc Reset { args } {

	if { [ hm_marklength elems 1 ] == 0 } {
 		return;
 	}
 	
 	hm_highlightmark elems 1 normal;
 	*clearmark elems 1;

}

