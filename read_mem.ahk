#SingleInstance force
#Include <classMemory>
#Include <convertHex>
#Include <memWrite>
#Include <JSON>

if (_ClassMemory.__Class != "_ClassMemory") {
  msgbox class memory not correctly installed. Or the (global class) variable "_ClassMemory" has been overwritten
}

dqx := new _ClassMemory("ahk_exe DQXGame.exe", "", hProcessCopy)
Global dqx

if !isObject(dqx)
{
    msgbox failed to open a handle
  if (hProcessCopy = 0)
    msgbox The program isn't running (not found) or you passed an incorrect program identifier parameter. 
  else if (hProcessCopy = "")
    msgbox OpenProcess failed. If the target process has admin rights, then the script also needs to be ran as admin. Consult A_LastError for more information.
}

; ;; String : Address + offsets for any text that appears on the bottom of the screen
; ;; Example: dqx.readString(baseAddress + dialogAddress, sizeBytes := 0, encoding := "utf-16", offsets*)
; dialogAddress := 0x01E5A458
; dialogOffsets := [0x8, 0x8, 0x30, 0x18, 0x4C, 0x4, 0x39C]

; ;; UChar : Boolean (0 or 1) value that checks if dialog box is open or not
; ;; Example: dqx.read(baseAddress + 0x1E62FC8, "UChar")
; isDialogOpenAddress := 0x1E62FC8

; ;; UChar : Boolean (0 or 1) value that checks if non-dialog white text is at bottom of screen
; ;; Example: dqx.read(baseAddress + 0x1E62FC8, "UChar")
; isNonDialogBottomTextActiveAddress := 0x01E5A440
; isNonDialogBottomTextActiveOffsets := [0x8, 0x70, 0x8, 0x48, 0x40, 0x8, 0xF4]

Gui, +AlwaysOnTop +E0x08000000
Gui, Font, s12
Gui, Add, Edit, vNotes w500 r10 +ReadOnly -WantCtrlA -WantReturn,
Gui, Show, Autosize

;; Mark FileRead operations as UTF-8
FileEncoding UTF-8

;; Start timer
startTime := A_TickCount

;; Loop through all files in json directory
Loop, Files, json\*.json, F
{
  FileRead, jsonData, %A_ScriptDir%\%A_LoopFileFullPath%
  data := JSON.Load(jsonData)
  loop, % data.Count()
  {
    obj := DATA[A_Index]

    ;; Convert utf-8 strings to hex
    jp := 00 . convertStrToHex(obj.jp_string) . 00
    jp := RegExReplace(jp, "\r\n", "")
    jp_raw := obj.jp_string
    jp_len := StrLen(jp)

    ;; For other languages, we want to make the length of our JP hex
    ;; string the same as what we're inputting.
    en := 00 . convertStrToHex(obj.en_string) . 00
    en := RegExReplace(en, "\r\n", "")
    en_raw := obj.en_string
    en_len := StrLen(en)

    ;; Whether or not we should prepend/append null terminators
    ignore_first_term := obj.ignore_first_term
    ignore_last_term := obj.ignore_last_term

    ;; If loop is specified in json, use it. Otherwise, default to 1
    loop_count := obj.loop_count
    if (loop_count == "")
      loop_count = 1

    GuiControl,, Notes, Reading %A_ScriptDir%\%A_LoopFileFullPath%`n`nOn this text:`n`nJP: %jp_raw%`nEN:%en_raw%

    ;; If the string length doesn't match, we add blank text until it does.
    ;; We still want room to add 00 at the end of our string.
    if (jp_len != en_len)
    {
      ;; Remove the 00 we added earlier as we aren't ready
      ;; to terminate the string yet. 
      en := SubStr(en, 1, (en_len - 2))
      Loop
      {
        en .= 02
        new_len := StrLen(en)
      }
      Until ((jp_len - new_len) == 2)

      en .= 00

      jp_len := StrLen(en)
      en_len := StrLen(jp)

      if (ignore_first_term != "")
      {
        jp := SubStr(jp, 3, jp_len)
        en := SubStr(en, 3, en_len)
      }

      if (ignore_last_term != "")
      {
        jp := SubStr(jp, 1, (jp_len - 2))
        en := SubStr(en, 1, (en_len - 2))
      }
    }

    memWrite(jp, en, loop_count)
  }

  elapsedTime := A_TickCount - startTime
  FileAppend, Last run time: %elapsedTime%ms`n, times.txt
  GuiControl,, Notes, Done.`n`nElapsed time: %elapsedTime%ms
}

Return
