
; CrewChief-Changer 
; Monitors started games and (re)launches Crew Cheif with specific game.
;
; *Important*: You should check 'Run immediatly' from within Crew Cheif 'Properties' dialog.

;@Ahk2Exe-SetMainIcon CrewChiefV4-Changer.ico

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
ListLines, Off
SetBatchLines, 100ms
#KeyHistory 0
#SingleInstance force

; Hide unneded menu options
Menu, Tray, NoStandard 
Menu, Tray, Add, Exit, ByeScript 

If (A_Args.Length() > 0) {
    If (A_Args.Length() > 1 && A_Args[1] = "--crewchief-path") 
        CrewChiefPath := A_Args[2]
    Else {
         MsgBox, 16,,Invalid command line arguments.`n`nSupported:`n --crewchief-path "PATH_TO_CREWCHIEF_EXECUTABLE"'
         GoTo, ByeScript
    }
} Else {
    CrewChiefPath := "C:\Program Files (x86)\Britton IT Ltd\CrewChiefV4\CrewChiefV4.exe"
}
If !FileExist(CrewChiefPath) {
     MsgBox, 16,,Unable to locate CrewCheif executable '%CrewChiefPath%'. 
     Goto, ByeScript
}

; See https://mr_belowski.gitlab.io/CrewChiefV4/GameSpecific_CommandLineSwitches.html
Games := [ { exe: "rFactor2.exe", pid: 0, cc: "RF2" }
, { exe: "rFactor.exe", pid: 0, cc: "RF1" } 
, { exe: "acs.exe", pid: 0, cc: "ASSETTO_64BIT" }
, { exe: "AC2-Win64-Shipping.exe", pid: 0, cc: "ACC" }
, { exe: "RRRE64.exe", pid: 0, cc: "RACE_ROOM" }
, { exe: "AMS.exe", pid: 0, cc: "AMS" } ]


sleep_time := 2000
Loop {
    For i, value in Games {
        ;MsgBox % i ": exe=" value.exe " pid=" value.pid " cc=" value.cc
        If Check(value) {
            sleep_time := 25000
            Break
        } Else {
            sleep_time := 2000
        }
    }
    DllCall("Sleep",UInt,sleep_time)
}

Check(ByRef Game) {
    global CrewChiefPath
    Process, Exist, % Game.exe
    Pid := ErrorLevel
    If (Pid) {
        If (!Game.Pid) {
            ;MsgBox, % "Game '" . Game.exe . "' just started"
            Game.pid := Pid
            Run, % CrewChiefPath . " -C_EXIT"
            Process, WaitClose, CrewChiefV4.exe
            Run, % CrewChiefPath . " -game " . Game.cc
        }
        Return True
    } Else {
        ; not started / or recently closed
        Game.pid := 0
        Return False
    }
}

ByeScript: 
  ExitApp 
