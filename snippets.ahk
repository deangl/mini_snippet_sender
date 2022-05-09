#singleinstance
#Include .\toolFunc.ahk
#Include .\json2.ahk
global TheEdit
global toSend

hKey := json2(".\conf.json").hKey

hotkey, %hKey%, gogo


gogo(){
	snippetsFile := ".\snippets.json"
	SD := json2(snippetsFile)
	sendSnippet(SD)
	return
}


SnippetsGuiEscape:
	Gui Snippets:Destroy
	; exitapp
	return

SnippetsGuiClose:
	Gui Snippets:Destroy
	; exitapp
	return



creatSnippets(snippetsDistList){
	p := getCaretPos()
	if not p.x
	{
		return
	}
	global TheText
	Gui, Snippets:new, -MaximizeBox -MinimizeBox -Caption,Snippets
	Gui, Snippets:add, edit, vTheEdit
	sList:=""

	for i,l in snippetsDistList{
		sList := sList . "-------------------`n"
		for k,v in l{
			sList := sList . k . ":`t"
			sList := sList . v.name
			sList := sList . "`n"
		}

	}

	Gui,Snippets:add, text, , %sList%
	Gui, Add, Button, Hidden w0 h0 Default gSetMatch
	Gui, Snippets:Show, Hide
	Gui, +LastFound
	WinGetPos, , , w, h

	cx := p.x
	cy := p.y
	winPos := calcWinPos(cx,cy,w,h)
	x:=winPos.x
	y:=winPos.y
	Gui, Snippets:show, x%x% y%y%
	return
}

calcWinPos(cx,cy,w,h){
	; 不要出屏幕边缘
	winW := A_ScreenWidth
	winH := A_ScreenHeight
	x := Min(cx+5, winW-w-10)
	if (cy+h+30 < winH -5)
	{
		y:=cy+30
	}else{
		y := cy - 30 - h
	}
	return {x:x, y:y}
}

clearSnippetDictList(sdList){
	; 处理一个list中的obj们，如果有重复的key名，就在后面加数字后缀
	allKeys := {}
	rslt := []
	for i,l in sdList{
		r := {}
		for k,v in l{
			if allKeys[k]
			{
				k:= k . i
			}
			else
			{
				allKeys[k] := 1
			}
			r[k] := v
		}
		rslt.push(r)
	}

	return rslt
}

getMatchSnippet(snippetsDistList){
	global TheEdit
	Gui Snippets:Submit
	k:= TheEdit
	Gui Snippets:Destroy
	for i,l in snippetsDistList{
		if l[k]["string"]{
			return l[k]["string"]
		}
	}

}


getWindowInfo(){
	WinGetActiveTitle, title
	cid := getfocusedcontrol("Hwnd")
	controlgetfocus, contrl, %title%
	rslt := {title:title, contrl: contrl,cid:cID}
	return rslt
}



sendSnippet(snippetsConf){
	toSend := {}
	sDict := 
	winInfo := getWindowInfo()
	for k,v in snippetsConf{
		if Instr(winInfo.title,k){
			sDict := [v]
			break
		}
	}

	if snippetsConf.any{
		if not sDict{
			sDict := [snippetsConf.any]
		} else{
			sDict.push(snippetsConf.any)
		}
	}
	if sDict{
		sDict := clearSnippetDictList(sDict)
		toSend.winInfo := winInfo
		toSend.sDict := sDict
		creatSnippets(sDict)
	}
	return
}


SetMatch:
	global toSend
	snippetGot := getMatchSnippet(toSend.sDict)
	cid:= toSend.winInfo.cid
	controlfocus, ,ahk_id %cid%


	stringreplace, snippetForPos, snippetGot,``n,n,1
	iPos:=instr(snippetForPos,"<@>")
	l:=strlen(snippetForPos)
	stringreplace, snippetGot, snippetGot,``n,`r`n,1

	n := l-iPos-2
	stringreplace, snippetGot, snippetGot, <@>,,1
	sendinput {Text}%snippetGot%
	if iPos{
		loop, %n%
		{
			sendinput, {Left}
		}
	}
	return