; ─────────────────────────────────────────────────────────────
; BrawlMacro Watchdog Externo
; ─────────────────────────────────────────────────────────────
; Vigila el macro principal (brawlmacrotct.ahk) leyendo el archivo
; brawlmacro_heartbeat.txt que el macro actualiza cada 5 segundos.
;
; Si el heartbeat lleva >90s sin actualizarse Y el PID sigue vivo
; (= proceso colgado de verdad), mata el proceso y arranca de nuevo.
;
; Si el heartbeat no existe → el macro está cerrado intencionadamente,
; no hace nada.
;
; USO: ejecútalo en paralelo con el macro. Puedes ponerlo en el
; arranque de Windows para que siempre vigile.
; ─────────────────────────────────────────────────────────────

#Requires AutoHotkey v2.0
#SingleInstance Force

global scriptDir    := A_ScriptDir
global heartbeatPath := scriptDir "\brawlmacro_heartbeat.txt"
global macroPath    := scriptDir "\brawlmacrotct.ahk"
global logPath      := scriptDir "\brawlmacro_watchdog.log"

global ultimoArranque := 0  ; timestamp del último restart automático (anti-loop)

; ── Tray ─────────────────────────────────────────────
try TraySetIcon("imageres.dll", -159)  ; engranaje
A_IconTip := "BrawlMacro Watchdog (vigilando)"

A_TrayMenu.Delete()
A_TrayMenu.Add("Reiniciar macro AHORA", (*) => ForzarReinicio())
A_TrayMenu.Add("Ver log", (*) => Run("notepad.exe " . '"' logPath '"'))
A_TrayMenu.Add()
A_TrayMenu.Add("Salir del watchdog", (*) => ExitApp())

Log("Watchdog iniciado. Vigilando " heartbeatPath)

; ── Loop principal ───────────────────────────────────
SetTimer(VerificarMacro, 15000)
VerificarMacro()  ; primera verificación inmediata
Persistent

; ─────────────────────────────────────────────────────

VerificarMacro() {
    global heartbeatPath, macroPath, ultimoArranque

    if (!FileExist(heartbeatPath)) {
        ; Macro no está corriendo (cerrado intencionadamente o nunca arrancado).
        ; No hacer nada — el watchdog solo actúa si había un macro vivo que se colgó.
        return
    }

    try {
        content := FileRead(heartbeatPath, "UTF-8")
    } catch {
        ; Archivo bloqueado mientras se escribía, ignorar este tick
        return
    }

    parts := StrSplit(content, "|")
    if (parts.Length < 2) {
        Log("Heartbeat malformado, ignorando este tick")
        return
    }

    macroPid := Integer(parts[2])

    ; Edad del archivo (segundos desde último mtime)
    try {
        mtime := FileGetTime(heartbeatPath, "M")
        edad := DateDiff(A_Now, mtime, "Seconds")
    } catch {
        Log("No se pudo leer mtime del heartbeat")
        return
    }

    ; Verifica si el proceso del macro sigue vivo
    procVivo := ProcessExist(macroPid)

    if (!procVivo) {
        ; El proceso ya está muerto pero el heartbeat existe (terminó abruptamente).
        Log("Proceso PID " macroPid " no existe — relanzando macro")
        Relanzar("proceso muerto")
        return
    }

    if (edad > 90) {
        ; Heartbeat con >90s sin actualizar Y proceso vivo = colgado de verdad
        Log("Heartbeat congelado (" edad "s) con PID " macroPid " vivo — matando y relanzando")
        try ProcessClose(macroPid)
        Sleep 1500
        Relanzar("congelamiento detectado (" edad "s sin heartbeat)")
        return
    }

    ; Todo bien, log mínimo cada cierto tiempo (opcional, descomenta si quieres ruido)
    ; Log("OK — heartbeat hace " edad "s, PID " macroPid)
}

Relanzar(razon) {
    global macroPath, ultimoArranque, heartbeatPath

    ; Anti-bucle: si acabamos de reiniciar hace <30s, no insistir
    if (ultimoArranque && (A_TickCount - ultimoArranque < 30000)) {
        Log("Anti-bucle: salté reinicio porque acabamos de relanzar")
        return
    }

    ; Borrar heartbeat viejo para que cuando arranque el nuevo proceso, el archivo sea fresco
    try FileDelete(heartbeatPath)

    if (!FileExist(macroPath)) {
        Log("ERROR: no encuentro el script " macroPath)
        return
    }

    try {
        Run('"' macroPath '"')
        ultimoArranque := A_TickCount
        Log("Macro relanzado. Razón: " razon)
    } catch as e {
        Log("ERROR al relanzar: " e.Message)
    }
}

ForzarReinicio() {
    global heartbeatPath, macroPath
    Log("Reinicio manual solicitado desde el menú")
    ; Leer el PID actual e intentar matarlo limpiamente
    if (FileExist(heartbeatPath)) {
        try {
            content := FileRead(heartbeatPath, "UTF-8")
            parts := StrSplit(content, "|")
            if (parts.Length >= 2) {
                pid := Integer(parts[2])
                if (ProcessExist(pid)) {
                    try ProcessClose(pid)
                    Sleep 1500
                }
            }
        }
    }
    Relanzar("reinicio manual desde tray")
}

Log(msg) {
    global logPath
    try {
        ts := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        FileAppend(ts " | " msg "`n", logPath, "UTF-8")
    }
}
