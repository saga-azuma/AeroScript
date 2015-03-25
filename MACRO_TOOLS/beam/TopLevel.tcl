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

package require hwt;

#------------------------------------------------------------------------------#
#  Sets global variables                                                       #
#------------------------------------------------------------------------------#
set MAC_DIR [ file dirname [ info script ] ];
set dir_work [file join [hm_info -appinfo CURRENTWORKINGDIR]];
set tmpfilename ${dir_work}/temp_[ clock second ].hm;
set currentfilename [hm_info currentfile];

#------------------------------------------------------------------------------#
#  Sets application font                                                       #
#------------------------------------------------------------------------------#
option add *font			{ {Tahoma} 8 roman }
option add *Dialog.msg.font { {Tahoma} 8 roman }
::hwt::SetAppFont -point 8 Tahoma;


#------------------------------------------------------------------------------#
#  Defines namespace & variables                                               #
#------------------------------------------------------------------------------#
namespace eval ::CustomHB {
variable INSTANCE;

}

#------------------------------------------------------------------------------#
#  ::CustomHB::Start                                                           #
#------------------------------------------------------------------------------#
#  Summary : This procedure starts the application.                            #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::Start { } {
global MAC_DIR;
variable INSTANCE;
	
	#----------------------#
	#  Loads program file  #
	#----------------------#
	source "${MAC_DIR}/GUICreate.tcl";
	source "${MAC_DIR}/CreateHB2.tcl";

	#-----------------------------#
	#  Checks application window  #
	#-----------------------------#
	if { [info exists INSTANCE] } {
		if { [::CustomHB::Exists] } {
			set msg "Can't open the window.";
			::CustomHB::MsgBox "Error" $msg;
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
		::CustomHB::MainWindow;
		::CustomHB::ManageWindow;
	} err];

	#------------------------#
	#  Checks window status  #
	#------------------------#
	if { $res != 0 } {
		set msg "$err\n$::errorCode\n$::errorInfo";
		::CustomHB::MsgBox "Error" $msg;
		set msg "Starting macro program failed.";
		::CustomHB::MsgBox "Error" $msg;
		::CustomHB::End;
	}
}

#------------------------------------------------------------------------------#
#  ::CustomHB::End                                                             #
#------------------------------------------------------------------------------#
#  Summary : This procedure terminates the application.                        #
#                                                                              #
#  Args    : nothing                                                           #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::End { } {
	
	#---------------------#
	#  Save Input Value   #
	#---------------------#
	::CustomHB::SAVECFG

	#--------------------------------#
	#  Delete file for reject        #
	#--------------------------------#
	::CustomHB::execute_temp 2;

	#--------------------------------#
	#  Resets dynamic rotation mode  #
	#--------------------------------#
	*dynamicrotatemode 0;

	#-------------------------------#
	#  Removes callback procedures  #
	#-------------------------------#
#	RemoveCallback *dynamicviewbegin ::CustomHB::DynamicViewBegin;
#	RemoveCallback *dynamicviewend ::CustomHB::DynamicViewEnd;
	RemoveAllCallbacks *dynamicviewbegin;
	RemoveAllCallbacks *dynamicviewend;

	#--------------------------------#
	#  Destroies application window  #
	#--------------------------------#
	::CustomHB::Destroy;

	#---------------------#
	#  Deletes namespace  #
	#---------------------#
	namespace delete ::CustomHB;
 }
 
#------------------------------------------------------------------------------#
#  ::CustomHB::MsgBox                                                          #
#------------------------------------------------------------------------------#
#  Summary : This procedure displays the message box.                          #
#                                                                              #
#  Args    : type : message box type(Error/Warning)                            #
#            msg  : message text                                               #
#                                                                              #
#  Return  : nothing                                                           #
#------------------------------------------------------------------------------#
proc ::CustomHB::MsgBox { type msg } {

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

}

::CustomHB::Start
