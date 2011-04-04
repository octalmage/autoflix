/*
                 __           ____    ___                  
                /\ \__       /\  _`\ /\_ \    __           
   __     __  __\ \ ,_\   ___\ \ \L\_\//\ \  /\_\   __  _  
 /'__`\  /\ \/\ \\ \ \/  / __`\ \  _\/ \ \ \ \/\ \ /\ \/'\ 
/\ \L\.\_\ \ \_\ \\ \ \_/\ \L\ \ \ \/   \_\ \_\ \ \\/>  </ 
\ \__/.\_\\ \____/ \ \__\ \____/\ \_\   /\____\\ \_\/\_/\_\
 \/__/\/_/ \/___/   \/__/\/___/  \/_/   \/____/ \/_/\//\/_/

-------------------------------
| Program Settings        |
-------------------------------
*/            

#singleinstance force
SetWorkingDir, %A_ScriptDir%
SetTitleMatchMode, 2
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
;PID := DllCall("GetCurrentProcessId")


/*
-------------------------------
| Hotkeys					   |
-------------------------------
*/      
hotkey, lbutton, SELECT_SCREENSHOT_AREA
hotkey, lbutton, off
hotkey, esc, cancel_screenshot
hotkey, esc, off



/*
-------------------------------
| Variables                    |
-------------------------------
*/      
ES_DISPLAY_REQUIRED := 0x00000002
version=1.7.9
ontop=0
;By default autoFlix is always on.
on=1
x1:=(a_screenwidth/2)-200
y1:=(a_screenheight/2)-200
;using VirtualWidth and height for multimonitor support.
SysGet, VirtualWidth, 78
SysGet, VirtualHeight, 79





/*
-------------------------------
| User Settings             |
-------------------------------
*/      
if not FileExist("autoFlix.ini")
{
	IniWrite, 0,autoFlix.ini,Settings, antisleep
    IniWrite, 0,autoFlix.ini,Settings, startup
	IniWrite, 0,autoFlix.ini,Settings, custompng
	gosub thanks
}

IniRead, antisleep, autoFlix.ini, Settings,antisleep
IniRead, startup, autoFlix.ini, Settings,startup
IniRead,custompng, autoFlix.ini, Settings,custompng


/*
-------------------------------
| Included Files             |
-------------------------------
*/      
fileinstall,logo.ico,logo.ico
fileinstall,search.png,search.png


/*
-------------------------------
| Tray Menu                  |
-------------------------------
*/    
;autoFlix requires higher privileges on Vista and 7 to save the custom image. This was added to support Compile_AHK II 
;http://www.autohotkey.com/forum/viewtopic.php?t=22975
if A_IsCompiled
  Menu, Tray, Icon, %A_ScriptFullPath%, -159
menu, tray, NoStandard
menu, tray, add, On, flixon
menu, tray, Check, On
menu, tray, add ; separator
;menu, tray, add, Always on top?, netcheck
menu, tray, add, Settings, settings
menu, tray, add ; separator
menu,tray,add,Exit,cleanup


/*
-------------------------------
| Timers                       |
-------------------------------
*/   
settimer, autoflix, 1000
settimer, CheckWindowsState, 30000
return

Thanks:
gui 60: default
gui,add,text,,Thank you for installing and using autoFlix.
gui,add,text,,If autoFlix isn't working immediately, please try the Custom Image button located in the settings menu.
gui,add,text,cBlue gsettings, Launch settings menu
gui,add,text,, If you find any bugs`, or have any feature requests please visit the link below. 
gui,add,text,cBlue gwebsite, http://code.google.com/p/autoflix/
gui,add,button,gintrobegone,Thanks!
gui,show,xcenter ycenter,Introduction
gui 1: default
return

introbegone:
gui 60:destroy
return

website:
run http://code.google.com/p/autoflix/

return

autoflix:
	if not winexist("Netflix")
		return
	if !on
	{
		return
	}
	WinGetActiveStats, Netflix, net_w, net_h, net_x, net_y 
	if fileexist("custom.png")
	{
		ImageSearch, foundx,foundy, net_x, net_y,net_w,net_h, custom.png
	}
	else
	{
		ImageSearch, foundx,foundy, net_x, net_y,net_w,net_h, search.png
	}
	if !ErrorLevel
	{
		foundx:=foundx+10
		foundy:=foundy+10
		SystemCursor(off) 
		mouseclick , , %FoundX%, %FoundY%
		mousemove,%VirtualWidth%, %FoundY%
		SystemCursor(on) 
		sleep 10000
	}

return


flixon:
	menu, tray, ToggleCheck, On
	if on=1
	{
		on=0
	}
	else
	{
		on=1
	}
return

netcheck:
	menu, tray, ToggleCheck, Always on top?
	if ontop=0
	{
		ontop=1
	}
	else
	{
		ontop=0
	}
return


sleepcheck:
	menu, tray, ToggleCheck, Anti-Sleep
	if antisleep=0
	{
		antisleep=1
	}
	else
	{
		antisleep=0
	}
return


cleanup:
	IniWrite, %antisleep%,autoFlix.ini,Settings, antisleep
    IniWrite, %startup%,autoFlix.ini,Settings, startup
exitapp


CheckWindowsState:
	if antisleep=1
	{
		If ( WinActive("ahk_class AGFullScreenWinClass") || WinActive("ahk_class ShockwaveFlashFullScreen") )
		{
			DllCall("SetThreadExecutionState", UInt, ES_DISPLAY_REQUIRED) ;prevent sleep
		}
	}
Return


settings:

	gui, destroy
	gui,color, b9090b
	
	Gui, Add, picture, x29,autoflix.png
	Gui, Font, S12 cwhite normal, Verdana
	if startup
	{
		Gui, Add, CheckBox, x12 y50 w190 h20 vstartup checked, Run at Startup?
	}
	Else
	{
		Gui, Add, CheckBox, x12 y50 w190 h20 vstartup, Run at Startup?
	}
	if antisleep
	{
		Gui, Add, CheckBox, x12 y80 w190 h20 vantisleep checked, Anti-Sleep Mode
	}
	Else
	{
		Gui, Add, CheckBox, x12 y80 w190 h20 vantisleep , Anti-Sleep Mode
	}
	gui,add,button,gcustompng, Custom Image
	gui,add,text,,autoFlix v%version%
	Gui, Add, Button, x92 y178 w80 h20 gsave, Save
	Gui, Show, w180 h206, Settings

Return

custompng:

	msgbox Open Netflix and get to the end of an episode. (so the next button is showing). `n Click ok when you are ready.
	winactivate, Netflix
	loop	
	{
		WinWaitActive Netflix,,5
		if errorlevel
		{
			MsgBox, 4,, Could not find the Netflix window, would you like to continue waiting?
			IfMsgBox Yes
				continue
			else
				return
		}
		else
			break
	}
	msgbox Click and drag around the outside of the next button. `nPress Escape at any time to cancel.
	winmaximize, Netflix
	WinWaitActive Netflix
	sleep 500
	file= temp.png
	sc_CaptureScreen(0, false,file )
	gui 99:default
	gui -caption +toolwindow
	gui, add, picture, x0 y0, temp.png
	gui, show, x0 y0 w%a_screenwidth% h%a_screenheight%
	gui 1: default
	hotkey, lbutton, on
return


esc::
	hotkey, lbutton, off
return



save:
	gui,submit
	gui,destroy

	IniWrite, %antisleep%,autoFlix.ini,Settings, antisleep
    IniWrite, %startup%,autoFlix.ini,Settings, startup
    
    if startup=1
    {
		RegWrite, REG_SZ,HKCU,Software\Microsoft\Windows\CurrentVersion\Run,autoFlix, "%A_ScriptFullPath%"
	}
	Else
	{
		RegDelete, HKCU,Software\Microsoft\Windows\CurrentVersion\Run,autoFlix
	}
return

GuiClose:
	gui,destroy
return

SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
    static AndMask, XorMask, $, h_cursor
        ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13 ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13   ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13   ; handles of default cursors
    if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
    {
        $ = h                                          ; active default cursors
        VarSetCapacity( h_cursor,4444, 1 )
        VarSetCapacity( AndMask, 32*4, 0xFF )
        VarSetCapacity( XorMask, 32*4, 0 )
        system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
        StringSplit c, system_cursors, `,
        Loop %c0%
        {
            h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
            h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
            b%A_Index% := DllCall("CreateCursor","uint",0, "int",0, "int",0
                , "int",32, "int",32, "uint",&AndMask, "uint",&XorMask )
        }
    }
    if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
        $ = b  ; use blank cursors
    else
        $ = h  ; use the saved cursors

    Loop %c0%
    {
        h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
        DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
    }
}



EmptyMem(pid){
    pid:=(pid) ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}










cancel_screenshot:
	hotkey, esc, off
	gui 99: destroy
	filedelete, temp.png
return



;// Create partial window screenshot //
TakeScreenshot:
{
	arect = %SS_WinxPos% , %SS_WinyPos%, %winbottomx%, %winbottomy%
	file= %A_ScriptDir%\custom.png
	sc_CaptureScreen(arect, false,file )
	gui 99: destroy
	filedelete, temp.png
	msgbox Image Saved!
}
Return


SELECT_SCREENSHOT_AREA: 
{
	hotkey, esc, on

	CoordMode, Mouse ,Screen
	MouseGetPos, MX, MY

	Gui, 5:Color, EEAA99
	Gui, 5:+Lastfound
	WinSet, TransColor, EEAA99
	Gui, 5:-Caption +Border

	Loop
    {
		if GetKeyState("esc", "P")
		{
			gosub cancel_screenshot
			return
		}
		else If GetKeyState("LButton", "P")
        {
          MouseGetPos, MXend, MYend
          w := abs(MX - MXend)
          h := abs(MY - MYend)
          If ( MX < MXend )
              X := MX
          Else
              X := MXend
          If ( MY < MYend )
              Y := MY
          Else
              Y := MYend
          Gui, 5:Show, x%X% y%Y% w%w% h%h%
        }
      Else
          Break
    }
	MouseGetPos, MXend, MYend
	Gui, 5:Destroy

	SS_WinxPos=%MX%
	SS_WinyPos=%MY%
	winbottomy=%MYend%
	winbottomx=%MXend%
	hotkey, lbutton, off
	gosub TakeScreenshot
} 
Return


sc_CaptureScreen(aRect = 0, bCursor = False, sFile = "", nQuality = "")
{
	If	!aRect
	{
		SysGet, nL, 76
		SysGet, nT, 77
		SysGet, nW, 78
		SysGet, nH, 79
	}
	Else If	aRect = 1
		WinGetPos, nL, nT, nW, nH, A
	Else If	aRect = 2
	{
		WinGet, hWnd, ID, A
		VarSetCapacity(rt, 16, 0)
		DllCall("GetClientRect" , "Uint", hWnd, "Uint", &rt)
		DllCall("ClientToScreen", "Uint", hWnd, "Uint", &rt)
		nL := NumGet(rt, 0, "int")
		nT := NumGet(rt, 4, "int")
		nW := NumGet(rt, 8)
		nH := NumGet(rt,12)
	}
	Else If	aRect = 3
	{
		VarSetCapacity(mi, 40, 0)
		DllCall("GetCursorPos", "int64P", pt)
		DllCall("GetMonitorInfo", "Uint", DllCall("MonitorFromPoint", "int64", pt, "Uint", 2), "Uint", NumPut(40,mi)-4)
		nL := NumGet(mi, 4, "int")
		nT := NumGet(mi, 8, "int")
		nW := NumGet(mi,12, "int") - nL
		nH := NumGet(mi,16, "int") - nT
	}
	Else
	{
		StringSplit, rt, aRect, `,, %A_Space%%A_Tab%
		nL := rt1
		nT := rt2
		nW := rt3 - rt1
		nH := rt4 - rt2
		znW := rt5
		znH := rt6
	}

	mDC := DllCall("CreateCompatibleDC", "Uint", 0)
	hBM := sc_CreateDIBSection(mDC, nW, nH)
	oBM := DllCall("SelectObject", "Uint", mDC, "Uint", hBM)
	hDC := DllCall("GetDC", "Uint", 0)
	DllCall("BitBlt", "Uint", mDC, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", hDC, "int", nL, "int", nT, "Uint", 0x40000000 | 0x00CC0020)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	If	bCursor
		sc_CaptureCursor(mDC, nL, nT)
	DllCall("SelectObject", "Uint", mDC, "Uint", oBM)
	DllCall("DeleteDC", "Uint", mDC)
	If	znW && znH
		hBM := sc_Zoomer(hBM, nW, nH, znW, znH)
	If	sFile = 0
		sc_SetClipboardData(hBM)
	Else	sc_Convert(hBM, sFile, nQuality), DllCall("DeleteObject", "Uint", hBM)
}

sc_CaptureCursor(hDC, nL, nT)
{
	VarSetCapacity(mi, 20, 0)
	mi := Chr(20)
	DllCall("GetCursorInfo", "Uint", &mi)
	bShow   := NumGet(mi, 4)
	hCursor := NumGet(mi, 8)
	xCursor := NumGet(mi,12)
	yCursor := NumGet(mi,16)

	VarSetCapacity(ni, 20, 0)
	DllCall("GetIconInfo", "Uint", hCursor, "Uint", &ni)
	xHotspot := NumGet(ni, 4)
	yHotspot := NumGet(ni, 8)
	hBMMask  := NumGet(ni,12)
	hBMColor := NumGet(ni,16)

	If	bShow
		DllCall("DrawIcon", "Uint", hDC, "int", xCursor - xHotspot - nL, "int", yCursor - yHotspot - nT, "Uint", hCursor)
	If	hBMMask
		DllCall("DeleteObject", "Uint", hBMMask)
	If	hBMColor
		DllCall("DeleteObject", "Uint", hBMColor)
}

sc_Zoomer(hBM, nW, nH, znW, znH)
{
	mDC1 := DllCall("CreateCompatibleDC", "Uint", 0)
	mDC2 := DllCall("CreateCompatibleDC", "Uint", 0)
	zhBM := sc_CreateDIBSection(mDC2, znW, znH)
	oBM1 := DllCall("SelectObject", "Uint", mDC1, "Uint",  hBM)
	oBM2 := DllCall("SelectObject", "Uint", mDC2, "Uint", zhBM)
	DllCall("SetStretchBltMode", "Uint", mDC2, "int", 4)
	DllCall("StretchBlt", "Uint", mDC2, "int", 0, "int", 0, "int", znW, "int", znH, "Uint", mDC1, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", 0x00CC0020)
	DllCall("SelectObject", "Uint", mDC1, "Uint", oBM1)
	DllCall("SelectObject", "Uint", mDC2, "Uint", oBM2)
	DllCall("DeleteDC", "Uint", mDC1)
	DllCall("DeleteDC", "Uint", mDC2)
	DllCall("DeleteObject", "Uint", hBM)
	Return	zhBM
}

sc_Convert(sFileFr = "", sFileTo = "", nQuality = "")
{
	If	sFileTo  =
		sFileTo := A_ScriptDir . "\screen.bmp"
	SplitPath, sFileTo, , sDirTo, sExtTo, sNameTo

	If Not	hGdiPlus := DllCall("LoadLibrary", "str", "gdiplus.dll")
		Return	sFileFr+0 ? sc_SaveHBITMAPToFile(sFileFr, sDirTo . "\" . sNameTo . ".bmp") : ""
	VarSetCapacity(si, 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", "UintP", pToken, "Uint", &si, "Uint", 0)

	If	!sFileFr
	{
		DllCall("OpenClipboard", "Uint", 0)
		If	 DllCall("IsClipboardFormatAvailable", "Uint", 2) && (hBM:=DllCall("GetClipboardData", "Uint", 2))
		DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Uint", hBM, "Uint", 0, "UintP", pImage)
		DllCall("CloseClipboard")
	}
	Else If	sFileFr Is Integer
		DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Uint", sFileFr, "Uint", 0, "UintP", pImage)
	Else	DllCall("gdiplus\GdipLoadImageFromFile", "Uint", sc_Unicode4Ansi(wFileFr,sFileFr), "UintP", pImage)

	DllCall("gdiplus\GdipGetImageEncodersSize", "UintP", nCount, "UintP", nSize)
	VarSetCapacity(ci,nSize,0)
	DllCall("gdiplus\GdipGetImageEncoders", "Uint", nCount, "Uint", nSize, "Uint", &ci)
	Loop, %	nCount
		If	InStr(sc_Ansi4Unicode(NumGet(ci,76*(A_Index-1)+44)), "." . sExtTo)
		{
			pCodec := &ci+76*(A_Index-1)
			Break
		}
	If	InStr(".JPG.JPEG.JPE.JFIF", "." . sExtTo) && nQuality<>"" && pImage && pCodec
	{
	DllCall("gdiplus\GdipGetEncoderParameterListSize", "Uint", pImage, "Uint", pCodec, "UintP", nSize)
	VarSetCapacity(pi,nSize,0)
	DllCall("gdiplus\GdipGetEncoderParameterList", "Uint", pImage, "Uint", pCodec, "Uint", nSize, "Uint", &pi)
	Loop, %	NumGet(pi)
		If	NumGet(pi,28*(A_Index-1)+20)=1 && NumGet(pi,28*(A_Index-1)+24)=6
		{
			pParam := &pi+28*(A_Index-1)
			NumPut(nQuality,NumGet(NumPut(4,NumPut(1,pParam+0)+20)))
			Break
		}
	}

	If	pImage
		pCodec	? DllCall("gdiplus\GdipSaveImageToFile", "Uint", pImage, "Uint", sc_Unicode4Ansi(wFileTo,sFileTo), "Uint", pCodec, "Uint", pParam) : DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Uint", pImage, "UintP", hBitmap, "Uint", 0) . sc_SetClipboardData(hBitmap), DllCall("gdiplus\GdipDisposeImage", "Uint", pImage)

	DllCall("gdiplus\GdiplusShutdown" , "Uint", pToken)
	DllCall("FreeLibrary", "Uint", hGdiPlus)
}

sc_CreateDIBSection(hDC, nW, nH, bpp = 32, ByRef pBits = "")
{
	NumPut(VarSetCapacity(bi, 40, 0), bi)
	NumPut(nW, bi, 4)
	NumPut(nH, bi, 8)
	NumPut(bpp, NumPut(1, bi, 12, "UShort"), 0, "Ushort")
	NumPut(0,  bi,16)
	Return	DllCall("gdi32\CreateDIBSection", "Uint", hDC, "Uint", &bi, "Uint", 0, "UintP", pBits, "Uint", 0, "Uint", 0)
}

sc_SaveHBITMAPToFile(hBitmap, sFile)
{
	DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
	hFile:=	DllCall("CreateFile", "Uint", &sFile, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "int64P", 0x4D42|14+40+NumGet(oi,44)<<16, "Uint", 6, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "Uint", &oi+24, "Uint", 40, "UintP", 0, "Uint", 0)
	DllCall("WriteFile", "Uint", hFile, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44), "UintP", 0, "Uint", 0)
	DllCall("CloseHandle", "Uint", hFile)
}

sc_SetClipboardData(hBitmap)
{
	DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
	hDIB :=	DllCall("GlobalAlloc", "Uint", 2, "Uint", 40+NumGet(oi,44))
	pDIB :=	DllCall("GlobalLock", "Uint", hDIB)
	DllCall("RtlMoveMemory", "Uint", pDIB, "Uint", &oi+24, "Uint", 40)
	DllCall("RtlMoveMemory", "Uint", pDIB+40, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44))
	DllCall("GlobalUnlock", "Uint", hDIB)
	DllCall("DeleteObject", "Uint", hBitmap)
	DllCall("OpenClipboard", "Uint", 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "Uint", 8, "Uint", hDIB)
	DllCall("CloseClipboard")
}

sc_Unicode4Ansi(ByRef wString, sString)
{
	nSize := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2)
	DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize)
	Return	&wString
}

sc_Ansi4Unicode(pString)
{
	nSize := DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
	Return	sString
}




GDIplus_Start()
{
	local r, structGdiplusStartupInput

	; Note: LoadLibrary *must* be called, otherwise on each call of the GDIplus
	; functions, AutoHotkey will free the DLL, and we loose the token, crashing AHK!
	#hGDIplusDLL := DllCall("LoadLibrary", "Str", "GDIplus.dll")
	If (#hGDIplusDLL = 0)
	{
		MsgBox 16, GDIplus Wrapper, You need the GDIplus.dll in your path!
		Exit
	}

	VarSetCapacity(structGdiplusStartupInput, 4 * 4, 0)
	SetInteger(structGdiplusStartupInput, 1)    ; Version
	r := DllCall("GDIplus.dll\GdiplusStartup"
			, "UInt *", #GDIplus_token
			, "UInt", &structGdiplusStartupInput
			, "UInt", 0)
	
	Return r
}

; Close GDI+ library
GDIplus_Stop()
{
	DllCall("GDIplus.dll\GdiplusShutdown"
			, "UInt", #GDIplus_token)
	DllCall("FreeLibrary", "UInt", #hGDIplusDLL)
	#hGDIplusDLL := 0
}

GDIplus_CaptureScreenRectangle(ByRef @bitmap
		, _x=0, _y=0
		, _w=0, _h=0
		, _hwndWindow=0)
{
	local result, bRes, r, hOld
	local hdcWindow, hdcBuffer, hbmpBuffer

	result := 0

	If (_hwndWindow!=0)
	{
		WinGetPos, ,,_w, _h, ahk_id %_hwndWindow%
		_x =0
		_y =0
	}
	else if (_w < 0 or _h < 0)
	{
		_x := 0
		_y := 0		
		_w := A_ScreenWidth
		_h := A_ScreenHeight
	}
	
	If (_hwndWindow = 0)
		hdcWindow := DllCall("GetDC", "UInt",  _hwndWindow)
	Else
		hdcWindow := DllCall("GetWindowDC", "UInt",  _hwndWindow)
	If (hdcWindow = 0)
	{
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}
	
	; Create the buffer holding the capture
	hdcBuffer := DllCall("GDI32.dll\CreateCompatibleDC", "UInt", hdcWindow)
	If (hdcBuffer = 0)
	{
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}
	hbmpBuffer := DllCall("GDI32.dll\CreateCompatibleBitmap"
			, "UInt", hdcWindow
			, "Int", _w
			, "Int", _h)
	If (hbmpBuffer = 0)
	{
	   result := -1
		Goto CaptureScreenRectangle_CleanUp
	}
	hOld := DllCall("GDI32.dll\SelectObject", "UInt", hdcBuffer, "UInt", hbmpBuffer)
	If (hOld = 0)
	{
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}
	bRes := DllCall("GDI32.dll\BitBlt"
			, "UInt", hdcBuffer	; HDC hdcDest
			, "Int", 0			; nXDest
			, "Int", 0			; nYDest
			, "Int", _w			; nWidth
			, "Int", _h			; nHeight
			, "UInt", hdcWindow	; HDC hdcSrc
			, "Int", _x			; nXSrc
			, "Int", _y			; nYSrc
			, "UInt", 0x00CC0020)	; DWORD dwRop=SRCCOPY
	If (!bRes)
	{
		result := -1
		Goto CaptureScreenRectangle_CleanUp
	}

	r := DllCall("GDIplus.dll\GdipCreateBitmapFromHBITMAP"
			, "UInt", hbmpBuffer
			, "UInt", 0
			, "UInt *", @bitmap)
	If (r != 0)
	{
		result := r
		Goto CaptureScreenRectangle_CleanUp
	}

CaptureScreenRectangle_CleanUp:
	DllCall("GDI32.dll\DeleteObject", "UInt", hbmpBuffer)
	DllCall("GDI32.dll\DeleteDC", "UInt", hdcBuffer)
	DllCall("GDI32.dll\ReleaseDC", "UInt", hdcWindow)

	Return result
}

; Save an image on a file
GDIplus_SaveImage(_image, _fileName, ByRef @clsidEncoder, ByRef @encoderParams)
{
	local r, ufn, encoderAddr

	If @encoderParams = NONE
		encoderAddr := 0
	Else
		encoderAddr := &@encoderParams
	GetUnicodeString(ufn, _fileName)
	r := DllCall("GDIplus.dll\GdipSaveImageToFile"
			, "UInt", _image
			, "UInt", &ufn
			, "UInt", &@clsidEncoder
			, "UInt", encoderAddr)
	Return r
}

; Free the memory allocated for an image
GDIplus_FreeImage(_image)
{
	local r

	r := DllCall("GDIplus.dll\GdipDisposeImage"
			, "UInt", _image)
	
	Return r
}

GDIplus_GetEncoderCLSID(ByRef @encoderCLSID, _mimeType)
{
	local r, numEncoders, size, encoders, encoderAddr, sizeImageCodecInfo
	local addr, mimeTypeAddr, mimeType, codecIdentifierAddr

	; What size do we need?
	r := DllCall("GDIplus.dll\GdipGetImageEncodersSize"
			, "UInt *", numEncoders
			, "UInt *", size)

	; Allocate this size
	VarSetCapacity(encoders, size, 0)
	; And get the listing of encoders
	r := DllCall("GDIplus.dll\GdipGetImageEncoders"
			, "UInt", numEncoders
			, "UInt", size
			, "UInt", &encoders)
	
	encoderAddr := &encoders

	sizeImageCodecInfo := 76
	mimeTypeOffset := 48
	
	; Loop through all the codecs
	codecIdentifierAddr = 0
	Loop %numEncoders%
	{
		addr := encoderAddr + 48
		mimeTypeAddr := *addr + (*(addr + 1) << 8) +  (*(addr + 2) << 16) + (*(addr + 3) << 24)
		mimeType := GetAnsiStringFromUnicodePointer(mimeTypeAddr)
		If (mimeType = _mimeType)
		{
			; We found it!
			codecIdentifierAddr := encoderAddr
			Break
		}
		encoderAddr += sizeImageCodecInfo
	}

	If (codecIdentifierAddr = 0)
	{
		; Not found
		r := 1	
	}
	Else
	{
		; Copy the CLSID of the codec
		VarSetCapacity(@encoderCLSID, #sizeOfCLSID, 0)
		DllCall("RtlMoveMemory"
				, "UInt", &@encoderCLSID
				, "UInt", codecIdentifierAddr
				, "Int", #sizeOfCLSID)
	}

	Return r
}

SetInteger(ByRef @dest, _integer, _offset = 0, _size = 4)
{
	Loop %_size%  ; Copy each byte in the integer into the structure as raw binary data.
	{
		DllCall("RtlFillMemory"
				, "UInt", &@dest + _offset + A_Index-1
				, "UInt", 1
				, "UChar", (_integer >> 8*(A_Index-1)) & 0xFF)
	}
}

; Some API functions require a WCHAR string.
GetUnicodeString(ByRef @unicodeString, _ansiString)
{
	local len

	len := StrLen(_ansiString)
	VarSetCapacity(@unicodeString, len * 2 + 1, 0)

	; http://msdn.microsoft.com/library/default.asp?url=/library/en-us/intl/unicode_17si.asp
	DllCall("MultiByteToWideChar"
			, "UInt", 0             ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
			, "UInt", 0             ; dwFlags
			, "Str", _ansiString    ; LPSTR lpMultiByteStr
			, "Int", len            ; cbMultiByte: -1=null terminated
			, "UInt", &@unicodeString ; LPCWSTR lpWideCharStr
			, "Int", len)           ; cchWideChar: 0 to get required size
}

; Some API functions return a WCHAR string.
GetAnsiStringFromUnicodePointer(_unicodeStringPt)
{
	local len, ansiString

	len := DllCall("lstrlenW", "UInt", _unicodeStringPt)
	VarSetCapacity(ansiString, len, 0)

	DllCall("WideCharToMultiByte"
			, "UInt", 0           ; CodePage: CP_ACP=0 (current Ansi), CP_UTF7=65000, CP_UTF8=65001
			, "UInt", 0           ; dwFlags
			, "UInt", _unicodeStringPt ; LPCWSTR lpWideCharStr
			, "Int", len          ; cchWideChar: size in WCHAR values, -1=null terminated
			, "Str", ansiString   ; LPSTR lpMultiByteStr
			, "Int", len          ; cbMultiByte: 0 to get required size
			, "UInt", 0           ; LPCSTR lpDefaultChar
			, "UInt", 0)          ; LPBOOL lpUsedDefaultChar

	Return ansiString
}

DisableCloseButton(hWnd="") {
 If hWnd=
    hWnd:=WinExist("A")
 hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
 nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
 DllCall("DrawMenuBar","Int",hWnd)
Return ""
}
