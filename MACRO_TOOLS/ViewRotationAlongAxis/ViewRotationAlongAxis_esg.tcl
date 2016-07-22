############################################################
# Copyright (c) 2016 Altair Engineering Japan.  All Rights #
############################################################
##### View rotation along global axis #####
namespace eval ::view {
    set libDir [ file normalize [ file dirname [ info script ] ] ];
    if { $libDir ni $::auto_path } {
        lappend ::auto_path $libDir;
    }
}

##
# This procedure updates view rotating around the given axis.
# \param[in] angle rotation angle (in degrees)
# \param[in] axis rotation axis
# \param[in] center rotation center (optional)
proc ::view::Rotate { angle axis {center "0 0 0"} } {
    puts "$angle $axis $center"
    
    # degrees to radians
    set angle [ expr { $angle * acos(-1) / 180.0 } ];
    
    set viewmatrix [ hm_winfo viewmatrix ];
    set matrix(view) [ list\
    [ lrange $viewmatrix 0 3 ] [ lrange $viewmatrix 4 7 ]\
    [ lrange $viewmatrix 8 11 ] [ lrange $viewmatrix 12 15 ] ];
    set ortho [ lrange $viewmatrix 16 end ];
    
    # matrix for rotation
    set matrix(rotate) [ ::ajlib::matrix::GetRotationMatrix $angle 4 $axis ];
    
    # matrix for translation
    set org [ list {*}$center 0 ];
    set new [ ::ajlib::matrix::Multiply $matrix(rotate) $org ];
    set trans [ ::ajlib::vector::Subtract $new $org ];
    set trans [ lrange $trans 0 2 ];
    
    set matrix(trans) [ ::ajlib::matrix::GetIdentityMatrix 4 ];
    lset matrix(trans) 3 [ lreplace [ lindex $matrix(trans) 3 ] 0 2 {*}$trans ];
    
    # update view matrix
    set matrix(view) [ ::ajlib::matrix::Multiply $matrix(rotate) $matrix(view) ];
    set matrix(view) [ ::ajlib::matrix::Multiply $matrix(trans) $matrix(view) ];
    *viewset {*}[ concat {*}$matrix(view) $ortho ];
    return -code ok;
}
package require ajlib::matrix;
package require ajlib::vector;


##### for GUI #####
proc ::view::UpdateAxisInfo {AxisDir} {
	variable axis;
	variable origin;
	if {$AxisDir == "Global-X"} {
		set axis "1 0 0";
		set origin "0  0  0";
	} elseif {$AxisDir == "Global-Y"} {
		set axis "0 1 0";
		set origin "0  0  0";
	} elseif {$AxisDir == "Global-Z"} {
		set axis "0 0 1";
		set origin "0  0  0";
	} elseif {$AxisDir == "N1, N2, N3"} {
		set planeres [lindex [hm_getplanepanel] 0];
		set axis [lindex $planeres 0];
		set origin [lindex $planeres 1];
		wm deiconify .viewrotation;
	}
	.viewrotation.label3 configure -text "X=[lindex $origin 0], Y=[lindex $origin 1], Z=[lindex $origin 2]";
}


### Base window ###
proc ::view::ViewRotationAlongAxisGUI {args} {
	set w ".viewrotation";
	set win(w) 320;
	set win(h) 100;
	set win(x) [expr ([hm_winfo graphicx]+[hm_winfo graphicwidth])/2];
	set win(y) [expr ([hm_winfo graphicy]+[hm_winfo graphicheight])/2];
	set row 1;

	toplevel $w;
	wm title $w "View Rotation";
	wm geometry $w $win(w)x$win(h)+$win(x)+$win(y);
	wm resizable $w 1 0;
        wm attributes $w -topmost 1
	set fontsize "10";
	variable selaxis "Global-X";
	variable axis "1 0 0";
	variable origin "0 0 0";
	variable angle [hm_info rotationangle];

	### Axis selection ###
	incr row;
	label $w.label1 -text "Rotate Axis:" -font [AppFont $fontsize];
	set axislist [list "Global-X" "Global-Y" "Global-Z" "N1, N2, N3"];
	ttk::combobox $w.axisdir -textvariable selaxis -values $axislist -font [AppFont $fontsize];;
	grid $w.label1 -row $row -column 0 -sticky w -padx 2 -pady 2;
	grid $w.axisdir -row $row -column 1 -sticky w -padx 2 -pady 2;

	# Bind Axis dir #
	bind $w.axisdir <<ComboboxSelected>> {::view::UpdateAxisInfo $selaxis};

	### Origin ###
	incr row;
	label $w.label2 -text "Origin:" -font [AppFont $fontsize];
	label $w.label3 -text "X=[lindex $origin 0], Y=[lindex $origin 1], Z=[lindex $origin 2]";
	grid $w.label2 -row $row -column 0 -sticky w -padx 2 -pady 2;
	grid $w.label3 -row $row -column 1 -sticky w -padx 2 -pady 2;

	### Angle ###
	incr row;
	label $w.label4 -text "Rotate Angle:" -font [AppFont $fontsize];
	entry $w.angle_box -textvariable ::view::angle -font [AppFont $fontsize] -width 10;
	grid $w.label4 -row $row -column 0 -sticky w -padx 2 -pady 2;
	grid $w.angle_box -row $row -column 1 -sticky w -padx 2 -pady 2;

	### Exec button ###
	incr row;
	button $w.proceed -text " Rotate " -font [AppFont $fontsize] -command {::view::Rotate $::view::angle $::view::axis $::view::origin} -background yellow;
	place $w.proceed -rely 0.7 -relx 0.8;
}
::view::ViewRotationAlongAxisGUI
