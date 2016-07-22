# Tcl package index file, version 1.1
# $Id: pkgIndex.tcl 107 2013-11-17 12:09:24Z oguchi $

if { ![ package vsatisfies [ package provide Tcl ] 8.5 ] } {
    return;
}

package ifneeded ajlib::matrix 2.0 [ subst -nocommands {
    if { [ file exists [ file join "$dir" matrix.tcl ] ] } {
        source [ file join "$dir" generic.tcl ];
        source [ file join "$dir" 2x2.tcl ];
        source [ file join "$dir" 3x3.tcl ];
        source [ file join "$dir" 4x4.tcl ];
        source [ file join "$dir" matrix.tcl ]; # must be laoded at last
    } else {
        source [ file join "$dir" generic.tbc ];
        source [ file join "$dir" 2x2.tbc ];
        source [ file join "$dir" 3x3.tbc ];
        source [ file join "$dir" 4x4.tbc ];
        source [ file join "$dir" matrix.tbc ];
    }
} ];
