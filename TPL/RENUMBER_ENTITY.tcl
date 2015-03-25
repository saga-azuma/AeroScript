#------------------------------------------------------------------------------#
#  Copyright (c) 2008 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.                                            #
#------------------------------------------------------------------------------#
package require hwt;

#Sets program environment
set INSTALL_DIR         "__INSTALL_DIR__";
set RENUM_ENTY_MACRO_DIR  "${INSTALL_DIR}/MAIN/renum_enty";

option add *font			{ { Tahoma } 8 roman };
option add *Dialog.msg.font { { Tahoma } 8 roman };
hwt::SetAppFont -point 8 Tahoma;
#------------------------------------------------------------------------------#
#  global variable                                                             #
#------------------------------------------------------------------------------#
namespace eval ::_RENUMB_ENTITY {
}
#------------------------------------------------------------------------------#
#::_RENUMB_ENTITY::Renumber_Elements                                           #
#Purpose : to load system resource and control 1d element coordinate           #
#------------------------------------------------------------------------------#
proc ::_RENUMB_ENTITY::Renumber_Elements { } {

    global RENUM_ENTY_MACRO_DIR;

    #Sets default Font
    option add *font { Tahoma 8 roman }

    #Loads source file
    source ${RENUM_ENTY_MACRO_DIR}/renum_elem2.tcl;

    #Sets dynamic rotation mode
    *dynamicrotatemode 1;

    #Creates window dialog
    set res [catch {
        ::Rereele::renum_node_elem;
    } err];

    #Checks status
    if { $res != 0 } {
        #Resets dynamic rotation mode
        *dynamicrotatemode 0;

        foreach name [namespace children ::Rereele] {eval ${name}::Destroy;}
        namespace delete ::Rereele

        Message msgTheme  "msgErrorTheme" msgIcon   "error" \
                msgTitle  "Error"  msgCancel "Ok" \
                msgText   "$err\n$::errorCode\n$::errorInfo";

        Message msgTheme  "msgErrorTheme" msgIcon "error" \
                msgTitle  "Error" msgCancel "Ok" \
                msgText   "Starting macro program failed.";
    }
}
#------------------------------------------------------------------------------#
#::_RENUMB_ENTITY::Renumber_Nodes                                              #
#Purpose : to load system resource and control 1d element coordinate           #
#------------------------------------------------------------------------------#
proc ::_RENUMB_ENTITY::Renumber_Nodes { } {

    global RENUM_ENTY_MACRO_DIR;

    #Sets default Font
    option add *font { Tahoma 8 roman }

    #Loads source file
    source ${RENUM_ENTY_MACRO_DIR}/renum_node2.tcl;

    #Sets dynamic rotation mode
    *dynamicrotatemode 1;

    #Creates window dialog
    set res [catch {
        ::Rerenod::renum_node_elem;
    } err];

    #Checks status
    if { $res != 0 } {
        #Resets dynamic rotation mode
        *dynamicrotatemode 0;
        
        foreach name [namespace children ::Rerenod] {eval ${name}::Destroy;}
        namespace delete ::Rerenod;
        
        Message msgTheme  "msgErrorTheme" msgIcon   "error" \
                msgTitle  "Error"  msgCancel "Ok" \
                msgText   "$err\n$::errorCode\n$::errorInfo";

        Message msgTheme  "msgErrorTheme" msgIcon "error" \
                msgTitle  "Error" msgCancel "Ok" \
                msgText   "Starting macro program failed.";
    }
}
#------------------------------------------------------------------------------#
#::_RENUMB_ENTITY::Get_Refer_Node_Coord                                        #
#Purpose : to load system resource and control 1d element coordinate           #
#------------------------------------------------------------------------------#
proc ::_RENUMB_ENTITY::Get_Refer_Node_Coord { } {

    global RENUM_ENTY_MACRO_DIR;

    #Sets default Font
    option add *font { Tahoma 8 roman }

    #Loads source file
    source ${RENUM_ENTY_MACRO_DIR}/output.tcl;

    #Sets dynamic rotation mode
    *dynamicrotatemode 1;

    #Creates window dialog
    set res [catch {
        ::GET_OUTPUT_COORD::node_out;
    } err];

    #Checks status
    if { $res != 0 } {
        #Resets dynamic rotation mode
        *dynamicrotatemode 0;

        foreach name [namespace children ::GET_OUTPUT_COORD] {eval ${name}::Destroy;}
        namespace delete ::GET_OUTPUT_COORD;

        Message msgTheme  "msgErrorTheme" msgIcon   "error" \
                msgTitle  "Error"  msgCancel "Ok" \
                msgText   "$err\n$::errorCode\n$::errorInfo";

        Message msgTheme  "msgErrorTheme" msgIcon "error" \
                msgTitle  "Error" msgCancel "Ok" \
                msgText   "Starting macro program failed.";
    }
}