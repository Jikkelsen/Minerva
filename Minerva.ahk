; Jonas Vollhaase Mikkelsen, 2020
; Contact: Mikkelsen.v.jonas@gmail.com
; 
; Used for formatted text inputter
;


#SingleInstance force       ; Cannot have multiple instances of program
;#MaxHotkeysPerInterval 200  ; Won't crash if button held down
#NoEnv                      ; Avoids checking empty variables to see if they are environment variables
#Persistent                 ; Script will stay running after auto-execute section completes 

SetWorkingDir, %A_ScriptDir%

; Globals
global ScriptName := "Minerva"
global Version    := "1.23"

;icon
if A_IsCompiled
    {
    Menu, Tray, Icon, __ASSETS__\Logo\icon.ico 
    }



; ######################################################################## Hotstring Init ########################################################################

if FileExist("hotstrings.txt")
{
	Loop
	{
        FileReadLine, line, hotstrings.txt, %A_Index%
		if ErrorLevel
			break
        
        FirstLetter         := SubStr(line, 1, 1) 
        CommentIdentifier   := "#"
        
        if (FirstLetter = CommentIdentifier)
        {
            continue
        }
    
        
        
		; ifstatement for comment goes here
		
		TextArray 	:= StrSplit(line, ";")       ; Split string into two substrings
		callsign 	:= Trim(TextArray[1])
		replacement	:= Trim(TextArray[2])
		
		Hotstring(callsign, replacement)
		
	}
}

; ######################################################################## Begin ########################################################################

; Stores all folderElements
allElements := []




; Now loop through every folder (and subfolder) in Texts and find the .clip files
Loop Files, %A_ScriptDir%\*.*, D R
{
    ; Stores all files that are inside this folder
    temp := []
    ; Get every file inside this folder
    Loop, Files, %A_LoopFileFullPath%\*.rtf
    {
        ; Add the file to the array
        ;~ temp.Push(A_LoopFileFullPath)
        temp.Push(A_LoopFileName)
    }

    ; Create a new folderElement
      element := new folderElement(A_LoopFileName, temp)
    ; Prepare the array
    element.prepareArray()
    ; Check if the element has files stored, if yes add it to the array
    If (element.hasFiles())
    {
        ; Pushes to the main array
        allElements.Push(element)
    }
}


; ######################################################################## Hotkeys ########################################################################


		
Control & Space::
if not WinActive("ahk_class XLMAIN")
    {
    HotstringMenu(allElements)          ; starts minerva, if not in excel
    }
else
    send, ^{space}                      ; Sends Crtl+space, if in excel
Return


; ######################################################################## Functions ########################################################################


HotstringMenu(PassedArray)
{
        
    Loop % PassedArray.Length()
    {
        ; The current item
        tempItem := PassedArray[A_Index]

        ; Store the current index for the submenu
        loopIndex := A_Index
        
        ; Get the name of the current submenu
        TESTE := tempItem.folderName

        ; Create a submenu for each element
        Loop, % tempItem.filesInFolder.Length()
        {
            Menu, %TESTE%, Add, % tempItem.filesInFolder[A_Index], MenuAction
        }
        
        
        folderName := % "&" . LoopIndex "  " . tempItem.folderName  ; Grants the shortcut dot "." concatenates 
       
        ; Add each folderName to the menu
        Menu, TheMenu, Add, % folderName, :%TESTE%
    }
    Menu, TheMenu, Add,
    
    Menu, Submenu1, Add, &1 Reload, ReloadProgram
    Menu, Submenu1, Add, &2 Exit, ExitApp
    Menu, Submenu1, Add, &3 Go to folder, GoToRootFolder
    Menu, Submenu1, Add, &4 Version number, VersionNumber

  ; Create a submenu in the first menu (a right-arrow indicator). When the user selects it, the second menu is displayed.
  Menu, TheMenu, Add, &0 Admin, :Submenu1
  ; end submenu test

    Menu, TheMenu, Show, % A_CaretX, % A_Carety    ; Puts the menu at caret
    Menu, TheMenu, DeleteAll                                      ; Removes it after use
}



MenuAction() 
{
    TextArray := StrSplit(A_ThisMenuItem, "  ")       ; Split string into two substrings
    TextOut := Trim(TextArray[2])                    ; Get second part, arrays start at 1, trim whitespace
  
    FilePath := A_ScriptDir "\" A_ThisMenu "\" TextOut

    ClipboardVar := ClipboardAll    ;stores content of clipboard in variable
    Clipboard =                     ;clears clipboard
    
    Send, {U+231B}      ; Loading Icon
    Send, {LEFT}
      
    oDoc := ComObjGet(FilePath)
    Sleep, 250
    oDoc.Range.FormattedText.Copy
    ;Sleep, 200
    
    ClipWait, 2
    if ErrorLevel
    {
        MsgBox, The attempt to copy text onto the clipboard failed.
        return
    }
    
    oDoc.Close(0)
    ;~ Sleep, 200
    ClipWait
    
    ;~ Send, {Backspace 1}
    ;~ Sleep, 40
    
    Paste()
    ;~ Clipboard := ClipboardVar  ??? Kommenter mig p?? igen en dag 
}

Paste()
{
    SendInput, {CTRL DOWN}
    Sleep, 1000
    SendInput, {v DOWN}
    SendInput, {v UP}
    SendInput, {CTRL UP}
    Send, {Delete 1}
    }

ReloadProgram()
{
    MsgBox, 64, About to restart %ScriptName%, Restarting %ScriptName%
    Reload
}

ExitApp()
{
    MsgBox, 48, About to exit %ScriptName%, %ScriptName% will TERMINATE when you click OK
    IfMsgBox OK
    ExitApp
}

GoToRootFolder()
{
    run, explore %A_ScriptDir%
}

VersionNumber()
{
    MsgBox, 64, Version number, %Version%
}


; ######################################################################## Classes ########################################################################

; Stores a folder path with all files inside (not recursive)
class FolderElement
{
    ; The name of the folder
    folderName := ""
   
    ; Stores every file inside the folder
    filesInFolder := []

    ; Constructer
    __New(name, files)
    {
        this.folderName     := name
        this.filesInFolder  := files
    }

    prepareArray()
    {
        Loop % this.filesInFolder.Length()
        {
            text := % "&" . A_Index . "  " . this.filesInFolder[A_Index]  ; dot "." concatenates 
            this.filesInFolder[A_Index] := text                            ; adds the seperators to stuff
        } 
    }

    ; Check if this element has files
    hasFiles()
    {
        Return (this.filesInFolder[1] = "") ? false : true      ; Shorthand if/else
    }
}

; ######################################################################## HotStrings ########################################################################

:*:,dt::
FormatTime, CurrentDateTime,, dd-MM-yyyy hh:mm  ; It will look like 06-11-2019 04:59
SendInput %CurrentDateTime%
return

::,d::
FormatTime, CurrentDateTime,, dd-MM-yyyy ; It will look like 06-11-2020
SendInput %CurrentDateTime%
return

::,t::
FormatTime, CurrentDateTime,, hh:mm  ; It will look like 04:59
SendInput %CurrentDateTime%
return

:*:,sd::
FormatTime, CurrentDateTime,, ddMMyy ; It will look like 061120
SendInput %CurrentDateTime% 
return



