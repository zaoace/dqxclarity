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

;; Delete tmp dir from updater if exists
FileRemoveDir, %A_ScriptDir%\tmp

;; Create GUI
Gui, 1:Default
Gui, Add, Tab3,, General|Update|About
Gui, Font, s10, Segoe UI
Gui, Add, Text,, Number of files to process at once`n(Higher number uses more CPU)
Gui, Add, Edit
Gui, Add, UpDown, vParallelProcessing Range10-50, 15
Gui, Add, Button, gRun, Run

;; Update tab
Gui, Tab, Update
Gui, Add, Button, gUpdateApp, Update Clarity
Gui, Add, Button, gUpdateJSON, Get latest JSON

;; About tab
Gui, Tab, About
Gui, Add, Link,, Join the unofficial Dragon Quest X <a href="https://discord.gg/UFaUHBxKMY">Discord</a>!
Gui, Add, Link,, <a href="https://github.com/jmctune/dqxclarity">Get the Source</a>
Gui, Add, Link,, Like what I'm doing? <a href="https://www.paypal.com/paypalme/supportjmct">Donate :P</a>
Gui, Add, Text,, Catch me on Discord: mebo#1337
Gui, Add, Link,, Core app made by Serany <3 `n`nTranslations done by several members`nof the DQX community.`n<a href="https://github.com/jmctune/dqxclarity/graphs/contributors">Check them out!</a> 

Gui, Show, Autosize
Return

UpdateApp:
  Run, %A_ScriptDir%\updater.exe
  ExitApp
  Return

UpdateJSON:
  Run, %A_ScriptDir%\json_latest.exe
  ExitApp
  Return

Run:
  Gui, Submit, Hide

;; Open Progress UI
Gui, 2:Default
Gui, Font, s12
Gui, +AlwaysOnTop +E0x08000000
Gui, Add, Edit, vNotes w500 r10 +ReadOnly -WantCtrlA -WantReturn,
Gui, Show, Autosize

;; Start timer
startTime := A_TickCount

;; Get number of files we're going to process
numberOfFiles := 0
Loop, json\*.json
  numberOfFiles++

;; Loop through all files in json directory
numberOfRunningProcesses := 0
Loop, Files, json\*.json, F
{
  Loop
  {
    numberOfRunningProcesses := 0
    for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
    {
      if process.Name = "run_json.exe"
        numberOfRunningProcesses++
    }
  }
  Until (numberOfRunningProcesses < ParallelProcessing)   ;; Limit throughput processing based on user input.

  Run, %A_ScriptDir%\run_json.exe %A_LoopFileFullPath%
  numberOfFiles := (numberOfFiles - 1)
  GuiControl,, Notes, Queued files waiting to process: %numberOfFiles%
}

;; Let user know how many files are left to process
while (numberOfRunningProcesses != 0)
{
  numberOfRunningProcesses = 0
  for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process")
  {
    if process.Name = "run_json.exe"
      numberOfRunningProcesses++
  }
  GuiControl,, Notes, Number of files left to translate: %numberOfRunningProcesses%
  sleep 500
}

elapsedTime := A_TickCount - startTime
GuiControl,, Notes, Done.`n`nElapsed time: %elapsedTime%ms
Sleep 750

ExitApp

GuiEscape:
GuiClose:
  ExitApp
