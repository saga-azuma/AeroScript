############################################################
# Copyright (c) 2016 Altair Engineering Japan.  All Rights #
############################################################
### Create Dimensions Version 5 ###
### Ver1 Create Dimensions for Distance, Length, Radius ###
### Ver2 change the direction mean of Distance. ###
### Ver3 add the 2 vector angle and 3 node angle. ###
### Ver4 add the Remove latest and delete PLOTEL with tags feature ###
### Ver5 Show/Hide PLOTEL with tags, Show the path for Length ###
############################################################

############################################################
######## Common proc ########
proc ::DimensionCompSettings {args} {
	set compname "^Dimensions";
	if {[hm_entityinfo exist comps $compname] == 1} {
		*currentcollector components $compname;
	} else {
		*collectorcreateonly components $compname "" 5;
	}
}

############################################################
### Distance ###
proc ::Distance2nodes {args} {
	# Select nodes #
	*createlistpanel nodes 1 "Select 2 nodes";
	lassign [hm_getlist nodes 1] n1a n2a;

	# Select Plane #
	set vector [lindex [hm_getdirectionpanel] 0];

	if {$n1a != "" && $n2a != "" && $vector != ""} {
		::DimensionCompSettings;
		# Distance #
		set dis1 [format %.3f [lindex [hm_getdistance nodes $n1a $n2a 0] 0]];
		set dis2 [expr $dis1 * 0.2];

		# Create node #
		eval *createnode [hm_getvalue nodes id=$n1a dataname=coordinates] 0 0 0;
		set n1b [hm_latestentityid nodes];
		eval *createnode [hm_getvalue nodes id=$n2a dataname=coordinates] 0 0 0;
		set n2b [hm_latestentityid nodes];

		# Create PLOTEL #
		*createlist nodes 1 $n1a $n1b;
		*createelement 2 1 1 1;
		*createlist nodes 1 $n2a $n2b;
		*createelement 2 1 1 1;
		*createlist nodes 1 $n1b $n2b;
		*createelement 2 1 1 1;
		set plotid [hm_latestentityid elems];

		# Create Tags #
		set tagname [::hwat::utils::GetUniqueName tags "Dis=$dis1"];
		*tagcreate elements $plotid $tagname "Node$n1a\,$n2a" 5;

		# For Remove #
		*createmark tags 1 [hm_latestentityid tags];
		*createarray 3 [hm_latestentityid elems 0] [hm_latestentityid elems 1] [hm_latestentityid elems 2];
		*metadatamarkintarray tags 1 "RelatedElementsWithTag" 1 3;

		# Translate nodes #
		*createmark nodes 1 $n1b $n2b;
		eval *createvector 1 $vector;
		*translatemark nodes 1 1 $dis2;

		# Clear temp nodes #
		*createmark nodes 1 $n1b $n2b;
		*nodemarkcleartempmark 1;
	} else {
		# Error Message #
		tk_messageBox -message "Selected entity does not enough, Please select again";
	}
}

############################################################
### Length ###
proc ::LengthOfNodes {args} {
	# Select nodes #
	*createlistbypathpanel nodes 1 "Select nodes by path";
	set nodelist [hm_getlist nodes 1];
	set n1a [lindex $nodelist 0];
	set n2a [lindex $nodelist end];
	if {[llength $nodelist] == "2"} {
		# Select Plane #
		set plane [lindex [hm_getdirectionpanel] 0];
	} elseif {[llength $nodelist] > "2"} {
		# Get Plane #
		set i [expr [llength $nodelist] / 2];
		set n3 [lindex $nodelist $i];
		set vec1 [::hwat::math::GetVector [hm_getvalue nodes id=$n1a dataname=coordinates] [hm_getvalue nodes id=$n3 dataname=coordinates]];
		set vec2 [::hwat::math::GetVector [hm_getvalue nodes id=$n3 dataname=coordinates] [hm_getvalue nodes id=$n2a dataname=coordinates]];
		set plane [::hwat::math::VectorCrossProduct $vec1 $vec2];
	}
	if {$n1a != "" && $n2a != "" && $plane != ""} {
		::DimensionCompSettings;
		# Length #
		eval *createlist nodes 1 $nodelist;
		*linecreatefromnodes 1 0 150 5 179;
		set lineid [hm_latestentityid lines];
		set dis1 [format %.3f [hm_linelength $lineid]];
		set dis2 [expr $dis1 * 0.2];

		# Delete line #
		*createmark lines 1 $lineid;
		*deletemark lines 1;

		# Vector #
		set vec1 [::hwat::math::GetVector [hm_getvalue nodes id=$n1a dataname=coordinates] [hm_getvalue nodes id=$n2a dataname=coordinates]];
		set vec2 [::hwat::math::VectorCrossProduct $plane $vec1];

		# Create node #
		eval *createnode [hm_getvalue nodes id=$n1a dataname=coordinates] 0 0 0;
		set n1b [hm_latestentityid nodes];
		eval *createnode [hm_getvalue nodes id=$n2a dataname=coordinates] 0 0 0;
		set n2b [hm_latestentityid nodes];

		# Start elem recorder #
		hm_entityrecorder elems on;

		# Create Lead line PLOTEL #
		*createlist nodes 1 $n1a $n1b;
		*createelement 2 1 1 1;
		*createlist nodes 1 $n2a $n2b;
		*createelement 2 1 1 1;
		*createlist nodes 1 $n1b $n2b;
		*createelement 2 1 1 1;
		set plotid [hm_latestentityid elems];
		# Create path PLOTEL #
		eval *createlist nodes 1 $nodelist;
		*createelement 2 1 1 1;

		# End elem recorder #
		hm_entityrecorder elems off;
		set plotellist [hm_entityrecorder elems ids];

		# Create Tags #
		set tagname [::hwat::utils::GetUniqueName tags "Length=$dis1"];
		*tagcreate elements $plotid $tagname "Node$n1a\,$n2a" 5;

		# For Remove #
		*createmark tags 1 [hm_latestentityid tags];
		eval *createarray [llength $plotellist] $plotellist;
		*metadatamarkintarray tags 1 "RelatedElementsWithTag" 1 [llength $plotellist];

		# Translate nodes #
		*createmark nodes 1 $n1b $n2b;
		eval *createvector 1 $vec2;
		*translatemark nodes 1 1 $dis2;

		# Clear temp nodes #
		*createmark nodes 1 $n1b $n2b;
		*nodemarkcleartempmark 1;
	} else {
		# Error Message #
		tk_messageBox -message "Selected entity does not enough, Please select again";
	}
}

############################################################
### Radius ###
proc ::Radius3nodes {args} {
	# Select nodes #
	*createlistpanel nodes 1 "Select 3 nodes";
	lassign [hm_getlist nodes 1] n1 n2 n3;

	if {$n1 != "" && $n2 != "" && $n3 != ""} {
		::DimensionCompSettings;
		# Create center node #
		*createcenternode $n1 $n2 $n3;
		set centernode [hm_latestentityid nodes];

		# R #
		set R [format %.3f [lindex [hm_getdistance nodes $n2 $centernode 0] 0]];

		# Create PLOTEL #
		*createlist nodes 1 $n2 $centernode;
		*createelement 2 1 1 1;
		set plotid [hm_latestentityid elems];

		# Create Tags #
		set tagname [::hwat::utils::GetUniqueName tags "R=$R"];
		*tagcreate elements $plotid $tagname "Node$n1\,$n2\,$n3" 5;

		# For Remove #
		*createmark tags 1 [hm_latestentityid tags];
		*createarray 1 [hm_latestentityid elems 0];
		*metadatamarkintarray tags 1 "RelatedElementsWithTag" 1 1;

		# Clear temp nodes #
		*createmark nodes 1 $centernode;
		*nodemarkcleartempmark 1;
	} else {
		# Error Message #
		tk_messageBox -message "Selected entity does not enough, Please select again";
	}
}

############################################################
### Two vector angle ###
proc ::Vector2angle {args} {
	# Select vectors #
	tk_messageBox -message "Select 1st vector";
	lassign [lindex [hm_getplanepanel] 0] vector1 base1;
	lassign $base1 x1 y1 z1;
	tk_messageBox -message "Select 2nd vector";
	lassign [lindex [hm_getplanepanel] 0] vector2 base2;
	lassign $base2 x2 y2 z2;

	# Check #
	if {$vector1 == "" || $vector2 == ""} {
		tk_messageBox -message "User selection does not enough, Stop this script";
		return;
	}

	# Distance and Angle#
	set distance [expr sqrt(pow($x2-$x1,2) + pow($y2-$y1,2) + pow($z2-$z1,2))]
	set angle [format %.3f [::hwat::math::AngleBetweenVectors $vector1 $vector2]];

	::DimensionCompSettings;
	# Line 1 #
	eval *createnode $base1;
	set base1node [hm_latestentityid nodes];
	*createmark nodes 1 $base1node;
	eval *createvector 1 $vector1;
	*linecreatedragnodealongvector nodes 1 1 [expr $distance * 2];
	set line1 [hm_latestentityid lines];

	# Line 2 #
	eval *createnode $base2;
	set base2node [hm_latestentityid nodes];
	*createmark nodes 1 $base2node;
	eval *createvector 1 $vector2;
	*linecreatedragnodealongvector nodes 1 1 [expr $distance * 2];
	set line2 [hm_latestentityid lines];

	# Cross point #
	*createmark lines 1 $line1
	*createmark lines 2 $line2;
	catch {*nodecreateatintersection lines 1 lines 2 0} intersectionflag;

	# Intersection or not #
	if {$intersectionflag == "1"} {							#Two vector was intersected #
		# Intersection node #
		set intersect [hm_latestentityid nodes];

		# Create PLOTEL #
		*createlist nodes 1 $base1node $intersect;
		*createelement 2 1 1 1;
		*createlist nodes 1 $base2node $intersect;
		*createelement 2 1 1 1;

		# Create Tags for node #
		set tagname [::hwat::utils::GetUniqueName tags "VectorAngle=$angle"];
		*tagcreate nodes $intersect $tagname "" 5;

		# For Remove #
		*createmark tags 1 [hm_latestentityid tags];
		*createarray 2 [hm_latestentityid elems 0] [hm_latestentityid elems 1];
		*metadatamarkintarray tags 1 "RelatedElementsWithTag" 1 2;

		# Delete lines and nodes #
		*createmark lines 1 $line1 $line2;
		*deletemark lines 1;
		*createmark nodes 1 $base1node $base2node $intersect;
		*nodemarkcleartempmark 1;
	} elseif {$intersectionflag == "0"} {						#Two vector was not intersected #
		# Select projection plane #
		hm_usermessage "Please select projection plane.";
		tk_messageBox -message "Selected vector does not intersected\nPlease select projection plane.";
		lassign [lindex [hm_getplanepanel] 0] v b;

		# Project #
		*createmark lines 1 $line1 $line2;
		eval *createplane 1 $v $b;
		eval *createvector 1 $v;
		*projectmarktoplane lines 1 1 1 1;

		# Cross point #
		*createmark lines 1 $line1;
		*createmark lines 2 $line2;
		catch {*nodecreateatintersection lines 1 lines 2 0} intersectionflag;
		set intersect [hm_latestentityid nodes];

		# Calc new angle #
		set angle [format %.3f [eval hm_getlinelineangle $line1 $line2 [hm_getvalue nodes id=$intersect dataname=coordinates]]];

		# Create PLOTEL #
		*createlist nodes 1 $base1node $intersect;
		*createelement 2 1 1 1;
		*createlist nodes 1 $base2node $intersect;
		*createelement 2 1 1 1;

		# Create Tags for node #
		set tagname [::hwat::utils::GetUniqueName tags "VectorAngle=$angle"];
		*tagcreate nodes $intersect $tagname "" 5;

		# For Remove #
		*createmark tags 1 [hm_latestentityid tags];
		*createarray 2 [hm_latestentityid elems 0] [hm_latestentityid elems 1];
		*metadatamarkintarray tags 1 "RelatedElementsWithTag" 1 2;

		# Delete lines and nodes #
		*createmark lines 1 $line1 $line2;
		*deletemark lines 1;
		*createmark nodes 1 $base1node $base2node $intersect;
		*nodemarkcleartempmark 1;
	}
}

############################################################
### 3 node angle ###
proc ::3NodeAngle {args} {
	# Select nodes #
	*createlistpanel nodes 1 "Select 3 nodes";
	lassign [hm_getlist nodes 1] n1 n2 n3;

	if {$n1 != "" && $n2 != "" && $n3 != ""} {
		::DimensionCompSettings;
		# Angle #
		set angle [format %.3f [hm_getangle nodes $n1 $n2 $n3]];

		# Create PLOTEL #
		*createlist nodes 1 $n1 $n2;
		*createelement 2 1 1 1;
		*createlist nodes 1 $n2 $n3;
		*createelement 2 1 1 1;

		# Create Tags #
		set tagname [::hwat::utils::GetUniqueName tags "3NodeAngle=$angle"];
		*tagcreate nodes $n2 $tagname "Node$n1\,$n2\,$n3" 5;

		# For Remove #
		*createmark tags 1 [hm_latestentityid tags];
		*createarray 2 [hm_latestentityid elems 0] [hm_latestentityid elems 1];
		*metadatamarkintarray tags 1 "RelatedElementsWithTag" 1 2;
	} else {
		# Error Message #
		tk_messageBox -message "Selected entity does not enough, Please select again";
	}
}

############################################################
######## Remove the PLOTEL with Tags ########
proc ::RemovePlotelWithTag {args} {
	set type [lindex [split [lindex [split $args (] end] ,] 0];
	set mark [string trim [lindex [split [lindex [split $args (] end] ,] end] )];
	if {$type == "tags"} {
		set taglist [hm_getmark tags $mark];
		foreach meta [hm_metadata findbyname "RelatedElementsWithTag"] {
			lassign $meta t tagid dataname datatype elemlist;
			if {$dataname == "RelatedElementsWithTag" && [lsearch $taglist $tagid] != "-1"} {
				eval *createmark elems 1 $elemlist;
				if {[hm_marklength elems 1] >= 1} {
					::hwt::DisableCallbacks;
					*deletemark elems 1;
					::hwt::EnableCallbacks;
				}
			}
		}
		eval *createmark tags $mark $taglist;
		if {[hm_marklength tags $mark] == 0} {
			*createnode 0 0 0 0 0 0;
			*createmark nodes 1 [hm_latestentityid nodes];
			*tagcreatelabelbyid nodes 1 "1" 4;
			*createmark tags $mark [hm_latestentityid tags];
			*createmark nodes 1 [hm_latestentityid nodes];
			*nodemarkcleartempmark 1;
		}
	}
}
::hwt::AddCallback *deletemark ::RemovePlotelWithTag before;

############################################################
######## Remove latest ########
proc ::RemoveLatest {args} {
	set tagid  [hm_latestentityid tags];
	if {$tagid >= "1"} {
		*createmark tags 1 $tagid;
		*deletemark tags 1;
	} else {
		tk_messageBox -message "There is no tags";
	}
}

############################################################
######## Show/Hide PLOTEL with tag ########
proc ::ShowHidePlotelWithTag {args} {
	set mark [lindex [split [lindex [split $args (] end] ,] 0];
	if {[hm_marklength tags $mark] != 0} {
		set taglist [hm_getmark tags $mark];
		foreach meta [hm_metadata findbyname "RelatedElementsWithTag"] {
			lassign $meta t tagid dataname datatype elemlist;
			if {$dataname == "RelatedElementsWithTag" && [lsearch $taglist $tagid] != "-1"} {
				hm_appendmark elems $mark $elemlist;
			}
		}
	}
}
::hwt::AddCallback *hideentitybymark ::ShowHidePlotelWithTag before;
::hwt::AddCallback *showentitybymark ::ShowHidePlotelWithTag before;

############################################################
######## Pulldown menu ########
# Set window names #
set PullDown [hm_framework getpulldowns];
set DimensionPullDown "$PullDown.dimension";
set menulabel "Dimensions";
if {[winfo exist $DimensionPullDown] == "1"} {
	destroy $DimensionPullDown;
	set menuindex [$PullDown index "$menulabel"];
	$PullDown delete $menuindex $menuindex;
}
set UserMenu [menu $DimensionPullDown -tearoff 0];

# Button1 #
$UserMenu add command	-label "Distance: 2 nodes" -command {::Distance2nodes};

# Button2 #
$UserMenu add command	-label "Length: Node list" -command {::LengthOfNodes};

# Separator #
$UserMenu add separator;

# Button3 #
$UserMenu add command	-label "Radius: 3 Nodes" -command {::Radius3nodes};

# Separator #
$UserMenu add separator;

# Button4 #
$UserMenu add command	-label "Angle: 2 Vector" -command {::Vector2angle};

# Button5 #
$UserMenu add command	-label "Angle: 3 Nodes" -command {::3NodeAngle};

# Separator #
$UserMenu add separator;

# Button6 #
$UserMenu add command	-label "Remove latest tag" -command {::RemoveLatest};

# Add to PullDown Menu #
$PullDown insert end cascade -label "$menulabel" -menu $UserMenu -underline 0;
############################################################
