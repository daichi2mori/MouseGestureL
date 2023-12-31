﻿;===============================================================================
;
;		MouseGestureL.ahk - Common Functions Library
;
;														Created by Pyonkichi
;===============================================================================
#Requires AutoHotkey v1.1.25+
MG_Version := 1.40
MG_InitCommonGlobals()
Goto MG_CommonLibEnd

;-------------------------------------------------------------------------------
; Initialize common global variables
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_InitCommonGlobals()
{
	global
	MG_DirConfig  := A_ScriptDir "\Config\"
	MG_DirLang	  := A_ScriptDir "\Languages\"
	MG_DirPlugins := A_ScriptDir "\Plugins\"
	MG_DirButtons := A_ScriptDir "\Components\Buttons\"
	MG_DirScrEdge := MG_DirButtons "ScreenEdges\"
	MG_DirUserBtn := MG_DirConfig "UserButtons\"
	MG_DirAHK	  := A_ScriptDir "\AutoHotkey\"
	MG_IconFile	  := A_ScriptDir "\Components\MouseGestureL.icl"
	MG_ReplaceStr := "###REPLACE###"
	MG_DefTargetName := "Default"

	MG_SaveModificationObj := Func("SaveModification")
	MG_TgDelim := "/"
	MG_RuleNames =
	(LTrim Join|
		WClass
		WClass_[NPTBR][PTBR]?
		CClass
		CClass_[NPTBR][PTBR]?
		Title
		Title_[NPTBR][PTBR]?
		Exe
		Exe_[NPTBR][PTBR]?
		Custom
		Custom_N
		Include
		Include_N
	)
	if (A_Is64bitOS) {
		EnvGet, A_ProgramFilesX86, ProgramFiles(x86)
	} else {
		A_ProgramFilesX86 := A_ProgramFiles
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Menu commands
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Reload Gesture Configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Reload()
{
	RunWait, %A_AhkPath% "%A_ScriptDir%\MG_Edit.ahk" /ini2ahk
	Reload
}

;-------------------------------------------------------------------------------
; Edit Gesture Configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Edit()
{
	global
	if (MG_EditCommand) {
		Run, %MG_EditCommand%
		return
	}
	MG_SearchPlugins()
	local t1:=0, t2:=0
	FileGetTime, t1, %MG_DirConfig%MG_Config.ahk
	RunWait, %A_AhkPath% "%A_ScriptDir%\MG_Edit.ahk"
	FileGetTime, t2, %MG_DirConfig%MG_Config.ahk
	if (t2 > t1) {
		Reload
		CheckConfigurationError()
	}
}

;-------------------------------------------------------------------------------
; Show Help Document
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ShowHelp()
{
	global
	IfWinExist, MouseGestureL-Help ahk_class HH Parent
	{
		WinActivate
	}
	else if(FileExist(A_ScriptDir . "\Docs\" . MC_HelpFile)) {
		Run, %A_ScriptDir%\Docs\%MC_HelpFile%
	}
	else {
		MsgBox, %MC_LngMessage001%
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Configurations
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Check whether configuration files exist
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckConfigFiles()
{
	local szNewIni, szOldIni, bExists

	szNewIni := MG_DirConfig "MouseGestureL.ini"
	szOldIni := A_ScriptDir "\MouseGesture.ini"
	bExists := true

	if (FileExist(MG_DirConfig) != "D") {
		FileCreateDir, %MG_DirConfig%
	}
	if (!FileExist(szNewIni)) {
		if (FileExist(szOldIni)) {
			FileCopy, %szOldIni%, %szNewIni%
		}
		bExists := false
	}
	if (!MG_IsEdit) {
		if (!bExists) {
			MG_Edit()
		}
		else if (!FileExist(MG_DirConfig "MG_Config.ahk")) {
			MG_Reload()
		}
	}
	return bExists
}

;-------------------------------------------------------------------------------
; Load Ini File
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_LoadIniFile(szIniData="")
{
	global
	Target_Count  := 0
	Gesture_Count := 0
	if (!szIniData) {
		FileRead, szIniData, %MG_DirConfig%MouseGestureL.ini
	}
	MG_LoadIni(szIniData)
	Config_IniFileVersion := MG_Version
}

;-------------------------------------------------------------------------------
; Convert ini string to variables
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_LoadIni(szIni, ByRef tpos=0, ByRef gpos=0)
{
	global
	local szLine, com, SName, tidx, tname, cnt, gidx, rcount, acount, bChild
		, bGes, parent, lv, tstart, lvdiff, bImpT, bImpG , LastIdx, nIgnore, aryTmp

	szIni .= "`n[EndOfIni]`n"
	SName := ""
	tstart := Target_Count + 1
	bImpT:= bImpG := bChild := false
	nIgnore := 0
	LastIdx := []
	if (!MG_ActvtExclud.MaxIndex()) {
		MG_ActvtExclud := []
	}
	Loop, parse, szIni, `n, `r%A_Tab%%A_Space%
	{
		;-----------------------------------------------------------------------
		; Read one line : 行データ取得
		;-----------------------------------------------------------------------
		szLine := A_LoopField
		;.......................................................................
		; Start comments : 範囲コメント開始
		if (RegExMatch(szLine, "^\s*\/\*")) {
			if (!RegExMatch(szLine, "\*\/\s*$")){
				com := 1
			}
		}
		;.......................................................................
		; End comments : 範囲コメント終了
		else if (RegExMatch(szLine, "\*\/\s*$")) {
			com := 0
		}
		;.......................................................................
		; Skip other comments : その他コメントはスキップ
		else if (RegExMatch(szLine, "^\s*#")||com) {
		}
		;-----------------------------------------------------------------------
		; Section : セクション
		;-----------------------------------------------------------------------
		else if (RegExMatch(szLine, "^\[(.+)\]$", $)) {
			if (SName == "") {
				; Section has not been found.
			}
			;.......................................................................
 			; Previous section is gesture : 前のセクションがジェスチャーだった場合
			else if (bGes) {
				if (GestureIndexOf(SName)) {
					cnt := 1
					Loop {
						cnt++
						tname := SName . " (" . cnt . ")"
						if (!GestureIndexOf(tname)) {
							SName := tname
							break
						}
					}
				}
				Gesture_%gidx%_Count := acount
				if (!Gesture_%gidx%_Name) {
					Gesture_%gidx%_Name := SName
					Gesture_Count++
					bImpG := true
				}
			}
			;.......................................................................
			; Previous section is target : 前のセクションがターゲットだった場合
			else if (SName!="Settings" && SName!="ActivationExcluded") {
				if (lv==1 && TargetIndexOf(SName)) {
					cnt := 1
					Loop {
						cnt++
						tname := SName . " (" . cnt . ")"
						if (!TargetIndexOf(tname)) {
							SName := tname
							break
						}
					}
				}
				Target_%tidx%_Count := rcount
				if (!Target_%tidx%_Name) {
					Target_%tidx%_Name := SName
					Target_Count++
					LastIdx[lv] := tidx
					bImpT := true
				}
			}
			;.......................................................................
			SName := $1
			tidx := Target_Count + 1
			Target_%tidx%_Name	:= ""
			Target_%tidx%_Icon	:= 0
			Target_%tidx%_IsAnd	:= 0
			Target_%tidx%_Level := 1
			Target_%tidx%_Parent := ""
			Target_%tidx%_NotInh := 0
			rcount := 0
			gidx := Gesture_Count + 1
			Gesture_%gidx%_Name		:= ""
			Gesture_%gidx%_Patterns	:= ""
			Gesture_%gidx%_Default	:= ""
			acount := 0
			bGes := false
			lv := 1
		}
		;-----------------------------------------------------------------------
		; Entry : エントリ
		;-----------------------------------------------------------------------
		else if (RegExMatch(szLine, "^(.+?)\s*=\s*(.*?)$", $)) {
			if (SName = "Settings") {
				Config_%$1% := $2
			}
			;.......................................................................
			; Excluded targets for MG_ActivatePrevWin() function
			else if (SName = "ActivationExcluded") {
				if (RegExMatch($2, "^{(.*?)\t(.*?)\t(.*?)}$", $) && ($1 || $2 || $3)) {
					aryTmp := Array($1, $2, $3)
					nIgnore++
					MG_ActvtExclud.InsertAt(nIgnore, aryTmp)
				}
			}
			;.......................................................................
			; Target rule : ターゲットルール
			else if (RegExMatch($1, "^(" . MG_RuleNames . ")$")) {
				if (!MG_RuleExists(tidx, $1, $2)) {
					rcount++
					Target_%tidx%_%rcount%_Type	 := $1
					Target_%tidx%_%rcount%_Value := $2
				}
			}
			;.......................................................................
			; Target icon : ターゲットのアイコン
			else if (MG_hImageList && $1="Icon") {
				Target_%tidx%_IconFile := $2
				Target_%tidx%_Icon := MG_SerchSameIcon($2)
				if (!Target_%tidx%_Icon) {
					RegExMatch($2, "^(.+?)\s*,\s*(.*?)$", $)
					Target_%tidx%_Icon := IL_Add(MG_hImageList, MG_VarInStr($1), $2)
				}
			}
			;.......................................................................
			; Target rule "And" mode : ターゲットルールANDモード
			else if ($1 = "And") {
				Target_%tidx%_IsAnd := $2
			}
			;.......................................................................
			; Target rule "Exclude from default gesture targets"
			else if ($1 = "ExcludeDefault") {
				Target_%tidx%_IsExDef := $2
			}
			;.......................................................................
			; Target nesting level
			else if ($1 = "Level") {
				lv := $2 - 1
				if (LastIdx[lv]) {
					Target_%tidx%_Parent := LastIdx[lv]
				} else if (!bChild) {
					bChild := true
					Target_%tidx%_Parent := (tpos > 1) ? tpos : Target_Count
				} else {
					lv := $2 + lvdiff - 1
					Target_%tidx%_Parent := LastIdx[lv]
				}
				parent := Target_%tidx%_Parent
				lv := Target_%parent%_Level + 1
				if (tstart == tidx) {
					lvdiff := lv - $2
				}
				Target_%tidx%_Level := lv
			}
			;.......................................................................
			; Target rule "Don't inherit the parent conditions"
			else if ($1 = "NotInherit") {
				Target_%tidx%_NotInh := $2
			}
			;.......................................................................
			; Gesture : ジェスチャー
			else if ($1 = "G") {
				bGes := true
				if ($2) {
					Join(Gesture_%gidx%_Patterns, $2)
				}
			}
			;.......................................................................
			; Bound Action : 割り当てアクション
			else if (bGes) {
				if (!MG_ActionExists(gidx, $1)) {
					if (Config_IniFileVersion < 1.20) {
						$2 := RegExReplace($2, "(?<!\t)\t", "<MG_CR>")
					}
					acount++
					Gesture_%gidx%_%acount%_Target := $1
					Gesture_%gidx%_%acount%_Action := $2
				}
			}
		}
	}
	tpos := bImpT ? tpos : 0
	gpos := bImpG ? gpos : 0
}

;-------------------------------------------------------------------------------
; Check whether specified rule exists
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_RuleExists(iTarget, szType, szValue)
{
	global
	Loop, % Target_%iTarget%_Count
	{
		if ((Target_%iTarget%_%A_Index%_Type  = szType)
		&&	(Target_%iTarget%_%A_Index%_Value = szValue)) {
			return true
		}
	}
	return false
}

;-------------------------------------------------------------------------------
; Check whether specified action exists
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ActionExists(iGesture, szTarget)
{
	global
	Loop, % Gesture_%iGesture%_Count
	{
		if (Gesture_%iGesture%_%A_Index%_Target = szTarget) {
			return A_Index
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Retrieve Target Index by Name
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
TargetIndexOf(name)
{
	local idx:=1, ret:=0, lv

	if (name == MG_DefTargetName) {
		return 1
	}
	Loop, Parse, name, %MG_TgDelim%
	{
		if (!A_LoopField) {
			break
		}
		lv := A_Index
		while (idx <= Target_Count) {
			if ((Target_%idx%_Name == A_LoopField)
			&&	(Target_%idx%_Level == lv)) {
				ret:=idx
				break
			}
			idx++
		}
		idx++
	}
	return ret
}

;-------------------------------------------------------------------------------
; Retrieve Gesture Index by Name
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
GestureIndexOf(name)
{
	global
	Loop, %Gesture_Count%
	{
		if (Gesture_%A_Index%_Name = name) {
			return A_Index
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Retrieve Gesture Index by Gesture String
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_FindGesture(szGesture)
{
	global
	Loop, %Gesture_Count%
	{
		local idxGes := A_Index
		Loop, Parse, Gesture_%A_Index%_Patterns, `n
		{
			if (A_LoopField && (A_LoopField = szGesture)) {
				return idxGes
			}
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Serch Target Icon Filename
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SerchSameIcon(szIconFile)
{
	global
	Loop, %Target_Count%
	{
		if (Target_%A_Index%_IconFile = szIconFile) {
			return Target_%A_Index%_Icon
		}
	}
	return 0
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Conditions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Regisger Custom Condition Category
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_AddConditionCategory(key, name)
{
	global
	if (!MG_IsEdit
	||	CustomExpressions_%category%_Count)
	{
		return
	}
	Menu, CustomExpressions_%key%, Add
	Menu, CustomExpressions_%key%, DeleteAll
	Menu, CustomExpressions, Add, %name%, :CustomExpressions_%key%
}

;-------------------------------------------------------------------------------
; Regisger Custom Condition
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_AddCustomCondition(category, name="", value="")
{
	local cnt, szCommand
	if (!MG_IsEdit) {
		return
	}
	Menu, CustomExpressions_%category%, Add, %name%, CustomExpressionsMenuSelect
	cnt := CustomExpressions_%category%_Count
	cnt := cnt ? cnt+1 : 1
	CustomExpressions_%category%_Count := cnt
	CustomExpressions_%category%_%cnt% := value
	return

	;---------------------------------------------------------------------------
	; The menu item has been selected
CustomExpressionsMenuSelect:
	szCommand := %A_ThisMenu%_%A_ThisMenuItemPos%
	if (IsFunc(szCommand)) {
		Func(szCommand).()
	}
	else if (IsLabel(szCommand)) {
		GoSub, %szCommand%
	}
	else {
		MG_SetRuleValue(szCommand)
	}
	return
}

;-------------------------------------------------------------------------------
; Set Rule Value
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_SetRuleValue(val) {
	GuiControl, MEW_Main:, ERuleValue, %val%
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Actions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Regisger Action Category
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_AddActionCategory(key="Others", name="???")
{
	global
	if (!MG_IsEdit) {
		return
	}
	local idx := GetActionCategoryIdx(key)
	if (idx) {
		ActionCategory%idx%_Name := name
	}
	else {
		if (key = "Others") {
			idx := "Temp"
		}
		else {
			ActionCategory_Count++
			idx := ActionCategory_Count
		}
		ActionCategory%idx%_Count := 0
		ActionCategory%idx%_Key	  := key
		ActionCategory%idx%_Name  := name
	}
	GuiControl, MEW_Main:, DDLActionCategory, `n
}

;-------------------------------------------------------------------------------
; Regisger Action to Template
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_AddActionTemplate(category, name, script)
{
	global
	if (!MG_IsEdit) {
		return
	}
	ActionCategory1_Count++
	ActionTitle1_%ActionCategory1_Count% := name
	ActionTemplate1_%ActionCategory1_Count% := script

	local idx := GetActionCategoryIdx(category)
	if (!idx) {
		MG_AddActionCategory(category)
		idx := (category = "Others") ? "Temp" : ActionCategory_Count
	}
	ActionCategory%idx%_Count++
	local cnt := ActionCategory%idx%_Count
	ActionTitle%idx%_%cnt% := name
	ActionTemplate%idx%_%cnt% := script
}

;-------------------------------------------------------------------------------
; Get Action Category Index by Key
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
GetActionCategoryIdx(key)
{
	global
	if ((key = "Others") && ActionCategoryTemp_Key) {
		return "Temp"
	}
	Loop, %ActionCategory_Count%
	{
		if (key = ActionCategory%A_Index%_Key) {
			return A_Index
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Add Action Script
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_AddActionScript(szScript, szDesc="", pos="")
{
	global
	if (szDesc) {
		szScript := ";" . szDesc . "`n" . szScript
	} else {
		szScript := ";" ActionTitle%DDLActionCategory%_%DDLActionTemplate% . szDesc "`n" szScript
	}
	Gui, MEW_Main:Submit, NoHide
	if (pos = "top") {
		EAction := szScript "`n" EAction
	} else {
		Join(EAction, szScript)
	}
	GuiControl, MEW_Main:, EAction, %EAction%
	MG_SaveModificationObj.("Modified", "EAction")
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Languages
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Check and Select Language
;	fChoose : 0 = Determine whether language module has been included
;			  1 = Show "Choose Language" dialog box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckLanguage(fChoose=0)
{
	local	szFileName, szDispName, szDDL, szBuf, objFileList, iLng, iSel, file, hWnd
	static	tblLang := [ [ "Japanese.ahk", "0411" ]
					   , [ "Chinese.ahk" , "0804", "0C04", "1004", "0404" ] ]

	; Create Config folder
	if (FileExist(MG_DirConfig) != "D") {
		FileCreateDir, %MG_DirConfig%
	}
	; Determination whether language module has been included
	if (!fChoose) {
		if (MG_Language) {
			return
		}
		; MG_Language.ahk does not exist -> Select language automatically by LCID
		szFileName := ""
		MG_ChkLngLoop:
		Loop, % tblLang.MaxIndex() {
			iLng := A_Index
			Loop, % tblLang[iLng].MaxIndex()-1 {
				if (A_Language = tblLang[iLng][A_Index+1]) {
					szFileName := tblLang[iLng][1]
					break MG_ChkLngLoop
				}
			}
		}
		if (!szFileName || !FileExist(MG_DirLang . szFileName)) {
			szFileName := "English.ahk"
		}
		Goto MGW_LangApply
	}
	; Retrieving name of the stored language files
	iSel := 0
	szDDL := ""
	objFileList := []
	Loop, %MG_DirLang%*.ahk
	{
		if (A_LoopFileName != "MG_Language.ahk") {
			objFileList.InsertAt(A_Index, A_LoopFileName)
			szFileName := RegExReplace(A_LoopFileName, ".ahk")
			if (szFileName = MG_Language) {
				iSel := A_Index
			}
			szDispName := ""
			file := FileOpen(A_LoopFileFullPath, "r", "UTF-8")
			if (file) {
				szBuf := file.Read(file.Length)
				file.Close
				if (RegExMatch(szBuf, "m)^.*MC_LanguageName.*=(.+).*$", $)) {
					szDispName := $1
				}
			}
			if (szDispName == "") {
				szDispName := szFileName
			}
			szDDL .= szDispName . "|"
		}
	}
	; Choose Language dialog box
	Gui, MGW_Lng:New
	Gui, MGW_Lng:-MaximizeBox -MinimizeBox +HWNDhWnd
	Gui, MGW_Lng:Add, Text, x10 y10, Choose your language:
	Gui, MGW_Lng:Add, DropDownList, VddlLang xp+0 y+10 w180 AltSubmit, %szDDL%
	Gui, MGW_Lng:Add, Button, gOnLngSelected x+-168 y+10 w80 Default, OK
	Gui, MGW_Lng:Add, Button, gOnLngCanceled x+8 yp+0 w80, &Cancel
	GuiControl, MGW_Lng:Choose, ddlLang, %iSel%
	Gui, MGW_Lng:Show, , Choose Language

	WinWaitClose, ahk_id %hWnd%
	return

	;---------------------------------------------------------------------------
	; Selected
OnLngSelected:
	GuiControlGet, iSel, MGW_Lng:, ddlLang
	szFileName := objFileList[iSel]
	Loop, % objFileList.MaxIndex() {
		objFileList.RemoveAt(A_Index)
	}
MGW_LangApply:
	file := FileOpen(MG_DirLang . szFileName, "r", "UTF-8")
	if (file) {
		szBuf := file.Read(file.Length)
		file.Close
		if (!RegExMatch(szBuf, "m)^[\s\t]*MG_Language\s*:=\s*RegExReplace"))
		{
			MsgBox, ERROR : Language file is invalid.
			Goto, OnLngCanceled
		}
		file := FileOpen(MG_DirConfig "MG_Language.ahk", "w `n", "UTF-8")
		if (!file) {
			MsgBox, ERROR : Failed in file writing.
			Goto, OnLngCanceled
		}
		file.Write("#" . "Include %A_ScriptDir%\Languages\" . szFileName . "`n")
		file.Close
		FileDelete, %MG_DirLang%MG_Language.ahk
	}
	Reload

	;---------------------------------------------------------------------------
	; Canceled
OnLngCanceled:
MGW_LngGuiClose:
MGW_LngGuiEscape:
	if (fChoose) {
		Gui, MGW_Lng:Destroy
		return
	} else {
		ExitApp
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Plugins
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Search Plugins
;	return=1 : Plugin Include Script has been Updated
;	return=0 : Plugin Include Script has Not been Changed
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SearchPlugins()
{
	local szInc, szCur, file
	;...........................................................................
	; Search Plugin Script Files
	szInc := ""
	Loop, %MG_DirPlugins%*.ahk
	{
		if (A_LoopFileName != "MG_Plugin.ahk")
		{
			szInc .= "#" . "Include *i %A_ScriptDir%\Plugins\" . A_LoopFileName . "`n"
		}
	}
	if (szInc == "") {
		return 0
	}
	;...........................................................................
	; Check if Plugin Files are Added or Removed
	file := FileOpen(MG_DirConfig "MG_Plugins.ahk", "r `n", "UTF-8")
	if (!file) {
		file := FileOpen(MG_DirPlugins "MG_Plugin.ahk", "r `n", "UTF-8")
	}
	if (file)
	{
		szCur := file.Read(file.Length)
		file.Close
		if (szCur == szInc) {
			return 0
		}
	}
	;...........................................................................
	; Write Plugin Include Script
	file := FileOpen(MG_DirConfig "MG_Plugins.ahk", "w `n", "UTF-8")
	if (!file) {
		return 0
	}
	file.Write(szInc)
	file.Close
	FileDelete, %MG_DirPlugins%MG_Plugin.ahk
	return 1
}

;-------------------------------------------------------------------------------
; Regisger Plugin Menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_AddPluginMenu(szName="", szCommand="")
{
	global
	if (MG_IsEdit) {
		return
	}
	MG_PluginMenuCount++
	MG_PluginMenu%MG_PluginMenuCount%_Name	  := szName
	MG_PluginMenu%MG_PluginMenuCount%_Command := szCommand
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture pattern rendering functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Create Font
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateFont(szFace, nSize, nWeight=0, nQuality=0)
{
	local nHeight := -(nSize * MG_ScreenDPI // 72)

	return DllCall("CreateFont"
					,"Int",nHeight							; nHeight
					,"Int",0								; nWidth
					,"Int",0								; nEscapement
					,"Int",0								; nOrientation
					,"Int",nWeight							; nWeight
					,"UInt",0								; fdwItalic
					,"UInt",0								; fdwUnderline
					,"UInt",0								; fdwStrikeOut
					,"UInt",(szFace="Wingdings" ? 2 : 1)	; fdwCharset
					,"UInt",0								; fdwOutPrecision
					,"UInt",0								; fdwClipPrecision
					,"UInt",nQuality						; fdwQuality
					,"UInt",0								; fdwPitchAndFamily
					,"Str",szFace							; pszFaceName
					,"Ptr")
}

;-------------------------------------------------------------------------------
; Draw Gesture Pattern
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DrawGesture(hDC, ptX, ptY, szGesture, ByRef strW=0, ByRef strH=0, fMeasure=0, nGesLen=0)
{
	global MG_BtnNames, MG_AdNaviNI2, MG_hFntBtn, MG_hFntDir, MG_AdNaviSize
	static DirD:=0xEA, DirL:=0xE7, DirR:=0xE8, DirU:=0xE9
	static Dir1:=0xED, Dir2:=0xEA, Dir3:=0xEE, Dir4:=0xE7, Dir6:=0xE8, Dir7:=0xEB, Dir8:=0xE9, Dir9:=0xEC

	if (!fMeasure) {
		hRgn := DllCall("CreateRectRgn", "Int",ptX, "Int",ptY, "Int",ptX+strW, "Int",ptY+strH, "Ptr")
		DllCall("SelectClipRgn", "Ptr",hDC, "Ptr",hRgn)
	}
	hFntOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",MG_hFntBtn, "Ptr")
	VarSetCapacity(size, 8, 0)
	max:=StrLen(szGesture), pos:=1, preFont:=1, nowX:=ptX, strH:=0
	nHeight := MG_AdjustToDPI(MG_AdNaviSize)
	while (pos <= max)
	{
		if (SubStr(szGesture, pos, 1) == "_") {
			newFont := 1
			szDraw := "_"
			offset := 1
			shift := fDown ? 0 : -nHeight*5//4
			fDown := 0
		}
		else {
			shift := 0
			fDown := 0
			Loop, % MG_BtnNames.MaxIndex() {
				if (MG_BtnNames[A_Index] && InStr(SubStr(szGesture, pos), MG_BtnNames[A_Index]) == 1) {
					newFont := 1
					szDraw := MG_BtnNames[A_Index]
					offset := StrLen(MG_BtnNames[A_Index])
					fDown := 1
					break
				}
			}
			if (!fDown) {
				newFont := 2
				dir := "Dir" . SubStr(szGesture, pos, 1)
				szDraw := Chr(%dir%)
				offset := 1
				shift := nHeight//4
				shift -= (dir="DirU"||dir="Dir8") ? nHeight//6 : 0
				shift += (dir="DirD"||dir="Dir2") ? nHeight//6 : 0
			}
		}
		if (preFont != newFont) {
			preFont := newFont
			DllCall("SelectObject", "Ptr",hDC, "Ptr",(newFont==1 ? MG_hFntBtn : MG_hFntDir))
		}
		if (!fMeasure) {
			DllCall("TextOut", "Ptr",hDC, "Int",nowX, "Int",ptY+shift, "Str",szDraw, "Int",StrLen(szDraw))
		}
		DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",szDraw, "Int",StrLen(szDraw), "Ptr",&size)
		nowX += NumGet(size, 0, "UInt")
		h := NumGet(size, 4, "UInt")
		if (h > strH) {
			strH := h
		}
		pos += offset
		if (pos == nGesLen+1) {
			DllCall("SetTextColor", "Ptr",hDC, "UInt",MG_AdNaviNI2)
		}
	}
	strW := nowX - ptX
	DllCall("SelectObject", "Ptr",hDC, "Ptr",hFntOld)
	if (!fMeasure) {
		DllCall("SelectClipRgn", "Ptr",hDC, "Ptr",0)
		DllCall("DeleteObject", "Ptr",hRgn)
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	General functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Combine strings with delimiter
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
Join(ByRef list, value, delim="`n") {
	list := list ? (list . delim . value) : value
	return list
}

;-------------------------------------------------------------------------------
; Replace Variables in String
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_VarInStr(str) {
	out := str
	while (RegExMatch(out, ".*%(.+?)%.*", $)) {
		out := RegExReplace(out, "%" $1 "%", %$1%)
	}
	return out
}

;-------------------------------------------------------------------------------
; Check whether the operating system is recent one
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_IsNewOS() {
	return (A_OSVersion!="WIN_NT4" && A_OSVersion!="WIN_2000"
		&&	A_OSVersion!="WIN_XP"  && A_OSVersion!="WIN_2003")
}

;-------------------------------------------------------------------------------
; Call specified function if it is needed
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CallIfUsed(func, conditions, param:="")
{
	local file, buf, pos
	if (file := FileOpen(MG_DirConfig "MG_Config.ahk", "r", "UTF-8")) {
		buf := file.Read(file.Length)
		file.Close
		if (RegExMatch(buf, conditions)) {
			Func(func).(param)
		}
	}
}

;-------------------------------------------------------------------------------
; Execute a program as normal user
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_RunAsUser(szTarget, szWorkDir="", szWinStat="", bWait=false)
{
	szTarget := MG_VarInStr(szTarget)
	szWorkDir := MG_VarInStr(szWorkDir)
	if (A_IsAdmin && MG_IsNewOS()) {
		if (MG_CreateProcessAsUser(szTarget, szWorkDir, szWinStat, bWait)) {
			return
		}
	}
	if (bWait) {
		RunWait, %szTarget%, %szWorkDir%, % szWinStat . " UseErrorLevel"
	} else {
		Run, %szTarget%, %szWorkDir%, % szWinStat . " UseErrorLevel"
	}
}

;-------------------------------------------------------------------------------
; Create process as normal user
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateProcessAsUser(szTarget, szWorkDir="", szWinStat="", bWait=false)
{
	; Get process handle of the shell
	local hProc:=0, hWnd:=0, pid:=0
	WinGet, hWnd, ID, Program Manager ahk_class Progman
	if (hWnd) {
		WinGet, pid, PID, % "ahk_id " hWnd
		hProc := DllCall("OpenProcess", UInt,0x0400 , UInt,1, UInt,pid, Ptr)
	}
	if (!hProc) {
		return false
	}
	; Duplicate user token
	local res, htkUser:=0, htkCopy:=0
	VarSetCapacity(htkUser, A_PtrSize, 0)
	VarSetCapacity(htkCopy, A_PtrSize, 0)
	res := DllCall("advapi32.dll\OpenProcessToken", Ptr,hProc, UInt,0x000E, PtrP,htkUser, UInt)
	DllCall("CloseHandle", Ptr,hProc)
	if (!res) {
		return false
	}
	res := DllCall("advapi32.dll\DuplicateTokenEx", Ptr,htkUser, UInt,0x02000000, Ptr,0, Int,3, Int,1, PtrP,htkCopy, UInt)
	DllCall("CloseHandle", Ptr,htkUser)
	if (!res || !htkCopy) {
		return false
	}
	; Create process with user token
	local size, sinfo, pinfo, stat, ofs
	size := 4*9 + 2*2 + A_PtrSize*7 + (A_PtrSize//8*4)
	VarSetCapacity(sinfo, size, 0)
	NumPut(size, sinfo, 0, "UInt")
	ofs := 4*8 + A_PtrSize*3 + (A_PtrSize//8*4)
	NumPut(1, sinfo, ofs, "UInt")
	stat := (szWinStat="Max") ? 3
		 :	(szWinStat="Min") ? 7
		 :	(szWinStat="Hide") ? 0 : 1
	ofs += 4
	NumPut(stat, sinfo, ofs, "UShort")

	size := 4*2 + A_PtrSize*2
	VarSetCapacity(pinfo, size, 0)
	pid := 0
	szWorkDir := szWorkDir ? szWorkDir : A_ScriptDir
	if (DllCall("advapi32.dll\CreateProcessWithTokenW", Ptr,htkCopy, UInt,0, Ptr,0, Str,szTarget
			,UInt,0x00000400, Ptr,0, Str,szWorkDir, Ptr,&sinfo, Ptr,&pinfo, UInt)) {
		DllCall("CloseHandle", Ptr,NumGet(pinfo, A_PtrSize, "Ptr"))
		DllCall("CloseHandle", Ptr,NumGet(pinfo, 0, "Ptr"))
		ofs := A_PtrSize * 2
		pid := NumGet(pinfo, ofs, "UInt")
	}
	DllCall("CloseHandle", Ptr,htkCopy)
	if (!pid) {
		return false
	}
	if (bWait) {
		DetectHiddenWindows, On
		WinWait, % "ahk_pid " pid
		WinWaitClose, % "ahk_pid " pid
		DetectHiddenWindows, Off
	}
	return true
}

;-------------------------------------------------------------------------------
; Get monitor rectangle that includes specified coordinates
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetMonitorRect(ptX, ptY, ByRef monL=0, ByRef monT=0, ByRef monR=0, ByRef monB=0, fWork=false)
{
	pt := (ptY<<32) | (ptX & 0xffffffff)
	hMon := DllCall("MonitorFromPoint", "UInt64",pt, "UInt",2, "Ptr")
	VarSetCapacity(infMon, 40, 0)
	NumPut(40, infMon, 0, "UInt")
	res := DllCall("GetMonitorInfo", "Ptr",hMon, "Ptr",&infMon, "UInt")
	offset := fWork ? 20 : 4
	monL := NumGet(infMon, offset+ 0, "Int")
	monT := NumGet(infMon, offset+ 4, "Int")
	monR := NumGet(infMon, offset+ 8, "Int")
	monB := NumGet(infMon, offset+12, "Int")
}

;-------------------------------------------------------------------------------
; Adjust size value to screen DPI
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_AdjustToDPI(size, dpiNew=0, dpiBase=0) {
	global MG_ScreenDPI
	if (dpiNew == 0) {
		dpiNew := MG_ScreenDPI
	}
	if (dpiBase == 0) {
		dpiBase := 96
	}
	return size * dpiNew // dpiBase
}

;-------------------------------------------------------------------------------
; Get screen DPI from cursor position
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetDpiFromPoint(x, y)
{
	pt := (y<<32) | (x & 0xffffffff)
	hMon := DllCall("MonitorFromPoint", UInt64,pt, UInt,1, Ptr)
	VarSetCapacity(dpiX, 4, 0)
	VarSetCapacity(dpiY, 4, 0)
	DllCall("Shcore.dll\GetDpiForMonitor", UPtr,hMon, Int,0, IntP,dpiX, IntP,dpiY)
	return dpiX ? dpiX : A_ScreenDPI
}

;-------------------------------------------------------------------------------
; Get screen DPI from specified window
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetDpiFromWindow(hWnd:=0)
{
	global MG_HWND
	if (!hWnd) {
		hWnd := MG_HWND
	}
	hMon := DllCall("MonitorFromWindow", Ptr,hWnd, UInt,2, Ptr)
	VarSetCapacity(dpiX, 4, 0)
	VarSetCapacity(dpiY, 4, 0)
	DllCall("Shcore.dll\GetDpiForMonitor", UPtr,hMon, Int,0, IntP,dpiX, IntP,dpiY)
	return dpiX
}

;-------------------------------------------------------------------------------
; Get module filename from window handle
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetExeName(hWnd, bPath=false)
{
	local szExe, hChild

	WinGet, szExe, ProcessName, ahk_id %hWnd%
	if (szExe = "ApplicationFrameHost.exe") {
		hChild := DllCall("FindWindowExW", Ptr,hWnd, Ptr,0, Str,"Windows.UI.Core.CoreWindow", Ptr,0, Ptr)
		if (hChild) {
			hWnd := hChild
		}
	}
	if (bPath) {
		WinGet, szExe, ProcessPath, ahk_id %hWnd%
	} else {
		WinGet, szExe, ProcessName, ahk_id %hWnd%
	}
	return szExe
}

;-------------------------------------------------------------------------------
; Check whether specified window is activation target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_IsActivationTarget(hWnd, bIncRegWnd:=true)
{
	local dwStyle, dwExStyle, szTitle, szClass

	WinGet, dwStyle, Style, ahk_id %hWnd%
	WinGet, dwExStyle, ExStyle, ahk_id %hWnd%
	if ((dwStyle&0x08000000) || !(dwStyle&0x10000000) || (dwExStyle&0x00000080)
	||	((dwStyle&0x80000000) && !(dwStyle&0x20C80000))) {
		return false
	}
	WinGetClass, szClass, ahk_id %hWnd%
	if (szClass = "TApplication") {
		return false
	}
	if (!bIncRegWnd) {
		return true
	}
	Loop, % MG_ActvtExclud.MaxIndex()
	{
		szTitle := MG_ActvtExclud[A_Index][1]
		szTitle .= MG_ActvtExclud[A_Index][2] ? " ahk_class " MG_ActvtExclud[A_Index][2] : ""
		szTitle .= MG_ActvtExclud[A_Index][3] ? " ahk_exe " MG_ActvtExclud[A_Index][3] : ""
		if (hWnd = WinExist(szTitle)) {
			return false
		}
	}
	return true
}

;-------------------------------------------------------------------------------
; Wait Error Message
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
CheckConfigurationError()
{
	global MC_LngButton001, MC_LngButton002, MC_LngMessage002
	WinWait, MouseGestureL.ahk ahk_class #32770, Error
	if (ErrorLevel==0) {
		ControlGetText, szMsg1, Static1
		ControlGetText, szMsg2, Static2
		WinClose
		Gui, MGW_Err:New
		Gui, MGW_Err:+HWNDhWnd
		Gui, MGW_Err:Add, Text, x10 y10, % MC_LngMessage002 . szMsg1 . szMsg2
		Gui, MGW_Err:Add, Button, gOnSendClipboard x+-250 y+16 w160 h26, %MC_LngButton002%
		Gui, MGW_Err:Add, Button, gOnMsgClosed x+10 yp+0 w80 h26, %MC_LngButton001%
		Gui, MGW_Err:Show, ,
		WinWaitClose, ahk_id %hWnd%
	}
	return

	;---------------------------------------------------------------------------
	; Copy to Clipboard
OnSendClipboard:
	Clipboard := szMsg1 . szMsg2
	Gui, MGW_Err:Destroy
	return

	;---------------------------------------------------------------------------
	; Canceled
OnMsgClosed:
MGW_ErrGuiClose:
MGW_ErrGuiEscape:
	Gui, MGW_Err:Destroy
	return
}

MG_CommonLibEnd:
