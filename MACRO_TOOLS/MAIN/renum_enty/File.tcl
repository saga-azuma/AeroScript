# change log: 
#   - INSTALL_DIR changes to <current_dir>/MACRO_TOOLS
#   - "err" of "tk_messageBox -icon" changes to warning
#   - renumid.exe のところをダブルコーテションなしにすると、フォルダ、ファイルに
#     スペースが入っていても動いた
#------------------------------------------------------------------------------#
#  Copyright (c) 2004 Altair Engineering Inc. All Rights Reserved              #
#  Contains trade secrets of Altair Engineering, Inc.Copyright notice          #
#  does not imply publication.Decompilation or disassembly of this             #
#  software is strictly prohibited.            Update : 02/02/2005             #
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
# Global Valuables                                                             #
#------------------------------------------------------------------------------#

#Sets program environment
#set INSTALL_DIR         "__INSTALL_DIR__";
set INSTALL_DIR         [pwd];
set RENUMIDS_EXEC_MACRO_DIR  "${INSTALL_DIR}/MACRO_TOOLS/MAIN/BIN";

option add *Font {{Tahoma} 8 roman};
option add *Dialog.msg.font {{Tahoma} 8 roman};
SetAppFont Tahoma

namespace eval ::File_Tool {

    #--------------------------------------------------------------------------#
    # Main                                                                     #
    # Main program                                                             #
    #--------------------------------------------------------------------------#
    proc Import { } {
        
        global RENUMIDS_EXEC_MACRO_DIR;

        set ALTAIR_HOME [ hm_info -appinfo ALTAIR_HOME ]
# Get current folder name  #
        set cwd    [ pwd ]

        set fltyp  { { "NASTRAN BULK DATA" {*.nas *.dat *.bdf *.blk *.bulk } } {"HM file" {*.hm} } {"All files" *} };
        set DialogTitle "Select Nastran Bulk Data";
        set FileName [ tk_getOpenFile -filetypes $fltyp -parent . -initialdir $cwd -title $DialogTitle -x [ expr [ winfo screenwidth . ] - 505] -y 20 ];
        if { $FileName != "" } {
             hm_answernext "yes"
             *deletemodel
             if { [ file extension $FileName ] == ".hm" } {
                *readfile $FileName
             } else {
                 set Hm_BulkName ${FileName}_hmblk

                 #catch { exec cmd.exe /c "${RENUMIDS_EXEC_MACRO_DIR}/RenumId.exe ${FileName} ${FileName}_hmblk" } err
                 # fix: to work when the dir name has space chars.
                 catch { exec cmd.exe /c ${RENUMIDS_EXEC_MACRO_DIR}/RenumId.exe ${FileName} ${FileName}_hmblk } err
                 if { [ file exist $Hm_BulkName ] } {
                     set FEINPUT "\#nastran\\nastran";
                     *displayimporterrors 1
                     *feinput "$FEINPUT" "$Hm_BulkName" 0 0 -0.01 1 0;
                     *displayimporterrors 0
#                     *displaycollectorwithfilter loadcols "none" "" 1 0
#                     *elementhandle 0
                     tk_messageBox -parent . -title "Information" -icon info -message "Nastran bulk data was imported." -type ok;
                 } else {
#                     tk_messageBox -parent . -title "Information" -icon err -message "$err" -type ok;
                     tk_messageBox -parent . -title "Information" -icon warning -message "$err" -type ok;
                 }
             }
        }
    }

    #--------------------------------------------------------------------------#
    # Export_BDF                                                               #
    # Export Nastran bulk data                                                 #
    #--------------------------------------------------------------------------#
    proc Export { } {
# Get current folder name  #
        set ALTAIR_HOME [ hm_info -appinfo ALTAIR_HOME ]
        set cwd    [ pwd ]

        set fltyp  { { "NASTRAN BULK DATA" {*nas *dat *bdf} }  {"All files" *} };
        set DialogTitle "Export NASTRAN Bulk Data";
        set FileName [ tk_getSaveFile -filetypes $fltyp \
                                      -parent     .     \
                                      -initialdir $cwd  \
                                      -title $DialogTitle \
                                      -defaultextension "nas" \
                                      -x [ expr [ winfo screenwidth . ] - 505 ] \
                                      -y 20 ];
        if { $FileName != "" } {
            set FEINPUT "\#nastran\\nastran";
            hm_answernext "yes"
            *feoutput "$ALTAIR_HOME/templates/feoutput/nastran/general" $FileName 1 1 0
        }
    }


}
