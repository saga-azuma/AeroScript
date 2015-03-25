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
package require Tktable;
global ary "";

#------------------------------------------------------------------------------#
#  Defines namespace & variables                                               #
#------------------------------------------------------------------------------#
namespace eval ::CustomHB {
variable DISPLAY_FLAG;
variable MainWin;
variable surfID;
variable nodeID;
variable nodeID_end;
variable Line_num;
variable line_len;
variable node_ID;
variable surf_ID;
variable nodeB_ID;
variable line_ID;
variable line_ID_rec;

variable node_flg;

variable MatName;
variable MatNameList;

variable select_bt1;
variable select_bt2;
variable select_bt3;
variable select_bt4;
variable CkVal;
variable Datalist "";
variable ListTable_flg 0;
variable rej_flg 0;
}


#------------------------------------------------------------------------------#
#  ::CustomHB::MainWindow                                                      #
#------------------------------------------------------------------------------#
#  Summary : This procedure creates the main window.                           #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::MainWindow { } {
global ary
	variable MainWin;
	variable Line_num;
	variable line_len;
	variable elem_size;

	variable MatName;
	variable MatNameList;
	variable node_flg "num";
	
	variable Datalist;
#--------------------------#
#  Sets window parameters  #
#--------------------------#
	set MainWin(name)	dia;
	set MainWin(base)	.$MainWin(name);
	set MainWin(width)	420;
	set MainWin(height)	425;
	set MainWin(x)		120;
	set MainWin(y)		180;


#----------------------#
#  Creates top window  #
#----------------------#
	toplevel     $MainWin(base);
	wm title     $MainWin(base) "Create Beam Models";
	wm geometry  $MainWin(base) $MainWin(width)x$MainWin(height)+$MainWin(x)+$MainWin(y);
	wm resizable $MainWin(base) 0 0;
	wm protocol  $MainWin(base) WM_DELETE_WINDOW ::CustomHB::End;
	wm withdraw  $MainWin(base);
	KeepOnTop $MainWin(base);

#---------------------#
#  Load Input Value   #
#---------------------#
	::CustomHB::OPENCFG

#---------------------#
#  Creates Top frame  #
#---------------------#
	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fT -height 20 -relief groove -bd 0;
	set top_f $MainWin(base).fT;
	#----- label ---------------------------------------------------------------
	label $top_f.lb1 -text " Please specify the input item.";
	place $top_f.lb1	-relx   0 -rely  0.5 -anchor w;

#-----------------------#
#  Creates Middle frame #
#-----------------------#
	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fM -width 400 -height 360 -relief groove -bd 2;
	set middle_f $MainWin(base).fM;
	#----- Edit ---------------------------------------------------------------
	label $middle_f.lb1 -text "model for sections:";
	label $middle_f.lb2 -text "guide line:";
	label $middle_f.lb6 -text "node of side A:";
	label $middle_f.lb7 -text "first section surface:";
	label $middle_f.lb8 -text "node of side B:";
	label $middle_f.lb9 -text "stress data recovery:";
	label $middle_f.lb10 -text "(lines Max4):";
	label $middle_f.lb5 -text "element size of section:";

#-----------------------------*
	CanvasButton	$middle_f.btnSlt1		60	22								\
							-background #E6E664								\
							-width 10			\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHB::Sel_entity_Tool solids 1";

	CanvasButton	$middle_f.btnSlt2		60	22								\
							-background #E6E664								\
							-width 10			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHB::Sel_entity_Tool lines 1";

	CanvasButton	$middle_f.btnSlt3		60	22								\
							-background #E6E664								\
							-width 10			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHB::Sel_entity_Tool nodes 1";

#-----------------------------*
	 AddEntry	$middle_f.sel1      \
                                    text        "auto section"            \
                                    labelWidth   12                \
                                    entryWidth   11                 \
                                    listProc                         \
                                    whenPressed "::CustomHB::ToggleGender1" \
                                    iconName    small_updownarrow      \
                                    iconLoc     1 4                     \
                                    withoutPacking  asButton;

	CanvasButton	$middle_f.btnSlt4		60	22								\
							-background #E6E664								\
							-width 10			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHB::Sel_entity_Tool surfs 1";

#-----------------------------*
	 AddEntry	$middle_f.sel2      \
                                    text        "create Node B"            \
                                    labelWidth   12                \
                                    entryWidth   14                 \
                                    listProc                         \
                                    whenPressed "::CustomHB::ToggleGender2" \
                                    iconName    small_updownarrow      \
                                    iconLoc     1 4                     \
                                    withoutPacking  asButton;

	CanvasButton	$middle_f.btnSlt5		60	22								\
							-background #E6E664								\
							-width 10			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHB::Sel_entity_Tool nodes 2";

#-----------------------------*
	 AddEntry	$middle_f.sel3      \
                                    text        "auto axis"            \
                                    labelWidth   12                \
                                    entryWidth   11                 \
                                    listProc                         \
                                    whenPressed "::CustomHB::ToggleGender3" \
                                    iconName    small_updownarrow      \
                                    iconLoc     1 4                     \
                                    withoutPacking  asButton;

	CanvasButton	$middle_f.btnSlt7		60	22								\
							-background #E6E664								\
							-width 10			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"origin"								\
							command			"::CustomHB::Sel_entity_Tool lines 3";

	CanvasButton	$middle_f.btnSlt8		60	22								\
							-background #E6E664								\
							-width 10			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"y-axis"							\
							command			"::CustomHB::Sel_entity_Tool lines 4";

#-----------------------------*
	 AddEntry	$middle_f.sel4      \
                                    text        "(none)"            \
                                    labelWidth   12                \
                                    entryWidth   11                 \
                                    listProc                         \
                                    whenPressed "::CustomHB::ToggleGender4" \
                                    iconName    small_updownarrow      \
                                    iconLoc     1 4                     \
                                    withoutPacking  asButton;

	CanvasButton	$middle_f.btnSlt6		60	22								\
							-background #E6E664								\
							-width 10			\
							-activebackground "YELLOW"						\
							-relief 	ridge								\
							text			"Select"								\
							command			"::CustomHB::Sel_entity_Tool lines 2";

#-----------------------------*
	AddEntry	$middle_f.ent3       entryWidth  9                   \
									anchor      nw                   \
									validate      real                   \
									textvariable    [namespace current]::elem_size        \
									withoutPacking;

#-----------------------------*
	labelframe $middle_f.div -width 200 -height 80 -relief groove -bd 2 -text "The way of cutting the model";
	set div_f $middle_f.div;
	place $div_f		-relx   0.48 -y  155 -anchor nw;

	label $div_f.lb3 -text "division number:";
	label $div_f.lb4 -text "magnitude:";

	radiobutton $div_f.rad1 		 -variable [namespace current]::node_flg	\
									 -value num -command ::CustomHB::RadSelect;

	radiobutton $div_f.rad2 		 -variable [namespace current]::node_flg	\
									 -value len -command ::CustomHB::RadSelect;

	AddEntry	$div_f.ent1       entryWidth  10                   \
									anchor      nw                   \
									validate      integer                   \
									textvariable    [namespace current]::Line_num        \
									withoutPacking;

	AddEntry	$div_f.ent2       entryWidth  10                   \
									anchor      nw                   \
									validate      real                   \
									state     disabled	\
									textvariable    [namespace current]::line_len        \
									withoutPacking;

	place $div_f.lb3	-relx   0.03 -y  8 -anchor w;
	place $div_f.lb4	-relx   0.03 -y  38 -anchor w;
	place $div_f.rad1		-relx   0.48 -y  15 -anchor w;
	place $div_f.ent1		-relx   0.58 -y  15 -anchor w;
	place $div_f.rad2		-relx   0.48 -y  45 -anchor w;
	place $div_f.ent2		-relx   0.58 -y  45 -anchor w;

#-----------------------------*
	labelframe $middle_f.fTT -width 155 -height 40 -relief groove -bd 2 -text "Material List";
	set list_f $middle_f.fTT;
	place $list_f		-relx   0.02 -y  240 -anchor nw;

	listbox $list_f.l1 -height 6 -selectmode browse -width 30 -yscrollcommand {.dia.fM.fTT.s1 set};
	scrollbar $list_f.s1 -orient vertical -command {.dia.fM.fTT.l1 yview};
	$middle_f.fTT.l1 delete 0 end

	set MatNameList [hm_entitylist mats name];
	foreach i $MatNameList {
		$list_f.l1 insert end $i
	}
	pack $list_f.l1 -fill y -side left;
	pack $list_f.s1 -fill y -side left;

	CanvasButton	$middle_f.btnMupdt		80	20								\
							text			"MAT Update"					\
							-background "skyblue"								\
							command			"::CustomHB::UpDate_MAT";
	place $middle_f.btnMupdt -relx 0.04  -y 225 -anchor w;
#-----------------------------*

	place $middle_f.lb1	-relx   0.04 -y  15 -anchor w;
	place $middle_f.lb2	-relx   0.04 -y  45 -anchor w;
	place $middle_f.lb6	-relx   0.04 -y  75 -anchor w;

	place $middle_f.btnSlt1		-relx   0.30 -y  15 -anchor w;
	place $middle_f.btnSlt2		-relx   0.30 -y  45 -anchor w;
	place $middle_f.btnSlt3		-relx   0.30 -y  75 -anchor w;
	
	place $middle_f.sel1		-relx   0.53 -y  105 -anchor w;
	
	place $middle_f.sel2		-relx   0.04 -y  105 -anchor w;
	
	place $middle_f.lb9	-relx   0.58 -y  253 -anchor w;
	place $middle_f.sel4	-relx   0.58 -y  278 -anchor w;

	place $middle_f.sel3		-relx   0.53 -y  15 -anchor w;

	place $middle_f.lb5	-relx   0.02 -y  165 -anchor w;
	place $middle_f.ent3		-relx   0.30 -y  190 -anchor w;

	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fM2 -width 400 -height 360 -relief groove -bd 2;
	set middle_f2 $MainWin(base).fM2;
	#----- Edit ---------------------------------------------------------------
	label $middle_f2.lb1 -text "Please change the property for elemen ID.";
	label $middle_f2.lb2 -text "Configuration Table of Elements and Properties:";
	
	#----- Frame ---------------------------------------------------------------
	labelframe $MainWin(base).fM2.tb2 -text "Property Name"
	set middle_tb2 $MainWin(base).fM2.tb2;
	#----- Edit ---------------------------------------------------------------
    listbox $middle_tb2.l1 -height 5 -yscrollcommand {.dia.fM2.tb2.s1 set};
    scrollbar $middle_tb2.s1 -command {.dia.fM2.tb2.l1 yview};
    $middle_tb2.l1 delete 0 end
    foreach i $Datalist {
    	$middle_tb2.l1 insert end [lindex $i 1];
    }
    pack $middle_tb2.l1 -fill both -side left
    pack $middle_tb2.s1 -fill y -side left
    
    
	CanvasButton	$MainWin(base).fM2.btnUpdt		30	30								\
							text			"<<"						\
							-command			"::CustomHB::btCmd $MainWin(base).fM2";

	CanvasButton	$MainWin(base).fM2.btdef		60	25								\
							text			"Default" \
							-command			"::CustomHB::btDef $MainWin(base).fM2";


	place $middle_f2.lb1		-relx   0.01 -y  10 -anchor w;
    place $middle_tb2		-relx   0.02 -y  70 -anchor w;
    place $middle_f2.lb2		-relx   0.02 -y  145 -anchor w;
	place $middle_f2.btnUpdt	-relx   0.85 -y  170 -anchor w;
	place $middle_f2.btdef	-relx   0.42 -y  50 -anchor w;

#------------------------#
#  Creates button frame  #
#------------------------#
	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fB -width 280 -height 40 -relief groove -bd 0;
	set btm_f $MainWin(base).fB;

	#----- Action button -------------------------------------------------------
	CanvasButton	$btm_f.btnCre		60	20								\
							text			"Create"						\
							-command			{::CustomHB::Getlist
											 ::CustomHB::CreLocation};

	CanvasButton	$btm_f.btnRje		60	20								\
							-background #d6d6d6									\
							text			"Reject"								\
							-command			{::CustomHB::execute_temp 1;
							::CustomHB::End;}

	CanvasButton	$btm_f.btnClose		60	20								\
							text			"Close"								\
							command			"::CustomHB::End";

	place $btm_f.btnCre -relx 0.44  -rely 0.4 -anchor e;
	place $btm_f.btnRje -relx 0.70  -rely 0.4 -anchor e;
	place $btm_f.btnClose -relx 0.96  -rely 0.4 -anchor e;


	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fB2 -width 280 -height 40 -relief groove -bd 0;
	set btm_f2 $MainWin(base).fB2;

	#----- Action button -------------------------------------------------------
	CanvasButton	$btm_f2.btnCre		60	20								\
							text			"Add Props"						\
							-command			{::CustomHB::UpdatePropforElem};

	CanvasButton	$btm_f2.btnRje		60	20								\
							-background #d6d6d6									\
							text			"Reject"								\
							-command			{::CustomHB::execute_temp 1;
							::CustomHB::End;}

	CanvasButton	$btm_f2.btnClose		60	20								\
							text			"Close"								\
							command			"::CustomHB::End";

	place $btm_f2.btnCre -relx 0.44  -rely 0.4 -anchor e;
	place $btm_f2.btnRje -relx 0.70  -rely 0.4 -anchor e;
	place $btm_f2.btnClose -relx 0.96  -rely 0.4 -anchor e;

#-----------------#
#  Layouts frame  #
#-----------------#
    pack $top_f -fill x  -padx 5 -pady 0 -anchor nw ;
    pack $middle_f -fill y -expand 0 -padx 10 -pady  5 -anchor nw -side top;
    pack $btm_f -fill y -side bottom -anchor e;

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
		AddCallback *dynamicviewbegin ::CustomHB::DynamicViewBegin;
		AddCallback *dynamicviewend   ::CustomHB::DynamicViewEnd;
}
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to update prop info of list					                   #
#                                                                              #
#	INPUT:	table info 														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::btCmd {table} {
    global ary
    variable CkVal;
    set selProp "";
	$table.tb1.t tag row clear;

	if { [$table.tb2.l1 curselection] != "" } {
		set selProp [$table.tb2.l1 get [$table.tb2.l1 curselection]];
	}

	for {set i 1} {$i <= [array size CkVal]} {incr i} {
	    if { $CkVal(${i}) == 1 && $selProp != ""} {
	    	set ary($i,3) $selProp;
			$table.tb1.t tag row row$i $i
			$table.tb1.t tag configure row$i -fg red;
	    	set CkVal(${i}) 0;
	    }
	}
return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to edit prop default info						                   #
#                                                                              #
#	INPUT:	table info 														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::btDef {table} {
    global ary
    variable CkVal;
    variable Datalist
	
	$table.tb1.t tag row clear

	for {set i 1} {$i <= [array size CkVal]} {incr i} {
    	set ary($i,3) [lindex [lindex $Datalist [expr $i - 1]] 1];
		$table.tb1.t tag row row0 $i
		$table.tb1.t tag configure row0 -fg black;
    	
    	set CkVal(${i}) 0;
	}

return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to create table and enter list info			                   #
#                                                                              #
#	INPUT:	data list (elemsID propName)									   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::CreListTable { Datalist } {
global ary;
variable MainWin;
variable CkVal;
variable ListTable_flg;

set middle_f2 $MainWin(base).fM2;
array unset ary
array unset CkVal

	if { [llength $Datalist] >= 10 } {
		set rowNum [expr [llength $Datalist] + 1];
	} else {
		set rowNum 11;
	}

	if {$ListTable_flg == 1} {
		destroy $MainWin(base).fM2.tb1;
	}

	#----- Frame ---------------------------------------------------------------
	frame $MainWin(base).fM2.tb1 -bd 2 -relief ridge;
	set middle_tb1 $MainWin(base).fM2.tb1;
	#----- Edit ---------------------------------------------------------------
	# Create Table
	table $middle_tb1.t -variable ary -rows $rowNum -cols 4 \
	    -colstretchmode unset -rowstretchmode unset \
	    -multiline 0 -selectmode extended \
	    -state disabled \
	    -bg white \
	    -maxheight 187 -maxwidth 380 \
	    -titlerows 1 -titlecols 1 -selecttitle 1 \
	    -yscrollcommand {.dia.fM2.tb1.y set}
	scrollbar $middle_tb1.y -orient vertical -command {.dia.fM2.tb1.t yview};

	pack $middle_tb1.t -fill y -side left;
	pack $middle_tb1.y -fill y -side left;

	# Create title
	set ary(0,1) "Sel"
	set ary(0,2) "ElementID"
	set ary(0,3) "Property Name"
	$middle_tb1.t tag config title -relief groove -bg #3366cc
	for {set i 0} {$i < $rowNum} {incr i} {
		if { $i > 0 } {set ary($i,0) $i}
	}

	for {set i 1} {$i<=[expr [$middle_tb1.t cget -rows]-1]} {incr i} {
		if { [llength $Datalist] >= $i } {
		    checkbutton $middle_tb1.t.ck$i -variable [namespace current]::CkVal(${i}) -bg white
		    $middle_tb1.t window configure $i,1 -window $middle_tb1.t.ck$i
		    
		    set ary($i,2) [lindex [lindex $Datalist [expr $i - 1]] 0]
		    set ary($i,3) [lindex [lindex $Datalist [expr $i - 1]] 1]
	    }
	}

	$middle_tb1.t tag configure sel    -fg black -bg #99ccff

	# set size of col
	$middle_tb1.t width 0 4 1 4 2 10 3 30

	set ListTable_flg 1;
	place $middle_tb1		-relx   0.02 -y  250 -anchor w;
return 0;
}
#------------------------------------------------------------------------------#
#  ::CustomHB::UpDate_MAT                                                      #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to update the Material List.									   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::UpDate_MAT {args} {
variable MainWin;
variable MatNameList;

	$MainWin(base).fM.fTT.l1 delete 0 end
	set MatNameList [hm_entitylist mats name];
	foreach i $MatNameList {
		$MainWin(base).fM.fTT.l1 insert end $i
	}
}

#------------------------------------------------------------------------------#
#  ::CustomHB::CkSelect                                                        #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to operate by check button.									   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::CkSelect { flg } {
variable MainWin;
variable ck_data1;
variable ck_data2;
variable ck_data3;

variable surf_ID;
variable nodeB_ID;
variable line_ID_rec;

	if { $ck_data1 == "1" && $flg == 1 } {
		EnableCanvasButton $MainWin(base).fM.btnSlt4;
		set surf_ID "";
	} elseif { $ck_data1 == "0" } {
		DisableCanvasButton $MainWin(base).fM.btnSlt4;
	}
	if { $ck_data2 == "1" && $flg == 2 } {
		EnableCanvasButton $MainWin(base).fM.btnSlt5;
		set nodeB_ID "";
	} elseif { $ck_data2 == "0" } {
		DisableCanvasButton $MainWin(base).fM.btnSlt5;
	}
	if { $ck_data3 == "1" && $flg == 3 } {
		EnableCanvasButton $MainWin(base).fM.btnSlt6;
		set line_ID_rec "";
	} elseif { $ck_data3 == "0" } {
		DisableCanvasButton $MainWin(base).fM.btnSlt6;
	}
	
}

#------------------------------------------------------------------------------#
#  ::CustomHB::RadSelect                                                       #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to operate by radio button.									   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::RadSelect { args } {
variable MainWin;
variable node_flg;

	if { $node_flg == "num" } {
		EntryState $MainWin(base).fM.div.ent1 normal;
		EntryState $MainWin(base).fM.div.ent2 disabled;
	} else {
		EntryState $MainWin(base).fM.div.ent1 disabled;
		EntryState $MainWin(base).fM.div.ent2 normal;
	}


}

#------------------------------------------------------------------------------#
#  ::CustomHB::Exists                                                          #
#------------------------------------------------------------------------------#
#  Summary : This procedure checks the existence of the main window.           #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : 0 : not existing                                                  #
#            1 : existing                                                      #
#------------------------------------------------------------------------------#
proc ::CustomHB::Exists { } {

	variable MainWin;

	#--------------------------#
	#  Checks the main window  #
	#--------------------------#
	if { [winfo exists $MainWin(base)] } { return 1; }

return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::Init                                                            #
#------------------------------------------------------------------------------#
#  Summary : This procedure initializes the main window.                       #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::Init { } {

	#-------------------------#
	#  Initializes parameter  #
	#-------------------------#
variable MatName "";
variable solid_ID "";
variable line_ID "";
variable surf_ID "";
variable nodeB_ID "";
variable node_ID "";
variable line_ID_rec "";
variable lineID_AxisYSt "";
variable lineID_AxisYEnd "";
variable select_bt1 0;
variable select_bt2 0;
variable select_bt3 0;
variable select_bt4 0;
variable DISPLAY_FLAG 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::ManageWindow                                                    #
#------------------------------------------------------------------------------#
#  Summary : This procedure opens the main window.                             #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::ManageWindow { } {
variable MainWin;

	#-------------------------------#
	#  Initializes the main window  #
	#-------------------------------#
	::CustomHB::Init;

	#-------------------------#
	#  Opens the main window  #
	#-------------------------#
	wm deiconify $MainWin(base);

}


#------------------------------------------------------------------------------#
#  ::CustomHB::UnManageWindow                                                  #
#------------------------------------------------------------------------------#
#  Summary : This procedure closes the main window.                            #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::UnManageWindow { } {
variable MainWin;

	#--------------------------#
	#  Closes the main window  #
	#--------------------------#
	wm iconify $MainWin(base);

}


#------------------------------------------------------------------------------#
#  ::CustomHB::Destroy                                                         #
#------------------------------------------------------------------------------#
#  Summary : This procedure destroys the main window.                          #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::Destroy { } {
variable MainWin;

	#----------------------------#
	#  Destroys the main window  #
	#----------------------------#
	destroy $MainWin(base);

}
#------------------------------------------------------------------------------#
#  ::CustomHB::DynamicViewBegin                                                #
#------------------------------------------------------------------------------#
#  Summary : This procedure is HyperMesh's callback function.                  #
#            Closes the main window while the model is rotating.               #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::DynamicViewBegin { args } {
variable DISPLAY_FLAG;

	#------------------------#
	#  Closes macro windows  #
	#------------------------#
	if { $DISPLAY_FLAG == 0 && [wm state $::CustomHB::MainWin(base)] != "iconic" } {
		set DISPLAY_FLAG 1;
		catch { wm withdraw $::CustomHB::MainWin(base);}
		#catch { wm iconify $::CustomHB::MainWin(base); }
	}

}
#------------------------------------------------------------------------------#
#  ::CustomHB::DynamicViewEnd                                                  #
#------------------------------------------------------------------------------#
#  Summary : This procedure is HyperMesh's callback function.                  #
#            Opens the main window when the model's rotation ends.             #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::DynamicViewEnd { args } {
variable DISPLAY_FLAG;

	#-----------------------#
	#  Opens macro windows  #
	#-----------------------#
	if { $DISPLAY_FLAG == 1 } {
		set DISPLAY_FLAG 0;
		catch { wm deiconify $::CustomHB::MainWin(base); }
	}
    if { [wm state $::CustomHB::MainWin(base)] == "withdraw"  } {
        catch { wm deiconify $::CustomHB::MainWin(base); }
    }
}

#------------------------------------------------------------------------------#
#  ::CustomHB::Sel_entity_Tool                                                 #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to select entity												   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::Sel_entity_Tool { entity_name flg} {
variable MainWin;
variable solid_ID;
variable line_ID;
variable node_ID;
variable surf_ID;
variable nodeB_ID;
variable line_ID_rec;
variable lineID_AxisYSt;
variable lineID_AxisYEnd;

	set comps_all [hm_entitylist comps name];
	if { $comps_all == "" } {return};
	*clearmark $entity_name 1;
	
	catch {::CustomHB::Change_window 1} res;

	if { $entity_name == "solids" && $solid_ID != "" } {
		eval *createmark $entity_name 2 $solid_ID;
		hm_highlightmark $entity_name 2 h;
		set solid_ID "";
	} elseif { $entity_name == "lines" && $flg == 1 && $line_ID != ""} {
		eval *createmark $entity_name 2 $line_ID;
		hm_highlightmark $entity_name 2 h;
		set line_ID "";
	} elseif { $entity_name == "lines" && $flg == 2 && $line_ID_rec != ""} {
		eval *createmark $entity_name 2 $line_ID_rec;
		hm_highlightmark $entity_name 2 h;
		set line_ID_rec "";
	} elseif { $entity_name == "lines" && $flg == 3 && $lineID_AxisYSt != ""} {
		eval *createmark $entity_name 2 $lineID_AxisYSt;
		hm_highlightmark $entity_name 2 h;
		set lineID_AxisYSt "";
	} elseif { $entity_name == "lines" && $flg == 4 && $lineID_AxisYEnd != ""} {
		eval *createmark $entity_name 2 $lineID_AxisYEnd;
		hm_highlightmark $entity_name 2 h;
		set lineID_AxisYEnd "";
	} elseif { $entity_name == "surfs" && $surf_ID != "" } {
		eval *createmark $entity_name 2 $surf_ID;
		hm_highlightmark $entity_name 2 h;
		set surf_ID "";
	} elseif { $entity_name == "nodes" && $flg == 1 && $node_ID != "" } {
		eval *createmark $entity_name 2 $node_ID;
		hm_highlightmark $entity_name 2 h;
		set node_ID "";
	} elseif { $entity_name == "nodes" && $flg == 2 && $nodeB_ID != "" } {
		eval *createmark $entity_name 2 $nodeB_ID;
		hm_highlightmark $entity_name 2 h;
		set nodeB_ID "";
	}
	
	## display the panel to select one solid
	*createmarkpanel $entity_name 1 "Please select the one entity"
	*clearmark $entity_name 2;
	set entity_ID "";
	set entity_ID [hm_getmark $entity_name 1];
	*clearmark $entity_name 1;

	if { $entity_ID == "" } {
		tk_messageBox -type ok -icon warning -title "Warning" -message "You are not selecting the entity.";
		if { [catch {::CustomHB::Change_window 0} res ] } {return};
		return 1;
	}
	if { [llength $entity_ID] >= 5 && $entity_name == "lines" && $flg == 2} {
		tk_messageBox -type ok -icon warning -title "Warning" -message "You can not select the ${entity_name} more than five.";
		if { [catch {::CustomHB::Change_window 0} res ] } {return};
		return 1;
	}
	if {([llength $entity_ID] != 1 && $entity_name == "nodes") || ([llength $entity_ID] != 1 && $entity_name == "solids") || ([llength $entity_ID] != 1 && $entity_name == "lines" && $flg != 2)} {
		tk_messageBox -type ok -icon warning -title "Warning" -message "You can not select the ${entity_name} more than two.";
		if { [catch {::CustomHB::Change_window 0} res ] } {return};
		return 1;
	}
	if { $entity_name == "solids" } {
		set solid_ID $entity_ID;
	} elseif { $entity_name == "lines" && $flg == 1 } {
		set line_ID $entity_ID;
	} elseif { $entity_name == "lines" && $flg == 2 } {
		set line_ID_rec $entity_ID;
	} elseif { $entity_name == "lines" && $flg == 3 } {
		set lineID_AxisYSt $entity_ID;
	} elseif { $entity_name == "lines" && $flg == 4 } {
		set lineID_AxisYEnd $entity_ID;
	} elseif { $entity_name == "surfs" } {
		set surf_ID $entity_ID;
	} elseif { $entity_name == "nodes" && $flg == 1 } {
		set node_ID $entity_ID;
	} elseif { $entity_name == "nodes" && $flg == 2 } {
		set nodeB_ID $entity_ID;
	}
	
	catch {::CustomHB::Change_window 0} res;
return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::Getlist                                                         #
#------------------------------------------------------------------------------#
#                                                                              #
# Function is to get List info												   #
#  												                               #
#------------------------------------------------------------------------------#
proc ::CustomHB::Getlist { args } {
variable MainWin;
variable MatName;

	set selectedIndex [$MainWin(base).fM.fTT.l1 curselection]
	if {$selectedIndex eq ""} {
		set MatName "";
	} else {
		set MatName [$MainWin(base).fM.fTT.l1 get $selectedIndex]
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
proc ::CustomHB::ToggleGender1 { args } {
variable MainWin;
variable select_bt1;
variable surf_ID;
	
	set curGender [ EntValue $MainWin(base).fM.sel1 ];
	if { $curGender == "auto section" } {
		EntryInsert $MainWin(base).fM.sel1 "select surf";
		place configure $MainWin(base).fM.lb7	-relx   0.52 -y  133 -anchor w;
		place configure $MainWin(base).fM.btnSlt4	-relx   0.80 -y  133 -anchor w;
		set select_bt1 1;
	} elseif { $curGender == "select surf" } {
		EntryInsert $MainWin(base).fM.sel1 "auto section";
		place forget $MainWin(base).fM.btnSlt4;
		place forget $MainWin(base).fM.lb7;
		set select_bt1 0;
		set surf_ID "";
	}

return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to change toggle name	2						                   #
#                                                                              #
#	INPUT:	Nothing 														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::ToggleGender2 { args } {
variable MainWin;
variable select_bt2;
variable nodeB_ID;
	
	set curGender [ EntValue $MainWin(base).fM.sel2 ];
	if { $curGender == "create Node B" } {
		EntryInsert $MainWin(base).fM.sel2 "select Node B";
		place configure $MainWin(base).fM.lb8	-relx   0.04 -y  133 -anchor w;
		place configure $MainWin(base).fM.btnSlt5	-relx   0.30 -y  133 -anchor w;
		set select_bt2 1;
	} elseif { $curGender == "select Node B" } {
		EntryInsert $MainWin(base).fM.sel2 "create Node B";
		place forget $MainWin(base).fM.lb8;
		place forget $MainWin(base).fM.btnSlt5;
		set select_bt2 0;
		set nodeB_ID ""
	}

return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to change toggle name	3						                   #
#                                                                              #
#	INPUT:	Nothing 														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::ToggleGender3 { args } {
variable MainWin;
variable select_bt3;
variable lineID_AxisYSt;
variable lineID_AxisYEnd;
	
	set curGender [ EntValue $MainWin(base).fM.sel3 ];
	if { $curGender == "auto axis" } {
		EntryInsert $MainWin(base).fM.sel3 "Y-axis";
		place configure $MainWin(base).fM.btnSlt7		-relx   0.55 -y  45 -anchor w;
		place configure $MainWin(base).fM.btnSlt8		-relx   0.75 -y  45 -anchor w;
		set select_bt3 1;
	} elseif { $curGender == "Y-axis" } {
		EntryInsert $MainWin(base).fM.sel3 "auto axis";
		place forget $MainWin(base).fM.btnSlt7;
		place forget $MainWin(base).fM.btnSlt8;
		set select_bt3 0;
		set lineID_AxisYSt;
		set lineID_AxisYEnd;
	}

return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is to change toggle name	4						                   #
#                                                                              #
#	INPUT:	Nothing 														   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::ToggleGender4 { args } {
variable MainWin;
variable select_bt4;
variable line_ID_rec;
	
	set curGender [ EntValue $MainWin(base).fM.sel4 ];
	if { $curGender == "(none)" } {
		EntryInsert $MainWin(base).fM.sel4 "select lines";
		place configure $MainWin(base).fM.btnSlt6		-relx   0.80 -y  305 -anchor w;
		place configure $MainWin(base).fM.lb10		-relx   0.60 -y  305 -anchor w;
		set select_bt4 1;
	} elseif { $curGender == "select lines" } {
		EntryInsert $MainWin(base).fM.sel4 "(none)";
		place forget $MainWin(base).fM.btnSlt6;
		place forget $MainWin(base).fM.lb10;
		set select_bt4 0;
		set line_ID_rec "";
	}

return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is Change flame of Window						                   #
#                                                                              #
#	INPUT:	$cg_flg[args] 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::Change_window { cg_flg } {
variable MainWin;
variable node_flg;
variable Datalist;

	if { $cg_flg == 0 } {
		EnableCanvasButton $MainWin(base).fM.btnSlt1;
		EnableCanvasButton $MainWin(base).fM.btnSlt2;
		EnableCanvasButton $MainWin(base).fM.btnSlt3;

		EntryState $MainWin(base).fM.ent3 normal;


		$MainWin(base).fM.fTT.l1 configure -state normal;

		EnableCanvasButton $MainWin(base).fB.btnCre;
		EnableCanvasButton $MainWin(base).fB.btnClose;
		EnableCanvasButton $MainWin(base).fM.btnMupdt;

		$MainWin(base).fM.div.rad1 configure -state normal;
		$MainWin(base).fM.div.rad2 configure -state normal;
		
		if { $node_flg == "num" } {
			EntryState $MainWin(base).fM.div.ent1 normal;
			EntryState $MainWin(base).fM.div.ent2 disabled;
		} else {
			EntryState $MainWin(base).fM.div.ent1 disabled;
			EntryState $MainWin(base).fM.div.ent2 normal;
		}
		
		EnableCanvasButton $MainWin(base).fM.btnSlt4;
		EnableCanvasButton $MainWin(base).fM.btnSlt5;
		EnableCanvasButton $MainWin(base).fM.btnSlt7;
		EnableCanvasButton $MainWin(base).fM.btnSlt8;
		EnableCanvasButton $MainWin(base).fM.btnSlt6;

	} elseif { $cg_flg == 1 } {
		DisableCanvasButton $MainWin(base).fM.btnSlt1;
		DisableCanvasButton $MainWin(base).fM.btnSlt2;
		DisableCanvasButton $MainWin(base).fM.btnSlt3;

		DisableCanvasButton $MainWin(base).fM.btnSlt4;
		DisableCanvasButton $MainWin(base).fM.btnSlt5;
		DisableCanvasButton $MainWin(base).fM.btnSlt7;
		DisableCanvasButton $MainWin(base).fM.btnSlt8;
		DisableCanvasButton $MainWin(base).fM.btnSlt6;
		
		$MainWin(base).fM.div.rad1 configure -state disabled;
		$MainWin(base).fM.div.rad2 configure -state disabled;
		EntryState $MainWin(base).fM.div.ent1 disabled;
		EntryState $MainWin(base).fM.div.ent2 disabled;
		EntryState $MainWin(base).fM.ent3 disabled;

		$MainWin(base).fM.fTT.l1 configure -state disabled;

		DisableCanvasButton $MainWin(base).fB.btnCre;
		DisableCanvasButton $MainWin(base).fB.btnClose;
		DisableCanvasButton $MainWin(base).fM.btnMupdt;
	} elseif { $cg_flg == 2 } {
		if { [llength $Datalist] >= 1 } {
			pack forget $MainWin(base).fM
			pack forget $MainWin(base).fB
			pack $MainWin(base).fM2 -fill y -expand 0 -padx 10 -pady  5 -anchor nw -side top;
			pack $MainWin(base).fB2 -fill y -side bottom -anchor e;
			catch {::CustomHB::CreListTable $Datalist} res;
			$MainWin(base).fM2.tb2.l1 delete 0 end;

			for {set i 1} {$i <= [llength $Datalist]} {incr i} {
				$MainWin(base).fM2.tb2.l1 insert end [lindex [lindex $Datalist [expr $i - 1]] 1];
				
#			    checkbutton $MainWin(base).fM2.tb1.t.ck$i -variable [namespace current]::CkVal(${i}) -bg white
#			    $MainWin(base).fM2.tb1.t window configure $i,1 -window $MainWin(base).fM2.tb1.t.ck$i
#			    set ary($i,2) [lindex [lindex $Datalist [expr $i - 1]] 0]
#			    set ary($i,3) [lindex [lindex $Datalist [expr $i - 1]] 1]
			}
		} else {
			tk_messageBox -type ok -icon warning -title "Warning" -message "Can't get the infomation of a elment and a property.";
			return 1;
		}
	} elseif { $cg_flg == 3 } {
		pack forget $MainWin(base).fM2
		pack forget $MainWin(base).fB2
		pack $MainWin(base).fM -fill y -expand 0 -padx 10 -pady  5 -anchor nw -side top;
		pack $MainWin(base).fB -fill y -side bottom -anchor e;
	}
update;
return 0;
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is Save into config file							                   #
#                                                                              #
#	INPUT:	Nothing		 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::SAVECFG { args } {
global dir_work;
variable Line_num;
variable line_len;
variable elem_size;
	
    set dirfile [file join ${dir_work}/_panel_input.cfg];

	if { ${::CustomHB::Line_num} == "" } {
		set ::CustomHB::Line_num 1;
	}
	
	if { ${::CustomHB::line_len} == "" } {
		set ::CustomHB::line_len 1.0;
	}

	if { ${::CustomHB::elem_size} == "" } {
		set ::CustomHB::elem_size 1.0;
	}

    if {([file exists $dirfile] == 1 && [file writable $dirfile] == 1) || [file exists $dirfile] == 0} {
        set fout [open $dirfile w];
        puts $fout ${::CustomHB::Line_num};
        puts $fout ${::CustomHB::line_len};
        puts $fout ${::CustomHB::elem_size};
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
proc ::CustomHB::OPENCFG { args } {
global dir_work;
variable Line_num;
variable line_len;
variable elem_size;

    set dirfile [file join ${dir_work}/_panel_input.cfg];

    if {[file readable $dirfile] == 0} {
        set [namespace current]::Line_num 1;
        set [namespace current]::line_len 1.0;
        set [namespace current]::elem_size 1.0;
        
    } else {
        set fin [open $dirfile r];
        set [namespace current]::Line_num [gets $fin];
        set [namespace current]::line_len [gets $fin];
        set [namespace current]::elem_size [gets $fin];
        close $fin;
    }
}

#------------------------------------------------------------------------------#
#                                                                              #
# Function is Execute templete								                   #
#                                                                              #
#	INPUT:	$cg_flg[args] 													   #
#	OUTPUT:	Nothing															   #
#------------------------------------------------------------------------------#
proc ::CustomHB::execute_temp { exe_flg } {
global dir_work;
global tmpfilename;
global currentfilename;
set tmpfilename_old "";
variable rej_flg;

	if { [hm_info currentfile] != $tmpfilename && [hm_info currentfile] != $currentfilename } {
		set currentfilename [hm_info currentfile];
	}

hm_answernext yes;
	if { $exe_flg == 0 } {
		if { [file exists $tmpfilename] == 1 } {
			set tmpfilename_old $tmpfilename;
			set tmpfilename ${dir_work}/temp_[ clock second ].hm;
			if {[catch {*writefile "${tmpfilename}" 1} res]} {return 1};
			catch {file delete $tmpfilename_old} res;
		} else {
			if {[catch {*writefile "${tmpfilename}" 1} res]} {return 1};
		}
		set rej_flg 1;
	} elseif { $exe_flg == 1 && $rej_flg != 0} {
		if {[catch {*readfile "$tmpfilename"} res]} {return 1};
		set rej_flg 2;
	} elseif { $exe_flg == 2 } {
		if { $currentfilename != "" && $rej_flg != 0 } {
			set ext_curfile [file extension ${currentfilename}];
			set except_ext_curfile [file rootname ${currentfilename}];
			if { $rej_flg == 2 } {
				if { [string range ${except_ext_curfile} end-6 end ] != "_reject" } {
					set currentfilename_af "${except_ext_curfile}_reject${ext_curfile}";
				} else {
					set currentfilename_af ${currentfilename};
				}
			} else {
				if { [string range ${except_ext_curfile} end-5 end ] != "_after" } {
					set currentfilename_af "${except_ext_curfile}_after${ext_curfile}";
				} else {
					set currentfilename_af ${currentfilename};
				}
			}
			
			if {[catch {*writefile "${currentfilename_af}" 1} res]} {return 1};
		}
		if {[catch {file delete $tmpfilename} res]} {return 1};
	}

return 0;
}

#------------------------------------------------------------------------------#
#  ::CustomHB::Highlighting                                                    #
#------------------------------------------------------------------------------#
#  Summary : This procedure changes entity hilighting and displaying message.  #
#                                                                              #
#  Args    : flg : highlight switch(On/Off)                                    #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::Highlighting { flg } {

	#----------------------------------------------------#
	#  Changes entity hilighting and displaying message  #
	#----------------------------------------------------#
	switch $flg {
		"On"  {
			hm_blockmessages 0;
			hm_blockerrormessages 0;
			*entityhighlighting 1;
		}
		"Off" {
			hm_blockmessages 1;
			hm_blockerrormessages 1;
			*entityhighlighting 0;
		}
	}

}
