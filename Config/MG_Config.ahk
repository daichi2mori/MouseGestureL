MG_IniFileVersion=1.40
MG_8Dir=0
MG_ActiveAsTarget=0
MG_Interval=20
MG_AlwaysHook=1
MG_PrvntCtxtMenu=1
MG_Threshold=12
MG_LongThresholdX=800
MG_LongThresholdY=600
MG_LongThreshold=700
MG_TimeoutThreshold=12
MG_Timeout=400
MG_DGInterval=0
MG_TmReleaseTrigger=3
MG_ORangeDefault=3
MG_ORangeA=3
MG_ORangeB=3
MG_EdgeInterval=20
MG_EdgeIndiv=0
MG_CornerX=1
MG_CornerY=1
MG_DisableDefMB=0
MG_DisableDefX1B=0
MG_DisableDefX2B=0
MG_UseNavi=1
MG_UseExNavi=3
MG_NaviInterval=10
MG_NaviPersist=0
MG_ExNaviTransBG=1
MG_ExNaviFG=000000
MG_ExNaviBG=FFFFFF
MG_ExNaviTranspcy=255
MG_ExNaviSize=24
MG_ExNaviSpacing=2
MG_ExNaviPadding=4
MG_ExNaviMargin=8
MG_AdNaviFG=FFFFFF
MG_AdNaviNI=7F7F7F
MG_AdNaviBG=0096FF
MG_AdNaviTranspcy=220
MG_AdNaviSize=11
MG_AdNaviFont=メイリオ
MG_AdNaviPosition=2
MG_AdNaviPaddingL=6
MG_AdNaviPaddingR=6
MG_AdNaviPaddingT=3
MG_AdNaviPaddingB=3
MG_AdNaviRound=2
MG_AdNaviMargin=500
MG_AdNaviSpaceX=1200
MG_AdNaviSpaceY=700
MG_AdNaviOnClick=0
MG_ShowTrail=0
MG_DrawTrailWnd=1
MG_TrailColor=0000FF
MG_TrailTranspcy=255
MG_TrailWidth=3
MG_TrailStartMove=3
MG_TrailInterval=10
MG_ShowLogs=0
MG_LogPosition=4
MG_LogPosX=0
MG_LogPosY=0
MG_LogMax=20
MG_LogSizeW=400
MG_LogInterval=500
MG_LogFG=FFFFFF
MG_LogBG=000000
MG_LogTranspcy=100
MG_LogFontSize=10
MG_LogFont=MS UI Gothic
MG_EditCommand=
MG_HotkeyEnable=
MG_HotkeyNavi=
MG_HotkeyReload=
MG_ScriptEditor=
MG_TraySubmenu=0
MG_AdjustDlg=0
MG_DlgHeightLimit=800
MG_FoldTarget=0
MG_DisableWarning=0
MG_ActvtExclud := []
MG_MaxLength=6
MG_Triggers=RB
MG_SubTriggers=WU_WD


Goto, MG_RB_End

MG_RB_Enable:
	if (!MG_AlwaysHook) {
		MG_RB_HookEnabled := Func("MG_IsHookEnabled_RB")
		Hotkey, If, % MG_RB_HookEnabled
	}
	Hotkey, *RButton, MG_RB_DownHotkey, On
	Hotkey, *RButton up, MG_RB_UpHotkey, On
	Hotkey, If
	MG_RB_Enabled := 1
return

MG_RB_Disable:
	Hotkey, *RButton, MG_RB_DownHotkey, Off
	Hotkey, *RButton up, MG_RB_UpHotkey, Off
	MG_RB_Enabled := 0
return

MG_RB_DownHotkey:
	MG_TriggerDown("RB")
return

MG_RB_UpHotkey:
	MG_TriggerUp("RB")
return

MG_RB_Down:
	MG_SendButton("RB", "RButton", "Down")
return

MG_RB_Up:
	MG_SendButton("RB", "RButton", "Up")
return

MG_RB_Check:
	MG_CheckButton("RB", "RButton")
return

MG_RB_End:


Goto, MG_WU_End

MG_WU_Enable:
	if (!MG_AlwaysHook) {
		MG_WU_HookEnabled := Func("MG_IsHookEnabled_WU")
		Hotkey, If, % MG_WU_HookEnabled
	}
	Hotkey, *WheelUp, MG_WU_Hotkey, On
	Hotkey, If
	MG_WU_Enabled := 1
return

MG_WU_Disable:
	Hotkey, *WheelUp, MG_WU_Hotkey, Off
	MG_WU_Enabled := 0
return

MG_WU_Hotkey:
	MG_ButtonPress("WU")
return

MG_WU_Press:
	MG_SendButton("WU", "WheelUp")
return

MG_WU_End:


Goto, MG_WD_End

MG_WD_Enable:
	if (!MG_AlwaysHook) {
		MG_WD_HookEnabled := Func("MG_IsHookEnabled_WD")
		Hotkey, If, % MG_WD_HookEnabled
	}
	Hotkey, *WheelDown, MG_WD_Hotkey, On
	Hotkey, If
	MG_WD_Enabled := 1
return

MG_WD_Disable:
	Hotkey, *WheelDown, MG_WD_Hotkey, Off
	MG_WD_Enabled := 0
return

MG_WD_Hotkey:
	MG_ButtonPress("WD")
return

MG_WD_Press:
	MG_SendButton("WD", "WheelDown")
return

MG_WD_End:


Goto, MG_Config_End


MG_IsDisable() {
	global
	return ((InStr(MG_ExePath(),"C:\Program Files (x86)\Steam")) || (InStr(MG_ExePath(),"D:\torrent\護身術道場 秘密のNTRレッスン")))
}

MG_IsTarget1() {
	global
	return ((MG_Exe="iexplore.exe") || (MG_Exe="msedge.exe") || (MG_Exe="chrome.exe") || (MG_Exe="firefox.exe"))
}

MG_IsTarget2() {
	global
	return ((MG_WClass="CabinetWClass") || (MG_WClass="ExploreWClass") || (MG_WClass="Progman") || (MG_WClass="WorkerW"))
}

MG_IsTarget3() {
	global
	return (MG_IsTarget2() && ((MG_TreeListHitTest())))
}

MG_IsTarget4() {
	global
	return ((MG_WClass="Chrome_WidgetWin_1"))
}

MG_IsExDefault() {
	return (0)
}

MG_Gesture_RB_:
	if (!MG_IsExDefault()) {
		;アクティブ化
		if (MG_WClass != "Chrome_WidgetWin_2") {
			MG_WinActivate()
		}
	}
return

MG_GetAction_RB_:
	if (!MG_IsExDefault()) {
		MG_ActionStr := "アクティブ化"
	}
return

MG_Gesture_RB_R_:
	if (MG_IsTarget4()) {
		;右のタブへ移動
		Send, ^{PgDn}
	} else if (!MG_IsExDefault()){
		;右のタブへ移動
		Send, ^{Tab}
	}
return

MG_GetAction_RB_R_:
	if (MG_IsTarget4()) {
		MG_ActionStr := "右のタブへ移動"
	} else if (!MG_IsExDefault()){
		MG_ActionStr := "右のタブへ移動"
	}
return

MG_Gesture_RB_L_:
	if (MG_IsTarget4()) {
		;左のタブへ移動
		Send, ^{PgUp}
	} else if (!MG_IsExDefault()){
		;左のタブへ移動
		Send, ^+{Tab}
	}
return

MG_GetAction_RB_L_:
	if (MG_IsTarget4()) {
		MG_ActionStr := "左のタブへ移動"
	} else if (!MG_IsExDefault()){
		MG_ActionStr := "左のタブへ移動"
	}
return

MG_Gesture_RB_U_:
	if (MG_IsTarget1()) {
		;新規タブを追加
		Send, ^t
	} else {
		MG_Cancel()
	}
return

MG_GetAction_RB_U_:
	if (MG_IsTarget1()) {
		MG_ActionStr := "新規タブを追加"
	} else {
		MG_ActionStr := ""
	}
return

MG_Gesture_RB_D_:
	if (MG_IsTarget1()) {
		;タブを閉じる
		Send, ^w
	} else if (MG_IsTarget4()) {
		;タブを閉じる
		Send, ^w
	} else {
		MG_Cancel()
	}
return

MG_GetAction_RB_D_:
	if (MG_IsTarget1()) {
		MG_ActionStr := "タブを閉じる"
	} else if (MG_IsTarget4()) {
		MG_ActionStr := "タブを閉じる"
	} else {
		MG_ActionStr := ""
	}
return

MG_Gesture_RB_WU_:
	if (!MG_IsExDefault()) {
		;pageUp
		Send, {PgUp}
	}
return

MG_GetAction_RB_WU_:
	if (!MG_IsExDefault()) {
		MG_ActionStr := "pageUp"
	}
return

MG_Gesture_RB_WD_:
	if (!MG_IsExDefault()) {
		;pageDown
		Send, {PgDn}
	}
return

MG_GetAction_RB_WD_:
	if (!MG_IsExDefault()) {
		MG_ActionStr := "pageDown"
	}
return


MG_IsHookEnabled_RB() {
	global
	MG_TriggerCount ? : MG_GetMousePosInfo()
	return (MG_RB_Enabled && (MG_TriggerCount || (!MG_IsDisable())))
}

MG_IsHookEnabled_WU() {
	global
	return (MG_WU_Enabled && MG_TriggerCount)
}

MG_IsHookEnabled_WD() {
	global
	return (MG_WD_Enabled && MG_TriggerCount)
}



MG_Config_end: