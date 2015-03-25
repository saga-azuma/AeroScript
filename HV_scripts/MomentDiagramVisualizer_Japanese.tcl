############################################################
# Copyright (c) 2015 Altair Engineering Japan.  All Rights #
############## Create Moment Diagram Animation #############
########### MasahideImoto (imoto@altairjp.co.jp) ###########
############################################################
###Version 1_Rev6 Japanese###

### Output request ###
#ELFORCE(OUTPUT2) = ALL
#ELFORCE(OPTI) = ALL
#GPFORCE(OPTI) = ALL

### Set User setting variable ###
set ModelExtensions ".fem .nas .bdf .blk .bulk .dat .nastran";

### Create dict and variable ###
variable BarData [dict create];
set BarList "";

#Proc1#######################################################################################################################
proc ::StartBeamDiagram {ModelExtensions} {
	##### Check HM(FePre) client windows #####
	set clientlist "";
	set t [::post::GetT];
	catch {hwi CloseStack};
	hwi OpenStack;
	hwi GetSessionHandle		sess$t;
	sess$t GetProjectHandle		proj$t;
	set CurrentPage [proj$t GetActivePage];
	proj$t GetPageHandle    page$t $CurrentPage;
	set CurrentWind [page$t GetActiveWindow];
	for {set p 1} {$p <= [proj$t GetNumberOfPages]} {incr p} {
		proj$t SetActivePage	$p;
		proj$t GetPageHandle	page$t$p	$p;
		for {set w 1} {$w <= [page$t$p GetNumberOfWindows]} {incr w} {
			page$t$p	GetWindowHandle	wind$t$p$w	$w;
			lappend clientlist [wind$t$p$w	GetClientType];
		}
	}
	proj$t SetActivePage $CurrentPage;
	page$t SetActiveWindow $CurrentWind;
	hwi CloseStack;

	##### Display message of FePre is exist, and HV(Post) client check #####
	if {[lsearch $clientlist "FePre"] != "-1"} {
		tk_messageBox -message	"お使いのHWDでは既にHyperMesh Desktopが起動しています \n\
					HyperMesh Desktopを終了してからスクリプトを再実行して下さい";
		return;
	} elseif {[lsearch $clientlist "Animation"] != "-1"} {
		### Check input model file name ###
		set t [::post::GetT];
		hwi OpenStack;
		hwi GetSessionHandle	sess$t;
		sess$t GetProjectHandle proj$t;
		proj$t GetPageHandle    page$t [proj$t GetActivePage];
		page$t GetWindowHandle  wind$t [page$t GetActiveWindow];
		wind$t GetClientHandle  clit$t;
		clit$t GetModelHandle   modl$t [clit$t GetActiveModel];
		set ModelFileName [file nativename [modl$t GetFileName]];
		#set ResultFileName [file nativename [modl$t GetResultFileName]];
		set LoadFileDir [file dirname $ModelFileName];
		set OnlyModelName [lindex [split [file tail $ModelFileName] .] 0];

		### Search model file ###
		if {[lsearch $ModelExtensions [file extension $ModelFileName]] == "-1"} {
			set SuccessModelFound "0";
			foreach extension $ModelExtensions {
				set SearchName "$LoadFileDir\/$OnlyModelName$extension"
				if {[file exists "$SearchName"] == "1"} {
					set ModelFileName $SearchName;
					set SuccessModelFound "1";
				}
			}
			if {$SuccessModelFound == "0"} {
				set ModelFileName "";
			}
		}

		### Search force file ###
		set ForceFileName "";
		if {[file exists $LoadFileDir\/$OnlyModelName\.force] == "1"} {
			set ForceFileName "$LoadFileDir\/$OnlyModelName\.force";
		}

		### Kick GUI Proc ###
		::BeamDiagramGUI $LoadFileDir $ModelFileName $ForceFileName;
		hwi CloseStack;
	}
}



#Proc2#######################################################################################################################
### For GUI ###
proc ::BeamDiagramGUI {LoadFileDir1 ModelFileName1 ForceFileName1} {
	### Set variable ###
	variable ResultType "op2";
	variable ModelFileName $ModelFileName1;
	variable ForceFileName $ForceFileName1;
	variable LoadFileDir $LoadFileDir1;

	### Base window ###
	set w ".momentVisualizer";
	toplevel $w
	wm title $w "ビームダイアグラム";
	wm geometry $w "500x320";
	wm resizable $w 0 0;
	::hwt::KeepOnTop $w;

	### Get Altair Home ###
	set t [::post::GetT];
	hwi OpenStack;
	hwi GetSessionHandle sess$t;
	set altairhome [sess$t GetSystemVariable "ALTAIR_HOME"]

	### Get File and Force file name ###
	set forceTypeList { {{force} {.force}} {{All files} {*}} }

	### Label ###
	label $w\.beamdiagram		-text "ビームダイアグラム";

	### RadioButton ###
	radiobutton $w\.radio1 		-text ".op2ファイル" \
					-variable ::ResultType \
					-value	"op2";
	radiobutton $w\.radio2		-text ".force(OptiStruct)ファイル" \
					-variable ::ResultType \
					-value	"force";

	### Create file open image ###
	image create photo FileOpenIcon -file "$altairhome\/hw/images/fileOpen-16.png";

	### Select model file entry ###
	label $w\.modellabel		-text "ソルバーの入力ファイルを指定して下さい";
	entry $w\.modelentry		-width 70 \
					-textvariable ModelFileName;
	button $w.selectmodel		-image FileOpenIcon \
					-command {set ModelFileName [tk_getOpenFile -initialdir $LoadFileDir]}

	### Select force file entry ###
	label $w\.forcelabel		-text ".forceファイルを指定して下さい";
	entry $w\.forceentry		-width 70 \
					-textvariable ForceFileName;
	button $w.selectforce		-image FileOpenIcon \
					-command {set ForceFileName [tk_getOpenFile -initialdir $LoadFileDir -filetypes $forceTypeList]}

	#Grayout1#
	if {$ResultType == "op2"} {
		$w\.forcelabel config -font {{MS Sans Serif} 8 overstrike};
		$w\.forceentry config -state disabled -font {{MS Sans Serif} 8 overstrike};
	} else {
		$w\.forcelabel config -font {{MS Sans Serif} 8 normal};
		$w\.forceentry config -state normal -font {{MS Sans Serif} 8 normal};
	}

	# Execute button #
	button $w\.execute		-text "実行" \
					-width 14 \
					-background red \
					-foreground white \
					-command {::JudgeNextProc $::ResultType $ModelFileName $ForceFileName};

	# Quit button #
        button $w\.quit                 -text "終了" \
                                        -width 14 \
					-background blue \
					-foreground white \
                                        -command {set a [destroy .momentVisualizer]}

	#Place#
	place $w\.beamdiagram		-relx 0.05	-y 35	-anchor w;

	place $w\.radio1		-relx 0.05	-y 70	-anchor w;
	place $w\.radio2		-relx 0.45	-y 70 	-anchor w;

	place $w\.modellabel		-relx 0.05	-y 100	-anchor w;
	place $w\.modelentry		-relx 0.05	-y 120	-anchor w;
	place $w.selectmodel		-relx 0.9	-y 120	-anchor w;

	place $w\.forcelabel		-relx 0.05	-y 160	-anchor w;
	place $w\.forceentry		-relx 0.05	-y 180	-anchor w;
	place $w.selectforce		-relx 0.9	-y 180	-anchor w;

	place $w\.execute		-relx 0.72	-y 240	-anchor w;
	place $w\.quit   		-relx 0.72	-y 280	-anchor w;

	#Grayout2 Bind#
	bind $w\.radio1 <Button-1>	{.momentVisualizer.forceentry config -state disabled -font {{MS Sans Serif} 8 overstrike};\
					.momentVisualizer.forcelabel config -font {{MS Sans Serif} 8 overstrike}};
	bind $w\.radio2 <Button-1>	{.momentVisualizer.forceentry config -state normal -font {{MS Sans Serif} 8 normal};\
					.momentVisualizer.forcelabel config -font {{MS Sans Serif} 8 normal}};
	hwi CloseStack;
}



#Proc3#######################################################################################################################
proc ::JudgeNextProc {ResultType ModelFileName ForceFileName} {
	if {$ResultType == "op2"} {
		### Kick ResultCollector using OP2 ###
		::CollectResultUsingHyperViewOP2Result $ModelFileName;
	} elseif {$ResultType == "force"} {
		### Kick ResultCollector using force ###
		::CollectResultUsingOptistructForceFile $ModelFileName $ForceFileName;
	}
}



#Proc4#######################################################################################################################
proc ::CollectResultUsingHyperViewOP2Result {ModelFileName} {
	## Collect LoadCaseList and elemnet results in HV ###
	variable BarData;
	variable BarList;

	set t [::post::GetT];
 	hwi	OpenStack;
	hwi	GetSessionHandle sess$t;
	sess$t	GetProjectHandle proj$t;
	proj$t	GetPageHandle    page$t [proj$t GetActivePage];
	page$t	GetWindowHandle  wind$t [page$t GetActiveWindow];
	wind$t	GetClientHandle  clit$t;
	clit$t	GetModelHandle   modl$t [clit$t GetActiveModel];
	modl$t	GetResultCtrlHandle resu$t;
	resu$t 	GetContourCtrlHandle cont$t;

	### Add Selection Set ###
	set selsetid [modl$t AddSelectionSet element]
	modl$t GetSelectionSetHandle selec$t $selsetid;
	selec$t Add "config 60";

	### Loop subcase ###
	set LoadCaseList [resu$t GetSubcaseList Base];
	foreach s [resu$t GetSubcaseList Base] {
		resu$t SetCurrentSubcase $s;
		resu$t GetSubcaseHandle subcase$t$s $s;
		set DataCompList [subcase$t$s GetDataComponentList "1D Force" scalar];
		foreach DataComp $DataCompList {
			### Contour to BEND1 A ###
			if {$DataComp == "CBAR Bending Moment A1" || $DataComp == "CBEAM Bending Moment-Plane1 A"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;
				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s A Bend1 $value1;
				}
			}

			### Contour to BEND1 B ###
			if {$DataComp == "CBAR Bending Moment B1" || $DataComp == "CBEAM Bending Moment-Plane1 B"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;

				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s B Bend1 $value1;
				}
			}

			### Contour to BEND2 A ###
			if {$DataComp == "CBAR Bending Moment A2" || $DataComp == "CBEAM Bending Moment-Plane2 A"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;

				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s A Bend2 $value1;
				}
			}

			### Contour to BEND2 B ###
			if {$DataComp == "CBAR Bending Moment B2" || $DataComp == "CBEAM Bending Moment-Plane2 B"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;

				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s B Bend2 $value1;
				}
			}

			### Contour to Shear1 A ###
			if {$DataComp == "CBAR Shear1" || $DataComp == "CBEAM Web Shear-Plane1 A"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;

				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s A Shear1 $value1;
				}
			}

			### Contour to Shear1 B ###
			if {$DataComp == "CBAR Shear1" || $DataComp == "CBEAM Web Shear-Plane1 B"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;

				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s B Shear1 $value1;
				}
			}

			### Contour to Shear2 A ###
			if {$DataComp == "CBAR Shear2" || $DataComp == "CBEAM Web Shear-Plane2 A"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;

				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s A Shear2 $value1;
				}
			}

			### Contour to Shear2 B ###
			if {$DataComp == "CBAR Shear2" || $DataComp == "CBEAM Web Shear-Plane2 B"} {
				clit$t	SetDisplayOptions Legend	true;
				clit$t	SetActiveModel			1;
				cont$t	SetDataType			"1D Force";
				cont$t	SetDataComponent		"$DataComp";
				resu$t	SetCurrentSimulation		"1";
				cont$t	SetEnableState			true
				clit$t	SetDisplayOptions "contour" true;

				clit$t	Draw;

				set t2 [::post::GetT];

				modl$t		GetQueryCtrlHandle quey$t$t2;
				quey$t$t2	SetSelectionSet $selsetid;
				modl$t		RemoveSelectionSet $selsetid;
				quey$t$t2	SetQuery "element.id contour.value";

				quey$t$t2	GetIteratorHandle iter$t$t2;
				for {iter$t$t2 First} {[iter$t$t2 Valid]} {iter$t$t2 Next} {
					set data [iter$t$t2 GetDataList];
					set elemid [lindex $data 0];
					lappend BarList $elemid;
					set value1 [lindex $data 1];
					dict set BarData $elemid $s B Shear2 $value1;
				}
			}
		}
	}
	hwi CloseStack;


	### Create hwascii in HM ###
	::CommonProcCreateHwasciiAndReloadOnHmHv $LoadCaseList $ModelFileName;
}



#Proc5#######################################################################################################################
proc ::CollectResultUsingOptistructForceFile {ModelFileName ForceFileName} {
	### Variable ###
	variable BarData;
	variable BarList;
	set LoadCaseList "";
	set ElemType "Shell";

	set filehand [open $ForceFileName];
	set filedata [read $filehand];
	close $filehand;
	set filedata [split $filedata \n];

	### Get and set dict Barinfo from variable ###
	for {set i 0} {$i < [llength $filedata]} {incr i} {
		set line [lindex $filedata $i];
		### Get Number of Steps ###
		if {[string range $line 0 3] == "ITER"} {
			set NumStep [string trim [string range $line 9 end]];
		}

		### If line has containg the LOAD == It is meaning the STEP ###
		if {[string first "LOAD" $line] != "-1"} {
			set LoadCase	[string trim [string range $line 0 7]];
			set LoadCaseList [lsort -unique [lappend LoadCaseList $LoadCase]];
			set ElemType	[string trim [string range [lindex $filedata $i+1] 0 7]];
		}

		### Set dict for each info ###
		set elemid [string trim [string range $line 0 7]];
		if {$ElemType == "BAR #" && [string is integer $elemid] == "1"} {
			set AorB	[string trim [string range $line 9 9]];
			if {$AorB == "A" || $AorB == "B"} {
				lappend BarList $elemid;
				dict set BarData $elemid $LoadCase $AorB Axial	[string trim [string range $line 10 21]];
				dict set BarData $elemid $LoadCase $AorB Shear1	[string trim [string range $line 22 33]];
				dict set BarData $elemid $LoadCase $AorB Shear2	[string trim [string range $line 34 45]];
				dict set BarData $elemid $LoadCase $AorB Torque	[string trim [string range $line 46 57]];
				dict set BarData $elemid $LoadCase $AorB Bend1	[string trim [string range $line 58 69]];
				dict set BarData $elemid $LoadCase $AorB Bend2	[string trim [string range $line 70 81]];
			}
		}
	}
	set filedata "";

	### Create hwascii in HM ###
	::CommonProcCreateHwasciiAndReloadOnHmHv $LoadCaseList $ModelFileName;
}



#Proc6#######################################################################################################################
proc ::CommonProcCreateHwasciiAndReloadOnHmHv {LoadCaseList modelfile} {
	### Variable ###
	variable BarData;
	variable BarList;

	### Add new page & Change to HM session ###
	set t [::post::GetT];
	hwi OpenStack;
	hwi GetSessionHandle	sess$t;
	sess$t GetProjectHandle proj$t;
	proj$t GetPageHandle    page$t [proj$t GetActivePage];
	page$t GetWindowHandle  wind$t [page$t GetActiveWindow];
	wind$t GetClientHandle  clit$t;
	clit$t GetModelHandle   modl$t [clit$t GetActiveModel];

	set HyperMeshPageID [proj$t AddPage];
	proj$t GetPageHandle hmpage$t $HyperMeshPageID;
	hmpage$t GetWindowHandle hmwind$t 1;
	hmwind$t SetClientType fepre;

	### Load Userprofile and Import model ###
	::UserProfiles::CancelDialogChanges;
	*displayimporterrors 0;
	hm_framework loaduserprofile "OptiStruct";
	*feinputwithdata2 "#optistruct\\optistruct" "$modelfile" 0 0 0 0 0 1 0 1 0;

	### Stop export message and highlight ###
	*entityhighlighting 0;
	hm_blockmessages 1;

	### Set hwascii names ###
	set savedir [file dirname $modelfile];
	set temphwascii "$savedir\/temporary.hwascii"
	set savehand [open $temphwascii w];

	### Puts initial string of hwasicii ###
	puts $savehand "ALTAIR ASCII FILE";
	puts $savehand "\$TITLE   = Static analysis";

	### Create shell ###
	set BarList [lsort -unique $BarList];
	set movednodelist "";
	foreach elemid $BarList {
		### Drag bar to shell ###
		*createmark elems 1 $elemid
		*createvector 1 0 0 1;
		*meshdragelements2 1 1 1 1 0 0 0;

		### Get new nodes ID ###
		dict set BarData $elemid NewNodeAID [hm_latestentityid nodes 0];
		dict set BarData $elemid NewNodeBID [hm_latestentityid nodes 1];
		lappend movednodelist [dict get $BarData $elemid NewNodeAID] [dict get $BarData $elemid NewNodeBID];
	}
	### Translate back to original posiiton ###
	if {[llength $movednodelist] > "0"} {
		eval *createmark nodes 1 $movednodelist;
		*createvector 1 0 0 1;
		*translatemark nodes 1 1 -1;
	}

	### Get Local data and create hwascii on HyperMesh ###
	foreach LoadCase $LoadCaseList {
		### BEND 1+2 ###
		puts $savehand "\$SUBCASE = $LoadCase    Subcase $LoadCase";
		puts $savehand "\$BINDING = NODE";
		puts $savehand "\$COLUMN_INFO=	ENTITY_ID";
		puts $savehand "\$RESULT_TYPE =  Moment(v)";
		foreach elemid $BarList {
			### Get Bend 1and2 ###
			set Bend1A [dict get $BarData $elemid $LoadCase A Bend1];
			set Bend1B [dict get $BarData $elemid $LoadCase B Bend1];
			set Bend2A [dict get $BarData $elemid $LoadCase A Bend2];
			set Bend2B [dict get $BarData $elemid $LoadCase B Bend2];

			### Get local xyz for barY ###
			set YX [hm_getentityvalue elems $elemid localyx 0];
			set YY [hm_getentityvalue elems $elemid localyy 0];
			set YZ [hm_getentityvalue elems $elemid localyz 0];

			### Get local xyz for barZ ###
			set ZX [hm_getentityvalue elems $elemid localzx 0];
			set ZY [hm_getentityvalue elems $elemid localzy 0];
			set ZZ [hm_getentityvalue elems $elemid localzz 0];

			### Bend1+2 of A ###
			set AX [expr ($Bend1A * $YX) + ($Bend2A * $ZX)];
			set AY [expr ($Bend1A * $YY) + ($Bend2A * $ZY)];
			set AZ [expr ($Bend1A * $YZ) + ($Bend2A * $ZZ)];

			### Bend1+2 of B ###
			set BX [expr ($Bend1B * $YX) + ($Bend2B * $ZX)];
			set BY [expr ($Bend1B * $YY) + ($Bend2B * $ZY)];
			set BZ [expr ($Bend1B * $YZ) + ($Bend2B * $ZZ)];


			### Put to hwascii ###
			puts $savehand "[dict get $BarData $elemid NewNodeAID] \t $AX \t $AY \t $AZ";
			puts $savehand "[dict get $BarData $elemid NewNodeBID] \t $BX \t $BY \t $BZ";
			puts $savehand "[hm_getentityvalue elems $elemid node1.id 0] \t 0.0 \t 0.0 \t 0.0";
			puts $savehand "[hm_getentityvalue elems $elemid node2.id 0] \t 0.0 \t 0.0 \t 0.0";
		}

		### BEND1 ###
		puts $savehand "\$BINDING = NODE";
		puts $savehand "\$COLUMN_INFO=	ENTITY_ID";
		puts $savehand "\$RESULT_TYPE =  Moment Bending1(v)";
		foreach elemid $BarList {
			### Get Bend1 ###
			set Bend1A [dict get $BarData $elemid $LoadCase A Bend1];
			set Bend1B [dict get $BarData $elemid $LoadCase B Bend1];

			### Get local xyz for barY ###
			set YX [hm_getentityvalue elems $elemid localyx 0];
			set YY [hm_getentityvalue elems $elemid localyy 0];
			set YZ [hm_getentityvalue elems $elemid localyz 0];

			### Put to hwascii ###
			puts $savehand "[dict get $BarData $elemid NewNodeAID] \t [expr $Bend1A * $YX] \t [expr $Bend1A * $YY] \t [expr $Bend1A * $YZ]";
			puts $savehand "[dict get $BarData $elemid NewNodeBID] \t [expr $Bend1B * $YX] \t [expr $Bend1B * $YY] \t [expr $Bend1B * $YZ]";
			puts $savehand "[hm_getentityvalue elems $elemid node1.id 0] \t 0.0 \t 0.0 \t 0.0";
			puts $savehand "[hm_getentityvalue elems $elemid node2.id 0] \t 0.0 \t 0.0 \t 0.0";
		}

		### BEND2 ###
		puts $savehand "\$BINDING = NODE";
		puts $savehand "\$COLUMN_INFO=	ENTITY_ID";
		puts $savehand "\$RESULT_TYPE =  Moment Bending2(v)";
		foreach elemid $BarList {
			### Get Bend2 ###
			set Bend2A [dict get $BarData $elemid $LoadCase A Bend2];
			set Bend2B [dict get $BarData $elemid $LoadCase B Bend2];

			### Get local xyz for barZ ###
			set ZX [hm_getentityvalue elems $elemid localzx 0];
			set ZY [hm_getentityvalue elems $elemid localzy 0];
			set ZZ [hm_getentityvalue elems $elemid localzz 0];

			### Put to hwascii ###
			puts $savehand "[dict get $BarData $elemid NewNodeAID] \t [expr $Bend2A * $ZX] \t [expr $Bend2A * $ZY] \t [expr $Bend2A * $ZZ]";
			puts $savehand "[dict get $BarData $elemid NewNodeBID] \t [expr $Bend2B * $ZX] \t [expr $Bend2B * $ZY] \t [expr $Bend2B * $ZZ]";
			puts $savehand "[hm_getentityvalue elems $elemid node1.id 0] \t 0.0 \t 0.0 \t 0.0";
			puts $savehand "[hm_getentityvalue elems $elemid node2.id 0] \t 0.0 \t 0.0 \t 0.0";
		}

		### Shear 1+2 ###
		puts $savehand "\$BINDING = NODE";
		puts $savehand "\$COLUMN_INFO=	ENTITY_ID";
		puts $savehand "\$RESULT_TYPE =  Shear(v)";
		foreach elemid $BarList {
			### Get Shear 1and2 ###
			set Shear1A [dict get $BarData $elemid $LoadCase A Shear1];
			set Shear1B [dict get $BarData $elemid $LoadCase B Shear1];
			set Shear2A [dict get $BarData $elemid $LoadCase A Shear2];
			set Shear2B [dict get $BarData $elemid $LoadCase B Shear2];

			### Get local xyz for barY ###
			set YX [hm_getentityvalue elems $elemid localyx 0];
			set YY [hm_getentityvalue elems $elemid localyy 0];
			set YZ [hm_getentityvalue elems $elemid localyz 0];

			### Get local xyz for barZ ###
			set ZX [hm_getentityvalue elems $elemid localzx 0];
			set ZY [hm_getentityvalue elems $elemid localzy 0];
			set ZZ [hm_getentityvalue elems $elemid localzz 0];

			### Shear1+2 of A ###
			set AX [expr ($Shear1A * $YX) + ($Shear2A * $ZX)];
			set AY [expr ($Shear1A * $YY) + ($Shear2A * $ZY)];
			set AZ [expr ($Shear1A * $YZ) + ($Shear2A * $ZZ)];

			### Shear1+2 of B ###
			set BX [expr ($Shear1B * $YX) + ($Shear2B * $ZX)];
			set BY [expr ($Shear1B * $YY) + ($Shear2B * $ZY)];
			set BZ [expr ($Shear1B * $YZ) + ($Shear2B * $ZZ)];

			### Put to hwascii ###
			puts $savehand "[dict get $BarData $elemid NewNodeAID] \t $AX \t $AY \t $AZ";
			puts $savehand "[dict get $BarData $elemid NewNodeBID] \t $BX \t $BY \t $BZ";
			puts $savehand "[hm_getentityvalue elems $elemid node1.id 0] \t 0.0 \t 0.0 \t 0.0";
			puts $savehand "[hm_getentityvalue elems $elemid node2.id 0] \t 0.0 \t 0.0 \t 0.0";
		}

		### Shear1 ###
		puts $savehand "\$BINDING = NODE";
		puts $savehand "\$COLUMN_INFO=	ENTITY_ID";
		puts $savehand "\$RESULT_TYPE =  Shear Plane1(v)";
		foreach elemid $BarList {
			### Get Shear1 ###
			set Shear1A [dict get $BarData $elemid $LoadCase A Shear1];
			set Shear1B [dict get $BarData $elemid $LoadCase B Shear1];

			### Get local xyz for barY ###
			set YX [hm_getentityvalue elems $elemid localyx 0];
			set YY [hm_getentityvalue elems $elemid localyy 0];
			set YZ [hm_getentityvalue elems $elemid localyz 0];

			### Put to hwascii ###
			puts $savehand "[dict get $BarData $elemid NewNodeAID] \t [expr $Shear1A * $YX] \t [expr $Shear1A * $YY] \t [expr $Shear1A * $YZ]";
			puts $savehand "[dict get $BarData $elemid NewNodeBID] \t [expr $Shear1B * $YX] \t [expr $Shear1B * $YY] \t [expr $Shear1B * $YZ]";
			puts $savehand "[hm_getentityvalue elems $elemid node1.id 0] \t 0.0 \t 0.0 \t 0.0";
			puts $savehand "[hm_getentityvalue elems $elemid node2.id 0] \t 0.0 \t 0.0 \t 0.0";
		}

		### Shear2 ###
		puts $savehand "\$BINDING = NODE";
		puts $savehand "\$COLUMN_INFO=	ENTITY_ID";
		puts $savehand "\$RESULT_TYPE =  Shear Plane2(v)";
		foreach elemid $BarList {
			### Get Shear1 ###
			set Shear2A [dict get $BarData $elemid $LoadCase A Shear2];
			set Shear2B [dict get $BarData $elemid $LoadCase B Shear2];

			### Get local xyz for barZ ###
			set ZX [hm_getentityvalue elems $elemid localzx 0];
			set ZY [hm_getentityvalue elems $elemid localzy 0];
			set ZZ [hm_getentityvalue elems $elemid localzz 0];

			### Put to hwascii ###
			puts $savehand "[dict get $BarData $elemid NewNodeAID] \t [expr $Shear2A * $ZX] \t [expr $Shear2A * $ZY] \t [expr $Shear2A * $ZZ]";
			puts $savehand "[dict get $BarData $elemid NewNodeBID] \t [expr $Shear2B * $ZX] \t [expr $Shear2B * $ZY] \t [expr $Shear2B * $ZZ]";
			puts $savehand "[hm_getentityvalue elems $elemid node1.id 0] \t 0.0 \t 0.0 \t 0.0";
			puts $savehand "[hm_getentityvalue elems $elemid node2.id 0] \t 0.0 \t 0.0 \t 0.0";
		}

	}
	close $savehand;

	### Export temporary model file ###
	set tempmodel "$savedir\/temporary.fem";
	hm_answernext "yes";
	*feoutputwithdata "[hm_info -appinfo ALTAIR_HOME]/templates/feoutput/optistruct/optistruct" "$tempmodel" 0 0 2 1 0;

	### Start export message and highlight ###
	*entityhighlighting 1;
	hm_blockmessages 0;

	### Remove page ###
	proj$t RemovePage $HyperMeshPageID;
	hwi CloseStack;

	### Add new page & Load new temp result ###
	set t [::post::GetT];
	hwi OpenStack;
	hwi GetSessionHandle	sess$t;
	sess$t GetProjectHandle proj$t;
	set NewPageID [proj$t AddPage];
	proj$t GetPageHandle page$t $NewPageID;
	proj$t SetActivePage $NewPageID;
	page$t GetWindowHandle  wind$t [page$t GetActiveWindow];
	wind$t SetClientType Animation;
	wind$t GetClientHandle  clit$t;
	clit$t GetModelHandle modltemp$t [clit$t AddModel $tempmodel];
	modltemp$t SetResult $temphwascii;

	sess$t GetClientManagerHandle mana$t Animation;
	mana$t GetRenderOptionsHandle rend$t
	rend$t SetElementMarkEnabled true
	rend$t SetElementMarkShape Bar Cylinder

	page$t Draw;
	hwi CloseStack;

	tk_messageBox -message " スクリプトの処理が完了しました。 \n Contourパネルでコンター表示を行って下さい。 \n Deformedパネルで変形結果を選択して下さい。"
}

### Kick proc1 ###
::StartBeamDiagram $ModelExtensions;
