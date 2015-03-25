#------------------------------------------------------------------------------#
#  Copyright (c) 2012 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.                                            #
#------------------------------------------------------------------------------#
#    System :  HyperMesh Customization                                         #
#                                                                              #
#    Create  : 2012/03/19                                                      #
#    Edit    :                                                                 #
#                                                                              #
#    Version   : HyperMesh10.0                                                 #
#              : HyperMesh11.0                                                 #
#------------------------------------------------------------------------------#

package require hwt;

#------------------------------------------------------------------------------#
#  Sets global variables                                                       #
#------------------------------------------------------------------------------#
set MAC_DIR [ file dirname [ info script ] ];
global ary_Ntabe "";

#------------------------------------------------------------------------------#
#  Sets application font                                                       #
#------------------------------------------------------------------------------#
option add *font			{ {Tahoma} 8 roman }
option add *Dialog.msg.font { {Tahoma} 8 roman }
::hwt::SetAppFont -point 8 Tahoma;


#------------------------------------------------------------------------------#
#  Defines namespace & variables                                               #
#------------------------------------------------------------------------------#
namespace eval ::CustomHM_ViewNode {
variable INSTANCE;
variable DISPLAY_FLAG;
variable MainWin;
variable Exp_path "";

variable num_flg
variable Et_bk "";
variable PrecVal;
variable ListTb_flg_sub 0;

variable SubLabelList "";
variable SysIDView;
variable EntityType;
variable EntityList "";
variable EntityList2 "";
variable dir_work [hm_info -appinfo CURRENTWORKINGDIR];
}

#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::Start                                                    #
#------------------------------------------------------------------------------#
#  Summary : This procedure starts the application.                            #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::Start { } {
global MAC_DIR;
variable INSTANCE;
	
	#----------------------#
	#  Loads program file  #
	#----------------------#
#	source "${MAC_DIR}/GUIMain.tcl";
#	source "${MAC_DIR}/sample.tcl";

	#-----------------------------#
	#  Checks application window  #
	#-----------------------------#
	if { [info exists INSTANCE] } {
		if { [::CustomHM_ViewNode::Exists] } {
			set msg "Can't open the window.";
			::CustomHM_ViewNode::MsgBox "Error" $msg;
			return 1;
		}
	}
	set INSTANCE 1;

	#---------------------#
	#  Sets default Font  #
	#---------------------#
	option add *font { {Tahoma} 8 roman }

	
	#------------------------------#
	#  Creates application window  #
	#------------------------------#
	set res [catch {
		::CustomHM_ViewNode::MainWindow;
		::CustomHM_ViewNode::ManageWindow;
	} err];

	#------------------------#
	#  Checks window status  #
	#------------------------#
	if { $res != 0 } {
		set msg "$err\n$::errorCode\n$::errorInfo";
		::CustomHM_ViewNode::MsgBox "Error" $msg;
		set msg "Starting macro program failed.";
		::CustomHM_ViewNode::MsgBox "Error" $msg;
		::CustomHM_ViewNode::End;
	}
}

#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::End                                                      #
#------------------------------------------------------------------------------#
#  Summary : This procedure terminates the application.                        #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::End { } {
	
	#---------------------#
	#  Save Input Value   #
	#---------------------#
	::CustomHM_ViewNode::SAVECFG

	#--------------------------------#
	#  Destroies application window  #
	#--------------------------------#
	::CustomHM_ViewNode::Destroy;

	#---------------------#
	#  Deletes namespace  #
	#---------------------#
	namespace delete ::CustomHM_ViewNode;
 }
 
#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::MsgBox                                                   #
#------------------------------------------------------------------------------#
#  Summary : This procedure displays the message box.                          #
#                                                                              #
#  Args    : type : message box type(Error/Warning)                            #
#            msg  : message text                                               #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::MsgBox { type msg } {

	#------------------------#
	#  Displays message box  #
	#------------------------#
	if { $type == "Error" } {
		tk_messageBox 	-icon  "error"					\
				-title  "Error"			-type ok		\
				-message  $msg;
	} elseif { $type == "Warning"} {
		tk_messageBox 	-icon  "warning"					\
				-title  "Warning"			-type ok		\
				-message  $msg;
	}

}

#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::MainWindow                                               #
#------------------------------------------------------------------------------#
#  Summary : This procedure creates the main window.                           #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::MainWindow { } {
global ary_Ntabe;

variable MainWin;
variable num_flg "Fnum";
variable PrecVal;
variable SubLabelList;
variable SysIDView "Global System";
variable EntityType "nodes";
variable EntityList2;
	
#--------------------------#
#  Sets window parameters  #
#--------------------------#
	set MainWin(name)	eview;
	set MainWin(base)	.$MainWin(name);
	set MainWin(width)	475;
	set MainWin(height)	440;
	set MainWin(x)		120;
	set MainWin(y)		180;


#----------------------#
#  Creates top window  #
#----------------------#
	toplevel     $MainWin(base);
	wm title     $MainWin(base) "Display the coordinates of entities";
	wm geometry  $MainWin(base) $MainWin(width)x$MainWin(height)+$MainWin(x)+$MainWin(y);
	wm resizable $MainWin(base) 0 0;
	wm protocol  $MainWin(base) WM_DELETE_WINDOW ::CustomHM_ViewNode::End;
	wm withdraw  $MainWin(base);
	wm attributes $MainWin(base) -topmost 1;

#---------------------#
#  Load Input Value   #
#---------------------#
	::CustomHM_ViewNode::OPENCFG

#---------------------#
#  Creates Top frame  #
#---------------------#

	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fT -height 400 -relief groove -bd 2;
	set top_f $MainWin(base).fT;
	#----- label ---------------------------------------------------------------
	labelframe $top_f.div -width 77 -height 72 -relief groove -bd 2 -text "Entity Type";
	set div_f $top_f.div;
	place $div_f		-relx   0.01 -y  5 -anchor nw;

	label $div_f.lb3 -text "Nodes:";
	label $div_f.lb4 -text "Elements:";

	radiobutton $div_f.rad1 		 -variable [namespace current]::EntityType	\
									 -value nodes;

	radiobutton $div_f.rad2 		 -variable [namespace current]::EntityType	\
									 -value elems;	

	place $div_f.lb3	-relx   0.03 -y  12 -anchor w;
	place $div_f.lb4	-relx   0.03 -y  34 -anchor w;
	place $div_f.rad1		-relx   0.68 -y  15 -anchor w;
	place $div_f.rad2		-relx   0.68 -y  37 -anchor w;

#--------
	label $top_f.elb1 -text "Entity ID:";
	CanvasButton	$top_f.btnSlt0		55	20								\
							-background #E6E664								\
							-width 8			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHM_ViewNode::Sel_entity_Tool $[namespace current]::EntityType";

	place $top_f.elb1		-relx   0.22 -y  25 -anchor w;
	place $top_f.btnSlt0		-relx   0.35 -y  25 -anchor w;
#--------
	label $top_f.elb2 -text "Entity List:";
	entry	$top_f.ent0       -width  38  \
								  -state normal \
								  -relief groove \
									-textvariable    [namespace current]::EntityList2;
	button	$top_f.btviw	-width  6								\
							-text			"View"						\
							-command			{::CustomHM_ViewNode::main $::CustomHM_ViewNode::EntityList2;};

	place $top_f.elb2		-relx   0.22 -y  55 -anchor w;
	place $top_f.ent0		-relx   0.35 -y  55 -anchor w;
	place $top_f.btviw		-relx   0.87 -y  55 -anchor w;
#--------
	label $top_f.syslb1 -text "System ID:";
	CanvasButton	$top_f.btnSlt1		55	20								\
							-background #E6E664								\
							-width 8			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHM_ViewNode::Sel_entity_Tool systems";
	
	entry	$top_f.sysent1       -width  12                   \
								  -state readonly \
								  -relief groove \
									-textvariable    [namespace current]::SysIDView;
	
	place $top_f.syslb1		-relx   0.53 -y  25 -anchor w;
	place $top_f.btnSlt1		-relx   0.66 -y  25 -anchor w;
	place $top_f.sysent1		-relx   0.8 -y  25 -anchor w;

#-----------------------------------------------------------------
	set sepa1 [add_sepalator $top_f h top 440];

	labelframe $top_f.div2 -width 220 -height 40 -relief groove -bd 2 -text "The way of figure output";
	set div2_f $top_f.div2;
	
	radiobutton $div2_f.rad1 		 -variable [namespace current]::num_flg	\
									 -text "Fixed"\
									 -value Fnum ;
	radiobutton $div2_f.rad2 		 -variable [namespace current]::num_flg	\
									 -text "Scientific"\
									 -value Inum ;
	place $div2_f.rad1		-relx   0.03 -y  10 -anchor w;
	place $div2_f.rad2		-relx   0.55 -y  10 -anchor w;

#--------
	set PrecVal 6;
	label $top_f.lb3 -text "Precision:";
	spinbox $top_f.sp1 -from 0 -to 10 -increment 1 -width 5 -state readonly -textvariable [namespace current]::PrecVal

#--------
	place $sepa1	-relx   0.02 -y  86 -anchor w;
	place $div2_f		-relx   0.5 -y  95 -anchor nw;
	place $top_f.lb3	-relx   0.02 -y  105 -anchor w;
	place $top_f.sp1	-relx   0.14 -y  105 -anchor w;

#--------
	label $top_f.lb2 -text "The coordinates list of entities:";
	::CustomHM_ViewNode::CreListTable_sub $SubLabelList;

	place $top_f.lb2	-relx   0.01 -y  135 -anchor w;

#-----------------------------------------------------------------
	label $top_f.lb1 -text "Output File:";

	entry	$top_f.ent1       -width  44                   \
									-textvariable    [namespace current]::Exp_path;
	button	$top_f.selph1								\
							-text			"..."								\
							-command			"::CustomHM_ViewNode::SEL_CSV 2";
	button	$top_f.btexp	-width  10								\
							-text			"Export"						\
							-command			{::CustomHM_ViewNode::export};

	place $top_f.lb1	-relx   0.01 -y  375 -anchor w;
	place $top_f.ent1		-relx   0.15 -y  375 -anchor w;
	place $top_f.selph1		-relx   0.75 -y  375 -anchor w;
	
	place $top_f.btexp	-relx   0.83 -y  375 -anchor w;


#------------------------#
#  Creates button frame  #
#------------------------#
	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fB  -height 30 -relief groove -bd 0;
	set btm_f $MainWin(base).fB;

	#----- Action button -------------------------------------------------------
	button	$btm_f.btnClose	 -width  77 -bg skyblue								\
							-text			"CLOSE"								\
							-command			"::CustomHM_ViewNode::End";

	place $btm_f.btnClose -relx 1.0  -rely 0.3 -anchor e;

#-----------------#
#  Layouts frame  #
#-----------------#
        pack $top_f -fill x  -padx 5 -pady 3 -anchor nw ;
        pack $btm_f -fill y -fill x -padx 5 -pady  0 -side bottom -anchor nw;

#--------------------#
#  move end of path  #
#--------------------#
	if { ${::CustomHM_ViewNode::Exp_path} != "" } {
		$MainWin(base).fT.ent1 xview moveto 1.0;
		$MainWin(base).fT.ent1 icursor end;
		 focus $MainWin(base).fT.ent1;
	} 

#---------------------#
#  Binds mouse event  #
#---------------------#

	foreach frm [winfo children $MainWin(base)] {
		foreach widget [winfo children $frm] {
			if { [winfo class $widget] == "Canvas"} {
				bind	 $widget <Double-1> "";
				bind	 $widget <Button-3> "";
				bindtags $widget "Canvas $widget $MainWin(base) all";
			}
		}
	}
return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to create the table of coords of entity list	                   #
#                                                                              #
#	INPUT:	coords list														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::CreListTable_sub { Datalist } {
global ary_Ntabe;

variable MainWin;
variable ListTb_flg_sub;

array unset ary_Ntabe

	if { [llength $Datalist] >= 10 } {
		set rowNum [expr [llength $Datalist] + 1];
	} else {
		set rowNum 11;
	}

	if {$ListTb_flg_sub == 1} {
		destroy $MainWin(base).fT.tb1;
	}
	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fT.tb1 -bd 2 -relief ridge;
	set top_f_tb1 $MainWin(base).fT.tb1;
	#----- Edit ---------------------------------------------------------------
	# Create Table
	table $top_f_tb1.t -variable ary_Ntabe -rows $rowNum -cols 5 \
	    -colstretchmode unset -rowstretchmode unset \
	    -multiline 0 -selectmode extended \
	    -state disabled \
	    -bg white \
	    -anchor w \
	    -maxheight 188 -maxwidth 460 \
	    -titlerows 1 -titlecols 0 -selecttitle 1 \
	    -yscrollcommand {.eview.fT.tb1.y set} \
	    -xscrollcommand {.eview.fT.tb1.x set};    
	scrollbar $top_f_tb1.y -orient vertical -command {.eview.fT.tb1.t yview};
	scrollbar $top_f_tb1.x -orient horizontal -command {.eview.fT.tb1.t xview};

	pack $top_f_tb1.x -fill x -side bottom;
	pack $top_f_tb1.y -fill y -side right;
	pack $top_f_tb1.t -fill y -side left;

	
	# Create title
	set ary_Ntabe(0,0) "EntityID"
	set ary_Ntabe(0,1) "X-Axis"
	set ary_Ntabe(0,2) "Y-Axis"
	set ary_Ntabe(0,3) "Z-Axis"
	set ary_Ntabe(0,4) "SysID"
	
	$top_f_tb1.t tag config title -anchor c
	$top_f_tb1.t tag config title -relief groove -bg #3366cc

	for {set i 1} {$i<=[expr [$top_f_tb1.t cget -rows]-1]} {incr i} {
		if { [llength $Datalist] >= $i } {
			for {set j 0} {$j <= 4} {incr j} {
		    	set ary_Ntabe($i,$j) [lindex [lindex $Datalist [expr $i - 1]] $j];
		    	if { [lindex [lindex $Datalist [expr $i - 1]] $j] < 0 } {
		    		$top_f_tb1.t tag cell cel${i}${j} $i,$j
		    		$top_f_tb1.t tag configure cel${i}${j} -fg red;
		    	}
		   	}
		    
	    } else {
	    	break;
	    }
	}

	$top_f_tb1.t tag col col1 0
	$top_f_tb1.t tag configure col1 -anc c -fg blue;
	$top_f_tb1.t tag configure sel    -fg black -bg #99ccff

	# set size of col
	$top_f_tb1.t width 0 10 1 18 2 18 3 18 4 6

	set ListTb_flg_sub 1;
	place $top_f_tb1		-relx   0.0 -y  250 -anchor w;
return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::Sel_entity_Tool               		                   #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to select entity												   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::Sel_entity_Tool { entity_name} {
variable MainWin;
variable EntityList;
variable SysIDView;
variable Et_bk;

	set comps_all [hm_entitylist comps name];
	if { $comps_all == "" } {return};
	*clearmark $entity_name 1;
	
	if { [catch {::CustomHM_ViewNode::Change_window 1} res ] } {return};

	if { $Et_bk != "" && $Et_bk != $entity_name && $entity_name != "systems" } {
		set EntityList "";
	}

	if { $EntityList != "" && $entity_name != "systems" } {
		eval *createmark $entity_name 1 $EntityList;
		*editmarkpanel $entity_name 1 "Please select the one entity"
#		hm_highlightmark $entity_name 2 h;
#		set EntityList "";
	} else {
		*createmarkpanel $entity_name 1 "Please select the one entity"
	}
	
	## display the panel to select one solid
	
	set entity_ID "";
	set entity_ID [hm_getmark $entity_name 1];
	*clearmark $entity_name 2;

	*clearmark $entity_name 1;
	if { $entity_ID == "" && $entity_name == "systems" } {
		set SysIDView "Global System";
		if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return};
		return 0;
	} elseif { $entity_ID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "You are not selecting the entity.";
		if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return};
		return 1;
	} elseif { [llength $entity_ID] > 1 && $entity_name == "systems" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "You can not select more than one System.";
		if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return};
		return 1;
	}
	
	if { $entity_name == "systems" } {
		set SysIDView $entity_ID;
	} else {
		set EntityList $entity_ID;
		set Et_bk $entity_name;
		::CustomHM_ViewNode::main $EntityList;
	}
update;
*plot
	
	if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return};
return 0;
}
#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::Exists                                                 #
#------------------------------------------------------------------------------#
#  Summary : This procedure checks the existence of the main window.           #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : 0 : not existing                                                  #
#            1 : existing                                                      #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::Exists { } {
variable MainWin;

	#--------------------------#
	#  Checks the main window  #
	#--------------------------#
	if { [winfo exists .eview] } { return 1; }

return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::Init                                                   #
#------------------------------------------------------------------------------#
#  Summary : This procedure initializes the main window.                       #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::Init { } {

	#-------------------------#
	#  Initializes parameter  #
	#-------------------------#
	variable DISPLAY_FLAG       0;
	variable Exp_path "";
	variable Et_bk "";
	

}

#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::ManageWindow                                           #
#------------------------------------------------------------------------------#
#  Summary : This procedure opens the main window.                             #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::ManageWindow { } {
variable MainWin;

	#-------------------------#
	#  Opens the main window  #
	#-------------------------#
	wm deiconify $MainWin(base);

}


#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::UnManageWindow                                         #
#------------------------------------------------------------------------------#
#  Summary : This procedure closes the main window.                            #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::UnManageWindow { } {
variable MainWin;

	#--------------------------#
	#  Closes the main window  #
	#--------------------------#
	wm iconify $MainWin(base);

}


#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::Destroy                                                #
#------------------------------------------------------------------------------#
#  Summary : This procedure destroys the main window.                          #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::Destroy { } {
variable MainWin;

	#----------------------------#
	#  Destroys the main window  #
	#----------------------------#
	destroy $MainWin(base);

}


#------------------------------------------------------------------------------#
#                                                                              #
# Function is Change flame of Window						                   #
#                                                                              #
#	INPUT:	$cg_flg[args] 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::Change_window { cg_flg } {
variable MainWin;

	if { $cg_flg == 0 } {
		$MainWin(base).fT.div.rad1 configure -state normal;
		$MainWin(base).fT.div.rad2 configure -state normal;
		EnableCanvasButton $MainWin(base).fT.btnSlt0;
		$MainWin(base).fT.ent0 configure -state normal;
		$MainWin(base).fT.btviw configure -state normal;
		EnableCanvasButton $MainWin(base).fT.btnSlt1;
		$MainWin(base).fT.sysent1 configure -state readonly;
		$MainWin(base).fT.div2.rad1 configure -state normal;
		$MainWin(base).fT.div2.rad2 configure -state normal;
		$MainWin(base).fT.sp1 configure -state readonly;
		$MainWin(base).fT.ent1 configure -state normal;
		$MainWin(base).fT.selph1 configure -state normal;
		$MainWin(base).fT.btexp configure -state normal;
		$MainWin(base).fB.btnClose configure -state normal;
		
	} elseif { $cg_flg == 1 } {
		$MainWin(base).fT.div.rad1 configure -state disabled;
		$MainWin(base).fT.div.rad2 configure -state disabled;
		DisableCanvasButton $MainWin(base).fT.btnSlt0;
		$MainWin(base).fT.ent0 configure -state disabled;
		$MainWin(base).fT.btviw configure -state disabled;
		DisableCanvasButton $MainWin(base).fT.btnSlt1;
		$MainWin(base).fT.sysent1 configure -state disabled;
		$MainWin(base).fT.div2.rad1 configure -state disabled;
		$MainWin(base).fT.div2.rad2 configure -state disabled;
		$MainWin(base).fT.sp1 configure -state disabled;
		$MainWin(base).fT.ent1 configure -state disabled;
		$MainWin(base).fT.selph1 configure -state disabled;
		$MainWin(base).fT.btexp configure -state disabled;
		$MainWin(base).fB.btnClose configure -state disabled;

	}
update;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to open & save File Select Dialog for CSV_FILE                   #
#                                                                              #
#	INPUT:	Nothing		 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::SEL_CSV { flg } {
variable MainWin;
variable Exp_path;
variable dir_work

	if { [catch {::CustomHM_ViewNode::Change_window 1} res ] } {return 1};
	set CSV_FILE "";
	if { $flg == 1 } {
		set CSV_FILE $Imp_path;
	} else {
		set CSV_FILE $Exp_path;
	}

    set x [expr [winfo screenwidth  .] / 2 - 250]
    set y [expr [winfo screenheight .] / 2 - 100]

    set ftype {
        {"CSV Files"  {*.csv}  }
        {"All Files" {*.*} }
    }
    
    if { $CSV_FILE == "" } {
        set initdir "";
    } else {
        if { [file isfile $CSV_FILE] == 1 } {
            set initdir [file dirname $CSV_FILE];
        } elseif { [file isdirectory $CSV_FILE] == 1 } {
            set initdir $CSV_FILE;
        } else {
            set initdir "$dir_work";
        }
    }
	if { $flg == 1 } {
	    set fname [tk_getOpenFile -filetypes $ftype                  \
	                              -parent $MainWin(base)             \
	                              -x $x                              \
	                              -y $y                              \
	                              -initialdir $initdir               \
	                              -title "Select Coord Info CSV File" ];
	} else {
	    set fname [tk_getSaveFile -filetypes $ftype                  \
	                              -parent $MainWin(base)             \
	                              -x $x                              \
	                              -y $y                              \
	                              -initialdir $initdir               \
	                              -defaultextension "csv"            \
	                              -title "Output CSV File" ];
    }
    if {$fname == ""} {
    	if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return 1};
        return
    }
    
	if { $flg == 2 } {
		set Exp_path $fname;
		$MainWin(base).fT.ent1 xview moveto 1.0;
		$MainWin(base).fT.ent1 icursor end;
		 focus $MainWin(base).fT.ent1;
	}
	if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return 1};
return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is Save into config file							                   #
#                                                                              #
#	INPUT:	Nothing		 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::SAVECFG { args } {
variable Exp_path;
variable dir_work

    set dirfile [file join "${dir_work}/_panel_input_hmDispCoord.cfg"];

	if { [file isdirectory ${::CustomHM_ViewNode::Exp_path}] == 0 || [file extension ${::CustomHM_ViewNode::Exp_path}] != "" } {
		set ::CustomHM_ViewNode::Exp_path [file dirname ${::CustomHM_ViewNode::Exp_path}];
	}
	
    if {([file exists $dirfile] == 1 && [file writable $dirfile] == 1) || [file exists $dirfile] == 0} {
        set fout [open $dirfile w];
        puts $fout ${::CustomHM_ViewNode::Exp_path};
        close $fout;
    }

}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is Open config file								                   #
#                                                                              #
#	INPUT:	Nothing		 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::OPENCFG { args } {
variable Exp_path;
variable dir_work

    set dirfile [file join "${dir_work}/_panel_input_hmDispCoord.cfg"];
	if {[file readable $dirfile] == 1} {
	    set fin [open $dirfile r];
	    set [namespace current]::Exp_path [gets $fin];
	    close $fin;

	    if { [file isdirectory ${::CustomHM_ViewNode::Exp_path}] == 0 || ${::CustomHM_ViewNode::Exp_path} == "." } {
	    	set [namespace current]::Exp_path "";
	    }
	}
}

#----------------------------------------------------------------------------------#
# add_sepalator                                                                    #
# add frame as a separator on parent widget                                        #
#                                                                                  #
# parameters                                                                       #
# parent  : parent widget                                                          #
# dir     : direction either (v:vertical, h:horizontal)                            #
# sideDir : directon for -side parameter (top, bottom, side, left)                 #
# length  : border length (v:height, h:width)                                      #
#----------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::add_sepalator { parent dir sideDir length } {
	# existance check
	for { set i 0 } { [ winfo exists $parent.sep$i ] == 1 } { incr i } {

	}
	
	if { $dir == "v" } {
		frame $parent.sep$i -width 2 -height $length -borderwidth 1 -relief sunken;
#		pack $parent.sep$i -side $sideDir -fill y -padx 2;
	} elseif { $dir == "h" } {
		frame $parent.sep$i -width $length -height 2 -borderwidth 1 -relief sunken;
#		pack $parent.sep$i -side $sideDir -fill x -padx 2;
	} else {
#		puts "ERROR : ::HV_MHI_MACRO::add_sepalator invalid direction parameter $dir";
	}
return $parent.sep$i;
}


#--------------------<The following is main program>---------------------------#
#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::main				                                   #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to get and display the coordinates of entities				   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::main { EntityList } {
variable num_flg;
variable PrecVal;
variable SubLabelList "";
variable SysIDView;
variable EntityType;
set EchkList "";

	if { $EntityList == "" } {
		catch {::CustomHM_ViewNode::CreListTable_sub ""} res;
		return 0;
	}
	if { [catch {::CustomHM_ViewNode::Change_window 1} res ] } {return 1};
hm_blockmessages 1;
hm_blockerrormessages 1;
*entityhighlighting 0;
	set EntityList [string trim [string map { "," " " } $EntityList]];
	eval *createmark $EntityType 1 $EntityList;
	set EchkList [hm_getmark $EntityType 1];
	
	if { $EchkList == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "There is no the entity ID in model.";
		catch {::CustomHM_ViewNode::CreListTable_sub ""} res;
		if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return 1};
		hm_blockmessages 0;
		hm_blockerrormessages 0;
		*entityhighlighting 1;
		return 0;
	}

	if { $SysIDView == "Global System" } {
		set SysID 0;
	} else {
		set SysID $SysIDView;
	}
	
	if { $num_flg == "Fnum" } {
		set ftype "%.${PrecVal}f"
	} elseif { $num_flg == "Inum" } {
		set ftype "%.${PrecVal}e"
	} else {
		set ftype "%.${PrecVal}g"
	}
	
	foreach i $EntityList {
		if { [lsearch -exact -real $EchkList $i] != -1 } {
			set XCoord "";
			set YCoord "";
			set ZCoord "";
			if { $SysID == 0 && $EntityType == "nodes" } {
				set XCoord [format $ftype [hm_getentityvalue nodes $i x 0]];
				set YCoord [format $ftype [hm_getentityvalue nodes $i y 0]];
				set ZCoord [format $ftype [hm_getentityvalue nodes $i z 0]];
			} elseif { $SysID == 0 && $EntityType == "elems" } {
				set XCoord [format $ftype [hm_getentityvalue elems $i centerx 0]];
				set YCoord [format $ftype [hm_getentityvalue elems $i centery 0]];
				set ZCoord [format $ftype [hm_getentityvalue elems $i centerz 0]];
			} else {
				if { $EntityType == "nodes" } {
					set XCoord [format $ftype [lindex [hm_xformnodetolocal $i $SysID] 0]];
					set YCoord [format $ftype [lindex [hm_xformnodetolocal $i $SysID] 1]];
					set ZCoord [format $ftype [lindex [hm_xformnodetolocal $i $SysID] 2]];
				} else {
					set XCoord [format $ftype [hm_xpointlocal $SysID [hm_getentityvalue elems $i centerx 0] [hm_getentityvalue elems $i centery 0] [hm_getentityvalue elems $i centerz 0]]];
					set YCoord [format $ftype [hm_ypointlocal $SysID [hm_getentityvalue elems $i centerx 0] [hm_getentityvalue elems $i centery 0] [hm_getentityvalue elems $i centerz 0]]];
					set ZCoord [format $ftype [hm_zpointlocal $SysID [hm_getentityvalue elems $i centerx 0] [hm_getentityvalue elems $i centery 0] [hm_getentityvalue elems $i centerz 0]]];
				}
			}
			lappend SubLabelList "$i $XCoord $YCoord $ZCoord $SysID";
		}
	}
	catch {::CustomHM_ViewNode::CreListTable_sub $SubLabelList} res;
	if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return 1};
hm_blockmessages 0;
hm_blockerrormessages 0;
*entityhighlighting 1;
return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::export				                                   #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to export the list of the entities coordinates				   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHM_ViewNode::export { args } {
global ary_Ntabe;
variable MainWin;
variable Exp_path;
variable EntityType;
set CSVList "";

set len_ary [expr (([llength [array name ary_Ntabe]] - 1) / 5) - 1];
	if { $Exp_path == "" || [file isdirectory [file dirname $Exp_path]] == 0 || [file isdirectory $Exp_path] == 1 } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please enter the file path.";
		return 1;
	}
	if { [catch {::CustomHM_ViewNode::Change_window 1} res ] } {return 1};
	
	if { $len_ary >= 1 } {
		if { $EntityType == "nodes" } {
			set CSVList "NodeID,X-Axis,Y-Axis,Z-Axis,SystemID";
		} else {
			set CSVList "ElementID,X-Axis,Y-Axis,Z-Axis,SystemID";
		}
	}
	for {set i 1} {$i <= $len_ary} {incr i} {
		append CSVList "\n$ary_Ntabe($i,0),$ary_Ntabe($i,1),$ary_Ntabe($i,2),$ary_Ntabe($i,3),$ary_Ntabe($i,4)"
	}
	
	if {([file exists $Exp_path] == 1 && [file writable $Exp_path] == 1) || [file exists $Exp_path] == 0} {
		set fout [open $Exp_path w];
		puts $fout $CSVList;
		close $fout;
	}
	
	if { [catch {::CustomHM_ViewNode::Change_window 0} res ] } {return 1};
return 0;
}
::CustomHM_ViewNode::Start;
