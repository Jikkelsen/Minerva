#SingleInstance Force
/*
    __  __  _                                   _  _     ___  
   |  \/  |(_)                                 | || |   / _ \ 
   | \  / | _  _ __    ___  _ __ __   __ __ _  | || |_ | | | |
   | |\/| || || '_ \  / _ \| '__|\ \ / // _` | |__   _|| | | |
   | |  | || || | | ||  __/| |    \ V /| (_| |    | | _| |_| |
   |_|  |_||_||_| |_| \___||_|     \_/  \__,_|    |_|(_)\___/ 

   Name ...........: Minerva
   Description ....: Will generate a context menu from which to insert text, launch shortcuts and much more
   AHK Version ....: AHK_L 1.1.33.10 (Unicode 32-bit) - 28-12-2021
   Platform .......: Tested on Windows 10
   Language .......: English (en-US)
   Author .........: Jonas Vollhaase Mikkelsen <Mikkelsen.v.jonas@gmail.com>
   Documentation ..: Github.com
*/

;----------------------------------------------| VARIABLES |---------------------------------------------;
FileEncoding, UTF-8
global ScriptName := "Minerva"
global Version    := "4.0"
global items	  := 0
global MyProgress := 0
Global TotalWords := 0

; comment if Gdip.ahk is in your standard library
#Include, LoadingGraphics\Gdip.ahk 				

; Change tray icon from default
Menu, Tray, Icon, %A_ScriptDir%\icon\icon.ico

; Get amount of items in folder and prepare the menu
FindAmountItems()	
PrepareMenu(A_ScriptDir "\CustomMenuFiles") 

; Run other scripts in the "IncludeOtherScripts" folder
RunOtherScripts(A_ScriptDir "\IncludeOtherScripts")

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
	ExitApp
}
OnExit, Exit

Width  := A_ScreenWidth
Height := A_ScreenHeight
Gui, 1: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
Gui, 1: Show, NA

; Intro taken from GDIP library introduction, see https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk
hwnd1 := WinExist() 						; Get a handle to this window we have created in order to update it later
hbm   := CreateDIBSection(Width, Height) 	; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
hdc   := CreateCompatibleDC() 				; Get a device context compatible with the screen
obm   := SelectObject(hdc, hbm) 			; Select the bitmap into the device context
G     := Gdip_GraphicsFromHDC(hdc) 			; Get a pointer to the graphics of the bitmap, for use with drawing functions
Gdip_SetSmoothingMode(G, 4) 				; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)

; Create a slightly transparent gray brush to draw rectagle with
pBrush 	:= Gdip_BrushCreateSolid(0x80C7C7C7) 
Gdip_FillRectangle(G, pBrush, 0, 0, A_ScreenWidth, A_ScreenHeight)

; Create Hourglass image and draw it onto screen
pBitmap := Gdip_CreateBitmapFromFile("LoadingGraphics\Hourglass.png")
Gdip_DrawImage(G, pBitmap, A_ScreenWidth/2 - 128, A_ScreenHeight/2 - 128, Width/2, Height/2, 0, 0, Width, Height)

; Graphic has at this point been drawn, but view is not yet updated. Waiting to update view until script is called
return

; CODE AUTO-EXECUTE ENDS HERE

;------------------------------------------------| MENU |------------------------------------------------#
PrepareMenu(PATH)
{
	global
		
	; GUI loading/progress bar
	Gui, new, +ToolWindow, % ScriptName " is Loading"		; Adding title to progressbar
	Gui, add, Progress, w200 vMyProgress range1-%items%, 0	; Adding progressbar
	Gui, show	  											; Displaying Progressbar

	; Add Name, Icon and seperating line
	Menu, %PATH%, Add, % ScriptName " vers. " Version, About									; Name
	Menu, %PATH%, Icon,% ScriptName " vers. " Version, %A_ScriptDir%\Icon\Minerva-logo.png 		; Logo
	Menu, %PATH%, Add, 																			; seperating 
		
	; Add all custom items using algorithm 
	LoopOverFolder(Path)

	; Add Admin Panel
	Sleep, 200
	Menu, %PATH%, Add, 													; seperating line 
	Menu, %PATH%"\Admin", Add, &1 Restart, ReloadProgram				; Add Reload option
	Menu, %PATH%"\Admin", Add, &2 Exit, ExitApp							; Add Exit option
	Menu, %PATH%"\Admin", Add, &3 Go to Parent Folder, GoToRootFolder	; Open script folder
	Menu, %PATH%"\Admin", Add, &4 Add Custom Item, GoToCustomFolder		; Open custom folder
	Menu, %PATH%, Add, &0 Admin, :%PATH%"\Admin"						; Adds Admin section

	; Loadingbar GUI is no longer needed, remove it from memory
	Gui, Destroy 
}

;---------------------------------------| FOLDER ADDING ALGORITHM |--------------------------------------;

; From the perspective of a folder, items are read top to bottom, but AHK Expects menus to be build from bottom to top.
; Therefore; recurse into the most bottom element, note all the elements on the way there, and build from bottom up
LoopOverFolder(PATH)
{
	; Prepare empty arrays for folders and files
	FolderArray := []
	FileArray   := []
	
	; Loop over all files and folders in input path, but do NOT recurse
	Loop, Files, %PATH%\* , DF
	{
		; Clear return value from last iteration, and assign it to attribute of current item
		VALUE := ""
		VALUE := FileExist(A_LoopFilePath)
		
		; Current item is a directory
		if (VALUE = "D")
		{
			;~ MsgBox, % "Pushing to folders`n" A_LoopFilePath
			FolderArray.Push(A_LoopFilePath)
		}
		; Current item is a file
		else
		{
			;~ MsgBox, % "Pushing to files`n" A_LoopFilePath
			FileArray.Push(A_LoopFilePath)
		}
	}
	
	; Arrays are sorted to get alphabetical representation in GUI menu
	Sort, FolderArray
	Sort, FileArray
	
	; First add all folders, so files have a place to stay
	for index, element in FolderArray
	{
		; Recurse into next folder
		LoopOverFolder(element)
		
		; Then add it as item to menu
		SplitPath, element, name, dir, ext, name_no_ext, drive
		Menu, %dir%, Add, %name%, :%element%
		
		; Iterate loading GUI progress
		FoundItem("Folder")
	}
	
	; Then add all files to folders
	for index, element in FileArray
	{
		; Add To Menu
		SplitPath, element, name, dir, ext, name_no_ext, drive
		Menu, %dir%, Add, %name%, MenuEventHandler
		
		; Iterate GUI loading
		FoundItem("File")
	}
}


;-----------------------------------------------| HOTKEYS |----------------------------------------------;

; Bring up Minerva Menu
Ctrl & RShift::
Menu, %A_ScriptDir%\CustomMenuFiles, show
return

; Reload program if Graphics for whatever reason does not work
LShift & Delete::
	Reload
return


;-----------------------------------------------| LABELS |-----------------------------------------------#;
; Labels are a simple .AHK implementation of Functions (which .AHK also supports), but only labels are supported some places - like in menus.
; See more here: https://www.autohotkey.com/board/topic/25097-are-there-any-advantages-with-labels-over-functions/

; This is called when user selects an item from a menu in GUI window
MenuEventHandler:
{
	; Draw the rectangle, the hourglass and update the Window
	Gdip_FillRectangle(G, pBrush, 0, 0, A_ScreenWidth, A_ScreenHeight)
	Gdip_DrawImage(G, pBitmap, A_ScreenWidth/2 - 128, A_ScreenHeight/2 - 128, Width/2, Height/2, 0, 0, Width, Height)
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)  ;This is what actually changes the display
	
	; Get Extension of item to evaluate what handler to use
	WordArray := StrSplit(A_ThisMenuItem, ".")
	FileExtension := % WordArray[WordArray.MaxIndex()]
	
	; Get full path from Menu Item pass to handler
	FileItem := SubStr(A_ThisMenuItem, 2, StrLen(A_ThisMenuItem))
	FilePath := % A_ThisMenu "\" A_ThisMenuItem	
	
	; Run item with appropriate handler
	Switch FileExtension
	{
		case "rtf" : Handler_RTF(FilePath)
		case "bat" : Handler_LaunchProgram(FilePath)
		case "txt" : Handler_txt(FilePath)
		case "lnk" : Handler_LaunchProgram(FilePath)
		case "exe" : Handler_LaunchProgram(FilePath)
		Default: Handler_Default(FilePath)
	}
	
	; Clear the graphics and update thw window
	Gdip_GraphicsClear(G)  								  ;This sets the entire area of the graphics to 'transparent'
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)  ;This is what actually changes the display
		
	return
}

; Is run when the program exits. This will take care of now unused graphics elements
Exit:
{
	Gdip_DeleteBrush(pBrush) 	; Delete the brush as it is no longer needed and wastes memory
	SelectObject(hdc, obm) 		; Select the object back into the hdc
	DeleteObject(hbm) 			; Now the bitmap may be deleted
	DeleteDC(hdc) 				; Also the device context related to the bitmap may be deleted
	Gdip_DeleteGraphics(G) 		; The graphics may now be deleted
	
	; gdi+ may now be shutdown on exiting the program
	Gdip_Shutdown(pToken)
	ExitApp
	Return
}

DrawGraphics:
{
	; Draw the rectangle and hourglass to the graphic
	Gdip_FillRectangle(G, pBrush, 0, 0, A_ScreenWidth, A_ScreenHeight)
	Gdip_DrawImage(G, pBitmap, A_ScreenWidth/2 - 128, A_ScreenHeight/2 - 128, Width/2, Height/2, 0, 0, Width, Height)
	
	; Update the display to show the graphcis
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)  
	return
}

DeleteGraphics:
{
	; This sets the entire area of the graphics to 'transparent'
	Gdip_GraphicsClear(G)  
	
	; Update the display to ide the graphics
	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)  
	return
}


;----------------------------------------------| FUNCTIONS |---------------------------------------------;
; ---- Handlers ----

; Case not known; try to open the file
Handler_Default(PATH)
{
	MsgBox, 48,, "No Default action for this filetype, attempting to run it"
	Handler_LaunchProgram(PATH)
}

; contents of .txt should be copied to clipboard and pasted. This is fast.
Handler_txt(PATH)
{
	FileRead, Clipboard, %PATH%
	
	; Gets amount of words (spaces) in file just pasted
	GetWordCount()						
	Sleep, 50
	
	; Adds Info to file
	AddAmountFile(A_ThisMenuItem, TotalWords)
	Sleep, 50
	
	; Paste content of clipboard
	Send, ^v
}

; If program is executable, simply launch it
Handler_LaunchProgram(FilePath)
{
	run, %FilePath%
}

; .rtf files should be opened with a ComObject, that silently opens the file and copies the formatted text. Then paste
Handler_RTF(FilePath)
{
	; Clears clipboard. Syntax looks werid, but it is right.
	Clipboard =                     
	Sleep, 200
	
	; Load contents of file into memory
	oDoc := ComObjGet(FilePath)
	Sleep, 250
	
	; Copy contents of file into clipboard
	oDoc.Range.FormattedText.Copy
	Sleep, 250
	
	; Wait up to two seconds for content to appear on the clipboard
	ClipWait, 2
	if ErrorLevel
	{
		MsgBox, The attempt to copy text onto the clipboard failed.
		return
	}
	
	; File is no longer needed, close it
	oDoc.Close(0)
	Sleep, 250
	
	; Gets amount of words (spaces) in file just pasted
	GetWordCount()						
	Sleep, 50
	
	; Add amount words to the AmountFile
	AddAmountFile(A_ThisMenuItem, TotalWords)
	Sleep, 50
	
	; Then Paste 
	Send, ^v
	Sleep, 50
}

; ---- Other Functions ----
; Amountfile is a .csv that the user can use to see how much info was saved. 
AddAmountFile(FileName, WordCount)
{
	; Average Typing speed is 40 wpm pr. https://www.typingpal.com/en/typing-test
	MinutesSaved := WordCount / 40
	
	; It will look like 28-12-2021 13:23
	FormatTime, CurrentDateTime,, dd-MM-yyyy HH:mm 
	
	; Check if file already exists. All other times than the very first run, it will exist.
	; If if not, create it and append, otherwise just append
	if FileExist("AmountUsed.csv") 					
	{
		FileAppend, %CurrentDateTime%`,%FileName%`,%WordCount%`,%MinutesSaved%`n, %A_ScriptDir%\AmountUsed.csv
	}
	else 										
	{
		FileAppend, Date`,Text`,Word Count`,Minutes Saved`n, %A_ScriptDir%\AmountUsed.csv
		FileAppend, %CurrentDateTime%`,%FileName%`,%WordCount%`,%MinutesSaved%`n, %A_ScriptDir%\AmountUsed.csv
	}
}

; Gets the amount of words on the clipboard
GetWordCount()
{
	Global TotalWords := 0
	Loop, parse, clipboard, %A_Space%,
	{
		TotalWords = %A_Index%
	}
}

; Recursively 
FindAmountItems()
{
	Loop, Files, %A_ScriptDir%\*, FR
	{
		global items := items+ 1
	} 
}

; Iterate step of the GUI process bar by one
FoundItem(WhatWasFound)
{
	global
	GuiControl,, MyProgress, +1

	; Comment in for Debug
	;~ Sleep, 50
	;~ MsgBox, % "Found " WhatWasFound ": " A_LoopFileName "`n`nWith Path:`n" A_LoopFileFullPath "`n`nIn Folder`n" A_LoopFileDir
}

; Restarts the program. This is handy for updates in the code
ReloadProgram()
{
    MsgBox, 64, About to restart %ScriptName%, Restarting %ScriptName%
    Reload
}

; Exits the program
ExitApp()
{
    MsgBox, 48, About to exit %ScriptName%, %ScriptName% will TERMINATE when you click OK
    IfMsgBox OK
    ExitApp
}

; Opens explorer window in root folder of script 
GoToRootFolder()
{
    run, explore %A_ScriptDir%
}

; Opens explorer window in folder where custom folders and menu item goes
GoToCustomFolder()
{
	run, explore %A_ScriptDir%\CustomMenuFiles
}

; Launch Github repo
About()
{
	run, https://github.com/jikkelsen/Minerva
}

; Attemps to start all other files in the specified path.
RunOtherScripts(PATH)
{
	Loop, Files, %PATH%\* , F
	{
		;~ MsgBox, % "Including:`n" A_LoopFilePath
		run, %A_LoopFilePath%
	}
}