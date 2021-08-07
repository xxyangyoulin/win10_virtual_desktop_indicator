#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

FileInstall, indicator01.ico, %A_ScriptDir%\indicator01.ico
FileInstall, indicator02.ico, %A_ScriptDir%\indicator02.ico
FileInstall, indicator03.ico, %A_ScriptDir%\indicator03.ico
FileInstall, indicator04.ico, %A_ScriptDir%\indicator04.ico
FileInstall, indicator05.ico, %A_ScriptDir%\indicator05.ico
FileInstall, indicator06.ico, %A_ScriptDir%\indicator06.ico
FileInstall, indicator07.ico, %A_ScriptDir%\indicator07.ico
FileInstall, indicator08.ico, %A_ScriptDir%\indicator08.ico
FileInstall, indicator09.ico, %A_ScriptDir%\indicator09.ico
FileInstall, indicator00.ico, %A_ScriptDir%\indicator00.ico

DesktopCount = 2 ; Windows starts with 2 desktops at boot
CurrentDesktop = 1 ; Desktop count is 1-indexed (Microsoft numbers them this way)

updateVirtualDesktopIndicator()
SetTimer, updateVirtualDesktopIndicator, 300

Loop, {
    Input, Key, L1 V , {Left}{Right}
    if ( InStr(ErrorLevel,"EndKey:") ) { 
        Sleep, 50
        updateVirtualDesktopIndicator()
    }
}

updateVirtualDesktopIndicator(){ ; update taskbar tray icons
    global CurrentDesktop, DesktopCount
    mapDesktopsFromRegistry()
    if (CurrentDesktop < 10){
        Menu, Tray, Icon,indicator0%CurrentDesktop%.ico,1
    }else{
        Menu, Tray, Icon,indicator00.ico,1
    }
    Return
}

mapDesktopsFromRegistry() {
    global CurrentDesktop, DesktopCount
    ; Get the current desktop UUID. Length should be 32 always, but there's no guarantee this couldn't change in a later Windows release so we check.
    IdLength := 32
    SessionId := getSessionId()
    if (SessionId) {
        RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
        if (CurrentDesktopId) {
            IdLength := StrLen(CurrentDesktopId)
        }
    }
    ; Get a list of the UUIDs for all virtual desktops on the system
    RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
    if (DesktopList) {
        DesktopListLength := StrLen(DesktopList)
        ; Figure out how many virtual desktops there are
        DesktopCount := DesktopListLength / IdLength
    }
    else {
        DesktopCount := 1
    }
    ; Parse the REG_DATA string that stores the array of UUID's for virtual desktops in the registry.
    i := 0
    while (CurrentDesktopId and i < DesktopCount) {
        StartPos := (i * IdLength) + 1
        DesktopIter := SubStr(DesktopList, StartPos, IdLength)
        OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
        ; Break out if we find a match in the list. If we didn't find anything, keep the
        ; old guess and pray we're still correct :-D.
        if (DesktopIter = CurrentDesktopId) {
            CurrentDesktop := i + 1
            OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
            break
        }
        i++
    }
}

;
; This functions finds out ID of current session.
;
getSessionId()
{
    ProcessId := DllCall("GetCurrentProcessId", "UInt")
    if ErrorLevel {
        OutputDebug, Error getting current process id: %ErrorLevel%
        return
    }
    OutputDebug, Current Process Id: %ProcessId%
    DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
    if ErrorLevel {
        OutputDebug, Error getting session id: %ErrorLevel%
        return
    }
    OutputDebug, Current Session Id: %SessionId%
return SessionId
}