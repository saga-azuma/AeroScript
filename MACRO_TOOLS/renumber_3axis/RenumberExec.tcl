#------------------------------------------------------------------------------#
#  Copyright (c) 2011 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.                                            #
#------------------------------------------------------------------------------#
#  System :  HyperMesh Customization                                           #
#                                                                              #
#    Create  : 12/02/24                                                        #
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
set dir_work [file join [hm_info -appinfo CURRENTWORKINGDIR]];
#set tmpfilename ${dir_work}/temp_[ clock second ].hm;
set currentfilename [hm_info currentfile];

#------------------------------------------------------------------------------#
#  Defines namespace & variables                                               #
#------------------------------------------------------------------------------#
namespace eval ::HM_ReNumber_MACRO {
variable DISPLAY_FLAG;
variable MainWin;

variable StID;
variable EntityList;
variable Faxis_val;
variable Saxis_val;
variable ck_data1;
variable SysIDView;
variable EntityType;
variable SortType
variable Et_bk;
}

#------------------------------------------------------------------------------#
#  Sets application font                                                       #
#------------------------------------------------------------------------------#
option add *font			{ {Tahoma} 8 roman }
option add *Dialog.msg.font { {Tahoma} 8 roman }
::hwt::SetAppFont -point 8 Tahoma;


#------------------------------------------------------------------------------#
#  Defines namespace & variables                                               #
#------------------------------------------------------------------------------#
namespace eval ::HM_ReNumber_MACRO {
variable INSTANCE;

}

#------------------------------------------------------------------------------#
#  ::HM_MHI_MACRO_ResultVal::Start                                             #
#------------------------------------------------------------------------------#
#  Summary : This procedure starts the application.                            #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::Start { } {
global MAC_DIR;
variable INSTANCE;

	#-----------------------------#
	#  Checks application window  #
	#-----------------------------#
	if { [info exists INSTANCE] } {
		if { [::HM_ReNumber_MACRO::Exists] } {
			set msg "Can't open the window.";
			::HM_ReNumber_MACRO::MsgBox "Error" $msg;
			return 1;
		}
	}
	set INSTANCE 1;

	#---------------------#
	#  Sets default Font  #
	#---------------------#
	option add *font { {Tahoma} 8 roman }

	#------------------------------#
	#  Sets dynamic rotation mode  #
	#------------------------------#
	*dynamicrotatemode 1;

	#------------------------------#
	#  Creates application window  #
	#------------------------------#
	set res [catch {
		::HM_ReNumber_MACRO::Init;
		::HM_ReNumber_MACRO::MainWindow;
		::HM_ReNumber_MACRO::ManageWindow;
	} err];

	#------------------------#
	#  Checks window status  #
	#------------------------#
	if { $res != 0 } {
		set msg "$err\n$::errorCode\n$::errorInfo";
		::HM_ReNumber_MACRO::MsgBox "Error" $msg;
		set msg "Starting macro program failed.";
		::HM_ReNumber_MACRO::MsgBox "Error" $msg;
		::HM_ReNumber_MACRO::End;
	}
}

#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::End                                               #
#------------------------------------------------------------------------------#
#  Summary : This procedure terminates the application.                        #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::End { } {

	#--------------------------------#
	#  Resets dynamic rotation mode  #
	#--------------------------------#
	*dynamicrotatemode 0;

	#-------------------------------#
	#  Removes callback procedures  #
	#-------------------------------#
#	RemoveCallback *dynamicviewbegin ::HM_ReNumber_MACRO::DynamicViewBegin;
#	RemoveCallback *dynamicviewend ::HM_ReNumber_MACRO::DynamicViewEnd;
	RemoveAllCallbacks *dynamicviewbegin;
	RemoveAllCallbacks *dynamicviewend;

	#--------------------------------#
	#  Destroies application window  #
	#--------------------------------#
	::HM_ReNumber_MACRO::Destroy;

	#---------------------#
	#  Deletes namespace  #
	#---------------------#
	namespace delete ::HM_ReNumber_MACRO;
 }
 
#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::MsgBox                                            #
#------------------------------------------------------------------------------#
#  Summary : This procedure displays the message box.                          #
#                                                                              #
#  Args    : type : message box type(Error/Warning)                            #
#            msg  : message text                                               #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::MsgBox { type msg } {

	#------------------------#
	#  Displays message box  #
	#------------------------#
	if { $type == "Error" } {
		Message msgTheme  "msgErrorTheme"	msgIcon   "error"					\
				msgTitle  "Error"			msgCancel "Ok"						\
				msgText   $msg;
	} elseif { $type == "Warning"} {
		Message msgTheme  "msgWarningTheme"	msgIcon   "warning"					\
				msgTitle  "Warning"			msgCancel "Ok"						\
				msgText   $msg;
	}
return 0
}

#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::MainWindow                                        #
#------------------------------------------------------------------------------#
#  Summary : This procedure creates the main window.                           #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::MainWindow { } {
	variable MainWin;
	variable SysIDView "Global System";
	variable EntityType "nodes";
	variable EntityList "";
	variable StID 1;
	variable Faxis_val 2;
	variable Saxis_val 3;
	variable ck_data1;
#--------------------------#
#  Sets window parameters  #
#--------------------------#
	set MainWin(name)	dia;
	set MainWin(base)	.$MainWin(name);
	set MainWin(width)	320;
	set MainWin(height)	315;
	set MainWin(x)		120;
	set MainWin(y)		180;


#----------------------#
#  Creates top window  #
#----------------------#
	toplevel     $MainWin(base);
	wm title     $MainWin(base) "Renumber the Entities";
	wm geometry  $MainWin(base) $MainWin(width)x$MainWin(height)+$MainWin(x)+$MainWin(y);
	wm resizable $MainWin(base) 0 0;
	wm protocol  $MainWin(base) WM_DELETE_WINDOW ::HM_ReNumber_MACRO::End;
	wm withdraw  $MainWin(base);
	KeepOnTop $MainWin(base);

#---------------------#
#  Creates Top frame  #
#---------------------#

	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fT -height 150 -relief groove -bd 2;
	set top_f $MainWin(base).fT;
	#----- label ---------------------------------------------------------------
	
	label $top_f.lb2 -text "System ID:";
	CanvasButton	$top_f.btnSlt1		55	20								\
							-background #E6E664								\
							-width 8			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::HM_ReNumber_MACRO::Sel_entity_Tool systems";
	
	entry	$top_f.ent1       -width  13                   \
								  -state readonly \
								  -relief groove \
									-textvariable    [namespace current]::SysIDView;
	

	place $top_f.lb2		-relx   0.03 -y  20 -anchor w;
	place $top_f.btnSlt1		-relx   0.23 -y  20 -anchor w;
	place $top_f.ent1		-relx   0.23 -y  45 -anchor w;
	

#-----------------------------*
	label $top_f.lb5 -text "Start with:";
	
	AddEntry	$top_f.ent2       entryWidth  9                   \
									anchor      nw                   \
									validate      integer            \
									textvariable    [namespace current]::StID        \
									withoutPacking;

	place $top_f.lb5		-relx   0.53 -y  20 -anchor w;
	place $top_f.ent2		-relx   0.73 -y  20 -anchor w;

#-----------------------------*
	labelframe $top_f.div -width 164 -height 72 -relief groove -bd 2 -text "Select Entity Type";
	set div_f $top_f.div;
	place $div_f		-relx   0.03 -y  63 -anchor nw;

	label $div_f.lb3 -text "Nodes:";
	label $div_f.lb4 -text "Elements:";

	radiobutton $div_f.rad1 		 -variable [namespace current]::EntityType	\
									 -value nodes;

	radiobutton $div_f.rad2 		 -variable [namespace current]::EntityType	\
									 -value elems;	

	CanvasButton	$div_f.btnSlt2		55	20								\
							-background #E6E664								\
							-width 8			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::HM_ReNumber_MACRO::Sel_entity_Tool $[namespace current]::EntityType";

	place $div_f.btnSlt2		-relx   0.55 -y  37 -anchor w;
	
	place $div_f.lb3	-relx   0.03 -y  12 -anchor w;
	place $div_f.lb4	-relx   0.03 -y  34 -anchor w;
	place $div_f.rad1		-relx   0.38 -y  15 -anchor w;
	place $div_f.rad2		-relx   0.38 -y  37 -anchor w;

#-----------------------#
#  Creates Middle frame #
#-----------------------#
	#----- Frame ---------------------------------------------------------------
	labelframe $MainWin(base).fM -height 120 -relief groove -bd 2 -text " Sort Option ";
	set middle_f $MainWin(base).fM;
	#----- label ---------------------------------------------------------------
#	label $middle_f.lb0 -text "* Sort Option";
#	place $middle_f.lb0	-relx   0.03 -y  15 -anchor w;
#-----------------------------*
	labelframe $middle_f.div1 -width 80 -height 80 -relief groove -bd 2 -text "First Axis";
	set div1_f $middle_f.div1;
	place $div1_f		-relx   0.03 -y  5 -anchor nw;

	radiobutton $div1_f.rad1 		 -variable [namespace current]::Faxis_val	-text ": X-axis"\
									 -value 2 -command ::HM_ReNumber_MACRO::SelAxisOpe;

	radiobutton $div1_f.rad2 		 -variable [namespace current]::Faxis_val	-text ": Y-axis"\
									 -value 3 -command ::HM_ReNumber_MACRO::SelAxisOpe;	

	radiobutton $div1_f.rad3 		 -variable [namespace current]::Faxis_val	-text ": Z-axis"\
									 -value 4 -command ::HM_ReNumber_MACRO::SelAxisOpe;	

	place $div1_f.rad1		-relx   0.03 -y  13 -anchor w;
	place $div1_f.rad2		-relx   0.03 -y  33 -anchor w;
	place $div1_f.rad3		-relx   0.03 -y  53 -anchor w;

#-----------------------------*
	labelframe $middle_f.div2 -width 80 -height 80 -relief groove -bd 2 -text "Second Axis";
	set div2_f $middle_f.div2;
	place $div2_f		-relx   0.33 -y  5 -anchor nw;

	radiobutton $div2_f.rad1 		 -variable [namespace current]::Saxis_val	-text ": X-axis"\
									 -value 2 -state disabled;

	radiobutton $div2_f.rad2 		 -variable [namespace current]::Saxis_val	-text ": Y-axis"\
									 -value 3;	

	radiobutton $div2_f.rad3 		 -variable [namespace current]::Saxis_val	-text ": Z-axis"\
									 -value 4;	

	place $div2_f.rad1		-relx   0.03 -y  13 -anchor w;
	place $div2_f.rad2		-relx   0.03 -y  33 -anchor w;
	place $div2_f.rad3		-relx   0.03 -y  53 -anchor w;

	label $middle_f.lb2 -text "Sort Type:";
	AddEntry	$middle_f.sel1      \
                                    text        "Increasing"            \
                                    labelWidth   12                \
                                    entryWidth   11                 \
                                    listProc                         \
                                    whenPressed "::HM_ReNumber_MACRO::ToggleGender1" \
                                    iconName    small_updownarrow      \
                                    iconLoc     1 4                     \
                                    withoutPacking  asButton;

	place $middle_f.lb2		-relx   0.63 -y  10 -anchor w;
	place $middle_f.sel1		-relx   0.63 -y  32 -anchor w;
#	place $middle_f.lb2		-relx   0.63 -y  53 -anchor w;
#	place $middle_f.sel1		-relx   0.63 -y  78 -anchor w;

	label $middle_f.lb1 -text "Consider the Distance:";
	checkbutton $middle_f.c1		-state normal \
									-variable [namespace current]::ck_data1 ;

	place $middle_f.c1	-relx   0.63 -y  80 -anchor w;
	place $middle_f.lb1	-relx   0.63 -y  59 -anchor w;
#	place $middle_f.c1	-relx   0.63 -y  30 -anchor w;
#	place $middle_f.lb1	-relx   0.63 -y  10 -anchor w;

#------------------------#
#  Creates button frame  #
#------------------------#
	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fB -width 300 -height 40 -relief groove -bd 0;
	set btm_f $MainWin(base).fB;

	#----- Action button -------------------------------------------------------
	CanvasButton	$btm_f.btnCre		60	20								\
							text			"Execute"						\
							-command			{::HM_ReNumber_MACRO::RenumberExec};

	CanvasButton	$btm_f.btnClose		60	20								\
							text			"Close"								\
							command			"::HM_ReNumber_MACRO::End";

	place $btm_f.btnCre -relx 0.0  -rely 0.4 -anchor w;
	place $btm_f.btnClose -relx 1.0  -rely 0.4 -anchor e;
#-----------------#
#  Layouts frame  #
#-----------------#
        pack $top_f -fill x  -padx 5 -pady 3 -anchor nw ;
        pack $middle_f  -fill x  -padx 5 -pady 3 -anchor nw ;
        pack $btm_f -fill y  -padx 10 -pady  0 -side bottom -anchor nw;
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

#------------------------------#
#  Sets HM callback procedure  #
#------------------------------#

		AddCallback *dynamicviewbegin ::HM_ReNumber_MACRO::DynamicViewBegin;
		AddCallback *dynamicviewend   ::HM_ReNumber_MACRO::DynamicViewEnd;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to operate the radio buttons					                   #
#                                                                              #
#	INPUT:	Nothing 														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::SelAxisOpe { args } {
variable MainWin;
variable Faxis_val;
variable Saxis_val;
	switch $Faxis_val {
		2 {
			$MainWin(base).fM.div2.rad1 configure -state disabled;
			$MainWin(base).fM.div2.rad2 configure -state normal;
			$MainWin(base).fM.div2.rad3 configure -state normal;
			if { $Saxis_val == 2 } {set Saxis_val 3;}
		}
		3 {
			$MainWin(base).fM.div2.rad1 configure -state normal;
			$MainWin(base).fM.div2.rad2 configure -state disabled;
			$MainWin(base).fM.div2.rad3 configure -state normal;
			if { $Saxis_val == 3 } {set Saxis_val 2;}
		}
		4 {
			$MainWin(base).fM.div2.rad1 configure -state normal;
			$MainWin(base).fM.div2.rad2 configure -state normal;
			$MainWin(base).fM.div2.rad3 configure -state disabled;
			if { $Saxis_val == 4 } {set Saxis_val 2;}
		}
		
	}
return 0;
}
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to change toggle name	1						                   #
#                                                                              #
#	INPUT:	Nothing 														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::ToggleGender1 { args } {
variable MainWin;
variable SortType;
	
	set curGender [ EntValue $MainWin(base).fM.sel1 ];
	if { $curGender == "Increasing" } {
		EntryInsert $MainWin(base).fM.sel1 "Decreasing";
		set SortType "-decreasing";
		
	} elseif { $curGender == "Decreasing" } {
		EntryInsert $MainWin(base).fM.sel1 "Increasing";
		set SortType "-increasing";
	}

return 0;
}

#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::Exists                                            #
#------------------------------------------------------------------------------#
#  Summary : This procedure checks the existence of the main window.           #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : 0 : not existing                                                  #
#            1 : existing                                                      #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::Exists { } {
variable MainWin;

	#--------------------------#
	#  Checks the main window  #
	#--------------------------#
	if { [winfo exists $MainWin(base)] } { return 1; }

	return 0;

}

#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::Init                                              #
#------------------------------------------------------------------------------#
#  Summary : This procedure initializes the main window.                       #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::Init { } {

	#-------------------------#
	#  Initializes parameter  #
	#-------------------------#
	variable DISPLAY_FLAG       0;
	variable SysIDView "";
	variable ck_data1 0;
	variable Et_bk "";
	variable SortType "-increasing";
}

#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::ManageWindow                                      #
#------------------------------------------------------------------------------#
#  Summary : This procedure opens the main window.                             #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::ManageWindow { } {
variable MainWin;

	#-------------------------#
	#  Opens the main window  #
	#-------------------------#
	wm deiconify $MainWin(base);

}


#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::UnManageWindow                                    #
#------------------------------------------------------------------------------#
#  Summary : This procedure closes the main window.                            #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::UnManageWindow { } {
variable MainWin;

	#--------------------------#
	#  Closes the main window  #
	#--------------------------#
	wm iconify $MainWin(base);

}


#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::Destroy                                           #
#------------------------------------------------------------------------------#
#  Summary : This procedure destroys the main window.                          #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::Destroy { } {
variable MainWin;

	#----------------------------#
	#  Destroys the main window  #
	#----------------------------#
	destroy $MainWin(base);

}
#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::DynamicViewBegin                                  #
#------------------------------------------------------------------------------#
#  Summary : This procedure is HyperMesh's callback function.                  #
#            Closes the main window while the model is rotating.               #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::DynamicViewBegin { args } {
variable DISPLAY_FLAG;

	#------------------------#
	#  Closes macro windows  #
	#------------------------#
	if { $DISPLAY_FLAG == 0 && [wm state $::HM_ReNumber_MACRO::MainWin(base)] != "iconic" } {
		set DISPLAY_FLAG 1;
		catch { wm withdraw $::HM_ReNumber_MACRO::MainWin(base);}
		#catch { wm iconify $::HM_ReNumber_MACRO::MainWin(base); }
	}

}
#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::DynamicViewEnd                                    #
#------------------------------------------------------------------------------#
#  Summary : This procedure is HyperMesh's callback function.                  #
#            Opens the main window when the model's rotation ends.             #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::DynamicViewEnd { args } {
variable DISPLAY_FLAG;

	#-----------------------#
	#  Opens macro windows  #
	#-----------------------#
	if { $DISPLAY_FLAG == 1 } {
		set DISPLAY_FLAG 0;
		catch { wm deiconify $::HM_ReNumber_MACRO::MainWin(base); }
	}
    if { [wm state $::HM_ReNumber_MACRO::MainWin(base)] == "withdraw"  } {
        catch { wm deiconify $::HM_ReNumber_MACRO::MainWin(base); }
    }
}

proc ::HM_ReNumber_MACRO::Display_hide { flg } {
variable MainWin;
variable DISPLAY_FLAG;

     if { $flg == "0" } {
        UnpostWindow $MainWin(base)
        set DISPLAY_FLAG 2;
     } elseif { $flg == "1" } {
       PostWindow $MainWin(base)
       set DISPLAY_FLAG 0;
     }
     *plot
}

#------------------------------------------------------------------------------#
#  ::HM_ReNumber_MACRO::Sel_entity_Tool		                                   #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to select entity												   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::Sel_entity_Tool { entity_name} {
variable MainWin;
variable EntityList;
variable SysIDView;
variable Et_bk;

	set comps_all [hm_entitylist comps name];
	if { $comps_all == "" } {return};
	*clearmark $entity_name 1;
	
	if { [catch {::HM_ReNumber_MACRO::Change_window 1} res ] } {return};

	if { $Et_bk != "" && $Et_bk != $entity_name && $entity_name != "systems" } {
#		puts "del"
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
#	puts "entity_name $entity_name"
	
	## display the panel to select one solid
	
	set entity_ID "";
	set entity_ID [hm_getmark $entity_name 1];
	*clearmark $entity_name 2;

	*clearmark $entity_name 1;
	if { $entity_ID == "" && $entity_name == "systems" } {
		set SysIDView "Global System";
		if { [catch {::HM_ReNumber_MACRO::Change_window 0} res ] } {return};
		return 0;
	} elseif { $entity_ID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "You are not selecting the entity.";
		if { [catch {::HM_ReNumber_MACRO::Change_window 0} res ] } {return};
		return 1;
	} elseif { [llength $entity_ID] > 1 && $entity_name == "systems" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "You can not select more than one System.";
		if { [catch {::HM_ReNumber_MACRO::Change_window 0} res ] } {return};
		return 1;
	}
	
	if { $entity_name == "systems" } {
		set SysIDView $entity_ID;
	} else {
		set EntityList $entity_ID;
		set Et_bk $entity_name;
	}
update;
*plot
	
	if { [catch {::HM_ReNumber_MACRO::Change_window 0} res ] } {return};
return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is Change flame of Window						                   #
#                                                                              #
#	INPUT:	$cg_flg[args] 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::Change_window { cg_flg } {
variable MainWin;


	if { $cg_flg == 0 } {

		$MainWin(base).fT.ent1 configure -state readonly;
		EnableCanvasButton $MainWin(base).fT.btnSlt1;
		EntryState $MainWin(base).fT.ent2  normal;
		
		$MainWin(base).fT.div.rad1 configure -state normal;
		$MainWin(base).fT.div.rad2 configure -state normal;
		EnableCanvasButton $MainWin(base).fT.div.btnSlt2

		$MainWin(base).fM.div1.rad1 configure -state normal;
		$MainWin(base).fM.div1.rad2 configure -state normal;
		$MainWin(base).fM.div1.rad3 configure -state normal;
		
		::HM_ReNumber_MACRO::SelAxisOpe
		
		$MainWin(base).fM.c1 configure -state normal;
		EntryState $MainWin(base).fM.sel1 normal;

		EnableCanvasButton $MainWin(base).fB.btnCre;
		EnableCanvasButton $MainWin(base).fB.btnClose;

	} elseif { $cg_flg == 1 } {
		$MainWin(base).fT.ent1 configure -state disabled;
		DisableCanvasButton $MainWin(base).fT.btnSlt1;
		EntryState $MainWin(base).fT.ent2 disabled;
		
		$MainWin(base).fT.div.rad1 configure -state disabled;
		$MainWin(base).fT.div.rad2 configure -state disabled;
		DisableCanvasButton $MainWin(base).fT.div.btnSlt2
		
		$MainWin(base).fM.div1.rad1 configure -state disabled;
		$MainWin(base).fM.div1.rad2 configure -state disabled;
		$MainWin(base).fM.div1.rad3 configure -state disabled;

		$MainWin(base).fM.div2.rad1 configure -state disabled;
		$MainWin(base).fM.div2.rad2 configure -state disabled;
		$MainWin(base).fM.div2.rad3 configure -state disabled;
		
		$MainWin(base).fM.c1 configure -state disabled;
		EntryState $MainWin(base).fM.sel1 disabled;

		DisableCanvasButton $MainWin(base).fB.btnCre;
		DisableCanvasButton $MainWin(base).fB.btnClose;
	}
update;
}

#--------------------<The following is main program>---------------------------#
#------------------------------------------------------------------------------#
#  ::CustomHM_ViewNode::RenumberExec		                                   #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to renumber entity id in model								   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::HM_ReNumber_MACRO::RenumberExec { } {
variable StID;
variable EntityList;
variable EntityType;
variable SortType;

variable Faxis_val;
variable Saxis_val;
variable ck_data1;
variable SysIDView;


	if { [llength $EntityList] <= 0 } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please select the entity.";
		return 1;
	}
	if { [string is double -strict $StID] == 0 || $StID <= 0 } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "Please enter the right value to the start number.";
		return 1;
	}

	if { $SysIDView == "Global System" } {
		set SysID 0;
	} else {
		set SysID $SysIDView;
	}

	if { $ck_data1 == 0 } {
		set bs $Faxis_val;
		set fs $Saxis_val;
		if { $Faxis_val != 2 && $Saxis_val != 2 } {
			set sc 2;
		} elseif { $Faxis_val != 3 && $Saxis_val != 3 } {
			set sc 3;
		} elseif { $Faxis_val != 4 && $Saxis_val != 4 } {
			set sc 4;
		}
		set td 0;
	} else {
		set bs 1;
		set fs $Faxis_val;
		set sc $Saxis_val;
		if { $Faxis_val != 2 && $Saxis_val != 2 } {
			set td 2;
		} elseif { $Faxis_val != 3 && $Saxis_val != 3 } {
			set td 3;
		} elseif { $Faxis_val != 4 && $Saxis_val != 4 } {
			set td 4;
		}
	}

hm_blockmessages 1;
hm_blockerrormessages 1;
*entityhighlighting 0;

set XYZList "";
set XYZListSorted "";
	foreach i $EntityList {
		set XCoord "";
		set YCoord "";
		set ZCoord "";
		set DisNodes "";
		set interIDflg 0;
		if { $SysID == 0 && $EntityType == "nodes" } {
			set XCoord [format "%.10f" [hm_getentityvalue nodes $i x 0]];
			set YCoord [format "%.10f" [hm_getentityvalue nodes $i y 0]];
			set ZCoord [format "%.10f" [hm_getentityvalue nodes $i z 0]];
		} elseif { $SysID == 0 && $EntityType == "elems" } {
			set XCoord [format "%.10f" [hm_getentityvalue elems $i centerx 0]];
			set YCoord [format "%.10f" [hm_getentityvalue elems $i centery 0]];
			set ZCoord [format "%.10f" [hm_getentityvalue elems $i centerz 0]];
		} else {
			if { $EntityType == "nodes" } {
				set XCoord [format "%.10f" [lindex [hm_xformnodetolocal $i $SysID] 0]];
				set YCoord [format "%.10f" [lindex [hm_xformnodetolocal $i $SysID] 1]];
				set ZCoord [format "%.10f" [lindex [hm_xformnodetolocal $i $SysID] 2]];
			} else {
				set XCoord [format "%.10f" [hm_xpointlocal $SysID [hm_getentityvalue elems $i centerx 0] [hm_getentityvalue elems $i centery 0] [hm_getentityvalue elems $i centerz 0]]];
				set YCoord [format "%.10f" [hm_ypointlocal $SysID [hm_getentityvalue elems $i centerx 0] [hm_getentityvalue elems $i centery 0] [hm_getentityvalue elems $i centerz 0]]];
				set ZCoord [format "%.10f" [hm_zpointlocal $SysID [hm_getentityvalue elems $i centerx 0] [hm_getentityvalue elems $i centery 0] [hm_getentityvalue elems $i centerz 0]]];
			}
		}
		if { $ck_data1 == 0 } {
			set DisNodes 0;
		} else {
			set DisNodes [expr {pow(pow($XCoord,2) + pow($YCoord,2) + pow($ZCoord,2),0.5)}];
		}
		if { $EntityType == "elems" && [llength [hm_getidpoolsforidrange elems $i]] != 0 } {
			set interIDflg 1;
		}
		lappend XYZList "$i $DisNodes $XCoord $YCoord $ZCoord $interIDflg";
	}
	
	set EntityList "";
	set XYZListSort [lsort $SortType -real -index $bs $XYZList];

array unset SortList;
set flg_dis 0;
set flg_fs 0;
set flg_sc 0;

	for {set i 0} {$i < [llength $XYZListSort]} {incr i} {
		if { [lindex [lindex $XYZListSort $i] $bs] == [lindex [lindex $XYZListSort [expr $i + 1]] $bs] && [llength [lindex $XYZListSort [expr $i + 1]]] != 0 } {
			set flg_dis 1;
			lappend SortList($fs) [lindex $XYZListSort $i];
		} elseif { $flg_dis == 1 } {
			lappend SortList($fs) [lindex $XYZListSort $i];
			set SortList($fs) [lsort $SortType -real -index $fs $SortList($fs)];
			
			for {set j 0} {$j < [llength $SortList($fs)]} {incr j} {
				if { [lindex [lindex $SortList($fs) $j] $fs] == [lindex [lindex $SortList($fs) [expr $j + 1]] $fs] && [llength [lindex $SortList($fs) [expr $j + 1]]] != 0 } {
					lappend SortList($sc) [lindex $SortList($fs) $j];
					set flg_fs 1;
				} elseif { $flg_fs == 1 } {
					lappend SortList($sc) [lindex $SortList($fs) $j];
					set SortList($sc) [lsort $SortType -real -index $sc $SortList($sc)];
					
					for {set k 0} {$k < [llength $SortList($sc)]} {incr k} {
						if { [lindex [lindex $SortList($sc) $k] $sc] == [lindex [lindex $SortList($sc) [expr $k + 1]] $sc] && [llength [lindex $SortList($sc) [expr $k + 1]]] != 0 } {
							lappend SortList($td) [lindex $SortList($sc) $k];
							set flg_sc 1;
						} elseif { $flg_sc == 1 } {
							lappend SortList($td) [lindex $SortList($sc) $k];
							set SortList($td) [lsort $SortType -real -index $td $SortList($td)];
							foreach m $SortList($td) {
								lappend XYZListSorted $m;
							}
							set flg_sc 0;
							array unset SortList $td;
						} elseif { $flg_sc == 0 } {
							lappend XYZListSorted [lindex $SortList($sc) $k];
						}
					}
					
					set flg_fs 0;
					array unset SortList $sc;
				} elseif { $flg_fs == 0 } {
					lappend XYZListSorted [lindex $SortList($fs) $j];
				}
			}
			
			array unset SortList;
			set flg_dis 0;
		} elseif { $flg_dis == 0 } {
			lappend XYZListSorted [lindex $XYZListSort $i];
			set flg_dis 0;
		}
	}
	
	set MaxchgID "";
	set EtMaxID [expr {[hm_entitymaxid $EntityType] + 1}];

	foreach i $XYZListSorted {
		*createmark $EntityType 1 [lindex $i 0];
		*renumbersolverid $EntityType 1 $EtMaxID 1 0 0 0 0 0;
		*clearmark $EntityType 1;
		if { $EntityType == "elems" && [lindex $i 5] == 1 } {
			lappend MaxchgID [lindex $i 0];
		} else {
			lappend MaxchgID $EtMaxID;
		}
		incr EtMaxID;
	}

	foreach i $MaxchgID {
		*createmark $EntityType 1 $i;
		*renumbersolverid $EntityType 1 $StID 1 0 0 0 0 0;
		*clearmark $EntityType 1;
	}

hm_blockmessages 0;
hm_blockerrormessages 0;
*entityhighlighting 1;
return 0;
}
::HM_ReNumber_MACRO::Start;
