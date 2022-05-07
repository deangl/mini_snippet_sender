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