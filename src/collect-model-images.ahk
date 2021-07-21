SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
#Include common.ahk

progressFile := "..\curr.txt"
hzdScreens := % A_MyDocuments . "\Horizon Zero Dawn\Screenshots"
hzdPath := "E:\Games\SteamLibrary\steamapps\common\Horizon Zero Dawn\HorizonZeroDawn.exe"
aaPath := "E:\Projects\AloysAdjustments\src\AloysAdjustments\bin\Debug\AloysAdjustments.exe"
aaOutput := "E:\Projects\AloysAdjustments\src\AloysAdjustments\bin\Debug\output.txt"

totalOutfits := 138

SplitPath, hzdPath ,, hzdDir
SplitPath, aaPath ,, aaDir

WriteProgress(i) {
	global progressFile
	file := FileOpen(progressFile,"w")
	file.write(i)
	file.close()
}

ReadProgress() {
	global progressFile
	FileRead, p, %progressFile%
	return p
}

ReadModelName() {
	global aaOutput
	FileRead, outRaw, %aaOutput%
	StringSplit, split, outRaw, =
	return %split2%
}

;Delete existing screens
FileDelete, %hzdScreens%\*

;resume progress
progress := ReadProgress()
if (progress = "") {
	progress := 0
} else {
	progress++
}

i := progress
Loop, % totalOutfits - progress {
	;apply patch
	RunWait, %aaPath% --patch --cmd "Misc" i "Outfits" s%i%, %aaDir%

	Sleep, 500

	;take screen
	RunWait, run-hzd.ahk "%hzdPath%" "%hzdDir%"

	;copy screen
	Loop, %hzdScreens%\* {
		FileCreateDir, ..\db
		FileMove, %A_LoopFilePath%, % "..\db\" . ReadModelName() . ".png", 1
	}

	FileDelete, %hzdScreens%\*

	WriteProgress(i)
	i++
	
	Sleep, 2000
}