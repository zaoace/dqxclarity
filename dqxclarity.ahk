#SingleInstance, Off
#Include <classMemory>
#Include <convertHex>
#Include <memWrite>
#Include <JSON>

SetBatchLines, -1

Process, Exist, DQXGame.exe
if !ErrorLevel
{
  MsgBox Dragon Quest X must be running for dqxclarity to work.
  ExitApp
}

;; Open Progress UI
Gui, 1:Default
Gui, Font, s12
Gui, +AlwaysOnTop +E0x08000000
Gui, Add, Edit, vNotes w500 r10 +ReadOnly -WantCtrlA -WantReturn,
Gui, Show, Autosize

;; Start timer
startTime := A_TickCount

;; Loop through all files in json directory
Loop, Files, json\*.json, F
{
  Run, %A_ScriptDir%\run_json.exe %A_LoopFileFullPath%
}

while (numberOfRunningProcesses != 0)
{
  numberOfRunningProcesses = 0
  for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
  {
    if process.Name = "AutoHotkey.exe"
      numberOfRunningProcesses++
  }
  GuiControl,, Notes, Number of files left to translate: %numberOfRunningProcesses%
  sleep 500
}

elapsedTime := A_TickCount - startTime
GuiControl,, Notes, Done.`n`nElapsed time: %elapsedTime%ms
Sleep 3000

ExitApp
