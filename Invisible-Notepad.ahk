#SingleInstance Force

FileSettings := A_ScriptDir . "\PadSettings.ini"
;;FilePointer := A_ScriptDir . "\Warframe Needs.txt"

if (!FileExist(FileSettings)){
	file := FileOpen(FileSettings, "w")
	file.Write("[Main]`r`nX=0`r`nY=0`r`nW=400`r`nH=600`r`nTrans=180")
	file.close
}

IniRead, pos_x, %FileSettings%, Main, X
IniRead, pos_y, %FileSettings%, Main, Y
IniRead, pos_w, %FileSettings%, Main, W
IniRead, pos_h, %FileSettings%, Main, H
IniRead, Trans, %FileSettings%, Main, Trans
IniRead, FilePointer, %FileSettings%, Main, LastFile

GoSub, MakeSureGUI

global SliderH := 30
global SliderW := pos_w
global SliderX := 0
global SliderY := pos_h-SliderH
global ButtonX := 0
global ButtonY := 0
global ButtonW := 50
global ButtonH := 30
global TextBoxX := 0
global TextBoxY := ButtonH
global TextBoxH := pos_h-SliderH-TextBoxY
global TextBoxW := pos_w

Gui, 1:+Resize +LastFound
Gui, 1:Font, s12 wbold, Arial
Gui, 1:Margin, 0, 0
Gui, 1:Color, Black,Black


Gui, 1:Add, Edit, cWhite x%TextBoxX% y%TextBoxY% w%TextBoxW% h%TextBoxH% -Wrap vTextBox
Gui, 1:Add, Slider, x%SliderX% y%SliderY% w%SliderW% h%SliderH% gSlide vSlider NoTicks Range30-255 ToolTipTop, %Trans%


ShowingFileList := 0
ButtonX1 := 0, ButtonX2 := ButtonX1+ButtonW, ButtonX3 := ButtonX2+ButtonW
Gui, 1:Add, Button,	x%ButtonX1% y%ButtonY% w%ButtonW% h%ButtonH% vNewButton gNewFn, New
Gui, 1:Add, Button,	x%ButtonX2% y%ButtonY% w%ButtonW% h%ButtonH% vOpenButton gOpenFn, Open
Gui, 1:Add, Button,	x%ButtonX3% y%ButtonY% w%ButtonW% h%ButtonH% vCloseButton gCloseFn, Close

Gui, 1:Show, x%pos_x% y%pos_y%, Invisible Notepad
Winset, Transparent, %Trans%

FileRead, ReadText, %FilePointer%
GuiControl, ,TextBox, %ReadText%
	
Continue := 1
return





Slide:
	GuiControlGet, Trans, , Slider
	Winset, Transparent, %Trans%
return


MakeSureGUI:
	Gui, Sure:+LastFound -MaximizeBox -MinimizeBox
	Gui, Sure:Font, s16 wbold, Arial
	Gui, Sure:Add, Text, ,Do you want to save ???????
	
	Button2W := 80
	
	Gui, Sure:Font, s10 wnorm, Arial
	Gui, Sure:Add, Button, w%Button2W% gSaveFn,Save
	Gui, Sure:Add, Button, w%Button2W% xp+%Button2W% yp0 gDontSaveFn, Don't Save
	Gui, Sure:Add, Button, w%Button2W% xp+%Button2W% yp0 gCancelFn,Cancel
return

ShowSure:
	Gui, Sure:Show, x0 y0, Are you Sure?
return


NewFn:
	GuiControlGet, SaveText, ,TextBox
	SaveText := RegExReplace(SaveText, "\n", "`r`n")
	if (SaveText!=ReadText)
		GoSub, ShowSure
	While (WinExist("Are you Sure?"))
		Sleep 10
	if (Continue>0)
		GuiControl, ,TextBox
return

OpenFn:
	GuiControlGet, SaveText, ,TextBox
	SaveText := RegExReplace(SaveText, "\n", "`r`n")
	if (SaveText!=ReadText)
		GoSub, ShowSure
	While (WinExist("Are you Sure?"))
		Sleep 10
	if (Continue>0){
		FileSelectFile, FilePointer, 1, %A_ScriptDir%
		FileRead, ReadText, %FilePointer%
		GuiControl, ,TextBox, %ReadText%
	}
return

GuiClose:
CloseFn:
	FileRead, ReadText, %FilePointer%
	GuiControlGet, SaveText, ,TextBox
	SaveText := RegExReplace(SaveText, "\n", "`r`n")
	ReadText := RegExReplace(ReadText, "\n", "`r`n")
	;;Clipboard := SaveText . "`r`nXXXXXXXXXXXXXXXXXXXXXXX`r`n" . ReadText
	if (SaveText!=ReadText)
		GoSub, ShowSure
	While (WinExist("Are you Sure?"))
		Sleep 10
	WinGetPos, pos_x, pos_y, pos_w, pos_h, Invisible Notepad
	pos_w := pos_w-16
	pos_h := pos_h-39
	IniWrite, %pos_x%, %FileSettings%, Main, X
	IniWrite, %pos_y%, %FileSettings%, Main, Y
	IniWrite, %pos_w%, %FileSettings%, Main, W
	IniWrite, %pos_h%, %FileSettings%, Main, H
	IniWrite, %Trans%, %FileSettings%, Main, Trans
	IniWrite, %FilePointer%, %FileSettings%, Main, LastFile
	if (Continue>0)
		ExitApp
return

#IfWinActive,Invisible Notepad
~^s::
		SoundBeep
		GoSub, SaveFn
return

SaveFn:
	GuiControlGet, SaveText, ,TextBox
		if (!FileExist(FilePointer)){
			FileSelectFile, FilePointer, S, %A_ScriptDir%, Enter File to Save
		}
		file := FileOpen(FilePointer, "w")
		file.Write(SaveText)
		file.close()
		Continue := 1
		Gui, Sure:Hide
return

DontSaveFn:
	Continue := 1
	Gui, Sure:Hide
return

CancelFn:
	Continue := 0
	Gui, Sure:Hide
return

GuiSize(GuiHwnd, EventInfo, pos_w, pos_h){
	SliderW := pos_w
	SliderY := pos_h-SliderH
	TextBoxY := ButtonH
	TextBoxH := pos_h-SliderH-TextBoxY
	TextBoxW := pos_w
	GuiControl, Move, TextBox, x%TextBoxX% y%TextBoxY% w%TextBoxW% h%TextBoxH%
	GuiControl, Move, Slider, x%SliderX% y%SliderY% w%SliderW% h%SliderH%
}