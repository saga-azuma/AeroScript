# Tcl package index file, version 1.1
# $Id: pkgIndex.tcl 310 2015-12-16 01:05:17Z oguchi $

if { ![ package vsatisfies [ package provide Tcl ] 8.5 ] } {
    return;
}

package ifneeded ajlib::vector 2.4.310 [ subst -nocommands {
    if { [ file exists [ file join "$dir" vector.tcl ] ] } {
        source [ file join "$dir" vector.tcl ];
    } else {
        source [ file join "$dir" vector.tbc ];
    }
} ];
