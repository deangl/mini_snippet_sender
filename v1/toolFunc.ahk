;;;get the trading day start from the startDay, where trading day list
;;;is in fileName

getTradeDay(fName, startDay, dayShift)
{
	fileName = %A_ScriptDir%\%fName%
	static dateArr := Object()
	static fileNameNow
	if dateArr.MaxIndex() < 10 or fileNameNow <> fileName
	{
		Loop, Read, %fileName%
		{
			dateArr.Insert(A_LoopReadLine)
			fileNameNow := fileName
		}
	}
	dateNow := startDay
	Loop % dateArr.MaxIndex()
	{
		iDate = % dateArr[A_Index]
		IfGreaterOrEqual iDate, %dateNow%
		{
			return % dateArr[A_Index+dayShift]
		}
	}
}
forceInputEn()
{
	setIme("Chinese (Simplified) - US Keyboard")
	Return
}
;;Loop in Chrome Tabs

ChooseChromeTabs(TabTitle){
	IfWinExist, ahk_class Chrome_WidgetWin_1
	{
		; Get current open tab title
		WinActivate ahk_class Chrome_WidgetWin_1
		WinWaitActive ahk_class Chrome_WidgetWin_1
		sleep 200
		send ^+A
		sleep 200
		send % TabTitle
		sleep 200
		send {enter}
	}
}


LoopChromeTabs(TabTitle)
{
	CurrentTitle := ""
	IfWinExist, ahk_class Chrome_WidgetWin_1
	{
		; Get current open tab title
		WinActivate ahk_class Chrome_WidgetWin_1
		WinWaitActive ahk_class Chrome_WidgetWin_1
		WinGetTitle, FirstTitle
		If instr( FirstTitle,TabTitle)
		{
			Return 1
		}
		; Go through all open tabs and find the tab we are looking for or quit
		Loop
		{
			WinActivate ahk_class Chrome_WidgetWin_1
			WinWaitActive ahk_class Chrome_WidgetWin_1
			Send ^{Tab}
			Sleep, 10
			WinGetTitle, CurrentTitle
			; After we changed tab have we found our tab?
			If instr( currenttitle, Tabtitle)
			{
				Return 1
			}
			; We went through all tabs and we should stop there
			If (FirstTitle = CurrentTitle)
				Return 0
		}
	}
	Else
		Return 0
}
;;IE Dom
IEGet(Name="")		;Retrieve pointer to existing IE window/tab
{
	IfEqual, Name,, WinGetTitle, Name, ahk_class IEFrame
		Name := ( Name="New Tab - Windows Internet Explorer" ) ? "about:Tabs" 
	: RegExReplace( Name, " - (Windows|Microsoft) Internet Explorer" )
	For Pwb in ComObjCreate( "Shell.Application" ).Windows
	If ( Pwb.LocationName = Name ) && InStr( Pwb.FullName, "iexplore.exe" )
		Return Pwb
} ;written by Jethrow
IELoad(Pwb)	;You need to send the IE handle to the function unless you define it as global.
{
	If !Pwb	;If Pwb is not a valid pointer then quit
		Return False
Loop	;Otherwise sleep for .1 seconds untill the page starts loading
	Sleep,100
Until (Pwb.busy)
Loop	;Once it starts loading wait until completes
	Sleep,100
Until (!Pwb.busy)
Loop	;optional check to wait for the page to completely load
	Sleep,100
Until (Pwb.Document.Readystate = "Complete")
Return True
}

IEWait(Name="")
{ 
	Loop
	{
		Sleep, 20
		pb := IEGet(Name)
	}
	Until  pb
	Return pb
}

; chromeGotoTab(tabTitle, tabUrl)
; {
;   FileDelete, %aimTabFile%
;   theText :=  tabTitle . "|" . tabUrl
;   FileAppend, %theText% ,%aimTabFile%, UTF-8
;   IfWinExist, ahk_class Chrome_WidgetWin_1
;   {
;     WinActivate 
;     WinWaitActive ahk_class Chrome_WidgetWin_1, ,0.5
;     Sleep, 50
;     ControlSend, ahk_parent , {control down}q{control up}, ahk_class Chrome_WidgetWin_1    
;     Return
;   }
;   Else
;   {
;     Run  %chromeProg% %tabUrl%
;     Return
;   }

; }

chromeGotoTab(tabTitle, tabUrl){
	If (LoopChromeTabs(tabTitle)  == 0){
		Run  %chromeProg% %tabUrl%
	}
	Return
}

chromeAppTab(tabTitle, tabUrl, winHeight:=900, winWidth:=1400, Y:=50, X:=50){
	if not WinExist(tabTitle){
		a = %chromeProg% --app=%tabUrl%
		run, %a%
		winwait, %tabTitle%
		if (winHeight =="MAX")
		{
			winmaximize
		}
		else
		{
			if(winHeight<1)
			{
				winHeight := floor(A_ScreenHeight * winHeight)
			}
			if(winWidth<1)
			{
				winWidth := floor(A_ScreenWidth * winWidth)
			}
			if(X<1)
			{
				X := floor(A_ScreenWidth * X)
			}
			if(Y<1)
			{
				Y := floor(A_ScreenHeight * Y)
			}
			winmove, , ,%X%,%Y%,%winWidth%,%winHeight%
		}
	}
	WinActivate
	ControlFocus, Chrome_RenderWidgetHostHWND1
	Return
}


getImeId(name)
{ 
	if (name == "")
	{
		Return -1
	}
	Loop, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\Keyboard Layouts,1,1
	{ 
	if (A_LoopRegName == "Layout Text")
	{
		RegRead, layoutName
		if (InStr(layoutName,name) > 0)
		{    
		StringRight , outName, A_LoopRegSubKey,8
		return outName
		}
	}  
	}
	Return -1
}    

setIme(name)
{
	theID := getImeId(name)
	if (theID <> -1)
	{
		WinGet,id,,A          
		DllCall("SendMessage", "UInt",id, "UInt", "80", "UInt", "1", "UInt",(DllCall("LoadKeyboardLayout", "Str", theID, "UInt","257")))
	}
	Return
}


SwitchIME(name)

{ 

	Loop, HKLM, SYSTEM/CurrentControlSet/Control/Keyboard Layouts,1,1

	{ 

		if (A_LoopRegName == "Layout Text")

		{ 

			RegRead,Value


			IfInString,Value,%name%

			{ 

				RegExMatch(A_LoopRegSubKey,"[^//]+$",dwLayout)

				HKL:=DllCall("LoadKeyboardLayout", Str, dwLayout, UInt, 1)

				ControlGetFocus,ctl,A

				SendMessage,0x50,0,HKL,%ctl%,A

				Break

			}

		}

	}

}

GetFocusedControl(Option := "")
{
	;"Options": ClassNN \ Hwnd \ Text \ List \ All

	GuiWindowHwnd := WinExist("A")		;stores the current Active Window Hwnd id number in "GuiWindowHwnd" variable
	;"A" for Active Window

	ControlGetFocus, FocusedControl, ahk_id %GuiWindowHwnd%	;stores the  classname "ClassNN" of the current focused control from the window above in "FocusedControl" variable
	;"ahk_id" searches windows by Hwnd Id number

	if Option = ClassNN
		return, FocusedControl

ControlGet, FocusedControlId, Hwnd,, %FocusedControl%, ahk_id %GuiWindowHwnd%	;stores the Hwnd Id number of the focused control found above in "FocusedControlId" variable

if Option = Hwnd
	return, FocusedControlId

if (Option = "Text") or (Option = "All")
	ControlGetText, FocusedControlText, , ahk_id %FocusedControlId%		;stores the focused control texts in "FocusedControlText" variable
;"ahk_id" searches control by Hwnd id number

if Option = Text	
	return, FocusedControlText

if (Option = "List") or (Option = "All")
	ControlGet, FocusedControlList, List, , , ahk_id %FocusedControlId%	;"List", retrieves  all the text from a ListView, ListBox, or ComboBox controls

if Option = List	
	return, FocusedControlList

return, FocusedControl " - " FocusedControlId "`n`n____Text____`n`n" FocusedControlText "`n`n____List____`n`n" FocusedControlList

}



getCaretPos(){
	if winactive("ahk_class Chrome_WidgetWin_1")
	{
		Acc_Caret := Acc_ObjectFromWindow(WinExist("ahk_class Chrome_WidgetWin_1"), OBJID_CARET := 0xFFFFFFF8)
		Caret_Location := Acc_Location(Acc_Caret)
		x := Caret_Location.x
		y := Caret_Location.y
	}
	else
	{
		WinGetPos, winX, winY
		x := A_CaretX+winX
		y:= A_CaretY+winY

	}
	if not x
	{
		x :=  A_ScreenWidth/2
		y :=  100
	}
	rslt := {x:x,y:y}
	return rslt
}


; ---------------------------------------------------------------取得光标位置
; http://www.autohotkey.com/board/topic/77303-acc-library-ahk-l-updated-09272012/
; https://dl.dropbox.com/u/47573473/Web%20Server/AHK_L/Acc.ahk
;------------------------------------------------------------------------------
; Acc.ahk Standard Library
; by Sean
; Updated by jethrow:
; 	Modified ComObjEnwrap params from (9,pacc) --> (9,pacc,1)
; 	Changed ComObjUnwrap to ComObjValue in order to avoid AddRef (thanks fincs)
; 	Added Acc_GetRoleText & Acc_GetStateText
; 	Added additional functions - commented below
; 	Removed original Acc_Children function
; last updated 2/25/2010
;------------------------------------------------------------------------------



Acc_Init()
{
	Static	h
	If Not	h
		h:=DllCall("LoadLibrary","Str","oleacc","Ptr")
}
Acc_ObjectFromEvent(ByRef _idChild_, hWnd, idObject, idChild)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
		Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromPoint(ByRef _idChild_ = "", x = "", y = "")
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromPoint", "Int64", x==""||y==""?0*DllCall("GetCursorPos","Int64*",pt)+pt:x&0xFFFFFFFF|y<<32, "Ptr*", pacc, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0+&varChild)=0
		Return	ComObjEnwrap(9,pacc,1), _idChild_:=NumGet(varChild,8,"UInt")
}

Acc_ObjectFromWindow(hWnd, idObject = -4)
{
	Acc_Init()
	If	DllCall("oleacc\AccessibleObjectFromWindow", "Ptr", hWnd, "UInt", idObject&=0xFFFFFFFF, "Ptr", -VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
		Return	ComObjEnwrap(9,pacc,1)
}

Acc_WindowFromObject(pacc)
{
	If	DllCall("oleacc\WindowFromAccessibleObject", "Ptr", IsObject(pacc)?ComObjValue(pacc):pacc, "Ptr*", hWnd)=0
		Return	hWnd
}

Acc_GetRoleText(nRole)
{
	nSize := DllCall("oleacc\GetRoleText", "Uint", nRole, "Ptr", 0, "Uint", 0)
	VarSetCapacity(sRole, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetRoleText", "Uint", nRole, "str", sRole, "Uint", nSize+1)
	Return	sRole
}

Acc_GetStateText(nState)
{
	nSize := DllCall("oleacc\GetStateText", "Uint", nState, "Ptr", 0, "Uint", 0)
	VarSetCapacity(sState, (A_IsUnicode?2:1)*nSize)
	DllCall("oleacc\GetStateText", "Uint", nState, "str", sState, "Uint", nSize+1)
	Return	sState
}

Acc_SetWinEventHook(eventMin, eventMax, pCallback)
{
	Return	DllCall("SetWinEventHook", "Uint", eventMin, "Uint", eventMax, "Uint", 0, "Ptr", pCallback, "Uint", 0, "Uint", 0, "Uint", 0)
}

Acc_UnhookWinEvent(hHook)
{
	Return	DllCall("UnhookWinEvent", "Ptr", hHook)
}
/*	Win Events:

pCallback := RegisterCallback("WinEventProc")
WinEventProc(hHook, event, hWnd, idObject, idChild, eventThread, eventTime)
{
	Critical
	Acc := Acc_ObjectFromEvent(_idChild_, hWnd, idObject, idChild)
	; Code Here:

}
*/

; Written by jethrow
Acc_Role(Acc, ChildId=0) {
	try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetRoleText(Acc.accRole(ChildId)):"invalid object"
}
Acc_State(Acc, ChildId=0) {
	try return ComObjType(Acc,"Name")="IAccessible"?Acc_GetStateText(Acc.accState(ChildId)):"invalid object"
}
Acc_Location(Acc, ChildId=0, byref Position="") { ; adapted from Sean's code
	try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
	catch
	return
Position := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
return	{x:NumGet(x,0,"int"), y:NumGet(y,0,"int"), w:NumGet(w,0,"int"), h:NumGet(h,0,"int")}
}
Acc_Parent(Acc) { 
	try parent:=Acc.accParent
	return parent?Acc_Query(parent):
}
Acc_Child(Acc, ChildId=0) {
	try child:=Acc.accChild(ChildId)
	return child?Acc_Query(child):
}
Acc_Query(Acc) { ; thanks Lexikos - www.autohotkey.com/forum/viewtopic.php?t=81731&p=509530#509530
	try return ComObj(9, ComObjQuery(Acc,"{618736e0-3c3d-11cf-810c-00aa00389b71}"), 1)
}
Acc_Error(p="") {
	static setting:=0
	return p=""?setting:setting:=p
}
Acc_Children(Acc) {
	if ComObjType(Acc,"Name") != "IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren%
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i), Children.Insert(NumGet(varChildren,i-8)=9?Acc_Query(child):child), NumGet(varChildren,i-8)=9?ObjRelease(child):
			return Children.MaxIndex()?Children:
		} else
		ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_ChildrenByRole(Acc, Role) {
	if ComObjType(Acc,"Name")!="IAccessible"
		ErrorLevel := "Invalid IAccessible Object"
	else {
		Acc_Init(), cChildren:=Acc.accChildCount, Children:=[]
		if DllCall("oleacc\AccessibleChildren", "Ptr",ComObjValue(Acc), "Int",0, "Int",cChildren, "Ptr",VarSetCapacity(varChildren,cChildren*(8+2*A_PtrSize),0)*0+&varChildren, "Int*",cChildren)=0 {
			Loop %cChildren% {
				i:=(A_Index-1)*(A_PtrSize*2+8)+8, child:=NumGet(varChildren,i)
				if NumGet(varChildren,i-8)=9
					AccChild:=Acc_Query(child), ObjRelease(child), Acc_Role(AccChild)=Role?Children.Insert(AccChild):
				else
					Acc_Role(Acc, child)=Role?Children.Insert(child):
			}
			return Children.MaxIndex()?Children:, ErrorLevel:=0
		} else
		ErrorLevel := "AccessibleChildren DllCall Failed"
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}
Acc_Get(Cmd, ChildPath="", ChildID=0, WinTitle="", WinText="", ExcludeTitle="", ExcludeText="") {
	static properties := {Action:"DefaultAction", DoAction:"DoDefaultAction", Keyboard:"KeyboardShortcut"}
	AccObj :=   IsObject(WinTitle)? WinTitle
	:   Acc_ObjectFromWindow( WinExist(WinTitle, WinText, ExcludeTitle, ExcludeText), 0 )
	if ComObjType(AccObj, "Name") != "IAccessible"
		ErrorLevel := "Could not access an IAccessible Object"
	else {
		StringReplace, ChildPath, ChildPath, _, %A_Space%, All
		AccError:=Acc_Error(), Acc_Error(true)
		Loop Parse, ChildPath, ., %A_Space%
			try {
			if A_LoopField is digit
				Children:=Acc_Children(AccObj), m2:=A_LoopField ; mimic "m2" output in else-statement
			else
				RegExMatch(A_LoopField, "(\D*)(\d*)", m), Children:=Acc_ChildrenByRole(AccObj, m1), m2:=(m2?m2:1)
			if Not Children.HasKey(m2)
				throw
			AccObj := Children[m2]
			} catch {
				ErrorLevel:="Cannot access ChildPath Item #" A_Index " -> " A_LoopField, Acc_Error(AccError)
				if Acc_Error()
					throw Exception("Cannot access ChildPath Item", -1, "Item #" A_Index " -> " A_LoopField)
				return
			}
			Acc_Error(AccError)
			StringReplace, Cmd, Cmd, %A_Space%, , All
			properties.HasKey(Cmd)? Cmd:=properties[Cmd]:
			try {
				if (Cmd = "Location")
					AccObj.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId)
				, ret_val := "x" NumGet(x,0,"int") " y" NumGet(y,0,"int") " w" NumGet(w,0,"int") " h" NumGet(h,0,"int")
				else if (Cmd = "Object")
					ret_val := AccObj
				else if Cmd in Role,State
					ret_val := Acc_%Cmd%(AccObj, ChildID+0)
				else if Cmd in ChildCount,Selection,Focus
					ret_val := AccObj["acc" Cmd]
				else
					ret_val := AccObj["acc" Cmd](ChildID+0)
			} catch {
				ErrorLevel := """" Cmd """ Cmd Not Implemented"
				if Acc_Error()
					throw Exception("Cmd Not Implemented", -1, Cmd)
				return
			}
			return ret_val, ErrorLevel:=0
	}
	if Acc_Error()
		throw Exception(ErrorLevel,-1)
}