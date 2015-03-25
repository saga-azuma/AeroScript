#
# This TCL developed by Altair Japan (2008/3/19)
#

catch { namespace delete ::GET_OUTPUT_COORD }

namespace eval ::GET_OUTPUT_COORD {
}

proc ::GET_OUTPUT_COORD::node_out {} {
    set loops "0"
    set num_nod "0"

    for {set i 0} {$i<100} {incr i} {

        *clearmark systs 1
        *createmarkpanel systs 1 "Select system"
        set num_sys [hm_getmark systs 1]

        if {[llength $num_sys] == 0} {
            set ans1 [tk_messageBox -type yesno -message "Do you want to use Global system?"]
            if {$ans1 == "no"} break;
            set loops [expr $loops + 1]
            set axis($i) "0"
        } else {
            set loops [expr $loops + 1]
            set axis($i) $num_sys
        }

        *clearmark nodes 2
        *createlistpanel nodes 2 "Select nodes"
        set num_nod [hm_getlist nodes 2]

        if {[llength $num_nod] == 0} {
            break;
        } else {
            set node_list($i) $num_nod
            #echo $node_list($i)
        }
    }


    if {$loops != "0" && [llength $num_nod] != "0"} {

        ## Open File ##
        set initdir pwd;
        set types "{\"All files\"       *}";
        set flname [tk_getSaveFile -parent . -filetypes $types -initialdir $initdir -title "Node coordinate output"];
        if {$flname == "" } {return}

        set io [open $flname w];

        puts $io "   Node ID  Coord 1 Value  Coord 2 Value  Coord 3 Value    Ref-CID Type";

        for {set j 0} {$j < $loops} {incr j} {
            set num($j) [llength $node_list($j)]

            if {$axis($j) != 0} {
                set sys_Tid [hm_getentityvalue SYSTEM $axis($j) "type" 0 ]
                ## Set system type ##
                if {$sys_Tid == 0} {
                    set sys_type "Rectangular"
                } elseif {$sys_Tid == "1"} {
                    set sys_type "Cylindrical"
                }
            } else {
                set sys_type "Rectangular"
                set axis($j) "(Global)"
            }

            for {set k 0} {$k<$num($j)} {incr k} {

                if {$axis($j) != 0} {
                    set node_id [lindex $node_list($j) $k]
                    set org_axis [ hm_getentityvalue NODES $node_id "inputsystemid" 0 ]
                    *createmark nodes 1 $node_id
                    eval *systemsetreference nodes 1 $axis($j)
                }
                set x_val($k) [hm_getentityvalue NODES $node_id "x" 0 ]
                set y_val($k) [hm_getentityvalue NODES $node_id "y" 0 ]
                set z_val($k) [hm_getentityvalue NODES $node_id "z" 0 ]

                if {$axis($j) != 0} {
                    *createmark nodes 1 $node_id
                    *systemsetreference nodes 1 $org_axis
                }

                set x_res($k) [leng_check $x_val($k)];
                set y_res($k) [leng_check $y_val($k)];
                set z_res($k) [leng_check $z_val($k)];

                puts $io [format "%10.10s   %12.12s   %12.12s   %12.12s   %8.8s%12.12s" $node_id $x_res($k) $y_res($k) $z_res($k) $axis($j) $sys_type]
            }
        }

        close $io
    }
}

#set the reference system for an entity

#Check length
proc ::GET_OUTPUT_COORD::leng_check {val} {

    if {[string length $val] <= "12"} {
        set res $val;
    } else {
        if {$val < "0"} {
            set res [format "%1$-11.4le" $val]
        } else {
            set res [format "%1$-11.5le" $val]
        }
    }
    return $res;
}

#::GET_OUTPUT_COORD::node_out;


