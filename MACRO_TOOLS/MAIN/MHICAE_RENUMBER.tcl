namespace eval ::_MHICAE::RENUMBER {
    set win(name)    renumber;
    set win(base)   .$win(name);
    set win(width)   340;
    set win(height)  210;
    set win(x)       [ expr [ winfo screenwidth  . ] - 905 ];
    set win(y)       [ expr [ winfo screenheight . ] - 750 ];
    
    set DISPLAY_FLAG 0;
    
    Proc MainWindow {} {
        variable win;
        
        if { [winfo exists $win(base) ] } { return }
        
        toplevel        $win(base);
        wm title        $win(base) "Renumber entities"
        wm geometry     $win(base) $win(width)x$win(height)+$win(x)+$win(y);
        wm resizable    $win(base) 0 0;
        wm protocol     $win(base) WM_DELETE_WINDOW { ::_MHICAE::RENUMBER::UnManageWindow };
        wm withdraw     $win(base);
        hwt::KeepOnTop  $win(base);
        
        # init variables
        set ::_MHICAE::RENUMBER::reverse 0;
        set ::_MHICAE::RENUMBER::startId "";
        set ::_MHICAE::RENUMBER::selectedCoordSyst 0;
        set ::_MHICAE::RENUMBER::selectedNodes "";
        set ::_MHICAE::RENUMBER::selectedElems "";
        set ::_MHICAE::RENUMBER::cylindricalAxis X;
        set ::_MHICAE::RENUMBER::axisSystem 0;
        set ::_MHICAE::RENUMBER::origin 0;
        
        set x1_1 5;
        set y1_1 5;
        
        label $win(base).lblEntityType -text "entity type:";
        place $win(base).lblEntityType -x $x1_1 -y [ expr $y1_1 + 4 ];
        
        set entityTypeFrame [ frame $win(base).frmEntityType -bd 0 -relief flat -height 26 ];
        set entityTypeMenu [ ::_MHICAE::RENUMBER::EntityTypeMenu $entityTypeFrame ];
        set entityType [ CanvasButton $entityTypeFrame.frmEntityType 55 26 \
                        relief groov     \
                        text "nodes" \
                        popupMenu $entityTypeMenu ];
        place $entityTypeFrame -x [ expr $x1_1 + 60 ] -y $y1_1 -height 26;
        pack $entityType -side left -anchor nw;
        
        button $win(base).btnEntity -text "nodes" -bg "#E6E664" -activebackground "#E6E664" -relief flat -padx 3 -width 8 -command { ::_MHICAE::RENUMBER::SelectRenumberedEntity };
        place $win(base).btnEntity -x [ expr $x1_1 + 150 ] -y $y1_1 -height 26;
        
        set y1_2 [ expr $y1_1 + 32 ];
        label $win(base).lblCoordType -text "coordinate sytem type:";
        place $win(base).lblCoordType -x $x1_1 -y [ expr $y1_2 + 4 ];
        
        set coordTypeFrame [ frame $win(base).frmCoordType -bd 0 -relief flat -height 26 ];
        set coordTypeMenu [ ::_MHICAE::RENUMBER::CoordTypeMenu $coordTypeFrame ];
        set coordType [ CanvasButton $coordTypeFrame.frmCoordType 70 26 \
                        relief groov \
                        text "orthogonal" \
                        popupMenu $coordTypeMenu ];
        place $coordTypeFrame -x [ expr $x1_1 + 130 ] -y $y1_2 -height 26;
        pack $coordType -side left -anchor nw;
        
        set y1_3 [ expr $y1_2 + 30 ];
        labelframe $win(base).lfCoordAttr -text "coordinate attributes" -width [ expr $win(width) - 10 ] -height 60;
        place $win(base).lfCoordAttr -x $x1_1 -y $y1_3;
        
        ::_MHICAE::RENUMBER::DisplayCoordAttrFrame "orthogonal";
        
        set y1_4 [ expr $y1_3 + 70 ];
        label $win(base).lblStartId -text "start with =";
        place $win(base).lblStartId -x $x1_1 -y $y1_4;
        entry $win(base).entStartId -textvariable ::_MHICAE::RENUMBER::startId -width 12;
        place $win(base).entStartId -x [ expr $x1_1 + 65 ] -y [ expr $y1_4 - 3 ] -height 24;
        button $win(base).btnMaxId -text "max" -relief groov -command { ::_MHICAE::RENUMBER::GetMaxId };
        place $win(base).btnMaxId -x [ expr $x1_1 + 143 ] -y [ expr $y1_4 - 2 ] -height 24 -width 30;
        checkbutton $win(base).cbReverse -text "reverse" -variable ::_MHICAE::RENUMBER::reverse;
        place $win(base).cbReverse -x [ expr $x1_1 + 190 ] -y [ expr $y1_4 + 2 ]; 
        
        set y1_5 [ expr $y1_4 + 30 ];
        frame $win(base).fbar_1 -borderwidth 2 \
                                -relief      groove \
                                -width       [ expr $win(width) - 10 ] \
                                -height      2;
        place $win(base).fbar_1 -x 5 -y $y1_5;
        
        set y1_6 [ expr $y1_5 + 10 ];
        button $win(base).btnRenumber -text "renumber" -bg "#60C060" -activebackground "#60C060" -relief flat -padx 3 -width 8 -command { ::_MHICAE::RENUMBER::Renumber };
        place $win(base).btnRenumber -x [ expr $win(width) - 130 ] -y $y1_6 -height 25;
        button $win(base).btnClose -text "close" -relief groov -padx 3 -width 8 -command { ::_MHICAE::RENUMBER::UnManageWindow } 
        place $win(base).btnClose -x [ expr $win(width) - 65 ] -y $y1_6 -height 26;
        
        wm deiconify $win(base);
        focus $win(base);
        
    }
    
    #--------------------------------------------------------------------------#
    # EntityTypeMenu                                                           #
    # Create menu to select renumberd entity type                              #
    #--------------------------------------------------------------------------#
    proc EntityTypeMenu { W args } {
        variable win;

        #create the pull down menu
        if {[winfo exists $W.menu]} {
            destroy $W.menu;
        }
        set menu [ menu $W.menu -tearoff 0];
    
        # menu text
        $menu add command -compound left -label "nodes" -command { ::_MHICAE::RENUMBER::SwitchEntitiy nodes };
        $menu add command -compound left -label "elems" -command { ::_MHICAE::RENUMBER::SwitchEntitiy elems };
    
        return $menu;
    }
    
    #--------------------------------------------------------------------------#
    # CoordTypeMenu                                                            #
    # Create menu to select coordinate system type                             #
    #--------------------------------------------------------------------------#
    proc CoordTypeMenu { W args } {
        variable win;
        
        #create the pull down menu
        if {[winfo exists $W.menu]} {
            destroy $W.menu;
        }
        set menu [ menu $W.menu -tearoff 0];
    
        # menu text
        $menu add command -compound left -label "orthogonal" -command { ::_MHICAE::RENUMBER::DisplayCoordAttrFrame "orthogonal" };
        $menu add command -compound left -label "cylindrical" -command { ::_MHICAE::RENUMBER::DisplayCoordAttrFrame "cylindrical" };
        $menu add command -compound left -label "spherical" -command { ::_MHICAE::RENUMBER::DisplayCoordAttrFrame "spherical" };
    
        return $menu;
    }
    
    #--------------------------------------------------------------------------#
    # SwitchEntity                                                             #
    # Switch entity type which are renumberd                                   #
    #--------------------------------------------------------------------------#
    proc SwitchEntitiy { type } {
        variable win;
        
        $win(base).btnEntity configure -text "$type";
    }
    
    #--------------------------------------------------------------------------#
    # DisplayCoordAttrFrame                                                    #
    # Create widgets to configure attributes of coordinate system              #
    #--------------------------------------------------------------------------#
    proc DisplayCoordAttrFrame { type } {
        variable win;
        
        # delete widgets(orthogonal)
        if { [ winfo exists $win(base).lfCoordAttr.btnOrigin ] } {
            destroy $win(base).lfCoordAttr.btnOrigin;
        }
        if { [ winfo exists $win(base).lfCoordAttr.btnSyst ] } {
            destroy $win(base).lfCoordAttr.btnSyst;
        }
        if { [ winfo exists .renumber.lfCoordAttr.frmRenumberRule ] } {
            destroy .renumber.lfCoordAttr.frmRenumberRule;
        }
        if { [ winfo exists .renumber.lfCoordAttr.frmRenumberRule.frmRenumberRule ] } {
            destroy .renumber.lfCoordAttr.frmRenumberRule.frmRenumberRule;
        }
        
        # delete widgets(cylindrical)
        if { [ winfo exists $win(base).lfCoordAttr.lblOrigin ] } {
            destroy $win(base).lfCoordAttr.lblOrigin;
        }
        if { [ winfo exists $win(base).lfCoordAttr.btnOrigin ] } {
            destroy $win(base).lfCoordAttr.btnOrigin;
        }
        if { [ winfo exists .renumber.lfCoordAttr.frmAxisType ] } {
            destroy .renumber.lfCoordAttr.frmAxisType;
        }
        if { [ winfo exists .renumber.lfCoordAttr.frmAxisType.frmAxisType ] } {
            destroy .renumber.lfCoordAttr.frmAxisType.frmAxisType;
        }   
        if { [ winfo exists $win(base).lfCoordAttr.btnEntity ] } {
            destroy $win(base).lfCoordAttr.btnEntity;
        }
         
        
        switch $type {
            "orthogonal" {
                button $win(base).lfCoordAttr.btnSyst -text "system" -bg "#E6E664" -activebackground "#E6E664" -relief flat -padx 3 -width 8 -command { ::_MHICAE::RENUMBER::SelectCoordSyst };
                place $win(base).lfCoordAttr.btnSyst -x 5 -y 8 -height 26;
                set renumberRuleFrame [ frame $win(base).lfCoordAttr.frmRenumberRule -bd 0 -relief flat -height 26 ];
                set renumberRuleMenu [ ::_MHICAE::RENUMBER::RenumberRuleMenu $renumberRuleFrame ];
                set renumberRule [ CanvasButton $renumberRuleFrame.frmRenumberRule 60 26 \
                        relief groov \
                        text "X-axis" \
                        popupMenu $renumberRuleMenu ];
                place $renumberRuleFrame -x 70 -y 8 -height 26;
                pack $renumberRule -side left -anchor nw;
                set ::_MHICAE::RENUMBER::axis X; 
            }
            "cylindrical" {  
                label $win(base).lfCoordAttr.lblOrigin -text "origin:";
                place $win(base).lfCoordAttr.lblOrigin -x 5 -y 11;
                button $win(base).lfCoordAttr.btnOrigin -text "node" -bg "#E6E664" -activebackground "#E6E664" -relief flat -padx 3 -width 8 -command { ::_MHICAE::RENUMBER::SelectOrigin };
                place $win(base).lfCoordAttr.btnOrigin -x 40 -y 8 -height 26;
                set axisTypeFrame [ frame $win(base).lfCoordAttr.frmAxisType -bd 0 -relief flat -height 26 ];
                set axisTypeMenu [ ::_MHICAE::RENUMBER::AxisTypeMenu $axisTypeFrame ];
                set axisType [ CanvasButton $axisTypeFrame.frmAxisType 60 26 \
                        relief groov \
                        text "X-axis" \
                        popupMenu $axisTypeMenu ];
                place $axisTypeFrame -x 110 -y 8 -height 26;
                pack $axisType -side left -anchor nw;
                button $win(base).lfCoordAttr.btnEntity -text "syst" -bg "#E6E664" -activebackground "#E6E664" -relief flat -padx 3 -width 8 -command { ::_MHICAE::RENUMBER::SelectAxis };
                place $win(base).lfCoordAttr.btnEntity -x 190 -y 8 -height 26;
            }
            "spherical" {
                label $win(base).lfCoordAttr.lblOrigin -text "origin:";
                place $win(base).lfCoordAttr.lblOrigin -x 5 -y 11;
                button $win(base).lfCoordAttr.btnOrigin -text "node" -bg "#E6E664" -activebackground "#E6E664" -relief flat -padx 3 -width 8 -command { ::_MHICAE::RENUMBER::SelectOrigin } ;
                place $win(base).lfCoordAttr.btnOrigin -x 40 -y 8 -height 26;
            }
        }
        set ::_MHICAE::RENUMBER::coordSyst $type;
    } 
    
    #--------------------------------------------------------------------------#
    # RenumberRuleMenu                                                         #
    # select coordinate axis when orthogonal coordinate system is selected     #
    #--------------------------------------------------------------------------#
    proc RenumberRuleMenu { W args } {
        variable win;
        
        #create the pull down menu
        if {[winfo exists $W.menu]} {
            destroy $W.menu;
        }
        set menu [ menu $W.menu -tearoff 0];
    
        # menu text
        $menu add command -compound left -label "X-axis" -command { set ::_MHICAE::RENUMBER::axis X };
        $menu add command -compound left -label "Y-axis" -command { set ::_MHICAE::RENUMBER::axis Y };
        $menu add command -compound left -label "Z-axis" -command { set ::_MHICAE::RENUMBER::axis Z };
    
        return $menu;
    }
    
    #--------------------------------------------------------------------------#
    # AxisTypeMenu                                                             #
    # select axis type of cylindrical coordinate system                        #
    #--------------------------------------------------------------------------#
    proc AxisTypeMenu { W args } {
        variable win;
        
        #create the pull down menu
        if {[winfo exists $W.menu]} {
            destroy $W.menu;
        }
        set menu [ menu $W.menu -tearoff 0];
    
        # menu text
        $menu add command -compound left -label "X-axis" -command { ::_MHICAE::RENUMBER::SwitchAxisType "system" X };
        $menu add command -compound left -label "Y-axis" -command { ::_MHICAE::RENUMBER::SwitchAxisType "system" Y };
        $menu add command -compound left -label "Z-axis" -command { ::_MHICAE::RENUMBER::SwitchAxisType "system" Z };
        $menu add command -compound left -label "nodes" -command { ::_MHICAE::RENUMBER::SwitchAxisType "nodes" 0 };
        $menu add command -compound left -label "line" -command { ::_MHICAE::RENUMBER::SwitchAxisType "line" 0 };
        $menu add command -compound left -label "vector"  -command { ::_MHICAE::RENUMBER::SwitchAxisType "vector" 0 };
    
        return $menu;
    }
    
    #--------------------------------------------------------------------------#
    # SwitchAxisType                                                           #
    # switch entity select button when cylindrical coordinate axis is changed  #
    #--------------------------------------------------------------------------#
    proc SwitchAxisType { type axis } {
        variable win;
        
        switch $type {
            "system" {
                $win(base).lfCoordAttr.btnEntity configure -text "syst";
                set ::_MHICAE::RENUMBER::cylindricalAxis $axis; 
            }
            "nodes" {
                $win(base).lfCoordAttr.btnEntity configure -text "nodes";
            }
            "line" {
                $win(base).lfCoordAttr.btnEntity configure -text "line";
            }
            "vector" {
                $win(base).lfCoordAttr.btnEntity configure -text "vector";
            }
        }
    } 
    
    #--------------------------------------------------------------------------#
    # UnManageWindow                                                           #
    # This function is called when the window is closed                        #
    #--------------------------------------------------------------------------#
    Proc UnManageWindow { } {
        variable win;

        *clearmark nodes 1;
        *clearmark nodes 2;
        *clearmark elems 1;
        *clearmark elems 2;

        destroy $win(base);
    }
    
    #--------------------------------------------------------------------------#
    # Destroy                                                                  #
    # This function delete window and name space                               #
    #--------------------------------------------------------------------------#
    proc Destroy {} {
        variable win;
        
        ::_MHICAE::RENUMBER::UnManageWindow;
        namespace delete ::_MHICAE::RENUMBER;   
    }
    
    #--------------------------------------------------------------------------#
    # GetMaxId                                                                 #
    # return id which is added 1 to max entity id                              #
    #--------------------------------------------------------------------------#
    proc ::_MHICAE::RENUMBER::GetMaxId {} {
        variable win;
        
        set type [ $win(base).btnEntity cget -text ];
        hm_completemenuoperation;
        switch $type {
            "nodes" {
                set ::_MHICAE::RENUMBER::startId [ expr [ hm_entitymaxid nodes ] + 1 ];
            }
            "elems" {
                set ::_MHICAE::RENUMBER::startId [ expr [ hm_entitymaxid elems ] + 1 ];
            } 
        }
    }
    
    #--------------------------------------------------------------------------#
    # SelectRenumberedEntity                                                   #
    # select entities which must be renumbered                                 #
    #--------------------------------------------------------------------------#
    proc SelectRenumberedEntity {} {
        variable win;
        
        set ::_MHICAE::RENUMBER::selectedNodes "";
        set ::_MHICAE::RENUMBER::selectedElems "";
        set entityType [ $win(base).btnEntity cget -text ];
        
        wm iconify $win(base);
        
        switch $entityType {
            "nodes" {
                *createmarkpanel nodes 1 "Select entities to renumber.";
                if { [ hm_marklength nodes 1 ] != 0 } {
                    set ::_MHICAE::RENUMBER::selectedNodes [ hm_getmark nodes 1 ];
                }
                *clearmark nodes 1;
            }
            "elems" {
                *createmarkpanel elems 1 "Select entities to renumber.";
                if { [ hm_marklength elems 1 ] != 0 } {
                    set ::_MHICAE::RENUMBER::selectedElems [ hm_getmark elems 1 ];
                }
                *clearmark elems 1;
            }
        }
        
        wm deiconify $win(base);
    }
    
    #--------------------------------------------------------------------------#
    # SelectCoordSyst                                                          #
    # select coordinate system to specify axis direction                       #
    #--------------------------------------------------------------------------#
    proc SelectCoordSyst {} {
        variable win;
        
        wm iconify $win(base);
        
        *createmarkpanel systs 1 "Select coordinates system.";
        if { [ hm_marklength systs 1 ] == 1 } {
            set ::_MHICAE::RENUMBER::selectedCoordSyst [ hm_getmark systs 1 ];
        }
        *clearmark systs 1;
        
        wm deiconify $win(base);
    }
    
    #--------------------------------------------------------------------------#
    # SelectOrigin                                                             #
    # select origin node to specify origin of coordinate system                #
    #--------------------------------------------------------------------------#
    proc SelectOrigin {} {
        variable win;
        
        wm iconify $win(base);
        
        *createmarkpanel nodes 1 "Select node for origin.";
        if { [ hm_marklength nodes 1 ] != 1 } {
            tk_messageBox -message "Select one node." -type "ok" -title "WARNING" -icon warning;
            wm deiconify $win(base);
            return;    
        }
        set ::_MHICAE::RENUMBER::origin [ hm_getmark nodes 1 ];
        *clearmark nodes 1; 
        
        wm deiconify $win(base); 
    }
    
    #--------------------------------------------------------------------------#
    # SelectAxis                                                               #
    # select entity to specify direction of coordinate axis                    #
    #--------------------------------------------------------------------------#
    proc SelectAxis {} {
        variable win;
        
        set type [ $win(base).lfCoordAttr.btnEntity cget -text ];
        
        wm iconify $win(base);
        
        switch $type {
            "syst" {
                *createmarkpanel systs 1 "Select one coordinate system.";
                if { [ hm_marklength systs 1 ] == 1 } {
                    set ::_MHICAE::RENUMBER::axisSystem [ hm_getmark systs 1 ];
                } else {
                    set ::_MHICAE::RENUMBER::axisSystem 0;
                }
                *clearmark systs 1; 
            }
            "nodes" {
                *createmarkpanel nodes 1 "Select begin and end nodes.";
                if { [ hm_marklength nodes 1 ] != 2 } {
                    tk_messageBox -message "Select two nodes." -type "ok" -title "WARNING" -icon warning;
                    *clearmark nodes 1;
                    wm deiconify $win(base);
                    return;
                }
                set ::_MHICAE::RENUMBER::axisNodes [ hm_getmark nodes 1 ];
                *clearmark nodes 1;
            }
            "line" {
                *createmarkpanel lines 1 "Select one line.";
                if { [ hm_marklength lines 1 ] != 1 } {
                    tk_messageBox -message "Select one line." -type "ok" -title "WARNING" -icon warning;
                    *clearmark lines 1;
                    wm deiconify $win(base);
                    return;
                }
                set ::_MHICAE::RENUMBER::axisLine [ hm_getmark lines 1 ];
                *clearmark lines 1;
            }
            "vector" {
                *createmarkpanel vectors 1 "Select one vector.";
                if { [ hm_marklength vectors 1 ] != 1 } {
                    tk_messageBox -message "Select one vector." -type "ok" -title "WARNING" -icon warning;
                    *clearmark vectors 1;
                    wm deiconify $win(base);
                    return;
                }
                set ::_MHICAE::RENUMBER::axisVector [ hm_getmark vectors 1 ];
                *clearmark vectors 1;
            }
        }
        
        wm deiconify $win(base); 
    
    }
    
    #--------------------------------------------------------------------------#
    # Renumber                                                                 #
    # renumber entities                                                        #
    #--------------------------------------------------------------------------#
    proc Renumber {} {
        variable win;
        
        if { ![ string is integer $::_MHICAE::RENUMBER::startId ] || $::_MHICAE::RENUMBER::startId <= 0 } {
            tk_messageBox -message "Start ID is invalid." -type "ok" -icon warning -title "WARNING";
            return;
        }
        
        if { "$::_MHICAE::RENUMBER::coordSyst" == "cylindrical" || "$::_MHICAE::RENUMBER::coordSyst" == "spherical" } {
            if { ![ hm_entityinfo exist nodes $::_MHICAE::RENUMBER::origin ] } {
                tk_messageBox -message "Select origin node." -type "ok" -icon warning -title "WARNING";
                return;
            } 
        }
        
        set type [ $win(base).btnEntity cget -text ]; 
        
        *entityhighlighting 0;
        hm_blockmessages 1;
        
        switch $type {
            "nodes" {
            
                set listlength [ llength $::_MHICAE::RENUMBER::selectedNodes ];
                if { $listlength == 0 } {
                    tk_messageBox -message "Select entities to renumber." -type "ok" -icon warning  -title "WARNING";
                    *entityhighlighting 1;
                    hm_blockmessages 0;
                    return;
                }
            
                # renumber IDs if entity ID collision will occur
                if { $::_MHICAE::RENUMBER::startId <= [ hm_entitymaxid nodes ] } {
                    if { [ expr $::_MHICAE::RENUMBER::startId + $listlength ] > [ hm_entitymaxid nodes ] } {
                        set offset [ expr $::_MHICAE::RENUMBER::startId + $listlength ]; 
                    } else {
                        set offset [ expr [ hm_entitymaxid nodes ] - $::_MHICAE::RENUMBER::startId + 1 ];
                    }
                    *createmark nodes 1 ${::_MHICAE::RENUMBER::startId}-[ expr $::_MHICAE::RENUMBER::startId + $listlength - 1];
                    eval *createmark nodes 2 $::_MHICAE::RENUMBER::selectedNodes;
                    *markintersection nodes 2 nodes 1;
                    set intersectionList [ hm_getmark nodes 2 ];                                  
                    if { [ hm_marklength nodes 1 ] != 0 } {
                        *renumber nodes 1 $::_MHICAE::RENUMBER::startId 1 $offset 1;
                        if { [ llength $intersectionList ] != 0 } {
                            foreach nid $intersectionList {
                                set index [ lsearch $::_MHICAE::RENUMBER::selectedNodes $nid ];
                                set newId [ expr $nid + $offset ];
                                set ::_MHICAE::RENUMBER::selectedNodes [ lreplace $::_MHICAE::RENUMBER::selectedNodes $index $index $newId ]; 
                            }
                        }                     
                    }
                    *clearmark nodes 1;
                    *clearmark nodes 2;
                    unset intersectionList;
                } 
                
                switch $::_MHICAE::RENUMBER::coordSyst {
                    "orthogonal" {
                        switch $::_MHICAE::RENUMBER::axis {
                            "X" {
                                if { $::_MHICAE::RENUMBER::selectedCoordSyst == 0 } {
                                    set axis_x 1.0;
                                    set axis_y 0.0;
                                    set axis_z 0.0;
                                } else {
                                    set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalxaxisx 0 ];
                                    set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalxaxisy 0 ];
                                    set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalxaxisz 0 ];
                                }    
                            }
                            "Y" {
                                if { $::_MHICAE::RENUMBER::selectedCoordSyst == 0 } {
                                    set axis_x 0.0;
                                    set axis_y 1.0;
                                    set axis_z 0.0;
                                } else {
                                    set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalyaxisx 0 ];
                                    set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalyaxisy 0 ];
                                    set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalyaxisz 0 ];
                                }    
                            }
                            "Z" {
                                if { $::_MHICAE::RENUMBER::selectedCoordSyst == 0 } {
                                    set axis_x 0.0;
                                    set axis_y 0.0;
                                    set axis_z 1.0;
                                } else {
                                    set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalzaxisx 0 ];
                                    set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalzaxisy 0 ];
                                    set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalzaxisz 0 ];
                                }    
                            }
                        }
                        if { [ info exists varForSort ] } {
                            unset varForSort;
                        }
                        set coordList "";
                        foreach nid $::_MHICAE::RENUMBER::selectedNodes {
                            set nx [ hm_getentityvalue nodes $nid globalx 0 ];
                            set ny [ hm_getentityvalue nodes $nid globaly 0 ];
                            set nz [ hm_getentityvalue nodes $nid globalz 0 ];
                            set coordValue [ expr $axis_x * $nx + $axis_y * $ny + $axis_z * $nz ];
                            lappend varForSort(${coordValue}) $nid;
                            lappend coordList $coordValue;
                        }
                        if { $::_MHICAE::RENUMBER::reverse == 0 } {
                            set keys [ lsort -real -increasing $coordList ];
                        } else {
                            set keys [ lsort -real -decreasing $coordList ];
                        }
                        set newId $::_MHICAE::RENUMBER::startId;
                        foreach key $keys {
                            eval *createmark nodes 1 $varForSort(${key});
                            set marklength [ hm_marklength nodes 1 ];
                            if { $marklength != 0 } {
                                *renumber nodes 1 $newId 1 0 0;
                                incr newId $marklength;    
                            }     
                        }
                        *clearmark nodes 1; 
                    }
                    "cylindrical" {
                        set axisType [ $win(base).lfCoordAttr.btnEntity cget -text ];
                        switch $axisType {
                            "syst" {
                                switch $::_MHICAE::RENUMBER::cylindricalAxis {
                                    "X" {
                                        if { $::_MHICAE::RENUMBER::axisSystem == 0 } {
                                            set axis_x 1.0;
                                            set axis_y 0.0;
                                            set axis_z 0.0;
                                        } else {
                                            set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalxaxisx 0 ];
                                            set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalxaxisy 0 ];
                                            set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalxaxisz 0 ];
                                        } 
                                    }
                                    "Y" {
                                        if { $::_MHICAE::RENUMBER::axisSystem == 0 } {
                                            set axis_x 0.0;
                                            set axis_y 1.0;
                                            set axis_z 0.0;
                                        } else {
                                            set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalyaxisx 0 ];
                                            set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalyaxisy 0 ];
                                            set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalyaxisz 0 ];
                                        }
                                    }
                                    "Z" {
                                        if { $::_MHICAE::RENUMBER::axisSystem == 0 } {
                                            set axis_x 0.0;
                                            set axis_y 0.0;
                                            set axis_z 1.0;
                                        } else {
                                            set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalzaxisx 0 ];
                                            set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalzaxisy 0 ];
                                            set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalzaxisz 0 ];
                                        }
                                    }
                                }   
                            }
                            "nodes" {
                                set s_n [ lindex $::_MHICAE::RENUMBER::axisNodes 0 ];
                                set e_n [ lindex $::_MHICAE::RENUMBER::axisNodes 1 ];
                                set axis_x [ expr [ hm_getentityvalue nodes $e_n globalx 0 ] - [ hm_getentityvalue nodes $s_n globalx 0 ] ];
                                set axis_y [ expr [ hm_getentityvalue nodes $e_n globaly 0 ] - [ hm_getentityvalue nodes $s_n globaly 0 ] ];
                                set axis_z [ expr [ hm_getentityvalue nodes $e_n globalz 0 ] - [ hm_getentityvalue nodes $s_n globalz 0 ] ];
                            }
                            "line" {
                                set coords [ hm_getcoordinatesofpointsonline $::_MHICAE::RENUMBER::axisLine [ list 0.0 1.0 ] ];
                                set s_c [ lindex $coords 0 ];
                                set e_c [ lindex $coords 1 ];
                                set axis_x [ expr [ lindex $e_c 0 ] - [ lindex $s_c 0 ] ];
                                set axis_y [ expr [ lindex $e_c 1 ] - [ lindex $s_c 1 ] ];
                                set axis_z [ expr [ lindex $e_c 2 ] - [ lindex $s_c 2 ] ];   
                            }
                            "vector" {
                                set axis_x [ hm_getentityvalue vectors $::_MHICAE::RENUMBER::axisVector xcomp 0 ];
                                set axis_y [ hm_getentityvalue vectors $::_MHICAE::RENUMBER::axisVector ycomp 0 ];
                                set axis_z [ hm_getentityvalue vectors $::_MHICAE::RENUMBER::axisVector zcomp 0 ];
                            } 
                        } 
                        if { "$axisType" == "nodes" || "$axisType" == "line" } {
                            set norm [ expr sqrt(pow(${axis_x}, 2) + pow(${axis_y}, 2) + pow(${axis_z}, 2)) ];
                            set axis_x [ expr $axis_x / $norm ];
                            set axis_y [ expr $axis_y / $norm ];
                            set axis_z [ expr $axis_z / $norm ];
                        }
                        set o_x [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalx 0 ];
                        set o_y [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globaly 0 ];
                        set o_z [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalz 0 ];
                        if { [ info exists varForSort ] } {
                            unset varForSort;
                        }
                        set coordList "";
                        foreach nid $::_MHICAE::RENUMBER::selectedNodes {
                            set v_x [ expr [ hm_getentityvalue nodes $nid globalx 0 ] - $o_x ];
                            set v_y [ expr [ hm_getentityvalue nodes $nid globaly 0 ] - $o_y ];
                            set v_z [ expr [ hm_getentityvalue nodes $nid globalz 0 ] - $o_z ];
                            set v_norm [ expr sqrt(pow(${v_x}, 2) + pow(${v_y}, 2) + pow(${v_z}, 2)) ]; 
                            if { $v_norm != 0.0 } {
                                set theta [ expr acos(($axis_x * $v_x + $axis_y * $v_y + $axis_z * $v_z) / $v_norm) ];
                            } else {
                                set theta 0.0;
                            }
                            set coordValue [ expr $v_norm * sin(${theta}) ];
                            lappend varForSort(${coordValue}) $nid;
                            lappend coordList $coordValue;     
                        }
                        if { $::_MHICAE::RENUMBER::reverse == 0 } {
                            set keys [ lsort -real -increasing $coordList ];
                        } else {
                            set keys [ lsort -real -decreasing $coordList ];
                        }
                        set newId $::_MHICAE::RENUMBER::startId;
                        foreach key $keys {
                            eval *createmark nodes 1 $varForSort(${key});
                            set marklength [ hm_marklength nodes 1 ];
                            if { $marklength != 0 } {
                                *renumber nodes 1 $newId 1 0 0;
                                incr newId $marklength;    
                            }     
                        }
                        *clearmark nodes 1; 
                    }
                    "spherical" {
                        set o_x [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalx 0 ];
                        set o_y [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globaly 0 ];
                        set o_z [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalz 0 ];
                        if { [ info exists varForSort ] } {
                            unset varForSort;
                        }
                        set coordList "";
                        foreach nid $::_MHICAE::RENUMBER::selectedNodes {
                            set v_x [ expr [ hm_getentityvalue nodes $nid globalx 0 ] - $o_x ];
                            set v_y [ expr [ hm_getentityvalue nodes $nid globaly 0 ] - $o_y ];
                            set v_z [ expr [ hm_getentityvalue nodes $nid globalz 0 ] - $o_z ];
                            set coordValue [ expr sqrt(pow(${v_x}, 2) + pow(${v_y}, 2) + pow(${v_z}, 2)) ];
                            lappend varForSort(${coordValue}) $nid;
                            lappend coordList $coordValue;
                        }
                        if { $::_MHICAE::RENUMBER::reverse == 0 } {
                            set keys [ lsort -real -increasing $coordList ];
                        } else {
                            set keys [ lsort -real -decreasing $coordList ];
                        }
                        set newId $::_MHICAE::RENUMBER::startId;
                        foreach key $keys {
                            eval *createmark nodes 1 $varForSort(${key});
                            set marklength [ hm_marklength nodes 1 ];
                            if { $marklength != 0 } {
                                *renumber nodes 1 $newId 1 0 0;
                                incr newId $marklength;    
                            }     
                        }
                        *clearmark nodes 1;
                    }
                }
                                    
            }
            "elems" {
            
                set listlength [ llength $::_MHICAE::RENUMBER::selectedElems ];
                if { $listlength == 0 } {
                    tk_messageBox -message "Select entities to renumber." -type "ok" -icon warning  -title "WARNING";
                    *entityhighlighting 1;
                    hm_blockmessages 0;
                    return;
                }
            
                # renumber IDs if entity ID collision will occur
                if { $::_MHICAE::RENUMBER::startId <= [ hm_entitymaxid elems ] } {
                    if { [ expr $::_MHICAE::RENUMBER::startId + $listlength ] > [ hm_entitymaxid elems ] } {
                        set offset [ expr $::_MHICAE::RENUMBER::startId + $listlength ]; 
                    } else {
                        set offset [ expr [ hm_entitymaxid elems ] - $::_MHICAE::RENUMBER::startId + 1 ];
                    }
                    *createmark elems 1 ${::_MHICAE::RENUMBER::startId}-[ expr $::_MHICAE::RENUMBER::startId + $listlength - 1];
                    eval *createmark elems 2 $::_MHICAE::RENUMBER::selectedElems;
                    *markintersection elems 2 elems 1;
                    set intersectionList [ hm_getmark elems 2 ];                                  
                    if { [ hm_marklength elems 1 ] != 0 } {
                        *renumber elems 1 $::_MHICAE::RENUMBER::startId 1 $offset 1;
                        if { [ llength $intersectionList ] != 0 } {
                            foreach eid $intersectionList {
                                set index [ lsearch $::_MHICAE::RENUMBER::selectedElems $eid ];
                                set newId [ expr $eid + $offset ];
                                set ::_MHICAE::RENUMBER::selectedElems [ lreplace $::_MHICAE::RENUMBER::selectedElems $index $index $newId ]; 
                            }
                        }                     
                    }
                    *clearmark elems 1;
                    *clearmark elems 2;
                    unset intersectionList;
                } 
                
                switch $::_MHICAE::RENUMBER::coordSyst {
                    "orthogonal" {
                        switch $::_MHICAE::RENUMBER::axis {
                            "X" {
                                if { $::_MHICAE::RENUMBER::selectedCoordSyst == 0 } {
                                    set axis_x 1.0;
                                    set axis_y 0.0;
                                    set axis_z 0.0;
                                } else {
                                    set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalxaxisx 0 ];
                                    set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalxaxisy 0 ];
                                    set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalxaxisz 0 ];
                                }    
                            }
                            "Y" {
                                if { $::_MHICAE::RENUMBER::selectedCoordSyst == 0 } {
                                    set axis_x 0.0;
                                    set axis_y 1.0;
                                    set axis_z 0.0;
                                } else {
                                    set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalyaxisx 0 ];
                                    set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalyaxisy 0 ];
                                    set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalyaxisz 0 ];
                                }    
                            }
                            "Z" {
                                if { $::_MHICAE::RENUMBER::selectedCoordSyst == 0 } {
                                    set axis_x 0.0;
                                    set axis_y 0.0;
                                    set axis_z 1.0;
                                } else {
                                    set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalzaxisx 0 ];
                                    set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalzaxisy 0 ];
                                    set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::selectedCoordSyst globalzaxisz 0 ];
                                }    
                            }
                        }
                        if { [ info exists varForSort ] } {
                            unset varForSort;
                        }
                        set coordList "";
                        foreach eid $::_MHICAE::RENUMBER::selectedElems {
                            set cx [ hm_getentityvalue elems $eid centerx 0 ];
                            set cy [ hm_getentityvalue elems $eid centery 0 ];
                            set cz [ hm_getentityvalue elems $eid centerz 0 ];
                            set coordValue [ expr $axis_x * $cx + $axis_y * $cy + $axis_z * $cz ];
                            lappend varForSort(${coordValue}) $eid;
                            lappend coordList $coordValue;
                        }
                        if { $::_MHICAE::RENUMBER::reverse == 0 } {
                            set keys [ lsort -real -increasing $coordList ];
                        } else {
                            set keys [ lsort -real -decreasing $coordList ];
                        }
                        set newId $::_MHICAE::RENUMBER::startId;
                        foreach key $keys {
                            eval *createmark elems 1 $varForSort(${key});
                            set marklength [ hm_marklength elems 1 ];
                            if { $marklength != 0 } {
                                *renumber elems 1 $newId 1 0 0;
                                incr newId $marklength;    
                            }     
                        }
                        *clearmark elems 1; 
                    }
                    "cylindrical" {
                        set axisType [ $win(base).lfCoordAttr.btnEntity cget -text ];
                        switch $axisType {
                            "syst" {
                                switch $::_MHICAE::RENUMBER::cylindricalAxis {
                                    "X" {
                                        if { $::_MHICAE::RENUMBER::axisSystem == 0 } {
                                            set axis_x 1.0;
                                            set axis_y 0.0;
                                            set axis_z 0.0;
                                        } else {
                                            set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalxaxisx 0 ];
                                            set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalxaxisy 0 ];
                                            set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalxaxisz 0 ];
                                        } 
                                    }
                                    "Y" {
                                        if { $::_MHICAE::RENUMBER::axisSystem == 0 } {
                                            set axis_x 0.0;
                                            set axis_y 1.0;
                                            set axis_z 0.0;
                                        } else {
                                            set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalyaxisx 0 ];
                                            set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalyaxisy 0 ];
                                            set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalyaxisz 0 ];
                                        }
                                    }
                                    "Z" {
                                        if { $::_MHICAE::RENUMBER::axisSystem == 0 } {
                                            set axis_x 0.0;
                                            set axis_y 0.0;
                                            set axis_z 1.0;
                                        } else {
                                            set axis_x [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalzaxisx 0 ];
                                            set axis_y [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalzaxisy 0 ];
                                            set axis_z [ hm_getentityvalue systs $::_MHICAE::RENUMBER::axisSystem globalzaxisz 0 ];
                                        }
                                    }
                                }   
                            }
                            "nodes" {
                                set s_n [ lindex $::_MHICAE::RENUMBER::axisNodes 0 ];
                                set e_n [ lindex $::_MHICAE::RENUMBER::axisNodes 1 ];
                                set axis_x [ expr [ hm_getentityvalue nodes $e_n globalx 0 ] - [ hm_getentityvalue nodes $s_n globalx 0 ] ];
                                set axis_y [ expr [ hm_getentityvalue nodes $e_n globaly 0 ] - [ hm_getentityvalue nodes $s_n globaly 0 ] ];
                                set axis_z [ expr [ hm_getentityvalue nodes $e_n globalz 0 ] - [ hm_getentityvalue nodes $s_n globalz 0 ] ];
                            }
                            "line" {
                                set coords [ hm_getcoordinatesofpointsonline $::_MHICAE::RENUMBER::axisLine [ list 0.0 1.0 ] ];
                                set s_c [ lindex $coords 0 ];
                                set e_c [ lindex $coords 1 ];
                                set axis_x [ expr [ lindex $e_c 0 ] - [ lindex $s_c 0 ] ];
                                set axis_y [ expr [ lindex $e_c 1 ] - [ lindex $s_c 1 ] ];
                                set axis_z [ expr [ lindex $e_c 2 ] - [ lindex $s_c 2 ] ];   
                            }
                            "vector" {
                                set axis_x [ hm_getentityvalue vectors $::_MHICAE::RENUMBER::axisVector xcomp 0 ];
                                set axis_y [ hm_getentityvalue vectors $::_MHICAE::RENUMBER::axisVector ycomp 0 ];
                                set axis_z [ hm_getentityvalue vectors $::_MHICAE::RENUMBER::axisVector zcomp 0 ];
                            } 
                        } 
                        if { "$axisType" == "nodes" || "$axisType" == "line" } {
                            set norm [ expr sqrt(pow(${axis_x}, 2) + pow(${axis_y}, 2) + pow(${axis_z}, 2)) ];
                            set axis_x [ expr $axis_x / $norm ];
                            set axis_y [ expr $axis_y / $norm ];
                            set axis_z [ expr $axis_z / $norm ];
                        }
                        set o_x [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalx 0 ];
                        set o_y [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globaly 0 ];
                        set o_z [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalz 0 ];
                        if { [ info exists varForSort ] } {
                            unset varForSort;
                        }
                        set coordList "";
                        foreach eid $::_MHICAE::RENUMBER::selectedElems {
                            set v_x [ expr [ hm_getentityvalue elems $eid centerx 0 ] - $o_x ];
                            set v_y [ expr [ hm_getentityvalue elems $eid centery 0 ] - $o_y ];
                            set v_z [ expr [ hm_getentityvalue elems $eid centerz 0 ] - $o_z ];
                            set v_norm [ expr sqrt(pow(${v_x}, 2) + pow(${v_y}, 2) + pow(${v_z}, 2)) ]; 
                            if { $v_norm != 0.0 } {
                                set theta [ expr acos(($axis_x * $v_x + $axis_y * $v_y + $axis_z * $v_z) / $v_norm) ];
                            } else {
                                set theta 0.0;
                            }
                            set coordValue [ expr $v_norm * sin(${theta}) ];
                            lappend varForSort(${coordValue}) $eid;
                            lappend coordList $coordValue;     
                        }
                        if { $::_MHICAE::RENUMBER::reverse == 0 } {
                            set keys [ lsort -real -increasing $coordList ];
                        } else {
                            set keys [ lsort -real -decreasing $coordList ];
                        }
                        set newId $::_MHICAE::RENUMBER::startId;
                        foreach key $keys {
                            eval *createmark elems 1 $varForSort(${key});
                            set marklength [ hm_marklength elems 1 ];
                            if { $marklength != 0 } {
                                *renumber elems 1 $newId 1 0 0;
                                incr newId $marklength;    
                            }     
                        }
                        *clearmark elems 1; 
                    }
                    "spherical" {
                        set o_x [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalx 0 ];
                        set o_y [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globaly 0 ];
                        set o_z [ hm_getentityvalue nodes $::_MHICAE::RENUMBER::origin globalz 0 ];
                        if { [ info exists varForSort ] } {
                            unset varForSort;
                        }
                        set coordList "";
                        foreach eid $::_MHICAE::RENUMBER::selectedElems {
                            set v_x [ expr [ hm_getentityvalue elems $eid centerx 0 ] - $o_x ];
                            set v_y [ expr [ hm_getentityvalue elems $eid centery 0 ] - $o_y ];
                            set v_z [ expr [ hm_getentityvalue elems $eid centerz 0 ] - $o_z ];
                            set coordValue [ expr sqrt(pow(${v_x}, 2) + pow(${v_y}, 2) + pow(${v_z}, 2)) ];
                            lappend varForSort(${coordValue}) $eid;
                            lappend coordList $coordValue;
                        }
                        if { $::_MHICAE::RENUMBER::reverse == 0 } {
                            set keys [ lsort -real -increasing $coordList ];
                        } else {
                            set keys [ lsort -real -decreasing $coordList ];
                        }
                        set newId $::_MHICAE::RENUMBER::startId;
                        foreach key $keys {
                            eval *createmark elems 1 $varForSort(${key});
                            set marklength [ hm_marklength elems 1 ];
                            if { $marklength != 0 } {
                                *renumber elems 1 $newId 1 0 0;
                                incr newId $marklength;    
                            }     
                        }
                        *clearmark elems 1;
                    }
                }
            
            }
        }
        unset varForSort;
        unset coordList;
        *entityhighlighting 1;
        hm_blockmessages 0;
        
    }
    
}