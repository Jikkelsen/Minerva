# Minerva

Minerva is an open source [Autohotkey](https://www.autohotkey.com/) replacement for [Georgias Emailtemplates](https://chrome.google.com/webstore/detail/gorgias-templates-email-t/lmcngpkjkplipamgflhioabnhnopeabf?hl=en)

Minerva uses a hotkey combination, `Ctrl + RightShift` to bring up a GUI menu, from where users can quickly insert the following
* prewritten **formatted** text from `.rtf` documents
* Unformatted text from `.txt` documents
* Open `.lnk`, `.bat` and `.exe` files directly
* Much more

The GUI menu will be autopopulated with text and folders from the folder that Minerva lives in.

## Prerequisites
* Be on a Windows Computer
* [Autohotkey](https://www.autohotkey.com/) must be installed

## Installation
Download this *entire* repository and open Minerva.ahk with AutoHotkey.

### Executable
You can also use Minerva.exe, which can work standalone w/o AutoHotKey. It stil expects to see the folder structure in this repository

## Usage
By default, `Crtl + RightShift` brings up the Minerva menu. From here, navigate to the desired folder, and choose the text you wish to insert.
The first character of a folder name will also act as hotkey.

### Example
A folder structure like this ... 

    │   AmountUsed.csv
    │   Minerva4.ahk
    │   readme.md
    │
    ├───CustomMenuFiles
    │   ├───1 - Nested Folders & .txt
    │   │   │   Example 1.txt
    │   │   │   Example 2.txt
    │   │   │
    │   │   └───Nested folder
    │   │       └───Deeply Nested folder
    │   │               placeholder.txt
    │   │
    │   ├───2 - Formatted text with .rtf
    │   │       Enligsh text for mail.rtf
    │   │       Showcase.rtf
    │   │
    │   └───3 - Links, batch files and executables
    │           Opgaver.bat
    │
    ├───Icon
    │       icon.ico
    │       Minerva-logo.png
    │
    ├───IncludeOtherScripts
    └───LoadingGraphics
    		Gdip.ahk
    		Hourglass.png

... will result in a popup like this

![image](https://user-images.githubusercontent.com/22538066/147783312-bd6ae0a7-7735-40c2-b499-1e3dabce35b2.png)

When you have written your `.rtf` files reload Minerva either by using the admin panel or by killing the process and reopening it.

## Starting Minerva on Windows startup

Standing in the directory that Minerva lays in:
1. rightclick the .exe (or .ahk, if you would rather use that) file
2. `Create shortcut` and cut it
3. press `win + r` and write `shell:startup`
4. Paste the shortcut from before 
5. Reboot to confirm 

## Launch Additional scripts on Minerva startup
Any additional scripts, programs and other expecutable files in `./IncludeOtherScripts` will be launched when Minerva opens.

## Acknowledgements
* Thanks to [iconfinder](https://www.iconfinder.com/search?q=hourglass&price=free) for the loading graphic
* Thanks to Taric Porter for his amazing [GDI+ library](https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk) for autohotkey

## TODO
* Performance optimize
* Make .ini file 
* Allow for `.docx` files in input
