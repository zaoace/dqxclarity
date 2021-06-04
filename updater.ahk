#Persistent
#NoEnv
#SingleInstance force

/*
*************************************************
Used to update dqxclarity to the latest version
*************************************************
*/

;=== Display GUI to user showing the update is happening =======================
Gui, -SysMenu +AlwaysOnTop +E0x08000000
Gui, Font, s12
Gui, Add, Edit, vNotes w500 r10 +ReadOnly -WantCtrlA -WantReturn, Updating..
Gui, Add, Button, w60 +x225 Default +Disabled, OK
Gui, Show, Autosize
;===============================================================================

;; Make sure /tmp is clean by deleting + re-creating, then move updater into /tmp.
FileRemoveDir, %A_ScriptDir%\tmp
sleep 100
FileCreateDir, %A_ScriptDir%\tmp
sleep 100
FileMove, %A_ScriptDir%\updater.exe, %A_ScriptDir%\tmp\updater.exe

;; Download latest version
url := "https://github.com/jmctune/dqxclarity/releases/latest/download/dqxclarity.zip"
downloadFile(url)

;; Unzip files that were downloaded into same directory, overwriting anything
unzipName := A_ScriptDir "\dqxclarity.zip"
unzipLoc := A_ScriptDir
Unz(unzipName, unzipLoc)

;; Wrap up
GuiControl,, Notes, Update finished.
FileDelete, %A_ScriptDir%\dqxclarity.zip  ;; Delete the old file
GuiControl, Enable, OK
Return

ButtonOK:
  Run dqxclarity.exe
  ExitApp

;=== Functions ==========================================================
downloadFile(url, dir := "", fileName := "dqxclarity.zip") 
{
  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  whr.Open("GET", url, true)
  whr.Send()
  whr.WaitForResponse()

  body := whr.ResponseBody
  data := NumGet(ComObjValue(body) + 8 + A_PtrSize, "UInt")
  size := body.MaxIndex() + 1

  if !InStr(FileExist(dir), "D")
    FileCreateDir % dir

  SplitPath url, urlFileName
  f := FileOpen(dir (fileName ? fileName : urlFileName), "w")
  f.RawWrite(data + 0, size)
  f.Close()
}

Unz(sZip, sUnz)
{
  FileCreateDir, %sUnz%
    psh  := ComObjCreate("Shell.Application")
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
}
