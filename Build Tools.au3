#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Comment=This program helps IT professionals automate your work.
#AutoIt3Wrapper_Res_Description=Automation Software By Jacob Stewart
#AutoIt3Wrapper_Res_Fileversion=4.1.1.0
#AutoIt3Wrapper_Res_ProductName=Build Tools4.1.1.0
#AutoIt3Wrapper_Res_ProductVersion=4.1.1.0
#AutoIt3Wrapper_Res_CompanyName=jTech Computers
#AutoIt3Wrapper_Res_LegalCopyright=NA
#AutoIt3Wrapper_Res_LegalTradeMarks=NA
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Global $version="4.1.1.1"
;VERSION 4 AND ABOVE IS NOW HOSTED ON GITHUB.COM
Global $admin=0
If FileExists(@ScriptDir&"\admin") Then $admin=1

$Progress=ProgressOn("Starting...","Starting...","Loading varables...")
ProgressSet(20,"Setting up Varables...")
#Region ==================================================================================================================== Var

;=== Include ===
#include <File.au3>
#include <GUIComboBoxEx.au3>

;=== Error ===
$ErrorMissingFiles=0

;=== Links ===
Global $LinkWebsiteHelp="https://github.com/kingjacob280/BuildTools/wiki/Help"
Global $LinkWebsite="https://github.com/kingjacob280/BuildTools"
Global $LinkCurrentVersion="https://raw.githubusercontent.com/kingjacob280/BuildTools/main/current%20version.txt"
Global $LinkGrabify="https://grabify.link/KQJ835" ; Tracking link for stats

;=== Dir ===
Global $DirBin=@ScriptDir&"\Build Tools"
If Not FileExists($DirBin) Then DirCreate($DirBin)
Global $DirInstallers=$DirBin&"\Installers"
Global $DirOther=$DirBin&"\Other"

;=== File ===
Global $fileLog=$DirBin&"\Log.log"
Global $FileClipHistory=$DirBin&"\ClipBoardHistory.txt"
_log("---running---") ;Start the log file

;SetDefaultBrowser.exe
Global $FileDefaultBrowserEXE=$DirOther&"\SetDefaultBrowser.exe"
If Not FileExists($FileDefaultBrowserEXE) Then $ErrorMissingFiles+=1

;anydesk.exe
Global $FileAnyDesk=$DirOther&"\anydesk.exe"
If Not FileExists($FileAnyDesk) Then $ErrorMissingFiles+=1

Global $FileStartUp=@ScriptDir&"\Startup=true"
Global $FileStartUpLink=@StartupCommonDir&"\buildtools.lnk"
Global $fileKnownDirectories=$DirBin&"\Known Directories.txt"
If Not FileExists($fileKnownDirectories) Then FileWrite($fileKnownDirectories,"\AppData\Roaming\Thunderbird\Profiles")

;=== User Folder Dir ===
Global $DirFromFolder="unknow"
Global $DirToFolder=@UserProfileDir
_log("File Check Done")

;=== Version ===
Global $CurrentVersion=BinaryToString(InetRead($LinkCurrentVersion))
$CurrentVersion=StringStripWS($CurrentVersion,8)
If $CurrentVersion="" Then
	_log("ERROR: Could not get current version")
	$CurrentVersion="unknown"
Else
	_log("Current Version Read: "&$CurrentVersion)
EndIf

;=== COLOR ===
Global $colorOrange=0xF89123
Global $colorRED_dark=0x990000
Global $colorRed=0xff0000
Global $colorGreen=0x478a00
Global $colorBlue=0x000fb0
Global $colorBlack=0x000000
Global $colorPink=0xff54cf

;=== GUI Button ===
$FontButtons=10
$WeightButtons=700
$AttButtons=""
$FontNameButtons=""
$SpacingButtons=25

;=== Server ===
Global $ServerActive=0
Global $ClientActive=0
Global $ServerIP=@IPAddress1
Global $ServerPort=65432

;=== REG ===
Global $regSearch[3] = ["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search","SearchboxTaskbarMode","REG_DWORD"]
Global $regTask[3] = ["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowTaskViewButton","REG_DWORD"]
Global $regCortana[3]=["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced","ShowCortanaButton","REG_DWORD"]
Global $regHibernateEnabled[3]=["HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Power","HibernateEnabled","REG_DWORD"]
;DATA = ChromeHTML
Global $regBrowser1[3]=["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.htm\UserChoice","ProgId","REG_SZ"]

;=== GLOBAL ===
Global $CheckSoftware[99]
Global $StatusSearch, $StatusTask, $StatusCortana
Global $ButtonAbout, $ButtonInstall, $ButtonLog, $ButtonSearchIcon, $ButtonTaskIcon, $ButtonCopyAll
Global $ComboFromDrive, $ComboUsersFrom, $LableUserFromDir
Global $Socket, $SocketListen
Global $FontButtons,$WeightButtons,$AttButtons,$FontNameButtons, $SpacingButtons

;=== stopping decloration error ===
Global $ButtonSearchIcon="error"
Global $ButtonTaskIcon="error"
Global $ButtonGoogleChromeDefault="error"
Global $ButtonCortanaIcon="error"
Global $ButtonHibernateEnabled="error"

_log("Vars loaded")
;----Running live
#EndRegion ==================================================================================================================== Var
ProgressSet(60,"More setup...")

#Region ==================================================================================================================== Startup


If FileExists($FileStartUp) Then ;--------------------------- Remove startup files (if existes)
	$temp=FileDelete($FileStartUp)
	$temp2=FileDelete($FileStartUpLink)
	_log("startup files deleted, code: "&$temp&$temp2)
EndIf

If $admin=0 Then InetRead($LinkGrabify,3) ; Tracking for stats

If $ErrorMissingFiles>0 Then
	MsgBox(48,"Warning!","Warning! There are "&$ErrorMissingFiles&" missing files, please re-download the software folder!")
	_log("WARNING: SetDefaultBrowser.exe is missing!")
EndIf

_log("Version: "&$version)

#EndRegion==================================================================================================================== Startup

#Region ==================================================================================================================== Var/Status Setup

Func _StatusGoogleChromeDefault()
	$regBrowser1Read=RegRead($regBrowser1[0],$regBrowser1[1])
	If $regBrowser1Read="ChromeHTML" Then
		$StatusGoogleChrome="Is Default"
	Else
		$StatusGoogleChrome="Not Default"
	EndIf
	GUICtrlSetData($ButtonGoogleChromeDefault,"Chrome ("&$StatusGoogleChrome&")")
EndFunc

Func _StatusHibernateEnabled()
	$regHibernateEnabledRead=RegRead($regHibernateEnabled[0],$regHibernateEnabled[1])
	If $regHibernateEnabledRead=1 Then
		$StatusHibernateEnabled="Is On"
	ElseIf $regHibernateEnabledRead=0 Then
		$StatusHibernateEnabled="Is Off"
	Else
		$StatusHibernateEnabled="Unknown"
	EndIf
	GUICtrlSetData($ButtonHibernateEnabled,"Fast Boot ("&$StatusHibernateEnabled&")")
EndFunc

#EndRegion ==================================================================================================================== Var/Status Setup
ProgressSet(80,"Building GUI...")

#Region ==================================================================================================================== GUI setup
Global $guiH, $guiW
$guiH=725
$guiW=450
$guiName="Build Tools (v"&$version&")"
If $admin=1 Then $guiName="Build Tools (v"&$Version&") - admin"
GUICreate($guiName,$guiW,$guiH)
	GUISetBkColor(0xffffff)

; --------------------------------------------------------------------------------------- Bottom

$ButtonAbout=GUICtrlCreateButton("about",$guiW-82,$guiH-22,80,20)
	GUICtrlSetFont(01,7)
	GUICtrlSetColor(-1,$colorBlue)

$ButtonHelp=GUICtrlCreateButton("help",$guiW-164,$guiH-22,80,20)
	GUICtrlSetFont(01,7)
	GUICtrlSetColor(-1,$colorBlue)

$ButtonWebsite=GUICtrlCreateButton("GitHub Page",5,$guiH-22,135,20)
	GUICtrlSetFont(01,7)
	GUICtrlSetColor(-1,$colorBlue)
$ButtonUpdate=GUICtrlCreateButton("Update ("&$CurrentVersion&")",140,$guiH-22,135,20)
	GUICtrlSetFont(01,7)
	If $CurrentVersion>$version Then
		GUICtrlSetColor(-1,$colorOrange)
	Else
		GUICtrlSetColor(-1,$colorBlue)
	EndIf

$LableCurrentClip=GUICtrlCreateLabel("Current Clipboard: "&ClipGet(),5,$guiH-215,$guiW-10,15)
	GUICtrlSetColor(-1,$colorGreen)
$ButtonClear=GUICtrlCreateButton("Clear",5,$guiH-200,75)
GUICtrlCreateLabel("Clipboard History - (This will be keeped even after program is closed)",85,$guiH-195,$guiW-90)
	GUICtrlSetFont(-1,8,700)
$ListClipHistory=GUICtrlCreateList(ClipGet(),5,$guiH-175,$guiW-10,150)
If FileExists($FileClipHistory) Then
	$count=_FileCountLines($FileClipHistory)
	For $i=1 to $count Step 1
		GUICtrlSetData($ListClipHistory,FileReadLine($FileClipHistory,$i))
	Next
EndIf



; --------------------------------------------------------------------------------------- TOP
$top=5
GUICtrlCreateLabel('Build Tools - By Jacob Stewart',5,$top,$guiW-10,15,0x01)
	GUICtrlSetFont(-1,11,600)
	GUICtrlSetBkColor(-1,0xdbdbdb)

; --------------------------------------------------------------------------------------- LEFT
$width=$guiW/2-3
$top+=20

;Software setup
Global $SoftwareSearch=_FileListToArray($DirInstallers,"*.exe")

Global $SoftwareError=0
If Not @error Then
	For $i=1 To $SoftwareSearch[0] step 1
		$CheckSoftware[$i]=GUICtrlCreateCheckbox(StringTrimRight($SoftwareSearch[$i],4),5,$top,$width,15)
		GUICtrlSetBkColor(-1,0xbdbdbd)
		$top+=20
	Next
	$SoftwareError=0

Else
	$SoftwareError=1
	_log("No Software!")
EndIf

$ButtonInstall=GUICtrlCreateButton("Install Selected",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons
$ButtonAddInstallers=GUICtrlCreateButton("Add More Installers",5,$top,$width,25)
$top+=55

$ButtonHibernateEnabled=GUICtrlCreateButton("Fast Boot On/Off",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

$ButtonTaskbarIconsSetDefault=GUICtrlCreateButton("Taskbar Icons to Default",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

$ButtonExplorerRestart=GUICtrlCreateButton("Restart Explorer",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

$ButtonSetupAnyDesk=GUICtrlCreateButton("Setup AnyDesk",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

$ButtonGoogleChromeDefault=GUICtrlCreateButton("Google Chrome Default",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

$ButtonPowerOptions=GUICtrlCreateButton("Power Options",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

$ButtonUpdateWindows=GUICtrlCreateButton("Update Windows",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

$LableComputerName=GUICtrlCreateLabel("Computer Name: "&@ComputerName,5,$top,$width,25)
$top+=20
$ButtonChangeComputerName=GUICtrlCreateButton("Change",5,$top,$width*0.3,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$InputChangeComputerName=GUICtrlCreateInput(@YEAR&"-LAPTOP",($width*0.3)+10,$top,$width*0.65,25)
	GUICtrlSetFont(-1,11,500)
$top+=$SpacingButtons

#cs; Not used yet because of coding dificalties
$ButtonChangeUserName=GUICtrlCreateButton("Change Account User Name",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons
#ce

$ButtonReboot=GUICtrlCreateButton("Reboot Computer",5,$top,$width,25)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=$SpacingButtons

; --------------------------------------------------------------------------------------- RIGHT

$top=25
$left=($guiW/2)+3
$width=$guiW/2-6

GUICtrlCreateLabel("TCP:",$left,$top+3,30)
	GUICtrlSetFont(-1,10,700)
$ButtonServerOnOFF=GUICtrlCreateButton("Server",$left+35,$top,($width/2)-20)
	GUICtrlSetFont(-1,10,700)
$ButtonClientOnOFF=GUICtrlCreateButton("Client",$left+($width/2)+15,$top,($width/2)-20)
	GUICtrlSetFont(-1,10,700)
$top+=35

GUICtrlCreateLabel("Server IP:",$left,$top+2,70)
	GUICtrlSetFont(-1,10,700)
$InputServerIP=GUICtrlCreateInput($ServerIP,$left+75,$top,$width-80)
	GUICtrlSetFont(-1,9,700)
$top+=25

GUICtrlCreateLabel("Port:",$left,$top+2,70)
	GUICtrlSetFont(-1,10,700)
$InputServerPort=GUICtrlCreateInput($ServerPort,$left+75,$top,$width-80)
	GUICtrlSetFont(-1,9,700)
$top+=30

GUICtrlCreateLabel("  Server to Client Copy  ",$left,$top,$width,-1,0x01)
	GUICtrlSetFont(-1,10,700,4)
	GUICtrlSetColor(-1,$colorGreen)
$top+=20

$InputCopy=GUICtrlCreateInput("Message to send to client (or recive)",$left,$top,$width)
$top+=25

$ButtonUpdateCopy=GUICtrlCreateButton("Update and Copy",$left,$top,$width/2)
	GUICtrlSetFont(-1,8,700)
$ButtonPast=GUICtrlCreateButton("Paste",$left+$width/2,$top,$width/2)
	GUICtrlSetFont(-1,8,700)
$top+=35

GUICtrlCreateLabel("  Folder Copy  ",$left,$top,$width,-1,0x01) ; -- Folder Copy
	GUICtrlSetFont(-1,10,700,4)
	GUICtrlSetColor(-1,$colorGreen)
$top+=20
GUICtrlCreateLabel("  FROM  ",$left,$top,$width,-1,0x01)
	GUICtrlSetFont(-1,10,700)
$top+=20

$ButtonBrowseFromFolder=GUICtrlCreateButton("Browse to user profile folder",$left,$top,$width)
$top+=25

$LableFromDir=GUICtrlCreateLabel($DirFromFolder,$left,$top,$width)
$top+=20

GUICtrlCreateLabel("  TO  ",$left,$top,$width,-1,0x01)
	GUICtrlSetFont(-1,10,700)
$top+=20

$ButtonBrowseToFolder=GUICtrlCreateButton("Browse to destination folder",$left,$top,$width)
$top+=25

$LablToDir=GUICtrlCreateLabel($DirToFolder,$left,$top,$width)
$top+=20

$ButtonCopyUserData=GUICtrlCreateButton("Copy All (Except Appdata)",$left,$top,$width)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=25

$ButtonCopyChromeData=GUICtrlCreateButton("Copy Chrome Data",$left,$top,$width)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=25

$ButtonCopyFromCombo=GUICtrlCreateButton("Copy From:",$left,$top,$width)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)
$top+=25
$ComboCopyFrom=GUICtrlCreateCombo("\Appdata\Roaming\Microsoft\Outlook",$left,$top,$width)
$lines=_FileCountLines($fileKnownDirectories)
For $i=1 To $lines Step 1
	GUICtrlSetData($ComboCopyFrom,FileReadLine($fileKnownDirectories,$i))
Next
$top+=25
$ButtonAddKnownDirectories=GUICtrlCreateButton("Add More Known Directories",$left,$top,$width)
$top+=25
$ButtonImportExportAutoStream=GUICtrlCreateButton("Import/Export Auto Stream",$left,$top,$width)
	GUICtrlSetFont(-1,$FontButtons,$WeightButtons,$AttButtons,$FontNameButtons)

; -- Last GUI setup

GUISetState()

#EndRegion ==================================================================================================================== GUI setup

#Region ==================================================================================================================== Last call (var setup)
_StatusGoogleChromeDefault()
_StatusHibernateEnabled()

Global $ClipCurrent=ClipGet()
Global $ClipTimer=TimerInit()

ProgressSet(100,"Done")
_log("Loading Done")
Sleep(300)
#EndRegion
ProgressOff()

#Region ==================================================================================================================== While Loop 1 -- MAIN
While 1
	$guiMSG = GUIGetMsg()
	If $ServerActive=1 Then _Server()
	If $ClientActive=1 Then _Client()

	If TimerDiff($ClipTimer)>1000 Then
		$ClipRead=ClipGet()
		If $ClipRead<>$ClipCurrent And $ClipRead<>"" Then
			$ClipCurrent=ClipGet()
			GUICtrlSetData($LableCurrentClip,"Current Clipboard: "&$ClipCurrent)
			GUICtrlSetData($ListClipHistory,$ClipCurrent)
			FileWrite($FileClipHistory,$ClipCurrent&@CRLF)

		EndIf
	EndIf


	Switch $guiMSG
		Case -3
			_exit(0)

		Case $ListClipHistory ;ClipBoard History
			$ClipCurrent=GUICtrlRead($ListClipHistory)
			ClipPut($ClipCurrent)
			GUICtrlSetData($LableCurrentClip,"Current Clipboard: "&$ClipCurrent)

		Case $ButtonClear ;ClipBoard History
			FileDelete($FileClipHistory)
			GUICtrlSetData($ListClipHistory,"")

		Case $ButtonAbout
			MsgBox(0,"About","Program Designed and Written by Jacob Stewart"&@CRLF&"Version: "&$version)

		Case $ButtonTaskbarIconsSetDefault
			_TaskbarIconsToDefault()

		Case $ButtonExplorerRestart
			Run('"' & @ComSpec & '" /k ' &"taskkill /F /IM explorer.exe && start explorer",@WindowsDir,@SW_HIDE) ;restart explorer.exe
			GUICtrlSetBkColor($ButtonExplorerRestart,15069691)

		Case $ButtonUpdateWindows
			Run('"' & @ComSpec & '" /k ' &"C:\Windows\System32\control.exe /name Microsoft.WindowsUpdate",@WindowsDir,@SW_HIDE)

		Case $ButtonInstall
			_install()

		Case $ButtonGoogleChromeDefault
			_ChromeMakeDefault()

		Case $ButtonServerOnOFF
			_Server()

		Case $ButtonClientOnOFF
			_Client()

		Case $ButtonUpdateCopy
			_Client()
			ClipPut(GUICtrlRead($InputCopy))

		Case $ButtonPast
			GUICtrlSetData($InputCopy,ClipGet())

		Case $ButtonWebsite
			ShellExecute($LinkWebsite)

		Case $ButtonHelp
			ShellExecute($LinkWebsiteHelp)

		Case $ButtonBrowseFromFolder
			$Temp=FileSelectFolder("Browse to user folder you would like to copy","::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
			If Not @error=1 Then
				$DirFromFolder=$Temp
				GUICtrlSetData($LableFromDir,$DirFromFolder)
			EndIf

		Case $ButtonBrowseToFolder
			$Temp=FileSelectFolder("Browse to user folder you would like to copy","::{20D04FE0-3AEA-1069-A2D8-08002B30309D}")
			If Not @error=1 Then
				$DirToFolder=$Temp
				GUICtrlSetData($LablToDir,$DirToFolder)
			EndIf

		Case $ButtonCopyUserData
			_CopyAllButAppdata()

		Case $ButtonCopyChromeData
			_copyChromeData()

		Case $ButtonCopyFromCombo
			_CopyFromCombo()

		Case $ButtonSetupAnyDesk
			_SetupAnyDesk()

		Case $ButtonChangeComputerName
			_ChangeComputerName()

		Case $ButtonReboot
			_Reboot()

		Case $ButtonHibernateEnabled
			_FastBootOnOff()

		Case $ButtonAddKnownDirectories
			ShellExecute($fileKnownDirectories)
			MsgBox(0,"Info","Program will need to be reloaded.",3)

		;Case $ButtonChangeUserName ;Future use
			;_ChangeUserName()

		Case $ButtonAddInstallers
			ShellExecute($DirInstallers)
			MsgBox(0,"Info","Program will need to be reloaded.",3)

		Case $ButtonUpdate
			_Update()

		;Case $ButtonLog
			;ShellExecute($fileLog)

		Case $ButtonPowerOptions
			_PowerOptions()

		Case $ButtonImportExportAutoStream
			_ImportExportAutoStream()

		;Case
	EndSwitch
WEnd
#EndRegion ==================================================================================================================== While Loop 1 -- MAIN

#Region ==================================================================================================================== FUNCTIONS

Func _ImportExportAutoStream()

	_log("_ImportExportAutoStream called")


	If Not FileExists(@LocalAppDataDir&"\Microsoft\Outlook\RoamCache") Then
		MsgBox(16,"Error","Outlook 'RoamCache' folder does not exist!"&@CRLF&"Please setup Outlook First.")
		Return
	EndIf

	If ProcessExists("OUTLOOK.exe") Then
		$temp=MsgBox(48,"WARNING","Please close outlook!")
	EndIf


	FileChangeDir(@LocalAppDataDir&"\Microsoft\Outlook\RoamCache")
	$_ImportExportAutoStream_Search=FileFindFirstFile("Stream_Autocomplete*.*")
	$count=0
	Do
		$_ImportExportAutoStream_SearchTemp=FileFindNextFile($_ImportExportAutoStream_Search)
		If @error<>1 Then
			$_ImportExportAutoStream_FileCurrentLocalStream=$_ImportExportAutoStream_SearchTemp
			$count+=1
		EndIf
	Until @error=1
	If $count>1 Then
		MsgBox(48,"WARNING","There is more than 1 Auto Stream File!")
		_log("WARNING: More than one auto stream file found. Count: "&$count)
	EndIf

	$_ImportExportAutoStream_GUI=GUICreate("Import/Export Auto Stream",$guiW-20,40)
	$_ImportExportAutoStream_GUI_ButtonExport=GUICtrlCreateButton("Export/Backup",5,5,($guiW-20)/2-5,25)
	$_ImportExportAutoStream_GUI_ButtonImport=GUICtrlCreateButton("Import",($guiW-20)/2,5,($guiW-20)/2-5,25)

	GUISetState(@SW_SHOW,$_ImportExportAutoStream_GUI)

	While 1
		$guiMSG=GUIGetMsg()

		Switch $guiMSG
			Case $_ImportExportAutoStream_GUI_ButtonExport
				GUIDelete($_ImportExportAutoStream_GUI)
				MsgBox(0,"","Please Backup this file by selecting a 'To' destination folder under 'Folder Copy' and backing up the 'known directory': \Appdata\Local\Microsoft\Outlook")
				ExitLoop

			Case $_ImportExportAutoStream_GUI_ButtonImport
				GUIDelete($_ImportExportAutoStream_GUI)
				$_ImportExportAutoStream_FileImport=FileOpenDialog("Import Auto Stream File",$DirFromFolder&"\Appdata\Local\Microsoft\Outlook\RoamCache","Stream (Stream_Autocomplete*.*)",3)
				ExitLoop

			Case -3
				GUIDelete($_ImportExportAutoStream_GUI)
				Return


		EndSwitch
	WEnd

	Return

EndFunc


Func _PowerOptions()

	_log("_PowerOptions called")
	ShellExecute("powercfg.cpl")

EndFunc

Func _Update()

	_log("_Update called")

	$_UpdateLink="https://github.com/kingjacob280/BuildTools/raw/main/Build%20Tools%20"&$CurrentVersion&".exe"
	$_UpdateFileName="Build Tools "&$CurrentVersion&".exe"

	If $CurrentVersion>$version And $CurrentVersion<>"unknown" Then
		$temp=MsgBox(4,"Update","There is a new update (Version: "&$CurrentVersion&"). Would you like to download and run this update?"&@CRLF&"It is recomended that you read the version log changes on the GitHub page first.")
		If $temp=6 Then
			_log("There is a new version. Downloading...")
			$temp=InetGet($_UpdateLink,$_UpdateFileName,0,1)
			$temp3=0
			$_UpdateError=0
			$tempTimer=TimerInit()
			Do
				$temp2=InetGetInfo($temp,0)
				If $temp2=0 And TimerDiff($tempTimer)>3000 Then
					$temp3=1
					$_UpdateError=1
				EndIf
				If InetGetInfo($temp,3)="True" Then $temp3=1
				Sleep(50)
			Until $temp3=1
			If $_UpdateError=1 Then
				_log("ERROR: downloading new build tools.exe from link: "&$_UpdateLink)
				MsgBox(48,"ERROR","There was an error downloading the update!",5)
			Else
				ShellExecute($_UpdateFileName)
				_exit(0)
			EndIf
		EndIf
	Else
		MsgBox(0,"Update","There is no new updates :)")
	EndIf

EndFunc

Func _ChangeUserName()

	_log("_ChangeUserName called")
	MsgBox(0,"ERROR","Work in Progress, please see source code.")
	#cs ; This command does not yet work, dir does not get renamed AND the full name of the user does not update. -Change user name -Change Dir name
	$_ChangeUserName_SID=_SidGet()
	$temp=MsgBox(4,"Change User Name","Please Read:"&@CRLF&@CRLF&"Do you want to change the name of user "&@UserName&" and do these two number look similar?"&@CRLF&"S-1-5-21-3912756739-280575556-4175553296-500"&@CRLF&$_ChangeUserName_SID)
	If $temp=6 Then
		$_ChangeUserName_NewUserName=InputBox("Change User Name","Input the new user name you would like to change to:")
		If $_ChangeUserName_NewUserName<>"" Then
			$_ChangeUserName_RegPath="HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\"&$_ChangeUserName_SID
			$_ChangeUserName_DirOLD=RegRead($_ChangeUserName_RegPath,"ProfileImagePath")
			$_ChangeUserName_DirNEW=@HomeDrive&"\Users\"&$_ChangeUserName_NewUserName
			$temp=MsgBox(4,"","This will also change the user folder for this account."&@CRLF&"From: "&$_ChangeUserName_DirOLD&@CRLF&" To: "&$_ChangeUserName_DirNEW)

			If $temp=6 Then
				_log("Changing User Name...")
				$i=Run('"' & @ComSpec & '" /k ' &"wmic useraccount where name='"&@UserName&"' rename '"&$_ChangeUserName_NewUserName&"'",@WindowsDir,@SW_HIDE,2)
				ProcessWaitClose($i)
				_log("CMD: "&StdoutRead($i))
				_log("Reg change: "&$_ChangeUserName_RegPath)
				$temp=RegWrite($_ChangeUserName_RegPath,"ProfileImagePath","REG_EXPAND_SZ",@HomeDrive&"\Users\"&$_ChangeUserName_NewUserName)
				_log("RegWrite out Code: "&$temp)
				_log("Chaging Dir name...")
				$i=Run('"' & @ComSpec & '" /k ' &"ren "&$_ChangeUserName_DirOLD&" "&$_ChangeUserName_DirNEW,@WindowsDir,@SW_HIDE,2)
				ProcessWaitClose($i)
				_log("CMD: "&StdoutRead($i))
			EndIf

		EndIf
	EndIf
	#ce


EndFunc

Func _SidGet()

	_log("_SidGet called")
	$i=Run('"' & @ComSpec & '" /k ' &"wmic useraccount where name='"&@UserName&"' get sid",@WindowsDir,@SW_HIDE,2)
	ProcessWaitClose($i)
	$Read=StdoutRead($i)
	$Read=StringSplit($Read,"D")
	$Read=StringSplit($Read[2],StringTrimRight(@HomeDrive,1))
	$sid=StringStripWS($Read[1],7)
	_log("SID: "&$sid)
	Return $sid

EndFunc

Func _FastBootOnOff() ;Turns windows fast boot on or off  by looking at reg values

	_log("_FastBootOnOff called")
	$regHibernateEnabledRead=RegRead($regHibernateEnabled[0],$regHibernateEnabled[1])
	If $regHibernateEnabledRead=1 Then
		$temp=MsgBox(4,"Fast Boot","Fast Boot is ON, do you want to run the CMD OFF command? (This does not work on some computers)")
		If $temp=6 Then
			Run('"' & @ComSpec & '" /k ' &"powercfg -h off",@WindowsDir,@SW_SHOW)
			_log("Turned Fast Boot Off")
		EndIf
	ElseIf $regHibernateEnabledRead=0 Then
		$temp=MsgBox(4,"Fast Boot","Fast Boot is OFF, do you want to run the CMD ON command? (This does not work on some computers)")
		If $temp=6 Then
			Run('"' & @ComSpec & '" /k ' &"powercfg -h on",@WindowsDir,@SW_SHOW)
			_log("Turned Fast Boot On")
		EndIf
	Else
		MsgBox(48,"WARNING","Could not read power options value!")
		_log("WARNING: Could not read reg value for fast boot.")
	EndIf
	Sleep(500)
	_StatusHibernateEnabled()

EndFunc

Func _Reboot()

	_log("_Reboot called")
	$temp=MsgBox(4,"Reboot?","Reboot computer?")
	#cs -- auto restart not working
	If $temp=6 Then
		$temp=FileCreateShortcut(@ScriptFullPath,$FileStartUpLink)
		If $temp=0 Then
			MsgBox(48,"Warning","Could not create startup link, please start Build Tools manualy on startup.")
			_log("WARNING: Could not creat startup link: "&$FileStartUpLink)
		Else
			FileWrite($FileStartUp,"True")
	EndIf
	#ce
	If $temp=6 Then
		;Shutdown(6);The shutdown in now done in the _exit() function
		_exit("Reboot")
	EndIf

EndFunc

Func _ChangeComputerName()

	_log("_ChangeComputerName called")
	$ChangeComputerNameNewName=GUICtrlRead($InputChangeComputerName)
	$temp=MsgBox(4,"Change Computer Name","Are you sure you want to change the computer name"&@CRLF&"From:"&@CRLF&@ComputerName&@CRLF&"To:"&@CRLF&$ChangeComputerNameNewName)
	If $temp=6 Then
		Run('"' & @ComSpec & '" /k ' &"WMIC computersystem where caption='"&@ComputerName&"' rename '"&$ChangeComputerNameNewName&"'",@WindowsDir,@SW_SHOW)
	EndIf
	GUICtrlSetBkColor($ButtonChangeComputerName,$colorGreen)

EndFunc

Func _SetupAnyDesk()

	_log("_SetupAnyDesk called")
	$temp=FileCopy($FileAnyDesk,@DesktopCommonDir&"\AnyDesk - HELP.exe",1)
	If $temp=0 Then
		MsgBox(16,"Error","The AnyDesk.exe file could not be copied!")
		_log("ERROR: Could not copy anydesk.exe to "&@DesktopCommonDir)
		GUICtrlSetBkColor($ButtonSetupAnyDesk,$colorRed)
	Else
		GUICtrlSetBkColor($ButtonSetupAnyDesk,$colorGreen)
	EndIf

EndFunc

Func _CopyFromCombo()

	_log("_CopyFromCombo called")
	$_CopyFromCombo_DirFromFolder=$DirFromFolder&GUICtrlRead($ComboCopyFrom)
	$_CopyFromCombo_DirToFolder=$DirToFolder&GUICtrlRead($ComboCopyFrom)

	If FileExists($_CopyFromCombo_DirFromFolder) Then
		$temp=MsgBox(4,'Copy','Copy all (Excuding: system and temp files)"'&@CRLF&"From: "&$_CopyFromCombo_DirFromFolder&@CRLF&'To: '&$_CopyFromCombo_DirToFolder)
		If $temp=6 Then
			_log("Copying From: "&$_CopyFromCombo_DirFromFolder&"To: "&$_CopyFromCombo_DirToFolder)
			Run('"' & @ComSpec & '" /k ' &'robocopy "'&$_CopyFromCombo_DirFromFolder&'" "'&$_CopyFromCombo_DirToFolder&'" /E /Z /ZB /R:2 /W:1 /V /xjd /XA:ST',@WindowsDir,@SW_SHOW)
		EndIf
	Else
		MsgBox(16,"Error","This dir does not exist"&@CRLF&"From: "&$_CopyFromCombo_DirFromFolder)
	EndIf

EndFunc

Func _CopyAllButAppdata()

	_log("_CopyAllButAppdata called")
	If FileExists($DirFromFolder) And FileExists($DirToFolder) Then
		$temp=MsgBox(4,'Copy','Copy all folder exept folder called "appdata" and will skip any system and temp files.'&@CRLF&"From: "&$DirFromFolder&@CRLF&'To: '&$DirToFolder)
		If $temp=6 Then
			_log("Copying without appdata From: "&$DirFromFolder&" To: "&$DirToFolder)
			Run('"' & @ComSpec & '" /k ' &'robocopy "'&$DirFromFolder&'" "'&$DirToFolder&'" /E /Z /ZB /R:2 /W:1 /V /XA:ST /xjd /XD "'&$DirFromFolder&'\Appdata"',@WindowsDir,@SW_SHOW)
		EndIf
	Else
		MsgBox(16,"Error","one or more of these dirs does not exist"&@CRLF&"From: "&$DirFromFolder&@CRLF&'To: '&$DirToFolder)
	EndIf
EndFunc

Func _copyChromeData() ;------------------------------------------------------------------------------ Copy Google Chrome User Data

	_log("_CopyChromeData Called")
	$DirFromChromeData=$DirFromFolder&"\AppData\Local\Google\Chrome\User Data\Default"
	$DirToChromeData=$DirToFolder&"\AppData\Local\Google\Chrome\User Data\Default"

	If FileExists($DirFromChromeData) Then
		$temp=MsgBox(4,'Copy','Copy Chrome Data?'&@CRLF&"From: "&$DirFromChromeData&@CRLF&'To: '&$DirToChromeData)
		If $temp=6 Then
			_log("Copying Chrome Data From: "&$DirFromChromeData&"To: "&$DirToChromeData)
			Run('"' & @ComSpec & '" /k ' &'robocopy "'&$DirFromChromeData&'" "'&$DirToChromeData&'" /E /Z /ZB /R:2 /W:1 /V',@WindowsDir,@SW_SHOW)
		EndIf
	Else
		MsgBox(16,"Error","Error, no Chrome Data found. (please specify the user dir)"&@CRLF&"From: "&$DirFromFolder&@CRLF&'To: '&$DirToFolder)
	EndIf

EndFunc

Func _HelpGUI() ;------------------------------------------------------------------------------ Help GUI (Not in use)
	_log("_Help Called")
	$HelpGUI=GUICreate("HELP",300,300)
EndFunc

Func _Server() ;------------------------------------------------------------------------------ Server TCP

	_log("_Server called")
	If $ClientActive=1 Then
		MsgBox(16,"Server","You cant be a server when you are a client!")
		Return
	EndIf

	If $ServerActive=0 Then ;start the server for the first time
		If MsgBox(4,"Server","Are you sure you want to start the server?"&@CRLF&"(Please close the program to terminate the server).")<>6 Then Return

		_log("Server: Starting...")
		$ServerIP=GUICtrlRead($InputServerIP)
		$ServerPort=GUICtrlRead($InputServerPort)
		TCPStartup()
		$SocketListen=TCPListen($ServerIP,$ServerPort,5)
		If @error Then
			_log("Error("&@error&"): Starting TCP Server, PORT: "&$ServerPort&" IP: "&$ServerIP)
			GUICtrlSetColor($ButtonServerOnOFF,$colorRed)
			GUICtrlSetBkColor($ButtonServerOnOFF,14408667)
			TCPShutdown()
			Return
		EndIf


		$ServerActive=1
		GUICtrlSetBkColor($ButtonServerOnOFF,$colorGreen)
		GUICtrlSetColor($ButtonServerOnOFF,$colorBlack)
		_log("Server: Done")

	EndIf

	$Socket=TCPAccept($SocketListen)
	If $Socket<>-1 Then
		_log("Server: Sending Data")
		TCPSend($Socket,GUICtrlRead($InputCopy))
		TCPCloseSocket($Socket)
	EndIf

EndFunc

Func _Client() ;------------------------------------------------------------------------------ Client TCP

	_log("_Client called")
	If $ServerActive=1 Then
		MsgBox(16,"Client","You cant be a Client when you are a Server!")
		Return
	EndIf
	$ServerIP=GUICtrlRead($InputServerIP)
	$ServerPort=GUICtrlRead($InputServerPort)

	TCPStartup()

	$iSocket=TCPConnect($ServerIP,$ServerPort)
	If @error Then
		_log("ERROR("&@error&"): TCP Server not found.")
		GUICtrlSetColor($ButtonClientOnOFF,$colorOrange)
		Return
	EndIf

	$recive=TCPRecv($iSocket,500)
	GUICtrlSetData($InputCopy,$recive)
	GUICtrlSetBkColor($ButtonClientOnOFF,$colorGreen)
	GUICtrlSetColor($ButtonClientOnOFF,$colorBlack)

EndFunc

Func _install() ;------------------------------------------------------------------------------ Install Software

	_log("_install() called")
	If $SoftwareError=0 Then
		For $i=1 To $SoftwareSearch[0] step 1
			If GUICtrlRead($CheckSoftware[$i])=1 Then
				GUICtrlSetState($CheckSoftware[$i],4)
				ShellExecute($DirInstallers&"\"&$SoftwareSearch[$i])
			EndIf
		Next

	Else
		MsgBox(48,'Warning','Warning! There is no software to install!')
	EndIf

EndFunc

Func _ChromeMakeDefault() ;------------------------------------------------------------------------------ Google Chrome Deafult

	_log("_ChromeMakeDefault() called")
	If RegRead($regBrowser1[0],$regBrowser1[1])="ChromeHTML" Then
		_StatusGoogleChromeDefault()
		_log("Button: Chrome called and default already set")
	Else
		ShellExecuteWait($FileDefaultBrowserEXE,"Chrome")
		_StatusGoogleChromeDefault()
	EndIf
EndFunc

Func _TaskbarIconsToDefault()
	RegWrite($regSearch[0],$regSearch[1],$regSearch[2],1) ;make search small
		_log("REG: Search set 1")
	RegWrite($regTask[0],$regTask[1],$regTask[2],0) ;disable Task
		_log("REG: Task set 0")
	RegWrite($regCortana[0],$regCortana[1],$regCortana[2],0) ;disable Cortana
		_log("REG: Cortana set 0")

	GUICtrlSetBkColor($ButtonExplorerRestart,0xF89123)
EndFunc

Func _log($_logMSG) ;------------------------------------------------------------------------------ Log
	_FileWriteLog($fileLog,$_logMSG,1)
EndFunc

Func _exit($_exitCode) ;------------------------------------------------------------------------------ EXIT

	$_exitCode=String($_exitCode)
	_log("_exit() called (code: "&$_exitCode&")")
	TCPShutdown()

	If $_exitCode="Reboot" Then
		_log("Rebooting computer (called on exit)")
		Shutdown(6)
	EndIf

	_log("---stopping---")
	Exit

EndFunc
#EndRegion ==================================================================================================================== FUNCTIONS




MsgBox(16,"ERROR","END OF SCRIPT, you have fallen of the edge")


