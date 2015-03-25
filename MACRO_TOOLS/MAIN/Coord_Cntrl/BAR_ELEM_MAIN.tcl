#------------------------------------------------------------------------------#
#  Copyright (c) 2008 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.                                            #
#------------------------------------------------------------------------------#
package require hwt;

#Sets program environment
set INSTALL_DIR         "./MACRO_TOOLS";
set BAR_ELEM_MACRO_DIR  "${INSTALL_DIR}/MAIN/Coord_Cntrl";

option add *font			{ { Tahoma } 8 roman };
option add *Dialog.msg.font { { Tahoma } 8 roman };
hwt::SetAppFont -point 8 Tahoma;
#------------------------------------------------------------------------------#
#  global variable                                                             #
#------------------------------------------------------------------------------#
namespace eval ::_BARELEM {
}
#------------------------------------------------------------------------------#
#::_BARELEM::CreateDialog                                                      #
#Purpose : to load system resource and control 1d element coordinate           #
#------------------------------------------------------------------------------#
proc ::_BARELEM::CreateDialog { } {

    global BAR_ELEM_MACRO_DIR;

    #Sets default Font
    option add *font { Tahoma 8 roman }

    #Loads source file
    source ${BAR_ELEM_MACRO_DIR}/1DElementsCoordinateControl.tcl;

    #Sets dynamic rotation mode
    *dynamicrotatemode 1;

    #Creates window dialog
    set res [catch {
        ::BAR_ELEM_COORD_DISPLAY::MainWindow;
    } err];

    #Checks status
    if { $res != 0 } {
        ::_BARELEM::End;
        Message msgTheme  "msgErrorTheme" msgIcon   "error" \
                msgTitle  "Error"  msgCancel "Ok" \
                msgText   "$err\n$::errorCode\n$::errorInfo";

        Message msgTheme  "msgErrorTheme" msgIcon "error" \
                msgTitle  "Error" msgCancel "Ok" \
                msgText   "Starting macro program failed.";
	}
}
#------------------------------------------------------------------------------#
#::_BARELEM::DisplayShellElemSystem                                            #
#Purpose : to load system resource and control 1d element coordinate           #
#------------------------------------------------------------------------------#
proc ::_BARELEM::DisplayShellElemSystem { } {

    global BAR_ELEM_MACRO_DIR;

    #Sets default Font
    option add *font { Tahoma 8 roman }

    #Loads source file
    source ${BAR_ELEM_MACRO_DIR}/HM_quad_cord.tcl;

    #Sets dynamic rotation mode
    *dynamicrotatemode 1;

    #Creates window dialog
    set res [catch {
        ::SHELL_ELEM_COORD_DISPLAY::MainWindow;
    } err];

    #Checks status
    if { $res != 0 } {
        
        #Resets dynamic rotation mode
        *dynamicrotatemode 0;
        foreach name [namespace children ::SHELL_ELEM_COORD_DISPLAY] {eval ${name}::Destroy;}
        namespace delete ::SHELL_ELEM_COORD_DISPLAY;
        #exit panel
        ::SHELL_ELEM_COORD_DISPLAY::OnQuit;
        #Destroy Widgets
        ::_BARELEM::Destroy;

        Message msgTheme  "msgErrorTheme" msgIcon   "error" \
                msgTitle  "Error"  msgCancel "Ok" \
                msgText   "$err\n$::errorCode\n$::errorInfo";

        Message msgTheme  "msgErrorTheme" msgIcon "error" \
                msgTitle  "Error" msgCancel "Ok" \
                msgText   "Starting macro program failed.";
	}
}

#------------------------------------------------------------------------------#
#::_BARELEM::End                                                               #
#Purpose : to terminate program.                                               #
#------------------------------------------------------------------------------#
proc ::_BARELEM::End { } {

    #Resets dynamic rotation mode
    *dynamicrotatemode 0;

    #Remove coordinate callback settings
    RemoveCallback *vectordrawoptions;
    RemoveCallback *systemsize;
    RemoveCallback *readfile;
    
    foreach name [namespace children ::BAR_ELEM_COORD_DISPLAY] {eval ${name}::Destroy;}
    namespace delete ::BAR_ELEM_COORD_DISPLAY;
    
    #exit panel
    ::BAR_ELEM_COORD_DISPLAY::OnQuit

    #Destroy Widgets
    ::_BARELEM::Destroy;

}
