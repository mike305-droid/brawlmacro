#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode("Pixel", "Screen")
CoordMode("Mouse", "Screen")

; Blindaje anti-crash global: cualquier error sin capturar (p. ej. en un timer
; de un solo disparo lanzado durante un cambio de tema) por defecto muestra un
; diálogo y CIERRA el script entero. Lo registramos en un log y devolvemos true
; para que el macro siga vivo en vez de cerrarse/reiniciarse de golpe.
OnError(ManejarErrorGlobal)
ManejarErrorGlobal(err, mode) {
    static ultimoMsg := "", ultimoMsgT := 0, ultimaEscrituraT := 0, suprimidos := 0
    ; ANTES: se escribía a disco en CADA error. Si un error ocurría dentro de un
    ; timer rápido (cada 16 ms) eso eran ~60 FileAppend por segundo → el disco se
    ; saturaba y el macro se sentía trabado/"mal optimizado" e incluso el watchdog
    ; lo reiniciaba por falta de heartbeat. Ahora se limita el ritmo de escritura:
    ahora := A_TickCount
    msg := err.Message " @ " err.File ":" err.Line
    ; 1) Mismo error repetido en <10 s → suprimir (caso típico: timer que falla
    ;    cada frame; en el log se veían 342 líneas idénticas seguidas).
    if (msg = ultimoMsg && (ahora - ultimoMsgT) < 10000) {
        suprimidos += 1
        ultimoMsgT := ahora
        return true
    }
    ; 2) Tope global: como mucho 1 escritura por segundo aunque sean errores
    ;    distintos alternándose, para no thrashear el disco en una tormenta.
    if (ahora - ultimaEscrituraT < 1000) {
        suprimidos += 1
        return true
    }
    extra := suprimidos > 0 ? "  [+" suprimidos " suprimidos]" : ""
    suprimidos := 0
    ultimoMsg := msg
    ultimoMsgT := ahora
    ultimaEscrituraT := ahora
    try FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") " ERROR: " err.Message
        " @ " err.File ":" err.Line " (" err.What ") Extra=" err.Extra extra "`n",
        A_ScriptDir "\brawlmacro_errores.log")
    return true
}

; Windows redondea SetTimer hacia arriba al múltiplo de su resolución de reloj
; (15.6ms por defecto) — por eso los presets de fps altos (Ultra pide 16ms =
; 60fps) nunca pasaban de ~32fps reales. Bajar la resolución a 1ms deja que
; SetTimer se acerque de verdad a los intervalos cortos que pide cada preset.
DllCall("winmm\timeBeginPeriod", "UInt", 1)
OnExit((*) => DllCall("winmm\timeEndPeriod", "UInt", 1))

; ===== CONFIGURACION =====
configPath := A_ScriptDir "\brawlmacro_config.ini"
global eggsBackupPath := A_ScriptDir "\brawlmacro_eggs.txt"
global heartbeatPath := A_ScriptDir "\brawlmacro_heartbeat.txt"
global historialLogPath := A_ScriptDir "\brawlmacro_historial.log"
global VERSION_ACTUAL := "31.5.24"

; ===== TEMAS =====
temas := [
    ; ─────────── CLAROS (ordenados por color de boton) ───────────
    { nombre:"Monocromo",  fondo:"F0F0F0", texto:"1A1A1A", barra:"808080", textoBarra:"FFFFFF", historial:"F5F5F5", panel:"E0E0E0", cooldown:"404040", afk:"606060", boton:"808080", hover:"A0A0A0", logo:"1A1A1A", luzOn:"606060", luzAccion:"808080", luzOff:"1A1A1A",  btnTexto:"FFFFFF", histColor1:"1A1A1A", histColor2:"606060", histColor3:"808080" },
    { nombre:"Atardecer",  fondo:"FFE5D4", texto:"6B2F4A", barra:"E0735C", textoBarra:"FFF5EE", historial:"FFF2E8", panel:"F8C9A3", cooldown:"B91744", afk:"D4326B", boton:"E0735C", hover:"F08A6F", logo:"6B2F4A", luzOn:"A03A6E", luzAccion:"D4326B", luzOff:"6B2F4A",  btnTexto:"FFF5EE", histColor1:"6B2F4A", histColor2:"D4326B", histColor3:"F08A6F" },
    { nombre:"Melocotón",  fondo:"FFF5EC", texto:"7A2E2E", barra:"FFAB91", textoBarra:"FFFFFF", historial:"FFFAF3", panel:"FFD7BD", cooldown:"E63946", afk:"D86E3C", boton:"FFAB91", hover:"FFBFA8", logo:"7A2E2E", luzOn:"D86E3C", luzAccion:"FFAB91", luzOff:"7A2E2E",  btnTexto:"FFFFFF", histColor1:"7A2E2E", histColor2:"D86E3C", histColor3:"FFAB91" },
    { nombre:"Desierto",   fondo:"F5E6CB", texto:"4A2E0E", barra:"D2691E", textoBarra:"FFF8E1", historial:"F9F0DC", panel:"EDD5A8", cooldown:"B22222", afk:"8B4513", boton:"D2691E", hover:"E07E2A", logo:"6B3410", luzOn:"A0522D", luzAccion:"CD853F", luzOff:"6B3410",  btnTexto:"FFF8E1", histColor1:"4A2E0E", histColor2:"A0522D", histColor3:"CD853F" },
    { nombre:"Tropical",   fondo:"E0F7FA", texto:"006064", barra:"FF6F00", textoBarra:"FFFFFF", historial:"E8FAFC", panel:"B2EBF2", cooldown:"D81B60", afk:"00897B", boton:"FF6F00", hover:"FF9100", logo:"006064", luzOn:"00ACC1", luzAccion:"FF6F00", luzOff:"006064",  btnTexto:"FFFFFF", histColor1:"006064", histColor2:"FF6F00", histColor3:"00ACC1" },
    { nombre:"Naranja",    fondo:"FFE7CC", texto:"7A3B00", barra:"F28C28", textoBarra:"FFFFFF", historial:"FFF2E6", panel:"FFD9AD", cooldown:"CC3333", afk:"1D5BD7", boton:"F28C28", hover:"FFAA4D", logo:"4A2100", luzOn:"7A3600", luzAccion:"994700", luzOff:"4A2100",  btnTexto:"FFFFFF", histColor1:"7A3B00", histColor2:"994700", histColor3:"CC6600" },
    { nombre:"Mostaza",    fondo:"FFFDE7", texto:"5D4037", barra:"D4A017", textoBarra:"2C1810", historial:"FFFEF3", panel:"FFF59D", cooldown:"BF360C", afk:"6D4C41", boton:"D4A017", hover:"E5B82C", logo:"5D4037", luzOn:"795548", luzAccion:"D4A017", luzOff:"5D4037",  btnTexto:"2C1810", histColor1:"5D4037", histColor2:"795548", histColor3:"D4A017" },
    { nombre:"Miel",       fondo:"FFF8E7", texto:"6B4D10", barra:"F0C040", textoBarra:"4A3500", historial:"FFFCF0", panel:"FFEEBB", cooldown:"D04030", afk:"C08520", boton:"F0C040", hover:"F5D060", logo:"6B4D10", luzOn:"C08520", luzAccion:"F0C040", luzOff:"6B4D10",  btnTexto:"4A3500", histColor1:"6B4D10", histColor2:"C08520", histColor3:"F0C040" },
    { nombre:"Vainilla",   fondo:"FFFCF2", texto:"6B5435", barra:"F4E1A6", textoBarra:"4A3A20", historial:"FFFEF7", panel:"F8EDC8", cooldown:"D87333", afk:"B89464", boton:"F4E1A6", hover:"F8E9BD", logo:"6B5435", luzOn:"B89464", luzAccion:"D8B470", luzOff:"6B5435",  btnTexto:"4A3A20", histColor1:"6B5435", histColor2:"B89464", histColor3:"D8B470" },
    { nombre:"Bambú",      fondo:"F5F5E8", texto:"3D4A2C", barra:"98C46A", textoBarra:"FFFFFF", historial:"F8F8F0", panel:"E8ECD8", cooldown:"D05040", afk:"6D9840", boton:"98C46A", hover:"AAD080", logo:"3D4A2C", luzOn:"6D9840", luzAccion:"98C46A", luzOff:"3D4A2C",  btnTexto:"FFFFFF", histColor1:"3D4A2C", histColor2:"6D9840", histColor3:"98C46A" },
    { nombre:"Verde",      fondo:"F0FFF4", texto:"1B5E20", barra:"66BB6A", textoBarra:"FFFFFF", historial:"E8F5E9", panel:"C8E6C9", cooldown:"E53935", afk:"2E7D32", boton:"66BB6A", hover:"81C784", logo:"1B5E20", luzOn:"388E3C", luzAccion:"66BB6A", luzOff:"1B5E20",  btnTexto:"FFFFFF", histColor1:"1B5E20", histColor2:"388E3C", histColor3:"66BB6A" },
    { nombre:"Menta",      fondo:"FAF8F2", texto:"2C4A3E", barra:"A8E6CF", textoBarra:"1B3A2E", historial:"FEFDF8", panel:"D4F1E0", cooldown:"E07A5F", afk:"81B29A", boton:"A8E6CF", hover:"BBEFD9", logo:"2C4A3E", luzOn:"81B29A", luzAccion:"A8E6CF", luzOff:"2C4A3E",  btnTexto:"1B3A2E", histColor1:"2C4A3E", histColor2:"81B29A", histColor3:"A8E6CF" },
    { nombre:"Agua",       fondo:"D8F3F0", texto:"064C55", barra:"2E9E9A", textoBarra:"FFFFFF", historial:"ECFBF8", panel:"C7EDE8", cooldown:"D94848", afk:"1769AA", boton:"2E9E9A", hover:"4DB9B5", logo:"003C42", luzOn:"004A47", luzAccion:"00635F", luzOff:"003236",  btnTexto:"FFFFFF", histColor1:"064C55", histColor2:"00635F", histColor3:"2E9E9A" },
    { nombre:"Polar",      fondo:"F0F8FF", texto:"0B2545", barra:"8ECAE6", textoBarra:"0B2545", historial:"F8FCFF", panel:"D1E5F2", cooldown:"E63946", afk:"219EBC", boton:"8ECAE6", hover:"ADD8E6", logo:"0B2545", luzOn:"219EBC", luzAccion:"95D5B2", luzOff:"5E8AAE",  btnTexto:"0B2545", histColor1:"0B2545", histColor2:"219EBC", histColor3:"95D5B2" },
    { nombre:"Nube",       fondo:"FAFAFA", texto:"37474F", barra:"B0BEC5", textoBarra:"FFFFFF", historial:"FCFCFC", panel:"ECEFF1", cooldown:"EF5350", afk:"78909C", boton:"B0BEC5", hover:"CFD8DC", logo:"37474F", luzOn:"78909C", luzAccion:"90A4AE", luzOff:"37474F",  btnTexto:"FFFFFF", histColor1:"37474F", histColor2:"78909C", histColor3:"90A4AE" },
    { nombre:"Hielo",      fondo:"E8F4FD", texto:"1A5276", barra:"85C1E9", textoBarra:"FFFFFF", historial:"F0F9FF", panel:"D6EAF8", cooldown:"E74C3C", afk:"2980B9", boton:"85C1E9", hover:"AED6F1", logo:"1A5276", luzOn:"2471A3", luzAccion:"2E86C1", luzOff:"1A5276",  btnTexto:"FFFFFF", histColor1:"1A5276", histColor2:"2E86C1", histColor3:"85C1E9" },
    { nombre:"Lila",       fondo:"EFE6FF", texto:"4A2C7A", barra:"7B61C9", textoBarra:"FFFFFF", historial:"F7F1FF", panel:"E1D3FF", cooldown:"D94A6A", afk:"3D5AFE", boton:"7B61C9", hover:"9279DC", logo:"271052", luzOn:"3B1D78", luzAccion:"4E279E", luzOff:"271052",  btnTexto:"FFFFFF", histColor1:"4A2C7A", histColor2:"4E279E", histColor3:"7B61C9" },
    { nombre:"Lavanda",    fondo:"F8F4FF", texto:"5E3A8C", barra:"C8B6E2", textoBarra:"FFFFFF", historial:"FCFAFF", panel:"E8DEFC", cooldown:"D87093", afk:"9370DB", boton:"C8B6E2", hover:"D4C5E8", logo:"5E3A8C", luzOn:"9370DB", luzAccion:"BA9CDB", luzOff:"5E3A8C",  btnTexto:"FFFFFF", histColor1:"5E3A8C", histColor2:"9370DB", histColor3:"BA9CDB" },
    { nombre:"Sakura",     fondo:"FFF5F8", texto:"8B2252", barra:"F48FB1", textoBarra:"5D0030", historial:"FFF0F5", panel:"FCDDE8", cooldown:"C0392B", afk:"AD1457", boton:"F8BBD9", hover:"F48FB1", logo:"8B2252", luzOn:"C2185B", luzAccion:"E91E8C", luzOff:"8B2252",  btnTexto:"5D0030", histColor1:"8B2252", histColor2:"C2185B", histColor3:"F06292" },
    { nombre:"Rosa",       fondo:"FFE8F0", texto:"7A1040", barra:"E8528A", textoBarra:"FFFFFF", historial:"FFF0F5", panel:"FFDCEA", cooldown:"CC2244", afk:"D42070", boton:"E8528A", hover:"F07AAA", logo:"5A0028", luzOn:"C03060", luzAccion:"E04080", luzOff:"5A0028",  btnTexto:"FFFFFF", histColor1:"7A1040", histColor2:"E04080", histColor3:"CC3366" },
    { nombre:"Chicle",     fondo:"FFE0F5", texto:"4B0046", barra:"E91E63", textoBarra:"FFFFFF", historial:"FFEEF8", panel:"FFC1E0", cooldown:"00BFA5", afk:"7B1FA2", boton:"E91E63", hover:"F06292", logo:"4B0046", luzOn:"AD1457", luzAccion:"00BFA5", luzOff:"4B0046",  btnTexto:"FFFFFF", histColor1:"4B0046", histColor2:"00BFA5", histColor3:"E91E63" },
    ; ─────────── OSCUROS (ordenados por color de boton) ───────────
    { nombre:"Noche",      fondo:"0D0D0D", texto:"E8E8E8", barra:"222222", textoBarra:"FFFFFF", historial:"111111", panel:"1A1A1A", cooldown:"FF5555", afk:"7EB8FF", boton:"1E1E1E", hover:"2E2E2E", logo:"FFFFFF", luzOn:"AAAAAA", luzAccion:"FFFFFF", luzOff:"333333",  btnTexto:"CCCCCC", histColor1:"E8E8E8", histColor2:"AAAAAA", histColor3:"FFFFFF" },
    { nombre:"Ceniza",     fondo:"2C2C2C", texto:"BDBDBD", barra:"424242", textoBarra:"EEEEEE", historial:"242424", panel:"333333", cooldown:"EF5350", afk:"90A4AE", boton:"424242", hover:"555555", logo:"EEEEEE", luzOn:"9E9E9E", luzAccion:"BDBDBD", luzOff:"212121",  btnTexto:"EEEEEE", histColor1:"BDBDBD", histColor2:"9E9E9E", histColor3:"EEEEEE" },
    { nombre:"Sangre",     fondo:"0A0000", texto:"F5DDD0", barra:"2A0000", textoBarra:"FFD0C0", historial:"060000", panel:"160000", cooldown:"FF0000", afk:"FF6644", boton:"1A0000", hover:"3A0000", logo:"FF2222", luzOn:"CC0000", luzAccion:"FF3322", luzOff:"0A0000",  btnTexto:"FFD0C0", histColor1:"F5DDD0", histColor2:"CC0000", histColor3:"FF3322" },
    { nombre:"Rojo",       fondo:"2A0000", texto:"FFFFFF", barra:"DD0000", textoBarra:"FFFFFF", historial:"1A0000", panel:"3A0000", cooldown:"FF8888", afk:"FF4444", boton:"DD0000", hover:"FF2222", logo:"FF4444", luzOn:"FF4444", luzAccion:"FF4444", luzOff:"1A0000",  btnTexto:"FFFFFF", histColor1:"FFFFFF", histColor2:"FF4444", histColor3:"DD0000", deco:"rojo" },
    { nombre:"Magma",      fondo:"0E0400", texto:"FF6B35", barra:"1E0800", textoBarra:"FF9A5C", historial:"080200", panel:"180600", cooldown:"FF1744", afk:"FF6B35", boton:"1E0800", hover:"330D00", logo:"FF9A5C", luzOn:"FF4500", luzAccion:"FF6B35", luzOff:"1E0800",  btnTexto:"FF9A5C", histColor1:"FF6B35", histColor2:"FF4500", histColor3:"FF9A5C" },
    { nombre:"Cobre",      fondo:"180F0A", texto:"D97849", barra:"4A2818", textoBarra:"F2A878", historial:"100A08", panel:"261810", cooldown:"FFD700", afk:"B85C2E", boton:"4A2818", hover:"6B3A22", logo:"D97849", luzOn:"B85C2E", luzAccion:"FFD700", luzOff:"180F0A",  btnTexto:"F2A878", histColor1:"D97849", histColor2:"B85C2E", histColor3:"FFD700" },
    { nombre:"Cafe",       fondo:"1A1008", texto:"DEB887", barra:"3D2010", textoBarra:"F5D5A0", historial:"120B04", panel:"251508", cooldown:"FF5533", afk:"C8963C", boton:"3D2010", hover:"5A3018", logo:"F5D5A0", luzOn:"C8963C", luzAccion:"F5D5A0", luzOff:"3D2010",  btnTexto:"F5D5A0", histColor1:"DEB887", histColor2:"C8963C", histColor3:"F5D5A0" },
    { nombre:"Bosque",     fondo:"1C1208", texto:"C8A96E", barra:"2D1E0A", textoBarra:"E8C97A", historial:"140E06", panel:"231508", cooldown:"FF5533", afk:"8BC34A", boton:"3B2610", hover:"5A3D18", logo:"8BC34A", luzOn:"6D9B2A", luzAccion:"C8A96E", luzOff:"1C1208",  btnTexto:"E8C97A", histColor1:"C8A96E", histColor2:"8BC34A", histColor3:"D4944A" },
    { nombre:"Dorado",     fondo:"0A0800", texto:"FFD700", barra:"1E0F00", textoBarra:"FFE55C", historial:"070500", panel:"140C00", cooldown:"FF4422", afk:"FFA500", boton:"1A0F00", hover:"2E1A00", logo:"FFD700", luzOn:"CC8800", luzAccion:"FF6600", luzOff:"0A0800",  btnTexto:"FFE55C", histColor1:"FFD700", histColor2:"FF6600", histColor3:"FFA500" },
    { nombre:"Veneno",     fondo:"0A1208", texto:"C8FF00", barra:"2A4505", textoBarra:"E5FF7A", historial:"060A04", panel:"131F0A", cooldown:"FF1493", afk:"00FF7F", boton:"2A4505", hover:"3D6010", logo:"C8FF00", luzOn:"7FFF00", luzAccion:"C8FF00", luzOff:"0A1208",  btnTexto:"E5FF7A", histColor1:"C8FF00", histColor2:"7FFF00", histColor3:"00FF7F" },
    { nombre:"Neon",       efecto:"multi", fondo:"050F03", texto:"39FF14", barra:"0A1F06", textoBarra:"39FF14", historial:"030A02", panel:"081A04", cooldown:"FF003C", afk:"CCFF00", boton:"0A1F06", hover:"133D0A", logo:"39FF14", luzOn:"39FF14", luzAccion:"CCFF00", luzOff:"0A1F06",  btnTexto:"39FF14", histColor1:"39FF14", histColor2:"CCFF00", histColor3:"00FF66" },
    { nombre:"Jungla",     fondo:"0F1E0F", texto:"B4E197", barra:"1F4D2F", textoBarra:"E0FFCB", historial:"081108", panel:"152618", cooldown:"FF7043", afk:"FFB300", boton:"1F4D2F", hover:"2E6B3F", logo:"F4C430", luzOn:"4CAF50", luzAccion:"FFB300", luzOff:"0F1E0F",  btnTexto:"E0FFCB", histColor1:"B4E197", histColor2:"F4C430", histColor3:"4CAF50" },
    { nombre:"Cyber",      efecto:"multi", fondo:"030D06", texto:"00FF88", barra:"001A0D", textoBarra:"00FF88", historial:"020B05", panel:"041208", cooldown:"FF3355", afk:"00FFCC", boton:"002211", hover:"004422", logo:"00FF88", luzOn:"00CC66", luzAccion:"00FF88", luzOff:"001A0D",  btnTexto:"00FF88", histColor1:"00FF88", histColor2:"00CC66", histColor3:"00FFCC" },
    { nombre:"Esmeralda",  fondo:"010F08", texto:"A8FFD0", barra:"003320", textoBarra:"C8FFE8", historial:"000A05", panel:"001A0F", cooldown:"FF4444", afk:"00FF88", boton:"002218", hover:"004430", logo:"FFD700", luzOn:"00CC66", luzAccion:"FFD700", luzOff:"010F08",  btnTexto:"C8FFE8", histColor1:"00FF88", histColor2:"FFD700", histColor3:"00CC66" },
    { nombre:"Tundra",     fondo:"0C1A22", texto:"AED9E0", barra:"4F8A8B", textoBarra:"E0F4F5", historial:"081218", panel:"152A35", cooldown:"FF6B6B", afk:"79EAD0", boton:"4F8A8B", hover:"6BA8A9", logo:"FBD46D", luzOn:"79EAD0", luzAccion:"FBD46D", luzOff:"0C1A22",  btnTexto:"E0F4F5", histColor1:"AED9E0", histColor2:"FBD46D", histColor3:"79EAD0" },
    { nombre:"Submarino",  fondo:"001A26", texto:"7DE2D1", barra:"023E5C", textoBarra:"B3F0E8", historial:"00121A", panel:"002838", cooldown:"FF6B35", afk:"FFA600", boton:"023E5C", hover:"045A82", logo:"FFA600", luzOn:"00BCD4", luzAccion:"FFA600", luzOff:"001A26",  btnTexto:"B3F0E8", histColor1:"7DE2D1", histColor2:"FFA600", histColor3:"00BCD4" },
    { nombre:"Profundo",   fondo:"020A12", texto:"4FC3F7", barra:"021825", textoBarra:"81D4FA", historial:"010609", panel:"031020", cooldown:"FF4444", afk:"00BCD4", boton:"021825", hover:"033040", logo:"4FC3F7", luzOn:"00BCD4", luzAccion:"4FC3F7", luzOff:"021825",  btnTexto:"81D4FA", histColor1:"4FC3F7", histColor2:"00BCD4", histColor3:"0288D1" },
    { nombre:"Océano",     fondo:"0A1929", texto:"9CDCEB", barra:"1B4D6B", textoBarra:"E0F7FF", historial:"050D1A", panel:"0F2438", cooldown:"FF6B6B", afk:"FFB347", boton:"1B4D6B", hover:"2C6E92", logo:"5EE5D6", luzOn:"00B4D8", luzAccion:"90E0EF", luzOff:"03455A",  btnTexto:"E0F7FF", histColor1:"9CDCEB", histColor2:"5EE5D6", histColor3:"00B4D8" },
    { nombre:"Aurora",     fondo:"060A12", texto:"80FFDB", barra:"0A1E30", textoBarra:"80FFDB", historial:"040810", panel:"0C1C28", cooldown:"FF3366", afk:"00FFCC", boton:"0A1E30", hover:"163050", logo:"80FFDB", luzOn:"00FFCC", luzAccion:"AA80FF", luzOff:"0A1E30",  btnTexto:"80FFDB", histColor1:"80FFDB", histColor2:"AA80FF", histColor3:"40C4FF" },
    { nombre:"Grafito",    fondo:"26313D", texto:"EAF2FC", barra:"3E78B2", textoBarra:"FFFFFF", historial:"1E2730", panel:"303D4A", cooldown:"FF6B6B", afk:"73A7FF", boton:"3E78B2", hover:"5591CC", logo:"FFFFFF", luzOn:"9DD2FF", luzAccion:"C7E6FF", luzOff:"FFFFFF",  btnTexto:"FFFFFF", histColor1:"EAF2FC", histColor2:"9DD2FF", histColor3:"5591CC" },
    { nombre:"Azul",       fondo:"000A2E", texto:"FFFFFF", barra:"0050D5", textoBarra:"FFFFFF", historial:"000510", panel:"001A4D", cooldown:"FF6B6B", afk:"00BFFF", boton:"0050D5", hover:"1976D2", logo:"00BFFF", luzOn:"00BFFF", luzAccion:"00BFFF", luzOff:"000A2E",  btnTexto:"FFFFFF", histColor1:"FFFFFF", histColor2:"00BFFF", histColor3:"0050D5", deco:"azul" },
    { nombre:"Glitch",     efecto:"multi", fondo:"050510", texto:"00FFFF", barra:"FF00FF", textoBarra:"00FFFF", historial:"030308", panel:"0A0A18", cooldown:"FFFF00", afk:"00FFFF", boton:"1A1A2A", hover:"FF00FF", logo:"00FFFF", luzOn:"FF00FF", luzAccion:"00FFFF", luzOff:"0A0A18",  btnTexto:"00FFFF", histColor1:"00FFFF", histColor2:"FF00FF", histColor3:"FFFF00" },
    { nombre:"Electrico",  efecto:"multi", fondo:"0A0A1A", texto:"E040FB", barra:"4A148C", textoBarra:"EA80FC", historial:"080812", panel:"0D0D22", cooldown:"FF1744", afk:"7B1FA2", boton:"4A148C", hover:"6A1EB0", logo:"E040FB", luzOn:"AA00FF", luzAccion:"E040FB", luzOff:"1A0030",  btnTexto:"EA80FC", histColor1:"E040FB", histColor2:"AA00FF", histColor3:"CE93D8" },
    { nombre:"Abismo",     fondo:"0A0010", texto:"D8C8FF", barra:"120020", textoBarra:"E0D0FF", historial:"0D0018", panel:"140025", cooldown:"FF4477", afk:"AA88FF", boton:"1A0030", hover:"280050", logo:"C8A8FF", luzOn:"9966FF", luzAccion:"BB88FF", luzOff:"1A0030",  btnTexto:"D8C8FF", histColor1:"D8C8FF", histColor2:"9966FF", histColor3:"BB88FF" },
    { nombre:"Vino",       fondo:"180510", texto:"E8B7CC", barra:"5D0A2A", textoBarra:"F5D5DE", historial:"100308", panel:"260818", cooldown:"FF1744", afk:"D81B60", boton:"5D0A2A", hover:"7E1040", logo:"E8B7CC", luzOn:"AD1457", luzAccion:"E8B7CC", luzOff:"180510",  btnTexto:"F5D5DE", histColor1:"E8B7CC", histColor2:"AD1457", histColor3:"5D0A2A" },
    ; ─────────── SECRETOS (ordenados por color de boton) ───────────
    { nombre:"⚡ V O I D ⚡",      secreto:true, unlock:"void",    efecto:"cross", fondo:"000000", texto:"FFFFFF", barra:"0A0A0A", textoBarra:"FF0000", historial:"050505", panel:"0D0D0D", cooldown:"FF0000", afk:"FF0000", boton:"111111", hover:"1C1C1C", logo:"FF0000", luzOn:"FF0000", luzAccion:"FFFFFF", luzOff:"000000",  btnTexto:"FF0000", histColor1:"FFFFFF", histColor2:"FF0000", histColor3:"CC0000" },
    { nombre:"♪ Spotify",    secreto:true, unlock:"gamer", fondo:"121212", texto:"B3B3B3", barra:"1DB954", textoBarra:"FFFFFF", historial:"0A0A0A", panel:"1A1A1A", cooldown:"FF4444", afk:"1DB954", boton:"282828", hover:"1DB954", logo:"1DB954", luzOn:"1DB954", luzAccion:"1ED760", luzOff:"181818",  btnTexto:"FFFFFF", histColor1:"B3B3B3", histColor2:"1DB954", histColor3:"1ED760" },
    { nombre:"☆ Sky",         secreto:true, unlock:"leyendas", fondo:"E1F5FE", texto:"0277BD", barra:"FFFFFF", textoBarra:"0277BD", historial:"F0FAFE", panel:"B3E5FC", cooldown:"F06292", afk:"81D4FA", boton:"FFFFFF", hover:"F5F9FB", logo:"0277BD", luzOn:"81D4FA", luzAccion:"F8BBD9", luzOff:"0277BD",  btnTexto:"0277BD", histColor1:"0277BD", histColor2:"F06292", histColor3:"81D4FA" },
    { nombre:"✦ N I K A ✦",       secreto:true, unlock:"blanco",  fondo:"FFFFFF", texto:"CC0000", barra:"CC0000", textoBarra:"FFFFFF", historial:"FFFFFF", panel:"FFF2F2", cooldown:"990000", afk:"CC0000", boton:"FFF2F2", hover:"FFE0E0", logo:"CC0000", luzOn:"DD0000", luzAccion:"FF2222", luzOff:"CC0000",  btnTexto:"CC0000", histColor1:"CC0000", histColor2:"DD0000", histColor3:"FF2222" },
    { nombre:"◓ Pokémon",     secreto:true, unlock:"leyendas", fondo:"FFFFFF", texto:"1C2B43", barra:"FF1A1A", textoBarra:"FFFFFF", historial:"F5F7FA", panel:"E8EDF5", cooldown:"FFC107", afk:"3F7CE6", boton:"FF1A1A", hover:"E60000", logo:"FFC107", luzOn:"FF1A1A", luzAccion:"FFC107", luzOff:"1C2B43",  btnTexto:"FFFFFF", histColor1:"1C2B43", histColor2:"FF1A1A", histColor3:"FFC107" },
    { nombre:"⚓ One Piece",   secreto:true, unlock:"leyendas", fondo:"0A2540", texto:"FFE066", barra:"FF8C42", textoBarra:"2C1810", historial:"071E33", panel:"103056", cooldown:"E63946", afk:"06D6A0", boton:"FF8C42", hover:"FFA866", logo:"FFE066", luzOn:"FF8C42", luzAccion:"06D6A0", luzOff:"0A2540",  btnTexto:"2C1810", histColor1:"FFE066", histColor2:"FF8C42", histColor3:"06D6A0" },
    { nombre:"➰ Naruto",      secreto:true, unlock:"leyendas", efecto:"multi", fondo:"1A1008", texto:"FF9020", barra:"FF6600", textoBarra:"FFFFFF", historial:"120A05", panel:"281A08", cooldown:"3366FF", afk:"4488FF", boton:"FF6600", hover:"FF8830", logo:"4488FF", luzOn:"FF6600", luzAccion:"4488FF", luzOff:"1A1008",  btnTexto:"FFFFFF", histColor1:"FF9020", histColor2:"FF6600", histColor3:"4488FF" },
    { nombre:"☀ F E N I X ☀",   secreto:true, unlock:"solar",   fondo:"FFF8EC", texto:"8B3A00", barra:"FF6B00", textoBarra:"FFFFFF", historial:"FFFBF5", panel:"FFE5C0", cooldown:"00C9B7", afk:"00C9B7", boton:"FFB347", hover:"FF8C00", logo:"00C9B7", luzOn:"00C9B7", luzAccion:"FF6B00", luzOff:"FFB347",  btnTexto:"FFFFFF", histColor1:"FFD700", histColor2:"FF6B00", histColor3:"00C9B7" },
    { nombre:"⛏ Minecraft",   secreto:true, unlock:"gamer", fondo:"3B2A1A", texto:"7CFC00", barra:"5D8A3C", textoBarra:"FFFFFF", historial:"2E2010", panel:"4A3620", cooldown:"FF3333", afk:"55FF55", boton:"5D8A3C", hover:"6FA04A", logo:"7CFC00", luzOn:"55FF55", luzAccion:"7CFC00", luzOff:"3B2A1A",  btnTexto:"FFFFFF", histColor1:"7CFC00", histColor2:"55FF55", histColor3:"5D8A3C" },
    { nombre:"▣ Matrix",      secreto:true, unlock:"leyendas", efecto:"scan", fondo:"000000", texto:"00FF00", barra:"002200", textoBarra:"00FF00", historial:"000800", panel:"001100", cooldown:"FF0000", afk:"00FF00", boton:"002200", hover:"003800", logo:"00FF00", luzOn:"00FF00", luzAccion:"FFFFFF", luzOff:"001100",  btnTexto:"00FF00", histColor1:"00FF00", histColor2:"00FF88", histColor3:"FFFFFF" },
    { nombre:"⌖ Valorant",    secreto:true, unlock:"gamer", fondo:"0F1923", texto:"ECE8E1", barra:"FF4655", textoBarra:"FFFFFF", historial:"0A1018", panel:"162030", cooldown:"FFFF00", afk:"BD3944", boton:"1A2A3A", hover:"FF4655", logo:"FF4655", luzOn:"FF4655", luzAccion:"ECE8E1", luzOff:"0F1923",  btnTexto:"FFFFFF", histColor1:"ECE8E1", histColor2:"FF4655", histColor3:"BD3944" },
    { nombre:"★ Brawl",       secreto:true, unlock:"gamer", fondo:"000000", texto:"FFFFFF", barra:"0050D5", textoBarra:"FFFFFF", historial:"000000", panel:"0A1A30", cooldown:"FF4444", afk:"4FC3F7", boton:"0050D5", hover:"1976D2", logo:"FFFFFF", luzOn:"00B0FF", luzAccion:"FFFFFF", luzOff:"050E1C",  btnTexto:"FFFFFF", histColor1:"FFFFFF", histColor2:"00B0FF", histColor3:"0050D5" },
    { nombre:"✦ Discord",    secreto:true, unlock:"gamer", fondo:"2C2F33", texto:"DCDDDE", barra:"5865F2", textoBarra:"FFFFFF", historial:"23272A", panel:"36393F", cooldown:"ED4245", afk:"57F287", boton:"40444B", hover:"5865F2", logo:"FFFFFF", luzOn:"5865F2", luzAccion:"57F287", luzOff:"2C2F33",  btnTexto:"FFFFFF", histColor1:"DCDDDE", histColor2:"5865F2", histColor3:"57F287" },
    { nombre:"✦ E C L I P S E ✦", secreto:true, unlock:"shadow",  efecto:"nova", fondo:"050508", texto:"C8A060", barra:"0D0A20", textoBarra:"FFB347", historial:"030306", panel:"0A0818", cooldown:"FF2244", afk:"00FFCC", boton:"14102A", hover:"221840", logo:"FFB347", luzOn:"FF6600", luzAccion:"FFD700", luzOff:"080520",  btnTexto:"FFB347", histColor1:"FFD700", histColor2:"FF6600", histColor3:"00FFCC" },
    { nombre:"✦ C O S M O S ✦",   secreto:true, unlock:"cosmos",  efecto:"pulse", fondo:"03000F", texto:"E2C9FF", barra:"180040", textoBarra:"FFD700", historial:"020008", panel:"0D001E", cooldown:"FF1493", afk:"00E5FF", boton:"12002E", hover:"1E0050", logo:"FFD700", luzOn:"BF00FF", luzAccion:"FF69B4", luzOff:"080020",  btnTexto:"FFD700", histColor1:"FF69B4", histColor2:"BF00FF", histColor3:"00E5FF" },
    { nombre:"♦ P R E M I U M ♦", secreto:true, unlock:"premium", fondo:"050008", texto:"FFFFFF", barra:"0F0020", textoBarra:"FFFFFF", historial:"030005", panel:"0A0015", cooldown:"FF0066", afk:"00FFCC", boton:"15002A", hover:"25004A", logo:"FFFFFF", luzOn:"FF00FF", luzAccion:"FFD700", luzOff:"0A0015",  btnTexto:"FFFFFF", histColor1:"FF00FF", histColor2:"00FFFF", histColor3:"FFFF00" },
    { nombre:"☀ Retrowave",   secreto:true, unlock:"gamer", efecto:"nova", fondo:"1A0833", texto:"FF6EC7", barra:"7A1FA2", textoBarra:"00E5FF", historial:"0F051F", panel:"23104D", cooldown:"FF4081", afk:"FF8A50", boton:"7A1FA2", hover:"9C27B0", logo:"FF8A50", luzOn:"FF6EC7", luzAccion:"00E5FF", luzOff:"1A0833",  btnTexto:"FFFFFF", histColor1:"FF6EC7", histColor2:"00E5FF", histColor3:"FF8A50" },
    { nombre:"◆ Cyberpunk",   secreto:true, unlock:"gamer", efecto:"multi", fondo:"0D0B1F", texto:"00FFFF", barra:"FF00AA", textoBarra:"FFFF00", historial:"070518", panel:"130E2E", cooldown:"FFFF00", afk:"00FFFF", boton:"FF00AA", hover:"FF33BB", logo:"FFFF00", luzOn:"FF00AA", luzAccion:"00FFFF", luzOff:"1A1240",  btnTexto:"FFFFFF", histColor1:"00FFFF", histColor2:"FF00AA", histColor3:"FFFF00" },
    ; ── GOJO y SUKUNA fijos al final de los secretos (no por color): son los
    ;    unlocks más especiales, así que van siempre los últimos antes del custom.
    ; ── SUKUNA: Rey de las Maldiciones. Negro + rojos + gris rojizo + blanco hueso ──
    ; Acentos en BLANCO (los huesos visibles del Rey). Paleta de alto contraste.
    { nombre:"⛩ S U K U N A ⛩", secreto:true, unlock:"sukuna", logoChar:Chr(0x26E9), efecto:"cross",
      fondo:"0A0000", texto:"D9D5D2", barra:"2E0506", textoBarra:"D9D5D2",
      historial:"070000", panel:"3D1A1A", cooldown:"FF3030", afk:"D00000",
      boton:"3A0808", hover:"5C1010", logo:"B30000",
      luzOn:"D00000", luzAccion:"FF3030", luzOff:"2A1010",
      btnTexto:"D9D5D2", histColor1:"D9D5D2", histColor2:"FF3030", histColor3:"6E3838" },
    ; ── GOJO: el más fuerte. Uniforme negro + pelo blanco + Limitless beige + Six Eyes azul + Hollow Purple ──
    ; Logo: ∞ (Limitless). Negro azulado del uniforme, blanco del pelo, beige del Infinito, azul cielo, morado Hollow Purple.
    { nombre:"♾ G O J O ♾", secreto:true, unlock:"gojo", logoChar:Chr(0x221E), efecto:"pulse",
      fondo:"0A0E1F", texto:"E8DEC4", barra:"5B2A8C", textoBarra:"FFFFFF",
      historial:"070B18", panel:"131A30", cooldown:"D4C8A8", afk:"4FC3F7",
      boton:"1A1F35", hover:"3D1F66", logo:"FFFFFF",
      luzOn:"4FC3F7", luzAccion:"8A2BE2", luzOff:"0A0E1F",
      btnTexto:"E8DEC4", histColor1:"E8DEC4", histColor2:"4FC3F7", histColor3:"8A2BE2" },
]

; ── TEMA PERSONALIZABLE (v31.2): editable por el usuario y guardado en [TemaCustom] ──
; Se añade al final del array (no desplaza índices existentes). Los valores por
; defecto son una base neutra; el editor de tema los sobrescribe y CargarTemaCustom()
; restaura los guardados antes de aplicar el tema inicial.
temas.Push({ nombre:Chr(0x270E) " Personalizado", custom:true,
    fondo:"161A24", texto:"E6E6E6", barra:"3D7EBE", textoBarra:"FFFFFF",
    historial:"10131B", panel:"222838", cooldown:"FF6B6B", afk:"6FB0E0",
    boton:"2A3142", hover:"3A4459", logo:"FFFFFF",
    luzOn:"6FB0E0", luzAccion:"3D7EBE", luzOff:"161A24",
    btnTexto:"FFFFFF", histColor1:"E6E6E6", histColor2:"6FB0E0", histColor3:"3D7EBE" })
global temaCustomIdx := temas.Length
CargarTemaCustom()

temaActual := LeerTemaGuardado()
temaAnteriorNombre := ""  ; para detectar secuencia Azul → Rojo
temaInicial := temas[temaActual]
colorFondoPrincipal := temaInicial.fondo
colorTextoPrincipal := temaInicial.texto
colorBarra := temaInicial.barra
colorTextoBarra := temaInicial.textoBarra
colorVentanaHistorial := temaInicial.fondo
colorFondoHistorial := temaInicial.historial
colorCooldown := temaInicial.cooldown
colorAFK := temaInicial.afk
colorBotonNormal := temaInicial.boton
colorBotonHover := temaInicial.hover
colorLogoMacro := temaInicial.logo
colorLuzActiva := temaInicial.luzOn
colorLuzAccion := temaInicial.luzAccion
colorLuzApagado := temaInicial.luzOff
colorBtnTexto := temaInicial.btnTexto
colorHist1 := temaInicial.histColor1
colorHist2 := temaInicial.histColor2
colorHist3 := temaInicial.histColor3

; ===== ESCALADO =====
baseW := 1920
baseH := 1080
scaleX := A_ScreenWidth / baseW
scaleY := A_ScreenHeight / baseH

; ===== PASOS =====
pasosPrioridad := []
pasosNormales := []

; ===== PASOS DE PRIORIDAD =====
pasosPrioridad.Push({ tipo:"pimg", nombre:"LEAVINGGAME1...", color:0xFFFFFF, categoria:1, accion:"Esc", hold:1000, tolerancia:1, delayClick:3000, delayTecla:1000, cooldown:190000, tct:true, lastUsed:0, x1:1445, y1:65, x2:1448, y2:69, esperarA:"leaving1..." })

pasosPrioridad.Push({ tipo:"pimg", nombre:"LEAVINGGAME2...", color:0xFFFFFF, categoria:1, accion:"Esc", hold:1000, tolerancia:1, delayClick:3000, delayTecla:1000, cooldown:300000, sp:true, lastUsed:0, x1:1624, y1:67, x2:1625, y2:72, esperarA:"leaving2..." })

; ===== PIXEL PASOS NORMALES =====
; Categorias (color del log en historial):
;   1 = histColor1   → partida terminada (eventos principales)
;   2 = histColor2   → inicio / play
;   3 = histColor3   → navegacion + setup lobby
;   4 = texto        → estado in-game
;   5 = luzAccion    → salida / cierre
;   6 = afk          → anomalias / glitches

; ─── FASE 1: ENTRAR A PLAY (cat 2) ─────────────────────────────────
pasosNormales.Push({ tipo:"pimg", nombre:"play",          color:0xF6F7F8, categoria:2, hold:400, tolerancia:1, delayClick:30,  delayTecla:80,  cooldown:200, tct:true, lastUsed:0, x1:37, y1:271, x2:37, y2:271 })
pasosNormales.Push({ tipo:"pimg", nombre:"playbob",       color:0xFED511, categoria:2, hold:100, tolerancia:1, delayClick:500, delayTecla:500, cooldown:100, tct:true, lastUsed:0, x1:36, y1:264, x2:36, y2:264 })
pasosNormales.Push({ tipo:"pimg", nombre:"playwhite",     color:0xFFFFFF, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, tct:true, lastUsed:0, x1:34, y1:269, x2:34, y2:269 })
pasosNormales.Push({ tipo:"pimg", nombre:"play",          color:0xF6F7F8, categoria:2, hold:400, tolerancia:1, delayClick:30,  delayTecla:80,  cooldown:200, sp:true,  lastUsed:0, x1:34, y1:526, x2:34, y2:532 })
pasosNormales.Push({ tipo:"pimg", nombre:"playbob",       color:0xFED511, categoria:2, hold:100, tolerancia:1, delayClick:500, delayTecla:500, cooldown:100, sp:true,  lastUsed:0, x1:34, y1:526, x2:34, y2:532 })
pasosNormales.Push({ tipo:"pimg", nombre:"playwhite",     color:0xFFFFFF, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, sp:true,  lastUsed:0, x1:34, y1:526, x2:34, y2:532 })
pasosNormales.Push({ tipo:"pimg", nombre:"dragonpurple",		   color:0x8B52FF, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, sp:true,  lastUsed:0, x1:34, y1:526, x2:34, y2:532 })
pasosNormales.Push({ tipo:"pimg", nombre:"dragonpurple",		   color:0x8B52FF, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, tct:true,  lastUsed:0, x1:49, y1:271, x2:49, y2:271 })
pasosNormales.Push({ tipo:"pimg", nombre:"dragonyellow",		   color:0xFFFF28, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, tct:true,  lastUsed:0, x1:49, y1:271, x2:49, y2:271 })
pasosNormales.Push({ tipo:"pimg", nombre:"dragonyellow",		   color:0xFFFF28, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, sp:true,  lastUsed:0, x1:34, y1:526, x2:34, y2:532 })
; ─── FASE 2: NAVEGACION ENTRE PANTALLAS (cat 3) ────────────────────
pasosNormales.Push({ tipo:"pimg", nombre:"enteringsp1",   color:0x15171A, categoria:3, hold:200, tolerancia:1, delayClick:500, delayTecla:500, cooldown:500, sp:true, lastUsed:0, x1:465, y1:471, x2:466, y2:476 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringsp2",   color:0x9EA9BB, categoria:3, hold:200, tolerancia:1, delayClick:500, delayTecla:500, cooldown:500, sp:true, lastUsed:0, x1:734, y1:427, x2:738, y2:429 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringroom1", color:0xFF89D0, categoria:3, hold:400, tolerancia:1, delayClick:30,  delayTecla:80,  cooldown:500, tct:true, lastUsed:0, x1:262, y1:565, x2:262, y2:565 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringroom2", color:0x3F7F96, categoria:3, hold:400, tolerancia:1, delayClick:30,  delayTecla:80,  cooldown:500, tct:true, lastUsed:0, x1:292,  y1:562, x2:292, y2:562 })

; ─── FASE 3: SETUP DEL LOBBY / BOTS (cat 3) ────────────────────────
pasosNormales.Push({ tipo:"pimg", nombre:"addrobot",      color:0x70C9D3, categoria:3, hold:200, tolerancia:1, delayClick:500, delayTecla:500, cooldown:500, sp:true, lastUsed:0, x1:31,  y1:256, x2:34,  y2:256 })
pasosNormales.Push({ tipo:"pimg", nombre:"configbot",     color:0x70C9D3, categoria:3, accion:"c", hold:200, tolerancia:1, delayClick:500, delayTecla:500, cooldown:500, sp:true, lastUsed:0, x1:18,  y1:268, x2:18,  y2:268 })
pasosNormales.Push({ tipo:"pimg", nombre:"easybot",       color:0xFFFFFF, categoria:3, accion:"c", hold:200, tolerancia:1, delayClick:500, delayTecla:500,   sp:true, cooldown:500, lastUsed:0, x1:239, y1:323, x2:239, y2:323 })
pasosNormales.Push({ tipo:"pimg", nombre:"botbot",        color:0xFFFFFF, categoria:3, accion:"c", hold:200, tolerancia:1, delayClick:500, delayTecla:500,   sp:true, cooldown:500, lastUsed:0, x1:239, y1:323, x2:239, y2:323 })

; ─── FASE 4: ESTADO IN-GAME (cat 4) ────────────────────────────────
pasosNormales.Push({ tipo:"pimg", nombre:"ingame...",     color:0x70C9D3, categoria:4, accion:"c", hold:100, tolerancia:1, delayClick:10, delayTecla:10, cooldown:10,   tct:true, lastUsed:0, x1:32,  y1:266, x2:35,  y2:268 })
pasosNormales.Push({ tipo:"pimg", nombre:"INTHEGAME1",    color:0x38373E, categoria:4, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:5000, bloqueoGlobal:170000, tct:true, lastUsed:0, x1:792, y1:488, x2:794, y2:496 })
pasosNormales.Push({ tipo:"pimg", nombre:"INTHEGAME2",    color:0x38373E, categoria:4, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:5000, bloqueoGlobal:170000, sp:true, lastUsed:0, x1:792, y1:488, x2:794, y2:496 })
pasosNormales.Push({ tipo:"pimg", nombre:"creatingmap",   color:0x918D2D, categoria:4, tolerancia:2, hold:100, delayClick:500, delayTecla:500, cooldown:500, sp:true, lastUsed:0, x1:607, y1:243, x2:617, y2:254 })
pasosNormales.Push({ tipo:"pimg", nombre:"detector",      color:0xFFFFFF, categoria:4, tolerancia:0, cooldown:500, dstv:true, lastUsed:0, x1:893, y1:483, x2:1025, y2:615, circuloDetector:true, circuloRadio:67, circuloCantidad:100, circuloOffsetX:1, circuloOffsetY:19 })

; ─── FASE 5: PARTIDA TERMINADA (cat 1) ─────────────────────────────
pasosNormales.Push({ tipo:"pimg", nombre:"gamedone1",     color:0x000033, categoria:1, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, tct:true, sp:true, lastUsed:0, x1:941, y1:40, x2:959, y2:43 })
pasosNormales.Push({ tipo:"pimg", nombre:"gamedone2",     color:0xF7F9F9, categoria:1, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, tct:true, sp:true, lastUsed:0, x1:900, y1:43, x2:900, y2:43 })
pasosNormales.Push({ tipo:"pimg", nombre:"gamedone3",     color:0xF7F9F9, categoria:1, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, tct:true, sp:true, lastUsed:0, x1:876, y1:51, x2:876, y2:51 })

; ─── FASE 6: SALIDA / CIERRE (cat 5) ───────────────────────────────
pasosNormales.Push({ tipo:"pimg", nombre:"closing...",    color:0xD7D554, categoria:5, hold:400, tolerancia:1, delayClick:30, delayTecla:400, cooldown:300000, tct:true, sp:true, lastUsed:0, x1:742, y1:515, x2:743, y2:518 })
pasosNormales.Push({ tipo:"pimg", nombre:"leaving1...",    color:0x30F1DD, categoria:5, hold:400, tolerancia:1, delayClick:30, delayTecla:300, cooldown:500,    bloqueoGlobal:3000, sp:true,  lastUsed:0, x1:859, y1:928, x2:863, y2:931 })
pasosNormales.Push({ tipo:"pimg", nombre:"leaving2...",    color:0x30F1DD, categoria:5, hold:400, tolerancia:1, delayClick:30, delayTecla:300, cooldown:500,    bloqueoGlobal:3000, tct:true, lastUsed:0, x1:859, y1:928, x2:863, y2:931 })

; ─── FASE 7: ANOMALIAS / GLITCHES (cat 6, red de seguridad) ────────
pasosNormales.Push({ tipo:"pimg", nombre:"glitch1",       color:0x0059A2, categoria:6, tiempoNecesario:4000, tiempoDetectando:0, accion:"Esc", hold:400, tolerancia:1, delayClick:30, delayTecla:250, cooldown:500, tct:true, sp:true, lastUsed:0, x1:38,  y1:252, x2:53,  y2:259 })
pasosNormales.Push({ tipo:"pimg", nombre:"featured",      color:0x0E2C45, categoria:6, tiempoNecesario:4000, tiempoDetectando:0, accion:"Esc", hold:400, tolerancia:1, delayClick:30, delayTecla:250, cooldown:500, tct:true, sp:true, lastUsed:0, x1:166, y1:262, x2:166, y2:269 })

; ===== TECLAS HOTBAR (siempre activas al iniciar) =====
teclasHotbar     := ["1", "2", "3", "4", "5", "6", "7"]
delayEntreTeclas := 250   ; ms entre cada tecla

; ──────────────────────────────────────────────────────────

pasosPrioridad.Push({ nombre:"xxx", prioridad:1, color:0x7C1A9B, tolerancia:255, lastUsed:0, frt:true, x1:1454, y1:903, x2:1454, y2:903 })

; Array combinado (para iteracion uniforme si lo necesitas en el futuro)
pasos := []
for p in pasosPrioridad
    pasos.Push(p)
for p in pasosNormales
    pasos.Push(p)

; ===== GLOBALES =====
global pasosPrioridad, pasosNormales, activo := false
global luzActiva, luzAccion, luzApagado, historialGui := "", historialBox := "", cooldownText, afkText
global tiempoInicio := 0, tiempoAcumulado := 0, timerActivo := false
global avisoMostrado := false, avisoGui := "", ultimoCambio := 0
global ultimaDeteccionReal := 0   ; A_TickCount de la ULTIMA deteccion REAL de pixel (no resets/anti-AFK)
global tiempoLanzamientoSteam := 0 ; timestamp del Run Steam, para abortar Win+typing si hay deteccion en esos 30s
global ultimoPasoEjecutado := ""
global modoDestruccion := false
; ── Ciclo automático: jugar N horas → Alt+F4 + descanso M min → volver a jugar → repetir ──
global cicloActivo := true, cicloInicio := "", enDescanso := false, descansoInicio := ""
global CICLO_SEG := 28800, DESCANSO_SEG := 3600   ; 8 h jugando / 1 h descanso (configurable en [Ciclo])
global cicloLabel := ""   ; etiqueta que muestra cuánto falta para el descanso
global historialVisible := true, accionEnCurso := false, contadorEsc := 0
global perfilActivo := 1  ; 1=tct, 2=sp, 3=frt — los pasos sin marcar valen para tct y sp
; ── Velocidad de pasos (botón 🐢/🚶/⚡): 1=lento, 2=medio, 3=rápido ──
; Multiplica la cadencia de escaneo POR PASO (ver IntervaloScanPaso). Los pasos
; con cooldown >= 10s mantienen su cadencia fija — el botón no los toca.
global velocidadPasos := 2

; ===== DETECTOR CIRCULAR (perfil dstv): 100 cruces (cuadrados 3×3) alrededor de un círculo =====
; Estado del enganche + caché de las posiciones generadas + recursos GDI reutilizables
; para capturar la región del círculo en memoria una sola vez por frame (ver CapturarCirculo).
global circuloPuntos := [], circuloPuntosOrigen := "", circuloLockIdx := 0, circuloLockColores := []
global circuloHDCMem := 0, circuloHBMP := 0, circuloHBMPOld := 0, circuloHDCScreen := 0
global circuloBuf := 0, circuloBufW := 0, circuloBufH := 0, circuloBufOX := 0, circuloBufOY := 0

; ===== MODO FRT (spam clicks + cycle de teclas) =====
; Coordenadas del pixel a clickear continuamente cuando perfilActivo=3 y activo=true.
; Configura aqui donde quieres que clicke (en base a resolucion 1920x1080).
global frtClickX := 960
global frtClickY := 540
; Teclas que cicla automaticamente (1,2,3,4,5,6,7) — añade o quita aqui.
global frtTeclas := ["1", "2", "3", "4", "5", "6", "7"]
global frtIdxTecla := 1   ; indice de la tecla actual (rota automaticamente)
global histUltimoTexto := "", histUltimoCount := 0, histUltimoLongLinea := 0
global separadorHistorial := ""
global ultimoScrollManual := 0   ; última vez que el usuario movió la rueda en el historial
; ── Estimador de oro/XP ──
; Base real: una partida de 9 min da ~280 XP y ~70 monedas. Con el macro las
; partidas duran ~3 min → regla de 3: cada secuencia ≈ 93 XP y ≈ 23 monedas.
; Ajustable en el config, sección [Estimador].
global estXpPartida := 280, estOroPartida := 70, estMinReal := 9, estMinMacro := 3
global temaTransTema := "", temaTransGuardar := true, temaEnTransicion := false
global temaGuiVisible := false, temaGui := ""
global temaBotones := [], temaScrollOffset := 0, temasVisiblesGlobal := []
global temaAlturaItem := 32, temaAlturaBarra := 22, temaAlturaVisible := 0, temaAnchoPnl := 180
global temaBarraGui := "", temaBarraInfGui := ""
global temaBarraCtrl := "", temaBarraInfCtrl := ""
global scaleX, scaleY
global contadorSecuencias := 0, secuenciasLabel := ""
global contadorDestruccion := 0, destruccionesLabel := ""
global tiempoUltimoLanzamiento := 0
global bloqueoGlobalHasta := 0
global rgbBarraHue := 0
global rgbBarra := false, rgbBotones := false, rgbLogo := false, rgbTexto := false
global rgbActivo := false
global rgbVelocidad := 2        ; incremento de hue por tick (1=lento, 2=medio, 4=rapido, 6=maximo)
global rgbSaturacion := 1.0     ; 0.0 – 1.0  (máximo para colores puros)
global rgbBrillo := 1.0         ; 0.0 – 1.0
global rgbHueInicio := 0        ; 0 – 359, hue de arranque
global rgbDireccion := 1        ; 1=normal, -1=inverso
global rgbGui := "", rgbGuiVisible := false
global colorRGBActual := colorBarra
global rgbPreviewCtrl := ""
global overlayPixeles := "", overlayVisible := false
global miGui, barra, barraHistorial, logoMacro, tituloMacro, timerLabel
global miniGui := "", modoMini := false, logoMacroMini := "", miniSubclassCb := 0
global miniHistLabel := "", miniHistBuffer := []   ; mini historial del modo mini (últimas 3 líneas)
global barraMini := "", miniBarraSubclassCb := 0
global overlayPartMini := "", particulasMini := [], overlayDecoMini := "", overlayDecoMiniSubCb := 0
global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnStatsBtn, btnWebhook, btnLogros, btnPerfil, btnMini, btnTutorial, btnParches, btnMiniTema
global btnMiniIniciar := "", btnMiniParar := "", btnMiniCerrar := ""
global hoverAccent := "", hoverAnimStep := 0, hoverAccentTop := "", hoverAccentHist := ""
global hoverAccentBot := "", hoverAccentRight := "", hoverAccentBotHist := "", hoverAccentRightHist := ""
global glowTitulo := "", sepEstado := "", sepAccion := ""  ; polish visual estático
global glowTituloL := "", glowTituloR := ""               ; degradado fade línea título
global sepEstadoL  := "", sepEstadoR  := ""               ; degradado fade línea estado
global sepAccionL  := "", sepAccionR  := ""               ; degradado fade línea acción
global colorBotonNormal, colorBotonHover, colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
global colorVentanaHistorial, colorFondoHistorial, colorCooldown, colorAFK, colorLogoMacro
global colorLuzActiva, colorLuzAccion, colorLuzApagado
global colorBtnTexto, colorHist1, colorHist2, colorHist3
global temas, temaActual, configPath
global histColorIndex := 0
global modoCadena := false, pasoCadena := "", finCadena := 0
global pulsoBrilloDir := 1, pulsoBrilloT := 0.0
global logosPulsoDir := 1, logosPulsoT := 0.0
global hoverBreathT := 0.0, hoverBreathDir := 1, hoverBreathBase := ""
global hoverBotones := Map()  ; hwnd -> {btn, baseFn}
global _ctrlRadios  := Map()  ; ctrl_obj -> {radio, rw, rh}

; ===== CONFIG DE PARTÍCULAS (panel de decoración) =====
; Porcentajes (0-200) sobre los valores base. Se cargan desde INI más abajo.
global particulasActivas    := true
global particulasCantidad   := 100   ; 0-200, escala el conteo base (32 main / 40 hist)
global particulasVelocidad  := 100   ; 0-200, escala vx/vy
global particulasTamano     := 100   ; 50-200, escala el radio
global particulasOpacidad   := 100   ; 25-200, escala el alpha (clamp a 255)
global partGui := "", partGuiVisible := false

; ===== LOGO GIRATORIO (GDI+) =====
global gdipToken := 0, gdipInited := false
global logoFontFamily := 0, logoStringFormat := 0
; Cache del engranaje pre-renderizado (32 ángulos cubriendo 0-45° por simetría de 8 dientes)
global logoGearFont := 0           ; handle del font (no solo la familia)
global logoGearCache := []          ; array de 32 HBITMAPs ya rotados
global logoGearCacheColor := ""     ; color hex con el que está construido el cache
global logoGearCacheChar  := ""     ; char (∞/⛩/⚙) con el que está construido el cache
global logoGearCacheW := 0          ; ancho del bitmap cacheado
global logoGearCacheH := 0          ; alto del bitmap cacheado
global LOGO_GEAR_CACHE_FRAMES := 32     ; base: frames para 45° (gear)
global logoGearCacheFramesReales := 32  ; frames reales del cache actual (depende del char)
global logoGearCacheAngleSpan := 45.0   ; grados que cubre el cache
; Font cacheado para kanji de Sukuna — crear/destruir cada frame era el motivo principal del lag.
global sukunaFontFamily := 0, sukunaFont := 0
global logoAngulo := 0.0, logoVelActual := 0.0, logoVelObjetivo := 0.0
global logoVelMax := 6.0  ; grados por tick @ ~30fps  →  ~180°/s (giro completo cada 2s)
global logoNeedsRedraw := true
global logoFlashUntil := 0  ; A_TickCount hasta el cual el logo se pinta en flash (easter egg)
global colorLogoEnTransicion := "", colorFondoEnTransicion := ""  ; colores interpolados por TransicionPaso
; ⚠️ NO reinicializar las variables de eggDesbloqueado aquí — ya las carga LeerTemaGuardado()
; en la línea 43. Si las pones a false aquí, RESETEAS los eggs desbloqueados que se acaban de leer.
global eggClicks := 0, eggUltimo := 0
global eggVoidClicks := 0, eggVoidUltimo := 0
global eggShadowClicks := 0, eggShadowUltimo := 0
global luzSeq := [], luzSeqUltimo := 0
global nikaHistClicks := 0, nikaHistUltimo := 0
global eggPremiumClicks := 0, eggPremiumUltimo := 0
global eggGamerClicks := 0, eggGamerUltimo := 0
global eggLeyendasClicks := 0, eggLeyendasUltimo := 0  ; 8 clicks rapidos en el medidor ⚡ preset
global eggGojoClicks := 0, eggGojoUltimo := 0       ; 6 clicks (Six Eyes) en secuenciasLabel
global eggSukunaClicks := 0, eggSukunaUltimo := 0   ; 4 clicks (cuatro brazos) en destruccionesLabel

; ── Decoraciones tematicas (overlay topmost) ──
global overlayDecoraciones := "", overlayDecoSubclassCb := 0
global sukunaSlashFrame := 0     ; > 0 = pintando cortes Sukuna
global sukunaCortesActuales := []  ; trayectorias aleatorias del slash actual (se regeneran por secuencia)
global gojoAuraFrame := 0        ; > 0 = pintando anillo Gojo (Hollow Purple)
global gojoDominioFrame := 0     ; > 0 = Expansión de Dominio: Vacío Ilimitado (無量空処)
global DECO_COLORKEY_HEX := "010203"
global DECO_COLORKEY_BGR := 0x030201
global temaPremiumActivo := false
global temaArcoirisData := Map(), temaArcoirisCbs := []
global horaInicioSesion := ""

; ===== DINAMISMO =====
global contadorAcciones := 0, contadorLabel := ""
; ===== DINAMISMO EXTRA =====
global streakActual := 0, streakMax := 0
global logoSpeedLinesUntil := 0
global totalCriticos := 0
global confetiGui := "", confetiParticles := [], confetiActivo := false, confetiSubclassCb := 0
global logros := []
global logrosGui := "", logrosGuiVisible := false, btnLogros := ""
global logrosPagina := 1  ; página actual del libro
global ultimoAfkMove := A_TickCount  ; watchdog: timestamp del último MouseMove del AFK
global toastGui := "", toastX := 0, toastStartY := 0, toastTargetY := 0, toastStep := 0, toastDuracion := 3000
global logoGlitchActivo := false, logoGlitchHasta := 0, logoGlitchOffX := 0, logoGlitchOffY := 0
global milestonesList := [50, 100, 250, 500, 1000], milestonesVistos := []
global histFlashStep := 0
global logoTrailAngulos := [0.0, 0.0]
global afkAlertaFlash := false
global typeRevealHwnd := 0, typeRevealTotal := 0, typeRevealPos := 0
global typeRevealColor := "", typeRevealActivo := false
global barraOndaOffset := 0.0

; ===== OPTIMIZACION (toggles individuales de efectos visuales) =====
global optHoverAccent    := true   ; franjas de color al pasar el ratón
global optHoverBreath    := true   ; respiración animada del botón hover
global optShimmerBarra   := true   ; gradiente animado en barras
global optPulsoBarra     := true   ; onda en barra al detectar
global optPulsoLogo      := true   ; pulso de brillo del logo
global optLogoGiratorio  := true   ; animación del engranaje girando
global optDecoraciones   := true   ; animaciones de los temas
global optConfeti        := true   ; confeti en milestones
global optTypeReveal     := true   ; revelado progresivo de texto
global optEscena         := true   ; escena temática del borde (lo más pesado)
global optGui := "", optGuiVisible := false
global tutGui := "", tutGuiVisible := false, tutPagina := 1  ; tutorial tipo libro
global parchesGui := "", parchesGuiVisible := false, parchesPagina := 1  ; libro de parches (📋)

; ===== MEJORAS v31.2: HOTKEYS / TEMA CUSTOM / EFECTOS =====
global btnPersonalizar := ""

; ── Abrir Brawlhalla automáticamente al pulsar Iniciar (toggle en Personalizar) ──
global abrirBrawlAlIniciar := true

; ── Efectos de acción dinámicos (fade/glow/zoom/slide cuando se detecta una acción) ──
global efectosAccionActivos := true
global efAccionFrame := 0, efAccionColor := "", efAccionTipo := 1   ; tipo: 1=glow 2=zoom 3=slide
global efAccionEstilo := "estrellas"   ; categoría elemental del tema: la misma que EfectoDeTema()
global efAccionMaxFrame := 14
global efAccionParticulas := []   ; ráfaga temporal del efecto de acción (lluvia/viento/abejas/etc)
global EFACCION_W := 400, EFACCION_H := 215   ; tamaño fijo del overlay principal (sin BAR_H=25)
global efAccionOverlay := "", efAccionSubCb := 0, efAccionCx := 0, efAccionCy := 0

; ── Hotkeys personalizables (cualquier tecla reasignable; se guardan solas) ──
global hkIniciar := "F1", hkParar := "F2", hkMini := "", hkHistorial := "", hkTema := "", hkPerfil := ""
global hotkeysGui := "", hotkeysGuiVisible := false, hkRegistradas := Map(), hkCapturando := ""

; ── Tema totalmente personalizable + guardado ──
; temaCustomIdx (índice del tema custom en `temas`) se fija junto a temas.Push() al inicio.
global temaCustomActivo := false
global editorTemaGui := "", editorTemaVisible := false, editorTemaCampos := Map()
global temaCustomData := Map()
global temaCustomHue := 207, temaCustomOscuridad := 75   ; tono (0-360) y oscuridad (0-100) del tema personalizado
global temaCustomDeco := "", temaCustomAccion := ""   ; decoración (escena) y efecto de acción elegidos ("" = automático)
global editorTemaHbmHue := 0, editorTemaHbmOsc := 0   ; HBITMAP de las tiras de gradiente (hay que liberarlos a mano)
global editorTemaLiveArmed := false   ; throttle del preview en vivo sobre la ventana real

; ── Centro de personalización (hub que abre tema/RGB/partículas/atajos/optimización) ──
global centroPersGui := "", centroPersVisible := false

; ===== PRESETS DE RENDIMIENTO =====
global presetRendimiento := 4
global fpsLabel := ""
global presetLabel := ""
global presetHoverPoll := 16
global presetHoverBreath := 40
global presetParticulas := 50
global presetPulsoBar := 40
global presetPulsoLogo := 50
global presetRGB := 60
global presetBarras := 33            ; intervalo de AnimarBarras (gradiente shimmer)
global presetDecoraciones := true    ; pintar slashes Sukuna / aura Gojo
global presetDecoFps := 50           ; intervalo de TickDecoracionesPermanentes (Six Eyes Gojo, etc.)
global presetTrayIcon := 1000        ; intervalo de ActualizarTrayIcon
global presetLogros := 5000          ; intervalo de VerificarLogros

; ===== BARRA GRADIENTE / ANILLO COOLDOWN / STATS (GDI+) =====
global barraGradPhase := 0.0
global barraSubclassCbM := 0, barraSubclassCbH := 0
global colorBarraOverride := ""   ; "" = base; HEX = override total (flash error)
global barraExtraBrillo := 0      ; pulso/shimmer aditivo
global statsGuiActive := "", statsBarsData := [], statsBarsSubclassCbs := []

; ===== ACTUALIZADOR =====
global GITHUB_VERSION_URL := "https://raw.githubusercontent.com/mike305-droid/brawlmacro/main/parches.txt"
global GITHUB_SCRIPT_URL  := "https://raw.githubusercontent.com/mike305-droid/brawlmacro/main/brawlmacrotct.ahk"
global updateGui := "", updateGuiVisible := false

; ===== GUARDAR STATS =====
; (Stats viven dentro del config.ini en seccion [Stats] desde v27.9.2,
; antes vivian en brawlmacro_stats.ini — se migra automaticamente al cargar.)
global totalHorasGuardadas := 0.0
global totalSecuenciasGuardadas := 0
global totalDestruccionGuardada := 0

; ===== WEBHOOK DISCORD (globals) =====
global webhookURL := ""
global webhookEnabled := false
global webhookEventos := Map(
    "iniciado",    true,
    "parado",      true,
    "destruccion", true,
    "altf4",       true,
    "milestone",   true,
    "secuencia",   true
)

CargarStats() {
    global configPath, totalHorasGuardadas, totalSecuenciasGuardadas, totalDestruccionGuardada
    ; Migracion v27.9.2: si todavia existe el viejo brawlmacro_stats.ini, importar y borrar
    oldStatsPath := A_ScriptDir "\brawlmacro_stats.ini"
    if (FileExist(oldStatsPath)) {
        try {
            h := Float(IniRead(oldStatsPath, "Stats", "Horas", "0.0"))
            s := Integer(IniRead(oldStatsPath, "Stats", "Secuencias", "0"))
            d := Integer(IniRead(oldStatsPath, "Stats", "Destruccion", "0"))
            IniWrite(Round(h, 4), configPath, "Stats", "Horas")
            IniWrite(s,           configPath, "Stats", "Secuencias")
            IniWrite(d,           configPath, "Stats", "Destruccion")
            try FileDelete(oldStatsPath)
        }
    }
    totalHorasGuardadas      := Float(IniRead(configPath, "Stats", "Horas", "0.0"))
    totalSecuenciasGuardadas := Integer(IniRead(configPath, "Stats", "Secuencias", "0"))
    totalDestruccionGuardada := Integer(IniRead(configPath, "Stats", "Destruccion", "0"))
}

; ===== ESTIMADOR DE ORO/XP (regla de 3 sobre la partida real de 9 min) =====
XpPorSecuencia() {
    global estXpPartida, estMinReal, estMinMacro
    return estXpPartida * estMinMacro / Max(1, estMinReal)
}

OroPorSecuencia() {
    global estOroPartida, estMinReal, estMinMacro
    return estOroPartida * estMinMacro / Max(1, estMinReal)
}

; "12345" → "12.345" (separador de miles)
FormatearMiles(n) {
    s := String(Round(n))
    out := ""
    while (StrLen(s) > 3) {
        out := "." SubStr(s, -3) out
        s := SubStr(s, 1, StrLen(s) - 3)
    }
    return s out
}

GuardarStats() {
    global configPath, totalHorasGuardadas, totalSecuenciasGuardadas, totalDestruccionGuardada
    global tiempoAcumulado, tiempoInicio, timerActivo, contadorSecuencias
    global contadorDestruccion
    tiempoSesion := tiempoAcumulado
    if (timerActivo)
        tiempoSesion += (A_TickCount - tiempoInicio)
    horasSesion := tiempoSesion / 3600000.0
    totalGuardar := totalHorasGuardadas + horasSesion
    secGuardar := totalSecuenciasGuardadas + contadorSecuencias
    IniWrite(Round(totalGuardar, 4), configPath, "Stats", "Horas")
    IniWrite(secGuardar, configPath, "Stats", "Secuencias")
    IniWrite(totalDestruccionGuardada + contadorDestruccion, configPath, "Stats", "Destruccion")
}

MostrarEstadisticas(*) {
    global totalHorasGuardadas, totalSecuenciasGuardadas, totalDestruccionGuardada
    global tiempoAcumulado, tiempoInicio, timerActivo, contadorSecuencias, contadorDestruccion
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBtnTexto, colorHist1, colorHist2, colorCooldown
    global statsBarsData, statsGuiActive

    ; Toggle: si ya está abierto, cerrar y salir
    if (IsObject(statsGuiActive)) {
        try LimpiarHoverGui(statsGuiActive)
        try statsGuiActive.Destroy()
        statsGuiActive := ""
        statsBarsData := []
        return
    }
    statsBarsData := []

    tiempoSesion := tiempoAcumulado
    if (timerActivo)
        tiempoSesion += (A_TickCount - tiempoInicio)
    horasSesion := tiempoSesion / 3600000.0
    totalH := totalHorasGuardadas + horasSesion
    totalS := totalSecuenciasGuardadas + contadorSecuencias
    totalD := totalDestruccionGuardada + contadorDestruccion

    horas := Floor(totalH)
    mins  := Floor((totalH - horas) * 60)

    seqHora := (tiempoSesion > 0 && contadorSecuencias > 0)
               ? Round(contadorSecuencias / (tiempoSesion/3600000), 1) : 0
    sesMin := Format("{:.1f}", horasSesion * 60)

    sg := Gui("+AlwaysOnTop -Caption +ToolWindow")
    sg.BackColor := colorFondoPrincipal
    statsGuiActive := sg
    W := 290

    ; Barra superior (click = cerrar)
    barraSt := sg.Add("Text", "x0 y0 w" W " h28 Background" colorBarra " Center", Chr(0x1F4CA) "  Estadísticas")
    barraSt.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barraSt.OnEvent("Click", (*) => CerrarStatsGui())

    ; Tiempo total — destacado
    lblHdr := sg.Add("Text", "x16 y38 w" (W - 32) " h14 Center BackgroundTrans c" colorTextoPrincipal, "Tiempo total")
    lblHdr.SetFont("s8", "Segoe UI")
    lblT := sg.Add("Text", "x16 y54 w" (W - 32) " h30 Center BackgroundTrans c" colorTextoPrincipal, horas "h " mins "m")
    lblT.SetFont("s18 Bold", "Segoe UI Semibold")

    ; Separador
    sg.Add("Text", "x35 y92 w" (W - 70) " h1 Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.55), "")

    ; ── Estimador de oro/XP (regla de 3: 9min = 280xp/70oro → 3min por secuencia) ──
    halfW := Round(W / 2)
    oroEst  := Round(totalS * OroPorSecuencia())
    xpEst   := Round(totalS * XpPorSecuencia())
    oroHora := Round(seqHora * OroPorSecuencia())

    ; Bloque oro total estimado / oro por hora
    lblOHdr := sg.Add("Text", "x10 y102 w" (halfW - 10) " h14 Center BackgroundTrans c" colorTextoPrincipal, "Oro total estimado")
    lblOHdr.SetFont("s8", "Segoe UI")
    lblO := sg.Add("Text", "x10 y118 w" (halfW - 10) " h26 Center BackgroundTrans c" colorHist2, Chr(0x1FA99) " ~" FormatearMiles(oroEst))
    lblO.SetFont("s15 Bold", "Segoe UI Semibold")
    lblOHHdr := sg.Add("Text", "x" halfW " y102 w" (halfW - 10) " h14 Center BackgroundTrans c" colorTextoPrincipal, "Oro / hora")
    lblOHHdr.SetFont("s8", "Segoe UI")
    lblOH := sg.Add("Text", "x" halfW " y118 w" (halfW - 10) " h26 Center BackgroundTrans c" colorHist2, Chr(0x1FA99) " ~" FormatearMiles(oroHora))
    lblOH.SetFont("s15 Bold", "Segoe UI Semibold")

    ; Separador
    sg.Add("Text", "x35 y152 w" (W - 70) " h1 Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.55), "")

    ; Bloque secuencias
    lblSHdr := sg.Add("Text", "x10 y162 w" (halfW - 10) " h14 Center BackgroundTrans c" colorTextoPrincipal, "Secuencias")
    lblSHdr.SetFont("s8", "Segoe UI")
    lblS := sg.Add("Text", "x10 y178 w" (halfW - 10) " h26 Center BackgroundTrans c" colorHist2, totalS)
    lblS.SetFont("s15 Bold", "Segoe UI Semibold")

    ; Bloque destrucciones
    lblDHdr := sg.Add("Text", "x" halfW " y162 w" (halfW - 10) " h14 Center BackgroundTrans c" colorTextoPrincipal, "Destrucciones")
    lblDHdr.SetFont("s8", "Segoe UI")
    lblD := sg.Add("Text", "x" halfW " y178 w" (halfW - 10) " h26 Center BackgroundTrans c" colorCooldown, totalD)
    lblD.SetFont("s15 Bold", "Segoe UI Semibold")

    ; Separador
    sg.Add("Text", "x35 y212 w" (W - 70) " h1 Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.55), "")

    ; XP estimada (fila completa)
    lblXHdr := sg.Add("Text", "x16 y222 w" (W - 32) " h14 Center BackgroundTrans c" colorTextoPrincipal, "XP estimada")
    lblXHdr.SetFont("s8", "Segoe UI")
    lblX := sg.Add("Text", "x16 y238 w" (W - 32) " h24 Center BackgroundTrans c" colorHist1, Chr(0x2B50) " ~" FormatearMiles(xpEst))
    lblX.SetFont("s13 Bold", "Segoe UI Semibold")

    ; Separador
    sg.Add("Text", "x35 y268 w" (W - 70) " h1 Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.55), "")

    ; Sesión actual (con oro estimado de la sesión)
    oroSes := Round(contadorSecuencias * OroPorSecuencia())
    lblSesHdr := sg.Add("Text", "x16 y278 w" (W - 32) " h14 Center BackgroundTrans c" colorTextoPrincipal, "Sesión actual")
    lblSesHdr.SetFont("s8 Italic", "Segoe UI")
    lblSes := sg.Add("Text", "x16 y294 w" (W - 32) " h20 Center BackgroundTrans c" colorTextoPrincipal,
        Chr(0x1F4C5) " " sesMin " min  •  " contadorSecuencias " seqs  •  " seqHora "/h  •  ~" FormatearMiles(oroSes) " oro")
    lblSes.SetFont("s9 Bold", "Segoe UI")

    ; Botón exportar
    btnExp := sg.Add("Text", "x16 y326 w" (W - 32) " h32 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(128190) "  Exportar sesión")
    btnExp.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
    btnExp.OnEvent("Click", ExportarSesion)
    RegistrarHover(btnExp, () => colorBotonNormal)

    sg.Show("w" W " h370 Center")
    RedondearVentana(sg.Hwnd, 14)
    RegistrarAutoCierre(sg, CerrarStatsGui)
}

CerrarStatsGui(*) {
    global statsGuiActive, statsBarsData
    if (IsObject(statsGuiActive)) {
        try LimpiarHoverGui(statsGuiActive)
        try statsGuiActive.Destroy()
    }
    statsGuiActive := ""
    statsBarsData := []
    SetTimer(AnimarStatsBars, 0)
}

; ===== GDI+ + LOGO GIRATORIO =====
InicializarGdip() {
    global gdipToken, gdipInited, logoFontFamily, logoStringFormat, logoGearFont
    global sukunaFontFamily, sukunaFont
    if (gdipInited)
        return
    DllCall("LoadLibrary", "Str", "gdiplus.dll")
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &gdipToken, "Ptr", si, "Ptr", 0)
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI Symbol", "Ptr", 0, "Ptr*", &logoFontFamily)
    if (!logoFontFamily)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI Emoji", "Ptr", 0, "Ptr*", &logoFontFamily)
    if (!logoFontFamily)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Arial", "Ptr", 0, "Ptr*", &logoFontFamily)
    ; Crear UN solo font handle (reutilizable). Antes DibujarGearEnDC lo recreaba cada frame.
    if (logoFontFamily)
        DllCall("gdiplus\GdipCreateFont", "Ptr", logoFontFamily, "Float", 58, "Int", 1, "Int", 0, "Ptr*", &logoGearFont)
    DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &logoStringFormat)
    DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", logoStringFormat, "Int", 0)  ; top-left (compatible con DibujarGearEnDC)
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", logoStringFormat, "Int", 0)
    ; Font cacheado para kanji de Sukuna (decoración permanente del tema)
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Yu Mincho", "Ptr", 0, "Ptr*", &sukunaFontFamily)
    if (!sukunaFontFamily)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Yu Gothic", "Ptr", 0, "Ptr*", &sukunaFontFamily)
    if (!sukunaFontFamily)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Meiryo", "Ptr", 0, "Ptr*", &sukunaFontFamily)
    if (!sukunaFontFamily)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI", "Ptr", 0, "Ptr*", &sukunaFontFamily)
    if (sukunaFontFamily)
        DllCall("gdiplus\GdipCreateFont", "Ptr", sukunaFontFamily, "Float", 16.0, "Int", 1, "Int", 0, "Ptr*", &sukunaFont)
    gdipInited := true
}

; Libera el cache de bitmaps del engranaje (llamar al cambiar color o salir).
LiberarCacheGear() {
    global logoGearCache, logoGearCacheColor, logoGearCacheChar
    for hbm in logoGearCache {
        if (hbm)
            DllCall("DeleteObject", "Ptr", hbm)
    }
    logoGearCache := []
    logoGearCacheColor := ""
    logoGearCacheChar  := ""
}

; Devuelve el char que el logo debe mostrar segun el tema activo:
; - Tema Gojo → ∞ (Limitless)
; - Tema Sukuna → ⛩ (Malevolent Shrine)
; - Cualquier otro → ⚙ (engranaje por defecto)
ObtenerCharLogo() {
    global temas, temaActual
    if (temas[temaActual].HasProp("logoChar"))
        return temas[temaActual].logoChar
    return Chr(9881)
}

; Devuelve el ángulo (en grados) que cubre el cache para el char actual,
; según su simetría rotacional:
;   ⚙ (9881)  → 45°  (gear de 8 dientes — simetría 8-fold)
;   ∞ (0x221E) → 180° (infinito — simetría 2-fold)
;   ⛩ (0x26E9) → 360° (torii — sin simetría rotacional)
;   resto      → 360° (asumir sin simetría = seguro)
ObtenerSpanLogo(char) {
    if (char = Chr(9881))
        return 45.0
    if (char = Chr(0x221E))
        return 180.0
    return 360.0
}

; Pre-renderiza 32 bitmaps del engranaje (uno por cada ~1.4° en el rango 0-45°)
; en el color dado. El engranaje tiene 8 dientes → simetría rotacional de 45° → con 32 frames
; en ese rango se ve perfectamente fluido cubriendo cualquier ángulo (se hace modulo 45).
ConstruirCacheGear(colorHex, w, h) {
    global logoGearCache, logoGearCacheColor, logoGearCacheChar, logoGearCacheW, logoGearCacheH
    global logoFontFamily, logoGearFont, LOGO_GEAR_CACHE_FRAMES, logoGearCacheAngleSpan
    global logoGearCacheFramesReales

    if (!logoFontFamily || !logoGearFont)
        return false

    LiberarCacheGear()
    charLogo := ObtenerCharLogo()
    spanAngle := ObtenerSpanLogo(charLogo)
    logoGearCacheAngleSpan := spanAngle

    ; Escalamos N frames proporcionalmente al span para mantener ~1.4° por frame
    ; (mismo "stride" que tenía el gear). Para ∞ (180°) → 128 frames. Para ⛩ (360°) → 256.
    framesReales := Round(LOGO_GEAR_CACHE_FRAMES * spanAngle / 45.0)
    if (framesReales < LOGO_GEAR_CACHE_FRAMES)
        framesReales := LOGO_GEAR_CACHE_FRAMES
    logoGearCacheFramesReales := framesReales

    cRgb := Integer("0x" colorHex)
    cArgb := 0xFF000000 | cRgb

    Loop framesReales {
        angle := (A_Index - 1) * (spanAngle / framesReales)

        ; Crear bitmap GDI+ PARGB (alpha por pixel para preservar transparencia)
        static PixelFormat32bppPARGB := 0xE200B
        bmp := 0
        if (DllCall("gdiplus\GdipCreateBitmapFromScan0",
            "Int", w, "Int", h, "Int", 0,
            "Int", PixelFormat32bppPARGB,
            "Ptr", 0, "Ptr*", &bmp) != 0 || !bmp) {
            LiberarCacheGear()
            return false
        }

        g := 0
        DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", &g)
        if (!g) {
            DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)
            LiberarCacheGear()
            return false
        }

        DllCall("gdiplus\GdipSetSmoothingMode",     "Ptr", g, "Int", 4)
        DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)
        DllCall("gdiplus\GdipGraphicsClear",        "Ptr", g, "UInt", 0x00000000)  ; transparente

        ; Medir centro del glifo (usando la misma lógica que DibujarGearEnDC)
        mFmt := 0
        DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &mFmt)
        DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", mFmt, "Int", 0)
        DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", mFmt, "Int", 0)
        bigR := Buffer(16, 0)
        NumPut("Float", 0.0, bigR, 0)
        NumPut("Float", 0.0, bigR, 4)
        NumPut("Float", 1000.0, bigR, 8)
        NumPut("Float", 1000.0, bigR, 12)
        bb := Buffer(16, 0)
        cp := 0, ln := 0
        DllCall("gdiplus\GdipMeasureString", "Ptr", g, "WStr", charLogo, "Int", StrLen(charLogo),
                "Ptr", logoGearFont, "Ptr", bigR, "Ptr", mFmt, "Ptr", bb, "Int*", &cp, "Int*", &ln)
        DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", mFmt)
        gearCX := NumGet(bb, 0, "Float") + NumGet(bb, 8, "Float") / 2.0
        gearCY := NumGet(bb, 4, "Float") + NumGet(bb, 12, "Float") / 2.0
        drawX := w / 2.0 - gearCX
        drawY := h / 2.0 - gearCY

        ; Crear brush con el color y dibujar el glifo rotado
        brush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", cArgb, "Ptr*", &brush)

        fmt := 0
        DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &fmt)
        DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", fmt, "Int", 0)
        DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", fmt, "Int", 0)

        drawRect := Buffer(16, 0)
        NumPut("Float", drawX,                  drawRect, 0)
        NumPut("Float", drawY,                  drawRect, 4)
        NumPut("Float", gearCX * 2.0 + 20.0,    drawRect, 8)
        NumPut("Float", gearCY * 2.0 + 20.0,    drawRect, 12)

        DllCall("gdiplus\GdipResetWorldTransform",     "Ptr", g)
        DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float",  w/2.0, "Float",  h/2.0, "Int", 0)
        DllCall("gdiplus\GdipRotateWorldTransform",    "Ptr", g, "Float",  angle,                  "Int", 0)
        DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", -w/2.0, "Float", -h/2.0, "Int", 0)
        DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", charLogo, "Int", StrLen(charLogo), "Ptr", logoGearFont, "Ptr", drawRect, "Ptr", fmt, "Ptr", brush)

        DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmt)
        DllCall("gdiplus\GdipDeleteBrush",        "Ptr", brush)
        DllCall("gdiplus\GdipDeleteGraphics",     "Ptr", g)

        ; Convertir a HBITMAP y guardar en cache
        hbm := 0
        DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bmp, "Ptr*", &hbm, "UInt", 0)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)

        if (!hbm) {
            LiberarCacheGear()
            return false
        }

        logoGearCache.Push(hbm)
    }

    logoGearCacheColor := colorHex
    logoGearCacheChar  := charLogo
    logoGearCacheW := w
    logoGearCacheH := h
    return true
}

; Pinta el engranaje rotado directamente sobre el HDC dado, usando GDI para el fondo y GDI+ para
; el texto rotado. No crea bitmap intermedio. Lo invoca ManejarLogoOwnerDraw en respuesta a WM_DRAWITEM.
DibujarGearEnDC(hdc, w, h, angulo, colorHex, fondoHex) {
    static gearCX := "", gearCY := "", lastChar := ""
    charLogo := ObtenerCharLogo()
    ; Si cambio el char (cambio de tema), invalidar el cache estatico del centro
    if (charLogo != lastChar) {
        gearCX := ""
        gearCY := ""
        lastChar := charLogo
    }

    ; Fondo opaco
    fondoBgr := HexToBGR(fondoHex)
    brushBg  := DllCall("CreateSolidBrush", "UInt", fondoBgr, "Ptr")
    rc := Buffer(16, 0)
    NumPut("Int", 0, rc, 0)
    NumPut("Int", 0, rc, 4)
    NumPut("Int", w, rc, 8)
    NumPut("Int", h, rc, 12)
    DllCall("FillRect", "Ptr", hdc, "Ptr", rc, "Ptr", brushBg)
    DllCall("DeleteObject", "Ptr", brushBg)

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return

    DllCall("gdiplus\GdipSetSmoothingMode",     "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)

    ; ── SPEED LINES: líneas radiales blancas que aparecen brevemente al disparar acción ──
    global logoSpeedLinesUntil
    if (A_TickCount < logoSpeedLinesUntil) {
        cxS := w / 2.0
        cyS := h / 2.0
        progress := 1.0 - (logoSpeedLinesUntil - A_TickCount) / 200.0
        if (progress < 0)
            progress := 0
        if (progress > 1)
            progress := 1
        Loop 10 {
            angle := (A_Index - 1) * 36.0 + progress * 18
            rad := angle * 0.01745329
            innerR := 22 + progress * 12
            outerR := 38 + progress * 28
            x1 := cxS + Cos(rad) * innerR
            y1 := cyS + Sin(rad) * innerR
            x2 := cxS + Cos(rad) * outerR
            y2 := cyS + Sin(rad) * outerR
            alphaSL := Round((1.0 - progress) * 230)
            argbSL := (alphaSL << 24) | 0xFFFFFF
            penSL := 0
            DllCall("gdiplus\GdipCreatePen1", "UInt", argbSL, "Float", 2.0, "Int", 2, "Ptr*", &penSL)
            DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", penSL, "Float", x1, "Float", y1, "Float", x2, "Float", y2)
            DllCall("gdiplus\GdipDeletePen", "Ptr", penSL)
        }
    }

    ; ── MODO PREMIUM: glow arcoíris pulsante alrededor del gear ──
    global temaPremiumActivo, rgbBarraHue
    if (temaPremiumActivo) {
        cx := w / 2.0
        cy := h / 2.0
        ; Anillos concéntricos arcoíris, alpha decreciente hacia afuera
        Loop 5 {
            ring := A_Index
            radio := 28.0 + ring * 3.5
            hueRing := Mod(rgbBarraHue * 4 + ring * 60, 360)
            cHex := HSVaHex(hueRing, 1.0, 1.0)
            rI := Integer("0x" SubStr(cHex, 1, 2))
            gI := Integer("0x" SubStr(cHex, 3, 2))
            bI := Integer("0x" SubStr(cHex, 5, 2))
            alphaRing := Round(180 / ring)
            argbRing := (alphaRing << 24) | (rI << 16) | (gI << 8) | bI
            penRing := 0
            DllCall("gdiplus\GdipCreatePen1", "UInt", argbRing, "Float", 2.5, "Int", 2, "Ptr*", &penRing)
            DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", penRing, "Float", cx - radio, "Float", cy - radio, "Float", radio * 2, "Float", radio * 2)
            DllCall("gdiplus\GdipDeletePen", "Ptr", penRing)
        }
        ; Forzar color del gear a un hue cíclico vivo (no usa colorHex del tema)
        colorHex := HSVaHex(Mod(rgbBarraHue * 2, 360), 1.0, 1.0)
    }

    ; Usar handles cacheados (creados una sola vez en InicializarGdip).
    ; Antes esta función creaba y destruía el font family + font cada frame (20 DllCalls
    ; extra/segundo a 20fps). Ahora los reutilizamos.
    global logoFontFamily, logoGearFont
    family := logoFontFamily
    font := logoGearFont
    fontWasLocal := false

    ; Fallback defensivo: si por algún motivo no están cacheados, crearlos local (no debería pasar).
    if (!family) {
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI Symbol", "Ptr", 0, "Ptr*", &family)
        if (!family)
            DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Arial", "Ptr", 0, "Ptr*", &family)
        fontWasLocal := true
    }
    if (family && !font) {
        DllCall("gdiplus\GdipCreateFont", "Ptr", family, "Float", 58, "Int", 1, "Int", 0, "Ptr*", &font)
        fontWasLocal := true
    }

    if (family) {
        if (font) {
            ; Medir el centro visual real del glifo una sola vez y cachearlo.
            ; GdipMeasureString con alineación top-left devuelve el bounding box real
            ; del carácter, cuyo centro puede no coincidir con el centro tipográfico.
            if (gearCX = "") {
                mFmt := 0
                DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &mFmt)
                DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", mFmt, "Int", 0)
                DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", mFmt, "Int", 0)
                bigR := Buffer(16, 0)
                NumPut("Float", 0.0, bigR, 0)
                NumPut("Float", 0.0, bigR, 4)
                NumPut("Float", 1000.0, bigR, 8)
                NumPut("Float", 1000.0, bigR, 12)
                bb := Buffer(16, 0)
                cp := 0, ln := 0
                DllCall("gdiplus\GdipMeasureString", "Ptr", g, "WStr", charLogo, "Int", StrLen(charLogo),
                        "Ptr", font, "Ptr", bigR, "Ptr", mFmt, "Ptr", bb, "Int*", &cp, "Int*", &ln)
                DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", mFmt)
                gearCX := NumGet(bb, 0, "Float") + NumGet(bb, 8, "Float") / 2.0
                gearCY := NumGet(bb, 4, "Float") + NumGet(bb, 12, "Float") / 2.0
            }

            ; Desplazar el dibujo para que el centro real del glifo quede en (w/2, h/2)
            drawX := w / 2.0 - gearCX
            drawY := h / 2.0 - gearCY

            ; Glitch de modo destruccion: desplazar y forzar rojo
            global logoGlitchActivo, logoGlitchOffX, logoGlitchOffY
            global logoTrailAngulos, logoVelActual
            glitching := logoGlitchActivo
            if (glitching) {
                drawX += logoGlitchOffX
                drawY += logoGlitchOffY
                colorHex := "FF1100"
            }

            cRgb  := Integer("0x" colorHex)
            cArgb := 0xFF000000 | cRgb
            brushG := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", cArgb, "Ptr*", &brushG)

            fmt := 0
            DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &fmt)
            DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", fmt, "Int", 0)
            DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", fmt, "Int", 0)

            drawRect := Buffer(16, 0)
            NumPut("Float", drawX,          drawRect,  0)
            NumPut("Float", drawY,          drawRect,  4)
            NumPut("Float", gearCX * 2.0 + 20.0, drawRect,  8)
            NumPut("Float", gearCY * 2.0 + 20.0, drawRect, 12)

            ; ── Motion blur trail (dos copias desvanecidas en ángulos anteriores) ──
            if (!glitching && Abs(logoVelActual) > 1.5) {
                trailAngles := [logoTrailAngulos[1], logoTrailAngulos[2]]
                trailAlphas := [0x28, 0x55]
                loop 2 {
                    tArgb := (trailAlphas[A_Index] << 24) | cRgb
                    tBrush := 0
                    DllCall("gdiplus\GdipCreateSolidFill", "UInt", tArgb, "Ptr*", &tBrush)
                    tRc := Buffer(16, 0)
                    NumPut("Float", drawX,                tRc,  0)
                    NumPut("Float", drawY,                tRc,  4)
                    NumPut("Float", gearCX * 2.0 + 20.0, tRc,  8)
                    NumPut("Float", gearCY * 2.0 + 20.0, tRc, 12)
                    DllCall("gdiplus\GdipResetWorldTransform",     "Ptr", g)
                    DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float",  w/2.0, "Float",  h/2.0, "Int", 0)
                    DllCall("gdiplus\GdipRotateWorldTransform",    "Ptr", g, "Float",  trailAngles[A_Index], "Int", 0)
                    DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", -w/2.0, "Float", -h/2.0, "Int", 0)
                    DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", charLogo, "Int", StrLen(charLogo), "Ptr", font, "Ptr", tRc, "Ptr", fmt, "Ptr", tBrush)
                    DllCall("gdiplus\GdipDeleteBrush", "Ptr", tBrush)
                }
            }

            ; ── Rotar para el dibujo principal ──
            DllCall("gdiplus\GdipResetWorldTransform",     "Ptr", g)
            DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float",  w/2.0, "Float",  h/2.0, "Int", 0)
            DllCall("gdiplus\GdipRotateWorldTransform",    "Ptr", g, "Float",  angulo,                  "Int", 0)
            DllCall("gdiplus\GdipTranslateWorldTransform", "Ptr", g, "Float", -w/2.0, "Float", -h/2.0, "Int", 0)

            ; Ghost rojo semi-transparente desplazado (efecto glitch cromático)
            if (glitching) {
                ghostBrush := 0
                DllCall("gdiplus\GdipCreateSolidFill", "UInt", 0x66CC0000, "Ptr*", &ghostBrush)
                ghostRc := Buffer(16, 0)
                NumPut("Float", drawX - logoGlitchOffX * 2.5, ghostRc,  0)
                NumPut("Float", drawY - logoGlitchOffY * 2.5, ghostRc,  4)
                NumPut("Float", gearCX * 2.0 + 20.0,          ghostRc,  8)
                NumPut("Float", gearCY * 2.0 + 20.0,          ghostRc, 12)
                DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", charLogo, "Int", StrLen(charLogo), "Ptr", font, "Ptr", ghostRc, "Ptr", fmt, "Ptr", ghostBrush)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", ghostBrush)
            }

            ; ── DIBUJO PRINCIPAL DEL ENGRANAJE ──
            ; Usar BitBlt del bitmap pre-renderizado SIEMPRE que sea posible.
            ; El dibujo en vivo con GdipDrawString rotado introduce subpixel drift
            ; entre frames → el logo se ve descentrado/oscilante.
            ;
            ; Cuando activo=true el color pulsa cada frame, pero invalidar el cache
            ; cada tick es muy caro (rebuilds 32 bitmaps). Solución: cuando activo,
            ; IGNORAMOS el pulso de color y usamos el cache con el color BASE.
            ; El pulso visual ya se ve a través de la barra y las luces — el gear no
            ; necesita pulsar de color, solo girar suavemente.
            global logoGearCache, logoGearCacheColor, logoGearCacheChar, LOGO_GEAR_CACHE_FRAMES, temaPremiumActivo
            global activo, rgbLogo, temaEnTransicion, colorLogoMacro
            global logoGearCacheW, logoGearCacheH

            ; Solo bloqueamos el cache en modos VISUALMENTE incompatibles (color por
            ; pixel distinto cada frame que no se puede pre-renderizar):
            ;  - rgbLogo → color cicla con RGB cada frame
            ;  - premium → anillos arcoíris animados encima del gear
            ;  - glitching → desplazamiento + color rojo distinto cada glitch
            ;  - temaEnTransicion → colorLogoEnTransicion lerpea cada frame
            ;  - noRota → ∞/⛩ no giran nunca, no tiene sentido cachear 128/256
            ;    bitmaps que nunca se usan: se dibuja directo (1 GdipDrawString/frame).
            noRota := (charLogo = Chr(0x221E) || charLogo = Chr(0x26E9))
            puedeCachear := !rgbLogo && !temaPremiumActivo && !glitching && !temaEnTransicion && !noRota

            ; Cuando activo, ignorar el pulso de color y cachear con el color base estable.
            colorParaCache := activo ? colorLogoMacro : colorHex
            global logoGearCacheFramesReales
            ; OJO con w/h: el logo principal pide 95x95 y el mini 80x80. Si NO se
            ; comprueba el tamaño, el mini reusa el cache de 95 recortado a 80 →
            ; el engranaje sale desplazado (lo que se veía como "sombra" arriba-izq).
            canUseCache := puedeCachear && (logoGearCache.Length > 0) && (logoGearCache.Length = logoGearCacheFramesReales) && (logoGearCacheColor = colorParaCache) && (logoGearCacheChar = charLogo) && (logoGearCacheW = w) && (logoGearCacheH = h)

            ; Si podemos cachear pero el color cambió (o no hay cache), construirlo ahora
            if (!canUseCache && puedeCachear) {
                if (ConstruirCacheGear(colorParaCache, w, h)) {
                    canUseCache := true
                }
            }

            if (canUseCache) {
                ; Calcular qué frame del cache usar — el span depende de la simetría del char.
                ; ⚙ → 45° (32 frames), ∞ → 180° (128 frames), ⛩ → 360° (256 frames).
                ; Mantenemos ~1.4° por frame en todos los casos para igual fluidez.
                global logoGearCacheAngleSpan
                span := logoGearCacheAngleSpan
                if (span <= 0)
                    span := 45.0
                nFrames := logoGearCacheFramesReales
                angWrap := Mod(angulo, span)
                if (angWrap < 0)
                    angWrap += span
                idx := Mod(Round(angWrap * nFrames / span), nFrames) + 1
                hbmCached := logoGearCache[idx]
                if (hbmCached) {
                    ; AlphaBlend respeta el alpha por pixel del bitmap PARGB
                    DllCall("gdiplus\GdipFlush", "Ptr", g, "Int", 1)
                    hdcMem := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
                    oldBmp := DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbmCached, "Ptr")
                    blendFn := Buffer(4, 0)
                    NumPut("UChar", 0,   blendFn, 0)   ; BlendOp = AC_SRC_OVER
                    NumPut("UChar", 0,   blendFn, 1)   ; BlendFlags
                    NumPut("UChar", 255, blendFn, 2)   ; SourceConstantAlpha
                    NumPut("UChar", 1,   blendFn, 3)   ; AlphaFormat = AC_SRC_ALPHA
                    DllCall("Msimg32\AlphaBlend",
                        "Ptr",  hdc,
                        "Int",  0, "Int", 0, "Int", w, "Int", h,
                        "Ptr",  hdcMem,
                        "Int",  0, "Int", 0, "Int", w, "Int", h,
                        "UInt", NumGet(blendFn, 0, "UInt"))
                    DllCall("SelectObject", "Ptr", hdcMem, "Ptr", oldBmp)
                    DllCall("DeleteDC", "Ptr", hdcMem)
                }
            } else {
                ; Fallback: dibujo en vivo (premium, glitch, o cache no disponible)
                DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", charLogo, "Int", StrLen(charLogo), "Ptr", font, "Ptr", drawRect, "Ptr", fmt, "Ptr", brushG)
            }

            DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmt)
            if (brushG)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushG)
            ; Solo destruir font/family si los creamos local en este frame (fallback).
            ; Si vinieron del cache global, NO se tocan — se reutilizan eternamente.
            if (fontWasLocal && font)
                DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
        }
        if (fontWasLocal && family)
            DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", family)
    }

    ; ── GOJO: punto de luz viajando por el ∞ (Limitless) ──
    ; Se pinta encima del glifo estático. Solo cuando el logo es ∞.
    if (charLogo = Chr(0x221E))
        PintarInfinityTraveler(g, w, h)

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

; Punto de luz (con estela) que recorre la lemniscata ∞ de Gerono, escalada
; al glifo del logo. Da vida al logo de Gojo sin girarlo — como energía
; maldita recorriendo el Infinito. Fase basada en tiempo real (framerate-indep).
PintarInfinityTraveler(g, w, h) {
    cx := w / 2.0
    cy := h / 2.0
    A  := w * 0.23    ; semi-ancho del 8 (ajustado al glifo ∞)
    B  := h * 0.125   ; semi-alto del 8
    base := A_TickCount / 1000.0 * 1.6   ; velocidad de recorrido (rad/s)

    ; Estela: varios puntos detrás de la cabeza, alpha/tamaño decreciente.
    nTrail := 9
    Loop nTrail {
        k := A_Index - 1
        t := base - k * 0.085
        ; Lemniscata de Gerono (figura-8 horizontal = ∞)
        px := cx + A * Cos(t)
        py := cy + B * Sin(t) * Cos(t)
        if (k = 0) {
            ; Cabeza: glow cyan + núcleo blanco brillante
            argbGlow := (110 << 24) | 0x4FC3F7
            brG := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbGlow, "Ptr*", &brG)
            rg := 6.5
            DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brG, "Float", px - rg, "Float", py - rg, "Float", rg * 2, "Float", rg * 2)
            DllCall("gdiplus\GdipDeleteBrush", "Ptr", brG)
            brC := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", 0xFFFFFFFF, "Ptr*", &brC)
            rc := 2.8
            DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brC, "Float", px - rc, "Float", py - rc, "Float", rc * 2, "Float", rc * 2)
            DllCall("gdiplus\GdipDeleteBrush", "Ptr", brC)
        } else {
            frac := 1.0 - k / nTrail
            alpha := Round(170 * frac)
            if (alpha < 15)
                continue
            argb := (alpha << 24) | 0x4FC3F7
            br := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
            r := 1.2 + 2.3 * frac
            DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", br, "Float", px - r, "Float", py - r, "Float", r * 2, "Float", r * 2)
            DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
        }
    }
}

; Calcula el color final del engranaje para el frame actual (base + pulso + flash + transición/RGB).
ColorActualLogo() {
    global colorLogoMacro, activo, rgbLogo, colorRGBActual, logoFlashUntil
    global colorLogoEnTransicion, temaEnTransicion, logosPulsoT

    if (temaEnTransicion && colorLogoEnTransicion != "")
        baseColor := colorLogoEnTransicion
    else if (rgbLogo)
        baseColor := colorRGBActual
    else
        baseColor := colorLogoMacro

    color := baseColor
    if (activo) {
        rL := Integer("0x" SubStr(baseColor, 1, 2))
        gL := Integer("0x" SubStr(baseColor, 3, 2))
        bL := Integer("0x" SubStr(baseColor, 5, 2))
        delta := Round(55 * Sin(logosPulsoT * 3.14159))
        rN := Max(0, Min(255, rL + delta))
        gN := Max(0, Min(255, gL + delta))
        bN := Max(0, Min(255, bL + delta))
        color := Format("{:02X}{:02X}{:02X}", rN, gN, bN)
    }
    if (A_TickCount < logoFlashUntil)
        color := "FFFFFF"
    return color
}

FondoActualLogo() {
    global colorFondoPrincipal, colorFondoEnTransicion, temaEnTransicion
    return (temaEnTransicion && colorFondoEnTransicion != "") ? colorFondoEnTransicion : colorFondoPrincipal
}

; Pinta el engranaje sobre un HDC con double buffering (memDC + BitBlt) — sin flicker visible.
PintarLogoEnDC(hdcDest) {
    global logoAngulo

    memDC  := DllCall("CreateCompatibleDC",     "Ptr", hdcDest, "Ptr")
    hbm    := DllCall("CreateCompatibleBitmap", "Ptr", hdcDest, "Int", 95, "Int", 95, "Ptr")
    oldBmp := DllCall("SelectObject",           "Ptr", memDC, "Ptr", hbm, "Ptr")

    DibujarGearEnDC(memDC, 95, 95, logoAngulo, ColorActualLogo(), FondoActualLogo())

    ; SRCCOPY = 0x00CC0020
    DllCall("BitBlt", "Ptr", hdcDest, "Int", 0, "Int", 0, "Int", 95, "Int", 95, "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)

    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC",     "Ptr", memDC)
}

; Pinta vía GetDC (usado por el timer durante animación).
PintarLogo() {
    global logoMacro, modoMini, logoMacroMini
    ; En mini mode el logo principal está OCULTO. Pintarlo igual (a 95x95)
    ; reconstruiría el cache de engranaje a 95 cada frame, y el mini (80) lo
    ; reconstruiría a 80 el frame siguiente → thrash + desfase. Solo pintar el mini.
    if (modoMini) {
        if (IsObject(logoMacroMini)) {
            hdcMini := DllCall("GetDC", "Ptr", logoMacroMini.Hwnd, "Ptr")
            if (hdcMini) {
                PintarLogoMiniEnDC(hdcMini)
                DllCall("ReleaseDC", "Ptr", logoMacroMini.Hwnd, "Ptr", hdcMini)
            }
        }
        return
    }
    if (!IsObject(logoMacro))
        return
    hdc := DllCall("GetDC", "Ptr", logoMacro.Hwnd, "Ptr")
    if (!hdc)
        return
    PintarLogoEnDC(hdc)
    DllCall("ReleaseDC", "Ptr", logoMacro.Hwnd, "Ptr", hdc)
}

; ── Subclass del control: intercepta WM_PAINT y WM_ERASEBKGND para que cuando Windows
;    repinte el control (por movimiento de ventana, foco, etc.) el engranaje aparezca
;    de inmediato — sin esperar al siguiente tick del timer. Esto mata el flicker entre tics.
global logoSubclassCb := 0

LogoSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND) {
        ; No borrar el fondo: pintamos todo en WM_PAINT
        return 1
    }
    if (uMsg = WM_PAINT) {
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            PintarLogoEnDC(hdc)
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

InstalarSubclassLogo() {
    global logoMacro, logoSubclassCb
    if (!IsObject(logoMacro) || logoSubclassCb)
        return
    logoSubclassCb := CallbackCreate(LogoSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", logoMacro.Hwnd, "Ptr", logoSubclassCb, "Ptr", 1, "Ptr", 0)
}

; ===== MINI MODE: logo compacto flotante =====
PintarLogoMiniEnDC(hdc) {
    global logoAngulo
    memDC  := DllCall("CreateCompatibleDC",     "Ptr", hdc, "Ptr")
    hbm    := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", 80, "Int", 80, "Ptr")
    oldBmp := DllCall("SelectObject",           "Ptr", memDC, "Ptr", hbm, "Ptr")
    DibujarGearEnDC(memDC, 80, 80, logoAngulo, ColorActualLogo(), FondoActualLogo())
    DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", 80, "Int", 80, "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC",     "Ptr", memDC)
}

MiniLogoSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND)
        return 1
    if (uMsg = WM_PAINT) {
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            PintarLogoMiniEnDC(hdc)
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

InstalarSubclassMiniLogo() {
    global logoMacroMini, miniSubclassCb
    if (!IsObject(logoMacroMini))
        return
    ; Callback único reutilizado entre recreaciones del mini (la ventana anterior
    ; ya fue destruida, así que basta con re-instalarlo sobre el control nuevo).
    if (!miniSubclassCb)
        miniSubclassCb := CallbackCreate(MiniLogoSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", logoMacroMini.Hwnd, "Ptr", miniSubclassCb, "Ptr", 2, "Ptr", 0)
}

ToggleMiniMode(*) {
    global modoMini, miGui, historialGui, historialVisible, miniGui, logoMacroMini, barraMini
    global colorFondoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto, colorLogoMacro
    global overlayPartMain, overlayPartHist, miniBarraSubclassCb
    global overlayPartMini, particulasMini, overlayDecoMini, overlayDecoraciones, configPath

    if (modoMini) {
        ; ── Salir de mini mode ──
        modoMini := false
        try IniWrite(0, configPath, "UI", "MiniMode")
        if (IsObject(overlayPartMini))
            try overlayPartMini.Destroy()
        overlayPartMini := ""
        if (IsObject(overlayDecoMini))
            try overlayDecoMini.Destroy()
        overlayDecoMini := ""
        try miniGui.Destroy()
        miniGui := ""
        logoMacroMini := ""
        barraMini := ""
        miGui.Show()
        if (historialVisible)
            historialGui.Show()
        if (IsObject(overlayPartMain))
            try overlayPartMain.Show()
        if (historialVisible && IsObject(overlayPartHist))
            try overlayPartHist.Show()
        ; Re-mostrar y reposicionar el overlay de decoraciones principal
        if (IsObject(overlayDecoraciones)) {
            try overlayDecoraciones.Show("NoActivate")
            ReposicionarOverlayDeco()
        }
        ; Al re-mostrar miGui los controles pueden quedar cuadrados → re-redondear.
        SetTimer(RestaurarRedondeoCompleto, -80)
        return
    }

    ; ── Entrar en mini mode ──
    modoMini := true
    try IniWrite(1, configPath, "UI", "MiniMode")
    miGui.GetPos(&mx, &my)
    miGui.Hide()
    historialGui.Hide()
    if (IsObject(overlayPartMain))
        try overlayPartMain.Hide()
    if (IsObject(overlayPartHist))
        try overlayPartHist.Hide()
    ; ★ Ocultar el overlay de decoraciones PRINCIPAL — si no, se queda pintando
    ;   los cortes/Six Eyes en el sitio donde estaba el macro grande.
    if (IsObject(overlayDecoraciones))
        try overlayDecoraciones.Hide()

    CrearMiniGui(mx, my)
}

CrearMiniGui(posX, posY) {
    global miniGui, logoMacroMini, barraMini, miniBarraSubclassCb
    global colorFondoPrincipal, colorBarra, colorTextoBarra, colorLogoMacro, colorBotonNormal, colorBtnTexto
    global overlayPartMini, particulasMini, particulasActivas
    global overlayDecoMini, overlayDecoMiniSubCb, DECO_COLORKEY_HEX, DECO_COLORKEY_BGR
    global btnMiniIniciar, btnMiniParar, btnMiniCerrar, btnMiniTema, rgbBotones, colorRGBActual
    global miniHistLabel, miniHistBuffer, colorTextoPrincipal
    global MINI_W, MINI_H, BAR_H, MINI_OVL_H
    static __init := (MINI_W := 120, MINI_H := 138, BAR_H := 25, MINI_OVL_H := 85)

    miniGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    miniGui.BackColor := colorFondoPrincipal

    ; Barra superior: arrastrar con un clic, DOBLE CLIC para volver a la ventana grande
    barraMini := miniGui.Add("Text", "x0 y0 w" MINI_W " h" BAR_H " Background" colorBarra " Center +0x201", "Smart")
    barraMini.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barraMini.OnEvent("Click", ArrastrarMiniVentana)
    barraMini.OnEvent("DoubleClick", ToggleMiniMode)   ; doble clic = restaurar ventana grande

    ; 🎨 Temas en la esquina izquierda debajo de la barra
    btnMiniTema := miniGui.Add("Text", "x2 y" (BAR_H + 2) " w10 h11 +0x201 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x1F3A8))
    btnMiniTema.SetFont("s6 c" colorTextoPrincipal, "Segoe UI Emoji")
    btnMiniTema.OnEvent("Click", AbrirPanelTemas)

    ; ✕ Cerrar en la esquina derecha debajo de la barra
    btnMiniCerrar := miniGui.Add("Text", "x" (MINI_W - 13) " y" (BAR_H + 2) " w10 h11 +0x201 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(215))
    btnMiniCerrar.SetFont("s6 c" colorTextoPrincipal " Bold", "Segoe UI")
    btnMiniCerrar.OnEvent("Click", Cerrar)
    ; WS_CLIPSIBLINGS en barraMini: su repintado (shimmer) taparía los botones sin esto
    estiloBarraMini := DllCall("GetWindowLong", "Ptr", barraMini.Hwnd, "Int", -16, "Int")
    DllCall("SetWindowLong", "Ptr", barraMini.Hwnd, "Int", -16, "Int", estiloBarraMini | 0x04000000)

    ; Logo giratorio — siempre el mismo carácter para rotación consistente y centrado perfecto
    ; y = BAR_H (antes BAR_H-3, que lo metía 3px dentro de la barra): bajado 3px.
    logoMacroMini := miniGui.Add("Text", "x15 y" BAR_H " w80 h80 Center BackgroundTrans c" colorLogoMacro " +0x1", Chr(9881))
    logoMacroMini.SetFont("s48 c" colorLogoMacro " Bold", "Segoe UI Symbol")
    InstalarSubclassMiniLogo()

    ; ── 2 botones pequeños centrados: ▶ Iniciar · ■ Parar ──
    btnMiniIniciar := miniGui.Add("Text", "x27 y114 w30 h18 +0x201 Center Background" colorBotonNormal " c" colorBtnTexto, Chr(9654))
    btnMiniParar   := miniGui.Add("Text", "x63 y114 w30 h18 +0x201 Center Background" colorBotonNormal " c" colorBtnTexto, Chr(9632))
    for b in [btnMiniIniciar, btnMiniParar]
        b.SetFont("s9 c" colorBtnTexto " Bold", "Segoe UI Symbol")
    btnMiniIniciar.OnEvent("Click", Iniciar)
    btnMiniParar.OnEvent("Click", Parar)
    RegistrarHover(btnMiniIniciar, () => (rgbBotones ? colorRGBActual : colorBotonNormal))
    RegistrarHover(btnMiniParar,   () => (rgbBotones ? colorRGBActual : colorBotonNormal),
                                   () => MezclarHex(colorCooldown, colorBotonNormal, 0.45))
    RegistrarHover(btnMiniTema,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
    RegistrarHover(btnMiniCerrar,  () => colorFondoPrincipal, () => "C42B1C")

    ; Instalar subclass de ondas en la barra mini (mismo efecto que la barra principal).
    ; El callback se crea UNA vez y se reutiliza en cada recreación del mini —
    ; antes se creaba uno nuevo por cambio de tema sin liberar el anterior (fuga).
    if (!miniBarraSubclassCb)
        miniBarraSubclassCb := CallbackCreate(BarraSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", barraMini.Hwnd, "Ptr", miniBarraSubclassCb, "Ptr", 10, "Ptr", 0)

    miniGui.Show("x" posX " y" posY " w" MINI_W " h" MINI_H)
    RedondearVentana(miniGui.Hwnd, 14)
    for _btn in [btnMiniIniciar, btnMiniParar]
        RedondearControl(_btn, 8)
    for _btn in [btnMiniTema, btnMiniCerrar]
        RedondearControl(_btn, 4)

    ; ── Overlay de partículas + escena (decoración pequeña) para mini ──
    ; El overlay solo cubre hasta encima de los botones (MINI_OVL_H), así la
    ; decoración no pinta sobre los botones de abajo.
    if (particulasActivas) {
        try WinSetStyle("+0x02000000", "ahk_id " miniGui.Hwnd)
        overlayPartMini := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
        overlayPartMini.Opt("+Owner" miniGui.Hwnd)
        overlayPartMini.Show("x" posX " y" (posY + BAR_H) " w" MINI_W " h" MINI_OVL_H " NoActivate")
        InicializarParticulas(particulasMini, MINI_W, MINI_OVL_H, 15)
    }

    ; ── Overlay de decoraciones (Sukuna slashes / Gojo aura) para mini ──
    overlayDecoMini := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
    overlayDecoMini.Opt("+Owner" miniGui.Hwnd)
    overlayDecoMini.BackColor := DECO_COLORKEY_HEX
    overlayDecoMini.Show("x" posX " y" (posY + BAR_H) " w" MINI_W " h" MINI_OVL_H " NoActivate")
    DllCall("SetLayeredWindowAttributes", "Ptr", overlayDecoMini.Hwnd, "UInt", DECO_COLORKEY_BGR, "UChar", 255, "UInt", 1)
    ; Callback único reutilizado entre recreaciones (antes fugaba uno por cambio de tema)
    if (!overlayDecoMiniSubCb)
        overlayDecoMiniSubCb := CallbackCreate(DecoOverlaySubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", overlayDecoMini.Hwnd, "Ptr", overlayDecoMiniSubCb, "Ptr", 27, "Ptr", 0)
}

ArrastrarMiniVentana(*) {
    PostMessage(0xA1, 2,,, "A")
}

; Timer: actualiza velocidad/ángulo/pulso y pinta el logo directamente sobre su DC.
ActualizarLogoAnimacion() {
    global activo, logoAngulo, logoVelActual, logoVelObjetivo, logoNeedsRedraw, optLogoGiratorio
    global logosPulsoT, logosPulsoDir
    global modoDestruccion, logoGlitchActivo, logoGlitchHasta, logoGlitchOffX, logoGlitchOffY
    global logoTrailAngulos

    if (!optLogoGiratorio) {
        logoVelActual := 0
        return
    }

    ; ── Logos que NO giran: ∞ (Gojo) y ⛩ (Sukuna) ──
    ; En vez de girar, se quedan estáticos. Gojo muestra un punto de luz que
    ; viaja por el infinito (se pinta en DibujarGearEnDC). Seguimos pintando
    ; cada tick para animar ese traveler + el pulso de brillo.
    charLogo := ObtenerCharLogo()
    if (charLogo = Chr(0x221E) || charLogo = Chr(0x26E9)) {
        logoVelObjetivo := 0
        logoVelActual := 0
        logoAngulo := 0
        ; Pulso de brillo sigue activo para que el logo "respire" al iniciar
        if (activo) {
            logosPulsoT += 0.05 * logosPulsoDir
            if (logosPulsoT >= 1.0) {
                logosPulsoT := 1.0
                logosPulsoDir := -1
            } else if (logosPulsoT <= 0.0) {
                logosPulsoT := 0.0
                logosPulsoDir := 1
            }
        }
        PintarLogo()
        logoNeedsRedraw := false
        return
    }

    ; Lerp suave de velocidad hacia el objetivo (aceleración/deceleración)
    diff := logoVelObjetivo - logoVelActual
    logoVelActual += diff * 0.06

    ; Snap a 0 cuando está muy cerca y el objetivo es 0
    if (logoVelObjetivo = 0 && Abs(logoVelActual) < 0.01)
        logoVelActual := 0

    ; Guardar ángulo actual en el trail (antes de avanzar)
    logoTrailAngulos[1] := logoTrailAngulos[2]
    logoTrailAngulos[2] := logoAngulo

    ; Avanzar ángulo
    if (logoVelActual != 0) {
        logoAngulo += logoVelActual
        while (logoAngulo >= 360)
            logoAngulo -= 360
        while (logoAngulo < 0)
            logoAngulo += 360
    }

    ; Avanzar pulso de brillo si activo
    if (activo) {
        logosPulsoT += 0.05 * logosPulsoDir
        if (logosPulsoT >= 1.0) {
            logosPulsoT := 1.0
            logosPulsoDir := -1
        } else if (logosPulsoT <= 0.0) {
            logosPulsoT := 0.0
            logosPulsoDir := 1
        }
    }

    ; Glitch periódico cuando destruccion activa
    if (modoDestruccion && A_TickCount > logoGlitchHasta) {
        logoGlitchActivo := true
        logoGlitchOffX := Random(-5, 5)
        logoGlitchOffY := Random(-3, 3)
        logoGlitchHasta := A_TickCount + 130
        SetTimer(() => (logoGlitchActivo := false), -130)
    }

    ; ── MODO PREMIUM: logo gira siempre rápido ──
    global temaPremiumActivo, logoVelMax
    if (temaPremiumActivo) {
        logoVelObjetivo := logoVelMax * 1.8
    }

    ; Siempre pintar — más simple y robusto que decidir cuándo
    PintarLogo()
    logoNeedsRedraw := false
}

; ===== BARRAS CON GRADIENTE Y ONDA (GDI+) =====
DibujarBarraGradiente(hdc, w, h, hexBase, hexTexto, texto, phase, brillo) {
    global gdipInited, temaPremiumActivo, rgbBarraHue
    memDC := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hbm   := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr")
    oldBmp := DllCall("SelectObject", "Ptr", memDC, "Ptr", hbm, "Ptr")

    ; Color base + brillo aditivo (clamp)
    rB := Max(0, Min(255, Integer("0x" SubStr(hexBase, 1, 2)) + brillo))
    gB := Max(0, Min(255, Integer("0x" SubStr(hexBase, 3, 2)) + brillo))
    bB := Max(0, Min(255, Integer("0x" SubStr(hexBase, 5, 2)) + brillo))

    if (gdipInited) {
        g := 0
        DllCall("gdiplus\GdipCreateFromHDC", "Ptr", memDC, "Ptr*", &g)
        if (g) {
            DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
            DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)

            if (temaPremiumActivo) {
                ; ── MODO PREMIUM: arcoíris vivo desplazándose horizontalmente ──
                cols := 50
                colW := w * 1.0 / cols
                Loop cols {
                    j := A_Index - 1
                    hueCol := Mod(rgbBarraHue * 2 + (j / cols) * 360, 360)
                    cHex := HSVaHex(hueCol, 1.0, 0.95)
                    rI := Integer("0x" SubStr(cHex, 1, 2))
                    gI := Integer("0x" SubStr(cHex, 3, 2))
                    bI := Integer("0x" SubStr(cHex, 5, 2))
                    argbC := 0xFF000000 | (rI << 16) | (gI << 8) | bI
                    brushC := 0
                    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbC, "Ptr*", &brushC)
                    DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brushC, "Float", j * colW, "Float", 0, "Float", colW + 1, "Float", h)
                    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushC)
                }

                ; Banda de brillo blanca moviéndose encima (efecto destello)
                bandaW := w * 0.30
                cols2 := 22
                colW2 := bandaW / cols2
                offset := Mod(phase, 1.0)
                cx := (offset * (w + bandaW)) - bandaW / 2
                Loop cols2 {
                    j := A_Index - 1
                    tCol := j / cols2
                    d := (tCol - 0.5) * 2
                    gauss := Exp(-d * d * 4)
                    alpha := Round(gauss * 75)
                    if (alpha < 4)
                        continue
                    argbHi := (alpha << 24) | 0x00FFFFFF
                    brushHi := 0
                    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbHi, "Ptr*", &brushHi)
                    xRect := cx + j * colW2
                    DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brushHi, "Float", xRect, "Float", 0, "Float", colW2 + 1, "Float", h)
                    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushHi)
                }
                DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
            } else {
                ; Fondo base
                cBaseArgb := 0xFF000000 | (rB << 16) | (gB << 8) | bB
                brushBase := 0
                DllCall("gdiplus\GdipCreateSolidFill", "UInt", cBaseArgb, "Ptr*", &brushBase)
                DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brushBase, "Float", 0, "Float", 0, "Float", w, "Float", h)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushBase)

                ; Bandas de brillo (3 fases desplazadas) — gauss columna a columna.
                ; Color de la banda: el propio color de la barra aclarado hacia blanco
                ; (antes blanco puro fijo — chocaba como un tajo ajeno en temas oscuros).
                brilloHex := AclararHex(hexBase, 0.7)
                rBr := Integer("0x" SubStr(brilloHex, 1, 2))
                gBr := Integer("0x" SubStr(brilloHex, 3, 2))
                bBr := Integer("0x" SubStr(brilloHex, 5, 2))
                rgbBrillo := (rBr << 16) | (gBr << 8) | bBr
                bandaW := w * 0.40
                cols := 26
                colW := bandaW / cols
                Loop 3 {
                    i := A_Index - 1
                    offset := Mod(phase + i * 0.33, 1.0)
                    cx := (offset * (w + bandaW)) - bandaW / 2
                    Loop cols {
                        j := A_Index - 1
                        tCol := j / cols
                        d := (tCol - 0.5) * 2
                        gauss := Exp(-d * d * 4)
                        alpha := Round(gauss * 50)
                        if (alpha > 255)
                            alpha := 255
                        if (alpha < 4)
                            continue
                        argbHi := (alpha << 24) | rgbBrillo
                        brushHi := 0
                        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbHi, "Ptr*", &brushHi)
                        xRect := cx + j * colW
                        DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brushHi, "Float", xRect, "Float", 0, "Float", colW + 1, "Float", h)
                        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushHi)
                    }
                }

                ; Línea inferior fina más oscura para dar grosor
                rD := Round(rB * 0.55)
                gD := Round(gB * 0.55)
                bD := Round(bB * 0.55)
                argbD := 0x80000000 | (rD << 16) | (gD << 8) | bD
                brushD := 0
                DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbD, "Ptr*", &brushD)
                DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brushD, "Float", 0, "Float", h - 2, "Float", w, "Float", 2)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushD)

                DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
            }
        }
    } else {
        ; Fallback GDI puro si Gdip no inicializado
        brushBg := DllCall("CreateSolidBrush", "UInt", (bB << 16) | (gB << 8) | rB, "Ptr")
        rcBg := Buffer(16, 0)
        NumPut("Int", 0, rcBg, 0), NumPut("Int", 0, rcBg, 4), NumPut("Int", w, rcBg, 8), NumPut("Int", h, rcBg, 12)
        DllCall("FillRect", "Ptr", memDC, "Ptr", rcBg, "Ptr", brushBg)
        DllCall("DeleteObject", "Ptr", brushBg)
    }

    ; Texto centrado (GDI)
    if (texto != "") {
        fontH := (h >= 24) ? -16 : -14
        hFont := DllCall("CreateFont", "Int", fontH, "Int", 0, "Int", 0, "Int", 0,
            "Int", 700, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 1,
            "UInt", 0, "UInt", 0, "UInt", 4, "UInt", 0, "Str", "Segoe UI Semibold", "Ptr")
        oldFont := DllCall("SelectObject", "Ptr", memDC, "Ptr", hFont, "Ptr")
        DllCall("SetBkMode", "Ptr", memDC, "Int", 1)
        rTxt := Integer("0x" SubStr(hexTexto, 1, 2))
        gTxt := Integer("0x" SubStr(hexTexto, 3, 2))
        bTxt := Integer("0x" SubStr(hexTexto, 5, 2))
        sz := Buffer(8, 0)
        DllCall("GetTextExtentPoint32", "Ptr", memDC, "Str", texto, "Int", StrLen(texto), "Ptr", sz)
        txtW := NumGet(sz, 0, "Int")
        txtH := NumGet(sz, 4, "Int")
        xTxt := (w - txtW) // 2
        yTxt := (h - txtH) // 2

        if (temaPremiumActivo) {
            ; ── Texto letra por letra con colores del arcoíris cambiantes ──
            xCur := xTxt
            chars := StrSplit(texto)
            for i, ch in chars {
                hueChar := Mod(rgbBarraHue * 2 + (i - 1) * 28, 360)
                cHex := HSVaHex(hueChar, 1.0, 1.0)
                rPi := Integer("0x" SubStr(cHex, 1, 2))
                gPi := Integer("0x" SubStr(cHex, 3, 2))
                bPi := Integer("0x" SubStr(cHex, 5, 2))
                DllCall("SetTextColor", "Ptr", memDC, "UInt", (bPi << 16) | (gPi << 8) | rPi)
                DllCall("TextOut", "Ptr", memDC, "Int", xCur, "Int", yTxt, "Str", ch, "Int", StrLen(ch))
                szCh := Buffer(8, 0)
                DllCall("GetTextExtentPoint32", "Ptr", memDC, "Str", ch, "Int", StrLen(ch), "Ptr", szCh)
                xCur += NumGet(szCh, 0, "Int")
            }
        } else {
            DllCall("SetTextColor", "Ptr", memDC, "UInt", (bTxt << 16) | (gTxt << 8) | rTxt)
            DllCall("TextOut", "Ptr", memDC, "Int", xTxt, "Int", yTxt, "Str", texto, "Int", StrLen(texto))
        }
        DllCall("SelectObject", "Ptr", memDC, "Ptr", oldFont)
        DllCall("DeleteObject", "Ptr", hFont)
    }

    DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", memDC)
}

BarraSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND)
        return 1
    if (uMsg = WM_PAINT) {
        global barraGradPhase, colorBarra, colorTextoBarra, colorBarraOverride, barraExtraBrillo
        global rgbBarra, colorRGBActual
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            rc := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", hWnd, "Ptr", rc)
            w := NumGet(rc, 8, "Int")
            h := NumGet(rc, 12, "Int")
            len := DllCall("GetWindowTextLength", "Ptr", hWnd, "Int") + 1
            buf := Buffer(len * 2, 0)
            DllCall("GetWindowText", "Ptr", hWnd, "Ptr", buf, "Int", len)
            texto := StrGet(buf)
            ; Precedencia: flashOverride > rgbBarra > colorBarra
            if (colorBarraOverride != "") {
                base := colorBarraOverride
                txtCol := colorTextoBarra
            } else if (rgbBarra) {
                base := colorRGBActual
                txtCol := "000000"
            } else {
                base := colorBarra
                txtCol := colorTextoBarra
            }
            DibujarBarraGradiente(hdc, w, h, base, txtCol, texto, barraGradPhase, barraExtraBrillo)
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

InstalarSubclassBarras() {
    global barra, barraHistorial, barraSubclassCbM, barraSubclassCbH
    if (!barraSubclassCbM && IsObject(barra)) {
        barraSubclassCbM := CallbackCreate(BarraSubclassProc, "F", 6)
        DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", barra.Hwnd, "Ptr", barraSubclassCbM, "Ptr", 10, "Ptr", 0)
    }
    if (!barraSubclassCbH && IsObject(barraHistorial)) {
        barraSubclassCbH := CallbackCreate(BarraSubclassProc, "F", 6)
        DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", barraHistorial.Hwnd, "Ptr", barraSubclassCbH, "Ptr", 10, "Ptr", 0)
    }
}

AnimarBarras() {
    global barraGradPhase, barra, barraHistorial, barraMini, modoMini, activo, temaEnTransicion, optShimmerBarra
    if (temaEnTransicion || !optShimmerBarra)
        return
    vel := activo ? 0.013 : 0.005
    barraGradPhase += vel
    if (barraGradPhase >= 1000)
        barraGradPhase -= 1000
    if (IsObject(barra))
        DllCall("InvalidateRect", "Ptr", barra.Hwnd, "Ptr", 0, "Int", 0)
    if (IsObject(barraHistorial))
        DllCall("InvalidateRect", "Ptr", barraHistorial.Hwnd, "Ptr", 0, "Int", 0)
    if (modoMini && IsObject(barraMini))
        DllCall("InvalidateRect", "Ptr", barraMini.Hwnd, "Ptr", 0, "Int", 0)
}

; ===== PARTICULAS DE FONDO (GDI+) =====
global particulasMain := [], particulasHist := []
global miGuiPartCb := 0, histGuiPartCb := 0
global particulasInited := false
global overlayPartMain := "", overlayPartHist := ""

; ═══════════════════════════════════════════════════════════════
; EFECTOS DE PARTÍCULA POR TEMA — cada tema tiene su propio "detalle"
; ═══════════════════════════════════════════════════════════════
EfectoDeTema(t) {
    ; Efecto elegido a mano (tema personalizado): tiene prioridad sobre todo.
    if (t.HasProp("efAccion") && t.efAccion != "")
        return t.efAccion
    ; Secretos identificables por su unlock (nombres con espacios entre letras)
    if (t.HasProp("unlock")) {
        switch t.unlock {
            case "gojo":    return "estrellas"
            case "sukuna":  return "brasas"
            case "cosmos":  return "estrellas"
            case "void":    return "estrellas"
            case "solar":   return "brasas"     ; Fénix
            case "blanco":  return "chispas"    ; Nika
            case "shadow":  return "estrellas"  ; Eclipse
            case "premium": return "chispas"
        }
    }
    n := t.nombre
    ; Mapeo por nombre (substring). El orden es la prioridad. Lo que no encaje
    ; aquí se infiere por color más abajo, así que TODOS los temas tienen efecto.
    pares := [
        ["Matrix","matrix"], ["Glitch","matrix"], ["Cyberpunk","matrix"], ["Cyber","matrix"], ["Neon","matrix"],
        ["Naruto","hojas"], ["Minecraft","hojas"], ["Bosque","hojas"], ["Jungla","hojas"], ["Bamb","hojas"], ["Verde","hojas"],
        ["One Piece","burbujas"], ["Agua","burbujas"], ["Océano","burbujas"], ["Submarino","burbujas"], ["Tropical","burbujas"], ["Profundo","burbujas"], ["Discord","burbujas"],
        ["Sky","nieve"], ["Hielo","nieve"], ["Polar","nieve"], ["Tundra","nieve"], ["Nube","nieve"],
        ["Pok","chispas"], ["Brawl","chispas"], ["Valorant","chispas"], ["Spotify","chispas"], ["Dorado","chispas"], ["Miel","chispas"], ["Mostaza","chispas"], ["Electrico","chispas"],
        ["Retrowave","estrellas"], ["Noche","estrellas"], ["Aurora","estrellas"], ["Abismo","estrellas"],
        ["Sakura","petalos"], ["Rosa","petalos"], ["Lavanda","petalos"], ["Lila","petalos"], ["Chicle","petalos"], ["Vino","petalos"],
        ["Magma","brasas"], ["Sangre","brasas"]
    ]
    for par in pares {
        if (InStr(n, par[1]))
            return par[2]
    }
    ; Resto: inferir del color de la paleta
    return InferirEfectoPorColor(t)
}

; Deriva un efecto del color de acento (barra) + si el fondo es oscuro.
InferirEfectoPorColor(t) {
    acc := t.barra
    r := Integer("0x" SubStr(acc, 1, 2)), g := Integer("0x" SubStr(acc, 3, 2)), b := Integer("0x" SubStr(acc, 5, 2))
    fr := Integer("0x" SubStr(t.fondo, 1, 2)), fg := Integer("0x" SubStr(t.fondo, 3, 2)), fb := Integer("0x" SubStr(t.fondo, 5, 2))
    oscuro := ((fr * 299 + fg * 587 + fb * 114) / 1000) < 110
    mx := Max(r, g, b), mn := Min(r, g, b), d := mx - mn
    sat := (mx = 0) ? 0 : d / mx
    if (d = 0)
        h := 0
    else if (mx = r)
        h := Mod(60 * (((g - b) / d) + 6), 360)
    else if (mx = g)
        h := 60 * (((b - r) / d) + 2)
    else
        h := 60 * (((r - g) / d) + 4)
    if (sat < 0.18)
        return oscuro ? "estrellas" : "nieve"
    if (h < 35 || h >= 330)
        return "brasas"
    if (h < 65)
        return "chispas"
    if (h < 165)
        return oscuro ? "matrix" : "hojas"
    if (h < 200)
        return "burbujas"
    if (h < 255)
        return oscuro ? "estrellas" : "nieve"
    return "petalos"
}

InicializarParticulas(arr, w, h, n := 35) {
    global particulasCantidad, particulasVelocidad, particulasTamano, particulasOpacidad
    global temas, temaActual
    while (arr.Length > 0)
        arr.Pop()
    ef := EfectoDeTema(temas[temaActual])
    realN := Max(0, Round(n * particulasCantidad / 100))
    factorVel := particulasVelocidad / 100
    factorTam := particulasTamano / 100
    factorAlpha := particulasOpacidad / 100
    loop realN {
        ; Defaults (efecto "default" — flotación suave en cualquier dirección)
        vx := (Random(-100, 100) / 500.0) * factorVel
        vy := (Random(-100, 100) / 650.0) * factorVel
        rr := (Random(20, 45) / 10.0) * factorTam
        al := Min(255, Round(Random(45, 110) * factorAlpha))
        switch ef {
            case "nieve":
                vx := (Random(-40, 40) / 500.0) * factorVel
                vy := (Random(30, 90) / 300.0) * factorVel       ; cae despacio
                rr := (Random(15, 35) / 10.0) * factorTam
                al := Min(255, Round(Random(120, 210) * factorAlpha))
            case "brasas":
                vx := (Random(-30, 30) / 600.0) * factorVel
                vy := -(Random(40, 110) / 300.0) * factorVel      ; sube
                rr := (Random(10, 24) / 10.0) * factorTam
                al := Min(255, Round(Random(120, 220) * factorAlpha))
            case "estrellas", "chispas":
                vx := (Random(-15, 15) / 900.0) * factorVel       ; casi quietas (titilan)
                vy := (Random(-15, 15) / 900.0) * factorVel
                rr := (Random(8, 20) / 10.0) * factorTam
                al := Min(255, Round(Random(70, 170) * factorAlpha))
            case "lluvia":
                vx := 0.0
                vy := (Random(120, 240) / 300.0) * factorVel      ; cae rápido
                rr := (Random(20, 38) / 10.0) * factorTam         ; r = largo del trazo
                al := Min(255, Round(Random(90, 160) * factorAlpha))
            case "matrix":
                vx := 0.0
                vy := (Random(90, 180) / 300.0) * factorVel
                rr := (Random(14, 28) / 10.0) * factorTam
                al := Min(255, Round(Random(110, 200) * factorAlpha))
            case "burbujas":
                vx := (Random(-20, 20) / 700.0) * factorVel
                vy := -(Random(25, 70) / 300.0) * factorVel       ; sube
                rr := (Random(18, 40) / 10.0) * factorTam
                al := Min(255, Round(Random(60, 130) * factorAlpha))
            case "petalos", "hojas":
                vx := (Random(-60, 60) / 500.0) * factorVel       ; deriva lateral
                vy := (Random(25, 70) / 300.0) * factorVel        ; cae suave
                rr := (Random(22, 42) / 10.0) * factorTam
                al := Min(255, Round(Random(110, 190) * factorAlpha))
        }
        arr.Push({ x: Random(0.0, w * 1.0), y: Random(0.0, h * 1.0),
                   vx: vx, vy: vy, r: rr, alpha: al, ph: Random(0.0, 6.2831) })
    }
}

; Aplica la config actual: re-inicializa los arrays con los nuevos multiplicadores
; y muestra/oculta los overlays según el toggle de activadas.
AplicarConfigParticulas() {
    global particulasMain, particulasHist, miGui, historialGui, historialVisible
    global overlayPartMain, overlayPartHist, particulasActivas, optEscena
    static BAR_H := 25

    if (IsObject(miGui) && IsObject(overlayPartMain)) {
        miGui.GetPos(,, &mw, &mh)
        InicializarParticulas(particulasMain, mw, mh - BAR_H, 32)
        ; El overlay principal se muestra si hay partículas O si está activa la
        ; decoración del tema (escena), aunque las partículas estén apagadas.
        if (particulasActivas || optEscena) {
            try overlayPartMain.Show("NoActivate")
        } else {
            try overlayPartMain.Hide()
        }
    }
    if (IsObject(historialGui) && IsObject(overlayPartHist)) {
        historialGui.GetPos(,, &hw, &hh)
        InicializarParticulas(particulasHist, hw, hh - BAR_H, 40)
        if (particulasActivas && historialVisible) {
            try overlayPartHist.Show("NoActivate")
        } else {
            try overlayPartHist.Hide()
        }
    }
}

; Pinta SOLO la escena/decoración del tema en el overlay principal, sin partículas.
; Se usa cuando las partículas están apagadas (preset Eco o toggle de partículas off)
; pero el usuario quiere mantener la decoración (toggle "Decoración del tema").
ActualizarEscenaSola() {
    global miGui, overlayPartMain, temaEnTransicion, optEscena
    global particulasActivas, presetParticulas, modoMini
    static BAR_H := 25
    if (temaEnTransicion || !optEscena || modoMini)
        return
    if (particulasActivas && presetParticulas > 0)
        return  ; las partículas ya están pintando la escena, no duplicar
    try if (IsObject(miGui) && IsObject(overlayPartMain) && !DllCall("IsIconic", "Ptr", miGui.Hwnd, "Int")) {
        miGui.GetPos(&mx, &my, &mw, &mh)
        overlayPartMain.GetPos(&ox, &oy, &ow, &oh)
        targetY := my + BAR_H
        targetH := mh - BAR_H
        if (mx != ox || targetY != oy || mw != ow || targetH != oh)
            overlayPartMain.Move(mx, targetY, mw, targetH)
        PintarOverlayParticulas(overlayPartMain.Hwnd, mw, targetH, [], "", true)
    }
}

; Decide qué timers visuales corren y la visibilidad del overlay principal.
; - Partículas encendidas (toggle on + preset con fps) → timer de partículas, que
;   pinta partículas + escena juntas.
; - Si no, pero la decoración está activa → timer ligero (presetDecoFps) que pinta
;   SOLO la escena. Así Eco / partículas-off conservan la decoración del tema.
RefrescarTimersVisuales() {
    global particulasActivas, presetParticulas, presetDecoFps, optEscena, overlayPartMain
    particulasOn := particulasActivas && presetParticulas > 0
    escenaSola := optEscena && !particulasOn
    SetTimer(ActualizarParticulas, particulasOn ? presetParticulas : 0)
    SetTimer(ActualizarEscenaSola, escenaSola ? presetDecoFps : 0)
    if (IsObject(overlayPartMain)) {
        if (particulasOn || optEscena) {
            try overlayPartMain.Show("NoActivate")
        } else {
            try overlayPartMain.Hide()
        }
    }
    if (escenaSola)
        try ActualizarEscenaSola()   ; pinta un frame ya, sin esperar al primer tick
}

ActualizarParticulas() {
    global particulasMain, particulasHist, miGui, historialGui, historialVisible, particulasInited
    global overlayPartMain, overlayPartHist
    global temaEnTransicion, particulasActivas
    global temas, temaActual, modoMini, particulasMini
    if (!particulasInited || temaEnTransicion || !particulasActivas)
        return

    static BAR_H := 25  ; alto de la barra de título excluida del overlay
    static MINI_OVL_H := 85  ; alto del overlay mini (deja hueco a los 3 botones de abajo)

    ; ── Si cambió el EFECTO del tema, re-inicializar las partículas para que
    ;    adopten la nueva dirección/forma (nieve cae, brasas suben, etc.) ──
    static lastEf := ""
    efAhora := EfectoDeTema(temas[temaActual])
    if (efAhora != lastEf) {
        lastEf := efAhora
        try {
            if (IsObject(miGui)) {
                miGui.GetPos(,, &rw, &rh)
                InicializarParticulas(particulasMain, rw, rh - BAR_H, 32)
            }
            if (IsObject(historialGui)) {
                historialGui.GetPos(,, &rhw, &rhh)
                InicializarParticulas(particulasHist, rhw, rhh - BAR_H, 40)
            }
            if (modoMini && IsObject(particulasMini))
                InicializarParticulas(particulasMini, 120, 100, 15)
        }
    }
    ; Sincronizar overlay con la ventana padre (sigue el drag) y repintar.
    ; Saltar actualización si el padre está minimizado — GetPos devolvería coords
    ; basura del estado minimizado y las partículas se apiñarían ahí.
    ; Todo dentro de try/catch porque durante minimize/restore Windows puede dejar
    ; las ventanas en estados transitorios donde GetPos/Move tiran excepciones.
    try if (!modoMini && IsObject(miGui) && IsObject(overlayPartMain) && !DllCall("IsIconic", "Ptr", miGui.Hwnd, "Int")) {
        miGui.GetPos(&mx, &my, &mw, &mh)
        overlayPartMain.GetPos(&ox, &oy, &ow, &oh)
        targetY := my + BAR_H
        targetH := mh - BAR_H
        if (mx != ox || targetY != oy || mw != ow || targetH != oh)
            overlayPartMain.Move(mx, targetY, mw, targetH)
        for p in particulasMain {
            p.x += p.vx
            p.y += p.vy
            if (p.x < -8)
                p.x := mw + 8
            else if (p.x > mw + 8)
                p.x := -8
            if (p.y < -8)
                p.y := targetH + 8
            else if (p.y > targetH + 8)
                p.y := -8
        }
        PintarOverlayParticulas(overlayPartMain.Hwnd, mw, targetH, particulasMain, "", true)
    }
    try if (!modoMini && IsObject(historialGui) && IsObject(overlayPartHist) && historialVisible
        && !DllCall("IsIconic", "Ptr", historialGui.Hwnd, "Int")) {
        historialGui.GetPos(&hx, &hy, &hw, &hh)
        overlayPartHist.GetPos(&ox, &oy, &ow, &oh)
        targetY := hy + BAR_H
        targetH := hh - BAR_H
        if (hx != ox || targetY != oy || hw != ow || targetH != oh)
            overlayPartHist.Move(hx, targetY, hw, targetH)
        for p in particulasHist {
            p.x += p.vx
            p.y += p.vy
            if (p.x < -8)
                p.x := hw + 8
            else if (p.x > hw + 8)
                p.x := -8
            if (p.y < -8)
                p.y := targetH + 8
            else if (p.y > targetH + 8)
                p.y := -8
        }
        ; conEscena=true: el historial también lleva la decoración del tema.
        ; (Sin excludeRect: el scrollbar custom se quitó y ya no hay nada que esquivar.)
        PintarOverlayParticulas(overlayPartHist.Hwnd, hw, targetH, particulasHist, "", true)
    }

    ; ── Partículas + decoraciones del mini mode ──
    global modoMini, miniGui, overlayPartMini, particulasMini, overlayDecoMini
    try if (modoMini && IsObject(miniGui) && IsObject(overlayPartMini)) {
        miniGui.GetPos(&mnx, &mny, &mnw, &mnh)
        overlayPartMini.GetPos(&opx, &opy, &opw, &oph)
        tgtY := mny + BAR_H
        tgtH := MINI_OVL_H
        if (mnx != opx || tgtY != opy || mnw != opw || tgtH != oph)
            overlayPartMini.Move(mnx, tgtY, mnw, tgtH)
        for p in particulasMini {
            p.x += p.vx
            p.y += p.vy
            if (p.x < -8)
                p.x := mnw + 8
            else if (p.x > mnw + 8)
                p.x := -8
            if (p.y < -8)
                p.y := tgtH + 8
            else if (p.y > tgtH + 8)
                p.y := -8
        }
        PintarOverlayParticulas(overlayPartMini.Hwnd, mnw, tgtH, particulasMini, "", true)
    }
    ; Reposicionar overlay deco mini
    try if (modoMini && IsObject(miniGui) && IsObject(overlayDecoMini)) {
        miniGui.GetPos(&mnx2, &mny2, &mnw2, &mnh2)
        overlayDecoMini.GetPos(&odx, &ody, &odw, &odh)
        tgtY2 := mny2 + BAR_H
        tgtH2 := MINI_OVL_H
        if (mnx2 != odx || tgtY2 != ody || mnw2 != odw || tgtH2 != odh)
            overlayDecoMini.Move(mnx2, tgtY2, mnw2, tgtH2)
    }
}

; ===== WATCHDOG AFK =====
; Si el macro está activo pero ningún timer ha actualizado el heartbeat en > 3 min,
; AHK está realmente congelado (Windows Update, antivirus, deadlock, etc).
; Re-lanzamos el script para recuperar la actividad.
; Heartbeats: EjecutarMacro (cada 50ms) + ActualizarTrayIcon (cada 1s).
WatchdogAFK() {
    global activo, ultimoAfkMove, configPath
    if (!activo)
        return
    elapsed := A_TickCount - ultimoAfkMove
    if (elapsed > 180000) {  ; 3 minutos sin heartbeat = AHK realmente colgado
        try {
            IniWrite(FormatTime(, "yyyy-MM-dd HH:mm:ss"), configPath, "Watchdog", "UltimoReinicio")
            IniWrite(elapsed, configPath, "Watchdog", "MsSinAFK")
            IniWrite(1,       configPath, "Watchdog", "AutoStart")
        }
        Reload()
    }
}

; ===== HEARTBEAT PARA WATCHDOG EXTERNO =====
; Escribe en cada tick: <A_TickCount>|<PID actual>|<fecha legible>|<activo 1/0>
; El watchdog externo lee este archivo y verifica el mtime + PID. Si pasa >90s
; sin actualizarse y el PID sigue vivo (= colgado de verdad), lo mata y reinicia.
; El 4º campo (activo) le dice al watchdog si debe RE-ARRANCAR el macro al
; relanzarlo (si estaba detectando, debe volver a detectar — no quedarse parado).
EscribirHeartbeat() {
    global heartbeatPath, activo
    try {
        f := FileOpen(heartbeatPath, "w", "UTF-8")
        if (f) {
            f.Write(A_TickCount "|" ProcessExist() "|" FormatTime(, "yyyy-MM-dd HH:mm:ss") "|" (activo ? 1 : 0))
            f.Close()
        }
    }
}

; Lanza el watchdog externo si no está ya corriendo. El watchdog escribe su PID
; en brawlmacro_watchdog.pid al arrancar y lo borra al salir. Comprobamos ambos.
LanzarWatchdogSiNoEsta() {
    pidPath := A_ScriptDir "\brawlmacro_watchdog.pid"
    watchdogPath := A_ScriptDir "\brawlmacro_watchdog.ahk"
    if (!FileExist(watchdogPath))
        return  ; no hay archivo del watchdog, no podemos lanzarlo
    ; ¿Ya está corriendo?
    if (FileExist(pidPath)) {
        try {
            pid := Integer(Trim(FileRead(pidPath, "UTF-8")))
            if (pid > 0 && ProcessExist(pid))
                return  ; ya está vivo, no relanzar
        }
    }
    ; No está corriendo → lanzarlo (Hide para que no parpadee la consola de AHK)
    try Run('"' watchdogPath '"', A_ScriptDir, "Hide")
}


; Pinta partículas con alpha por píxel (PARGB) sobre la overlay layered y las muestra
; vía UpdateLayeredWindow. Así cada partícula se mezcla contra los píxeles reales que
; hay detrás (sin halo y respetando el fondo), no contra una color-key negra.
PintarOverlayParticulas(overlayHwnd, w, h, particulas, excludeRect := "", conEscena := false) {
    global colorLogoMacro, colorFondoPrincipal, temaPremiumActivo, rgbBarraHue
    global temas, temaActual, optEscena

    if (w <= 0 || h <= 0)
        return

    ; Bitmap GDI+ con formato PARGB (premultiplicado, lo que UpdateLayeredWindow espera)
    static PixelFormat32bppPARGB := 0xE200B
    bmp := 0
    if (DllCall("gdiplus\GdipCreateBitmapFromScan0",
        "Int", w, "Int", h, "Int", 0,
        "Int", PixelFormat32bppPARGB,
        "Ptr", 0, "Ptr*", &bmp) != 0)
        return

    g := 0
    if (DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", &g) != 0 || !g) {
        DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)
        return
    }

    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)            ; AA on
    DllCall("gdiplus\GdipGraphicsClear",    "Ptr", g, "UInt", 0x00000000)   ; transparente total

    ; Excluir del clip una zona (p. ej. la del scrollbar) para que las partículas no pinten ahí
    if (IsObject(excludeRect)) {
        DllCall("gdiplus\GdipSetClipRectI", "Ptr", g,
            "Int", excludeRect.x, "Int", excludeRect.y,
            "Int", excludeRect.w, "Int", excludeRect.h,
            "Int", 4)   ; CombineModeExclude
    }

    tint := colorLogoMacro
    rC := Integer("0x" SubStr(tint, 1, 2))
    gC := Integer("0x" SubStr(tint, 3, 2))
    bC := Integer("0x" SubStr(tint, 5, 2))

    ; Si el tema es CLARO (fondo con luminancia alta), aclarar el tinte mezclando con blanco.
    ; Si no, sobre fondo claro se ven puntos oscuros sucios. Sobre tema oscuro no se toca.
    rF := Integer("0x" SubStr(colorFondoPrincipal, 1, 2))
    gF := Integer("0x" SubStr(colorFondoPrincipal, 3, 2))
    bF := Integer("0x" SubStr(colorFondoPrincipal, 5, 2))
    fondoClaro := ((rF * 299 + gF * 587 + bF * 114) / 1000 > 180)  ; ≈ tema claro
    if (fondoClaro) {
        rC := (rC + 255) // 2
        gC := (gC + 255) // 2
        bC := (bC + 255) // 2
    }

    ; Efecto del tema actual (premium ignora el efecto: mantiene su arcoíris)
    ef := temaPremiumActivo ? "premium" : EfectoDeTema(temas[temaActual])
    tNow := A_TickCount

    ; Escena temática en el borde inferior (solo ventana principal). Se pinta
    ; ANTES que las partículas para que estas floten por delante. La decoración
    ; es ESPECÍFICA por tema (bambú→cañas, miel→panal...), no por categoría.
    if (conEscena && optEscena) {
        deco := temaPremiumActivo ? "premium" : DecoDeTema(temas[temaActual])
        if (deco != "") {
            TestTrace("ES> " deco " w=" w " h=" h)
            PintarEscenaTema(g, w, h, deco, rC, gC, bC, fondoClaro)
            TestTrace("ES ok")
        }
    }

    for i, p in particulas {
        ph := p.HasProp("ph") ? p.ph : 0.0
        if (ef = "premium") {
            huePart := Mod(rgbBarraHue * 3 + i * 25, 360)
            cHex := HSVaHex(huePart, 1.0, 1.0)
            pr := Integer("0x" SubStr(cHex, 1, 2))
            pg := Integer("0x" SubStr(cHex, 3, 2))
            pb := Integer("0x" SubStr(cHex, 5, 2))
            a  := Min(255, p.alpha + 50)
        } else {
            ; Color característico por efecto (los que tienen identidad fuerte usan
            ; color fijo; el resto usa el tinte del tema ya aclarado para fondos claros).
            a := p.alpha
            switch ef {
                case "nieve":     pr := fondoClaro ? 130 : 235, pg := fondoClaro ? 165 : 245, pb := fondoClaro ? 210 : 255
                case "estrellas": pr := fondoClaro ? 120 : 255, pg := fondoClaro ? 130 : 255, pb := fondoClaro ? 200 : 255
                case "chispas":   pr := fondoClaro ? 210 : 255, pg := fondoClaro ? 160 : 224, pb := fondoClaro ? 40  : 130
                case "matrix":    pr := fondoClaro ? 20  : 40,  pg := fondoClaro ? 160 : 255, pb := fondoClaro ? 70  : 110
                case "petalos":   pr := fondoClaro ? 225 : 255, pg := fondoClaro ? 90  : 150, pb := fondoClaro ? 150 : 195
                case "hojas":     pr := fondoClaro ? 80  : 130, pg := fondoClaro ? 150 : 190, pb := fondoClaro ? 40  : 70
                case "brasas":
                    fl := 0.5 + 0.5 * Sin(tNow / 160.0 + ph)
                    pr := fondoClaro ? 220 : 255, pg := Round((fondoClaro ? 40 : 70) + 130 * fl), pb := 30
                default:          pr := rC,  pg := gC,  pb := bC   ; lluvia, burbujas, default
            }
            ; Titileo para estrellas y chispas
            if (ef = "estrellas" || ef = "chispas") {
                tw := 0.30 + 0.70 * (0.5 + 0.5 * Sin(tNow / 280.0 + ph))
                a := Round(p.alpha * tw)
            }
        }
        if (a < 4)
            continue
        argb := (a << 24) | (pr << 16) | (pg << 8) | pb

        ; ── Burbujas: anillo hueco (pen), no relleno ──
        if (ef = "burbujas") {
            pen := 0
            DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", 1.4, "Int", 2, "Ptr*", &pen)
            DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", pen,
                    "Float", p.x - p.r, "Float", p.y - p.r, "Float", p.r * 2, "Float", p.r * 2)
            DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
            continue
        }

        brush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &brush)
        switch ef {
            case "lluvia":
                ; trazo vertical fino (gota alargada)
                DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brush,
                        "Float", p.x - 0.8, "Float", p.y, "Float", 1.6, "Float", p.r * 4)
            case "matrix":
                ; cuadrito de "código"
                DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brush,
                        "Float", p.x - p.r, "Float", p.y - p.r, "Float", p.r * 2, "Float", p.r * 2)
            case "petalos", "hojas":
                ; óvalo (más ancho que alto)
                DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brush,
                        "Float", p.x - p.r * 1.2, "Float", p.y - p.r * 0.7, "Float", p.r * 2.4, "Float", p.r * 1.4)
            default:
                ; círculo (nieve, brasas, estrellas, chispas, default)
                DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brush,
                        "Float", p.x - p.r, "Float", p.y - p.r, "Float", p.r * 2, "Float", p.r * 2)
        }
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)

    ; HBITMAP premultiplicado a partir del Bitmap PARGB
    hbm := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bmp, "Ptr*", &hbm, "UInt", 0)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)
    if (!hbm)
        return

    hdcScreen := DllCall("GetDC", "Ptr", 0, "Ptr")
    hdcMem    := DllCall("CreateCompatibleDC", "Ptr", hdcScreen, "Ptr")
    oldBmp    := DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hbm, "Ptr")

    sizeWin := Buffer(8, 0)
    NumPut("Int", w, sizeWin, 0)
    NumPut("Int", h, sizeWin, 4)
    ptSrc := Buffer(8, 0)
    NumPut("Int", 0, ptSrc, 0)
    NumPut("Int", 0, ptSrc, 4)
    blend := Buffer(4, 0)
    NumPut("UChar", 0,   blend, 0)   ; BlendOp = AC_SRC_OVER
    NumPut("UChar", 0,   blend, 1)   ; BlendFlags
    NumPut("UChar", 255, blend, 2)   ; SourceConstantAlpha (255 = usar alpha por píxel)
    NumPut("UChar", 1,   blend, 3)   ; AlphaFormat = AC_SRC_ALPHA

    DllCall("UpdateLayeredWindow",
        "Ptr",  overlayHwnd,
        "Ptr",  hdcScreen,
        "Ptr",  0,          ; pptDst NULL → no mover
        "Ptr",  sizeWin,
        "Ptr",  hdcMem,
        "Ptr",  ptSrc,
        "UInt", 0,          ; crKey (no se usa)
        "Ptr",  blend,
        "UInt", 2,          ; ULW_ALPHA
        "Int")

    DllCall("SelectObject", "Ptr", hdcMem, "Ptr", oldBmp)
    DllCall("DeleteDC",     "Ptr", hdcMem)
    DllCall("ReleaseDC",    "Ptr", 0, "Ptr", hdcScreen)
    DllCall("DeleteObject", "Ptr", hbm)
}

; Rellena un polígono GDI+ a partir de un array de puntos [[x,y],...].
EscenaPoligono(g, argb, pts) {
    n := pts.Length
    if (n < 2)
        return
    buf := Buffer(n * 8)
    for i, pt in pts {
        NumPut("Float", pt[1], buf, (i - 1) * 8)
        NumPut("Float", pt[2], buf, (i - 1) * 8 + 4)
    }
    br := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
    DllCall("gdiplus\GdipFillPolygon", "Ptr", g, "Ptr", br, "Ptr", buf, "Int", n, "Int", 0)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

; Elipse rellena rápida (helper).
EscenaElipse(g, argb, x, y, ew, eh) {
    br := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
    DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", br, "Float", x, "Float", y, "Float", ew, "Float", eh)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

EscenaRect(g, argb, x, y, ew, eh) {
    br := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
    DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", br, "Float", x, "Float", y, "Float", ew, "Float", eh)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

EscenaAnillo(g, argb, x, y, d, grosor) {
    pen := 0
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", grosor, "Int", 2, "Ptr*", &pen)
    DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", pen, "Float", x, "Float", y, "Float", d, "Float", d)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
}

EscenaPie(g, argb, x, y, ew, eh, start, sweep) {
    br := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
    DllCall("gdiplus\GdipFillPie", "Ptr", g, "Ptr", br, "Float", x, "Float", y, "Float", ew, "Float", eh, "Float", start, "Float", sweep)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

EscenaLinea(g, argb, x1, y1, x2, y2, grosor) {
    pen := 0
    DllCall("gdiplus\GdipCreatePen1", "UInt", argb, "Float", grosor, "Int", 2, "Ptr*", &pen)
    DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", pen, "Float", x1, "Float", y1, "Float", x2, "Float", y2)
    DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
}

; Decoración ESPECÍFICA por tema (según su nombre), con respaldo a la categoría
; por efecto (EfectoDeTema) si el tema no tiene una decoración propia definida.
DecoDeTema(t) {
    if (t.HasProp("deco") && t.deco != "")
        return t.deco
    ; Secretos de nombre espaciado (✦ C O S M O S ✦, etc.) → por unlock
    if (t.HasProp("unlock")) {
        switch t.unlock {
            case "shadow":  return "eclipse"
            case "cosmos":  return "planeta"
            case "void":    return "void"
            case "solar":   return "fenix"
            case "premium": return "diamantes"
            case "blanco":  return "solnika"
            case "gojo":    return ""
            case "sukuna":  return ""
        }
    }
    n := t.nombre
    ; Cada tema → una decoración ÚNICA (sin repeticiones). Orden = prioridad.
    pares := [
        ; ── claros ──
        ["Hielo","hielo"], ["Polar","iglu"], ["Agua","gotas"], ["Menta","menta"],
        ["Verde","pasto"], ["Nube","nubes"], ["Lavanda","lavanda"],
        ["Lila","lila"], ["Sakura","sakura"], ["Rosa","rosa"], ["Atardecer","atardecer"],
        ["Melocot","melocoton"], ["Naranja","naranja"], ["Desierto","cactus"], ["Vainilla","vainilla"],
        ["Miel","miel"], ["Bamb","bambu"], ["Monocromo","ajedrez"], ["Chicle","chicle"],
        ["Mostaza","mostaza"], ["Tropical","palmera"],
        ; ── oscuros ──
        ["Ceniza","ceniza"], ["Grafito","grafito"], ["Noche","luna"], ["Profundo","abisal"],
        ["Océano","olas"], ["Aurora","aurora"], ["Cyberpunk","ciudadneon"], ["Cyber","circuito"],
        ["Neon","neon"], ["Esmeralda","gema"], ["Jungla","jungla"], ["Bosque","pinos"],
        ["Cafe","cafe"], ["Dorado","oro"], ["Magma","lava"], ["Sangre","sangre"],
        ["Abismo","portal"], ["Electrico","electrico"], ["Glitch","glitch"], ["Tundra","tundra"],
        ["Veneno","veneno"], ["Cobre","cobre"], ["Vino","vino"], ["Submarino","submarino"],
        ; ── secretos gamer / leyendas ──
        ["Brawl","espadas"], ["Retrowave","retrowave"], ["Discord","chat"], ["Spotify","spotify"],
        ["Valorant","mira"], ["Minecraft","bloques"], ["Sky","cielo"], ["Matrix","matrixlluvia"],
        ["Pok","pokebola"], ["Naruto","naruto"], ["One Piece","onepiece"]
    ]
    for par in pares {
        if (InStr(n, par[1]))
            return par[2]
    }
    return EfectoDeTema(t)
}

; ═══════════════════════════════════════════════════════════════
; ESCENA TEMÁTICA en el borde inferior de la ventana principal.
; Cada tipo de tema dibuja un decorado reconocible: hielo→nieve,
; jungla→árboles, magma→llamas, océano→olas, etc.
; ═══════════════════════════════════════════════════════════════
PintarEscenaTema(g, w, h, ef, rC, gC, bC, fondoClaro) {
    tNow := A_TickCount

    switch ef {
    ; ─────────── DECORACIONES ESPECÍFICAS POR TEMA ───────────
    case "hielo":
        ; Carámbanos colgando arriba (con goteo) + cristales de hielo en el borde
        ; inferior + grietas en el suelo helado + destellos y copos titilando
        loop 4 {
            cx := (A_Index - 0.5) * w / 4 + w * 0.06
            il := 9 + Mod(A_Index * 8, 13)
            EscenaPoligono(g, (210 << 24) | (160 << 16) | (215 << 8) | 245, [[cx - 4, 0], [cx + 4, 0], [cx + 1.5, il], [cx - 1.5, il]])
            EscenaLinea(g, (235 << 24) | (255 << 16) | (255 << 8) | 255, cx - 2.5, 0, cx - 0.5, il * 0.75, 1)
            dy := Mod(tNow / 14.0 + A_Index * 23, 30)
            EscenaElipse(g, (Round(200 * (1 - dy / 30)) << 24) | (190 << 16) | (230 << 8) | 255, cx - 1, il + dy, 2, 2.5)
        }
        loop 5 {
            cx := (A_Index - 0.5) * w / 5
            hh := 15 + Mod(A_Index * 7, 11)
            EscenaPoligono(g, (200 << 24) | (130 << 16) | (205 << 8) | 235, [[cx, h - hh], [cx + 5, h - hh + 6], [cx + 4, h], [cx - 4, h], [cx - 5, h - hh + 6]])
            EscenaLinea(g, (235 << 24) | (255 << 16) | (255 << 8) | 255, cx, h - hh, cx - 5, h - hh + 6, 1.4)
            EscenaLinea(g, (210 << 24) | (40 << 16) | (110 << 8) | 190, cx + 5, h - hh + 6, cx + 4, h, 1.2)
        }
        loop 2 {
            lx := w * (0.28 + A_Index * 0.34)
            EscenaLinea(g, (130 << 24) | (90 << 16) | (160 << 8) | 220, lx, h - 1, lx + 12, h - 8, 1)
            EscenaLinea(g, (130 << 24) | (90 << 16) | (160 << 8) | 220, lx + 12, h - 8, lx + 5, h - 13, 1)
        }
        loop 4 {
            sx := Mod(A_Index * 73, Round(w - 12)) + 6
            sy := 6 + Mod(A_Index * 11, 18)
            tw := 0.5 + 0.5 * Sin(tNow / 220.0 + A_Index)
            EscenaElipse(g, (Round(225 * tw) << 24) | (170 << 16) | (215 << 8) | 255, sx - 2, sy - 2, 4, 4)
        }
        loop 2 {
            fx := Mod(A_Index * 97, Round(w - 16)) + 8
            fy := 8 + Mod(A_Index * 17, 16)
            rot := tNow / 900.0 + A_Index * 1.2
            tw := 0.5 + 0.5 * Sin(tNow / 260.0 + A_Index * 3)
            colF := (Round(220 * tw) << 24) | (255 << 16) | (255 << 8) | 255
            EscenaLinea(g, colF, fx - Cos(rot) * 4, fy - Sin(rot) * 4, fx + Cos(rot) * 4, fy + Sin(rot) * 4, 1)
            EscenaLinea(g, colF, fx - Cos(rot + 1.047) * 4, fy - Sin(rot + 1.047) * 4, fx + Cos(rot + 1.047) * 4, fy + Sin(rot + 1.047) * 4, 1)
            EscenaLinea(g, colF, fx - Cos(rot + 2.094) * 4, fy - Sin(rot + 2.094) * 4, fx + Cos(rot + 2.094) * 4, fy + Sin(rot + 2.094) * 4, 1)
        }
    case "iglu":
        ; Aurora boreal ondulando arriba + estrellas titilando + pinos nevados +
        ; suelo nevado con iglús (bloques de hielo, entrada y humo) + nieve cayendo
        loop 2 {
            capa := A_Index
            fase := tNow / 1500.0 + capa * 2.1
            ay := h * (0.06 + capa * 0.06)
            aA := capa = 1 ? 60 : 40
            pts := []
            pts.Push([0, 0])
            x := 0.0
            while (x <= w) {
                yy := ay + Sin(x / 34.0 + fase) * (5 + capa * 3)
                pts.Push([x, yy])
                x += w / 12
            }
            pts.Push([w, 0])
            EscenaPoligono(g, (aA << 24) | (rC << 16) | (gC << 8) | bC, pts)
        }
        loop 5 {
            sx := Mod(A_Index * 67, Round(w - 6)) + 3
            sy := 3 + Mod(A_Index * 13, Round(h * 0.3))
            tw := 0.4 + 0.6 * (0.5 + 0.5 * Sin(tNow / 260.0 + A_Index * 2))
            EscenaElipse(g, (Round(220 * tw) << 24) | (255 << 16) | (255 << 8) | 255, sx - 1, sy - 1, 2, 2)
        }
        loop 3 {
            px := w * (0.08 + A_Index * 0.32)
            ph := 15 + Mod(A_Index * 5, 6)
            EscenaPoligono(g, (160 << 24) | (45 << 16) | (95 << 8) | 75, [[px, h - ph - 4], [px - 7, h - 4], [px + 7, h - 4]])
            EscenaPoligono(g, (200 << 24) | (235 << 16) | (245 << 8) | 255, [[px, h - ph - 4], [px - 5, h - 9], [px + 5, h - 9]])
        }
        EscenaRect(g, (215 << 24) | (235 << 16) | (245 << 8) | 255, 0, h - 5, w, 5)
        loop 2 {
            esPrimero := (A_Index = 1)
            cx := A_Index * w / 3 + w * 0.06
            EscenaPie(g, (235 << 24) | (242 << 16) | (252 << 8) | 255, cx - 18, h - 23, 36, 38, 180, 180)
            loop 3 {
                k := A_Index * 5
                lw := 18 * (1 - k / 19)
                EscenaLinea(g, (130 << 24) | (170 << 16) | (200 << 8) | 230, cx - lw, h - 5 - k, cx + lw, h - 5 - k, 1)
            }
            EscenaLinea(g, (170 << 24) | (130 << 16) | (155 << 8) | 195, cx - 17, h - 5, cx + 17, h - 5, 1.2)
            EscenaPie(g, (215 << 24) | (70 << 16) | (100 << 8) | 150, cx - 6, h - 11, 12, 15, 180, 180)
            if (esPrimero) {
                loop 3 {
                    rise := Mod(tNow / 18.0 + A_Index * 14, 26)
                    al := Round(110 * (1 - rise / 26))
                    EscenaElipse(g, (al << 24) | (235 << 16) | (240 << 8) | 245, cx + 6 + A_Index, h - 23 - rise, 3 + A_Index, 3 + A_Index)
                }
            }
        }
        loop 6 {
            sx := Mod(A_Index * 53, Round(w - 8)) + 4
            sy := Mod(tNow / 16.0 + A_Index * 30, h)
            EscenaElipse(g, (210 << 24) | (255 << 16) | (255 << 8) | 255, sx - 1.5, sy - 1.5, 3, 3)
        }
    case "gotas":
        ; Superficie del agua ondulando arriba + pez nadando + burbujas subiendo +
        ; algas meciéndose en las esquinas, además de gotas y ondas en el suelo
        wy := h * 0.16
        pts := []
        pts.Push([0, 0])
        x := 0.0
        while (x <= w) {
            yy := wy + Sin(x / 28.0 + tNow / 700.0) * 3
            pts.Push([x, yy])
            x += w / 14
        }
        pts.Push([w, 0])
        EscenaPoligono(g, (60 << 24) | (rC << 16) | (gC << 8) | bC, pts)
        loop 2 {
            esIzq := (A_Index = 1)
            ax := esIzq ? w * 0.08 : w * 0.92
            dirSign := esIzq ? 1 : -1
            py := h
            loop 3 {
                sway := Sin(tNow / 600.0 + A_Index * 0.8) * (2 + A_Index) * dirSign
                nx := ax + sway
                ny := h - A_Index * 6
                EscenaLinea(g, (190 << 24) | (60 << 16) | (170 << 8) | 110, ax, py, nx, ny, 1.6)
                ax := nx
                py := ny
            }
        }
        fx := w * 0.5 + Sin(tNow / 2200.0) * w * 0.35
        fy := h * 0.45 + Sin(tNow / 500.0) * 3
        dir := Cos(tNow / 2200.0) >= 0 ? 1 : -1
        EscenaElipse(g, (200 << 24) | (rC << 16) | (gC << 8) | bC, fx - 5, fy - 3, 10, 6)
        EscenaPoligono(g, (200 << 24) | (rC << 16) | (gC << 8) | bC, [[fx - 5 * dir, fy], [fx - 9 * dir, fy - 3], [fx - 9 * dir, fy + 3]])
        EscenaElipse(g, (230 << 24) | (255 << 16) | (255 << 8) | 255, fx + 2 * dir, fy - 1.5, 1.6, 1.6)
        loop 5 {
            bx := Mod(A_Index * 59, Round(w - 8)) + 4
            by := h - Mod(tNow / 11.0 + A_Index * 26, h)
            EscenaAnillo(g, (160 << 24) | (255 << 16) | (255 << 8) | 255, bx - 1.5, by - 1.5, 3, 0.8)
        }
        loop 6 {
            cx := Mod(A_Index * 61, Round(w - 10)) + 5
            gy := Mod(tNow / 9.0 + A_Index * 35, h)
            EscenaElipse(g, (180 << 24) | (rC << 16) | (gC << 8) | bC, cx - 2, gy, 4, 6)
        }
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (130 << 24) | (rC << 16) | (gC << 8) | bC, "Float", 1.2, "Int", 2, "Ptr*", &pen)
        loop 4 {
            cx := (A_Index - 0.5) * w / 4
            rip := 4 + Mod(tNow // 150 + A_Index * 4, 8)
            DllCall("gdiplus\GdipDrawArc", "Ptr", g, "Ptr", pen, "Float", cx - rip, "Float", h - 3 - rip * 0.4, "Float", rip * 2, "Float", rip * 0.8, "Float", 180, "Float", 180)
        }
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    case "menta":
        ; Ramitas meciéndose con la brisa + hojitas cayendo en péndulo
        verde := (205 << 24) | (90 << 16) | (200 << 8) | 130
        loop 5 {
            cx := (A_Index - 0.5) * w / 5
            sway := Sin(tNow / 650.0 + A_Index * 0.9) * 2.5
            EscenaLinea(g, verde, cx, h, cx + sway, h - 13, 1.4)
            EscenaElipse(g, verde, cx + sway - 7, h - 13, 7, 5)
            EscenaElipse(g, verde, cx + sway, h - 13, 7, 5)
            EscenaElipse(g, verde, cx + sway * 0.6 - 5, h - 8, 6, 4)
            EscenaElipse(g, verde, cx + sway * 0.6, h - 8, 6, 4)
        }
        loop 4 {
            fy := Mod(tNow / 28.0 + A_Index * (h / 4.0), h + 14) - 7
            fx := Mod(A_Index * 71, Round(w - 16)) + 8 + Sin(fy / 14.0 + A_Index) * 7
            EscenaElipse(g, (185 << 24) | (110 << 16) | (215 << 8) | 150, fx - 3, fy - 2, 6, 4)
            EscenaLinea(g, (150 << 24) | (70 << 16) | (170 << 8) | 110, fx - 2, fy, fx + 2, fy, 1)
        }
        ; Lucecitas (luciérnagas) parpadeando entre las hojas
        loop 2 {
            lx := Mod(A_Index * 113, Round(w - 10)) + 5
            ly := h * 0.3 + Mod(A_Index * 17, Round(h * 0.4))
            tw := 0.3 + 0.7 * (0.5 + 0.5 * Sin(tNow / 380.0 + A_Index * 2))
            EscenaElipse(g, (Round(200 * tw) << 24) | (210 << 16) | (255 << 8) | 160, lx - 1.5, ly - 1.5, 3, 3)
        }
        ; Más luciérnagas con deriva lenta (4 extra, distintas fases)
        loop 4 {
            lx2 := Mod(A_Index * 67, Round(w - 14)) + 7 + Sin(tNow / 1100.0 + A_Index * 1.4) * 8
            ly2 := h * 0.2 + Mod(A_Index * 23, Round(h * 0.5)) + Cos(tNow / 900.0 + A_Index) * 4
            tw2 := 0.2 + 0.8 * (0.5 + 0.5 * Sin(tNow / 300.0 + A_Index * 2.6))
            EscenaElipse(g, (Round(190 * tw2) << 24) | (200 << 16) | (255 << 8) | 150, lx2 - 1.3, ly2 - 1.3, 2.6, 2.6)
        }
        ; Taza de té de menta a la derecha con vaho subiendo
        tzx := w * 0.86
        EscenaRect(g, (225 << 24) | (250 << 16) | (250 << 8) | 248, tzx - 9, h - 12, 18, 10)
        EscenaRect(g, (210 << 24) | (90 << 16) | (200 << 8) | 130, tzx - 7, h - 11, 14, 3)   ; té verde menta
        EscenaAnillo(g, (215 << 24) | (250 << 16) | (250 << 8) | 248, tzx + 8, h - 10, 6, 1.8)  ; asa
        EscenaPoligono(g, (200 << 24) | (80 << 16) | (180 << 8) | 115, [[tzx - 2, h - 12], [tzx + 4, h - 16], [tzx + 1, h - 11]])  ; hojita en el té
        loop 3 {
            faseT := Mod(tNow / 17.0 + A_Index * 24, 32)
            aT2 := Round(160 * (1 - faseT / 32.0))
            EscenaElipse(g, (aT2 << 24) | (235 << 16) | (250 << 8) | 242, tzx - 5 + A_Index * 4 + Sin(tNow / 300.0 + A_Index * 1.8) * 2, h - 14 - faseT, 3.6, 2.6)
        }
        ; Niebla fresca de menta derivando a media altura
        nbx := Mod(tNow / 120.0, w + 70) - 70
        EscenaElipse(g, (35 << 24) | (170 << 16) | (240 << 8) | 205, nbx, h * 0.35, 44, 8)
        EscenaElipse(g, (28 << 24) | (170 << 16) | (240 << 8) | 205, nbx + 22, h * 0.32, 34, 7)
    case "pasto":
        ; Césped con el viento en OLEADAS (recorre el prado) + florecillas + mariposa
        verde := (205 << 24) | (70 << 16) | (160 << 8) | 60
        loop 15 {
            cx := A_Index * w / 16
            hh := 8 + Mod(A_Index * 5, 10)
            sway := Sin(tNow / 600.0 - cx / 30.0) * 3
            EscenaLinea(g, verde, cx, h, cx + sway, h - hh, 1.6)
        }
        loop 3 {
            fx := A_Index * w / 4 + 8
            sway := Sin(tNow / 600.0 - fx / 30.0) * 2
            EscenaElipse(g, (215 << 24) | (255 << 16) | (235 << 8) | 120, fx + sway - 2, h - 13, 4, 4)
        }
        ; mariposa en vuelo errático con aleteo
        bx := w * 0.5 + Sin(tNow / 1000.0) * w * 0.34
        by := h - 22 + Sin(tNow / 470.0) * 6
        flap := Abs(Sin(tNow / 110.0))
        EscenaElipse(g, (210 << 24) | (255 << 16) | (170 << 8) | 60, bx - 4 * flap - 1, by - 2, 4 * flap + 1, 4)
        EscenaElipse(g, (210 << 24) | (255 << 16) | (170 << 8) | 60, bx, by - 2, 4 * flap + 1, 4)
        EscenaLinea(g, (200 << 24) | (60 << 16) | (50 << 8) | 30, bx, by - 3, bx, by + 3, 1.2)
        ; Sol con rayos arriba a la izquierda
        sx2 := w * 0.1
        sy2 := h * 0.12
        rot2 := tNow / 2200.0
        loop 6 {
            ang := rot2 + (A_Index - 1) * 1.047
            EscenaLinea(g, (130 << 24) | (255 << 16) | (220 << 8) | 90, sx2, sy2, sx2 + Cos(ang) * 9, sy2 + Sin(ang) * 9, 1.3)
        }
        EscenaElipse(g, (210 << 24) | (255 << 16) | (225 << 8) | 100, sx2 - 5, sy2 - 5, 10, 10)
        ; Mariquita caminando por el césped
        lbx := Mod(tNow / 40.0, w + 16) - 8
        lby := h - 4
        EscenaElipse(g, (220 << 24) | (220 << 16) | (40 << 8) | 40, lbx - 2.5, lby - 2.5, 5, 4)
        EscenaLinea(g, (230 << 24) | (30 << 16) | (30 << 8) | 30, lbx, lby - 2.5, lbx, lby + 1.5, 1)
        EscenaElipse(g, (230 << 24) | (30 << 16) | (30 << 8) | 30, lbx - 1.5, lby - 1.2, 1, 1)
        EscenaElipse(g, (230 << 24) | (30 << 16) | (30 << 8) | 30, lbx + 1, lby, 1, 1)
    case "vainilla":
        ; Cupcakes de vainilla: envoltorio + crema + cereza (contraste para fondo claro)
        loop 3 {
            cx := (A_Index - 0.5) * w / 3
            EscenaPoligono(g, (225 << 24) | (225 << 16) | (170 << 8) | 110, [[cx - 9, h], [cx + 9, h], [cx + 7, h - 9], [cx - 7, h - 9]])
            EscenaLinea(g, (200 << 24) | (180 << 16) | (130 << 8) | 70, cx - 3, h, cx - 4, h - 9, 1)
            EscenaLinea(g, (200 << 24) | (180 << 16) | (130 << 8) | 70, cx + 3, h, cx + 4, h - 9, 1)
            crema := (235 << 24) | (255 << 16) | (245 << 8) | 215
            EscenaElipse(g, crema, cx - 8, h - 15, 16, 9)
            EscenaElipse(g, crema, cx - 5, h - 19, 10, 8)
            EscenaElipse(g, crema, cx - 2.5, h - 22, 5, 6)
            EscenaElipse(g, (235 << 24) | (220 << 16) | (40 << 8) | 60, cx - 2, h - 25, 4, 4)
        }
        ; Aroma recién horneado subiendo de cada cupcake (volutas que se desvanecen)
        loop 3 {
            acx := (A_Index - 0.5) * w / 3
            faseV := Mod(tNow / 18.0 + A_Index * 37, 46)
            aA := Round(150 * (1 - faseV / 46.0))
            EscenaElipse(g, (aA << 24) | (185 << 16) | (150 << 8) | 95, acx - 3 + Sin(tNow / 350.0 + A_Index) * 3, h - 26 - faseV, 5, 3)
        }
        ; Chispitas de azúcar de colores cayendo
        loop 5 {
            sxv := Mod(A_Index * 53, Round(w - 10)) + 5
            syv := Mod(tNow / 22.0 + A_Index * 31, h + 6) - 3
            colS := A_Index = 1 ? (210 << 24) | (220 << 16) | (60 << 8) | 90
                : A_Index = 2 ? (210 << 24) | (80 << 16) | (140 << 8) | 200
                : A_Index = 3 ? (210 << 24) | (230 << 16) | (150 << 8) | 40
                : A_Index = 4 ? (210 << 24) | (90 << 16) | (170 << 8) | 90
                : (210 << 24) | (200 << 16) | (90 << 8) | 160
            EscenaRect(g, colS, sxv, syv, 2, 4)
        }
        ; Destellos de azúcar titilando a media altura
        loop 4 {
            dxv := Mod(A_Index * 67, Round(w - 14)) + 7
            twv := 0.5 + 0.5 * Sin(tNow / 260.0 + A_Index * 1.7)
            EscenaElipse(g, (Round(190 * twv) << 24) | (200 << 16) | (160 << 8) | 80, dxv, h - 28 + Mod(A_Index * 5, 9), 2.2, 2.2)
        }
        ; Flor de vainilla a la izquierda (pétalos crema + centro amarillo), se mece
        fvx := w * 0.07 + Sin(tNow / 800.0) * 2
        fvy := h - 9
        EscenaLinea(g, (220 << 24) | (90 << 16) | (130 << 8) | 60, w * 0.07, h, fvx, fvy, 1.5)
        loop 5 {
            angF := (A_Index - 1) * 1.2566
            EscenaElipse(g, (230 << 24) | (250 << 16) | (243 << 8) | 220, fvx + Cos(angF) * 4 - 2.5, fvy + Sin(angF) * 4 - 2.5, 5, 5)
        }
        EscenaElipse(g, (245 << 24) | (230 << 16) | (180 << 8) | 50, fvx - 2, fvy - 2, 4, 4)
        ; Vainas de vainilla colgando de arriba (marrón oscuro: el toque que faltaba)
        loop 3 {
            vnx := w * (0.18 + (A_Index - 1) * 0.3)
            balV := Sin(tNow / 850.0 + A_Index * 1.7) * 3
            EscenaLinea(g, (215 << 24) | (120 << 16) | (160 << 8) | 80, vnx, 0, vnx + balV * 0.4, 5, 1.2)   ; tallito
            EscenaLinea(g, (240 << 24) | (75 << 16) | (48 << 8) | 28, vnx + balV * 0.4, 5, vnx + balV, 22, 2.8)   ; vaina
            EscenaLinea(g, (200 << 24) | (45 << 16) | (28 << 8) | 16, vnx + balV * 0.4 + 0.8, 7, vnx + balV + 0.8, 20, 1)   ; sombra
            EscenaElipse(g, (240 << 24) | (75 << 16) | (48 << 8) | 28, vnx + balV - 1.5, 20, 3.5, 4.5)      ; punta curvada
        }
    case "ajedrez":
        ; Suelo de ajedrez con profundidad (3 filas) + un peón en el centro
        loop 3 {
            row := A_Index
            ry := h - row * 6
            cols := 16 + (row - 1) * 2
            a := 215 - (row - 1) * 50
            loop cols {
                cx := (A_Index - 1) * w / cols
                c := Mod(A_Index + row, 2) ? ((a << 24) | (28 << 16) | (28 << 8) | 28) : ((Round(a * 0.8) << 24) | (235 << 16) | (235 << 8) | 235)
                EscenaRect(g, c, cx, ry, w / cols + 1, 6)
            }
        }
        px := w * 0.5, py := h - 16
        EscenaElipse(g, (120 << 24) | (20 << 16) | (20 << 8) | 20, px - 7, py + 8, 14, 4)   ; sombra
        pc := (230 << 24) | (240 << 16) | (240 << 8) | 240
        EscenaElipse(g, pc, px - 4, py - 10, 8, 8)                                            ; cabeza
        EscenaPoligono(g, pc, [[px - 3, py - 3], [px + 3, py - 3], [px + 5, py + 8], [px - 5, py + 8]])  ; cuerpo
        EscenaRect(g, pc, px - 6, py + 8, 12, 3)                                              ; base
        ; Caballo negro a la izquierda (el rival del peón)
        kx := w * 0.2, ky := h - 8
        EscenaElipse(g, (120 << 24) | (20 << 16) | (20 << 8) | 20, kx - 6, ky + 4, 12, 4)   ; sombra
        EscenaPoligono(g, (225 << 24) | (45 << 16) | (45 << 8) | 45, [[kx - 4, ky + 4], [kx + 4, ky + 4], [kx + 3, ky - 4], [kx + 6, ky - 8], [kx + 1, ky - 13], [kx - 3, ky - 9], [kx - 1, ky - 4]])
        EscenaElipse(g, (235 << 24) | (250 << 16) | (250 << 8) | 250, kx + 1, ky - 11, 1.6, 1.6)  ; ojo
        ; Torre blanca deslizándose por el tablero (va y viene)
        txr := w * (0.62 + 0.24 * (0.5 + 0.5 * Sin(tNow / 1300.0)))
        EscenaElipse(g, (110 << 24) | (20 << 16) | (20 << 8) | 20, txr - 5, h - 4, 10, 3)   ; sombra
        EscenaPoligono(g, pc, [[txr - 4, h - 3], [txr + 4, h - 3], [txr + 3, h - 12], [txr - 3, h - 12]])
        EscenaRect(g, pc, txr - 5, h - 15, 10, 3)
        EscenaRect(g, pc, txr - 5, h - 17, 2.5, 2)
        EscenaRect(g, pc, txr - 1.2, h - 17, 2.5, 2)
        EscenaRect(g, pc, txr + 2.5, h - 17, 2.5, 2)
    case "mostaza":
        ; Charco + goterones + zigzag de mostaza exprimida (estilo hotdog)
        col := (225 << 24) | (215 << 16) | (165 << 8) | 25
        colD := (230 << 24) | (175 << 16) | (120 << 8) | 12
        EscenaPoligono(g, col, [[0, h], [0, h - 4], [w, h - 4], [w, h]])
        loop 6 {
            cx := (A_Index - 0.5) * w / 6
            dl := 6 + Mod(A_Index * 5, 10)
            EscenaRect(g, col, cx - 2, h - 4 - dl, 4, dl)
            EscenaElipse(g, col, cx - 3, h - 4 - dl - 2, 6, 6)
        }
        ; El zigzag se EXPRIME en vivo: se dibuja progresivamente con el bote
        ; siguiendo la punta, pausa breve y vuelve a empezar
        prog := Min(1.0, Mod(tNow, 3400) / 2800.0)
        segsLlenos := prog * 9
        px := 4.0, py := 14.0
        loop 9 {
            nx := px + w / 9
            ny := Mod(A_Index, 2) ? 22.0 : 12.0
            if (A_Index <= Floor(segsLlenos)) {
                EscenaLinea(g, colD, px, py, nx, ny, 2.6)
            } else if (A_Index = Floor(segsLlenos) + 1) {
                f := segsLlenos - Floor(segsLlenos)
                mx2 := px + (nx - px) * f
                my2 := py + (ny - py) * f
                EscenaLinea(g, colD, px, py, mx2, my2, 2.6)
                EscenaPoligono(g, (235 << 24) | (230 << 16) | (60 << 8) | 40, [[mx2 - 1.5, my2 - 4], [mx2 + 1.5, my2 - 4], [mx2, my2]])
                EscenaRect(g, (235 << 24) | (230 << 16) | (180 << 8) | 30, mx2 - 4, my2 - 16, 8, 12)
            }
            px := nx, py := ny
        }
    case "palmera":
        ; Playa viva: sol con rayos girando lento + orilla con espuma + palmeras
        ; meciéndose con cocos
        sol := (205 << 24) | (255 << 16) | (210 << 8) | 60
        EscenaElipse(g, sol, w - 24, 6, 16, 16)
        loop 8 {
            ra := (A_Index - 1) * 0.785 + tNow / 4000.0
            EscenaLinea(g, sol, w - 16 + Cos(ra) * 12, 14 + Sin(ra) * 12, w - 16 + Cos(ra) * 16, 14 + Sin(ra) * 16, 1.4)
        }
        pts := []
        pts.Push([0, h])
        x := 0.0
        while (x <= w) {
            pts.Push([x, h - 4 + 2 * Sin(x / 18.0 + tNow / 550.0)])
            x += 10
        }
        pts.Push([w, h])
        EscenaPoligono(g, (140 << 24) | (90 << 16) | (200 << 8) | 215, pts)
        tronco := (210 << 24) | (150 << 16) | (100 << 8) | 50
        verde := (210 << 24) | (40 << 16) | (160 << 8) | 80
        loop 2 {
            cx := A_Index * w / 3
            EscenaLinea(g, tronco, cx, h - 3, cx - 3, h - 23, 3)
            ty := h - 23
            loop 5 {
                ang := 3.4 + (A_Index - 1) * 0.45 + Sin(tNow / 700.0 + A_Index) * 0.1
                EscenaLinea(g, verde, cx - 3, ty, cx - 3 + Cos(ang) * 14, ty + Sin(ang) * 9 + 9, 2)
            }
            EscenaElipse(g, (220 << 24) | (110 << 16) | (70 << 8) | 35, cx - 6, ty + 1, 4, 4)
            EscenaElipse(g, (220 << 24) | (110 << 16) | (70 << 8) | 35, cx - 1, ty + 2, 4, 4)
        }
        ; Cangrejo escabulléndose de lado por la orilla (patitas y pinzas)
        cgx := w * 0.5 + Sin(tNow / 1400.0) * w * 0.3
        cgy := h - 6.0
        EscenaElipse(g, (230 << 24) | (235 << 16) | (70 << 8) | 50, cgx - 6, cgy - 4, 12, 7)
        EscenaElipse(g, (240 << 24) | (40 << 16) | (30 << 8) | 25, cgx - 3, cgy - 6, 2, 2)   ; ojos
        EscenaElipse(g, (240 << 24) | (40 << 16) | (30 << 8) | 25, cgx + 1, cgy - 6, 2, 2)
        pinza := Sin(tNow / 220.0) * 1.5
        EscenaElipse(g, (230 << 24) | (245 << 16) | (90 << 8) | 60, cgx - 11, cgy - 5 - pinza, 5, 4)
        EscenaElipse(g, (230 << 24) | (245 << 16) | (90 << 8) | 60, cgx + 6, cgy - 5 + pinza, 5, 4)
        loop 3 {
            paso2 := Sin(tNow / 130.0 + A_Index * 2) * 1.5
            EscenaLinea(g, (220 << 24) | (210 << 16) | (60 << 8) | 40, cgx - 6 + A_Index * 4, cgy + 2, cgx - 8 + A_Index * 4, cgy + 4 + paso2, 1.2)
        }
        ; Cóctel clavado en la arena (vaso + pajita + sombrillita)
        ktx := w * 0.84
        EscenaPoligono(g, (200 << 24) | (255 << 16) | (160 << 8) | 60, [[ktx - 5, h - 14], [ktx + 5, h - 14], [ktx + 3, h - 4], [ktx - 3, h - 4]])
        EscenaLinea(g, (220 << 24) | (240 << 16) | (70 << 8) | 90, ktx + 1, h - 14, ktx + 4, h - 21, 1.2)   ; pajita
        EscenaLinea(g, (215 << 24) | (140 << 16) | (90 << 8) | 50, ktx - 2, h - 13, ktx - 6, h - 22, 1)     ; palo sombrilla
        EscenaPie(g, (220 << 24) | (250 << 16) | (90 << 8) | 110, ktx - 13, h - 26, 14, 12, 180, 180)       ; sombrillita
        ; Pez saltando fuera del agua en arco (ciclo 2.8s)
        pzc := Mod(tNow, 2800) / 2800.0
        if (pzc < 0.45) {
            pzp := pzc / 0.45
            pzx := w * 0.35 + pzp * w * 0.14
            pzy := h - 3 - Sin(pzp * 3.14159) * 13
            EscenaElipse(g, (220 << 24) | (90 << 16) | (200 << 8) | 230, pzx - 4, pzy - 2.5, 8, 5)
            EscenaPoligono(g, (220 << 24) | (90 << 16) | (200 << 8) | 230, [[pzx - 4, pzy], [pzx - 8, pzy - 3], [pzx - 8, pzy + 3]])
            EscenaElipse(g, (240 << 24) | (20 << 16) | (40 << 8) | 60, pzx + 1.5, pzy - 1.5, 1.6, 1.6)
        }
    case "ceniza":
        ; Suelo de rescoldos LATIENDO + columnas de humo serpenteante + ceniza cayendo
        EscenaRect(g, (160 << 24) | (45 << 16) | (40 << 8) | 38, 0, h - 5, w, 5)
        loop 6 {
            ex := (A_Index - 0.5) * w / 6
            gl := 0.5 + 0.5 * Sin(tNow / 320.0 + A_Index * 1.7)
            EscenaElipse(g, (Round(60 + 70 * gl) << 24) | (255 << 16) | (150 << 8) | 50, ex - 8, h - 10, 16, 9)   ; halo del rescoldo
            EscenaElipse(g, (Round(140 + 100 * gl) << 24) | (255 << 16) | (Round(70 + 90 * gl) << 8) | 15, ex - 4, h - 7, 8, 5)
        }
        ; humo que serpentea hacia arriba, se ensancha y se desvanece
        loop 3 {
            colH := A_Index
            sx := w * (0.2 + (colH - 1) * 0.3)
            sy := h - 10.0
            while (sy > 8) {
                prog := (h - sy) / h
                off := Sin(tNow / 900.0 + sy / 14.0 + colH * 2) * (3 + prog * 9)
                EscenaElipse(g, (Round(65 * (1 - prog)) << 24) | (175 << 16) | (175 << 8) | 175, sx + off - 3 - prog * 4, sy - 4, 6 + prog * 8, 6 + prog * 8)
                sy -= 11
            }
        }
        ; copos de ceniza cayendo con vaivén
        loop 7 {
            cx := Mod(A_Index * 53, Round(w - 10)) + 5 + Sin(tNow / 500.0 + A_Index) * 5
            cy := Mod(tNow / 18.0 + A_Index * 30, h + 20) - 10
            d := 2 + Mod(A_Index, 3) * 1.5
            EscenaElipse(g, (110 << 24) | (185 << 16) | (185 << 8) | 185, cx - d / 2, cy - d / 2, d, d)
        }
        ; chispas naranjas escapando de los rescoldos
        loop 3 {
            cx := Mod(A_Index * 97, Round(w - 10)) + 5 + Sin(tNow / 250.0 + A_Index * 3) * 4
            cy := Mod(h - tNow / 9.0 - A_Index * 50, h) - 5
            EscenaElipse(g, (220 << 24) | (255 << 16) | (140 << 8) | 30, cx - 1.5, cy - 1.5, 3, 3)
        }
    case "grafito":
        ; Hoja cuadriculada de fondo + boceto de un círculo a compás + trazos de
        ; boceto + lápices (grafito y uno de color) apoyados abajo + virutas
        loop 6 {
            gx := A_Index * w / 6
            EscenaLinea(g, (35 << 24) | (rC << 16) | (gC << 8) | bC, gx, 2, gx, h - 6, 1)
        }
        loop 9 {
            x1 := A_Index * w / 9
            EscenaLinea(g, (60 << 24) | (rC << 16) | (gC << 8) | bC, x1 - 12, h - 3, x1 + 4, h - 17, 1.1)
        }
        ccx := w * 0.66
        ccy := h * 0.32
        crad := 16 + 2 * Sin(tNow / 1100.0)
        EscenaAnillo(g, (130 << 24) | (rC << 16) | (gC << 8) | bC, ccx - crad, ccy - crad, crad * 2, 1)
        EscenaLinea(g, (90 << 24) | (rC << 16) | (gC << 8) | bC, ccx - crad - 4, ccy, ccx + crad + 4, ccy, 0.8)
        EscenaLinea(g, (90 << 24) | (rC << 16) | (gC << 8) | bC, ccx, ccy - crad - 4, ccx, ccy + crad + 4, 0.8)
        loop 3 {
            bx := w * 0.12 + (A_Index - 1) * (w * 0.3)
            by := h - 5 - Mod(A_Index, 2) * 4
            EscenaRect(g, (235 << 24) | (235 << 16) | (140 << 8) | 160, bx - 4, by - 3, 3.5, 4)              ; goma
            EscenaRect(g, (220 << 24) | (180 << 16) | (180 << 8) | 190, bx - 0.5, by - 3, 1.5, 4)            ; virola
            EscenaRect(g, (235 << 24) | (235 << 16) | (195 << 8) | 235, bx, by - 3, 28, 4)                   ; cuerpo madera
            EscenaRect(g, (150 << 24) | (255 << 16) | (250 << 8) | 215, bx, by - 3, 28, 1)                   ; brillo
            EscenaPoligono(g, (235 << 24) | (215 << 16) | (165 << 8) | 235, [[bx + 28, by - 3], [bx + 28, by + 1], [bx + 36, by - 1]])  ; punta madera
            EscenaPoligono(g, (245 << 24) | (55 << 16) | (55 << 8) | 65, [[bx + 33.5, by - 1.7], [bx + 36, by - 1], [bx + 33.5, by - 0.3]])  ; mina
        }
        rbx := w * 0.42
        rby := h - 9
        EscenaRect(g, (230 << 24) | (210 << 16) | (60 << 8) | 60, rbx, rby - 1.5, 24, 3)              ; cuerpo lápiz rojo
        EscenaPoligono(g, (230 << 24) | (235 << 16) | (200 << 8) | 170, [[rbx + 24, rby - 1.5], [rbx + 24, rby + 1.5], [rbx + 31, rby]])  ; punta madera
        EscenaPoligono(g, (245 << 24) | (110 << 16) | (40 << 8) | 40, [[rbx + 28.5, rby - 0.6], [rbx + 31, rby], [rbx + 28.5, rby + 0.6]])  ; mina roja
        loop 3 {
            shx := w * (0.2 + A_Index * 0.22)
            shy := h - 2.5
            EscenaPoligono(g, (150 << 24) | (225 << 16) | (200 << 8) | 130, [[shx, shy], [shx + 4, shy - 2.5], [shx + 7, shy - 0.5], [shx + 3, shy + 1]])
        }
        ; Lápiz DIBUJANDO en vivo: la punta va y viene y deja un trazo ondulado
        dprog := 0.5 + 0.5 * Sin(tNow / 1600.0)
        dx0 := w * 0.1
        dxf := dx0 + dprog * w * 0.34
        dy0 := h * 0.6
        dxs := dx0
        while (dxs < dxf) {
            EscenaLinea(g, (170 << 24) | (rC << 16) | (gC << 8) | bC, dxs, dy0 + Sin(dxs / 9.0) * 2.5, dxs + 4, dy0 + Sin((dxs + 4) / 9.0) * 2.5, 1.2)
            dxs += 4
        }
        EscenaLinea(g, (235 << 24) | (235 << 16) | (195 << 8) | 235, dxf + 2, dy0 - 3, dxf + 11, dy0 - 14, 3)   ; lápiz inclinado
        EscenaPoligono(g, (245 << 24) | (55 << 16) | (55 << 8) | 65, [[dxf, dy0 + Sin(dxf / 9.0) * 2.5], [dxf + 3.5, dy0 - 4.5], [dxf + 1, dy0 - 5.5]])  ; punta
        ; Avión de papel planeando (estilo boceto, con estela punteada)
        avp := Mod(tNow / 18.0, w + 50) - 25
        avy := h * 0.18 + Sin(avp / 26.0) * 5
        EscenaPoligono(g, (210 << 24) | (240 << 16) | (245 << 8) | 255, [[avp, avy], [avp - 11, avy + 4.5], [avp - 7, avy + 2]])
        EscenaPoligono(g, (165 << 24) | (200 << 16) | (210 << 8) | 225, [[avp, avy], [avp - 9, avy - 3], [avp - 7, avy + 2]])
        loop 4 {
            EscenaElipse(g, (Round(95 - A_Index * 20) << 24) | (rC << 16) | (gC << 8) | bC, avp - 14 - A_Index * 6, avy + 3 + Sin((avp - A_Index * 6) / 26.0) * 2, 1.6, 1.6)
        }
        ; Regla apoyada en el borde inferior derecho (con marcas)
        rgx := w * 0.72
        EscenaRect(g, (200 << 24) | (250 << 16) | (215 << 8) | 130, rgx, h - 6, w * 0.24, 4.5)
        loop 6 {
            EscenaLinea(g, (190 << 24) | (110 << 16) | (90 << 8) | 50, rgx + A_Index * (w * 0.24 / 7), h - 6, rgx + A_Index * (w * 0.24 / 7), h - 3.8, 0.8)
        }
    case "abisal":
        loop 10 {
            cx := Mod(A_Index * 47, Round(w - 10)) + 5
            cy := Mod(A_Index * 31, Round(h - 20)) + 10
            tw := 0.4 + 0.6 * (0.5 + 0.5 * Sin(tNow / 300.0 + A_Index))
            EscenaElipse(g, (Round(200 * tw) << 24) | (80 << 16) | (220 << 8) | 255, cx - 1.5, cy - 1.5, 3, 3)
        }
        mx := w * 0.5 + Sin(tNow / 700.0) * 30
        my := h * 0.5
        EscenaPie(g, (170 << 24) | (120 << 16) | (180 << 8) | 255, mx - 10, my - 8, 20, 16, 180, 180)
        loop 4 {
            tx := mx - 6 + A_Index * 3.5
            EscenaLinea(g, (140 << 24) | (120 << 16) | (180 << 8) | 255, tx, my, tx, my + 8 + Sin(tNow / 300.0 + A_Index) * 2, 1.2)
        }
    case "olas":
        loop 2 {
            capa := A_Index
            fase := tNow / 650.0 + capa * 1.6
            baseY := h - (capa = 1 ? 4 : 9)
            aA := capa = 1 ? 160 : 100
            pts := []
            pts.Push([0, h])
            x := 0.0
            while (x <= w) {
                pts.Push([x, baseY + 3.5 * Sin(x / 24.0 + fase)])
                x += 12
            }
            pts.Push([w, h])
            EscenaPoligono(g, (aA << 24) | (rC << 16) | (gC << 8) | bC, pts)
        }
        bx := Mod(tNow / 40.0, w + 40) - 20
        EscenaPoligono(g, (200 << 24) | (120 << 16) | (80 << 8) | 50, [[bx - 8, h - 12], [bx + 8, h - 12], [bx + 5, h - 8], [bx - 5, h - 8]])
        EscenaPoligono(g, (210 << 24) | (255 << 16) | (255 << 8) | 255, [[bx, h - 12], [bx, h - 22], [bx + 7, h - 13]])
    case "aurora":
        loop 6 {
            cx := A_Index * w / 7
            sway := Sin(tNow / 500.0 + A_Index) * 6
            loop 7 {
                yy := (A_Index - 1) * 4
                a := Round(110 * (1 - A_Index / 8))
                c := (A_Index < 5) ? ((a << 24) | (80 << 16) | (255 << 8) | 150) : ((a << 24) | (170 << 16) | (90 << 8) | 255)
                EscenaLinea(g, c, cx + sway, yy, cx + sway + Sin(tNow / 400.0 + A_Index) * 4, yy + 5, 3)
            }
        }
    case "ciudadneon":
        loop 7 {
            cx := (A_Index - 1) * w / 7
            bw := w / 7 - 2
            bh := 14 + Mod(A_Index * 7, 16)
            EscenaRect(g, (210 << 24) | (20 << 16) | (10 << 8) | 35, cx + 1, h - bh, bw, bh)
            loop 6 {
                wx := cx + 3 + Mod(A_Index, 3) * (bw / 3)
                wy := h - bh + 3 + ((A_Index - 1) // 3) * 5
                lit := Mod(A_Index * 3 + Round(cx), 5) < 3
                EscenaRect(g, (lit ? ((230 << 24) | (255 << 16) | (90 << 8) | 220) : ((120 << 24) | (60 << 16) | (40 << 8) | 80)), wx, wy, 2, 2.5)
            }
        }
        ; Ventanas que se encienden y apagan con el tiempo (vida en la ciudad)
        loop 8 {
            bIdx := Mod(A_Index * 3, 7) + 1
            bx2 := (bIdx - 1) * w / 7
            bh2 := 14 + Mod(bIdx * 7, 16)
            if (Mod(tNow / 700.0 + A_Index * 217, 9) < 4.5) {
                wx2 := bx2 + 3 + Mod(A_Index, 3) * ((w / 7 - 2) / 3)
                wy2 := h - bh2 + 3 + Mod(A_Index, 2) * 5
                EscenaRect(g, (240 << 24) | (120 << 16) | (240 << 8) | 255, wx2, wy2, 2, 2.5)
            }
        }
        ; Antena con luz roja parpadeante en el edificio más alto (el 2º)
        antX := w / 7 + 1 + (w / 7 - 2) / 2
        EscenaLinea(g, (220 << 24) | (90 << 16) | (90 << 8) | 110, antX, h - 28, antX, h - 35, 1.3)
        if (Mod(tNow, 1400) < 700)
            EscenaElipse(g, (245 << 24) | (255 << 16) | (60 << 8) | 90, antX - 2, h - 37, 4, 4)
        ; Coche volador: estela de luz cian cruzando el cielo
        fcx := Mod(tNow / 7.0, w + 60) - 30
        fcy := 5 + Sin(tNow / 900.0) * 3
        loop 4 {
            aT := 220 - A_Index * 50
            EscenaElipse(g, (aT << 24) | (90 << 16) | (220 << 8) | 255, fcx - A_Index * 5, fcy, 3.5 - A_Index * 0.6, 1.8)
        }
        ; Letrero de neón rosa parpadeante en un edificio
        flickN := (Sin(tNow / 120.0) > -0.7) ? 1.0 : 0.3
        snX := 4 * w / 7 + 3
        EscenaRect(g, (Round(200 * flickN) << 24) | (255 << 16) | (60 << 8) | 180, snX, h - 12, 8, 4)
        EscenaAnillo(g, (Round(150 * flickN) << 24) | (255 << 16) | (120 << 8) | 220, snX - 1.5, h - 13.5, 11, 1)
    case "circuito":
        ; Placa de circuito: pistas + pads + un chip + un pulso de luz viajando
        col := (170 << 24) | (40 << 16) | (210 << 8) | 150
        colBright := (235 << 24) | (130 << 16) | (255 << 8) | 210
        loop 3 {
            ty := h - 4 - (A_Index - 1) * 7
            EscenaLinea(g, col, 0, ty, w, ty, 1.3)
        }
        loop 7 {
            cx := (A_Index - 0.5) * w / 7
            topY := h - 4 - Mod(A_Index, 3) * 7
            EscenaLinea(g, col, cx, h, cx, topY, 1.2)
            EscenaAnillo(g, col, cx - 2.5, topY - 2.5, 5, 1.2)
        }
        chx := w * 0.3, chy := h - 19
        EscenaRect(g, (215 << 24) | (35 << 16) | (20 << 8) | 60, chx - 8, chy - 5, 16, 11)
        loop 4 {
            py := chy - 3 + (A_Index - 1) * 2.6
            EscenaLinea(g, col, chx - 12, py, chx - 8, py, 1)
            EscenaLinea(g, col, chx + 8, py, chx + 12, py, 1)
        }
        EscenaElipse(g, colBright, chx - 6, chy - 3, 2.5, 2.5)
        pulseX := Mod(tNow / 6.0, w)
        EscenaElipse(g, colBright, pulseX - 2.5, h - 6.5, 5, 5)
    case "pinos":
        ; Pinar nocturno: niebla baja que deriva + luciérnagas titilando entre los árboles
        EscenaPoligono(g, (70 << 24) | (200 << 16) | (210 << 8) | 215, [[0, h], [0, h - 5], [w, h - 5], [w, h]])
        verde := (215 << 24) | (30 << 16) | (75 << 8) | 45
        loop 6 {
            cx := (A_Index - 0.5) * w / 6
            ph := 16 + Mod(A_Index * 5, 8)
            EscenaPoligono(g, verde, [[cx - 7, h - 4], [cx + 7, h - 4], [cx, h - 4 - ph * 0.55]])
            EscenaPoligono(g, verde, [[cx - 5, h - 4 - ph * 0.4], [cx + 5, h - 4 - ph * 0.4], [cx, h - 4 - ph]])
        }
        loop 3 {
            nx := Mod(tNow / 120.0 + A_Index * w / 3, w + 80) - 40
            EscenaElipse(g, (45 << 24) | (220 << 16) | (225 << 8) | 230, nx - 30, h - 10 - A_Index * 3, 60, 7)
        }
        loop 4 {
            lx := Mod(A_Index * 73, Round(w - 16)) + 8 + Sin(tNow / 800.0 + A_Index * 2) * 6
            ly := h - 12 - Mod(A_Index * 7, 14) + Sin(tNow / 600.0 + A_Index) * 3
            tw := 0.5 + 0.5 * Sin(tNow / 350.0 + A_Index * 1.7)
            if (tw > 0.45)
                EscenaElipse(g, (Round(220 * tw) << 24) | (255 << 16) | (230 << 8) | 90, lx - 1.5, ly - 1.5, 3, 3)
        }
    case "cafe":
        taza := (220 << 24) | (235 << 16) | (240 << 8) | 245
        cafe := (220 << 24) | (90 << 16) | (55 << 8) | 30
        cx := w * 0.5
        EscenaRect(g, taza, cx - 11, h - 14, 22, 12)
        EscenaRect(g, cafe, cx - 9, h - 13, 18, 3)
        EscenaAnillo(g, taza, cx + 9, h - 12, 8, 2)
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (110 << 24) | (220 << 16) | (220 << 8) | 220, "Float", 1.4, "Int", 2, "Ptr*", &pen)
        loop 2 {
            vx := cx - 4 + A_Index * 6
            DllCall("gdiplus\GdipDrawArc", "Ptr", g, "Ptr", pen, "Float", vx - 3, "Float", h - 24 + Sin(tNow / 300.0 + A_Index) * 2, "Float", 6, "Float", 8, "Float", 90, "Float", 250)
        }
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
        ; Vapor que SUBE de verdad (volutas ascendiendo y desvaneciéndose)
        loop 3 {
            faseV := Mod(tNow / 16.0 + A_Index * 26, 34)
            aV := Round(170 * (1 - faseV / 34.0))
            vxr := cx - 7 + A_Index * 5 + Sin(tNow / 280.0 + A_Index * 1.6) * 2.5
            EscenaElipse(g, (aV << 24) | (230 << 16) | (230 << 8) | 232, vxr, h - 16 - faseV, 4, 3)
        }
        ; Granos de café esparcidos por la mesa (con su ranura característica)
        for fG in [0.08, 0.20, 0.33, 0.67, 0.81, 0.92] {
            gbx := w * fG
            EscenaElipse(g, (220 << 24) | (130 << 16) | (82 << 8) | 45, gbx - 3, h - 5, 6, 4.5)
            EscenaLinea(g, (210 << 24) | (75 << 16) | (45 << 8) | 22, gbx, h - 5, gbx, h - 0.5, 1.1)
        }
        ; Terrones de azúcar junto a la taza
        EscenaRect(g, (230 << 24) | (245 << 16) | (245 << 8) | 248, cx - 26, h - 6, 6, 5)
        EscenaRect(g, (205 << 24) | (222 << 16) | (222 << 8) | 228, cx - 20, h - 4, 5, 4)
        ; Cucharilla apoyada a la derecha
        EscenaLinea(g, (215 << 24) | (200 << 16) | (205 << 8) | 215, cx + 22, h - 1, cx + 31, h - 9, 1.6)
        EscenaElipse(g, (215 << 24) | (200 << 16) | (205 << 8) | 215, cx + 29, h - 13, 4.5, 5.5)
    case "portal":
        ; Vórtice: anillos pulsando + partículas ABSORBIDAS en espiral + arcos de energía
        cx := w * 0.5, cy := h * 0.5
        loop 5 {
            r := 6 + A_Index * 5 + Sin(tNow / 300.0 + A_Index) * 2
            a := Round(150 / A_Index)
            EscenaAnillo(g, (a << 24) | (170 << 16) | (60 << 8) | 255, cx - r, cy - r, r * 2, 1.6)
        }
        ; partículas espiralando hacia el centro (succión)
        loop 8 {
            sp := Mod(tNow / 1400.0 + A_Index * 0.125, 1.0)
            rr := (1 - sp) * 46 + 4
            a := sp * 14 + A_Index * 0.785
            EscenaElipse(g, (Round(90 + 150 * sp) << 24) | (200 << 16) | (120 << 8) | 255, cx + Cos(a) * rr * 1.35 - 1.8, cy + Sin(a) * rr * 0.75 - 1.8, 3.6, 3.6)
        }
        ; arcos de energía chisporroteando alrededor
        loop 3 {
            aa := tNow / 350.0 + A_Index * 2.094
            r1 := 24 + Sin(tNow / 180.0 + A_Index) * 4
            EscenaLinea(g, (170 << 24) | (220 << 16) | (140 << 8) | 255, cx + Cos(aa) * r1 * 1.3, cy + Sin(aa) * r1 * 0.72, cx + Cos(aa + 0.5) * (r1 + 7) * 1.3, cy + Sin(aa + 0.5) * (r1 + 7) * 0.72, 1.3)
        }
        ; núcleo brillante latiendo
        np := 0.5 + 0.5 * Sin(tNow / 220.0)
        EscenaElipse(g, (Round(80 + 60 * np) << 24) | (210 << 16) | (150 << 8) | 255, cx - 8, cy - 6, 16, 12)
        EscenaElipse(g, (230 << 24) | (230 << 16) | (180 << 8) | 255, cx - 3.5, cy - 3, 7, 6)
    case "tundra":
        loop 5 {
            cx := A_Index * w / 6
            EscenaLinea(g, (70 << 24) | (120 << 16) | (220 << 8) | 180, cx, 2, cx + 4, 9, 2)
        }
        EscenaPoligono(g, (200 << 24) | (235 << 16) | (245 << 8) | 255, [[0, h], [0, h - 5], [w, h - 7], [w, h]])
        loop 3 {
            cx := (A_Index - 0.5) * w / 3
            EscenaPoligono(g, (210 << 24) | (40 << 16) | (90 << 8) | 55, [[cx - 6, h - 5], [cx + 6, h - 5], [cx, h - 18]])
            EscenaPoligono(g, (180 << 24) | (240 << 16) | (248 << 8) | 255, [[cx - 6, h - 5], [cx + 6, h - 5], [cx, h - 9]])
        }
        ; Luna fría arriba-izquierda + estrellas titilando
        EscenaElipse(g, (210 << 24) | (220 << 16) | (240 << 8) | 250, 10, 3, 12, 12)
        EscenaElipse(g, (70 << 24) | (160 << 16) | (190 << 8) | 210, 14, 6, 3, 3)
        loop 6 {
            sxt := Mod(A_Index * 71, Round(w - 30)) + 26
            syt := 3 + Mod(A_Index * 17, 12)
            twT := 0.4 + 0.6 * (0.5 + 0.5 * Sin(tNow / 280.0 + A_Index * 1.3))
            EscenaElipse(g, (Round(200 * twT) << 24) | (235 << 16) | (245 << 8) | 255, sxt, syt, 2, 2)
        }
        ; Ráfagas de viento EN MOVIMIENTO cruzando (las rayitas fijas quedan de fondo)
        loop 3 {
            wxa := Mod(tNow / (10.0 + A_Index * 3) + A_Index * 90, w + 40) - 20
            wya := 8 + A_Index * 6
            EscenaLinea(g, (120 << 24) | (150 << 16) | (220 << 8) | 230, wxa, wya, wxa + 14, wya - 2, 1.4)
            EscenaLinea(g, (75 << 24) | (150 << 16) | (220 << 8) | 230, wxa - 8, wya + 2, wxa + 2, wya + 1, 1)
        }
        ; Nieve cayendo con deriva lateral
        loop 7 {
            nxt := Mod(A_Index * 47, Round(w - 8)) + 4 + Sin(tNow / 700.0 + A_Index) * 3
            nyt := Mod(tNow / 28.0 + A_Index * 39, h + 4) - 2
            EscenaElipse(g, (190 << 24) | (240 << 16) | (246 << 8) | 252, nxt, nyt, 2, 2)
        }
        ; Liebre ártica asomándose junto al árbol derecho
        lbx2 := w * 0.88
        asom := 0.5 + 0.5 * Sin(tNow / 1600.0)
        EscenaElipse(g, (215 << 24) | (245 << 16) | (248 << 8) | 252, lbx2 - 5, h - 6 - asom * 3, 10, 6 + asom * 3)
        EscenaElipse(g, (215 << 24) | (245 << 16) | (248 << 8) | 252, lbx2 - 3.5, h - 11 - asom * 3, 3, 6)
        EscenaElipse(g, (215 << 24) | (245 << 16) | (248 << 8) | 252, lbx2 + 0.5, h - 11 - asom * 3, 3, 6)
        EscenaElipse(g, (235 << 24) | (40 << 16) | (50 << 8) | 60, lbx2 - 2, h - 5 - asom * 3, 1.5, 1.5)
        EscenaElipse(g, (235 << 24) | (40 << 16) | (50 << 8) | 60, lbx2 + 1.5, h - 5 - asom * 3, 1.5, 1.5)
    case "submarino":
        loop 6 {
            cx := Mod(A_Index * 53, Round(w - 8)) + 4
            by := Mod(h - tNow / 22.0 - A_Index * 38, h + 20) - 10
            EscenaAnillo(g, (150 << 24) | (rC << 16) | (gC << 8) | bC, cx - 3, by - 3, 6, 1.3)
        }
        sx := Mod(tNow / 35.0, w + 50) - 25
        sub := (220 << 24) | (235 << 16) | (200 << 8) | 30
        EscenaElipse(g, sub, sx - 13, h - 16, 26, 11)
        EscenaRect(g, sub, sx - 2, h - 21, 4, 6)
        EscenaElipse(g, (220 << 24) | (120 << 16) | (210 << 8) | 255, sx - 4, h - 13, 5, 5)
    case "espadas":
        ; Espadas cruzadas: brillo recorriendo las hojas + chispas del choque + corona pulsante
        cx := w / 2
        acero := (220 << 24) | (210 << 16) | (215 << 8) | 230
        EscenaLinea(g, acero, cx - 14, h - 2, cx + 14, h - 20, 2.5)
        EscenaLinea(g, acero, cx + 14, h - 2, cx - 14, h - 20, 2.5)
        ; gleam: un punto de luz viaja por cada hoja
        gp := Mod(tNow / 1100.0, 1.0)
        EscenaElipse(g, (235 << 24) | (255 << 16) | (255 << 8) | 255, cx - 14 + 28 * gp - 2, h - 2 - 18 * gp - 2, 4, 4)
        EscenaElipse(g, (235 << 24) | (255 << 16) | (255 << 8) | 255, cx + 14 - 28 * gp - 2, h - 2 - 18 * gp - 2, 4, 4)
        EscenaLinea(g, (220 << 24) | (180 << 16) | (140 << 8) | 30, cx - 9, h - 6, cx - 3, h - 9, 2)
        EscenaLinea(g, (220 << 24) | (180 << 16) | (140 << 8) | 30, cx + 9, h - 6, cx + 3, h - 9, 2)
        ; chispas que saltan del cruce (estallido periódico)
        sp := Mod(tNow, 1400) / 1400.0
        if (sp < 0.45) {
            loop 5 {
                a := A_Index * 1.25 + 0.4
                rr := sp * 26
                aA := Round(230 * (1 - sp / 0.45))
                EscenaElipse(g, (aA << 24) | (255 << 16) | (220 << 8) | 90, cx + Cos(a) * rr - 1.2, h - 11 - Sin(a) * rr * 0.8 - 1.2, 2.4, 2.4)
            }
        }
        ; corona con pulso dorado + joya
        pulso := 0.5 + 0.5 * Sin(tNow / 400.0)
        EscenaPoligono(g, (Round(190 + 50 * pulso) << 24) | (255 << 16) | (Round(190 + 40 * pulso) << 8) | 40, [[cx - 8, h - 22], [cx - 8, h - 30], [cx - 3, h - 26], [cx, h - 32], [cx + 3, h - 26], [cx + 8, h - 30], [cx + 8, h - 22]])
        EscenaElipse(g, (220 << 24) | (255 << 16) | (60 << 8) | 90, cx - 1.5, h - 26.5, 3, 3)
    case "retrowave":
        ; Sol retro con bandas + horizonte + rejilla en perspectiva que AVANZA
        sx := w * 0.5, sy := 16
        loop 7 {
            a := Round(225 * (1 - A_Index / 9))
            EscenaPie(g, (a << 24) | (255 << 16) | (60 << 8) | (130 + A_Index * 15), sx - 17, sy - 17 + A_Index * 2.6, 34, 34, 180, 180)
        }
        ; bandas oscuras que cortan el sol (look clásico synthwave)
        loop 3 {
            EscenaRect(g, (200 << 24) | (15 << 16) | (5 << 8) | 30, sx - 18, sy - 2 + A_Index * 4, 36, 1.2 + A_Index * 0.4)
        }
        col := (170 << 24) | (255 << 16) | (40 << 8) | 200
        EscenaLinea(g, (220 << 24) | (255 << 16) | (70 << 8) | 220, 0, h - 16, w, h - 16, 1.6)
        ; verticales en abanico desde el punto de fuga
        loop 9 {
            fx := (A_Index - 5) * (w / 7)
            EscenaLinea(g, col, sx + fx * 0.12, h - 16, sx + fx, h, 1.1)
        }
        ; horizontales que aceleran hacia el espectador (scroll infinito)
        tt := Mod(tNow / 900.0, 1.0)
        loop 4 {
            p := Mod(tt + (A_Index - 1) * 0.25, 1.0)
            yy := h - 16 + p * p * 16
            EscenaLinea(g, (Round(60 + 160 * p) << 24) | (255 << 16) | (40 << 8) | 200, 0, yy, w, yy, 1 + p * 1.2)
        }
    case "chat":
        ; Mensajes estilo Discord: avatar de color + nombre + líneas de texto,
        ; badge rojo de notificación, reacción 👍 + "escribiendo..." + ❤ pop
        loop 3 {
            cx := Mod(A_Index * 89, Round(w - 52)) + 30
            cy := 10 + Mod(A_Index * 13, Round(h - 34)) + Sin(tNow / 500.0 + A_Index) * 4
            ; avatar circular con color de usuario (verde / rojo / amarillo Discord)
            colAv := A_Index = 1 ? (230 << 24) | (87 << 16) | (242 << 8) | 135
                : A_Index = 2 ? (230 << 24) | (237 << 16) | (66 << 8) | 69
                : (230 << 24) | (254 << 16) | (231 << 8) | 92
            EscenaElipse(g, colAv, cx - 22, cy - 6, 9, 9)
            EscenaElipse(g, (180 << 24) | (35 << 16) | (39 << 8) | 42, cx - 19.5, cy - 3.5, 4, 4)  ; "cara" hueca
            ; burbuja del mensaje
            EscenaRect(g, (200 << 24) | (88 << 16) | (101 << 8) | 242, cx - 10, cy - 7, 30, 14)
            EscenaPoligono(g, (200 << 24) | (88 << 16) | (101 << 8) | 242, [[cx - 10, cy - 2], [cx - 10, cy + 3], [cx - 13, cy]])
            ; nombre (línea corta de color del usuario) + texto (líneas blancas variadas)
            EscenaRect(g, colAv, cx - 7, cy - 5, 8, 1.6)
            EscenaRect(g, (210 << 24) | (255 << 16) | (255 << 8) | 255, cx - 7, cy - 1.5, 22 - Mod(A_Index * 5, 8), 2)
            EscenaRect(g, (160 << 24) | (255 << 16) | (255 << 8) | 255, cx - 7, cy + 2.5, 14 + Mod(A_Index * 7, 9), 2)
            ; badge rojo de notificación en el primer mensaje (parpadea suave)
            if (A_Index = 1) {
                bdg := 0.6 + 0.4 * Sin(tNow / 400.0)
                EscenaElipse(g, (Round(235 * bdg) << 24) | (237 << 16) | (66 << 8) | 69, cx + 16, cy - 10, 7, 7)
                EscenaElipse(g, (Round(245 * bdg) << 24) | (255 << 16) | (255 << 8) | 255, cx + 18.5, cy - 7.5, 2, 2)
            }
            ; pill de reacción 👍 bajo el segundo mensaje (saltito ocasional)
            if (A_Index = 2) {
                rj := Mod(tNow, 2000) > 1750 ? 2 : 0
                EscenaRect(g, (190 << 24) | (60 << 16) | (65 << 8) | 90, cx - 7, cy + 8 - rj, 14, 6)
                EscenaElipse(g, (225 << 24) | (254 << 16) | (231 << 8) | 92, cx - 5, cy + 9.2 - rj, 3.5, 3.5)
                EscenaRect(g, (210 << 24) | (255 << 16) | (255 << 8) | 255, cx + 1, cy + 10 - rj, 4, 2)
            }
        }
        ; burbuja "escribiendo..." — los 3 puntos saltan en secuencia
        tx := w * 0.72, ty := h - 18
        EscenaRect(g, (210 << 24) | (70 << 16) | (80 << 8) | 200, tx - 14, ty - 7, 28, 14)
        loop 3 {
            bounce := Sin(tNow / 180.0 - (A_Index - 1) * 0.9)
            off := bounce > 0 ? bounce * 3.5 : 0
            EscenaElipse(g, (230 << 24) | (255 << 16) | (255 << 8) | 255, tx - 8 + (A_Index - 1) * 6.5, ty - 1.5 - off, 3.5, 3.5)
        }
        ; reacción ❤ que aparece con "pop" y se queda un momento (ciclo 2.4s)
        hp := Mod(tNow, 2400) / 2400.0
        if (hp < 0.55) {
            hs := Min(1.0, hp / 0.12)
            hx := w * 0.22, hy := h - 16
            d := 9 * hs
            EscenaElipse(g, (230 << 24) | (240 << 16) | (70 << 8) | 90, hx - d * 0.55, hy - d * 0.35, d * 0.62, d * 0.62)
            EscenaElipse(g, (230 << 24) | (240 << 16) | (70 << 8) | 90, hx - d * 0.07, hy - d * 0.35, d * 0.62, d * 0.62)
            EscenaPoligono(g, (230 << 24) | (240 << 16) | (70 << 8) | 90, [[hx - d * 0.52, hy], [hx + d * 0.52, hy], [hx, hy + d * 0.55]])
        }
    case "mira":
        ; La mira PATRULLA buscando blancos; cada ~3 s fija uno (lock rojo + onda)
        cx := w * 0.5 + Sin(tNow / 1300.0) * w * 0.18 + Sin(tNow / 700.0) * 6
        cy := h * 0.5 + Cos(tNow / 1100.0) * h * 0.15
        lockT := Mod(tNow, 3000) / 3000.0
        locked := lockT > 0.82
        col := locked ? ((240 << 24) | (255 << 16) | (60 << 8) | 60) : ((210 << 24) | (255 << 16) | (70 << 8) | 85)
        EscenaAnillo(g, col, cx - 12, cy - 12, 24, locked ? 2.2 : 1.4)
        ; marcas tácticas del anillo exterior, rotando
        loop 4 {
            a := tNow / 800.0 + (A_Index - 1) * 1.5708
            EscenaLinea(g, col, cx + Cos(a) * 15, cy + Sin(a) * 15, cx + Cos(a) * 20, cy + Sin(a) * 20, 1.6)
        }
        ; cruz interior — respira, y se CONTRAE al fijar blanco
        gap := locked ? 4 : 6 + Sin(tNow / 250.0) * 1.5
        EscenaLinea(g, col, cx - 18, cy, cx - gap, cy, 2)
        EscenaLinea(g, col, cx + gap, cy, cx + 18, cy, 2)
        EscenaLinea(g, col, cx, cy - 18, cx, cy - gap, 2)
        EscenaLinea(g, col, cx, cy + gap, cx, cy + 18, 2)
        EscenaElipse(g, col, cx - 1.5, cy - 1.5, 3, 3)
        ; onda expansiva del lock
        if (locked) {
            lp := (lockT - 0.82) / 0.18
            EscenaAnillo(g, (Round(200 * (1 - lp)) << 24) | (255 << 16) | (60 << 8) | 60, cx - 12 - lp * 14, cy - 12 - lp * 14, 24 + lp * 28, 1.5)
        }
    case "cielo":
        ; Sol con rayos girando + nubes a la deriva + pájaros aleteando
        scx := w - 17, scy := 15
        EscenaElipse(g, (210 << 24) | (255 << 16) | (235 << 8) | 130, scx - 9, scy - 9, 18, 18)
        loop 8 {
            a := (A_Index - 1) * 0.785 + tNow / 3000.0
            EscenaLinea(g, (160 << 24) | (255 << 16) | (235 << 8) | 130, scx + Cos(a) * 11, scy + Sin(a) * 11, scx + Cos(a) * 15, scy + Sin(a) * 15, 1.6)
        }
        nube := (200 << 24) | (255 << 16) | (255 << 8) | 255
        loop 3 {
            drift := Mod(tNow / 55.0 + A_Index * w / 3, w + 60) - 30
            cy := 6 + Mod(A_Index * 10, 18)
            EscenaElipse(g, nube, drift - 11, cy, 22, 11)
            EscenaElipse(g, nube, drift - 3, cy - 5, 15, 13)
            EscenaElipse(g, nube, drift + 6, cy, 15, 11)
        }
        ; pájaros (uves aleteando) cruzando a media altura
        loop 3 {
            bx := Mod(tNow / 38.0 + A_Index * w / 3, w + 30) - 15
            by2 := h * 0.45 + Mod(A_Index * 9, 14) + Sin(tNow / 700.0 + A_Index) * 3
            wf := 3 + Sin(tNow / 150.0 + A_Index * 2) * 2.5
            EscenaLinea(g, (190 << 24) | (90 << 16) | (110 << 8) | 140, bx - 5, by2 - wf, bx, by2, 1.4)
            EscenaLinea(g, (190 << 24) | (90 << 16) | (110 << 8) | 140, bx, by2, bx + 5, by2 - wf, 1.4)
        }
    case "matrixlluvia":
        ; Columnas de código con CABEZA blanca brillante + estela que se apaga
        loop 12 {
            colM := A_Index
            cx := (colM - 0.5) * w / 12
            vel := 6.0 + Mod(colM * 7, 5)
            headY := Mod(tNow / vel + colM * 37, h + 30) - 15
            loop 6 {
                ty := headY - A_Index * 5
                if (ty < -4 || ty > h)
                    continue
                a := 235 - A_Index * 38
                EscenaRect(g, (a << 24) | (40 << 16) | (Round(255 - A_Index * 14) << 8) | 90, cx - 1.5, ty, 3, 4)
            }
            if (headY > -4 && headY < h)
                EscenaRect(g, (250 << 24) | (190 << 16) | (255 << 8) | 190, cx - 1.5, headY, 3, 4)
        }
    case "naruto":
        ; Remolinos que GIRAN de verdad (rasengan) + motas de chakra orbitando
        loop 2 {
            cx := A_Index * w / 3
            cy := h - 14
            rot := tNow / 350.0 * (Mod(A_Index, 2) ? 1 : -1)
            px := cx, py := cy
            loop 16 {
                a := A_Index * 0.6 + rot
                r := A_Index * 0.7
                nx := cx + Cos(a) * r
                ny := cy + Sin(a) * r
                if (A_Index > 1)
                    EscenaLinea(g, (220 << 24) | (255 << 16) | (120 << 8) | 20, px, py, nx, ny, 2)
                px := nx, py := ny
            }
            loop 3 {
                oa := tNow / 280.0 + A_Index * 2.09
                EscenaElipse(g, (200 << 24) | (120 << 16) | (200 << 8) | 255, cx + Cos(oa) * 13 - 1.5, cy + Sin(oa) * 13 - 1.5, 3, 3)
            }
        }
        ; Shuriken GIRANDO que cruza la pantalla (4 puntas + agujero central)
        shkx := Mod(tNow / 9.0, w + 40) - 20
        shky := h * 0.25 + Sin(shkx / 30.0) * 4
        rotS := tNow / 90.0
        loop 4 {
            angSh := rotS + (A_Index - 1) * 1.5708
            EscenaPoligono(g, (225 << 24) | (70 << 16) | (75 << 8) | 85,
                [[shkx + Cos(angSh) * 9, shky + Sin(angSh) * 9],
                 [shkx + Cos(angSh + 0.5) * 3, shky + Sin(angSh + 0.5) * 3],
                 [shkx + Cos(angSh - 0.5) * 3, shky + Sin(angSh - 0.5) * 3]])
        }
        EscenaAnillo(g, (230 << 24) | (180 << 16) | (185 << 8) | 195, shkx - 2, shky - 2, 4, 1.4)
        ; Kunai clavado en el suelo (hoja + mango con anilla)
        knx := w * 0.86
        EscenaPoligono(g, (225 << 24) | (160 << 16) | (165 << 8) | 175, [[knx, h], [knx + 6, h - 9], [knx + 8.5, h - 6]])  ; hoja clavada
        EscenaLinea(g, (220 << 24) | (60 << 16) | (50 << 8) | 45, knx + 6, h - 9, knx + 10, h - 15, 2)                     ; mango
        EscenaAnillo(g, (220 << 24) | (160 << 16) | (165 << 8) | 175, knx + 9, h - 19, 5, 1.3)                              ; anilla
        ; Llamas de chakra naranja flameando en el borde inferior
        loop 5 {
            fxc := (A_Index - 0.5) * w / 5
            fh := 5 + 3 * Sin(tNow / 160.0 + A_Index * 1.9) + 2 * Sin(tNow / 90.0 + A_Index * 3.1)
            EscenaPoligono(g, (150 << 24) | (255 << 16) | (130 << 8) | 30, [[fxc - 5, h], [fxc + 5, h], [fxc + Sin(tNow / 200.0 + A_Index) * 2, h - fh]])
        }
    case "onepiece":
        ; Mar en movimiento + Jolly Roger del Sombrero de Paja balanceándose + gaviotas
        loop 2 {
            capa := A_Index
            fase := tNow / 600.0 + capa * 1.4
            baseY := h - (capa = 1 ? 3 : 7)
            pts := []
            pts.Push([0, h])
            x := 0.0
            while (x <= w) {
                pts.Push([x, baseY + 2.5 * Sin(x / 20.0 + fase)])
                x += 10
            }
            pts.Push([w, h])
            EscenaPoligono(g, ((capa = 1 ? 150 : 100) << 24) | (rC << 16) | (gC << 8) | bC, pts)
        }
        cx := w * 0.5 + Sin(tNow / 900.0) * 4
        cy := h * 0.42 + Sin(tNow / 700.0) * 2
        hueso := (210 << 24) | (235 << 16) | (235 << 8) | 235
        EscenaLinea(g, hueso, cx - 12, cy + 8, cx + 12, cy - 8, 3)
        EscenaLinea(g, hueso, cx + 12, cy + 8, cx - 12, cy - 8, 3)
        ; calavera con cuencas
        EscenaElipse(g, hueso, cx - 7, cy - 9, 14, 12)
        EscenaElipse(g, (220 << 24) | (30 << 16) | (30 << 8) | 30, cx - 4.5, cy - 5, 3, 4)
        EscenaElipse(g, (220 << 24) | (30 << 16) | (30 << 8) | 30, cx + 1.5, cy - 5, 3, 4)
        ; sombrero de paja con banda roja
        EscenaPie(g, (225 << 24) | (240 << 16) | (200 << 8) | 70, cx - 11, cy - 16, 22, 14, 180, 180)
        EscenaRect(g, (225 << 24) | (240 << 16) | (200 << 8) | 70, cx - 13, cy - 10, 26, 2.6)
        EscenaRect(g, (225 << 24) | (200 << 16) | (40 << 8) | 40, cx - 11, cy - 11.5, 22, 2)
        ; gaviotas cruzando
        loop 2 {
            gvx := Mod(tNow / 30.0 + A_Index * w / 2, w + 30) - 15
            gvy := 8 + A_Index * 7 + Sin(tNow / 400.0 + A_Index) * 2
            EscenaLinea(g, (170 << 24) | (235 << 16) | (235 << 8) | 240, gvx - 4, gvy, gvx, gvy - 2.5, 1.3)
            EscenaLinea(g, (170 << 24) | (235 << 16) | (235 << 8) | 240, gvx, gvy - 2.5, gvx + 4, gvy, 1.3)
        }
    case "eclipse":
        loop 8 {
            sx := Mod(A_Index * 71, Round(w - 14)) + 7
            sy := 4 + Mod(A_Index * 17, 30)
            EscenaElipse(g, (180 << 24) | (255 << 16) | (210 << 8) | 130, sx - 1, sy - 1, 2, 2)
        }
        cx := w * 0.5, cy := h * 0.45
        loop 14 {
            a := (A_Index - 1) * 0.449
            cor := 16 + Sin(tNow / 250.0 + A_Index) * 3
            EscenaLinea(g, (160 << 24) | (255 << 16) | (170 << 8) | 30, cx + Cos(a) * 13, cy + Sin(a) * 13, cx + Cos(a) * cor, cy + Sin(a) * cor, 1.6)
        }
        EscenaElipse(g, (240 << 24) | (10 << 16) | (8 << 8) | 14, cx - 12, cy - 12, 24, 24)
        EscenaAnillo(g, (220 << 24) | (255 << 16) | (200 << 8) | 60, cx - 12, cy - 12, 24, 1.5)
    case "void":
        col := (230 << 24) | (255 << 16) | (20 << 8) | 20
        loop 4 {
            bx := (A_Index - 0.5) * w / 4
            px := bx, py := 0.0
            loop 6 {
                nx := bx + (Mod(A_Index, 2) ? 8 : -8) + Sin(tNow / 400.0 + A_Index) * 2
                ny := A_Index * (h / 6)
                EscenaLinea(g, col, px, py, nx, ny, 1.8)
                px := nx, py := ny
            }
        }
        loop 5 {
            cx := Mod(A_Index * 67, Round(w - 10)) + 5
            cy := Mod(A_Index * 43, Round(h - 10)) + 5
            tw := 0.5 + 0.5 * Sin(tNow / 200.0 + A_Index)
            EscenaElipse(g, (Round(220 * tw) << 24) | (255 << 16) | (30 << 8) | 30, cx - 1.5, cy - 1.5, 3, 3)
        }
    case "fenix":
        ; Llamas en el suelo + FÉNIX volando con alas batiendo y estela de chispas
        loop 7 {
            cx := (A_Index - 0.5) * w / 7
            fl := 0.5 + 0.5 * Sin(tNow / 140.0 + A_Index)
            alt := 10 + 11 * fl
            EscenaPoligono(g, (210 << 24) | (255 << 16) | (Round(120 + 100 * fl) << 8) | 20, [[cx - 4, h - 2], [cx + 4, h - 2], [cx + 2, h - 2 - alt * 0.6], [cx, h - 2 - alt], [cx - 2, h - 2 - alt * 0.6]])
        }
        fx := Mod(tNow / 28.0, w + 70) - 35
        fy := h * 0.32 + Sin(tNow / 600.0) * 8
        flap := Sin(tNow / 160.0)
        cuerpo := (235 << 24) | (255 << 16) | (150 << 8) | 30
        ala    := (220 << 24) | (255 << 16) | (90 << 8) | 20
        ; estela de chispas doradas desvaneciéndose
        loop 6 {
            tp := A_Index / 6.0
            ty := h * 0.32 + Sin((tNow - A_Index * 130) / 600.0) * 8
            EscenaElipse(g, (Round(170 * (1 - tp)) << 24) | (255 << 16) | (190 << 8) | 60, fx - 12 - A_Index * 7, ty - 2, 4 - tp * 2, 4 - tp * 2)
        }
        EscenaPoligono(g, ala, [[fx - 6, fy], [fx - 18, fy - 4], [fx - 16, fy + 3]])      ; cola
        EscenaElipse(g, cuerpo, fx - 7, fy - 3, 14, 7)                                     ; cuerpo
        EscenaElipse(g, cuerpo, fx + 5, fy - 4, 6, 6)                                      ; cabeza
        EscenaPoligono(g, (235 << 24) | (255 << 16) | (220 << 8) | 80, [[fx + 11, fy - 2], [fx + 15, fy - 1], [fx + 11, fy]])  ; pico
        EscenaPoligono(g, ala, [[fx - 2, fy - 1], [fx - 8, fy - 6 - flap * 7], [fx + 4, fy - 3]])   ; ala arriba
        EscenaPoligono(g, ala, [[fx - 2, fy + 1], [fx - 8, fy + 4 + flap * 5], [fx + 4, fy + 2]])   ; ala abajo
    case "diamantes":
        ; Gemas talladas ARCOÍRIS (cada una cicla su color) + lluvia de motitas + corona
        ; (las siluetas blancas de antes no lucían sobre el fondo premium)
        loop 5 {
            cx := Mod(A_Index * 79, Round(w - 20)) + 10
            cy := 10 + Mod(A_Index * 17, Round(h - 24)) + Sin(tNow / 400.0 + A_Index) * 4
            tw := 0.6 + 0.4 * Sin(tNow / 220.0 + A_Index * 2)
            ; color arcoíris propio de cada gema, rotando con el tiempo
            hG := tNow / 700.0 + A_Index * 1.26
            rG := Round(150 + 105 * Sin(hG))
            gG := Round(150 + 105 * Sin(hG + 2.094))
            bG := Round(150 + 105 * Sin(hG + 4.189))
            aG2 := Round(225 * tw)
            ; talla de diamante: corona (trapecio) + pabellón (V) + mesa + facetas
            EscenaPoligono(g, (aG2 << 24) | (rG << 16) | (gG << 8) | bG, [[cx - 5, cy - 2], [cx - 2.5, cy - 5], [cx + 2.5, cy - 5], [cx + 5, cy - 2]])
            EscenaPoligono(g, (Round(aG2 * 0.85) << 24) | (Round(rG * 0.7) << 16) | (Round(gG * 0.7) << 8) | Round(bG * 0.7), [[cx - 5, cy - 2], [cx + 5, cy - 2], [cx, cy + 6]])
            EscenaLinea(g, (Round(200 * tw) << 24) | (255 << 16) | (255 << 8) | 255, cx - 2.5, cy - 5, cx + 2.5, cy - 5, 1)   ; mesa brillante
            EscenaLinea(g, (Round(120 * tw) << 24) | (255 << 16) | (255 << 8) | 255, cx - 2.5, cy - 2, cx, cy + 6, 0.8)        ; facetas
            EscenaLinea(g, (Round(120 * tw) << 24) | (255 << 16) | (255 << 8) | 255, cx + 2.5, cy - 2, cx, cy + 6, 0.8)
            ; halo de color alrededor cuando brilla fuerte + destello en cruz
            if (tw > 0.9) {
                sp := (tw - 0.9) / 0.1
                EscenaElipse(g, (Round(70 * sp) << 24) | (rG << 16) | (gG << 8) | bG, cx - 9, cy - 9, 18, 18)
                EscenaLinea(g, (Round(220 * sp) << 24) | (255 << 16) | (255 << 8) | 255, cx - 7, cy, cx + 7, cy, 1.2)
                EscenaLinea(g, (Round(220 * sp) << 24) | (255 << 16) | (255 << 8) | 255, cx, cy - 8, cx, cy + 8, 1.2)
            }
        }
        ; motitas de brillo cayendo lento
        loop 4 {
            gx := Mod(A_Index * 61, Round(w - 12)) + 6
            gy := Mod(tNow / 50.0 + A_Index * 45, h + 10) - 5
            EscenaElipse(g, (170 << 24) | (230 << 16) | (245 << 8) | 255, gx - 1.2, gy - 1.2, 2.4, 2.4)
        }
        cx := w * 0.5
        EscenaPoligono(g, (220 << 24) | (255 << 16) | (215 << 8) | 40, [[cx - 10, h - 4], [cx - 10, h - 12], [cx - 4, h - 8], [cx, h - 14], [cx + 4, h - 8], [cx + 10, h - 12], [cx + 10, h - 4]])
        ; gemas de la corona titilando
        loop 3 {
            gt := 0.5 + 0.5 * Sin(tNow / 260.0 + A_Index * 2.1)
            EscenaElipse(g, (Round(120 + 130 * gt) << 24) | (255 << 16) | (90 << 8) | 120, cx - 7 + (A_Index - 1) * 7 - 1.5, h - 9, 3, 3)
        }
    case "solnika":
        ; Sol de Nika en ROJO + DORADO (el tema es blanco puro: los tonos crema
        ; de antes eran invisibles) — halo que respira + rayos girando + chispas
        cx := w * 0.5, cy := h * 0.42
        halo := 0.5 + 0.5 * Sin(tNow / 900.0)
        EscenaElipse(g, (Round(35 + 45 * halo) << 24) | (204 << 16) | (0 << 8) | 0, cx - 18, cy - 18, 36, 36)         ; halo rojo suave
        EscenaElipse(g, (235 << 24) | (255 << 16) | (170 << 8) | 30, cx - 11, cy - 11, 22, 22)                          ; núcleo dorado
        EscenaAnillo(g, (240 << 24) | (204 << 16) | (0 << 8) | 0, cx - 11, cy - 11, 22, 2)                              ; contorno carmesí
        loop 12 {
            a := (A_Index - 1) * 0.523 + tNow / 2400.0
            len := (Mod(A_Index, 2) ? 19 : 16) + halo * 2
            EscenaLinea(g, (230 << 24) | (204 << 16) | (10 << 8) | 10, cx + Cos(a) * 13, cy + Sin(a) * 13, cx + Cos(a) * len, cy + Sin(a) * len, 2.2)
        }
        loop 5 {
            a := -tNow / 1500.0 + A_Index * 1.2566
            tw := 0.5 + 0.5 * Sin(tNow / 240.0 + A_Index * 2)
            EscenaElipse(g, (Round(220 * tw) << 24) | (235 << 16) | (60 << 8) | 20, cx + Cos(a) * 24 - 1.5, cy + Sin(a) * 24 - 1.5, 3, 3)
        }
        ; Sonrisa de Nika en el núcleo (arco rojo) + nubes con borde rojo a los lados
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (235 << 24) | (180 << 16) | (0 << 8) | 0, "Float", 1.8, "Int", 2, "Ptr*", &pen)
        DllCall("gdiplus\GdipDrawArc", "Ptr", g, "Ptr", pen, "Float", cx - 6, "Float", cy - 5, "Float", 12, "Float", 10, "Float", 20, "Float", 140)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
        loop 2 {
            esIzqN := A_Index = 1
            ncx := esIzqN ? w * 0.13 : w * 0.87
            ncy := h * 0.7 + Sin(tNow / 800.0 + A_Index * 2) * 3
            EscenaElipse(g, (190 << 24) | (204 << 16) | (30 << 8) | 30, ncx - 14, ncy - 5, 28, 11)
            EscenaElipse(g, (235 << 24) | (255 << 16) | (245 << 8) | 240, ncx - 12, ncy - 4, 24, 9)
        }
    case "lavanda":
        ; Campo de lavanda meciéndose en ola + pétalos a la deriva
        verdeL := (200 << 24) | (70 << 16) | (150 << 8) | 80
        loop 8 {
            cx := (A_Index - 0.5) * w / 8
            sway := Sin(tNow / 750.0 - cx / 40.0) * 2.2
            EscenaLinea(g, verdeL, cx, h, cx + sway, h - 15, 1.4)
            loop 5 {
                yy := h - 8 - A_Index * 1.8
                EscenaElipse(g, (210 << 24) | (150 << 16) | (110 << 8) | 230, cx + sway * ((h - yy) / 15.0) - 1.6, yy - 1.6, 3.2, 3.2)
            }
        }
        loop 3 {
            py2 := Mod(tNow / 32.0 + A_Index * (h / 3.0), h + 10) - 5
            px2 := Mod(A_Index * 89, Round(w - 14)) + 7 + Sin(py2 / 15.0 + A_Index) * 6
            EscenaElipse(g, (180 << 24) | (170 << 16) | (130 << 8) | 235, px2 - 1.8, py2 - 1.4, 3.6, 2.8)
        }
        ; Abeja zumbando sobre el campo de lavanda
        bx2 := w * 0.5 + Cos(tNow / 600.0) * w * 0.38
        by2 := h * 0.55 + Sin(tNow / 420.0) * 6
        flapB := Abs(Sin(tNow / 90.0)) * 3
        EscenaElipse(g, (140 << 24) | (255 << 16) | (255 << 8) | 255, bx2 - 4, by2 - 3 - flapB, 3, 2)
        EscenaElipse(g, (140 << 24) | (255 << 16) | (255 << 8) | 255, bx2 + 1, by2 - 3 - flapB, 3, 2)
        EscenaElipse(g, (220 << 24) | (255 << 16) | (210 << 8) | 40, bx2 - 3, by2 - 2, 6, 4)
        EscenaLinea(g, (230 << 24) | (40 << 16) | (40 << 8) | 40, bx2 - 2, by2 - 2, bx2 - 2, by2 + 2, 1)
        EscenaLinea(g, (230 << 24) | (40 << 16) | (40 << 8) | 40, bx2, by2 - 2, bx2, by2 + 2, 1)
    case "atardecer":
        ; Atardecer: franjas cálidas + medio sol en el horizonte
        loop 4 {
            a := 120 - A_Index * 22
            EscenaRect(g, (a << 24) | (255 << 16) | (Round(120 - A_Index * 15) << 8) | (80 + A_Index * 20), 0, h - 4 - A_Index * 4, w, 4)
        }
        EscenaPie(g, (220 << 24) | (255 << 16) | (150 << 8) | 40, w * 0.5 - 16, h - 16, 32, 32, 180, 180)
        ; Halo pulsante alrededor del sol
        hp := 0.5 + 0.5 * Sin(tNow / 1100.0)
        EscenaPie(g, (Round(50 + 35 * hp) << 24) | (255 << 16) | (180 << 8) | 60, w * 0.5 - 22, h - 22, 44, 44, 180, 180)
        ; Rayos del sol oscilando suavemente
        loop 5 {
            angS := 3.14159 + (A_Index - 0.5) * (3.14159 / 5) + Sin(tNow / 1400.0) * 0.05
            EscenaLinea(g, (170 << 24) | (235 << 16) | (120 << 8) | 30, w * 0.5 + Cos(angS) * 18, h + Sin(angS) * 18, w * 0.5 + Cos(angS) * 26, h + Sin(angS) * 26, 1.5)
        }
        ; Pájaros volviendo a casa (siluetas V que aletean cruzando el cielo)
        loop 2 {
            esP1 := A_Index = 1
            bxa := Mod(tNow / (esP1 ? 28.0 : 36.0) + (esP1 ? 0 : 140), w + 30) - 15
            bya := (esP1 ? 8 : 15) + Sin(tNow / 500.0 + A_Index * 2) * 2
            flapA := Abs(Sin(tNow / 160.0 + A_Index)) * 3
            EscenaLinea(g, (210 << 24) | (90 << 16) | (45 << 8) | 60, bxa - 4, bya - flapA, bxa, bya, 1.4)
            EscenaLinea(g, (210 << 24) | (90 << 16) | (45 << 8) | 60, bxa, bya, bxa + 4, bya - flapA, 1.4)
        }
        ; Nube cálida derivando lentamente
        nxa := Mod(tNow / 110.0, w + 50) - 50
        EscenaElipse(g, (95 << 24) | (255 << 16) | (190 << 8) | 140, nxa, 4, 26, 7)
        EscenaElipse(g, (85 << 24) | (255 << 16) | (200 << 8) | 160, nxa + 12, 2, 18, 6)
        ; Primer lucero de la tarde titilando (naranja profundo, visible sobre fondo claro)
        twE := 0.4 + 0.6 * (0.5 + 0.5 * Sin(tNow / 320.0))
        EscenaElipse(g, (Round(225 * twE) << 24) | (210 << 16) | (75 << 8) | 25, w * 0.13, 5, 2.6, 2.6)
    case "jungla":
        ; Selva: árboles de copa redonda frondosa + lianas colgando
        tronco := (220 << 24) | (74 << 16) | (48 << 8) | 24
        v1 := (220 << 24) | (30 << 16) | (110 << 8) | 45
        v2 := (210 << 24) | (60 << 16) | (150 << 8) | 70
        loop 5 {
            lx := A_Index * w / 6
            ll := 12 + Mod(A_Index * 7, 14)
            EscenaLinea(g, v1, lx, 0, lx + Sin(tNow / 700.0 + A_Index) * 3, ll, 1.4)
            EscenaElipse(g, v2, lx - 2, ll - 2, 4, 5)
        }
        loop 3 {
            cx := (A_Index - 0.5) * w / 3
            EscenaRect(g, tronco, cx - 2.5, h - 14, 5, 14)
            EscenaElipse(g, v1, cx - 11, h - 24, 14, 14)
            EscenaElipse(g, v1, cx - 2, h - 25, 14, 14)
            EscenaElipse(g, v2, cx - 6, h - 20, 12, 12)
            EscenaElipse(g, v2, cx + 2, h - 21, 11, 11)
        }
    case "sangre":
        ; Sangre goteando del borde superior + charco abajo
        rojo := (225 << 24) | (150 << 16) | (0 << 8) | 8
        rojoB := (235 << 24) | (200 << 16) | (10 << 8) | 18
        loop 7 {
            cx := (A_Index - 0.5) * w / 7
            dl := 7 + Mod(A_Index * 5, 13) + Sin(tNow / 500.0 + A_Index) * 2
            EscenaRect(g, rojo, cx - 1.5, 0, 3, dl)
            EscenaElipse(g, rojo, cx - 2.5, dl - 2, 5, 6)
            gy := Mod(tNow / 8.0 + A_Index * 40, h)
            if (gy > dl + 4)
                EscenaElipse(g, rojoB, cx - 1.5, gy, 3, 4)
        }
        EscenaPoligono(g, rojo, [[0, h], [0, h - 4], [w, h - 6], [w, h]])
        loop 4 {
            cx := (A_Index - 0.5) * w / 4
            EscenaElipse(g, rojo, cx - 8, h - 9, 16, 9)
        }
    case "lava":
        ; Lava burbujeante abajo con burbujas que suben + chispas
        EscenaPoligono(g, (230 << 24) | (255 << 16) | (110 << 8) | 0, [[0, h], [0, h - 8], [w, h - 8], [w, h]])
        EscenaPoligono(g, (215 << 24) | (210 << 16) | (40 << 8) | 0, [[0, h], [0, h - 4], [w, h - 4], [w, h]])
        loop 6 {
            cx := (A_Index - 0.5) * w / 6
            bub := Abs(Sin(tNow / 600.0 + A_Index))
            by := h - 4 - bub * 8
            d := 3 + bub * 4
            EscenaElipse(g, (230 << 24) | (255 << 16) | (Round(140 + 100 * bub) << 8) | 20, cx - d / 2, by - d / 2, d, d)
        }
        loop 4 {
            cx := Mod(A_Index * 83, Round(w - 10)) + 5
            sy := h - 8 - Mod(tNow / 10.0 + A_Index * 30, 24)
            EscenaElipse(g, (220 << 24) | (255 << 16) | (210 << 8) | 60, cx - 1.2, sy - 1.2, 2.6, 2.6)
        }
    case "electrico":
        ; Rayos en zigzag destellando + chispas
        on := (Sin(tNow / 120.0) > 0.3) || (Sin(tNow / 55.0) > 0.7)
        loop 3 {
            bx := (A_Index - 0.5) * w / 3 + Sin(tNow / 300.0 + A_Index) * 5
            col := ((on ? 240 : 90) << 24) | (180 << 16) | (220 << 8) | 255
            px := bx, py := 0.0
            loop 5 {
                nx := bx + (Mod(A_Index, 2) ? 6 : -6)
                ny := A_Index * (h / 5)
                EscenaLinea(g, col, px, py, nx, ny, 2)
                px := nx, py := ny
            }
        }
        loop 6 {
            cx := Mod(A_Index * 61, Round(w - 10)) + 5
            cy := Mod(A_Index * 47, Round(h - 10)) + 5
            tw := 0.5 + 0.5 * Sin(tNow / 100.0 + A_Index)
            EscenaElipse(g, (Round(220 * tw) << 24) | (200 << 16) | (230 << 8) | 255, cx - 1.5, cy - 1.5, 3, 3)
        }
    case "glitch":
        ; Artefactos corruptos (RGB split) + líneas de escaneo
        loop 7 {
            seed := A_Index * 97 + (tNow // 200) * 13
            bx := Mod(seed * 7, Round(w - 30))
            by := Mod(seed * 11, Round(h - 10))
            bw := 12 + Mod(seed, 40)
            bh := 3 + Mod(seed, 6)
            EscenaRect(g, (150 << 24) | (0 << 16) | (255 << 8) | 255, bx - 2, by, bw, bh)
            EscenaRect(g, (150 << 24) | (255 << 16) | (0 << 8) | 255, bx + 2, by, bw, bh)
            EscenaRect(g, (180 << 24) | (230 << 16) | (230 << 8) | 230, bx, by, bw, bh)
        }
        loop 3 {
            sy := Mod(tNow / 6.0 + A_Index * h / 3, h)
            EscenaRect(g, (60 << 24) | (0 << 16) | (255 << 8) | 180, 0, sy, w, 1.5)
        }
    case "veneno":
        ; Charco tóxico ondulado + burbujas que revientan + goteo
        toxico := (220 << 24) | (160 << 16) | (255 << 8) | 20
        toxD := (230 << 24) | (120 << 16) | (200 << 8) | 10
        pts := []
        pts.Push([0, h])
        x := 0.0
        while (x <= w) {
            pts.Push([x, h - 6 + 2.5 * Sin(x / 20.0 + tNow / 500.0)])
            x += 10
        }
        pts.Push([w, h])
        EscenaPoligono(g, toxico, pts)
        loop 6 {
            cx := (A_Index - 0.5) * w / 6
            by := h - 6 - Abs(Sin(tNow / 500.0 + A_Index * 1.1)) * 9
            d := 3 + Abs(Sin(tNow / 500.0 + A_Index * 1.1)) * 4
            EscenaAnillo(g, toxD, cx - d / 2, by - d / 2, d, 1.4)
        }
        loop 3 {
            cx := A_Index * w / 4
            gy := Mod(tNow / 14.0 + A_Index * 50, h)
            EscenaElipse(g, toxico, cx - 2, gy, 4, 6)
        }
    case "cobre":
        ; Tuberías de cobre con remaches + una válvula (steampunk)
        cob := (230 << 24) | (200 << 16) | (115 << 8) | 60
        cobL := (200 << 24) | (235 << 16) | (160 << 8) | 100
        cobD := (230 << 24) | (140 << 16) | (75 << 8) | 35
        loop 2 {
            py := h - 6 - (A_Index - 1) * 9
            EscenaRect(g, cob, 0, py, w, 6)
            EscenaRect(g, cobL, 0, py, w, 1.5)
            EscenaRect(g, cobD, 0, py + 5, w, 1)
            loop 9 {
                rx := (A_Index - 0.5) * w / 9
                EscenaElipse(g, cobD, rx - 1.5, py + 2, 3, 3)
            }
        }
        EscenaAnillo(g, cob, w - 24, h - 26, 16, 3)
        loop 8 {
            a := (A_Index - 1) * 0.785
            EscenaLinea(g, cob, w - 16 + Cos(a) * 8, h - 18 + Sin(a) * 8, w - 16 + Cos(a) * 11, h - 18 + Sin(a) * 11, 2)
        }
        ; Vapor a presión escapando de dos juntas de la tubería
        loop 2 {
            jx := w * (A_Index = 1 ? 0.22 : 0.61)
            faseS := Mod(tNow / 14.0 + A_Index * 19, 28)
            aS2 := Round(170 * (1 - faseS / 28.0))
            EscenaElipse(g, (aS2 << 24) | (225 << 16) | (218 << 8) | 210, jx + faseS * 0.4, h - 16 - faseS, 4 + faseS * 0.25, 3.5 + faseS * 0.2)
            EscenaElipse(g, (Round(aS2 * 0.6) << 24) | (225 << 16) | (218 << 8) | 210, jx - 3 + faseS * 0.3, h - 13 - faseS * 0.8, 3, 2.6)
        }
        ; Manómetro con aguja que tiembla (presión)
        mgx := 22, mgy := h - 26
        EscenaElipse(g, (225 << 24) | (240 << 16) | (230 << 8) | 215, mgx - 8, mgy - 8, 16, 16)
        EscenaAnillo(g, cobD, mgx - 8, mgy - 8, 16, 1.6)
        agA := 3.9 + Sin(tNow / 300.0) * 0.5 + Sin(tNow / 90.0) * 0.12
        EscenaLinea(g, (240 << 24) | (200 << 16) | (40 << 8) | 30, mgx, mgy, mgx + Cos(agA) * 6, mgy + Sin(agA) * 6, 1.6)
        EscenaElipse(g, cobD, mgx - 1.5, mgy - 1.5, 3, 3)
        ; Engranaje girando junto a la válvula
        egx := w - 44, egy := h - 24
        rotE := tNow / 600.0
        loop 6 {
            aE := rotE + (A_Index - 1) * 1.047
            EscenaLinea(g, cobL, egx + Cos(aE) * 5, egy + Sin(aE) * 5, egx + Cos(aE) * 8.5, egy + Sin(aE) * 8.5, 2.4)
        }
        EscenaElipse(g, cob, egx - 5, egy - 5, 10, 10)
        EscenaElipse(g, (220 << 24) | (60 << 16) | (35 << 8) | 18, egx - 2, egy - 2, 4, 4)
        ; Chispa ocasional saltando de la tubería
        if (Mod(tNow, 1800) < 200) {
            spP := Mod(tNow, 1800) / 200.0
            EscenaElipse(g, (Round(240 * (1 - spP)) << 24) | (255 << 16) | (220 << 8) | 90, w * 0.45 + spP * 8, h - 16 - spP * 10, 2.5, 2.5)
        }
    case "vino":
        ; Copas de vino + racimo de uvas
        vino := (215 << 24) | (110 << 16) | (10 << 8) | 40
        vidrio := (90 << 24) | (220 << 16) | (220 << 8) | 235
        uva := (215 << 24) | (90 << 16) | (20 << 8) | 70
        loop 3 {
            cx := (A_Index - 0.5) * w / 3
            EscenaPie(g, vidrio, cx - 7, h - 22, 14, 16, 0, 180)
            ; vino oscilando dentro de la copa (superficie inclinada, remolino)
            tilt := Sin(tNow / 500.0 + A_Index * 1.3) * 2
            EscenaPie(g, vino, cx - 5.5, h - 19 + Abs(tilt) * 0.3, 11, 11, 0, 180)
            EscenaLinea(g, (230 << 24) | (160 << 16) | (30 << 8) | 60, cx - 5.5, h - 19 + tilt, cx + 5.5, h - 19 - tilt, 1.4)
            EscenaRect(g, vidrio, cx - 0.7, h - 12, 1.4, 8)
            EscenaRect(g, vidrio, cx - 5, h - 4, 10, 1.6)
            ; burbuja subiendo y destello en el cristal
            bub := Mod(tNow / 600.0 + A_Index * 0.7, 1.0)
            EscenaElipse(g, (Round(150 * (1 - bub)) << 24) | (255 << 16) | (180 << 8) | 200, cx - 1 + Sin(bub * 9) * 2, h - 14 - bub * 5, 2, 2)
            tw := 0.5 + 0.5 * Sin(tNow / 700.0 + A_Index * 2.1)
            if (tw > 0.75)
                EscenaLinea(g, (Round(200 * tw) << 24) | (255 << 16) | (255 << 8) | 255, cx - 6, h - 21, cx - 3, h - 22, 1.2)
        }
        ox := w - 22, oy := 6
        loop 6 {
            gx := ox + Mod(A_Index - 1, 3) * 5
            gy := oy + ((A_Index - 1) // 3) * 5
            EscenaElipse(g, uva, gx - 2.5, gy - 2.5, 5, 5)
        }
        ; Botella de vino con etiqueta y reflejo
        btx := w * 0.08
        EscenaRect(g, (225 << 24) | (35 << 16) | (60 << 8) | 35, btx - 4.5, h - 22, 9, 22)            ; cuerpo verde botella
        EscenaRect(g, (225 << 24) | (35 << 16) | (60 << 8) | 35, btx - 1.8, h - 30, 3.6, 9)           ; cuello
        EscenaRect(g, (230 << 24) | (110 << 16) | (10 << 8) | 40, btx - 1.8, h - 32, 3.6, 3)          ; cápsula granate
        EscenaRect(g, (220 << 24) | (235 << 16) | (225 << 8) | 205, btx - 3.5, h - 17, 7, 8)          ; etiqueta
        EscenaLinea(g, (200 << 24) | (110 << 16) | (10 << 8) | 40, btx - 2, h - 14.5, btx + 2, h - 14.5, 1)
        EscenaLinea(g, (160 << 24) | (110 << 16) | (10 << 8) | 40, btx - 2, h - 12, btx + 2, h - 12, 0.8)
        EscenaLinea(g, (120 << 24) | (235 << 16) | (240 << 8) | 245, btx - 3, h - 21, btx - 3, h - 8, 1)  ; reflejo
        ; Racimo grande de uvas con hoja de parra (esquina inferior derecha)
        rux := w - 16, ruy := h - 14
        loop 9 {
            ugx := rux + (Mod(A_Index - 1, 3) - 1) * 4.6 + (((A_Index - 1) // 3) * 2.3)
            ugy := ruy + ((A_Index - 1) // 3) * 4.4
            EscenaElipse(g, uva, ugx - 2.6, ugy - 2.6, 5.2, 5.2)
            EscenaElipse(g, (120 << 24) | (220 << 16) | (120 << 8) | 160, ugx - 1.4, ugy - 1.6, 1.6, 1.6)  ; brillito
        }
        EscenaPoligono(g, (205 << 24) | (90 << 16) | (150 << 8) | 60, [[rux - 1, ruy - 4], [rux - 9, ruy - 11], [rux - 1, ruy - 9], [rux + 4, ruy - 12], [rux + 3, ruy - 5]])  ; hoja
        EscenaLinea(g, (200 << 24) | (110 << 16) | (75 << 8) | 40, rux, ruy - 4, rux + 2, ruy - 12, 1.2)   ; tallo
        ; Vela encendida con llama que baila y halo cálido (entre las copas 2 y 3)
        vlx := w * 0.68
        EscenaRect(g, (220 << 24) | (235 << 16) | (225 << 8) | 200, vlx - 2.5, h - 30, 5, 9)
        EscenaLinea(g, (200 << 24) | (60 << 16) | (50 << 8) | 45, vlx, h - 30, vlx, h - 32, 1)
        llm := Sin(tNow / 130.0) * 1.2 + Sin(tNow / 71.0) * 0.6
        EscenaElipse(g, (Round(55 + 25 * Sin(tNow / 350.0)) << 24) | (255 << 16) | (170 << 8) | 60, vlx - 6 + llm, h - 41, 12, 12)  ; halo
        EscenaElipse(g, (230 << 24) | (255 << 16) | (180 << 8) | 60, vlx - 2 + llm, h - 38, 4, 7)   ; llama
        EscenaElipse(g, (240 << 24) | (255 << 16) | (240 << 8) | 180, vlx - 1 + llm * 0.7, h - 36, 2, 4)  ; núcleo
    case "bambu":
        ; Cañas de bambú verticales en los LATERALES (marco), hojas que se mecen
        caña := (210 << 24) | (90 << 16) | (170 << 8) | 70
        nodo := (220 << 24) | (50 << 16) | (110 << 8) | 45
        hoja := (200 << 24) | (110 << 16) | (190 << 8) | 90
        xs := [5, 14, w - 14, w - 5]
        for idx, cx in xs {
            EscenaRect(g, caña, cx - 2.5, 0, 5, h)
            yy := 6.0
            while (yy < h) {
                EscenaRect(g, nodo, cx - 2.5, yy, 5, 1.6)
                yy += 15
            }
            loop 3 {
                ly := 16 + (A_Index - 1) * (h / 3)
                sway := Sin(tNow / 600.0 + idx + A_Index) * 4
                dir := (cx < w / 2) ? 1 : -1
                EscenaPoligono(g, hoja, [[cx + dir * 2, ly], [cx + dir * (13 + sway), ly - 5], [cx + dir * 3, ly + 4]])
            }
        }
    case "sakura":
        ; Rama de cerezo ARRIBA con flores de 5 pétalos (los pétalos caen como partículas)
        rama := (215 << 24) | (120 << 16) | (80 << 8) | 60
        EscenaLinea(g, rama, 0, 5, w, 13, 3)
        EscenaLinea(g, rama, w * 0.25, 8, w * 0.25 + 12, 1, 2)
        EscenaLinea(g, rama, w * 0.6, 11, w * 0.6 + 10, 3, 2)
        loop 7 {
            fx := A_Index * w / 8
            fy := 11 + Mod(A_Index * 5, 8) + Mod(A_Index, 2) * 4
            loop 5 {
                ang := (A_Index - 1) * 1.2566 + Sin(tNow / 900.0 + fx) * 0.08
                EscenaElipse(g, (235 << 24) | (255 << 16) | (150 << 8) | 195, fx + Cos(ang) * 4 - 2.6, fy + Sin(ang) * 4 - 2.6, 5.2, 5.2)
            }
            EscenaElipse(g, (240 << 24) | (255 << 16) | (210 << 8) | 80, fx - 1.8, fy - 1.8, 3.6, 3.6)
        }
        ; Pajarito cruzando el cielo
        bxs := Mod(tNow / 30.0, w + 20) - 10
        bys := h * 0.06
        flapS := Sin(tNow / 150.0) * 2
        EscenaLinea(g, (190 << 24) | (140 << 16) | (90 << 8) | 110, bxs - 4, bys - flapS, bxs, bys, 1.2)
        EscenaLinea(g, (190 << 24) | (140 << 16) | (90 << 8) | 110, bxs, bys, bxs + 4, bys - flapS, 1.2)
        ; Pétalos acumulados en el suelo
        loop 3 {
            px3 := w * (0.15 + A_Index * 0.32)
            EscenaElipse(g, (200 << 24) | (255 << 16) | (215 << 8) | 225, px3 - 4, h - 3, 8, 3)
        }
    case "rosa":
        ; Rosas meciéndose suave + pétalos cayendo en zigzag
        loop 4 {
            cx := (A_Index - 0.5) * w / 4
            sway := Sin(tNow / 800.0 + A_Index * 1.1) * 1.8
            EscenaLinea(g, (200 << 24) | (30 << 16) | (110 << 8) | 40, cx, h, cx + sway, h - 11, 1.6)
            EscenaPoligono(g, (200 << 24) | (30 << 16) | (120 << 8) | 45, [[cx, h - 6], [cx + 7, h - 9], [cx + 2, h - 4]])
            ry := h - 14
            EscenaElipse(g, (235 << 24) | (150 << 16) | (10 << 8) | 30, cx + sway - 5.5, ry - 5.5, 11, 11)
            EscenaElipse(g, (235 << 24) | (205 << 16) | (25 << 8) | 55, cx + sway - 3.4, ry - 3.4, 6.8, 6.8)
            EscenaElipse(g, (240 << 24) | (255 << 16) | (70 << 8) | 95, cx + sway - 1.5, ry - 1.5, 3, 3)
        }
        loop 3 {
            py2 := Mod(tNow / 30.0 + A_Index * (h / 3.0), h + 10) - 5
            px2 := Mod(A_Index * 83, Round(w - 14)) + 7 + Sin(py2 / 16.0 + A_Index) * 6
            EscenaElipse(g, (190 << 24) | (220 << 16) | (40 << 8) | 70, px2 - 2.5, py2 - 1.8, 5, 3.6)
        }
        ; Corazoncitos flotando hacia arriba, desvaneciéndose
        loop 2 {
            hxr := Mod(A_Index * 101, Round(w - 14)) + 7
            hyr := h - Mod(tNow / 26.0 + A_Index * (h / 2.0), h + 14)
            al := Round(200 * (1 - (h - hyr) / h))
            colH := (al << 24) | (240 << 16) | (90 << 8) | 140
            EscenaElipse(g, colH, hxr - 2.5, hyr - 2, 3, 3)
            EscenaElipse(g, colH, hxr + 0.5, hyr - 2, 3, 3)
            EscenaPoligono(g, colH, [[hxr - 2.5, hyr - 0.5], [hxr + 3.5, hyr - 0.5], [hxr + 0.5, hyr + 3]])
        }
    case "lila":
        ; Racimos de lilas meciéndose — distinto de lavanda — con florecillas a la deriva
        loop 4 {
            cx := (A_Index - 0.5) * w / 4
            sway := Sin(tNow / 820.0 + A_Index * 1.4) * 1.8
            EscenaLinea(g, (200 << 24) | (70 << 16) | (130 << 8) | 70, cx, h, cx + sway, h - 11, 1.6)
            EscenaElipse(g, (200 << 24) | (60 << 16) | (140 << 8) | 70, cx - 6, h - 10, 7, 4)
            EscenaElipse(g, (200 << 24) | (60 << 16) | (140 << 8) | 70, cx + 1, h - 10, 7, 4)
            loop 10 {
                row := (A_Index - 1) // 3
                colp := Mod(A_Index - 1, 3)
                spread := 6 - row * 1.5
                fx := cx + sway + (colp - 1) * spread
                fy := h - 13 - row * 4.5
                EscenaElipse(g, (220 << 24) | (180 << 16) | (120 << 8) | 235, fx - 2.4, fy - 2.4, 4.8, 4.8)
            }
        }
        loop 3 {
            py2 := Mod(tNow / 34.0 + A_Index * (h / 3.0), h + 10) - 5
            px2 := Mod(A_Index * 97, Round(w - 14)) + 7 + Sin(py2 / 14.0 + A_Index) * 5
            EscenaElipse(g, (175 << 24) | (190 << 16) | (135 << 8) | 240, px2 - 1.6, py2 - 1.6, 3.2, 3.2)
        }
        ; Mariposa malva revoloteando entre los racimos
        bxl := w * 0.5 + Sin(tNow / 1100.0) * w * 0.3
        byl := h * 0.4 + Sin(tNow / 500.0) * 5
        flapL := Abs(Sin(tNow / 120.0))
        EscenaElipse(g, (210 << 24) | (200 << 16) | (140 << 8) | 230, bxl - 4 * flapL - 1, byl - 2, 4 * flapL + 1, 4)
        EscenaElipse(g, (210 << 24) | (200 << 16) | (140 << 8) | 230, bxl, byl - 2, 4 * flapL + 1, 4)
        EscenaLinea(g, (200 << 24) | (60 << 16) | (40 << 8) | 80, bxl, byl - 3, bxl, byl + 3, 1.2)
    case "melocoton":
        ; Melocotones colgando de una rama ARRIBA (se mecen)
        rama := (200 << 24) | (90 << 16) | (60 << 8) | 40
        EscenaLinea(g, rama, 0, 7, w, 7, 2.2)
        loop 4 {
            cx := (A_Index - 0.5) * w / 4 + Sin(tNow / 700.0 + A_Index) * 2
            EscenaLinea(g, rama, cx, 7, cx, 14, 1.2)
            fy := 21
            EscenaElipse(g, (225 << 24) | (255 << 16) | (175 << 8) | 135, cx - 7, fy - 7, 14, 15)
            EscenaElipse(g, (140 << 24) | (255 << 16) | (120 << 8) | 95, cx - 1, fy - 5, 6, 8)
            EscenaLinea(g, (150 << 24) | (210 << 16) | (110 << 8) | 80, cx, fy - 7, cx, fy + 7, 1.2)
            EscenaPoligono(g, (210 << 24) | (70 << 16) | (170 << 8) | 70, [[cx, fy - 7], [cx + 8, fy - 11], [cx + 1, fy - 4]])
        }
        ; Hojas extra repartidas por la rama
        loop 3 {
            hxm := A_Index * w / 3.5 + 10
            EscenaPoligono(g, (200 << 24) | (80 << 16) | (160 << 8) | 70, [[hxm, 7], [hxm + 9, 3], [hxm + 2, 9]])
        }
        ; Pétalos rosa de flor de melocotón cayendo
        loop 4 {
            pxm := Mod(A_Index * 61, Round(w - 8)) + 4 + Sin(tNow / 600.0 + A_Index * 2) * 4
            pym := Mod(tNow / 26.0 + A_Index * 43, h + 8) - 4
            EscenaElipse(g, (200 << 24) | (245 << 16) | (140 << 8) | 160, pxm, pym, 3.5, 2.5)
        }
        ; Melocotón caído en el suelo con su hoja
        mfx := w * 0.78
        EscenaElipse(g, (225 << 24) | (255 << 16) | (175 << 8) | 135, mfx - 6, h - 11, 13, 11)
        EscenaElipse(g, (130 << 24) | (255 << 16) | (120 << 8) | 95, mfx - 2, h - 9, 5, 6)
        EscenaPoligono(g, (210 << 24) | (70 << 16) | (170 << 8) | 70, [[mfx, h - 11], [mfx + 7, h - 14], [mfx + 1, h - 8]])
        ; Hierba meciéndose en el suelo
        loop 6 {
            gxm := (A_Index - 0.5) * w / 6
            EscenaLinea(g, (190 << 24) | (110 << 16) | (190 << 8) | 90, gxm, h, gxm + Sin(tNow / 600.0 + A_Index) * 1.5, h - 6, 1.3)
        }
        ; Mariposa rosada revoloteando entre los melocotones
        bxm := w * 0.3 + Sin(tNow / 900.0) * w * 0.22
        bym := h * 0.45 + Sin(tNow / 460.0) * 5
        flapM := 0.4 + 0.6 * Abs(Sin(tNow / 110.0))
        EscenaElipse(g, (215 << 24) | (235 << 16) | (90 << 8) | 120, bxm - 4 * flapM, bym - 2, 4 * flapM, 5)
        EscenaElipse(g, (215 << 24) | (235 << 16) | (90 << 8) | 120, bxm, bym - 2, 4 * flapM, 5)
        EscenaElipse(g, (230 << 24) | (120 << 16) | (60 << 8) | 50, bxm - 1, bym - 2.5, 2, 6)
    case "naranja":
        ; Naranjas colgando de una rama ARRIBA (se mecen)
        rama := (200 << 24) | (90 << 16) | (60 << 8) | 40
        EscenaLinea(g, rama, 0, 7, w, 7, 2.2)
        loop 4 {
            cx := (A_Index - 0.5) * w / 4 + Sin(tNow / 700.0 + A_Index * 1.3) * 2
            EscenaLinea(g, rama, cx, 7, cx, 13, 1.2)
            fy := 20
            EscenaElipse(g, (228 << 24) | (255 << 16) | (140 << 8) | 20, cx - 7, fy - 7, 14, 14)
            EscenaElipse(g, (110 << 24) | (255 << 16) | (210 << 8) | 130, cx - 4, fy - 5, 5, 4)
            EscenaPoligono(g, (210 << 24) | (50 << 16) | (160 << 8) | 55, [[cx, fy - 7], [cx + 7, fy - 10], [cx + 1, fy - 4]])
        }
        ; Flores de azahar (blancas) en la rama
        loop 2 {
            fxa := w * (A_Index = 1 ? 0.16 : 0.6)
            loop 5 {
                angA := (A_Index - 1) * 1.2566
                EscenaElipse(g, (225 << 24) | (255 << 16) | (250 << 8) | 240, fxa + Cos(angA) * 3 - 1.5, 7 + Sin(angA) * 3 - 1.5, 3, 3)
            }
            EscenaElipse(g, (240 << 24) | (250 << 16) | (200 << 8) | 60, fxa - 1.5, 5.5, 3, 3)
        }
        ; Rodaja de naranja asomando en la esquina derecha (con sus gajos)
        rsx := w * 0.9
        EscenaPie(g, (230 << 24) | (255 << 16) | (150 << 8) | 30, rsx - 14, h - 13, 28, 28, 180, 180)
        EscenaPie(g, (235 << 24) | (255 << 16) | (210 << 8) | 140, rsx - 11, h - 10, 22, 22, 180, 180)
        loop 4 {
            angG := 180 + (A_Index - 0.5) * 45
            EscenaPie(g, (225 << 24) | (255 << 16) | (165 << 8) | 50, rsx - 9, h - 8, 18, 18, angG - 16, 32)
        }
        ; Naranja rodando por el suelo (con brillo que gira)
        rox := Mod(tNow / 35.0, w + 24) - 12
        EscenaElipse(g, (228 << 24) | (255 << 16) | (140 << 8) | 20, rox - 6, h - 12, 12, 12)
        EscenaElipse(g, (160 << 24) | (255 << 16) | (210 << 8) | 130, rox - 1.5 + Cos(tNow / 200.0) * 3, h - 7.5 + Sin(tNow / 200.0) * 3, 3, 3)
        ; Hojitas verdes cayendo
        loop 3 {
            hxn := Mod(A_Index * 83, Round(w - 10)) + 5 + Sin(tNow / 500.0 + A_Index) * 4
            hyn := Mod(tNow / 30.0 + A_Index * 47, h + 6) - 3
            EscenaPoligono(g, (195 << 24) | (60 << 16) | (150 << 8) | 60, [[hxn, hyn], [hxn + 6, hyn - 3], [hxn + 1, hyn + 2]])
        }
    case "miel":
        ; Panal en la esquina superior-derecha + abeja volando
        amb  := (215 << 24) | (255 << 16) | (190 << 8) | 30
        ambD := (235 << 24) | (210 << 16) | (140 << 8) | 10
        celdas := [[0, 0], [1, 0], [0.5, 0.87], [-0.5, 0.87], [1.5, 0.87], [1, 1.74]]
        ox := w - 28, oy := 8
        for ci, c in celdas {
            cx := ox + c[1] * 13
            cy := oy + c[2] * 13
            rr := 7
            hex := []
            loop 6 {
                a := (A_Index - 1) * 1.0472 + 0.5236
                hex.Push([cx + Cos(a) * rr, cy + Sin(a) * rr])
            }
            EscenaPoligono(g, (Mod(ci, 2) ? amb : ambD), hex)
        }
        ; Abeja en trayectoria
        bt := tNow / 700.0
        bx := w * 0.42 + Cos(bt) * (w * 0.30)
        by := 18 + Sin(bt * 2) * 10
        EscenaElipse(g, (150 << 24) | (255 << 16) | (255 << 8) | 255, bx - 5, by - 6, 5, 4)
        EscenaElipse(g, (150 << 24) | (255 << 16) | (255 << 8) | 255, bx + 1, by - 6, 5, 4)
        EscenaElipse(g, (235 << 24) | (255 << 16) | (200 << 8) | 20, bx - 4, by - 3, 8, 6)
        EscenaRect(g, (235 << 24) | (30 << 16) | (24 << 8) | 16, bx - 2, by - 3, 1.6, 6)
        EscenaRect(g, (235 << 24) | (30 << 16) | (24 << 8) | 16, bx + 1, by - 3, 1.6, 6)
        ; Miel goteando del panal (gota viscosa que se estira y cae)
        gotF := Mod(tNow, 2200) / 2200.0
        gmx := ox + 6.5
        if (gotF < 0.45) {
            estir := gotF / 0.45 * 9
            EscenaLinea(g, ambD, gmx, oy + 26, gmx, oy + 26 + estir, 2.2)
            EscenaElipse(g, ambD, gmx - 2, oy + 24 + estir, 4, 5)
        } else {
            caida := (gotF - 0.45) / 0.55
            EscenaElipse(g, ambD, gmx - 2, oy + 33 + caida * (h - oy - 38), 4, 5.5)
        }
        ; Charco de miel abajo con cazo de miel (honey dipper)
        chx := w * 0.2
        EscenaElipse(g, (200 << 24) | (235 << 16) | (165 << 8) | 20, chx - 16, h - 6, 32, 6)
        EscenaElipse(g, (150 << 24) | (255 << 16) | (215 << 8) | 80, chx - 8, h - 5, 10, 2.5)   ; brillo del charco
        EscenaLinea(g, (220 << 24) | (170 << 16) | (115 << 8) | 45, chx + 2, h - 6, chx + 13, h - 22, 2)   ; mango
        loop 3 {
            EscenaElipse(g, (225 << 24) | (190 << 16) | (130 << 8) | 50, chx + 9 - A_Index, h - 24 + A_Index * 2.6, 8 + A_Index * 1.6, 2.4)  ; discos del cazo
        }
        ; Florecillas que visita la abeja
        loop 2 {
            flx := w * (A_Index = 1 ? 0.52 : 0.7)
            EscenaLinea(g, (200 << 24) | (110 << 16) | (170 << 8) | 60, flx, h, flx, h - 8, 1.2)
            loop 5 {
                aF2 := (A_Index - 1) * 1.2566
                EscenaElipse(g, (220 << 24) | (255 << 16) | (250 << 8) | 245, flx + Cos(aF2) * 3.2 - 1.6, h - 11 + Sin(aF2) * 3.2 - 1.6, 3.2, 3.2)
            }
            EscenaElipse(g, (235 << 24) | (255 << 16) | (200 << 8) | 30, flx - 1.8, h - 12.8, 3.6, 3.6)
        }
        ; Segunda abeja más pequeña en órbita contraria
        bt2 := -tNow / 950.0 + 2.5
        bx3 := w * 0.5 + Cos(bt2) * (w * 0.34)
        by3 := h * 0.45 + Sin(bt2 * 2) * 8
        EscenaElipse(g, (140 << 24) | (255 << 16) | (255 << 8) | 255, bx3 - 3.5, by3 - 4.5, 3.6, 3)
        EscenaElipse(g, (140 << 24) | (255 << 16) | (255 << 8) | 255, bx3 + 0.5, by3 - 4.5, 3.6, 3)
        EscenaElipse(g, (235 << 24) | (255 << 16) | (200 << 8) | 20, bx3 - 3, by3 - 2, 6, 4.5)
        EscenaRect(g, (235 << 24) | (30 << 16) | (24 << 8) | 16, bx3 - 1.4, by3 - 2, 1.2, 4.5)
        EscenaRect(g, (235 << 24) | (30 << 16) | (24 << 8) | 16, bx3 + 0.8, by3 - 2, 1.2, 4.5)
    case "chicle":
        ; Pompa GIGANTE que se infla y EXPLOTA + gumballs rodando + hilos pegajosos
        ; Borde OSCURO para que resalte sobre el fondo rosa del tema.
        borde := (215 << 24) | (90 << 16) | (10 << 8) | 80     ; magenta-morado oscuro (contraste)
        gum   := (220 << 24) | (233 << 16) | (30 << 8) | 99    ; rosa chicle saturado
        ; charco de chicle pegado abajo
        EscenaRect(g, gum, 0, h - 4, w, 4)
        loop 5 {
            cx := (A_Index - 0.5) * w / 5
            bw := 16 + Mod(A_Index * 5, 10)
            EscenaElipse(g, gum, cx - bw / 2, h - 9, bw, 9)
        }
        ; hilos de chicle estirándose del charco (pegajosos)
        loop 4 {
            hx := w * (0.13 + (A_Index - 1) * 0.25)
            str := 6 + 5 * Sin(tNow / 600.0 + A_Index * 1.8)
            if (str > 6)
                EscenaLinea(g, (170 << 24) | (240 << 16) | (80 << 8) | 150, hx, h - 6, hx + 2, h - 6 - str, 1.4)
        }
        ; gumballs de colores rodando sobre el charco
        gcols := [(230 << 24) | (255 << 16) | (90 << 8) | 90, (230 << 24) | (90 << 16) | (170 << 8) | 255, (230 << 24) | (255 << 16) | (210 << 8) | 60, (230 << 24) | (120 << 16) | (220 << 8) | 120]
        loop 4 {
            gx := Mod(tNow / 45.0 + (A_Index - 1) * w / 4, w + 16) - 8
            EscenaElipse(g, gcols[A_Index], gx - 4, h - 13, 8, 8)
            EscenaElipse(g, (200 << 24) | (255 << 16) | (255 << 8) | 255, gx - 2, h - 12, 2.5, 2.5)
        }
        ; pompa central que se INFLA... y explota en trocitos (ciclo de 3s)
        bt := Mod(tNow, 3000) / 3000.0
        bx := w * 0.5, byy := h * 0.42
        if (bt < 0.8) {
            bd := 6 + bt / 0.8 * 26
            EscenaElipse(g, (150 << 24) | (245 << 16) | (90 << 8) | 165, bx - bd / 2, byy - bd / 2, bd, bd)
            EscenaAnillo(g, borde, bx - bd / 2, byy - bd / 2, bd, 2)
            EscenaElipse(g, (235 << 24) | (255 << 16) | (255 << 8) | 255, bx - bd / 2 + bd * 0.25, byy - bd / 2 + bd * 0.2, bd * 0.22, bd * 0.22)
        } else {
            pp := (bt - 0.8) / 0.2
            loop 6 {
                a := A_Index * 1.047
                EscenaElipse(g, (Round(220 * (1 - pp)) << 24) | (245 << 16) | (90 << 8) | 165, bx + Cos(a) * (14 + pp * 18) - 2, byy + Sin(a) * (14 + pp * 18) - 2, 4, 4)
            }
        }
        ; pompas pequeñas subiendo
        loop 5 {
            d := 8 + Mod(A_Index * 7, 9)
            cx := Mod(A_Index * 67, Round(w - 20)) + 10 + Sin(tNow / 800.0 + A_Index) * 8
            cy := Mod(h - (tNow / 22.0) - A_Index * 40, h + 30) - 15
            EscenaElipse(g, (150 << 24) | (245 << 16) | (90 << 8) | 165, cx - d / 2, cy - d / 2, d, d)
            EscenaAnillo(g, borde, cx - d / 2, cy - d / 2, d, 1.6)
            EscenaElipse(g, (230 << 24) | (255 << 16) | (255 << 8) | 255, cx - d / 2 + d * 0.28, cy - d / 2 + d * 0.22, d * 0.26, d * 0.26)
        }
    case "gema":
        ; Esmeraldas facetadas con BARRIDO de luz recorriéndolas + destellos en cruz
        sweep := Mod(tNow / 1600.0, 1.0) * (w + 60) - 30
        loop 4 {
            cx := (A_Index - 0.5) * w / 4
            EscenaPoligono(g, (225 << 24) | (20 << 16) | (200 << 8) | 130, [[cx - 6, h - 14], [cx + 6, h - 14], [cx + 8, h - 9], [cx - 8, h - 9]])
            EscenaPoligono(g, (225 << 24) | (10 << 16) | (155 << 8) | 95, [[cx - 8, h - 9], [cx + 8, h - 9], [cx, h - 1]])
            EscenaLinea(g, (170 << 24) | (200 << 16) | (255 << 8) | 230, cx - 3, h - 14, cx, h - 9, 1)
            EscenaLinea(g, (170 << 24) | (200 << 16) | (255 << 8) | 230, cx + 3, h - 14, cx, h - 9, 1)
            ; la cara superior se ilumina cuando pasa el barrido
            d := Abs(cx - sweep)
            if (d < 22) {
                aL := Round(190 * (1 - d / 22))
                EscenaPoligono(g, (aL << 24) | (210 << 16) | (255 << 8) | 235, [[cx - 6, h - 14], [cx + 6, h - 14], [cx + 8, h - 9], [cx - 8, h - 9]])
            }
            ; destello en cruz titilando, desfasado por gema
            tw := 0.5 + 0.5 * Sin(tNow / 300.0 + A_Index * 1.8)
            if (tw > 0.7) {
                s := 2.5 + tw * 2.5
                EscenaLinea(g, (Round(230 * tw) << 24) | (235 << 16) | (255 << 8) | 245, cx - s, h - 14, cx + s, h - 14, 1)
                EscenaLinea(g, (Round(230 * tw) << 24) | (235 << 16) | (255 << 8) | 245, cx, h - 14 - s, cx, h - 14 + s, 1)
            }
        }
    case "neon":
        ; Marco de neón parpadeante por los bordes de la ventana
        flick := (Sin(tNow / 90.0) > -0.85) ? 1.0 : 0.4
        flick *= 0.72 + 0.28 * Sin(tNow / 130.0)
        aG := Round(90 * flick), aC := Round(255 * flick)
        glow := (aG << 24) | (rC << 16) | (gC << 8) | bC
        core := (aC << 24) | (Min(255, rC + 70) << 16) | (Min(255, gC + 70) << 8) | Min(255, bC + 70)
        m := 3
        bordes := [[m, m, w - m, m], [m, h - m, w - m, h - m], [m, m, m, h - m], [w - m, m, w - m, h - m]]
        for b in bordes {
            EscenaLinea(g, glow, b[1], b[2], b[3], b[4], 5)
        }
        for b in bordes {
            EscenaLinea(g, core, b[1], b[2], b[3], b[4], 1.8)
        }
        ; Pulsos de corriente recorriendo el marco (2 puntos opuestos en el perímetro)
        segW := w - 2 * m
        segH := h - 2 * m
        per := 2 * (segW + segH)
        loop 2 {
            poff := Mod(tNow / 6.0 + (A_Index - 1) * per / 2, per)
            if (poff < segW) {
                pxn := m + poff, pyn := m
            } else if (poff < segW + segH) {
                pxn := w - m, pyn := m + (poff - segW)
            } else if (poff < 2 * segW + segH) {
                pxn := w - m - (poff - segW - segH), pyn := h - m
            } else {
                pxn := m, pyn := h - m - (poff - 2 * segW - segH)
            }
            EscenaElipse(g, (110 << 24) | (rC << 16) | (gC << 8) | bC, pxn - 4, pyn - 4, 8, 8)
            EscenaElipse(g, (240 << 24) | (255 << 16) | (255 << 8) | 255, pxn - 2, pyn - 2, 4, 4)
        }
        ; Acentos dobles en las 4 esquinas
        loop 4 {
            cxn := (A_Index = 1 || A_Index = 3) ? m : w - m
            cyn := (A_Index <= 2) ? m : h - m
            dxn := (cxn = m) ? 1 : -1
            dyn := (cyn = m) ? 1 : -1
            EscenaLinea(g, core, cxn, cyn + dyn * 3, cxn + dxn * 7, cyn + dyn * 3, 1.2)
            EscenaLinea(g, core, cxn + dxn * 3, cyn, cxn + dxn * 3, cyn + dyn * 7, 1.2)
        }
    case "oro":
        ; Tesoro: lingotes de oro apilados + destellos + monedas cayendo
        oroC := (235 << 24) | (255 << 16) | (205 << 8) | 40
        oroL := (210 << 24) | (255 << 16) | (240 << 8) | 150
        oroD := (225 << 24) | (200 << 16) | (150 << 8) | 10
        lingotes := [[w * 0.26, h - 6], [w * 0.26 - 9, h - 6], [w * 0.26 + 9, h - 6], [w * 0.26, h - 12], [w * 0.26 + 9, h - 12], [w * 0.72, h - 6], [w * 0.72 + 10, h - 6], [w * 0.72 + 5, h - 12]]
        for L in lingotes {
            bx := L[1], by := L[2]
            EscenaPoligono(g, oroD, [[bx - 8, by], [bx + 8, by], [bx + 6, by - 6], [bx - 6, by - 6]])
            EscenaPoligono(g, oroC, [[bx - 7, by - 1], [bx + 7, by - 1], [bx + 5.5, by - 5.5], [bx - 5.5, by - 5.5]])
            EscenaRect(g, oroL, bx - 5, by - 6, 10, 1)
        }
        loop 5 {
            cx := Mod(A_Index * 73, Round(w - 20)) + 10
            cy := h - 6 - Mod(A_Index * 5, 12)
            tw := 0.5 + 0.5 * Sin(tNow / 200.0 + A_Index * 2)
            if (tw > 0.65) {
                s := 2 + tw * 2
                EscenaLinea(g, oroL, cx - s, cy, cx + s, cy, 1)
                EscenaLinea(g, oroL, cx, cy - s, cx, cy + s, 1)
            }
        }
        loop 3 {
            cx := Mod(A_Index * 97, Round(w - 16)) + 8
            cy := Mod((tNow / 12.0) + A_Index * 60, h + 20) - 10
            EscenaElipse(g, oroC, cx - 5, cy - 5, 10, 10)
            EscenaAnillo(g, oroD, cx - 5, cy - 5, 10, 1)
            EscenaElipse(g, oroL, cx - 2, cy - 2, 3, 3)
        }
        ; Cofre del tesoro abierto en el centro, con brillo que late
        cfx := w * 0.5
        glC := 0.5 + 0.5 * Sin(tNow / 600.0)
        EscenaElipse(g, (Round(40 + 50 * glC) << 24) | (255 << 16) | (215 << 8) | 60, cfx - 16, h - 26, 32, 20)  ; resplandor
        EscenaRect(g, (230 << 24) | (110 << 16) | (62 << 8) | 25, cfx - 13, h - 12, 26, 11)                       ; caja
        EscenaPie(g, (230 << 24) | (130 << 16) | (75 << 8) | 30, cfx - 13, h - 25, 26, 16, 180, 180)              ; tapa abierta
        EscenaRect(g, (220 << 24) | (70 << 16) | (38 << 8) | 14, cfx - 13, h - 12, 26, 1.6)                       ; borde
        EscenaRect(g, oroD, cfx - 1.6, h - 9, 3.2, 4)                                                              ; cerradura
        loop 5 {
            mx2 := cfx - 10 + (A_Index - 1) * 5
            EscenaElipse(g, oroC, mx2 - 2.5, h - 14 - Mod(A_Index, 2) * 2, 5, 5)                                   ; monedas desbordando
            EscenaElipse(g, oroL, mx2 - 1, h - 13 - Mod(A_Index, 2) * 2, 2, 2)
        }
        ; Polvo dorado ascendiendo desde el cofre
        loop 4 {
            faseD := Mod(tNow / 20.0 + A_Index * 22, 30)
            aD := Round(200 * (1 - faseD / 30.0))
            EscenaElipse(g, (aD << 24) | (255 << 16) | (225 << 8) | 90, cfx - 8 + A_Index * 4.5 + Sin(tNow / 250.0 + A_Index * 2) * 3, h - 18 - faseD, 2, 2)
        }
        ; Anillo de oro con diamante, apoyado en el suelo
        anx := w * 0.09
        EscenaAnillo(g, oroC, anx - 5, h - 11, 10, 2.2)
        twA := 0.5 + 0.5 * Sin(tNow / 280.0)
        EscenaPoligono(g, (Round(160 + 90 * twA) << 24) | (210 << 16) | (245 << 8) | 255, [[anx, h - 15], [anx + 3, h - 12], [anx, h - 9.5], [anx - 3, h - 12]])
        if (twA > 0.8) {
            EscenaLinea(g, (Round(230 * (twA - 0.8) / 0.2) << 24) | (255 << 16) | (255 << 8) | 255, anx - 5, h - 12, anx + 5, h - 12, 1)
        }
    case "cactus":
        ; Desierto: sol arriba + duna de arena + cactus
        sol := (210 << 24) | (255 << 16) | (200 << 8) | 40
        EscenaElipse(g, sol, w - 26, 6, 16, 16)
        loop 8 {
            ra := (A_Index - 1) * 0.785 + Sin(tNow / 1200.0) * 0.1
            EscenaLinea(g, sol, w - 18 + Cos(ra) * 13, 14 + Sin(ra) * 13, w - 18 + Cos(ra) * 18, 14 + Sin(ra) * 18, 1.6)
        }
        EscenaPoligono(g, (200 << 24) | (235 << 16) | (205 << 8) | 140, [[0, h], [0, h - 5], [w, h - 7], [w, h]])
        verde := (220 << 24) | (60 << 16) | (140 << 8) | 70
        loop 3 {
            cx := (A_Index - 0.5) * w / 3
            EscenaRect(g, verde, cx - 3, h - 20, 6, 18)
            EscenaRect(g, verde, cx - 8, h - 15, 5, 3)
            EscenaRect(g, verde, cx - 8, h - 21, 3, 6)
            EscenaRect(g, verde, cx + 3, h - 13, 5, 3)
            EscenaRect(g, verde, cx + 5, h - 19, 3, 6)
            ; flor rosa del cactus (abre y cierra despacio)
            abreF := 0.6 + 0.4 * Sin(tNow / 1500.0 + A_Index * 2)
            EscenaElipse(g, (225 << 24) | (235 << 16) | (90 << 8) | 140, cx - 2 * abreF, h - 23 - 1.5 * abreF, 4 * abreF, 3.5 * abreF)
            EscenaElipse(g, (235 << 24) | (255 << 16) | (210 << 8) | 80, cx - 1, h - 22.4, 2, 1.6)
        }
        ; Planta rodadora (tumbleweed) rodando y botando por la duna
        tbx := Mod(tNow / 16.0, w + 30) - 15
        tby := h - 9 - Abs(Sin(tNow / 240.0)) * 5
        rotT := tNow / 200.0
        loop 5 {
            aT3 := rotT + (A_Index - 1) * 1.2566
            EscenaLinea(g, (200 << 24) | (165 << 16) | (115 << 8) | 55, tbx - Cos(aT3) * 6, tby - Sin(aT3) * 6, tbx + Cos(aT3) * 6, tby + Sin(aT3) * 6, 1.1)
        }
        EscenaAnillo(g, (190 << 24) | (165 << 16) | (115 << 8) | 55, tbx - 6, tby - 6, 12, 1.2)
        ; Buitre planeando en círculos a lo lejos
        vtA := tNow / 2200.0
        vtx := w * 0.35 + Cos(vtA) * w * 0.13
        vty := 10 + Sin(vtA) * 4
        flapV := Abs(Sin(tNow / 400.0)) * 2
        EscenaLinea(g, (190 << 24) | (90 << 16) | (60 << 8) | 30, vtx - 5, vty - flapV, vtx, vty, 1.3)
        EscenaLinea(g, (190 << 24) | (90 << 16) | (60 << 8) | 30, vtx, vty, vtx + 5, vty - flapV, 1.3)
        ; Arena arrastrada por el viento a ras de suelo
        loop 4 {
            sdx := Mod(tNow / (6.0 + A_Index * 2) + A_Index * 70, w + 20) - 10
            EscenaElipse(g, (Round(80 + Mod(A_Index * 30, 60)) << 24) | (220 << 16) | (185 << 8) | 120, sdx, h - 4 - Mod(A_Index, 3), 4, 1.4)
        }
    case "spotify":
        ; Ecualizador de barras (verde) animado
        verde := (220 << 24) | (30 << 16) | (215 << 8) | 96
        loop 11 {
            cx := (A_Index - 0.5) * w / 11
            bh := 5 + Round(14 * (0.5 + 0.5 * Sin(tNow / 180.0 + A_Index * 0.7)))
            EscenaRect(g, verde, cx - 2.5, h - bh, 5, bh)
        }
        ; Barra de progreso de la canción con knob (encima del ecualizador)
        prY := h - 26
        prog := Mod(tNow / 24.0, w - 24)
        EscenaLinea(g, (130 << 24) | (90 << 16) | (90 << 8) | 90, 12, prY, w - 12, prY, 2)
        EscenaLinea(g, (230 << 24) | (30 << 16) | (215 << 8) | 96, 12, prY, 12 + prog, prY, 2)
        EscenaElipse(g, (245 << 24) | (245 << 16) | (245 << 8) | 245, 12 + prog - 2.5, prY - 2.5, 5, 5)
        ; Notas musicales subiendo y desvaneciéndose
        loop 3 {
            faseN := Mod(tNow / 14.0 + A_Index * 33, 40)
            aN := Round(220 * (1 - faseN / 40.0))
            nxs := w * (0.2 + A_Index * 0.28) + Sin(tNow / 320.0 + A_Index * 2) * 4
            nys := h - 18 - faseN
            EscenaElipse(g, (aN << 24) | (30 << 16) | (215 << 8) | 96, nxs - 2.5, nys, 5, 3.5)
            EscenaLinea(g, (aN << 24) | (30 << 16) | (215 << 8) | 96, nxs + 2.5, nys + 1.5, nxs + 2.5, nys - 8, 1.3)
            EscenaLinea(g, (aN << 24) | (30 << 16) | (215 << 8) | 96, nxs + 2.5, nys - 8, nxs + 6, nys - 6.5, 1.3)
        }
    case "pokebola":
        ; Pokébolas con CONTORNO (el tema es blanco: la mitad blanca se perdía)
        ; + captura con destello + chispas eléctricas tipo Pikachu
        loop 3 {
            cx := (A_Index - 0.5) * w / 3
            cy := h - 10 - Abs(Sin(tNow / 400.0 + A_Index * 1.7)) * 11   ; rebote
            d := 16
            EscenaElipse(g, (120 << 24) | (28 << 16) | (43 << 8) | 67, cx - d / 2 + 1.5, h - 4, d - 3, 3)  ; sombra en el suelo
            EscenaElipse(g, (238 << 24) | (245 << 16) | (245 << 8) | 245, cx - d / 2, cy - d / 2, d, d)
            EscenaPie(g, (238 << 24) | (230 << 16) | (40 << 8) | 40, cx - d / 2, cy - d / 2, d, d, 180, 180)
            EscenaRect(g, (240 << 24) | (20 << 16) | (20 << 8) | 20, cx - d / 2, cy - 1.5, d, 3)
            EscenaAnillo(g, (235 << 24) | (28 << 16) | (43 << 8) | 67, cx - d / 2, cy - d / 2, d, 1.6)     ; contorno azul marino
            EscenaElipse(g, (240 << 24) | (20 << 16) | (20 << 8) | 20, cx - 3, cy - 3, 6, 6)
            EscenaElipse(g, (240 << 24) | (245 << 16) | (245 << 8) | 245, cx - 1.8, cy - 1.8, 3.6, 3.6)
        }
        ; Captura: cada 3 s la pokébola central dispara el destello blanco-amarillo
        capF := Mod(tNow, 3000) / 3000.0
        if (capF < 0.25) {
            cpp := capF / 0.25
            ccx2 := w * 0.5
            ccy2 := h - 21
            EscenaAnillo(g, (Round(230 * (1 - cpp)) << 24) | (255 << 16) | (193 << 8) | 7, ccx2 - 6 - cpp * 16, ccy2 - 6 - cpp * 16, 12 + cpp * 32, 2)
            loop 6 {
                aC2 := (A_Index - 1) * 1.047 + cpp * 0.8
                EscenaLinea(g, (Round(220 * (1 - cpp)) << 24) | (255 << 16) | (215 << 8) | 60, ccx2 + Cos(aC2) * (6 + cpp * 10), ccy2 + Sin(aC2) * (6 + cpp * 10), ccx2 + Cos(aC2) * (10 + cpp * 14), ccy2 + Sin(aC2) * (10 + cpp * 14), 1.6)
            }
        }
        ; Rayo eléctrico amarillo (zigzag) con chispas-estrella titilando
        rzx := w * 0.82
        rzt := 0.4 + 0.6 * (0.5 + 0.5 * Sin(tNow / 320.0))
        EscenaPoligono(g, (Round(235 * rzt) << 24) | (255 << 16) | (193 << 8) | 7, [[rzx + 3, 4], [rzx - 3, 14], [rzx + 0.5, 14], [rzx - 2.5, 24], [rzx + 4.5, 12.5], [rzx + 1, 12.5]])
        loop 3 {
            spx2 := Mod(A_Index * 83, Round(w - 20)) + 10
            spy2 := 6 + Mod(A_Index * 11, 14)
            twP := 0.5 + 0.5 * Sin(tNow / 230.0 + A_Index * 2.2)
            EscenaLinea(g, (Round(210 * twP) << 24) | (255 << 16) | (193 << 8) | 7, spx2 - 2.5, spy2, spx2 + 2.5, spy2, 1.2)
            EscenaLinea(g, (Round(210 * twP) << 24) | (255 << 16) | (193 << 8) | 7, spx2, spy2 - 2.5, spx2, spy2 + 2.5, 1.2)
        }
    case "bloques":
        ; Bloques de tierra/césped + bloques flotando + creeper + mena de diamante
        ; + antorcha parpadeando + orbes de XP subiendo
        loop 6 {
            cx := (A_Index - 0.5) * w / 6
            s := 16
            EscenaRect(g, (230 << 24) | (120 << 16) | (78 << 8) | 40, cx - s / 2, h - s, s, s)
            EscenaRect(g, (235 << 24) | (90 << 16) | (170 << 8) | 60, cx - s / 2, h - s, s, 5)
        }
        loop 3 {
            cx := w * (0.2 + A_Index * 0.27)
            cy := 16 + Sin(tNow / 500.0 + A_Index * 2) * 5
            s := 12
            EscenaRect(g, (200 << 24) | (120 << 16) | (78 << 8) | 40, cx - s / 2, cy - s / 2, s, s)
            EscenaRect(g, (210 << 24) | (90 << 16) | (170 << 8) | 60, cx - s / 2, cy - s / 2, s, 4)
        }
        ; Creeper asomado sobre los bloques (cara pixelada icónica)
        crx := w * 0.42
        cry := h - 16.0
        EscenaRect(g, (240 << 24) | (60 << 16) | (180 << 8) | 60, crx - 7, cry - 14, 14, 14)
        EscenaRect(g, (215 << 24) | (40 << 16) | (130 << 8) | 40, crx - 7, cry - 14, 14, 3)   ; sombreado pixel
        EscenaRect(g, (245 << 24) | (15 << 16) | (40 << 8) | 15, crx - 5.5, cry - 11, 3.6, 3.6)  ; ojo izq
        EscenaRect(g, (245 << 24) | (15 << 16) | (40 << 8) | 15, crx + 2, cry - 11, 3.6, 3.6)    ; ojo der
        EscenaRect(g, (245 << 24) | (15 << 16) | (40 << 8) | 15, crx - 2, cry - 7.5, 4, 5.5)     ; boca centro
        EscenaRect(g, (245 << 24) | (15 << 16) | (40 << 8) | 15, crx - 4, cry - 5.5, 2.2, 3.5)   ; boca izq
        EscenaRect(g, (245 << 24) | (15 << 16) | (40 << 8) | 15, crx + 2, cry - 5.5, 2.2, 3.5)   ; boca der
        ; Mena de diamante (bloque de piedra con motas cian)
        mnx := w * 0.88
        EscenaRect(g, (235 << 24) | (128 << 16) | (128 << 8) | 128, mnx - 8, h - 32, 16, 16)
        EscenaRect(g, (215 << 24) | (100 << 16) | (100 << 8) | 100, mnx - 8, h - 32, 16, 3)
        for pD in [[-4.5, -12], [1.5, -10], [-2, -6], [3.5, -5.5], [-5.5, -4.5]] {
            EscenaRect(g, (240 << 24) | (90 << 16) | (235 << 8) | 226, mnx + pD[1], h - 20 + pD[2] - 8, 2.6, 2.6)
        }
        ; Antorcha sobre un bloque, con llama pixelada que parpadea
        atx := w * 0.13
        EscenaRect(g, (230 << 24) | (140 << 16) | (95 << 8) | 50, atx - 1.6, h - 27, 3.2, 11)
        flT := 0.6 + 0.4 * Sin(tNow / 110.0 + Sin(tNow / 47.0))
        EscenaRect(g, (Round(60 + 60 * flT) << 24) | (255 << 16) | (190 << 8) | 60, atx - 6, h - 36, 12, 12)  ; halo
        EscenaRect(g, (245 << 24) | (255 << 16) | (190 << 8) | 40, atx - 2.4, h - 31.5, 4.8, 4.8)
        EscenaRect(g, (Round(200 + 55 * flT) << 24) | (255 << 16) | (240 << 8) | 150, atx - 1.2, h - 30.5, 2.4, 2.4)
        ; Orbes de XP (verdes brillantes) subiendo hacia el jugador
        loop 4 {
            faseX := Mod(tNow / 18.0 + A_Index * 26, 36)
            aX := Round(220 * (1 - faseX / 36.0))
            xox := w * (0.3 + A_Index * 0.14) + Sin(tNow / 220.0 + A_Index * 1.8) * 4
            EscenaElipse(g, (aX << 24) | (130 << 16) | (255 << 8) | 90, xox, h - 20 - faseX, 4, 4)
            EscenaElipse(g, (Round(aX * 0.8) << 24) | (220 << 16) | (255 << 8) | 170, xox + 1, h - 19 - faseX, 1.8, 1.8)
        }
    case "nubes":
        ; Tinte de cielo (para que las nubes blancas resalten sobre el fondo claro) +
        ; sol con rayos + pájaros cruzando + nubes esponjosas a la deriva por ARRIBA,
        ; con base sombreada para que resalten
        cieloT := fondoClaro ? ((55 << 24) | (180 << 16) | (215 << 8) | 245) : ((70 << 24) | (40 << 16) | (60 << 8) | 110)
        EscenaRect(g, cieloT, 0, 0, w, Min(h, 52))
        sx := w * 0.85
        sy := h * 0.12
        rot := tNow / 2000.0
        loop 6 {
            ang := rot + (A_Index - 1) * 1.047
            EscenaLinea(g, (140 << 24) | (255 << 16) | (235 << 8) | 140, sx, sy, sx + Cos(ang) * 11, sy + Sin(ang) * 11, 1.4)
        }
        EscenaElipse(g, (220 << 24) | (255 << 16) | (240 << 8) | 150, sx - 6, sy - 6, 12, 12)
        loop 2 {
            bx := Mod(tNow / 26.0 + A_Index * w * 0.5, w + 20) - 10
            by := h * (0.05 + A_Index * 0.06)
            flap := Sin(tNow / 140.0 + A_Index) * 3
            EscenaLinea(g, (190 << 24) | (90 << 16) | (110 << 8) | 130, bx - 5, by - flap, bx, by, 1.3)
            EscenaLinea(g, (190 << 24) | (90 << 16) | (110 << 8) | 130, bx, by, bx + 5, by - flap, 1.3)
        }
        loop 4 {
            drift := Mod(tNow / 50.0 + A_Index * w / 4, w + 70) - 35
            cy := 5 + Mod(A_Index * 9, 20)
            sombra := fondoClaro ? ((150 << 24) | (150 << 16) | (165 << 8) | 195) : ((150 << 24) | (110 << 16) | (135 << 8) | 175)
            nube := fondoClaro ? ((235 << 24) | (250 << 16) | (252 << 8) | 255) : ((225 << 24) | (245 << 16) | (250 << 8) | 255)
            EscenaElipse(g, sombra, drift - 13, cy + 3, 40, 12)
            EscenaElipse(g, nube, drift - 13, cy, 26, 14)
            EscenaElipse(g, nube, drift - 3, cy - 7, 20, 18)
            EscenaElipse(g, nube, drift + 8, cy, 20, 14)
            EscenaElipse(g, nube, drift - 1, cy + 1, 30, 12)
        }
    case "luna":
        ; Luna arriba-derecha + estrellas titilando por todo el cielo
        EscenaElipse(g, (225 << 24) | (245 << 16) | (240 << 8) | 205, w - 30, 6, 17, 17)   ; luna pálida
        EscenaElipse(g, (90 << 24) | (200 << 16) | (195 << 8) | 165, w - 26, 9, 4, 4)       ; cráteres
        EscenaElipse(g, (80 << 24) | (200 << 16) | (195 << 8) | 165, w - 19, 15, 3, 3)
        loop 13 {
            sx := Mod(A_Index * 73, Round(w - 16)) + 8
            sy := 4 + Mod(A_Index * 13, 32)
            tw := 0.4 + 0.6 * (0.5 + 0.5 * Sin(tNow / 240.0 + A_Index))
            s := 1.5 + tw * 2
            EscenaElipse(g, (Round(235 * tw) << 24) | (255 << 16) | (255 << 8) | 255, sx - s / 2, sy - s / 2, s, s)
        }
        ; Halo lunar: resplandor pulsante detrás de la luna
        haloP := 0.5 + 0.5 * Sin(tNow / 900.0)
        EscenaElipse(g, (Round(35 + 25 * haloP) << 24) | (235 << 16) | (235 << 8) | 215, w - 36, 0, 29, 29)
        ; Constelación: une 3 de las estrellas titilantes con líneas finas
        c1x := Mod(1 * 73, Round(w - 16)) + 8, c1y := 4 + Mod(1 * 13, 32)
        c2x := Mod(4 * 73, Round(w - 16)) + 8, c2y := 4 + Mod(4 * 13, 32)
        c3x := Mod(7 * 73, Round(w - 16)) + 8, c3y := 4 + Mod(7 * 13, 32)
        EscenaLinea(g, (55 << 24) | (200 << 16) | (210 << 8) | 255, c1x, c1y, c2x, c2y, 1)
        EscenaLinea(g, (55 << 24) | (200 << 16) | (210 << 8) | 255, c2x, c2y, c3x, c3y, 1)
        ; Estrella fugaz periódica cruzando el cielo, con estela
        cicloFug := Mod(tNow, 6000)
        if (cicloFug < 900) {
            progF := cicloFug / 900.0
            fx := w * (1.1 - progF * 1.3)
            fy := h * 0.08 + progF * h * 0.35
            fAlpha := Round(255 * (1 - progF))
            loop 5 {
                tEx := A_Index * 2.2
                aEx := Max(0, fAlpha - A_Index * 50)
                EscenaElipse(g, (aEx << 24) | (255 << 16) | (255 << 8) | 240, fx + tEx, fy - tEx * 0.45, 2.4 - A_Index * 0.4, 2.4 - A_Index * 0.4)
            }
        }
        ; Nube oscura translúcida que cruza lentamente bajo la luna
        nubeXLuna := Mod(tNow / 90.0, w + 60) - 60
        EscenaElipse(g, (50 << 24) | (60 << 16) | (70 << 8) | 95, nubeXLuna, 10, 30, 9)
        EscenaElipse(g, (45 << 24) | (60 << 16) | (70 << 8) | 95, nubeXLuna + 14, 7, 22, 8)
        ; Búho posado en una rama, con parpadeo ocasional
        buhoX := w * 0.18
        buhoY := h - 13
        EscenaPoligono(g, (200 << 24) | (70 << 16) | (50 << 8) | 40, [[buhoX - 18, h], [buhoX + 18, h], [buhoX + 14, h - 3], [buhoX - 14, h - 3]])  ; rama
        EscenaElipse(g, (220 << 24) | (90 << 16) | (70 << 8) | 60, buhoX - 6, buhoY - 9, 12, 11)   ; cuerpo
        EscenaElipse(g, (220 << 24) | (110 << 16) | (90 << 8) | 75, buhoX - 6, buhoY - 14, 12, 9)  ; cabeza
        parpBuho := Mod(tNow, 4000) > 3800 ? 0.15 : 1.0
        EscenaElipse(g, (235 << 24) | (255 << 16) | (220 << 8) | 60, buhoX - 4, buhoY - 13, 4, Max(0.5, 4 * parpBuho))
        EscenaElipse(g, (235 << 24) | (255 << 16) | (220 << 8) | 60, buhoX + 1, buhoY - 13, 4, Max(0.5, 4 * parpBuho))
        EscenaElipse(g, (255 << 24) | (40 << 16) | (30 << 8) | 25, buhoX - 3, buhoY - 12, 1.6, Max(0.4, 1.6 * parpBuho))
        EscenaElipse(g, (255 << 24) | (40 << 16) | (30 << 8) | 25, buhoX + 2, buhoY - 12, 1.6, Max(0.4, 1.6 * parpBuho))
    case "planeta":
        ; Planeta con anillo arriba-derecha + luna orbitando + estrellas
        cxp := w * 0.82
        cyp := 18.0
        loop 6 {
            sx := Mod(A_Index * 67, Round(w - 30)) + 8
            sy := 4 + Mod(A_Index * 11, 26)
            tw := 0.4 + 0.6 * (0.5 + 0.5 * Sin(tNow / 220.0 + A_Index))
            EscenaElipse(g, (Round(220 * tw) << 24) | (255 << 16) | (255 << 8) | 255, sx - 1, sy - 1, 2.2, 2.2)
        }
        EscenaElipse(g, (230 << 24) | (rC << 16) | (gC << 8) | bC, cxp - 10, cyp - 10, 20, 20)
        EscenaElipse(g, (120 << 24) | (Min(255, rC + 70) << 16) | (Min(255, gC + 70) << 8) | Min(255, bC + 70), cxp - 6, cyp - 7, 8, 6)  ; brillo
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (210 << 24) | (255 << 16) | (220 << 8) | 150, "Float", 1.5, "Int", 2, "Ptr*", &pen)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", pen, "Float", cxp - 18, "Float", cyp - 4, "Float", 36, "Float", 9)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
        ; Luna orbitando (ángulo animado)
        oa := tNow / 600.0
        EscenaElipse(g, (235 << 24) | (235 << 16) | (235 << 8) | 245, cxp + Cos(oa) * 17 - 2, cyp + Sin(oa) * 6 - 2, 4, 4)
    ; ─────────── ESCENAS POR CATEGORÍA (respaldo) ───────────
    case "nieve":
        col := fondoClaro ? ((180 << 24) | (150 << 16) | (185 << 8) | 220) : ((210 << 24) | (240 << 16) | (248 << 8) | 255)
        colHielo := fondoClaro ? ((160 << 24) | (140 << 16) | (180 << 8) | 220) : ((190 << 24) | (200 << 16) | (230 << 8) | 255)
        ; Carámbanos colgando del borde SUPERIOR (largos variables)
        loop 11 {
            cx := (A_Index - 0.5) * w / 11
            ic := 8 + Mod(A_Index * 5, 12)
            EscenaPoligono(g, colHielo, [[cx - 3, 0], [cx + 3, 0], [cx, ic]])
        }
        ; Ventisquero abajo
        EscenaPoligono(g, col, [[0, h], [0, h - 5], [w, h - 5], [w, h]])
        loop 5 {
            cx := (A_Index - 0.5) * w / 5
            rr := w / 8
            EscenaElipse(g, col, cx - rr, h - 13, rr * 2, 26)
        }
    case "hojas":
        ; Bosque: pinos triangulares con tronco
        verde := fondoClaro ? ((210 << 24) | (35 << 16) | (105 << 8) | 45) : ((210 << 24) | (45 << 16) | (120 << 8) | 50)
        tronco := (220 << 24) | (74 << 16) | (48 << 8) | 24
        xs := [0.10, 0.30, 0.52, 0.72, 0.90]
        for idx, fx in xs {
            cx := fx * w
            alturaT := 13 + Mod(idx * 5, 8)    ; 13–20 px
            tw := alturaT * 0.5
            EscenaPoligono(g, tronco, [[cx - 1.5, h], [cx + 1.5, h], [cx + 1.5, h - 3], [cx - 1.5, h - 3]])
            EscenaPoligono(g, verde, [[cx - tw, h - 3], [cx + tw, h - 3], [cx, h - 3 - alturaT * 0.62]])
            EscenaPoligono(g, verde, [[cx - tw * 0.75, h - 3 - alturaT * 0.4], [cx + tw * 0.75, h - 3 - alturaT * 0.4], [cx, h - 3 - alturaT]])
        }
    case "brasas":
        ; Lava + llamas que parpadean
        EscenaPoligono(g, (210 << 24) | (180 << 16) | (20 << 8) | 10, [[0, h], [0, h - 5], [w, h - 5], [w, h]])
        loop 9 {
            cx := (A_Index - 0.5) * w / 9
            fl := 0.5 + 0.5 * Sin(tNow / 150.0 + A_Index)
            alt := 9 + 11 * fl
            half := w / 28
            EscenaPoligono(g, (200 << 24) | (255 << 16) | (Round(90 + 90 * fl) << 8) | 20,
                [[cx - half, h - 3], [cx + half, h - 3], [cx, h - 3 - alt]])
        }
    case "burbujas":
        ; Mar: dos capas de olas senoidales que se mueven
        loop 2 {
            capa := A_Index
            fase := tNow / 700.0 + capa * 1.7
            baseY := h - (capa = 1 ? 4 : 9)
            aA := capa = 1 ? 150 : 95
            pts := []
            pts.Push([0, h])
            x := 0.0
            while (x <= w) {
                pts.Push([x, baseY + 3.5 * Sin(x / 26.0 + fase)])
                x += 12
            }
            pts.Push([w, h])
            EscenaPoligono(g, (aA << 24) | (rC << 16) | (gC << 8) | bC, pts)
        }
    case "petalos":
        ; Pradera: césped + florecillas rosas
        verde := (180 << 24) | (70 << 16) | (150 << 8) | 70
        EscenaPoligono(g, verde, [[0, h], [0, h - 4], [w, h - 4], [w, h]])
        loop 6 {
            cx := (A_Index - 0.5) * w / 6
            tallo := 8 + Mod(A_Index * 5, 6)   ; 8–13 px
            EscenaPoligono(g, verde, [[cx - 1, h - 3], [cx + 1, h - 3], [cx + 1, h - 3 - tallo], [cx - 1, h - 3 - tallo]])
            fy := h - 3 - tallo
            loop 5 {
                ang := (A_Index - 1) * 1.2566
                px := cx + Cos(ang) * 3.0
                py := fy + Sin(ang) * 3.0
                EscenaElipse(g, (210 << 24) | (255 << 16) | (140 << 8) | 195, px - 2.0, py - 2.0, 4.0, 4.0)
            }
            EscenaElipse(g, (230 << 24) | (255 << 16) | (215 << 8) | 70, cx - 1.5, fy - 1.5, 3.0, 3.0)
        }
    case "estrellas":
        ; Cielo nocturno: estrellas titilando ARRIBA + montañas abajo
        loop 14 {
            sx := Mod(A_Index * 71, Round(w - 14)) + 7
            sy := 4 + Mod(A_Index * 17, 34)
            tw := 0.35 + 0.65 * (0.5 + 0.5 * Sin(tNow / 230.0 + A_Index * 1.3))
            s := 1.4 + tw * 2
            EscenaElipse(g, (Round(230 * tw) << 24) | (255 << 16) | (255 << 8) | 255, sx - s / 2, sy - s / 2, s, s)
        }
        ; Estrella fugaz periódica (cruza cada ~6 s)
        sf := Mod(tNow / 16.0, w + 120) - 60
        if (sf > 0 && sf < w) {
            EscenaLinea(g, (170 << 24) | (255 << 16) | (255 << 8) | 255, sf, 10, sf - 16, 18, 2)
            EscenaElipse(g, (235 << 24) | (255 << 16) | (255 << 8) | 255, sf - 1.5, 8.5, 3, 3)
        }
        oscuroCol := (190 << 24) | (30 << 16) | (26 << 8) | 54
        EscenaPoligono(g, oscuroCol,
            [[0, h], [0, h - 8], [w * 0.18, h - 20], [w * 0.34, h - 10],
             [w * 0.52, h - 22], [w * 0.68, h - 11], [w * 0.84, h - 19], [w, h - 12], [w, h]])
    case "matrix":
        ; Placa base: línea de circuito con nodos
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (180 << 24) | (40 << 16) | (255 << 8) | 110, "Float", 1.5, "Int", 2, "Ptr*", &pen)
        DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", pen, "Float", 0, "Float", h - 7, "Float", w, "Float", h - 7)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
        loop 7 {
            cx := (A_Index - 0.5) * w / 7
            EscenaElipse(g, (220 << 24) | (60 << 16) | (255 << 8) | 130, cx - 2.5, h - 9.5, 5, 5)
            EscenaPoligono(g, (160 << 24) | (40 << 16) | (255 << 8) | 110, [[cx - 0.8, h - 7], [cx + 0.8, h - 7], [cx + 0.8, h], [cx - 0.8, h]])
        }
    case "chispas":
        ; Destellos dorados (rombos brillantes) a lo largo del borde
        oro := fondoClaro ? ((210 << 24) | (200 << 16) | (150 << 8) | 20) : ((220 << 24) | (255 << 16) | (215 << 8) | 110)
        loop 7 {
            cx := (A_Index - 0.5) * w / 7
            br := 0.5 + 0.5 * Sin(tNow / 260.0 + A_Index)
            s := 4 + 3 * br
            EscenaPoligono(g, oro, [[cx, h - 3 - s], [cx + s * 0.5, h - 3], [cx, h - 3 + 0], [cx - s * 0.5, h - 3]])
        }
    case "lluvia":
        ; Charco: línea de agua + arcos de onda
        agua := (140 << 24) | (rC << 16) | (gC << 8) | bC
        EscenaPoligono(g, agua, [[0, h], [0, h - 4], [w, h - 4], [w, h]])
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (110 << 24) | (rC << 16) | (gC << 8) | bC, "Float", 1.2, "Int", 2, "Ptr*", &pen)
        loop 5 {
            cx := (A_Index - 0.5) * w / 5
            rip := 5 + Mod(tNow // 120 + A_Index * 3, 9)
            DllCall("gdiplus\GdipDrawArc", "Ptr", g, "Ptr", pen, "Float", cx - rip, "Float", h - 5 - rip * 0.4, "Float", rip * 2, "Float", rip * 0.8, "Float", 180, "Float", 180)
        }
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    default:
        ; Línea decorativa con banderines triangulares (tinte del tema)
        baseCol := (130 << 24) | (rC << 16) | (gC << 8) | bC
        EscenaPoligono(g, baseCol, [[0, h], [0, h - 3], [w, h - 3], [w, h]])
        loop 8 {
            cx := (A_Index - 0.5) * w / 8
            EscenaPoligono(g, (170 << 24) | (rC << 16) | (gC << 8) | bC, [[cx - 5, h - 3], [cx + 5, h - 3], [cx, h - 11]])
        }
    }
}

InstalarSubclassParticulas() {
    global miGui, historialGui
    global overlayPartMain, overlayPartHist
    global particulasMain, particulasHist, particulasInited, historialVisible

    ; Las partículas se renderizan en ventanas overlay layered + click-through encima
    ; del padre. Así aparecen sobre TODOS los controles (incluido el hitbox de los textos)
    ; sin sufrir el clipping de WS_CLIPCHILDREN.

    static BAR_H := 25  ; alto de la barra de título — se excluye del overlay
    if (IsObject(miGui) && !IsObject(overlayPartMain)) {
        ; WS_CLIPCHILDREN en el padre → evita flicker en los hijos cuando el padre se invalida
        try WinSetStyle("+0x02000000", "ahk_id " miGui.Hwnd)
        miGui.GetPos(&mx, &my, &mw, &mh)
        ; +AlwaysOnTop es OBLIGATORIO porque miGui es topmost — sin esto, la overlay queda
        ; en la capa normal y el padre topmost la oculta entera (las partículas no se ven).
        ; Sin WinSetTransColor: la transparencia se gestiona con UpdateLayeredWindow (alpha por píxel)
        ; → sin halo en los bordes ni mezcla contra fondo negro.
        overlayPartMain := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")  ; WS_EX_LAYERED | WS_EX_TRANSPARENT
        overlayPartMain.Opt("+Owner" miGui.Hwnd)
        overlayPartMain.Show("x" mx " y" (my + BAR_H) " w" mw " h" (mh - BAR_H) " NoActivate")
        InicializarParticulas(particulasMain, mw, mh - BAR_H, 32)
    }
    if (IsObject(historialGui) && !IsObject(overlayPartHist)) {
        try WinSetStyle("+0x02000000", "ahk_id " historialGui.Hwnd)
        historialGui.GetPos(&hx, &hy, &hw, &hh)
        overlayPartHist := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
        overlayPartHist.Opt("+Owner" historialGui.Hwnd)
        if (historialVisible)
            overlayPartHist.Show("x" hx " y" (hy + BAR_H) " w" hw " h" (hh - BAR_H) " NoActivate")
        InicializarParticulas(particulasHist, hw, hh - BAR_H, 40)
    }
    particulasInited := true
}

; ===== TRAY ICON DINAMICO =====
global trayIconCache := Map()
global trayLastColor := ""
global trayDir := A_Temp "\brawlmacro_tray"

EscribirIconoCirculo(path, hexColor, size := 32) {
    pixelBytes   := size * size * 4
    maskRowBytes := ((size + 31) // 32) * 4
    maskBytes    := maskRowBytes * size
    bitmapBytes  := 40 + pixelBytes + maskBytes

    bufHdr := Buffer(22, 0)
    NumPut("UShort", 0,                              bufHdr,  0)
    NumPut("UShort", 1,                              bufHdr,  2)
    NumPut("UShort", 1,                              bufHdr,  4)
    NumPut("UChar",  (size = 256 ? 0 : size),        bufHdr,  6)
    NumPut("UChar",  (size = 256 ? 0 : size),        bufHdr,  7)
    NumPut("UChar",  0,                              bufHdr,  8)
    NumPut("UChar",  0,                              bufHdr,  9)
    NumPut("UShort", 1,                              bufHdr, 10)
    NumPut("UShort", 32,                             bufHdr, 12)
    NumPut("UInt",   bitmapBytes,                    bufHdr, 14)
    NumPut("UInt",   22,                             bufHdr, 18)

    bufBmp := Buffer(40, 0)
    NumPut("UInt",   40,        bufBmp,  0)
    NumPut("Int",    size,      bufBmp,  4)
    NumPut("Int",    size * 2,  bufBmp,  8)
    NumPut("UShort", 1,         bufBmp, 12)
    NumPut("UShort", 32,        bufBmp, 14)
    NumPut("UInt",   0,         bufBmp, 16)
    NumPut("UInt",   0,         bufBmp, 20)

    bufPixels := Buffer(pixelBytes, 0)
    r := Integer("0x" SubStr(hexColor, 1, 2))
    g := Integer("0x" SubStr(hexColor, 3, 2))
    b := Integer("0x" SubStr(hexColor, 5, 2))

    cx := size / 2.0
    cy := size / 2.0
    rad := size / 2.0 - 1.5
    rad2 := rad * rad
    radOuter := rad + 1.5
    radOuter2 := radOuter * radOuter

    loop size {
        yPix := A_Index - 1
        bitmapRow := size - 1 - yPix    ; bottom-up
        loop size {
            xPix := A_Index - 1
            ofs := (bitmapRow * size + xPix) * 4
            dx := xPix + 0.5 - cx
            dy := yPix + 0.5 - cy
            d2 := dx*dx + dy*dy
            if (d2 <= rad2) {
                NumPut("UChar", b,    bufPixels, ofs)
                NumPut("UChar", g,    bufPixels, ofs + 1)
                NumPut("UChar", r,    bufPixels, ofs + 2)
                NumPut("UChar", 0xFF, bufPixels, ofs + 3)
            } else if (d2 <= radOuter2) {
                t := (Sqrt(d2) - rad) / (radOuter - rad)
                alpha := Round(255 * (1 - t))
                if (alpha < 0)
                    alpha := 0
                if (alpha > 255)
                    alpha := 255
                NumPut("UChar", (b * alpha) // 255, bufPixels, ofs)
                NumPut("UChar", (g * alpha) // 255, bufPixels, ofs + 1)
                NumPut("UChar", (r * alpha) // 255, bufPixels, ofs + 2)
                NumPut("UChar", alpha,              bufPixels, ofs + 3)
            }
        }
    }

    bufMask := Buffer(maskBytes, 0)

    try FileDelete(path)
    try {
        f := FileOpen(path, "w")
        if (!f)
            return false
        f.RawWrite(bufHdr,    22)
        f.RawWrite(bufBmp,    40)
        f.RawWrite(bufPixels, pixelBytes)
        f.RawWrite(bufMask,   maskBytes)
        f.Close()
    } catch {
        return false
    }
    return true
}

EstablecerTrayIcon(hexColor) {
    global trayIconCache, trayLastColor, trayDir
    if (trayLastColor = hexColor)
        return
    if (!trayIconCache.Has(hexColor)) {
        if (!DirExist(trayDir)) {
            try DirCreate(trayDir)
        }
        path := trayDir "\" hexColor ".ico"
        if (!FileExist(path)) {
            if (!EscribirIconoCirculo(path, hexColor, 32))
                return
        }
        trayIconCache[hexColor] := path
    }
    try TraySetIcon(trayIconCache[hexColor])
    trayLastColor := hexColor
}

ActualizarTrayIcon() {
    global activo, modoDestruccion, ultimoCambio, ultimoAfkMove
    ; Heartbeat secundario para el watchdog: este timer (cada 1s) es ligerísimo
    ; y prácticamente nunca falla. Sirve de respaldo si EjecutarMacro se bloquea
    ; brevemente en algún Sleep/SendInput largo.
    ultimoAfkMove := A_TickCount
    if (modoDestruccion) {
        EstablecerTrayIcon("FF2222")
        return
    }
    if (activo) {
        restante := 360000 - (A_TickCount - ultimoCambio)
        if (restante < 30000)
            EstablecerTrayIcon("FFA500")
        else
            EstablecerTrayIcon("22CC22")
    } else {
        EstablecerTrayIcon("888888")
    }
}

; ===== STATS — BARRAS DE PROGRESO ANIMADAS =====
DibujarRectRedondeado(g, brush, x, y, w, h, r) {
    path := 0
    DllCall("gdiplus\GdipCreatePath", "Int", 0, "Ptr*", &path)
    d := r * 2
    if (d > w) d := w
    if (d > h) d := h
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y, "Float", d, "Float", d, "Float", 180, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - d, "Float", y, "Float", d, "Float", d, "Float", 270, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x + w - d, "Float", y + h - d, "Float", d, "Float", d, "Float", 0, "Float", 90)
    DllCall("gdiplus\GdipAddPathArc", "Ptr", path, "Float", x, "Float", y + h - d, "Float", d, "Float", d, "Float", 90, "Float", 90)
    DllCall("gdiplus\GdipClosePathFigure", "Ptr", path)
    DllCall("gdiplus\GdipFillPath", "Ptr", g, "Ptr", brush, "Ptr", path)
    DllCall("gdiplus\GdipDeletePath", "Ptr", path)
}

DibujarStatsBar(hdc, w, h, valor, hexColor, hexTexto, hexFondo, etiqueta, valorTexto) {
    global gdipInited
    memDC := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hbm   := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr")
    oldBmp := DllCall("SelectObject", "Ptr", memDC, "Ptr", hbm, "Ptr")

    rF := Integer("0x" SubStr(hexFondo, 1, 2))
    gF := Integer("0x" SubStr(hexFondo, 3, 2))
    bF := Integer("0x" SubStr(hexFondo, 5, 2))
    brushF := DllCall("CreateSolidBrush", "UInt", (bF << 16) | (gF << 8) | rF, "Ptr")
    rcF := Buffer(16, 0)
    NumPut("Int", 0, rcF, 0), NumPut("Int", 0, rcF, 4), NumPut("Int", w, rcF, 8), NumPut("Int", h, rcF, 12)
    DllCall("FillRect", "Ptr", memDC, "Ptr", rcF, "Ptr", brushF)
    DllCall("DeleteObject", "Ptr", brushF)

    if (gdipInited) {
        g := 0
        DllCall("gdiplus\GdipCreateFromHDC", "Ptr", memDC, "Ptr*", &g)
        if (g) {
            DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
            barH := 9
            barY := h - barH - 3
            rC := Integer("0x" SubStr(hexColor, 1, 2))
            gC := Integer("0x" SubStr(hexColor, 3, 2))
            bC := Integer("0x" SubStr(hexColor, 5, 2))

            ; Track
            argbBg := (0x40 << 24) | (rC << 16) | (gC << 8) | bC
            brushBg := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbBg, "Ptr*", &brushBg)
            DibujarRectRedondeado(g, brushBg, 0, barY, w, barH, barH / 2)
            DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushBg)

            ; Fill
            if (valor > 0.005) {
                fillW := w * Min(valor, 1.0)
                if (fillW < barH)
                    fillW := barH
                argbFill := 0xFF000000 | (rC << 16) | (gC << 8) | bC
                brushFill := 0
                DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbFill, "Ptr*", &brushFill)
                DibujarRectRedondeado(g, brushFill, 0, barY, fillW, barH, barH / 2)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushFill)
            }

            DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
        }
    }

    ; Etiqueta + valor
    hFont := DllCall("CreateFont", "Int", -12, "Int", 0, "Int", 0, "Int", 0,
        "Int", 600, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 1,
        "UInt", 0, "UInt", 0, "UInt", 4, "UInt", 0, "Str", "Segoe UI", "Ptr")
    oldFont := DllCall("SelectObject", "Ptr", memDC, "Ptr", hFont, "Ptr")
    DllCall("SetBkMode", "Ptr", memDC, "Int", 1)
    rT := Integer("0x" SubStr(hexTexto, 1, 2))
    gT := Integer("0x" SubStr(hexTexto, 3, 2))
    bT := Integer("0x" SubStr(hexTexto, 5, 2))
    DllCall("SetTextColor", "Ptr", memDC, "UInt", (bT << 16) | (gT << 8) | rT)
    if (etiqueta != "")
        DllCall("TextOut", "Ptr", memDC, "Int", 2, "Int", 2, "Str", etiqueta, "Int", StrLen(etiqueta))
    if (valorTexto != "") {
        sz := Buffer(8, 0)
        DllCall("GetTextExtentPoint32", "Ptr", memDC, "Str", valorTexto, "Int", StrLen(valorTexto), "Ptr", sz)
        vW := NumGet(sz, 0, "Int")
        DllCall("TextOut", "Ptr", memDC, "Int", w - vW - 2, "Int", 2, "Str", valorTexto, "Int", StrLen(valorTexto))
    }
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldFont)
    DllCall("DeleteObject", "Ptr", hFont)

    DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", memDC)
}

StatsBarSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND)
        return 1
    if (uMsg = WM_PAINT) {
        global statsBarsData, colorFondoPrincipal, colorTextoPrincipal
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            rc := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", hWnd, "Ptr", rc)
            w := NumGet(rc, 8, "Int")
            h := NumGet(rc, 12, "Int")
            for d in statsBarsData {
                if (IsObject(d.ctrl) && d.ctrl.Hwnd = hWnd) {
                    DibujarStatsBar(hdc, w, h, d.valorActual, d.color, colorTextoPrincipal, colorFondoPrincipal, d.etiqueta, d.valorTexto)
                    break
                }
            }
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

AddStatsBar(gui, x, y, w, h, valor, color, etiqueta, valorTexto) {
    global statsBarsData, statsBarsSubclassCbs, colorFondoPrincipal
    ctrl := gui.Add("Text", "x" x " y" y " w" w " h" h " Background" colorFondoPrincipal " +0x1", "")
    statsBarsData.Push({
        ctrl: ctrl,
        valorObjetivo: valor,
        valorActual: 0.0,
        color: color,
        etiqueta: etiqueta,
        valorTexto: valorTexto
    })
    cb := CallbackCreate(StatsBarSubclassProc, "F", 6)
    statsBarsSubclassCbs.Push(cb)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", ctrl.Hwnd, "Ptr", cb, "Ptr", 12, "Ptr", 0)
}

AnimarStatsBars() {
    global statsBarsData, statsGuiActive
    if (!IsObject(statsGuiActive)) {
        SetTimer(AnimarStatsBars, 0)
        return
    }
    cambios := false
    for d in statsBarsData {
        diff := d.valorObjetivo - d.valorActual
        if (Abs(diff) > 0.003) {
            d.valorActual += diff * 0.14
            cambios := true
            if (IsObject(d.ctrl))
                DllCall("InvalidateRect", "Ptr", d.ctrl.Hwnd, "Ptr", 0, "Int", 0)
        }
    }
    if (!cambios) {
        for d in statsBarsData {
            if (d.valorActual != d.valorObjetivo) {
                d.valorActual := d.valorObjetivo
                if (IsObject(d.ctrl))
                    DllCall("InvalidateRect", "Ptr", d.ctrl.Hwnd, "Ptr", 0, "Int", 0)
            }
        }
        SetTimer(AnimarStatsBars, 0)
    }
}

; ===== INICIALIZAR GUI =====
; Cargar configuraciones guardadas (RGB y stats) antes de construir la GUI
LeerRGBsGuardados()
CargarStats()
LeerWebhook()
DefinirLogros()
CargarLogros()
InicializarGdip()
DllCall("LoadLibrary", "Str", "Msftedit.dll", "Ptr")

miGui := Gui("+AlwaysOnTop -Caption -Resize")
miGui.BackColor := colorFondoPrincipal
miGui.SetFont("s13 c" colorTextoPrincipal, "Segoe UI")

historialGui := Gui("+AlwaysOnTop +ToolWindow -Caption")
historialGui.Opt("+Owner" miGui.Hwnd)
historialGui.BackColor := colorVentanaHistorial
historialGui.SetFont("s11 c" colorTextoPrincipal, "Segoe UI")

barraHistorial := historialGui.Add("Text", "x0 y0 w270 h25 Background" colorBarra " Center", "Historial MacroSmart")
barraHistorial.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
; Combinado: primero registra el click para el egg de Nika, LUEGO arrastra
; (si arrastra antes, el drag modal de Windows bloquea el segundo handler)
barraHistorial.OnEvent("Click", (*) => (ClickBarraHistorialNika(), ArrastrarHistorial()))

; Sin WS_VSCROLL: el RichEdit no dibuja NINGUNA scrollbar nativa.
; La rueda del ratón se gestiona via hotkey #HotIf más abajo, que envía
; EM_LINESCROLL directamente — SIN scrollbar visual, como el panel de temas.
; (El scrollbar custom se quitó en 30.7.6: tapaba la decoración del tema y
; daba más problemas que servicio.)
historialBox := historialGui.Add("Custom", "ClassRICHEDIT50W x10 y35 w250 h110 +0x4 +0x10 +0x40 +0x800 vHistorial")
historialBox.Opt("+ReadOnly -TabStop")
SendMessage(0x00CF, 0, 0, historialBox)
SendMessage(0x0443, 0, HexToBGR(colorFondoHistorial), , "ahk_id " historialBox.Hwnd)

; Ocultar la barra nativa blanca del RichEdit (la mantiene internamente para scroll pero sin pintarla)
DllCall("ShowScrollBar", "Ptr", historialBox.Hwnd, "Int", 1, "Int", 0)  ; SB_VERT=1, bShow=0

cooldownText := historialGui.Add("Text", "x10 y155 w250 h88 vCooldownText c" colorCooldown " Background" colorVentanaHistorial)
cooldownText.SetFont("s9.6", "Segoe UI")   ; visor de detección en vivo (1.2x del tamaño original s8)
separadorHistorial := historialGui.Add("Text", "x0 y148 w270 h2 Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.45), "")
secuenciasLabel := historialGui.Add("Text", "x10 y245 w250 h20 +0x201 vSecuenciasLabel c" colorTextoPrincipal " Background" colorVentanaHistorial)
destruccionesLabel := historialGui.Add("Text", "x10 y265 w250 h20 +0x201 vDestruccionesLabel c" colorTextoPrincipal " Background" colorVentanaHistorial)
contadorLabel := historialGui.Add("Text", "x10 y285 w250 h18 +0x201 vContadorLabel c" colorTextoPrincipal " Background" colorVentanaHistorial, "")
contadorLabel.SetFont("s8 c" colorTextoPrincipal, "Segoe UI")
afkText      := historialGui.Add("Text", "x10 y305 w250 h18 vAfkText c" colorAFK " Background" colorVentanaHistorial)
secuenciasLabel.SetFont("s10 Bold", "Segoe UI")
destruccionesLabel.SetFont("s10 Bold", "Segoe UI")
secuenciasLabel.OnEvent("Click", ClickSecuenciasGamer)  ; egg secreto del pack Gamer
secuenciasLabel.Value := Chr(0x276E) "  Secuencias: 0  " Chr(0x276F)
destruccionesLabel.Value := Chr(0x276E) "  Destrucciones: 0  " Chr(0x276F)
; egg Sukuna (4 brazos / 4 clicks) en destruccionesLabel
destruccionesLabel.OnEvent("Click", ClickDestruccionesSukuna)

; Centrado: 8 botones × 22px + 7 gaps × 4px = 204px → x33 a x237 (centro de GUI 270)
; Orden lógico (izq→der): macro (🚶 velocidad, 👁 overlay) · info (📊 stats, 🏆 logros)
;                          · config (🔔 webhook, ⚙ optimizar) · sistema (⟨⟩ código, ↑ update)
global btnTutorial
btnTutorial := historialGui.Add("Text", "x6 y3 w22 h19 +0x201 Background" colorBarra " c" colorTextoBarra, Chr(0x1F4D6))
btnTutorial.SetFont("s9 c" colorTextoBarra, "Segoe UI Emoji")
btnTutorial.OnEvent("Click", AbrirTutorial)
; Subir el 📖 POR ENCIMA de la barra del historial; si no, queda detrás y no se puede pulsar
DllCall("SetWindowPos", "Ptr", btnTutorial.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
; Botón 📋 Parches en el OTRO lado de la barra (derecha), espejo del 📖
global btnParches
btnParches := historialGui.Add("Text", "x242 y3 w22 h19 +0x201 Background" colorBarra " c" colorTextoBarra, Chr(0x1F4CB))
btnParches.SetFont("s9 c" colorTextoBarra, "Segoe UI Emoji")
btnParches.OnEvent("Click", AbrirParches)
DllCall("SetWindowPos", "Ptr", btnParches.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
; WS_CLIPSIBLINGS en barraHistorial: sin esto, su repintado (shimmer/hover breath)
; invade el área de btnTutorial (hermano superpuesto) y lo tapa visualmente.
estiloBarraHist := DllCall("GetWindowLong", "Ptr", barraHistorial.Hwnd, "Int", -16, "Int")
DllCall("SetWindowLong", "Ptr", barraHistorial.Hwnd, "Int", -16, "Int", estiloBarraHist | 0x04000000)
; Botón de velocidad de pasos: cicla 🐢 lento → 🚶 medio → ⚡ rápido
btnStatsBtn := historialGui.Add("Text", "x72  y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F4CA))
btnStatsBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnStatsBtn.OnEvent("Click", MostrarEstadisticas)
btnLogros := historialGui.Add("Text", "x98  y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F3C5))
btnLogros.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnLogros.OnEvent("Click", AbrirPanelLogros)
btnWebhook := historialGui.Add("Text", "x124 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F514))
btnWebhook.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnWebhook.OnEvent("Click", AbrirPanelWebhook)
btnCodigo := historialGui.Add("Text", "x150 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9000))
btnCodigo.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Symbol")
btnCodigo.OnEvent("Click", AbrirCodigo)
btnUpdate := historialGui.Add("Text", "x176 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(8593))
btnUpdate.SetFont("s8 c" colorBtnTexto, "Segoe UI Symbol")
btnUpdate.OnEvent("Click", AbrirVentanaActualizacion)

; (btnPerfil ahora vive en miGui — se crea más abajo en la sección de miGui)
; Acentos hover para botones del historial (viven en historialGui)
hoverAccentHist      := historialGui.Add("Text", "x-20 y-20 w5 h0  Background" colorBarra, "")
hoverAccentBotHist   := historialGui.Add("Text", "x-20 y-20 w0 h4  Background" colorBarra, "")
hoverAccentRightHist := historialGui.Add("Text", "x-20 y-20 w5 h0  Background" colorBarra, "")

historialGui.Show("x" (A_ScreenWidth-270) " y100 w270 h352")
RedondearVentana(historialGui.Hwnd, 14)
for _btn in [btnTutorial, btnParches]
    RedondearControl(_btn, 8)
for _btn in [btnStatsBtn, btnLogros, btnWebhook, btnCodigo, btnUpdate]
    RedondearControl(_btn, 8)

; Restaurar posición guardada del historial
_savedHistX := IniRead(configPath, "Pos", "HistX", "")
_savedHistY := IniRead(configPath, "Pos", "HistY", "")
if (_savedHistX != "" && _savedHistY != "")
    historialGui.Move(Integer(_savedHistX), Integer(_savedHistY))

; Restaurar estado del historial guardado
historialVisible := Integer(IniRead(configPath, "UI", "HistorialVisible", "1")) = 1
if (!historialVisible)
    historialGui.Hide()

; Restaurar perfil activo guardado (1=tct, 2=sp, 3=frt, 4=dstv, 5/6=vacíos extra)
perfilActivo := Integer(IniRead(configPath, "UI", "PerfilActivo", "1"))
if (perfilActivo < 1 || perfilActivo > 6)
    perfilActivo := 1

; Restaurar velocidad de pasos (1=lento, 2=medio, 3=rápido)
; El botón 🐢/🚶/⚡ ya existe (se creó arriba con el valor por defecto) →
; refrescar su emoji con el valor cargado del INI.
velocidadPasos := Integer(IniRead(configPath, "UI", "VelocidadPasos", "2"))
if (velocidadPasos < 1 || velocidadPasos > 3)
    velocidadPasos := 2

; Estimador de oro/XP (ajustable a mano en el config si cambian los valores del juego)
estXpPartida  := Integer(IniRead(configPath, "Estimador", "XpPartida9min",   "280"))
estOroPartida := Integer(IniRead(configPath, "Estimador", "OroPartida9min",  "70"))
estMinReal    := Integer(IniRead(configPath, "Estimador", "MinPartidaReal",  "9"))
estMinMacro   := Integer(IniRead(configPath, "Estimador", "MinPartidaMacro", "3"))

; Cargar config de partículas
particulasActivas   := Integer(IniRead(configPath, "Particulas", "Activas",    "1")) = 1
particulasCantidad  := Integer(IniRead(configPath, "Particulas", "Cantidad",   "100"))
particulasVelocidad := Integer(IniRead(configPath, "Particulas", "Velocidad",  "100"))
particulasTamano    := Integer(IniRead(configPath, "Particulas", "Tamano",     "100"))
particulasOpacidad  := Integer(IniRead(configPath, "Particulas", "Opacidad",   "100"))

; Cargar preset de rendimiento
presetRendimiento := Integer(IniRead(configPath, "UI", "PresetRendimiento", "4"))
if (presetRendimiento < 1 || presetRendimiento > 7)
    presetRendimiento := 4

; Cargar toggles de optimización
optHoverAccent   := Integer(IniRead(configPath, "Optimizacion", "HoverAccent",   "1")) = 1
optHoverBreath   := Integer(IniRead(configPath, "Optimizacion", "HoverBreath",   "1")) = 1
optShimmerBarra  := Integer(IniRead(configPath, "Optimizacion", "ShimmerBarra",  "1")) = 1
optPulsoBarra    := Integer(IniRead(configPath, "Optimizacion", "PulsoBarra",    "1")) = 1
optPulsoLogo     := Integer(IniRead(configPath, "Optimizacion", "PulsoLogo",     "1")) = 1
optLogoGiratorio := Integer(IniRead(configPath, "Optimizacion", "LogoGiratorio", "1")) = 1
optDecoraciones  := Integer(IniRead(configPath, "Optimizacion", "Decoraciones",  "1")) = 1
optConfeti       := Integer(IniRead(configPath, "Optimizacion", "Confeti",       "1")) = 1
optTypeReveal    := Integer(IniRead(configPath, "Optimizacion", "TypeReveal",    "1")) = 1
optEscena        := Integer(IniRead(configPath, "Optimizacion", "Escena",        "1")) = 1

; Cargar configuración de efectos de acción
efectosAccionActivos := Integer(IniRead(configPath, "Efectos", "Accion", "1")) = 1

; Abrir Brawlhalla al pulsar Iniciar (por defecto sí, = comportamiento de siempre)
abrirBrawlAlIniciar := Integer(IniRead(configPath, "UI", "AbrirBrawlAlIniciar", "1")) = 1

; Ciclo automático de descanso (jugar X h → Alt+F4 + descanso Y min → repetir)
cicloActivo  := Integer(IniRead(configPath, "Ciclo", "Activo",  "1")) = 1
CICLO_SEG    := Integer(IniRead(configPath, "Ciclo", "Horas",   "8"))  * 3600
DESCANSO_SEG := Integer(IniRead(configPath, "Ciclo", "Minutos", "60")) * 60
; Restaurar el estado del ciclo para que sobreviva a cierres/crashes (sigue el mismo timer)
cicloInicio    := IniRead(configPath, "Ciclo", "InicioTS",   "")
descansoInicio := IniRead(configPath, "Ciclo", "DescansoTS", "")
enDescanso     := Integer(IniRead(configPath, "Ciclo", "EnDescanso", "0")) = 1
; Validar los timestamps (deben ser 14 dígitos tipo A_Now); si no, descartarlos
if !(StrLen(cicloInicio) = 14 && IsInteger(cicloInicio))
    cicloInicio := ""
if !(StrLen(descansoInicio) = 14 && IsInteger(descansoInicio))
    descansoInicio := ""
; Si el ciclo ya estaba vencido al volver (p. ej. estuvo cerrado muchas horas), empezar de nuevo
if (!enDescanso && cicloInicio != "" && DateDiff(A_Now, cicloInicio, "Seconds") >= CICLO_SEG)
    cicloInicio := ""
; Si arrancamos ya en descanso (p. ej. el watchdog reinició el script durante la
; hora de descanso), el cierre del juego solo se dispara UNA VEZ al ENTRAR en
; descanso y no se repite en este nuevo arranque — forzar el cierre aquí también.
if (enDescanso) {
    CerrarBrawlhallaAltF4()
    if (descansoInicio = "")
        descansoInicio := A_Now
    AgregarHistorial(Chr(0x1F4A4) " Macro reiniciado durante el descanso — Brawlhalla cerrado, esperando para reanudar", "FF8800")
}

barra := miGui.Add("Text", "x0 y0 w400 h25 Background" colorBarra " Center", "MacroSmart v31")
barra.SetFont("s13 c" colorTextoBarra " Bold", "Segoe UI Semibold")
barra.OnEvent("Click", ArrastrarVentana)
barra.OnEvent("DoubleClick", ClickTitulo)

; Boton de perfil — pequeñito al lado izquierdo del reset.
; Click cicla 🌐 tct → 🔒 sp → ⚔ frt → 🌐 tct.
btnPerfil := miGui.Add("Text", "x290 y36 w14 h14 +0x201 Center Background" colorBotonNormal " c" colorBtnTexto, EmojiPerfil())
btnPerfil.SetFont("s8 c" colorBtnTexto " Bold", "Segoe UI Emoji")
btnPerfil.OnEvent("Click", CambiarPerfil)

btnReset    := miGui.Add("Text", "x308 y33 w20 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(8635))
btnMin      := miGui.Add("Text", "x338 y33 w20 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(8722))
btnClose    := miGui.Add("Text", "x368 y33 w20 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(215))
btnReset.OnEvent("Click", Reiniciar)
btnMin.OnEvent("Click", Minimizar)
btnClose.OnEvent("Click", Cerrar)

logoMacro := miGui.Add("Text", "x19 y31 w95 h95 Center BackgroundTrans c" colorLogoMacro " +0x1", Chr(9881))
; s49 desde el principio (antes lo re-ajustaba AplicarTema en cada cambio de tema)
logoMacro.SetFont("s49 c" colorLogoMacro " Bold", "Segoe UI Symbol")
logoMacro.OnEvent("Click", ClickLogo)
InstalarSubclassLogo()
texto := "AFK Smart"
tituloMacro := miGui.Add("Text", "x120 y70 w110 h20 Background" colorFondoPrincipal " c" colorTextoPrincipal, texto)
tituloMacro.SetFont("s13 Bold", "Segoe UI Semibold")

presetLabel := miGui.Add("Text", "x125 y155 w80 h14 +0x201 Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x26A1) " " NombrePreset(presetRendimiento))
presetLabel.SetFont("s8 c" colorTextoPrincipal, "Segoe UI Semibold")
presetLabel.OnEvent("Click", ClickPresetLeyendas)  ; cicla preset + egg secreto Pack Leyendas
fpsLabel := miGui.Add("Text", "x335 y155 w55 h14 +0x201 Background" colorFondoPrincipal " c" colorTextoPrincipal, "-- fps")
fpsLabel.SetFont("s8 c" colorTextoPrincipal, "Segoe UI")

; Luces: controles Text (sin borde) — el color de la luz es su Background.
; (Antes eran Progress, que dibujan un marco propio imposible de quitar en modo coloreable.)
luzActiva := miGui.Add("Text", "x40 y130 w20 h20 +0x201 +0x100 Background" colorBotonNormal, "")
luzAccion := miGui.Add("Text", "x70 y130 w20 h20 +0x201 +0x100 Background" colorBotonNormal, "")
luzApagado := miGui.Add("Text", "x100 y130 w20 h20 +0x201 +0x100 Background" colorLuzApagado, "")
luzActiva.OnEvent("Click", (*) => ClickLuzSecuencia(1))
luzAccion.OnEvent("Click", (*) => ClickLuzSecuencia(2))
luzApagado.OnEvent("Click", (*) => ClickLuzSecuencia(3))
OnMessage(0x0003, OnMiGuiMove)   ; WM_MOVE → reposicionar overlays EN VIVO al mover la ventana
miGui.OnEvent("Size", GuiPrincipalSize)   ; restaurar redondeo tras minimizar→restaurar

; Barra principal: Apariencia (Temas, RGB, Partículas) · Toggle Historial
; Posiciones originales: tema(240), RGB y part ocupan los huecos de hist y notas, hist va al hueco que dejó reset
; Fila de apariencia (5 botones, w24, espaciado 28px → x230..342):
;   ◐ Tema · 🖌 Personalización · 📋 Historial · 👁 Overlay · ▣ Mini
btnTema         := miGui.Add("Text", "x230 y59 w24 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9680))
btnPersonalizar := miGui.Add("Text", "x258 y59 w24 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F58C))
btnHistorial    := miGui.Add("Text", "x286 y59 w24 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(128203))
btnOverlay      := miGui.Add("Text", "x314 y59 w24 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F441))
btnMini         := miGui.Add("Text", "x342 y59 w24 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x25A3))
btnIniciar   := miGui.Add("Text", "x40 y178 w140 h36 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9654) " Iniciar (F1)")
btnParar     := miGui.Add("Text", "x220 y178 w140 h36 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9632) " Parar (F2)")
; Cuenta atrás del ciclo de descanso (cuánto falta para el Alt+F4 / para volver a jugar)
cicloLabel   := miGui.Add("Text", "x30 y218 w340 h16 +0x201 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, "")
cicloLabel.SetFont("s8", "Segoe UI")
; ── Polish visual: línea glow bajo título + separadores de sección ──
; Los separadores van mezclados ~55% hacia el fondo: se notan sin gritar
; en temas de barra saturada (Glitch magenta, Chicle, etc.)
; Líneas decorativas dimensionadas para coincidir con los elementos del UI:
;   glowTitulo: ancho completo (x0-x400)              — debajo de la barra de título
;   sepEstado:  de logo (x19) a btnMini (x366)        — debajo del área AFK/timer
;   sepAccion:  de btnIniciar (x40) a fin de btnParar (x360) — encima de Iniciar/Parar
glowTituloL := miGui.Add("Text", "x0 y25 w0 h0", "")   ; placeholders (AplicarTema los recolorea)
glowTitulo  := miGui.Add("Text", "x0  y25 w400 h2 Background" AclararHex(colorBarra, 0.35), "")
glowTituloR := miGui.Add("Text", "x0 y25 w0 h0", "")
sepEstadoL  := miGui.Add("Text", "x0 y98 w0 h0", "")
sepEstado   := miGui.Add("Text", "x19  y98 w347 h1 Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.55), "")
sepEstadoR  := miGui.Add("Text", "x0 y98 w0 h0", "")
sepAccionL  := miGui.Add("Text", "x0 y170 w0 h0", "")
sepAccion   := miGui.Add("Text", "x40  y170 w320 h1 Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.55), "")
sepAccionR  := miGui.Add("Text", "x0 y170 w0 h0", "")

; Franjas de acento para hover — 4 lados (izquierda, derecha, arriba, abajo)
hoverAccent      := miGui.Add("Text", "x-20 y-20 w5 h0 Background" colorBarra, "")
hoverAccentTop   := miGui.Add("Text", "x-20 y-20 w0 h4 Background" colorBarra, "")
hoverAccentBot   := miGui.Add("Text", "x-20 y-20 w0 h4 Background" colorBarra, "")
hoverAccentRight := miGui.Add("Text", "x-20 y-20 w5 h0 Background" colorBarra, "")

for btn in [btnTema, btnHistorial, btnReset, btnMin, btnClose]
    btn.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")
btnOverlay.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnPersonalizar.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
for btn in [btnIniciar, btnParar]
    btn.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")

btnTema.OnEvent("Click", CambiarTema)
btnHistorial.OnEvent("Click", ToggleHistorial)
btnIniciar.OnEvent("Click", Iniciar)
btnParar.OnEvent("Click", Parar)
btnOverlay.OnEvent("Click", ToggleOverlayPixeles)
btnPersonalizar.OnEvent("Click", AbrirCentroPersonalizacion)
btnMini.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")
btnMini.OnEvent("Click", ToggleMiniMode)

; ── Registro de hover para los botones principales ──
; Semántica: Iniciar activo mantiene su tinte luzOn; Parar avisa en hover con
; tinte cooldown (el rojo del tema); × cierra en rojo estándar de Windows.
RegistrarHover(btnIniciar,   () => (activo ? (rgbBotones ? colorRGBActual : MezclarHex(colorLuzActiva, colorBotonNormal, 0.45)) : (rgbBotones ? colorRGBActual : colorBotonNormal)),
                             () => (activo ? AclararHex(MezclarHex(colorLuzActiva, colorBotonNormal, 0.45), 0.18) : (rgbBotones ? colorRGBActual : colorBotonHover)))
RegistrarHover(btnParar,     () => (rgbBotones ? colorRGBActual : colorBotonNormal),
                             () => MezclarHex(colorCooldown, colorBotonNormal, 0.45))
RegistrarHover(btnTema,      () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnPersonalizar, () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnHistorial, () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnCodigo,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnReset,     () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnPerfil,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnMin,       () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnClose,     () => (rgbBotones ? colorRGBActual : colorBotonNormal), () => "C42B1C")
RegistrarHover(btnUpdate,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnOverlay,   () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnStatsBtn,  () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnWebhook,   () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnLogros,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnTutorial,  () => colorBarra, () => AclararHex(colorBarra, 0.25))
RegistrarHover(btnParches,   () => colorBarra, () => AclararHex(colorBarra, 0.25))
RegistrarHover(btnMini,      () => (rgbBotones ? colorRGBActual : colorBotonNormal))

timerLabel := miGui.Add("Text", "x220 y130 w140 h25 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x23F0) " 00:00")
timerLabel.SetFont("s13 c" colorTextoPrincipal " Bold", "Segoe UI Semibold")
timerLabel.OnEvent("Click", ClickTimer)

miGui.Show("w400 h240")
RedondearVentana(miGui.Hwnd, 20)
RedondearControl(btnPerfil, 7)
for _btn in [btnReset, btnMin, btnClose]
    RedondearControl(_btn, 10)
for _btn in [btnTema, btnPersonalizar, btnOverlay, btnHistorial, btnMini]
    RedondearControl(_btn, 12)
for _btn in [btnIniciar, btnParar]
    RedondearControl(_btn, 14)
; Luces redondeadas (ahora son Text, sin borde propio — solo hace falta la región).
for _btn in [luzActiva, luzAccion, luzApagado]
    RedondearControl(_btn, 10)
logoVelObjetivo := 0.0
SetTimer(ActualizarLogoAnimacion, 33)

; Restaurar posición guardada de la ventana principal
_savedMainX := IniRead(configPath, "Pos", "MainX", "")
_savedMainY := IniRead(configPath, "Pos", "MainY", "")
if (_savedMainX != "" && _savedMainY != "")
    miGui.Move(Integer(_savedMainX), Integer(_savedMainY))
AplicarTema(temas[temaActual], false)
AplicarTransparenciaGuardada()   ; transparencia del tema personalizado (si se configuró)
; Red de seguridad: los botones interactivos se "autocorrigen" en cuanto el
; mouse pasa por encima (HoverPoll vuelve a aplicar su región). Los controles
; que nunca reciben hover/click (las luces de estado) no tienen ese mecanismo —
; si el primer pintado del arranque (o cualquier otro repintado) queda
; cuadrado, se quedan así para siempre. Operación barata (solo SetWindowRgn,
; sin dibujar nada) así que la repetimos cada 2s indefinidamente en vez de
; una sola vez, para que cualquier control se autocorrija solo sin depender
; de encontrar la causa exacta de cada posible carrera de repintado.
SetTimer(ReaplicarTodasLasRegiones, 2000)
global hoverActual := ""
AplicarPreset(presetRendimiento)
InstalarSubclassBarras()
InstalarSubclassParticulas()
CrearOverlayDecoraciones()   ; overlay topmost para slashes Sukuna + aura Gojo
; AnimarBarras, ActualizarTrayIcon y VerificarLogros los configura AplicarPreset
; (intervalos variables segun el preset Eco/Ligero/Normal/Ultra)
EstablecerTrayIcon("888888")
ActualizarVisibilidadFrt()  ; si arrancamos en frt, ocultar labels AFK/secuencias/destruccion
SetTimer(WatchdogAFK, 30000)     ; cada 30 s; si activo && > 90 s sin AFK → Reload()
; Pulso Hollow Purple del timer cada 4s (solo activo si el tema actual es GOJO)
SetTimer(GojoPulsoHollowPurple, 4000)
; Hollow Purple: Aka + Aoi convergen cada 4s y explotan en morado (solo GOJO)
SetTimer(TickAuraGojo, 4000)
; Refresco de decoraciones permanentes (Six Eyes orbitando, kanji 両面宿儺,
; anillos). El intervalo lo fija AplicarPreset (presetDecoFps): Eco ~8fps,
; Normal ~30fps, Ultra ~60fps. Solo invalida si el tema es Gojo o Sukuna.
; (AplicarPreset más abajo lo arranca; aquí no hace falta SetTimer fijo.)
; Auto-Desmantelamiento (解): cuando el tema Sukuna está activo, dispara
; un slash cada 4 segundos automáticamente — la presencia constante del Rey
; cortando la realidad. El timer corre siempre, pero solo dispara si Sukuna
; es el tema activo (chequeo barato dentro de la función).
SetTimer(SukunaAutoDismantle, 4000)

; Ciclo automático jugar/descanso (8 h jugar → Alt+F4 + 1 h descanso → relanzar). Cada 30 s.
SetTimer(TickCicloDescanso, 30000)
; Destrabar con 'c' si Brawlhalla está abierto pero el macro no detecta nada
; (p. ej. popup de noticias al despertar del descanso). Solo tct/sp, ver función.
SetTimer(TickDestrabarC, 5000)
; Guardado periódico de stats (horas/secuencias/destrucciones): antes SOLO se
; guardaban al cerrar con la ✕ o al reiniciar — si el watchdog mataba el proceso
; o había un crash, la sesión entera se perdía (por eso las secuencias se quedaban en 0).
SetTimer(GuardarStats, 300000)

SetTimer(EscribirHeartbeat, 5000) ; cada 5 s escribe pid + timestamp en heartbeat.txt para el watchdog externo
EscribirHeartbeat()              ; un primer write inmediato
LanzarWatchdogSiNoEsta()         ; arrancar el watchdog externo en paralelo si no está corriendo
; Re-chequeo periódico: si el watchdog externo se cierra/cuelga, el macro lo
; revive. Supervisión mutua → si uno muere, el otro lo restaura.
SetTimer(LanzarWatchdogSiNoEsta, 60000)  ; cada 60 s

; Marcar arranque del macro en el log persistente
try {
    FileAppend("`r`n═══════ MACRO ARRANCADO v" VERSION_ACTUAL " - " FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") " ═══════`r`n", historialLogPath, "UTF-8")
}

; Si la instancia anterior se reinició por watchdog, auto-arrancar el macro.
; Pequeño delay para que la GUI termine de asentarse antes de Iniciar().
; El descanso solo bloquea el auto-arranque en tct/sp — en frt/dstv el ciclo no aplica.
if ((!enDescanso || PerfilSinGestion()) && IniRead(configPath, "Watchdog", "AutoStart", "0") = "1") {
    try IniDelete(configPath, "Watchdog", "AutoStart")  ; consumir flag (single-shot)
    SetTimer(() => Iniciar(), -1500)
}

; Restaurar el modo mini si estaba activo cuando se cerró el macro
if (Integer(IniRead(configPath, "UI", "MiniMode", "0")) = 1) {
    ToggleMiniMode()   ; entra en mini (modoMini era false)
    _miniX := IniRead(configPath, "Pos", "MiniX", "")
    _miniY := IniRead(configPath, "Pos", "MiniY", "")
    if (_miniX != "" && _miniY != "" && IsObject(miniGui))
        try miniGui.Move(Integer(_miniX), Integer(_miniY))
}
; ===== HOVER via polling — efecto respiratorio =====
SetTimer(ActualizarFPS, 1000)

; Registra un botón para que reciba hover + respiración.
;   btn      : control AHK
;   baseFn   : función sin args que devuelve el color HEX base (cuando no hay hover)
;   hoverFn  : función sin args que devuelve el color HEX al entrar el hover
;              (si se omite: usa colorBotonHover o el color RGB si rgbBotones está ON)
RegistrarHover(btn, baseFn, hoverFn := "") {
    global hoverBotones
    hoverBotones[btn.Hwnd] := { btn: btn, baseFn: baseFn, hoverFn: hoverFn }
}

; Helper para capturar un color HEX en una closure (evita el bug de captura por referencia en for-loops)
MakeColorFn(hex) {
    return () => hex
}

; Mezcla dos colores HEX: factor 0.0 → 100% hexA, 1.0 → 100% hexB.
; Usado para separadores sutiles (barra mezclada hacia el fondo) y tintes semánticos.
MezclarHex(hexA, hexB, factor := 0.5) {
    rA := Integer("0x" SubStr(hexA, 1, 2)), gA := Integer("0x" SubStr(hexA, 3, 2)), bA := Integer("0x" SubStr(hexA, 5, 2))
    rB := Integer("0x" SubStr(hexB, 1, 2)), gB := Integer("0x" SubStr(hexB, 3, 2)), bB := Integer("0x" SubStr(hexB, 5, 2))
    r := Round(rA + (rB - rA) * factor)
    g := Round(gA + (gB - gA) * factor)
    b := Round(bA + (bB - bA) * factor)
    return Format("{:02X}{:02X}{:02X}", r, g, b)
}

; Aclara un color HEX hacia blanco por un factor 0.0–1.0
AclararHex(hex, factor := 0.18) {
    r := Integer("0x" SubStr(hex, 1, 2))
    g := Integer("0x" SubStr(hex, 3, 2))
    b := Integer("0x" SubStr(hex, 5, 2))
    r := Min(255, r + Round((255 - r) * factor))
    g := Min(255, g + Round((255 - g) * factor))
    b := Min(255, b + Round((255 - b) * factor))
    return Format("{:02X}{:02X}{:02X}", r, g, b)
}

; Luminancia perceptual aproximada (0-255) de un color HEX. >180 ≈ "claro".
LuminanciaHex(hex) {
    r := Integer("0x" SubStr(hex, 1, 2))
    g := Integer("0x" SubStr(hex, 3, 2))
    b := Integer("0x" SubStr(hex, 5, 2))
    return (r * 299 + g * 587 + b * 114) / 1000
}

; Elimina del registro todos los botones cuyo padre sea la gui dada.
; Llamar antes de destruir un panel para evitar entradas huérfanas.
LimpiarHoverGui(gui) {
    global hoverBotones, hoverActual, hoverBreathBase
    if (!IsObject(gui))
        return
    try targetHwnd := gui.Hwnd
    if (!IsSet(targetHwnd))
        return
    aBorrar := []
    for hwnd, info in hoverBotones {
        try {
            parent := DllCall("GetParent", "Ptr", hwnd, "Ptr")
            if (parent = targetHwnd)
                aBorrar.Push(hwnd)
        }
    }
    for hwnd in aBorrar {
        if (hoverActual != "") {
            try {
                if (hoverActual.Hwnd = hwnd) {
                    hoverActual := ""
                    hoverBreathBase := ""
                }
            }
        }
        hoverBotones.Delete(hwnd)
    }
}

; ===== AUTO-CIERRE DE PANELES SECUNDARIOS =====
; Cierra paneles tras N segundos sin que el cursor pase por encima.
; No aplica al historial ni a la ventana principal.
global autoCierrePaneles := Map()

RegistrarAutoCierre(gui, closeFn, segundos := 7) {
    global autoCierrePaneles
    if (!IsObject(gui))
        return
    try {
        autoCierrePaneles[gui.Hwnd] := { gui: gui, closeFn: closeFn,
            lastActivity: A_TickCount, delay: segundos * 1000 }
        SetTimer(ChequearAutoCierre, 400)
    }
}

ChequearAutoCierre() {
    global autoCierrePaneles
    if (autoCierrePaneles.Count = 0) {
        SetTimer(ChequearAutoCierre, 0)
        return
    }
    pt := Buffer(8, 0)
    DllCall("GetCursorPos", "Ptr", pt)
    mx := NumGet(pt, 0, "Int")
    my := NumGet(pt, 4, "Int")
    aEliminar := []
    aCerrar := []
    for hwnd, data in autoCierrePaneles {
        if (!WinExist("ahk_id " hwnd)) {
            aEliminar.Push(hwnd)
            continue
        }
        sobreGui := false
        try {
            data.gui.GetPos(&gx, &gy, &gw, &gh)
            if (mx >= gx && mx <= gx + gw && my >= gy && my <= gy + gh)
                sobreGui := true
        }
        if (sobreGui) {
            data.lastActivity := A_TickCount
        } else if (A_TickCount - data.lastActivity > data.delay) {
            aEliminar.Push(hwnd)
            aCerrar.Push(data.closeFn)
        }
    }
    for hwnd in aEliminar
        try autoCierrePaneles.Delete(hwnd)
    for fn in aCerrar {
        try fn.Call()
    }
    if (autoCierrePaneles.Count = 0)
        SetTimer(ChequearAutoCierre, 0)
}

HoverPoll() {
    global hoverBotones, hoverActual, hoverBreathT, hoverBreathDir, hoverBreathBase
    global colorBotonHover, colorBtnTexto, rgbBotones, colorRGBActual, temaPremiumActivo
    global _ctrlRadios

    ; ── En modo RGB (o PREMIUM): hover desactivado para evitar parpadeo.
    ;    Los botones ya ciclan colores uniformemente con ActualizarRGB; el hover compite
    ;    con esa actualización a 33fps y produce flicker visible. Mejor sin hover.
    if (rgbBotones || temaPremiumActivo) {
        if (hoverActual != "") {
            ; Limpiar el estado de hover anterior sin tocar el color (ActualizarRGB se encarga)
            hoverActual := ""
            hoverBreathBase := ""
        }
        return
    }

    pt := Buffer(8, 0)
    DllCall("GetCursorPos", "Ptr", pt)
    x := NumGet(pt, 0, "Int")
    y := NumGet(pt, 4, "Int")
    hwndBajo := DllCall("WindowFromPoint", "Int64", x | (y << 32), "Ptr")

    encontrado := ""
    if (hoverBotones.Has(hwndBajo))
        encontrado := hoverBotones[hwndBajo].btn

    if (encontrado = hoverActual)
        return

    ; ── Quitar hover del botón anterior — restaurar su color base ─────────
    ; ORDEN CRÍTICO: Opt() puede resetear la región; hay que restaurarla (SetWindowRgn)
    ; ANTES de cualquier repintado (InvalidateRect/UpdateWindow). Si se hace al revés,
    ; UpdateWindow fuerza un pintado cuadrado antes de que la región quede redonda.
    ; Además, Opt() puede disparar su propio repintado interno (vía SWP_FRAMECHANGED)
    ; ANTES de que nuestro código llegue al SetWindowRgn — eso se ve como un flash
    ; cuadrado de un frame. WM_SETREDRAW bloquea cualquier pintado (el nuestro o el
    ; interno de Opt()) hasta que la región ya está restaurada.
    if (hoverActual != "") {
        try {
            info := hoverBotones[hoverActual.Hwnd]
            base := info.baseFn.Call()
            DllCall("SendMessageW", "Ptr", hoverActual.Hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
            hoverActual.Opt("Background" base)
            if (_ctrlRadios.Has(hoverActual)) {
                _ri := _ctrlRadios[hoverActual]
                _rrgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", _ri.rw+1, "Int", _ri.rh+1, "Int", _ri.radio, "Int", _ri.radio, "Ptr")
                DllCall("SetWindowRgn", "Ptr", hoverActual.Hwnd, "Ptr", _rrgn, "Int", 0)
            }
            DllCall("SendMessageW", "Ptr", hoverActual.Hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
            DllCall("InvalidateRect", "Ptr", hoverActual.Hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", hoverActual.Hwnd)
            InvalidarEsquinasEnPadre(hoverActual)   ; el padre rellena las esquinas que el SetWindowRgn de arriba volvió a exponer
        }
    }

    ; ── Aplicar hover al nuevo botón ─────────────────────────────────────
    if (encontrado != "") {
        info := hoverBotones[encontrado.Hwnd]
        ; Defensa: si info no tiene hoverFn (entradas antiguas o malformadas)
        ; usamos el fallback. Asi no se rompe el hover.
        if (info.HasProp("hoverFn") && IsObject(info.hoverFn))
            hoverBg := info.hoverFn.Call()
        else
            hoverBg := (rgbBotones ? colorRGBActual : colorBotonHover)
        DllCall("SendMessageW", "Ptr", encontrado.Hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
        encontrado.Opt("Background" hoverBg)
        if (_ctrlRadios.Has(encontrado)) {
            _ri := _ctrlRadios[encontrado]
            _ergn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", _ri.rw+1, "Int", _ri.rh+1, "Int", _ri.radio, "Int", _ri.radio, "Ptr")
            DllCall("SetWindowRgn", "Ptr", encontrado.Hwnd, "Ptr", _ergn, "Int", 0)
        }
        DllCall("SendMessageW", "Ptr", encontrado.Hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
        DllCall("InvalidateRect", "Ptr", encontrado.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", encontrado.Hwnd)
        InvalidarEsquinasEnPadre(encontrado)   ; el padre rellena las esquinas que el SetWindowRgn de arriba volvió a exponer
        hoverBreathT    := 0.0
        hoverBreathDir  := 1
        hoverBreathBase := hoverBg
    } else {
        hoverBreathBase := ""
    }

    hoverActual := encontrado
}

; Pulso respiratorio del botón con hover — misma cadencia que PulsoBarraActivo
HoverBreath() {
    global hoverActual, hoverBreathT, hoverBreathDir, hoverBreathBase
    global rgbBotones, temaEnTransicion, optHoverBreath, _ctrlRadios

    if (!optHoverBreath || hoverActual = "" || hoverBreathBase = "" || temaEnTransicion || rgbBotones)
        return

    hoverBreathT += 0.04 * hoverBreathDir
    if (hoverBreathT >= 1.0) {
        hoverBreathT := 1.0
        hoverBreathDir := -1
    } else if (hoverBreathT <= 0.0) {
        hoverBreathT := 0.0
        hoverBreathDir := 1
    }

    rB := Integer("0x" SubStr(hoverBreathBase, 1, 2))
    gB := Integer("0x" SubStr(hoverBreathBase, 3, 2))
    bB := Integer("0x" SubStr(hoverBreathBase, 5, 2))
    delta := Round(40 * Sin(hoverBreathT * 3.14159))
    rN := Max(0, Min(255, rB + delta))
    gN := Max(0, Min(255, gB + delta))
    bN := Max(0, Min(255, bB + delta))
    c := Format("{:02X}{:02X}{:02X}", rN, gN, bN)

    try {
        DllCall("SendMessageW", "Ptr", hoverActual.Hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
        hoverActual.Opt("Background" c)
        if (_ctrlRadios.Has(hoverActual)) {
            _ri := _ctrlRadios[hoverActual]
            _brgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", _ri.rw+1, "Int", _ri.rh+1, "Int", _ri.radio, "Int", _ri.radio, "Ptr")
            DllCall("SetWindowRgn", "Ptr", hoverActual.Hwnd, "Ptr", _brgn, "Int", 0)
        }
        DllCall("SendMessageW", "Ptr", hoverActual.Hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
        DllCall("InvalidateRect", "Ptr", hoverActual.Hwnd, "Ptr", 0, "Int", 1)
        InvalidarEsquinasEnPadre(hoverActual, false)   ; encola (sin forzar) — corre muy seguido mientras respira
    }
}

; ===== PRESETS DE RENDIMIENTO =====
NombrePreset(p) {
    switch p {
        case 1: return "Eco"
        case 2: return "Bajo"
        case 3: return "Ligero"
        case 4: return "Normal"
        case 5: return "Fluido"
        case 6: return "Alto"
        case 7: return "Ultra"
        default: return "Normal"
    }
}

FpsObjetivoPreset(p) {
    switch p {
        case 1: return 8
        case 2: return 16
        case 3: return 20
        case 4: return 30
        case 5: return 33
        case 6: return 50
        case 7: return 60
        default: return 30
    }
}

AplicarPreset(p) {
    global presetRendimiento, presetHoverPoll, presetHoverBreath
    global presetParticulas, presetPulsoBar, presetPulsoLogo, presetRGB
    global presetBarras, presetDecoraciones, presetTrayIcon, presetLogros
    global presetDecoFps
    global presetLabel, fpsLabel, particulasActivas, rgbActivo
    global activo, colorTextoPrincipal

    presetRendimiento := p
    ; Presets ordenados de MENOR a MAYOR fps (1=más ahorro, 7=más fluido/más CPU).
    ; Nombres — ver NombrePreset(): Eco(8) Bajo(16) Ligero(20) Normal(30)
    ; Fluido(33) Alto(50) Ultra(60).
    switch p {
        case 1:
            ; Eco — 8 FPS, mínimo consumo de CPU posible sin romper funcionalidad
            ; Apaga TODAS las animaciones cosmeticas. La deteccion sigue funcionando igual.
            presetHoverPoll := 150       ; 1s ~ 6fps (era 50)
            presetHoverBreath := 0       ; off — el boton hover no respira
            presetParticulas := 0        ; off — sin particulas
            presetPulsoBar := 0          ; off
            presetPulsoLogo := 0         ; off
            presetRGB := 500             ; lentisimo si esta on
            presetBarras := 200          ; AnimarBarras a 5fps (gradiente shimmer casi parado)
            presetDecoraciones := false  ; sin slashes/aura Gojo/Sukuna
            presetDecoFps := 120         ; 8fps (apenas se usa, decoraciones off)
            presetTrayIcon := 3000       ; cada 3s (era 1s)
            presetLogros := 15000        ; cada 15s (era 5s)
        case 2:
            ; Bajo — 16 FPS
            presetHoverPoll := 71
            presetHoverBreath := 53
            presetParticulas := 63
            presetPulsoBar := 53
            presetPulsoLogo := 67
            presetRGB := 247
            presetBarras := 100
            presetDecoraciones := true
            presetDecoFps := 63          ; 16fps
            presetTrayIcon := 2000
            presetLogros := 10333
        case 3:
            ; Ligero — 20 FPS
            presetHoverPoll := 32
            presetHoverBreath := 80
            presetParticulas := 50
            presetPulsoBar := 80
            presetPulsoLogo := 100
            presetRGB := 120
            presetBarras := 50
            presetDecoraciones := true
            presetDecoFps := 50          ; 20fps
            presetTrayIcon := 1500
            presetLogros := 8000
        case 4:
            ; Normal — 30 FPS, equilibrio recomendado
            presetHoverPoll := 16
            presetHoverBreath := 40
            presetParticulas := 33
            presetPulsoBar := 40
            presetPulsoLogo := 50
            presetRGB := 60
            presetBarras := 33
            presetDecoraciones := true
            presetDecoFps := 33          ; 30fps
            presetTrayIcon := 1000
            presetLogros := 5000
        case 5:
            ; Fluido — 33 FPS
            presetHoverPoll := 15
            presetHoverBreath := 38
            presetParticulas := 30
            presetPulsoBar := 38
            presetPulsoLogo := 47
            presetRGB := 57
            presetBarras := 31
            presetDecoraciones := true
            presetDecoFps := 30          ; 33fps
            presetTrayIcon := 1000
            presetLogros := 5000
        case 6:
            ; Alto — 50 FPS
            presetHoverPoll := 11
            presetHoverBreath := 27
            presetParticulas := 20
            presetPulsoBar := 27
            presetPulsoLogo := 33
            presetRGB := 40
            presetBarras := 22
            presetDecoraciones := true
            presetDecoFps := 20          ; 50fps
            presetTrayIcon := 1000
            presetLogros := 5000
        case 7:
            ; Ultra — 60 FPS, máxima fluidez (Six Eyes Gojo suaves)
            presetHoverPoll := 8
            presetHoverBreath := 20
            presetParticulas := 16
            presetPulsoBar := 20
            presetPulsoLogo := 25
            presetRGB := 30
            presetBarras := 16
            presetDecoraciones := true
            presetDecoFps := 16          ; 60fps
            presetTrayIcon := 1000
            presetLogros := 5000
    }

    SetTimer(HoverPoll, presetHoverPoll)
    SetTimer(HoverBreath, presetHoverBreath > 0 ? presetHoverBreath : 0)
    RefrescarTimersVisuales()   ; partículas y/o escena-sola según preset + toggles
    SetTimer(AnimarBarras, presetBarras)
    SetTimer(TickDecoracionesPermanentes, presetDecoFps)
    SetTimer(ActualizarTrayIcon, presetTrayIcon)
    SetTimer(VerificarLogros, presetLogros)
    if (rgbActivo)
        SetTimer(ActualizarRGB, presetRGB)
    if (activo) {
        SetTimer(PulsoBarraActivo, presetPulsoBar > 0 ? presetPulsoBar : 0)
        SetTimer(PulsoLogoActivo, presetPulsoLogo > 0 ? presetPulsoLogo : 0)
    }

    if (IsObject(presetLabel))
        try presetLabel.Text := Chr(0x26A1) " " NombrePreset(p)
    IniWrite(p, configPath, "UI", "PresetRendimiento")
}

CiclarPreset(*) {
    global presetRendimiento
    p := presetRendimiento + 1
    if (p > 7)
        p := 1
    AplicarPreset(p)
}

; Muestra el fps OBJETIVO del preset activo (no el medido en vivo): el real
; depende del coste de dibujado del momento y confundía más de lo que ayudaba.
ActualizarFPS() {
    global presetRendimiento, fpsLabel
    if (IsObject(fpsLabel))
        try fpsLabel.Text := FpsObjetivoPreset(presetRendimiento) " fps"
    try ActualizarCicloLabel()
}

; El estado del ciclo ya NO se muestra bajo los botones: ahora va como
; "💤 dormir: Xh" al lado del contador anti-AFK del historial (ActualizarAFK).
ActualizarCicloLabel() {
    global cicloLabel
    if (IsObject(cicloLabel))
        try cicloLabel.Text := ""
}

; Línea compacta del ciclo de descanso para el historial: "dormir: Xh"
; (horas que faltan para el descanso; durante el descanso, minutos para volver)
TextoDormir() {
    global cicloActivo, cicloInicio, enDescanso, descansoInicio, CICLO_SEG, DESCANSO_SEG
    if (!cicloActivo)
        return ""
    if (enDescanso && descansoInicio != "") {
        falta := DESCANSO_SEG - DateDiff(A_Now, descansoInicio, "Seconds")
        if (falta < 0)
            falta := 0
        return "dormir: ahora (" Max(1, Ceil(falta / 60.0)) "m)"
    }
    falta := (cicloInicio != "") ? CICLO_SEG - DateDiff(A_Now, cicloInicio, "Seconds") : CICLO_SEG
    if (falta < 0)
        falta := 0
    if (falta >= 3600)
        return "dormir: " Ceil(falta / 3600.0) "h"
    return "dormir: " Max(1, Ceil(falta / 60.0)) "m"
}

; ===== VELOCIDAD DE PASOS — BOTÓN 🐢/🚶/⚡ =====
EmojiVelocidad() {
    global velocidadPasos
    return velocidadPasos = 1 ? Chr(0x1F422) : (velocidadPasos = 3 ? Chr(0x26A1) : Chr(0x1F6B6))
}

NombreVelocidad() {
    global velocidadPasos
    return velocidadPasos = 1 ? "Lento" : (velocidadPasos = 3 ? "Rápido" : "Medio")
}

CiclarVelocidadPasos(*) {
    global velocidadPasos, configPath
    velocidadPasos := (velocidadPasos >= 3) ? 1 : velocidadPasos + 1
    IniWrite(velocidadPasos, configPath, "UI", "VelocidadPasos")
    AgregarHistorial(EmojiVelocidad() " Velocidad de pasos: " NombreVelocidad(), "")
    ToolTip("Velocidad de pasos: " NombreVelocidad() "  (no afecta a pasos con cooldown de 10s+)")
    SetTimer(() => ToolTip(), -1400)
}

; Formatea segundos como "Xh Ym", "Ym" o "Xs"
FormatearTiempoCorto(seg) {
    seg := Round(seg)
    if (seg >= 3600) {
        h := seg // 3600
        m := (seg - h * 3600) // 60
        return h "h " m "m"
    }
    if (seg >= 60)
        return (seg // 60) "m"
    return seg "s"
}

ClickLogo(*) {
    global eggClicks, eggUltimo, eggDesbloqueado, logoMacro, colorLogoMacro
    global eggVoidDesbloqueado, eggShadowDesbloqueado, eggSolarDesbloqueado, eggBlancoDesbloqueado
    global eggPremiumDesbloqueado, eggPremiumClicks, eggPremiumUltimo
    global eggGojoClicks, eggGojoUltimo, eggGojoDesbloqueado
    global temas, temaActual

    ; ── GOJO: con el tema Gojo activo, un click en el ∞ DESPLIEGA su Expansión de
    ;    Dominio (Vacío Ilimitado). Shift+click se reserva para el egg de los Six Eyes. ──
    if (!GetKeyState("Shift", "P") && temas[temaActual].HasProp("unlock") && temas[temaActual].unlock = "gojo") {
        LanzarDominioGojo()
        return
    }

    ; ═════════════════════════════════════════════════════════════════
    ; EGG GOJO: SHIFT + 6 clicks en el logo. Cada click "abre" uno de
    ; los Six Eyes con un color distinto del paleta de Gojo. Al sexto
    ; (los 6 ojos abiertos) → desbloquea Limitless.
    ; ═════════════════════════════════════════════════════════════════
    if (!eggGojoDesbloqueado && GetKeyState("Shift", "P")) {
        if (A_TickCount - eggGojoUltimo < 2500)
            eggGojoClicks += 1
        else
            eggGojoClicks := 1
        eggGojoUltimo := A_TickCount
        ; Cada uno de los 6 ojos tiene un color distinto que se va abriendo
        ; secuencia: azul cielo → blanco → beige → morado claro → morado profundo → cyan
        sixEyesColors := ["4FC3F7", "FFFFFF", "E8DEC4", "B388FF", "8A2BE2", "00DDFF"]
        idx := Min(eggGojoClicks, sixEyesColors.Length)
        c := colorLogoMacro
        logoMacro.SetFont("s58 c" sixEyesColors[idx] " Bold", "Segoe UI Symbol")
        DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
        SetTimer(() => (logoMacro.SetFont("s58 c" c " Bold", "Segoe UI Symbol"), DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)), -300)
        if (eggGojoClicks >= 6) {  ; los Six Eyes están abiertos
            eggGojoClicks := 0
            DesbloquearGojo()
        }
        return  ; no caer en los otros eggs del logo
    }

    ; ── Unlock PREMIUM: cuando todos los 5 secretos están desbloqueados,
    ;    10 clicks en el logo en menos de 3 segundos ──
    if (eggDesbloqueado && eggVoidDesbloqueado && eggShadowDesbloqueado
        && eggSolarDesbloqueado && eggBlancoDesbloqueado && !eggPremiumDesbloqueado) {
        if (A_TickCount - eggPremiumUltimo < 3000)
            eggPremiumClicks += 1
        else
            eggPremiumClicks := 1
        eggPremiumUltimo := A_TickCount
        ; Flash arcoíris cada click para feedback
        c := colorLogoMacro
        flashCols := ["FF0000", "FF8800", "FFFF00", "00FF00", "00CCFF", "8800FF", "FF00FF"]
        randIdx := Random(1, flashCols.Length)
        logoMacro.SetFont("s58 c" flashCols[randIdx] " Bold", "Segoe UI Symbol")
        DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
        SetTimer(() => (logoMacro.SetFont("s58 c" c " Bold", "Segoe UI Symbol"), DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)), -120)
        if (eggPremiumClicks >= 10) {
            eggPremiumClicks := 0
            DesbloquearPremium()
        }
        return
    }

    if (eggDesbloqueado)
        return
    if (A_TickCount - eggUltimo < 2000)
        eggClicks += 1
    else
        eggClicks := 1
    eggUltimo := A_TickCount
    c := colorLogoMacro
    logoMacro.SetFont("s58 cFFFFFF Bold", "Segoe UI Symbol")
    DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
    SetTimer(() => (logoMacro.SetFont("s58 c" c " Bold", "Segoe UI Symbol"), DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)), -150)
    if (eggClicks >= 5) {
        eggClicks := 0
        DesbloquearCosmos()
    }
}

DesbloquearPremium() {
    global temas, temaActual, eggPremiumDesbloqueado, configPath

    eggPremiumDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("premium")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggPremium", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "000000"
    popup.SetFont("s14 cFF00FF Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w360 h32 Background050010 Center cFFD700", "  💎  T E M A   M I T I C O   💎  ")
    popup.SetFont("s11 cFFFFFF", "Segoe UI")
    popup.Add("Text", "x10 y42 w340 h20 Center cFF00FF", "✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦")
    popup.Add("Text", "x10 y68 w340 h24 Center cFFFFFF", "Has desbloqueado  ♦ P R E M I U M ♦")
    popup.Add("Text", "x10 y96 w340 h20 Center c00FFCC", "El tema definitivo — multi-RGB en todo.")
    popup.Add("Text", "x10 y116 w340 h20 Center cFFD700", "100 veces mejor que el resto.")
    popup.Add("Text", "x10 y140 w340 h20 Center cFF00FF", "✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦")
    popup.Show("w360 h168 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -5000)
}

DesbloquearVoid() {
    global temas, temaActual, eggVoidDesbloqueado, configPath, VERSION_ACTUAL

    eggVoidDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("void")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggVoid", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "000000"
    popup.SetFont("s13 cFF0000 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w320 h28 Background111111 Center cFF0000", "  ⚡ TEMA SECRETO DESBLOQUEADO ⚡  ")
    popup.SetFont("s11 cFFFFFF", "Segoe UI")
    popup.Add("Text", "x10 y38 w300 h20 Center cFF0000", "⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡")
    popup.Add("Text", "x10 y62 w300 h22 Center cFFFFFF", "Has desbloqueado  ⚡ V O I D ⚡")
    popup.Add("Text", "x10 y86 w300 h20 Center cFF0000", "La oscuridad absoluta es tuya.")
    popup.Add("Text", "x10 y110 w300 h20 Center cFF0000", "⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡ ─ ⚡")
    popup.Show("w320 h138 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -3500)
}

DesbloquearShadow() {
    global temas, temaActual, eggShadowDesbloqueado, configPath

    eggShadowDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("shadow")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggShadow", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "050508"
    popup.SetFont("s13 cFFD700 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w320 h28 Background0D0A20 Center cFFB347", "  ☯ TEMA SECRETO DESBLOQUEADO ☯  ")
    popup.SetFont("s11 cC8A060", "Segoe UI")
    popup.Add("Text", "x10 y38 w300 h20 Center cFF6600", "☯ · · · ✦ · · · · · ✦ · · · ☯")
    popup.Add("Text", "x10 y62 w300 h22 Center cFFD700", "Has desbloqueado  ✦ E C L I P S E ✦")
    popup.Add("Text", "x10 y86 w300 h20 Center c00FFCC", "El eclipse ha comenzado.")
    popup.Add("Text", "x10 y110 w300 h20 Center cFF6600", "☯ · · · ✦ · · · · · ✦ · · · ☯")
    popup.Show("w320 h138 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -3500)
}

ClickTimer(*) {
    global eggShadowClicks, eggShadowDesbloqueado, timerLabel, colorTextoPrincipal
    if (eggShadowDesbloqueado)
        return
    eggShadowClicks += 1
    c := colorTextoPrincipal
    timerLabel.Opt("cFFB347")
    DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)
    SetTimer(() => (timerLabel.Opt("c" c), DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)), -180)
    if (eggShadowClicks >= 7) {
        eggShadowClicks := 0
        DesbloquearShadow()
    }
}

ClickTitulo(*) {
    global eggVoidClicks, eggVoidUltimo, eggVoidDesbloqueado, tituloMacro, colorTextoPrincipal
    if (eggVoidDesbloqueado)
        return
    if (A_TickCount - eggVoidUltimo < 2000)
        eggVoidClicks += 1
    else
        eggVoidClicks := 1
    eggVoidUltimo := A_TickCount
    c := colorTextoPrincipal
    tituloMacro.Opt("cFF0000")
    DllCall("InvalidateRect", "Ptr", tituloMacro.Hwnd, "Ptr", 0, "Int", 1)
    SetTimer(() => (tituloMacro.Opt("c" c), DllCall("InvalidateRect", "Ptr", tituloMacro.Hwnd, "Ptr", 0, "Int", 1)), -150)
    if (eggVoidClicks >= 5) {
        eggVoidClicks := 0
        DesbloquearVoid()
    }
}

; ═══════════════════════════════════════════════════════════════
; EGG GOJO — Secuencia de temas: Azul → Rojo
; ═══════════════════════════════════════════════════════════════
DesbloquearEggGojoSecuencia() {
    global temas, temaActual, eggGojoDesbloqueado, configPath

    eggGojoDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("gojo")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggGojo", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "0A0E1F"
    popup.SetFont("s14 cE8DEC4 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w360 h32 Background5B2A8C Center cFFFFFF", "  ♾  L I M I T L E S S  D E S B L O Q U E A D O  ♾  ")
    popup.SetFont("s11 c4FC3F7", "Segoe UI")
    popup.Add("Text", "x10 y42 w340 h20 Center c8A2BE2", "○ · · ◉ · · ○ · · ◉ · · ○ · · ◉")
    popup.SetFont("s13 cFFFFFF Bold", "Segoe UI Semibold")
    popup.Add("Text", "x10 y66 w340 h24 Center cFFFFFF", "♾  G O J O  S A T O R U  ♾")
    popup.SetFont("s10 cE8DEC4 Italic", "Segoe UI")
    popup.Add("Text", "x10 y94 w340 h20 Center cE8DEC4", '" Throughout heaven and earth, "')
    popup.Add("Text", "x10 y112 w340 h20 Center cE8DEC4", '" I alone am the honored one. "')
    popup.SetFont("s9 c4FC3F7", "Segoe UI")
    popup.Add("Text", "x10 y138 w340 h18 Center c4FC3F7", "Los Seis Ojos están abiertos. El Infinito te protege.")
    popup.SetFont("s9 c8A2BE2", "Segoe UI")
    popup.Add("Text", "x10 y158 w340 h20 Center c8A2BE2", "○ · · ◉ · · ○ · · ◉ · · ○ · · ◉")
    popup.Show("w360 h184 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -4500)
}

; ═══════════════════════════════════════════════════════════════
; EGG GOJO (antiguo) — 6 clicks rápidos (Six Eyes) en secuenciasLabel
; ═══════════════════════════════════════════════════════════════
DesbloquearGojo() {
    DesbloquearEggGojoSecuencia()  ; reutilizar la misma función
}

; ═══════════════════════════════════════════════════════════════
; EGG SUKUNA — 4 clicks rápidos (4 brazos del Rey) en destruccionesLabel
; ═══════════════════════════════════════════════════════════════
DesbloquearSukuna() {
    global temas, temaActual, eggSukunaDesbloqueado, configPath

    eggSukunaDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("sukuna")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggSukuna", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "0A0000"
    popup.SetFont("s14 cD9D5D2 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w360 h32 Background2E0506 Center cD9D5D2", "  ⛩  E L  R E Y  D E  L A S  M A L D I C I O N E S  ⛩  ")
    popup.SetFont("s11 cFF3030", "Segoe UI")
    popup.Add("Text", "x10 y42 w340 h20 Center cFF3030", "⛧ · · · ⛩ · · · · · · · · · ⛩ · · · ⛧")
    popup.SetFont("s13 cD9D5D2 Bold", "Segoe UI Semibold")
    popup.Add("Text", "x10 y66 w340 h24 Center cD9D5D2", "⛩  R Y O M E N  S U K U N A  ⛩")
    popup.SetFont("s10 cD9D5D2 Italic", "Segoe UI")
    popup.Add("Text", "x10 y94 w340 h20 Center cD9D5D2", '" 天上天下、唯我独尊 "')
    popup.Add("Text", "x10 y112 w340 h20 Center cFF3030", '" Entre el cielo y la tierra, "')
    popup.Add("Text", "x10 y130 w340 h20 Center cFF3030", '" sólo yo merezco honor. "')
    popup.SetFont("s9 cD00000", "Segoe UI")
    popup.Add("Text", "x10 y158 w340 h18 Center cD00000", "El Rey de las Maldiciones se alza. 真人")
    popup.Add("Text", "x10 y178 w340 h20 Center cFF3030", "⛧ · · · ⛩ · · · · · · · · · ⛩ · · · ⛧")
    popup.Show("w360 h204 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -4500)
}

ClickDestruccionesSukuna(*) {
    global eggSukunaClicks, eggSukunaUltimo, eggSukunaDesbloqueado, destruccionesLabel, colorTextoPrincipal
    if (eggSukunaDesbloqueado)
        return
    if (A_TickCount - eggSukunaUltimo < 2500)
        eggSukunaClicks += 1
    else
        eggSukunaClicks := 1
    eggSukunaUltimo := A_TickCount
    c := colorTextoPrincipal
    destruccionesLabel.Opt("cFF4500")  ; flash naranja fuego (Fuga)
    DllCall("InvalidateRect", "Ptr", destruccionesLabel.Hwnd, "Ptr", 0, "Int", 1)
    SetTimer(() => (destruccionesLabel.Opt("c" c), DllCall("InvalidateRect", "Ptr", destruccionesLabel.Hwnd, "Ptr", 0, "Int", 1)), -180)
    if (eggSukunaClicks >= 4) {  ; CUATRO BRAZOS
        eggSukunaClicks := 0
        DesbloquearSukuna()
    }
}

; ===== FUNCIONES GUI =====
; ===== BACKUP ROBUSTO DE EGGS (UTF-8 — inmune a problemas de codificación del .ini) =====
CargarEggsBackup() {
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggGamerDesbloqueado, eggsBackupPath
    global eggGojoDesbloqueado, eggSukunaDesbloqueado, eggLeyendasDesbloqueado
    if (!FileExist(eggsBackupPath))
        return
    try {
        txt := FileRead(eggsBackupPath, "UTF-8")
        if (InStr(txt, "cosmos"))
            eggDesbloqueado := true
        if (InStr(txt, "void"))
            eggVoidDesbloqueado := true
        if (InStr(txt, "shadow"))
            eggShadowDesbloqueado := true
        if (InStr(txt, "solar"))
            eggSolarDesbloqueado := true
        if (InStr(txt, "blanco"))
            eggBlancoDesbloqueado := true
        if (InStr(txt, "premium"))
            eggPremiumDesbloqueado := true
        if (InStr(txt, "gamer"))
            eggGamerDesbloqueado := true
        if (InStr(txt, "leyendas"))
            eggLeyendasDesbloqueado := true
        if (InStr(txt, "gojo"))
            eggGojoDesbloqueado := true
        if (InStr(txt, "sukuna"))
            eggSukunaDesbloqueado := true
    }
}

GuardarEggsBackup() {
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggGamerDesbloqueado, eggsBackupPath
    global eggGojoDesbloqueado, eggSukunaDesbloqueado, eggLeyendasDesbloqueado
    txt := ""
    if (eggDesbloqueado)
        txt .= "cosmos`n"
    if (eggVoidDesbloqueado)
        txt .= "void`n"
    if (eggShadowDesbloqueado)
        txt .= "shadow`n"
    if (eggSolarDesbloqueado)
        txt .= "solar`n"
    if (eggBlancoDesbloqueado)
        txt .= "blanco`n"
    if (eggPremiumDesbloqueado)
        txt .= "premium`n"
    if (eggGamerDesbloqueado)
        txt .= "gamer`n"
    if (eggLeyendasDesbloqueado)
        txt .= "leyendas`n"
    if (eggGojoDesbloqueado)
        txt .= "gojo`n"
    if (eggSukunaDesbloqueado)
        txt .= "sukuna`n"
    try FileDelete(eggsBackupPath)
    try FileAppend(txt, eggsBackupPath, "UTF-8")
}

; Devuelve true si el usuario puede usar este tema (no-secreto o secreto desbloqueado).
PuedeUsarTema(t) {
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggGamerDesbloqueado
    global eggGojoDesbloqueado, eggSukunaDesbloqueado, eggLeyendasDesbloqueado
    if (!t.HasProp("secreto") || !t.secreto)
        return true
    if (!t.HasProp("unlock"))
        return false
    switch t.unlock {
        case "shadow":   return eggShadowDesbloqueado
        case "cosmos":   return eggDesbloqueado
        case "void":     return eggVoidDesbloqueado
        case "solar":    return eggSolarDesbloqueado
        case "blanco":   return eggBlancoDesbloqueado
        case "premium":  return eggPremiumDesbloqueado
        case "gamer":    return eggGamerDesbloqueado
        case "leyendas": return eggLeyendasDesbloqueado
        case "gojo":     return eggGojoDesbloqueado
        case "sukuna":   return eggSukunaDesbloqueado
    }
    return false
}

; Busca el índice del primer tema con el unlock id dado (devuelve 0 si no existe).
BuscarTemaPorUnlock(unlockId) {
    global temas
    for i, t in temas {
        if (t.HasProp("unlock") && t.unlock = unlockId)
            return i
    }
    return 0
}

LeerTemaGuardado() {
    global configPath, temas, eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggGamerDesbloqueado, VERSION_ACTUAL
    global eggGojoDesbloqueado, eggSukunaDesbloqueado, eggLeyendasDesbloqueado
    eggDesbloqueado        := Integer(IniRead(configPath, "Egg",        "Desbloqueado", "0")) = 1
    eggVoidDesbloqueado    := Integer(IniRead(configPath, "EggVoid",    "Desbloqueado", "0")) = 1
    eggShadowDesbloqueado  := Integer(IniRead(configPath, "EggShadow",  "Desbloqueado", "0")) = 1
    eggSolarDesbloqueado   := Integer(IniRead(configPath, "EggSolar",   "Desbloqueado", "0")) = 1
    eggBlancoDesbloqueado  := Integer(IniRead(configPath, "EggBlanco",  "Desbloqueado", "0")) = 1
    eggPremiumDesbloqueado := Integer(IniRead(configPath, "EggPremium", "Desbloqueado", "0")) = 1
    eggGamerDesbloqueado   := Integer(IniRead(configPath, "EggGamer",   "Desbloqueado", "0")) = 1
    eggLeyendasDesbloqueado := Integer(IniRead(configPath, "EggLeyendas", "Desbloqueado", "0")) = 1
    eggGojoDesbloqueado    := Integer(IniRead(configPath, "EggGojo",    "Desbloqueado", "0")) = 1
    eggSukunaDesbloqueado  := Integer(IniRead(configPath, "EggSukuna",  "Desbloqueado", "0")) = 1
    ; Fallback: si el .ini está corrupto o en UTF-16, leer del backup UTF-8
    CargarEggsBackup()
    ; Re-guardar al backup para mantenerlo sincronizado
    GuardarEggsBackup()
    ; Primero intentamos por NOMBRE (resiliente a reordenes del array)
    valor := 0
    nombreGuardado := IniRead(configPath, "Tema", "Nombre", "")
    if (nombreGuardado != "") {
        for i, t in temas {
            if (t.nombre = nombreGuardado) {
                valor := i
                break
            }
        }
    }
    ; Fallback al índice (INIs viejos sin Nombre)
    if (valor = 0)
        valor := Integer(IniRead(configPath, "Tema", "Actual", "1"))
    if (valor < 1 || valor > temas.Length)
        valor := 1
    ; Si el tema guardado es secreto y NO está desbloqueado → caer al tema 1
    if (!PuedeUsarTema(temas[valor]))
        valor := 1
    return valor
}

GuardarTema() {
    global configPath, temaActual, temas
    IniWrite(temaActual, configPath, "Tema", "Actual")
    ; Guardar también por nombre — sobrevive a reordenes del array
    if (temaActual >= 1 && temaActual <= temas.Length)
        IniWrite(temas[temaActual].nombre, configPath, "Tema", "Nombre")
}

; ===== WEBHOOK DISCORD =====
LeerWebhook() {
    global configPath, webhookURL, webhookEnabled, webhookEventos
    webhookURL := IniRead(configPath, "Webhook", "URL", "")
    webhookEnabled := Integer(IniRead(configPath, "Webhook", "Enabled", "0")) = 1
    for k, defaultValue in webhookEventos.Clone() {
        ; Si no existe en el INI, usa el default del mapa (true/false)
        defaultStr := defaultValue ? "1" : "0"
        webhookEventos[k] := Integer(IniRead(configPath, "Webhook", "Evt_" k, defaultStr)) = 1
    }
}

GuardarWebhook() {
    global configPath, webhookURL, webhookEnabled, webhookEventos
    IniWrite(webhookURL,                configPath, "Webhook", "URL")
    IniWrite(webhookEnabled ? 1 : 0,    configPath, "Webhook", "Enabled")
    for k, v in webhookEventos
        IniWrite(v ? 1 : 0, configPath, "Webhook", "Evt_" k)
}

EscapeJson(s) {
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`t", "\t")
    return s
}

EnviarWebhook(titulo, mensaje, colorHex := "5865F2") {
    global webhookURL, webhookEnabled
    if (!webhookEnabled || webhookURL = "")
        return
    SetTimer(EnviarWebhookSync.Bind(titulo, mensaje, colorHex), -1)
}

EnviarWebhookSync(titulo, mensaje, colorHex) {
    global webhookURL
    if (webhookURL = "")
        return
    colorInt := Integer("0x" colorHex)
    titulo := EscapeJson(titulo)
    mensaje := EscapeJson(mensaje)
    json := '{"embeds":[{"title":"' titulo '","description":"' mensaje '","color":' colorInt ',"footer":{"text":"AFK Macro"}}]}'

    ; Enviar via ComObject en modo SÍNCRONO dentro del timer de un solo disparo
    ; (el modo async + WaitForResponse fallaba a veces sin dejar rastro).
    ; Si falla (red, rate-limit 429 de Discord...), reintenta UNA vez tras 1.5s.
    loop 2 {
        intento := A_Index
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.SetTimeouts(5000, 5000, 10000, 10000)
            whr.Open("POST", webhookURL, false)
            whr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
            whr.Send(json)
            status := whr.Status
            if (status = 204 || status = 200)
                return  ; enviado OK
            if (intento = 2) {
                respText := ""
                try respText := whr.ResponseText
                AgregarHistorial("⚠ Webhook HTTP " status ": " SubStr(respText, 1, 60), "FF5555")
                return
            }
        } catch as e {
            if (intento = 2) {
                AgregarHistorial("⚠ Webhook error: " SubStr(e.Message, 1, 60), "FF5555")
                return
            }
        }
        Sleep 1500
    }
}

; ===== SCREENSHOT A DISCORD (Alt+F4 / destrucción) =====
GetPNGEncoderCLSID() {
    static buf := ""
    if (buf = "") {
        ; CLSID del encoder PNG: {557CF406-1A04-11D3-9A73-0000F81EF32E}
        buf := Buffer(16, 0)
        NumPut("UInt",   0x557CF406, buf,  0)
        NumPut("UShort", 0x1A04,     buf,  4)
        NumPut("UShort", 0x11D3,     buf,  6)
        NumPut("UChar",  0x9A,       buf,  8)
        NumPut("UChar",  0x73,       buf,  9)
        NumPut("UChar",  0x00,       buf, 10)
        NumPut("UChar",  0x00,       buf, 11)
        NumPut("UChar",  0xF8,       buf, 12)
        NumPut("UChar",  0x1E,       buf, 13)
        NumPut("UChar",  0xF3,       buf, 14)
        NumPut("UChar",  0x2E,       buf, 15)
    }
    return buf
}

TomarScreenshot(rutaPNG) {
    global gdipInited
    if (!gdipInited)
        InicializarGdip()

    sw := A_ScreenWidth
    sh := A_ScreenHeight
    hdcScreen := DllCall("GetDC",                "Ptr", 0, "Ptr")
    hdcMem    := DllCall("CreateCompatibleDC",   "Ptr", hdcScreen, "Ptr")
    hBitmap   := DllCall("CreateCompatibleBitmap", "Ptr", hdcScreen, "Int", sw, "Int", sh, "Ptr")
    oldBmp    := DllCall("SelectObject",         "Ptr", hdcMem, "Ptr", hBitmap, "Ptr")
    DllCall("BitBlt", "Ptr", hdcMem, "Int", 0, "Int", 0, "Int", sw, "Int", sh,
            "Ptr", hdcScreen, "Int", 0, "Int", 0, "UInt", 0x00CC0020)

    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "Ptr*", &pBitmap)
    success := false
    if (pBitmap) {
        try FileDelete(rutaPNG)
        encoderCLSID := GetPNGEncoderCLSID()
        ret := DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", rutaPNG, "Ptr", encoderCLSID, "Ptr", 0)
        success := (ret = 0)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    }

    DllCall("SelectObject", "Ptr", hdcMem,    "Ptr", oldBmp)
    DllCall("DeleteObject", "Ptr", hBitmap)
    DllCall("DeleteDC",     "Ptr", hdcMem)
    DllCall("ReleaseDC",    "Ptr", 0, "Ptr", hdcScreen)
    return success && FileExist(rutaPNG)
}

EnviarWebhookConFoto(titulo, mensaje, colorHex) {
    global webhookURL, webhookEnabled
    if (!webhookEnabled || webhookURL = "")
        return
    SetTimer(EnviarWebhookConFotoSync.Bind(titulo, mensaje, colorHex), -1)
}

EnviarWebhookConFotoSync(titulo, mensaje, colorHex) {
    global webhookURL
    ; Sin curl (necesario para multipart) → mandar el texto sin foto en vez de nada
    if (!FileExist(A_WinDir "\System32\curl.exe")) {
        EnviarWebhookSync(titulo, mensaje, colorHex)
        return
    }
    rutaFoto := A_Temp "\brawlmacro_shot_" A_TickCount ".png"
    if (!TomarScreenshot(rutaFoto)) {
        EnviarWebhookSync(titulo, mensaje, colorHex)
        return
    }

    colorInt := Integer("0x" colorHex)
    tEsc := EscapeJson(titulo)
    mEsc := EscapeJson(mensaje)
    json := '{"embeds":[{"title":"' tEsc '","description":"' mEsc '","color":' colorInt ',"image":{"url":"attachment://screenshot.png"},"footer":{"text":"AFK Macro"}}]}'

    ; curl necesario para multipart (adjuntar imagen)
    payloadFile := A_Temp "\brawlmacro_payload_" A_TickCount ".json"
    try FileDelete(payloadFile)
    try FileAppend(json, payloadFile, "UTF-8-RAW")
    cmd := A_ComSpec ' /c curl.exe -s -m 30 -X POST'
         . ' -F "payload_json=<' payloadFile ';type=application/json"'
         . ' -F "file=@' rutaFoto ';filename=screenshot.png"'
         . ' "' webhookURL '"'
         . ' & del "' payloadFile '" & del "' rutaFoto '"'
    try Run(cmd, , "Hide")
}

EnviarWebhookEvento(tipo) {
    global webhookEnabled, webhookEventos, webhookURL
    global contadorSecuencias, contadorDestruccion
    global totalSecuenciasGuardadas, totalDestruccionGuardada
    global tiempoAcumulado, tiempoInicio, timerActivo
    if (!webhookEnabled || webhookURL = "")
        return
    if (!webhookEventos.Has(tipo) || !webhookEventos[tipo])
        return

    tiempoSesion := tiempoAcumulado
    if (timerActivo)
        tiempoSesion += (A_TickCount - tiempoInicio)
    h := Floor(tiempoSesion / 3600000)
    m := Floor((tiempoSesion - h*3600000) / 60000)
    durStr := Format("{:02}h {:02}m", h, m)
    secs := contadorSecuencias + totalSecuenciasGuardadas
    destru := contadorDestruccion + totalDestruccionGuardada

    switch tipo {
        case "iniciado":
            EnviarWebhook(Chr(0x25B6) " Macro iniciado",
                "El macro AFK ha comenzado.`nSecuencias totales: " secs,
                "00CC44")
        case "parado":
            EnviarWebhook(Chr(0x23F8) " Macro parado",
                "Sesión: " durStr "`nSecuencias totales: " secs,
                "888888")
        case "destruccion":
            EnviarWebhookConFoto(Chr(0x26A0) " Modo destrucción activado",
                "El macro lleva 4:30 sin detectar nada.`nAlt+F4 en 1 minuto si no se recupera.`n📸 Captura adjunta:",
                "FF6600")
        case "altf4":
            EnviarWebhookConFoto(Chr(0x1F480) " Alt+F4 ejecutado",
                "Brawlhalla cerrado y relanzándose.`nDestrucciones totales: " destru "`n📸 Captura adjunta:",
                "FF2222")
        case "secuencia":
            EnviarWebhook(Chr(0x2705) " Secuencia completada",
                "Secuencia completada: " contadorSecuencias " (sesión)`nTotal: " secs
                . "`nEstimado total: ~" FormatearMiles(Round(secs * OroPorSecuencia())) " oro · ~" FormatearMiles(Round(secs * XpPorSecuencia())) " XP",
                "00AAFF")
    }
}

EnviarWebhookMilestone(n) {
    global webhookEnabled, webhookEventos, webhookURL
    if (!webhookEnabled || webhookURL = "")
        return
    if (!webhookEventos.Has("milestone") || !webhookEventos["milestone"])
        return
    EnviarWebhook(Chr(0x1F3C6) " ¡Hito alcanzado!",
        n " secuencias completadas.",
        "FFD700")
}

global webhookGuiRef := ""

AbrirPanelWebhook(*) {
    global webhookURL, webhookEnabled, webhookEventos
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBtnTexto, colorFondoHistorial
    global webhookGuiRef

    ; Toggle: si ya está abierto, cerrar y salir
    if (IsObject(webhookGuiRef)) {
        try LimpiarHoverGui(webhookGuiRef)
        try webhookGuiRef.Destroy()
        webhookGuiRef := ""
        return
    }

    wg := Gui("+AlwaysOnTop -Caption +ToolWindow")
    wg.BackColor := colorFondoPrincipal
    webhookGuiRef := wg
    W := 360

    barr := wg.Add("Text", "x0 y0 w" W " h28 Background" colorBarra " Center", Chr(0x1F514) " Webhook Discord")
    barr.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => (LimpiarHoverGui(wg), wg.Destroy(), webhookGuiRef := ""))

    wg.Add("Text", "x12 y36 w" (W - 24) " h14 c" colorTextoPrincipal " Background" colorFondoPrincipal, "URL del webhook:").SetFont("s9", "Segoe UI")
    urlEdit := wg.Add("Edit", "x12 y54 w" (W - 24) " h22 Background" colorFondoHistorial " c" colorTextoPrincipal " -E0x200", webhookURL)
    urlEdit.SetFont("s9", "Consolas")

    cbEnable := wg.Add("CheckBox", "x12 y84 w" (W - 24) " h20 c" colorTextoPrincipal " Background" colorFondoPrincipal " Checked" (webhookEnabled ? 1 : 0), " Activar envío de notificaciones")
    cbEnable.SetFont("s10 Bold", "Segoe UI")

    wg.Add("Text", "x12 y112 w" (W - 24) " h14 c" colorTextoPrincipal " Background" colorFondoPrincipal, "Eventos a enviar:").SetFont("s9 Bold", "Segoe UI")

    cbInic := wg.Add("CheckBox", "x22 y130 w" (W - 34) " h18 c" colorTextoPrincipal " Background" colorFondoPrincipal " Checked" (webhookEventos["iniciado"] ? 1 : 0), " " Chr(0x25B6) " Macro iniciado")
    cbPar  := wg.Add("CheckBox", "x22 y148 w" (W - 34) " h18 c" colorTextoPrincipal " Background" colorFondoPrincipal " Checked" (webhookEventos["parado"] ? 1 : 0), " " Chr(0x23F8) " Macro parado")
    cbDest := wg.Add("CheckBox", "x22 y166 w" (W - 34) " h18 c" colorTextoPrincipal " Background" colorFondoPrincipal " Checked" (webhookEventos["destruccion"] ? 1 : 0), " " Chr(0x26A0) " Modo destrucción activado")
    cbAlt  := wg.Add("CheckBox", "x22 y184 w" (W - 34) " h18 c" colorTextoPrincipal " Background" colorFondoPrincipal " Checked" (webhookEventos["altf4"] ? 1 : 0), " " Chr(0x1F480) " Alt+F4 ejecutado")
    cbMile := wg.Add("CheckBox", "x22 y202 w" (W - 34) " h18 c" colorTextoPrincipal " Background" colorFondoPrincipal " Checked" (webhookEventos["milestone"] ? 1 : 0), " " Chr(0x1F3C6) " Hitos de secuencias")
    cbSeq  := wg.Add("CheckBox", "x22 y220 w" (W - 34) " h18 c" colorTextoPrincipal " Background" colorFondoPrincipal " Checked" (webhookEventos["secuencia"] ? 1 : 0), " " Chr(0x2705) " Cada secuencia completada")
    for cb in [cbInic, cbPar, cbDest, cbAlt, cbMile, cbSeq]
        cb.SetFont("s9", "Segoe UI")

    lblStatus := wg.Add("Text", "x12 y244 w" (W - 24) " h16 c" colorTextoPrincipal " Background" colorFondoPrincipal, "")
    lblStatus.SetFont("s9 Italic", "Segoe UI")

    btnW := Round((W - 36) / 2)
    btnTest := wg.Add("Text", "x12 y266 w" btnW " h28 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(0x1F9EA) " Probar")
    btnSave := wg.Add("Text", "x" (24 + btnW) " y266 w" btnW " h28 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(0x1F4BE) " Guardar")
    for b in [btnTest, btnSave]
        b.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI")

    aplicarEstado := (*) => (
        webhookURL := Trim(urlEdit.Value, " `t`r`n"),
        webhookEnabled := cbEnable.Value,
        webhookEventos["iniciado"]   := cbInic.Value,
        webhookEventos["parado"]     := cbPar.Value,
        webhookEventos["destruccion"] := cbDest.Value,
        webhookEventos["altf4"]      := cbAlt.Value,
        webhookEventos["milestone"]  := cbMile.Value,
        webhookEventos["secuencia"]  := cbSeq.Value,
        GuardarWebhook(),
        AgregarHistorial(Chr(0x1F514) " Webhook guardado — "
            (webhookURL = "" ? "SIN URL" : (webhookEnabled ? "activado" : "DESACTIVADO")),
            (webhookURL != "" && webhookEnabled) ? "00CC44" : "FF8800")
    )

    btnTest.OnEvent("Click", (*) => (
        aplicarEstado(),
        (webhookURL = "" ? (lblStatus.Value := "Pon una URL antes de probar.", lblStatus.Opt("cFF5555"))
            : !webhookEnabled ? (EnviarWebhookForce("🧪 Test desde AFK Macro", "Si ves este mensaje, el webhook funciona correctamente.", "5865F2"),
               lblStatus.Value := "Test enviado — ¡pero el envío está DESACTIVADO! Marca la casilla.", lblStatus.Opt("cFF8800"))
            : (EnviarWebhookForce("🧪 Test desde AFK Macro", "Si ves este mensaje, el webhook funciona correctamente.", "5865F2"),
               lblStatus.Value := "Mensaje enviado — revisa Discord.", lblStatus.Opt("c00CC44")))
    ))
    btnSave.OnEvent("Click", (*) => (aplicarEstado(), LimpiarHoverGui(wg), wg.Destroy(), webhookGuiRef := ""))
    RegistrarHover(btnTest, () => colorBotonNormal)
    RegistrarHover(btnSave, () => colorBotonNormal)

    wg.Show("w" W " h306 Center")
    RedondearVentana(wg.Hwnd, 14)
    RegistrarAutoCierre(wg, (*) => (LimpiarHoverGui(wg), wg.Destroy(), webhookGuiRef := ""))
}

EnviarWebhookForce(titulo, mensaje, colorHex) {
    ; Para el test — ignora el toggle de "Enabled"
    SetTimer(EnviarWebhookSync.Bind(titulo, mensaje, colorHex), -1)
}

ArrastrarGenerico(g) {
    PostMessage(0xA1, 2,,, "ahk_id " g.Hwnd)
}

LeerRGBsGuardados() {
    global configPath, rgbBarra, rgbBotones, rgbLogo, rgbTexto, rgbActivo
    global rgbVelocidad, rgbSaturacion, rgbBrillo, rgbHueInicio, rgbBarraHue
    global rgbDireccion
    rgbBarra   := Integer(IniRead(configPath, "RGB", "Barra",   "0")) = 1
    rgbBotones := Integer(IniRead(configPath, "RGB", "Botones", "0")) = 1
    rgbLogo    := Integer(IniRead(configPath, "RGB", "Logo",    "0")) = 1
    rgbTexto   := Integer(IniRead(configPath, "RGB", "Texto",   "0")) = 1
    rgbActivo  := rgbBarra || rgbBotones || rgbLogo || rgbTexto
    rgbVelocidad  := Integer(IniRead(configPath, "RGB", "Velocidad",  "2"))
    rgbSaturacion := Float(IniRead(configPath,   "RGB", "Saturacion", "1.0"))
    rgbBrillo     := Float(IniRead(configPath,   "RGB", "Brillo",     "1.0"))
    rgbHueInicio  := Integer(IniRead(configPath, "RGB", "HueInicio",  "0"))
    rgbDireccion  := Integer(IniRead(configPath, "RGB", "Direccion",  "1"))
    rgbBarraHue   := rgbHueInicio
}

GuardarRGBs() {
    global configPath, rgbBarra, rgbBotones, rgbLogo, rgbTexto
    global rgbVelocidad, rgbSaturacion, rgbBrillo, rgbHueInicio
    global rgbDireccion
    IniWrite(rgbBarra   ? 1 : 0, configPath, "RGB", "Barra")
    IniWrite(rgbBotones ? 1 : 0, configPath, "RGB", "Botones")
    IniWrite(rgbLogo    ? 1 : 0, configPath, "RGB", "Logo")
    IniWrite(rgbTexto   ? 1 : 0, configPath, "RGB", "Texto")
    IniWrite(rgbVelocidad,              configPath, "RGB", "Velocidad")
    IniWrite(Round(rgbSaturacion, 2),   configPath, "RGB", "Saturacion")
    IniWrite(Round(rgbBrillo, 2),       configPath, "RGB", "Brillo")
    IniWrite(rgbHueInicio,              configPath, "RGB", "HueInicio")
    IniWrite(rgbDireccion,              configPath, "RGB", "Direccion")
}

GuardarPosiciones() {
    global configPath, miGui, historialGui, modoMini, miniGui
    ; try alrededor de cada uno: si la ventana está minimizada/oculta puede tirar
    try {
        miGui.GetPos(&mx, &my)
        IniWrite(mx, configPath, "Pos", "MainX")
        IniWrite(my, configPath, "Pos", "MainY")
    }
    try {
        historialGui.GetPos(&hx, &hy)
        IniWrite(hx, configPath, "Pos", "HistX")
        IniWrite(hy, configPath, "Pos", "HistY")
    }
    ; Posición de la mini ventana (si está activa) para restaurarla igual
    if (modoMini && IsObject(miniGui)) {
        try {
            miniGui.GetPos(&mnx, &mny)
            IniWrite(mnx, configPath, "Pos", "MiniX")
            IniWrite(mny, configPath, "Pos", "MiniY")
        }
    }
}

; ===== PANEL DE PARTÍCULAS =====
AbrirPanelParticulas(*) {
    global partGui, partGuiVisible, configPath
    global particulasActivas, particulasCantidad, particulasVelocidad, particulasTamano, particulasOpacidad
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBotonHover, colorBtnTexto

    if (partGuiVisible && IsObject(partGui)) {
        try LimpiarHoverGui(partGui)
        try partGui.Destroy()
        partGuiVisible := false
        return
    }

    partGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    partGui.BackColor := colorFondoPrincipal
    W := 260

    ; Barra superior arrastrable + cierre al click
    barr := partGui.Add("Text", "x0 y0 w" W " h28 Background" colorBarra " Center +0x200",
                        "  " Chr(0x2728) "  Partículas")
    barr.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " partGui.Hwnd))
    barr.OnEvent("DoubleClick", (*) => CerrarPanelParticulas())

    y := 40

    ; Toggle activas
    chk := partGui.Add("CheckBox", "x16 y" y " w" (W - 32) " h22 c" colorTextoPrincipal " Background" colorFondoPrincipal,
                       " Activar partículas")
    chk.SetFont("s10 Bold", "Segoe UI")
    chk.Value := particulasActivas ? 1 : 0
    chk.OnEvent("Click", PartChkActivas)
    y += 32

    ; ── Slider: Cantidad ──
    partGui.Add("Text", "x16 y" y " w120 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal, "Cantidad").SetFont("s9 Bold", "Segoe UI")
    lblCant := partGui.Add("Text", "x" (W - 60) " y" y " w44 h18 Right c" colorTextoPrincipal " Background" colorFondoPrincipal, particulasCantidad "%")
    lblCant.SetFont("s9", "Segoe UI")
    y += 18
    sldCant := partGui.Add("Slider", "x16 y" y " w" (W - 32) " h22 Range0-200 ToolTip", particulasCantidad)
    sldCant.OnEvent("Change", PartSlidCant)
    y += 30

    ; ── Slider: Velocidad ──
    partGui.Add("Text", "x16 y" y " w120 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal, "Velocidad").SetFont("s9 Bold", "Segoe UI")
    lblVel := partGui.Add("Text", "x" (W - 60) " y" y " w44 h18 Right c" colorTextoPrincipal " Background" colorFondoPrincipal, particulasVelocidad "%")
    lblVel.SetFont("s9", "Segoe UI")
    y += 18
    sldVel := partGui.Add("Slider", "x16 y" y " w" (W - 32) " h22 Range0-200 ToolTip", particulasVelocidad)
    sldVel.OnEvent("Change", PartSlidVel)
    y += 30

    ; ── Slider: Tamaño ──
    partGui.Add("Text", "x16 y" y " w120 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal, "Tamaño").SetFont("s9 Bold", "Segoe UI")
    lblTam := partGui.Add("Text", "x" (W - 60) " y" y " w44 h18 Right c" colorTextoPrincipal " Background" colorFondoPrincipal, particulasTamano "%")
    lblTam.SetFont("s9", "Segoe UI")
    y += 18
    sldTam := partGui.Add("Slider", "x16 y" y " w" (W - 32) " h22 Range50-200 ToolTip", particulasTamano)
    sldTam.OnEvent("Change", PartSlidTam)
    y += 30

    ; ── Slider: Opacidad ──
    partGui.Add("Text", "x16 y" y " w120 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal, "Opacidad").SetFont("s9 Bold", "Segoe UI")
    lblOpa := partGui.Add("Text", "x" (W - 60) " y" y " w44 h18 Right c" colorTextoPrincipal " Background" colorFondoPrincipal, particulasOpacidad "%")
    lblOpa.SetFont("s9", "Segoe UI")
    y += 18
    sldOpa := partGui.Add("Slider", "x16 y" y " w" (W - 32) " h22 Range25-200 ToolTip", particulasOpacidad)
    sldOpa.OnEvent("Change", PartSlidOpa)
    y += 30

    ; Guardar referencias a las labels para que los callbacks de slider las actualicen
    partGui._lblCant := lblCant
    partGui._lblVel  := lblVel
    partGui._lblTam  := lblTam
    partGui._lblOpa  := lblOpa

    ; Botones inferiores
    btnAplicar := partGui.Add("Text", "x16 y" y " w110 h32 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                              Chr(0x2714) "  Aplicar")
    btnAplicar.SetFont("s10 Bold", "Segoe UI Semibold")
    btnAplicar.OnEvent("Click", PartBtnAplicar)
    RegistrarHover(btnAplicar, () => colorBotonNormal)

    btnDefecto := partGui.Add("Text", "x" (W - 16 - 110) " y" y " w110 h32 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                              Chr(0x21BB) "  Por defecto")
    btnDefecto.SetFont("s10 Bold", "Segoe UI Semibold")
    btnDefecto.OnEvent("Click", PartBtnDefecto)
    RegistrarHover(btnDefecto, () => colorBotonNormal)

    y += 42
    partGui.Show("w" W " h" y " Center")
    RedondearVentana(partGui.Hwnd, 12)
    partGuiVisible := true
    RegistrarAutoCierre(partGui, CerrarPanelParticulas)
}

PartChkActivas(ctrl, *) {
    global particulasActivas, configPath
    particulasActivas := ctrl.Value = 1
    try IniWrite(particulasActivas ? 1 : 0, configPath, "Particulas", "Activas")
    AplicarConfigParticulas()
    RefrescarTimersVisuales()
}

PartSlidCant(ctrl, *) {
    global particulasCantidad, partGui
    particulasCantidad := ctrl.Value
    try partGui._lblCant.Value := particulasCantidad "%"
}
PartSlidVel(ctrl, *) {
    global particulasVelocidad, partGui
    particulasVelocidad := ctrl.Value
    try partGui._lblVel.Value := particulasVelocidad "%"
}
PartSlidTam(ctrl, *) {
    global particulasTamano, partGui
    particulasTamano := ctrl.Value
    try partGui._lblTam.Value := particulasTamano "%"
}
PartSlidOpa(ctrl, *) {
    global particulasOpacidad, partGui
    particulasOpacidad := ctrl.Value
    try partGui._lblOpa.Value := particulasOpacidad "%"
}

PartBtnAplicar(*) {
    global configPath, particulasCantidad, particulasVelocidad, particulasTamano, particulasOpacidad
    try {
        IniWrite(particulasCantidad,  configPath, "Particulas", "Cantidad")
        IniWrite(particulasVelocidad, configPath, "Particulas", "Velocidad")
        IniWrite(particulasTamano,    configPath, "Particulas", "Tamano")
        IniWrite(particulasOpacidad,  configPath, "Particulas", "Opacidad")
    }
    AplicarConfigParticulas()
    CerrarPanelParticulas()
}

PartBtnDefecto(*) {
    global particulasActivas, particulasCantidad, particulasVelocidad, particulasTamano, particulasOpacidad, configPath
    particulasActivas   := true
    particulasCantidad  := 100
    particulasVelocidad := 100
    particulasTamano    := 100
    particulasOpacidad  := 100
    try {
        IniWrite(1,   configPath, "Particulas", "Activas")
        IniWrite(100, configPath, "Particulas", "Cantidad")
        IniWrite(100, configPath, "Particulas", "Velocidad")
        IniWrite(100, configPath, "Particulas", "Tamano")
        IniWrite(100, configPath, "Particulas", "Opacidad")
    }
    AplicarConfigParticulas()
    CerrarPanelParticulas()
    AbrirPanelParticulas()  ; reabrir para que los sliders se vuelvan a posicionar en 100%
}

CerrarPanelParticulas() {
    global partGui, partGuiVisible
    if (partGuiVisible && IsObject(partGui)) {
        try LimpiarHoverGui(partGui)
        try partGui.Destroy()
        partGuiVisible := false
    }
}

; ═══════════════════════════════════════════════════════════════
; PANEL DE OPTIMIZACIÓN — toggles individuales de efectos visuales
; ═══════════════════════════════════════════════════════════════
AbrirPanelOptimizacion(*) {
    global optGui, optGuiVisible
    global optHoverAccent, optHoverBreath, optShimmerBarra, optPulsoBarra
    global optPulsoLogo, optLogoGiratorio, optDecoraciones, optConfeti, optTypeReveal
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBotonHover, colorBtnTexto, configPath

    if (optGuiVisible && IsObject(optGui)) {
        try LimpiarHoverGui(optGui)
        try optGui.Destroy()
        optGuiVisible := false
        return
    }

    optGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    optGui.BackColor := colorFondoPrincipal
    W := 270

    barr := optGui.Add("Text", "x0 y0 w" W " h28 Background" colorBarra " Center +0x200",
                       "  " Chr(0x2699) "  Optimización")
    barr.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " optGui.Hwnd))
    barr.OnEvent("DoubleClick", (*) => CerrarPanelOptimizacion())

    y := 38

    toggles := [
        {var: "optHoverAccent",   label: "Hover Accent",         desc: "Colores de efecto de los botones"},
        {var: "optHoverBreath",   label: "Hover Breath",         desc: "Efecto de los botones"},
        {var: "optShimmerBarra",  label: "Shimmer Barra",        desc: "Gradiente animado en barras"},
        {var: "optPulsoBarra",    label: "Pulso Detección",      desc: "Onda en barra al detectar"},
        {var: "optPulsoLogo",     label: "Pulso Logo",           desc: "Pulso de brillo del logo"},
        {var: "optLogoGiratorio", label: "Logo Giratorio",       desc: "Animación del engranaje"},
        {var: "optDecoraciones",  label: "Decoraciones",         desc: "Efectos los temas"},
        {var: "optConfeti",       label: "Confeti",              desc: "Confeti en milestones"},
        {var: "optTypeReveal",    label: "Type Reveal",          desc: "Revelado progresivo de texto"},
        {var: "optEscena",        label: "Decoración del tema",   desc: "Decorado del borde por tema. Se mantiene aunque las partículas/Eco estén apagadas"},
    ]

    for t in toggles {
        val := OptGetValor(t.var)
        chk := optGui.Add("CheckBox", "x16 y" y " w" (W - 32) " h20 c" colorTextoPrincipal " Background" colorFondoPrincipal,
                          " " t.label)
        chk.SetFont("s9 Bold", "Segoe UI")
        chk.Value := val ? 1 : 0
        varName := t.var
        chk.OnEvent("Click", OptToggleCallback.Bind(varName))

        optGui.Add("Text", "x32 y" (y + 20) " w" (W - 48) " h14 c" colorBarra " Background" colorFondoPrincipal, t.desc)
            .SetFont("s7", "Segoe UI")
        y += 38
    }

    y += 4
    sep := optGui.Add("Text", "x16 y" y " w" (W - 32) " h1 Background" colorBarra, "")
    y += 8

    btnTodoOn := optGui.Add("Text", "x16 y" y " w110 h28 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                            Chr(0x2714) " Todo ON")
    btnTodoOn.SetFont("s9 Bold", "Segoe UI Semibold")
    btnTodoOn.OnEvent("Click", OptTodoOn)
    RegistrarHover(btnTodoOn, () => colorBotonNormal)

    btnTodoOff := optGui.Add("Text", "x" (W - 16 - 110) " y" y " w110 h28 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                             Chr(0x2716) " Todo OFF")
    btnTodoOff.SetFont("s9 Bold", "Segoe UI Semibold")
    btnTodoOff.OnEvent("Click", OptTodoOff)
    RegistrarHover(btnTodoOff, () => colorBotonNormal)
    y += 38

    ; ── Extra: efectos de acción (movido desde Personalización) ──
    optGui.Add("Text", "x16 y" y " w" (W - 32) " h1 Background" colorBarra, "")
    y += 8
    btnEfOpt := optGui.Add("Text", "x16 y" y " w" (W-32) " h30 +0x201 Background" (efectosAccionActivos ? colorBarra : colorBotonNormal) " c" colorBtnTexto " Center",
        (efectosAccionActivos ? Chr(0x2714) : Chr(0x2716)) " Efectos de acción")
    btnEfOpt.SetFont("s9 Bold", "Segoe UI Semibold")
    btnEfOpt.OnEvent("Click", (*) => (ToggleEfectosAccion(), SetTimer(() => (CerrarPanelOptimizacion(), AbrirPanelOptimizacion()), -1)))
    RegistrarHover(btnEfOpt, () => (efectosAccionActivos ? colorBarra : colorBotonNormal))

    y += 38
    optGui.Show("w" W " h" y " Center")
    RedondearVentana(optGui.Hwnd, 12)
    optGuiVisible := true
    RegistrarAutoCierre(optGui, CerrarPanelOptimizacion)
}

OptGetValor(varName) {
    global optHoverAccent, optHoverBreath, optShimmerBarra, optPulsoBarra
    global optPulsoLogo, optLogoGiratorio, optDecoraciones, optConfeti, optTypeReveal, optEscena
    switch varName {
        case "optHoverAccent":      return optHoverAccent
        case "optHoverBreath":      return optHoverBreath
        case "optShimmerBarra":     return optShimmerBarra
        case "optPulsoBarra":       return optPulsoBarra
        case "optPulsoLogo":        return optPulsoLogo
        case "optLogoGiratorio":    return optLogoGiratorio
        case "optDecoraciones":     return optDecoraciones
        case "optConfeti":          return optConfeti
        case "optTypeReveal":       return optTypeReveal
        case "optEscena":           return optEscena
    }
    return false
}

OptToggleCallback(varName, ctrl, *) {
    global optEscena
    global configPath
    global optHoverAccent, optHoverBreath, optShimmerBarra, optPulsoBarra
    global optPulsoLogo, optLogoGiratorio, optDecoraciones, optConfeti, optTypeReveal
    val := ctrl.Value = 1
    switch varName {
        case "optHoverAccent":      optHoverAccent      := val
        case "optHoverBreath":      optHoverBreath      := val
        case "optShimmerBarra":     optShimmerBarra     := val
        case "optPulsoBarra":       optPulsoBarra       := val
        case "optPulsoLogo":        optPulsoLogo        := val
        case "optLogoGiratorio":    optLogoGiratorio    := val
        case "optDecoraciones":     optDecoraciones     := val
        case "optConfeti":          optConfeti          := val
        case "optTypeReveal":       optTypeReveal       := val
        case "optEscena":           optEscena           := val
    }
    iniKey := StrReplace(varName, "opt", "")
    IniWrite(val ? 1 : 0, configPath, "Optimizacion", iniKey)
    if (varName = "optEscena")
        RefrescarTimersVisuales()   ; encender/apagar la escena al instante (incluso en Eco)
}

OptSetTodos(val) {
    global configPath
    global optHoverAccent, optHoverBreath, optShimmerBarra, optPulsoBarra
    global optPulsoLogo, optLogoGiratorio, optDecoraciones, optConfeti, optTypeReveal, optEscena
    optHoverAccent   := val
    optHoverBreath   := val
    optShimmerBarra  := val
    optPulsoBarra    := val
    optPulsoLogo     := val
    optLogoGiratorio := val
    optDecoraciones  := val
    optConfeti       := val
    optTypeReveal    := val
    optEscena        := val
    v := val ? 1 : 0
    IniWrite(v, configPath, "Optimizacion", "HoverAccent")
    IniWrite(v, configPath, "Optimizacion", "HoverBreath")
    IniWrite(v, configPath, "Optimizacion", "ShimmerBarra")
    IniWrite(v, configPath, "Optimizacion", "PulsoBarra")
    IniWrite(v, configPath, "Optimizacion", "PulsoLogo")
    IniWrite(v, configPath, "Optimizacion", "LogoGiratorio")
    IniWrite(v, configPath, "Optimizacion", "Decoraciones")
    IniWrite(v, configPath, "Optimizacion", "Confeti")
    IniWrite(v, configPath, "Optimizacion", "TypeReveal")
    IniWrite(v, configPath, "Optimizacion", "Escena")
}

OptTodoOn(*) {
    OptSetTodos(true)
    RefrescarTimersVisuales()
    try {
        CerrarPanelOptimizacion()
        AbrirPanelOptimizacion()
    }
}

OptTodoOff(*) {
    OptSetTodos(false)
    RefrescarTimersVisuales()
    try {
        CerrarPanelOptimizacion()
        AbrirPanelOptimizacion()
    }
}

CerrarPanelOptimizacion() {
    global optGui, optGuiVisible
    if (optGuiVisible && IsObject(optGui)) {
        try LimpiarHoverGui(optGui)
        try optGui.Destroy()
        optGuiVisible := false
    }
}

; ═══════════════════════════════════════════════════════════════
; TUTORIAL — libro navegable con páginas que explican todo el macro
; ═══════════════════════════════════════════════════════════════
TutorialPaginas() {
    return [
    { ico: Chr(0x1F4D6), tit: "Tutorial AFK Smart",
      txt: "Este macro automatiza principalmente el farmeo AFK en Brawlhalla y otros juegos.`n`n"
         . "Detecta píxeles en la pantalla y hace acciones específicas: farmea, juega y sigue. Para conseguir oro, xp y darte una pequeña ventaja en algunos juegos.`n`n"
         . "Usa los botones  ◀ Anterior  y  Siguiente ▶  de abajo para pasar las páginas de este libro." },

    { ico: Chr(0x25B6), tit: "Empezar: Iniciar y Parar",
      txt: "• ▶ Iniciar (F1): arranca el macro. Abre Brawlhalla si hace falta y empieza a detectar.`n`n"
         . "• ■ Parar (F2): detiene las detecciones del macro y pausa todo lo que tenga que ver con el funcionamiento.`n`n"
         . "Los cuadraditos de arriba muestran el funcionamiento:`n"
         . "Primero: macro activo | Segundo: hizo una acción | Tercero: macro apagado.`n`n"
         . "El reloj ⏱ cuenta el tiempo que lleva activo." },

    { ico: Chr(0x1F3AE), tit: "Perfiles (botón perfil / F3)",
      txt: "Cambian QUÉ hace el macro:`n`n"
         . "• 🌐 tct — farmeo público: Juega todos contra todos en Brawlhalla.`n`n"
         . "• 🔒 sp — farmeo privado: crea sala en Brawlhalla y juega con un bot.`n`n"
         . "• ⚔ frt — modo fruta: farmea nivel en fruits battleground.`n`n"
         . "• ∅ dstv — generadores: Para distrito de violencia para hacer los generadores." },

    { ico: Chr(0x1F3A8), tit: "Apariencia y personalización",
      txt: "• ◐ Tema: sirve para cambiar el aspecto del macro con ~65 temas (claros, oscuros, temáticos y secretos (se consiguen con los logros)).`n`n"
         . "• 🎨 RGB: configura el rgb de ciertas partes del macro.`n`n"
         . "• ✨ Partículas: ajusta las partículas de fondo.`n`n"
         . "• ▣ Mini: hace el macro pequeño para que no moleste en la pantalla." },

    { ico: Chr(0x25A3), tit: "Mini ventana",
      txt: "El botón ▣ Mini encoge el macro a una ventana pequeña que no estorba mientras juegas.`n`n"
         . "Abajo tiene 3 botones:`n"
         . "• ▶ Iniciar · ■ Parar · ✕ Cerrar (cierra el macro).`n`n"
         . "Para volver a la ventana grande: doble clic en la barra de arriba de la mini.`n`n"
         . "Si cierras el macro estando en mini, al volver a abrirlo seguirá en mini, en el mismo sitio." },

    { ico: Chr(0x1F6E0), tit: "Botones de herramientas",
      txt: "En la ventana del historial hay estos botones (en este orden):`n`n"
         . "• 📖 Tutorial — este libro (arriba a la izquierda de la barra). 📋 Parches — las novedades de cada versión (arriba a la derecha).`n"
         . "• 🚶 Velocidad — cambia la velocidad de los pasos del macro (página siguiente).`n"
         . "• 👁 Overlay — muestra los píxeles que tiene que detectar. (para que no pongas el macro ahí).`n"
         . "• 📊 Stats — tus estadísticas totales.`n"
         . "• 🏆 Logros — logros conseguidos y por obtener.`n"
         . "• 🔔 Webhook — avisos a Discord.`n"
         . "• ⚙ Optimizar — quita efectos para mejor rendimiento.`n"
         . "• ⟨⟩ Código — abre el código del macro.`n"
         . "• ↑ Update — actualiza el macro (si es que hay actualización).`n`n"
	 . "• En las siguientes páginas se explicará más a detalle cada uno de estos para entenderlo mejor." },

    { ico: Chr(0x1F6B6), tit: "Velocidad de pasos",
      txt: "El botón 🐢/🚶/⚡ del historial cambia cada cuánto revisan la pantalla los pasos del macro:`n`n"
         . "• 🐢 Lento — revisa menos seguido. Menos falsos positivos y menos CPU.`n`n"
         . "• 🚶 Medio — velocidad normal (recomendado).`n`n"
         . "• ⚡ Rápido — revisa el doble de seguido. Reacciona antes a lo que pasa en pantalla.`n`n"
         . "Los pasos con cooldown largo (10 segundos o más) no cambian con este botón — esos van a su ritmo fijo.`n`n"
         . "Se guarda solo: al reabrir el macro sigue en la velocidad que dejaste." },

    { ico: Chr(0x26A1), tit: "Rendimiento (si va lento)",
      txt: "Baja o sube los fps del macro para mejor rendimiento:`n`n"
         . "• Eco : pocas animaciones (recomendado en pc lenta, como la del xavi).`n"
         . "• Bajo · Ligero · Normal · Fluido · Alto · Ultra : cada paso anima más fluido pero usa más CPU.`n`n"
         . "En ⚙ Optimizar apagas efectos sueltos. El toggle 'Decoración del tema' mantiene o quita los adornos del borde, aunque estés en Eco.`n`n"
         . "No afecta en el funcionamiento del macro." },

    { ico: Chr(0x1F4DC), tit: "Historial",
      txt: "Registra cada acción del macro con hora y un color según el tipo de evento.`n`n"
         . "Puedes mirar todas las acciones con la rueda del ratón.`n`n"
         . "Guarda hasta 5000 líneas en pantalla y guarda automáticamente todas las acciones en brawlmacro_historial.log por si el macro se crashea o lo cierras por accidente." },

    { ico: Chr(0x1F6E1), tit: "Anti-AFK y recuperación",
      txt: "Aunque el macro se crashee, aún así se inicia de nuevo como si lo hubieras abierto:`n`n"
         . "• Anti-AFK: cada cierto tiempo manda teclas para no quedar inactivo.`n`n"
         . "• Modo Destrucción: si pasa demasiado sin detectar nada, cierra Brawlhalla y lo vuelve a abrir.`n`n"
         . "• Watchdog: un vigilante externo para el macro. Si el macro se congela o se cierra solo, lo vuelve a abrir. Si estaba activo el macro, seguirá activo después de abrirse." },

    { ico: Chr(0x1F4A4), tit: "Descanso automático",
      txt: "Para no jugar 24/7 de seguido, el juego descansa solo:`n`n"
         . "• Tras 8 horas jugando, cierra Brawlhalla (Alt+F4 una vez) y espera 1 hora.`n`n"
         . "• El macro NO se apaga: se queda encendido en pausa de detección. Al acabar la hora reabre Brawlhalla y sigue solo.`n`n"
         . "• Si le das a ▶ Iniciar durante el descanso, lo cancelas y empieza un ciclo nuevo de 8h.`n`n"
         . "El contador sigue igual aunque pares, cierres o se crashee el macro. Se ajusta (horas/minutos) o se apaga en el config, sección [Ciclo]." },

    { ico: Chr(0x1F514), tit: "Webhook de Discord",
      txt: "Pega la URL de un webhook de tu servidor y el macro te avisa por Discord de:`n`n"
         . "Vas a tu servidor (o un servidor donde tengas permisos), configuras un canal, vas a integraciones y añades un webhook.`n"
	 . "Ahí puedes crear un webhook, copias el link y lo pegas en el macro.`n"
	 . "Puedes configurar el webhook con estas opciones para que te avise sobre estas acciones que haga el macro, algunas hacen captura de pantalla para que tengas una idea de cómo ocurrió el error:`n"
	 . "iniciado · parado · destrucción · Alt+F4 · hitos · secuencias.`n`n"
         . "Puedes activar o desactivar cada tipo de aviso por separado." },

    { ico: Chr(0x1F3C6), tit: "Logros y estadísticas",
      txt: "• 📊 Stats: horas totales, secuencias, destrucciones y el ORO y XP estimados que llevas farmeados (calculado por secuencias: cada partida de ~3 min da ~23 monedas y ~93 XP; se ajusta en el config, sección [Estimador]).`n`n"
         . "• 🏆 Logros: se desbloquean solos al cumplir retos (tu 1ª secuencia, 100 secuencias, 24 horas, 10 destrucciones...).`n`n"
         . "Algunos logros son SECRETOS y solo muestran una pista — descúbrelos tú mismo." },

    { ico: Chr(0x1F4A1), tit: "¿Quieres un macro de otro juego?",
      txt: "La siguiente página ya es la última.`n`n"
         . "Si tienes una petición para un macro de algún juego, dímelo y lo intentaré hacer.`n`n"
         . "No te aseguro que salga, depende del juego y de si se puede detectar bien, pero lo intento.`n`n"
         . "Y gracias por usar el macro." },

    { ico: Chr(0x2764), tit: "FIN",
      txt: "Y ya está, con esto ya sabes lo básico.`n`n"
         . "Pon el perfil que quieras, dale a F1 y deja el macro farmeando tranquilo mientras haces otra cosa.`n`n"
         . "Ve probando los temas y a ver si encuentras los secretos, que hay unos cuantos escondidos por ahí.`n`n"
         . "Si algo se rompe o se ve raro, avísame y lo arreglo.`n`n"
         . "Para cerrar el libro toca la barra de arriba. ¡A farmear! 🎮" }
    ]
}

AbrirTutorial(*) {
    global tutGui, tutGuiVisible, tutPagina
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBotonHover, colorBtnTexto

    if (IsObject(tutGui)) {
        CerrarTutorial()
        return
    }

    tutPagina := 1
    tutGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    tutGuiVisible := true   ; marcar YA (antes de cualquier paso que pueda fallar)
    tutGui.BackColor := colorFondoPrincipal
    tutGui.OnEvent("Escape", CerrarTutorial)
    tutGui.OnEvent("Close", CerrarTutorial)
    W := 460

    ; Barra superior (arrastrar / cerrar)
    barr := tutGui.Add("Text", "x0 y0 w" W " h32 Background" colorBarra " Center +0x200",
                       "  " Chr(0x1F4D6) "  Tutorial — AFK Smart")
    barr.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " tutGui.Hwnd))
    barr.OnEvent("DoubleClick", (*) => CerrarTutorial())

    ; Botón cerrar (×) en la esquina de la barra
    btnX := tutGui.Add("Text", "x" (W - 30) " y4 w24 h24 +0x201 Background" colorBarra " c" colorTextoBarra " Center", Chr(215))
    btnX.SetFont("s12 Bold", "Segoe UI")
    btnX.OnEvent("Click", (*) => CerrarTutorial())

    ; Título de página (icono + texto)
    lblTit := tutGui.Add("Text", "x20 y44 w" (W - 40) " h26 Background" colorFondoPrincipal " c" colorTextoPrincipal)
    lblTit.SetFont("s13 Bold", "Segoe UI Semibold")

    ; Línea separadora
    tutGui.Add("Text", "x20 y72 w" (W - 40) " h1 Background" colorBarra, "")

    ; Cuerpo de la página
    lblTxt := tutGui.Add("Text", "x20 y82 w" (W - 40) " h268 Background" colorFondoPrincipal " c" colorTextoPrincipal)
    lblTxt.SetFont("s10", "Segoe UI")

    ; Separador inferior
    tutGui.Add("Text", "x20 y356 w" (W - 40) " h1 Background" colorBarra, "")

    ; Navegación
    btnPrev := tutGui.Add("Text", "x20 y366 w130 h32 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                          Chr(0x25C0) "  Anterior")
    btnPrev.SetFont("s10 Bold", "Segoe UI Semibold")
    btnPrev.OnEvent("Click", (*) => TutorialNav(-1))
    RegistrarHover(btnPrev, () => colorBotonNormal)

    lblCount := tutGui.Add("Text", "x150 y372 w" (W - 300) " h20 +0x201 Background" colorFondoPrincipal " c" colorTextoPrincipal " Center")
    lblCount.SetFont("s10 Bold", "Segoe UI")

    btnNext := tutGui.Add("Text", "x" (W - 20 - 130) " y366 w130 h32 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                          "Siguiente  " Chr(0x25B6))
    btnNext.SetFont("s10 Bold", "Segoe UI Semibold")
    btnNext.OnEvent("Click", (*) => TutorialNav(1))
    RegistrarHover(btnNext, () => colorBotonNormal)

    tutGui._lblTit := lblTit
    tutGui._lblTxt := lblTxt
    tutGui._lblCount := lblCount

    TutorialRender()
    tutGui.Show("w" W " h410 Center")
    try RedondearVentana(tutGui.Hwnd, 14)
}

TutorialRender() {
    global tutGui, tutPagina
    if (!IsObject(tutGui))
        return
    pgs := TutorialPaginas()
    if (tutPagina < 1)
        tutPagina := 1
    if (tutPagina > pgs.Length)
        tutPagina := pgs.Length
    p := pgs[tutPagina]
    try {
        tutGui._lblTit.Value   := p.ico "  " p.tit
        tutGui._lblTxt.Value   := p.txt
        tutGui._lblCount.Value := tutPagina " / " pgs.Length
    }
}

TutorialNav(dir) {
    global tutPagina
    tutPagina += dir
    TutorialRender()
}

CerrarTutorial(*) {
    global tutGui, tutGuiVisible
    tutGuiVisible := false
    if (IsObject(tutGui)) {
        try LimpiarHoverGui(tutGui)
        try tutGui.Destroy()
    }
    tutGui := ""
}

; ═══════════════════════════════════════════════════════════════
; PARCHES — libro separado (📋 a la derecha de la barra del historial)
; Una página por versión, resumen en puntos sin explicar mucho.
; ═══════════════════════════════════════════════════════════════
ParchesPaginas() {
    return [
    { ico: Chr(0x1F4CB), tit: "Parche 31.5 (actual)",
      txt: "· Personalizar: opción para NO abrir Brawlhalla al iniciar`n"
         . "· Botones y luces SIEMPRE redondos (iniciar/minimizar/tema/mini)`n"
         . "· Logo del modo mini: sombra alineada y bajado a su sitio`n"
         . "· Botón 📋 Parches reaparece (estaba invisible)`n"
         . "· Efectos de acción más vistosos + actualizador arreglado`n" },

    { ico: Chr(0x1F4CB), tit: "Parche 31.2",
      txt: "· Botones y luces redondeados al cambiar de color`n"
         . "· Líneas decorativas a ancho completo`n"
         . "· Botón 'Abrir en bloc de notas' eliminado`n"
         . "· 5 botones superiores recentrados`n"
         . "· Personalización: incluye RGB y Partículas`n"
         . "· Efectos de acción movidos a Optimización`n"
         . "· Efecto de acción según el tema (lluvia, viento...)`n" },

    { ico: Chr(0x1F3A8), tit: "Parche 31.1 — Mejoras UI",
      txt: "· Notificación en historial cuando el macro arranca ya cerrando Brawlhalla`n"
         . "· Modo dormir: cierre de Brawlhalla fiable, sin despertar al instante`n"
         . "· Relanzamiento correcto tras cancelar el descanso`n"
         . "· Cierre directo del proceso de Brawlhalla sin Alt+F4`n"
         . "· Modo dormir pausa acciones pero mantiene PC despierta con mov. ratón`n"
         . "· Efectos de acción en TODOS los temas (onda glow/zoom al detectar)`n"
         . "· Expansión de Dominio Gojo: animación completa 30 frames al hacer clic`n"
         . "· Sistema de temas 100% personalizable: editor de colores + guardado`n"
         . "· Perfiles 5 y 6 vacíos: sin timers ni AFK, modo base libre`n"
         . "· Hotkeys reasignables: F1/F2/Mini configurables desde la UI`n"
         . "· Visor en vivo: ● parpadeante muestra qué paso detecta en tiempo real`n"
         . "· Botón 📝 abre el macro directamente en el Bloc de notas`n" },

    { ico: Chr(0x1F4D6), tit: "Parche 30.7.9 — Rendimiento",
      txt: "· Estimador de oro y XP en historial, Stats y webhook`n"
         . "· Lo nuevo SIEMPRE arriba; rueda de scroll respeta 10s`n"
         . "· Modo mini: botones, ✕ y mini historial`n"
         . "· Descanso de 1h: reabre Brawlhalla solo`n"
         . "· Sistema de velocidad (🐢/🚶/⚡) por paso`n"
         . "· Stats se guardan cada 5 min`n"
         . "· Webhook arreglado: secuencias contadas`n"
         . "· Libro de parches 📋 separado del tutorial`n"
         . "· 25 temas mejorados o rediseñados`n"
         . "· Bugs arreglados" },

    { ico: Chr(0x1F30C), tit: "Parche 30.5-30.6 — Visual",
      txt: "· Tutorial 📖 con libro navegable de páginas`n"
         . "· Decoración única para los 65 temas (cero repetición)`n"
         . "· Temas Agua, Hielo, Polar, Nube y más mejorados`n"
         . "· Sukuna sin cortes feos en la decoración`n"
         . "· Decoración independiente del preset de partículas`n"
         . "· Fix del botón Tutorial tapado por el hover`n"
         . "· Bugs arreglados" }
    ]
}

AbrirParches(*) {
    global parchesGui, parchesGuiVisible, parchesPagina
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBtnTexto

    if (IsObject(parchesGui)) {
        CerrarParches()
        return
    }

    parchesPagina := 1
    parchesGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    parchesGuiVisible := true
    parchesGui.BackColor := colorFondoPrincipal
    parchesGui.OnEvent("Escape", CerrarParches)
    parchesGui.OnEvent("Close", CerrarParches)
    W := 400

    barr := parchesGui.Add("Text", "x0 y0 w" W " h32 Background" colorBarra " Center +0x200",
                       "  " Chr(0x1F4CB) "  Parches — MacroSmart")
    barr.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " parchesGui.Hwnd))
    barr.OnEvent("DoubleClick", (*) => CerrarParches())

    btnX := parchesGui.Add("Text", "x" (W - 30) " y4 w24 h24 +0x201 Background" colorBarra " c" colorTextoBarra " Center", Chr(215))
    btnX.SetFont("s12 Bold", "Segoe UI")
    btnX.OnEvent("Click", (*) => CerrarParches())

    lblTit := parchesGui.Add("Text", "x20 y44 w" (W - 40) " h26 Background" colorFondoPrincipal " c" colorTextoPrincipal)
    lblTit.SetFont("s13 Bold", "Segoe UI Semibold")

    parchesGui.Add("Text", "x20 y72 w" (W - 40) " h1 Background" colorBarra, "")

    lblTxt := parchesGui.Add("Text", "x20 y82 w" (W - 40) " h188 Background" colorFondoPrincipal " c" colorTextoPrincipal)
    lblTxt.SetFont("s10", "Segoe UI")

    parchesGui.Add("Text", "x20 y276 w" (W - 40) " h1 Background" colorBarra, "")

    btnPrev := parchesGui.Add("Text", "x20 y286 w120 h30 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                          Chr(0x25C0) "  Anterior")
    btnPrev.SetFont("s10 Bold", "Segoe UI Semibold")
    btnPrev.OnEvent("Click", (*) => ParchesNav(-1))
    RegistrarHover(btnPrev, () => colorBotonNormal)

    lblCount := parchesGui.Add("Text", "x140 y292 w" (W - 280) " h20 +0x201 Background" colorFondoPrincipal " c" colorTextoPrincipal " Center")
    lblCount.SetFont("s10 Bold", "Segoe UI")

    btnNext := parchesGui.Add("Text", "x" (W - 20 - 120) " y286 w120 h30 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                          "Siguiente  " Chr(0x25B6))
    btnNext.SetFont("s10 Bold", "Segoe UI Semibold")
    btnNext.OnEvent("Click", (*) => ParchesNav(1))
    RegistrarHover(btnNext, () => colorBotonNormal)

    parchesGui._lblTit := lblTit
    parchesGui._lblTxt := lblTxt
    parchesGui._lblCount := lblCount

    ParchesRender()
    parchesGui.Show("w" W " h328 Center")
    try RedondearVentana(parchesGui.Hwnd, 14)
}

ParchesRender() {
    global parchesGui, parchesPagina
    if (!IsObject(parchesGui))
        return
    pgs := ParchesPaginas()
    if (parchesPagina < 1)
        parchesPagina := 1
    if (parchesPagina > pgs.Length)
        parchesPagina := pgs.Length
    p := pgs[parchesPagina]
    try {
        parchesGui._lblTit.Value   := p.ico "  " p.tit
        parchesGui._lblTxt.Value   := p.txt
        parchesGui._lblCount.Value := parchesPagina " / " pgs.Length
    }
}

ParchesNav(dir) {
    global parchesPagina
    parchesPagina += dir
    ParchesRender()
}

CerrarParches(*) {
    global parchesGui, parchesGuiVisible
    parchesGuiVisible := false
    if (IsObject(parchesGui)) {
        try LimpiarHoverGui(parchesGui)
        try parchesGui.Destroy()
    }
    parchesGui := ""
}

AbrirPanelRGB(*) {
    global rgbGui, rgbGuiVisible, rgbBarra, rgbBotones, rgbLogo, rgbTexto
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto
    global rgbVelocidad, rgbDireccion

    if (rgbGuiVisible && IsObject(rgbGui)) {
        LimpiarHoverGui(rgbGui)
        rgbGui.Destroy()
        rgbGuiVisible := false
        global rgbPreviewCtrl
        rgbPreviewCtrl := ""
        return
    }

    rgbGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    rgbGui.BackColor := colorFondoPrincipal
    pW := 220

    barraPnl := rgbGui.Add("Text", "x0 y0 w" pW " h22 Background" colorBarra " Center", "✦ RGB — Personalizar")
    barraPnl.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI")
    barraPnl.OnEvent("Click", (*) => (LimpiarHoverGui(rgbGui), rgbGui.Destroy(), CerrarPanelRGB()))

    ; ── Elementos ────────────────────────────────────────────────────────
    rgbGui.Add("Text", "x10 y30 w200 h14 c" colorTextoPrincipal " BackgroundTrans", "Elementos activos:").SetFont("s8 Bold", "Segoe UI")
    btnRB  := rgbGui.Add("Text", "x10  y46 w96 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, "Barra: "    (rgbBarra   ? "ON" : "OFF"))
    btnRBt := rgbGui.Add("Text", "x114 y46 w96 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, "Botones: " (rgbBotones ? "ON" : "OFF"))
    btnRL  := rgbGui.Add("Text", "x10  y74 w96 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, "Logo: "    (rgbLogo    ? "ON" : "OFF"))
    btnRT  := rgbGui.Add("Text", "x114 y74 w96 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, "Textos: "  (rgbTexto   ? "ON" : "OFF"))
    for b in [btnRB, btnRBt, btnRL, btnRT]
        b.SetFont("s9 c" colorBtnTexto " Bold", "Segoe UI")
    btnRB.OnEvent("Click",  (*) => ToggleRGBElemento("barra",   btnRB))
    btnRBt.OnEvent("Click", (*) => ToggleRGBElemento("botones", btnRBt))
    btnRL.OnEvent("Click",  (*) => ToggleRGBElemento("logo",    btnRL))
    btnRT.OnEvent("Click",  (*) => ToggleRGBElemento("texto",   btnRT))
    RegistrarHover(btnRB,  () => colorBotonNormal)
    RegistrarHover(btnRBt, () => colorBotonNormal)
    RegistrarHover(btnRL,  () => colorBotonNormal)
    RegistrarHover(btnRT,  () => colorBotonNormal)

    ; separador
    rgbGui.Add("Text", "x0 y108 w" pW " h1 Background" colorBarra, "")

    ; ── Velocidad ────────────────────────────────────────────────────────
    rgbGui.Add("Text", "x10 y114 w200 h14 c" colorTextoPrincipal " BackgroundTrans", "Velocidad:").SetFont("s8 Bold", "Segoe UI")
    vels := [{lbl:"Lenta", v:1}, {lbl:"Media", v:2}, {lbl:"Rápida", v:4}, {lbl:"Máx", v:6}]
    xv := 10
    for item in vels {
        bg := (rgbVelocidad = item.v) ? colorBarra : colorBotonNormal
        btn := rgbGui.Add("Text", "x" xv " y130 w48 h24 +0x201 Background" bg " c" colorBtnTexto, item.lbl)
        btn.SetFont("s8 c" colorBtnTexto " Bold", "Segoe UI")
        velVal := item.v
        btn.OnEvent("Click", RGBSetVelocidad.Bind(velVal))
        RegistrarHover(btn, MakeColorFn(bg))
        xv += 52
    }

    ; separador
    rgbGui.Add("Text", "x0 y162 w" pW " h1 Background" colorBarra, "")

    ; ── Dirección ────────────────────────────────────────────────────────
    rgbGui.Add("Text", "x10 y168 w200 h14 c" colorTextoPrincipal " BackgroundTrans", "Dirección:").SetFont("s8 Bold", "Segoe UI")
    dirs := [{lbl:"Normal →", d:-1}, {lbl:"← Inverso", d:1}]
    xd := 10
    for item in dirs {
        bg := (rgbDireccion = item.d) ? colorBarra : colorBotonNormal
        btn := rgbGui.Add("Text", "x" xd " y184 w96 h24 +0x201 Background" bg " c" colorBtnTexto, item.lbl)
        btn.SetFont("s8 c" colorBtnTexto " Bold", "Segoe UI")
        dVal := item.d
        btn.OnEvent("Click", RGBSetDireccion.Bind(dVal))
        RegistrarHover(btn, MakeColorFn(bg))
        xd += 104
    }

    ; separador
    rgbGui.Add("Text", "x0 y216 w" pW " h1 Background" colorBarra, "")

    ; ── Saturación ────────────────────────────────────────────────────────
    rgbGui.Add("Text", "x10 y222 w200 h14 c" colorTextoPrincipal " BackgroundTrans", "Saturación:").SetFont("s8 Bold", "Segoe UI")
    sats := [{lbl:"Pastel", v:0.45}, {lbl:"Medio", v:0.70}, {lbl:"Vivo", v:0.88}, {lbl:"Puro", v:1.0}]
    xs := 10
    for item in sats {
        bg := (Round(rgbSaturacion, 2) = Round(item.v, 2)) ? colorBarra : colorBotonNormal
        btn := rgbGui.Add("Text", "x" xs " y238 w48 h24 +0x201 Background" bg " c" colorBtnTexto, item.lbl)
        btn.SetFont("s8 c" colorBtnTexto " Bold", "Segoe UI")
        satVal := item.v
        btn.OnEvent("Click", RGBSetSaturacion.Bind(satVal))
        RegistrarHover(btn, MakeColorFn(bg))
        xs += 52
    }

    ; separador
    rgbGui.Add("Text", "x0 y270 w" pW " h1 Background" colorBarra, "")

    ; ── Brillo ────────────────────────────────────────────────────────────
    rgbGui.Add("Text", "x10 y276 w200 h14 c" colorTextoPrincipal " BackgroundTrans", "Brillo:").SetFont("s8 Bold", "Segoe UI")
    brills := [{lbl:"Oscuro", v:0.55}, {lbl:"Medio", v:0.75}, {lbl:"Alto", v:0.90}, {lbl:"Max", v:1.0}]
    xb := 10
    for item in brills {
        bg := (Round(rgbBrillo, 2) = Round(item.v, 2)) ? colorBarra : colorBotonNormal
        btn := rgbGui.Add("Text", "x" xb " y292 w48 h24 +0x201 Background" bg " c" colorBtnTexto, item.lbl)
        btn.SetFont("s8 c" colorBtnTexto " Bold", "Segoe UI")
        brillVal := item.v
        btn.OnEvent("Click", RGBSetBrillo.Bind(brillVal))
        RegistrarHover(btn, MakeColorFn(bg))
        xb += 52
    }

    ; separador
    rgbGui.Add("Text", "x0 y324 w" pW " h1 Background" colorBarra, "")

    ; ── Preview del color actual (animado vía ActualizarRGB) ─────────────
    global rgbPreviewCtrl
    rgbGui.Add("Text", "x10 y330 w200 h14 c" colorTextoPrincipal " BackgroundTrans", "Color actual:").SetFont("s8 Bold", "Segoe UI")
    rgbPreviewCtrl := rgbGui.Add("Text", "x10 y346 w" (pW-20) " h18 Background" colorRGBActual, "")

    rgbGui.Show("w" pW " h372 Center")
    try RedondearVentana(rgbGui.Hwnd, 14)
    rgbGuiVisible := true
    ; Asegurar que el timer corre para animar el preview (aunque no haya elementos activos)
    SetTimer(ActualizarRGB, presetRGB)
    rgbGui.OnEvent("Close", CerrarPanelRGB)
    RegistrarAutoCierre(rgbGui, (*) => (IsObject(rgbGui) ? (LimpiarHoverGui(rgbGui), rgbGui.Destroy()) : 0, CerrarPanelRGB()))
}

CerrarPanelRGB(*) {
    global rgbGui, rgbPreviewCtrl, rgbGuiVisible, rgbActivo
    if (IsObject(rgbGui))
        LimpiarHoverGui(rgbGui)
    rgbPreviewCtrl := ""
    rgbGuiVisible := false
    if (!rgbActivo)
        SetTimer(ActualizarRGB, 0)
}

RGBSetVelocidad(val, *) {
    global rgbVelocidad
    rgbVelocidad := val
    GuardarRGBs()
    ; Diferir el refresh del panel — sino el click del boton actual sigue
    ; en proceso cuando destruimos el boton → 'control is destroyed'
    SetTimer(() => (AbrirPanelRGB(), AbrirPanelRGB()), -1)
}

RGBSetDireccion(val, *) {
    global rgbDireccion
    rgbDireccion := val
    GuardarRGBs()
    ; Diferir el refresh del panel — sino el click del boton actual sigue
    ; en proceso cuando destruimos el boton → 'control is destroyed'
    SetTimer(() => (AbrirPanelRGB(), AbrirPanelRGB()), -1)
}

RGBSetSaturacion(val, *) {
    global rgbSaturacion
    rgbSaturacion := val
    GuardarRGBs()
    ; Diferir el refresh del panel — sino el click del boton actual sigue
    ; en proceso cuando destruimos el boton → 'control is destroyed'
    SetTimer(() => (AbrirPanelRGB(), AbrirPanelRGB()), -1)
}

RGBSetBrillo(val, *) {
    global rgbBrillo
    rgbBrillo := val
    GuardarRGBs()
    ; Diferir el refresh del panel — sino el click del boton actual sigue
    ; en proceso cuando destruimos el boton → 'control is destroyed'
    SetTimer(() => (AbrirPanelRGB(), AbrirPanelRGB()), -1)
}

ToggleRGBElemento(elemento, btn) {
    global rgbBarra, rgbBotones, rgbLogo, rgbTexto, rgbActivo, temas, temaActual, colorBtnTexto

    switch elemento {
        case "barra":   rgbBarra   := !rgbBarra
        case "botones": rgbBotones := !rgbBotones
        case "logo":    rgbLogo    := !rgbLogo
        case "texto":   rgbTexto   := !rgbTexto
    }
    rgbActivo := rgbBarra || rgbBotones || rgbLogo || rgbTexto

    AplicarTema(temas[temaActual], false)

    nombres := Map("barra","Barra","botones","Botones","logo","Logo","texto","Textos")
    estados := Map("barra",rgbBarra,"botones",rgbBotones,"logo",rgbLogo,"texto",rgbTexto)
    btn.Text := nombres[elemento] ": " (estados[elemento] ? "ON" : "OFF")
    btn.SetFont("s9 c" colorBtnTexto " Bold", "Segoe UI")

    GuardarRGBs()

    if (rgbActivo)
        SetTimer(ActualizarRGB, presetRGB)
    else
        SetTimer(ActualizarRGB, 0)
}

AbrirPanelTemas(*) {
    global temaGui, temaGuiVisible, temas, temaActual, eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado, eggSolarDesbloqueado, eggBlancoDesbloqueado
    global colorBarra, colorTextoBarra, colorTextoPrincipal
    global temaBotones, temaScrollOffset, temasVisiblesGlobal
    global temaAlturaItem, temaAnchoPnl, temaAlturaVisible, temaAlturaBarra
    global temaCardData

    if (temaGuiVisible && IsObject(temaGui)) {
        OnMessage(0x20A, ManejarScrollTema, 0)
        try LimpiarHoverGui(temaGui)
        try temaGui.Destroy()
        temaGuiVisible := false
        return
    }

    temasVisibles := []
    for i, t in temas {
        if (!PuedeUsarTema(t))
            continue
        temasVisibles.Push({ idx: i, nombre: t.nombre, tema: t })
    }

    ; ── Layout: una sola ventana con barra + lista de cards ──
    alturaItem    := 42
    alturaVisible := alturaItem * 5        ; 5 cards visibles
    alturaBarra   := 26
    anchoPnl      := 240
    totalH        := alturaBarra + alturaVisible

    temasVisiblesGlobal := temasVisibles
    temaScrollOffset    := 0
    temaAlturaItem      := alturaItem
    temaAnchoPnl        := anchoPnl
    temaAlturaVisible   := alturaVisible
    temaAlturaBarra     := alturaBarra
    temaCardData        := Map()

    ; Una sola ventana — barra + cards juntos
    temaGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    temaGui.BackColor := colorBarra

    temaBotones := []
    ; Añadimos las cards primero para que la barra de título quede ENCIMA en z-order
    for i, entry in temasVisibles {
        yPos := alturaBarra + (i - 1) * alturaItem
        yShow := (yPos >= alturaBarra + alturaVisible) ? -alturaItem - 10 : yPos
        esActivo := (entry.idx = temaActual)

        btn := temaGui.Add("Text",
            "x0 y" yShow " w" anchoPnl " h" alturaItem
            " +0x201 Background" entry.tema.fondo, "")
        local capturedEntry := entry
        btn.OnEvent("Click", MakeTemaClosure(capturedEntry))
        InstalarSubclassTemaCard(btn, entry, esActivo)
        temaBotones.Push(btn)
    }

    ; ── Barra superior (encima en z-order porque se añade DESPUÉS de las cards) ──
    global temaBarraCtrl
    tituloBar := Chr(0x1F3A8) "  Temas  " Chr(0x2022) "  " temasVisibles.Length
    temaBarraCtrl := temaGui.Add("Text", "x0 y0 w" anchoPnl " h" alturaBarra " +0x201 Background" colorBarra " c" colorTextoBarra " Center", tituloBar)
    temaBarraCtrl.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    ; Click en barra = arrastrar (movible). Para cerrar: vuelve a pulsar el botón 🎨
    temaBarraCtrl.OnEvent("Click", ArrastrarPanelTemas)

    ; ── Posicionar (centrado o última posición guardada) ──
    global miGui, btnTema, configPath
    _savedTemaX := IniRead(configPath, "Pos", "TemaX", "")
    _savedTemaY := IniRead(configPath, "Pos", "TemaY", "")
    if (_savedTemaX != "" && _savedTemaY != "") {
        panelX := Integer(_savedTemaX)
        panelY := Integer(_savedTemaY)
    } else {
        panelX := Round((A_ScreenWidth  - anchoPnl) / 2)
        panelY := Round((A_ScreenHeight - totalH) / 2)
    }

    temaGui.Show("x" panelX " y" panelY " w" anchoPnl " h" totalH " NoActivate")
    RedondearVentana(temaGui.Hwnd, 14)

    temaGuiVisible := true
    ActualizarColoresPanelTemas()
    temaGui.OnEvent("Close", (*) => (CerrarPanelTemas(), OnMessage(0x20A, ManejarScrollTema, 0)))
    OnMessage(0x20A, ManejarScrollTema)
    RegistrarAutoCierre(temaGui, (*) => (CerrarPanelTemas(), OnMessage(0x20A, ManejarScrollTema, 0)))
}

ArrastrarPanelTemas(*) {
    PostMessage(0xA1, 2,,, "A")
}

CerrarPanelTemas(*) {
    global temaGui, temaGuiVisible, configPath, temaArcoirisData
    OnMessage(0x20A, ManejarScrollTema, 0)
    temaArcoirisData := Map()
    if (IsObject(temaGui)) {
        try {
            temaGui.GetPos(&tx, &ty)
            IniWrite(tx, configPath, "Pos", "TemaX")
            IniWrite(ty, configPath, "Pos", "TemaY")
        }
        try LimpiarHoverGui(temaGui)
        try temaGui.Destroy()
    }
    temaGuiVisible := false
}

MakeTemaClosure(entry) {
    return (*) => ElegirTema(entry)
}

ElegirTema(entry) {
    global temaActual, temaAnteriorNombre, temaBotones, temasVisiblesGlobal
    global temaGui, colorBarra, colorTextoBarra, temaEnTransicion, temas, eggGojoDesbloqueado, configPath
    ; Ignorar clicks mientras hay una transición en curso: antes el click cambiaba
    ; temaActual + guardaba pero la transición se descartaba → estado incoherente.
    if (temaEnTransicion)
        return

    ; Detectar secuencia Azul → Rojo para desbloquear Gojo
    if (!eggGojoDesbloqueado && temaAnteriorNombre = "Azul" && entry.tema.nombre = "Rojo") {
        DesbloquearEggGojoSecuencia()
    }

    temaAnteriorNombre := entry.tema.nombre  ; guardar nombre del tema anterior ANTES de cambiar
    temaActual := entry.idx
    TransicionTema(entry.tema)
    GuardarTema()
    ToolTip("Tema: " entry.nombre)
    SetTimer(() => ToolTip(), -900)
    ; Actualizar el panel 160ms después (asíncrono, no bloquea el hilo)
    SetTimer(() => ActualizarPanelTemas(), -160)
}

ActualizarPanelTemas() {
    global temaGui, temaGuiVisible, temaBarraCtrl
    global colorBarra, colorTextoBarra
    global temaBotones, temasVisiblesGlobal, temaActual, temaCardData
    if (!temaGuiVisible || !IsObject(temaGui))
        return
    temaGui.BackColor := colorBarra
    if (IsObject(temaBarraCtrl)) {
        temaBarraCtrl.Opt("Background" colorBarra " c" colorTextoBarra)
        DllCall("InvalidateRect", "Ptr", temaBarraCtrl.Hwnd, "Ptr", 0, "Int", 1)
    }
    ; Marcar la card activa
    for i, btn in temaBotones {
        e := temasVisiblesGlobal[i]
        if (temaCardData.Has(btn.Hwnd)) {
            temaCardData[btn.Hwnd].esActivo := (e.idx = temaActual)
            DllCall("InvalidateRect", "Ptr", btn.Hwnd, "Ptr", 0, "Int", 1)
        }
    }
}

ActualizarColoresPanelTemas() {
    global temaGui, temaBarraCtrl
    global temasVisiblesGlobal, temaScrollOffset

    if (!temasVisiblesGlobal.Length || !IsObject(temaGui))
        return
    primerIdx := Min(temaScrollOffset + 1, temasVisiblesGlobal.Length)
    t := temasVisiblesGlobal[primerIdx].tema

    temaGui.BackColor := t.barra
    if (IsObject(temaBarraCtrl)) {
        temaBarraCtrl.Opt("Background" t.barra " c" t.textoBarra)
        DllCall("InvalidateRect", "Ptr", temaBarraCtrl.Hwnd, "Ptr", 0, "Int", 1)
    }
    DllCall("RedrawWindow", "Ptr", temaGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x85)
}

ManejarScrollTema(wParam, lParam, msg, hwnd) {
    global temaGui, temaGuiVisible, temaBotones, temasVisiblesGlobal
    global temaScrollOffset, temaAlturaItem, temaAlturaVisible, temaAnchoPnl, temaAlturaBarra

    if (!temaGuiVisible || !IsObject(temaGui))
        return
    temaGui.GetPos(&gx, &gy, &gw, &gh)
    MouseGetPos(&mx, &my)
    if (mx < gx || mx > gx + gw || my < gy || my > gy + gh)
        return

    delta := (wParam >> 16) & 0xFFFF
    if (delta >= 0x8000)
        delta := -(0x10000 - delta)
    paso := (delta > 0) ? -1 : 1

    maxOffset := temasVisiblesGlobal.Length - 2
    if (maxOffset < 0)
        maxOffset := 0
    temaScrollOffset := Max(0, Min(temaScrollOffset + paso, maxOffset))

    DllCall("LockWindowUpdate", "Ptr", temaGui.Hwnd)
    for i, btn in temaBotones {
        yPos := temaAlturaBarra + (i - 1 - temaScrollOffset) * temaAlturaItem
        ; Si está fuera del área visible (por encima de la barra o por debajo de la lista) → off-screen
        if (yPos < temaAlturaBarra - temaAlturaItem || yPos >= temaAlturaBarra + temaAlturaVisible)
            DllCall("MoveWindow", "Ptr", btn.Hwnd, "Int", 0, "Int", -200, "Int", temaAnchoPnl, "Int", temaAlturaItem, "Int", 0)
        else
            DllCall("MoveWindow", "Ptr", btn.Hwnd, "Int", 0, "Int", yPos, "Int", temaAnchoPnl, "Int", temaAlturaItem, "Int", 0)
    }
    DllCall("LockWindowUpdate", "Ptr", 0)
    ActualizarColoresPanelTemas()
}
CambiarTema(*) {
    AbrirPanelTemas()
}

DesbloquearCosmos() {
    global temas, temaActual, eggDesbloqueado, configPath, VERSION_ACTUAL
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto

    eggDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("cosmos")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "Egg", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "03000F"
    popup.SetFont("s13 cFFD700 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w320 h28 BackgroundFF1493 Center cFFD700", "  ✦ TEMA SECRETO DESBLOQUEADO ✦  ")
    popup.SetFont("s11 cE2C9FF", "Segoe UI")
    popup.Add("Text", "x10 y38 w300 h20 Center cBF00FF", "✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦")
    popup.Add("Text", "x10 y62 w300 h22 Center cE2C9FF", "Has desbloqueado  ✦ COSMOS ✦")
    popup.Add("Text", "x10 y86 w300 h20 Center c00E5FF", "El universo ahora es tuyo.")
    popup.Add("Text", "x10 y110 w300 h20 Center cBF00FF", "✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦ ✧ ✦")
    popup.Show("w320 h138 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -4000)
}

ManejarClickLuces(wParam, lParam, msg, hwnd) {
    global luzActiva, luzAccion, luzApagado
    if (hwnd = luzActiva.Hwnd)
        ClickLuzSecuencia(1)
    else if (hwnd = luzAccion.Hwnd)
        ClickLuzSecuencia(2)
    else if (hwnd = luzApagado.Hwnd)
        ClickLuzSecuencia(3)
}

; Trigger LIGHT: (3 clics en orden)
ClickLuzSecuencia(n) {
    global luzSeq, luzSeqUltimo, eggSolarDesbloqueado
    if (eggSolarDesbloqueado)
        return
    if (A_TickCount - luzSeqUltimo > 4000)
        luzSeq := []
    luzSeqUltimo := A_TickCount
    expected := [1, 2, 3]
    nextPos := luzSeq.Length + 1
    if (nextPos <= 3 && n = expected[nextPos]) {
        luzSeq.Push(n)
        if (luzSeq.Length >= 3) {
            luzSeq := []
            DesbloquearSolar()
        }
    } else {
        luzSeq := (n = 1) ? [1] : []
    }
}

; Trigger NIKA: clic en la barra del historial ×8 rápido mientras historial está abierto
ClickBarraHistorialNika(*) {
    global nikaHistClicks, nikaHistUltimo, eggBlancoDesbloqueado, historialVisible
    if (eggBlancoDesbloqueado || !historialVisible)
        return
    if (A_TickCount - nikaHistUltimo < 2500)
        nikaHistClicks += 1
    else
        nikaHistClicks := 1
    nikaHistUltimo := A_TickCount
    if (nikaHistClicks >= 5) {
        nikaHistClicks := 0
        DesbloquearBlanco()
    }
}

DesbloquearSolar() {
    global temas, temaActual, eggSolarDesbloqueado, configPath

    eggSolarDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("solar")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggSolar", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "FFF8EC"
    popup.SetFont("s13 c8B3A00 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w320 h28 BackgroundFF6B00 Center cFFFFFF", "  🔥 TEMA SECRETO DESBLOQUEADO 🔥  ")
    popup.SetFont("s11 c8B3A00", "Segoe UI")
    popup.Add("Text", "x10 y38 w300 h20 Center cFFD700", "✦ 🔥 ✦ 🔥 ✦ 🔥 ✦ 🔥 ✦ 🔥 ✦")
    popup.Add("Text", "x10 y62 w300 h22 Center cFF6B00", "Has desbloqueado  🔥 F E N I X 🔥")
    popup.Add("Text", "x10 y86 w300 h20 Center c00C9B7", "Renaces de las cenizas, eterno.")
    popup.Add("Text", "x10 y110 w300 h20 Center cFFD700", "✦ 🔥 ✦ 🔥 ✦ 🔥 ✦ 🔥 ✦ 🔥 ✦")
    popup.Show("w320 h138 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -4000)
}

DesbloquearBlanco() {
    global temas, temaActual, eggBlancoDesbloqueado, configPath

    eggBlancoDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("blanco")
    TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggBlanco", "Desbloqueado")
    GuardarEggsBackup()

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "FFFFFF"
    popup.SetFont("s13 cE53935 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w320 h28 BackgroundE53935 Center cFFFFFF", "  ✦ TEMA SECRETO DESBLOQUEADO ✦  ")
    popup.SetFont("s11 cC62828", "Segoe UI")
    popup.Add("Text", "x10 y38 w300 h20 Center cE53935", "✦ · · · · · · · · · · · · · · · ✦")
    popup.Add("Text", "x10 y62 w300 h22 Center cC62828", "Has desbloqueado  ✦ N I K A ✦")
    popup.Add("Text", "x10 y86 w300 h20 Center cE53935", "La pureza absoluta es tuya.")
    popup.Add("Text", "x10 y110 w300 h20 Center cE53935", "✦ · · · · · · · · · · · · · · · ✦")
    popup.Show("w320 h138 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -4000)
}

DesbloquearGamer() {
    global temas, temaActual, eggGamerDesbloqueado, configPath, logros

    eggGamerDesbloqueado := true
    ; Cambiar al primer tema del pack Gamer (Brawl)
    temaActual := BuscarTemaPorUnlock("gamer")
    if (temaActual > 0)
        TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggGamer", "Desbloqueado")
    GuardarEggsBackup()

    ; Marcar el logro como completado (si existe en la lista)
    for l in logros {
        if (l.id = "gamerpack" && !l.desbloqueado) {
            l.desbloqueado := true
            GuardarLogro("gamerpack")
            break
        }
    }

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "0D0B1F"
    popup.SetFont("s13 c00FFFF Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w340 h30 Background130E2E Center cFFFF00", "  ★ PACK SECRETO DESBLOQUEADO ★  ")
    popup.SetFont("s11 cFFFFFF", "Segoe UI")
    popup.Add("Text", "x10 y40 w320 h20 Center cFF00AA", "★ ─ ◆ ─ ☀ ─ ✦ ─ ♪ ─ ⌖ ─ ⛏")
    popup.Add("Text", "x10 y64 w320 h22 Center c00FFFF", "Has desbloqueado el PACK GAMER")
    popup.Add("Text", "x10 y90 w320 h20 Center cFFFF00", "7 temas nuevos en el selector")
    popup.Add("Text", "x10 y112 w320 h20 Center cFF00AA", "★ ─ ◆ ─ ☀ ─ ✦ ─ ♪ ─ ⌖ ─ ⛏")
    popup.Show("w340 h140 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -4500)
}

; Trigger GAMER: click ×10 sobre el contador "Secuencias" en 5 segundos
ClickSecuenciasGamer(*) {
    global eggGamerClicks, eggGamerUltimo, eggGamerDesbloqueado, secuenciasLabel, colorTextoPrincipal
    if (eggGamerDesbloqueado)
        return
    if (A_TickCount - eggGamerUltimo < 5000)
        eggGamerClicks += 1
    else
        eggGamerClicks := 1
    eggGamerUltimo := A_TickCount
    ; Flash visual para confirmar que el click se registra (sin spoilear cuántos llevamos)
    c := colorTextoPrincipal
    secuenciasLabel.Opt("cFFE100")
    DllCall("InvalidateRect", "Ptr", secuenciasLabel.Hwnd, "Ptr", 0, "Int", 1)
    SetTimer(() => (secuenciasLabel.Opt("c" c), DllCall("InvalidateRect", "Ptr", secuenciasLabel.Hwnd, "Ptr", 0, "Int", 1)), -120)
    if (eggGamerClicks >= 10) {
        eggGamerClicks := 0
        DesbloquearGamer()
    }
}

DesbloquearLeyendas() {
    global temas, temaActual, eggLeyendasDesbloqueado, configPath, logros

    eggLeyendasDesbloqueado := true
    temaActual := BuscarTemaPorUnlock("leyendas")   ; cambia al primero (Sky)
    if (temaActual > 0)
        TransicionTema(temas[temaActual])
    GuardarTema()
    IniWrite(1, configPath, "EggLeyendas", "Desbloqueado")
    GuardarEggsBackup()

    ; Marcar el logro
    for l in logros {
        if (l.id = "leyendaspack" && !l.desbloqueado) {
            l.desbloqueado := true
            GuardarLogro("leyendaspack")
            break
        }
    }

    popup := Gui("+AlwaysOnTop -Caption +ToolWindow")
    popup.BackColor := "0A0A18"
    popup.SetFont("s13 cFFD700 Bold", "Segoe UI")
    popup.Add("Text", "x0 y0 w340 h30 Background141430 Center cFFD700", "  ✦ PACK SECRETO DESBLOQUEADO ✦  ")
    popup.SetFont("s11 cFFFFFF", "Segoe UI")
    popup.Add("Text", "x10 y40 w320 h20 Center c00E5FF", "☆ ─ ▣ ─ ◓ ─ ➰ ─ ⚓")
    popup.Add("Text", "x10 y64 w320 h22 Center cFFD700", "Has desbloqueado el PACK LEYENDAS")
    popup.Add("Text", "x10 y90 w320 h20 Center c00E5FF", "5 temas nuevos en el selector")
    popup.Add("Text", "x10 y112 w320 h20 Center cFF69B4", "☆ ─ ▣ ─ ◓ ─ ➰ ─ ⚓")
    popup.Show("w340 h140 Center")
    RedondearVentana(popup.Hwnd, 14)
    SetTimer(() => popup.Destroy(), -4500)
}

; Trigger LEYENDAS: click ×8 sobre el medidor ⚡ de rendimiento en 4 segundos.
; CiclarPreset sigue funcionando (cada click cicla el preset); como 8 % 4 = 0,
; acabas en el mismo preset donde empezaste. Original y no muy difícil.
ClickPresetLeyendas(*) {
    global eggLeyendasClicks, eggLeyendasUltimo, eggLeyendasDesbloqueado
    CiclarPreset()   ; comportamiento normal: ciclar Eco/Ligero/Normal/Ultra
    if (eggLeyendasDesbloqueado)
        return
    if (A_TickCount - eggLeyendasUltimo < 4000)
        eggLeyendasClicks += 1
    else
        eggLeyendasClicks := 1
    eggLeyendasUltimo := A_TickCount
    if (eggLeyendasClicks >= 8) {
        eggLeyendasClicks := 0
        DesbloquearLeyendas()
    }
}

; ── Arcoíris en botones de temas secretos ──
; Instala un subclass WM_PAINT en el botón para dibujar cada token del nombre
; con un color distinto del arcoíris usando GDI puro.
InstallarArcoirisEnBoton(btn, entry, marca) {
    global temaArcoirisData, temaArcoirisCbs
    temaArcoirisData[btn.Hwnd] := { tema: entry.tema, nombre: entry.nombre, marca: marca }
    cb := CallbackCreate(ArcoirisSubclassProc, "F", 6)
    temaArcoirisCbs.Push(cb)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", btn.Hwnd, "Ptr", cb, "Ptr", 3, "Ptr", 0)
}

ArcoirisSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND)
        return 1
    if (uMsg = WM_PAINT) {
        global temaArcoirisData
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            rc := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", hWnd, "Ptr", rc)
            w := NumGet(rc, 8, "Int")
            h := NumGet(rc, 12, "Int")

            data := temaArcoirisData.Get(hWnd, "")
            if (IsObject(data)) {
                ; Fondo del tema
                fh := Integer("0x" data.tema.fondo)
                bgr := ((fh & 0xFF) << 16) | (fh & 0xFF00) | ((fh >> 16) & 0xFF)
                brushBg := DllCall("CreateSolidBrush", "UInt", bgr, "Ptr")
                DllCall("FillRect", "Ptr", hdc, "Ptr", rc, "Ptr", brushBg)
                DllCall("DeleteObject", "Ptr", brushBg)

                ; Fuente
                hFont := DllCall("CreateFont", "Int", 14, "Int", 0, "Int", 0, "Int", 0,
                    "Int", 700, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 1,
                    "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "Str", "Segoe UI", "Ptr")
                oldFont := DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr")
                DllCall("SetBkMode", "Ptr", hdc, "Int", 1)  ; TRANSPARENT

                ; Métricas para centrado vertical
                tm := Buffer(60, 0)
                DllCall("GetTextMetrics", "Ptr", hdc, "Ptr", tm)
                fontH := NumGet(tm, 0, "Int")
                yTxt := (h - fontH) // 2

                ; Paleta arcoíris (BGR para GDI)
                palette := [0x4040FF, 0x0088FF, 0x00DDFF, 0x44DD44, 0xDDDD00, 0x0088FF, 0xFF44DD, 0xFF4488, 0x4488FF]

                ; Medir ancho total de tokens para centrar horizontalmente
                tokens := StrSplit(data.nombre, " ")
                totalW := 0
                gap := 3
                for j, tok in tokens {
                    sz := Buffer(8, 0)
                    DllCall("GetTextExtentPoint32", "Ptr", hdc, "Str", tok, "Int", StrLen(tok), "Ptr", sz)
                    totalW += NumGet(sz, 0, "Int") + gap
                }
                totalW -= gap
                xCur := Max(4, (w - totalW) // 2)

                ; Dibujar cada token con su color
                for j, tok in tokens {
                    rgb := palette[Mod(j - 1, palette.Length) + 1]
                    DllCall("SetTextColor", "Ptr", hdc, "UInt", rgb)
                    sz := Buffer(8, 0)
                    DllCall("GetTextExtentPoint32", "Ptr", hdc, "Str", tok, "Int", StrLen(tok), "Ptr", sz)
                    tokW := NumGet(sz, 0, "Int")
                    DllCall("TextOut", "Ptr", hdc, "Int", xCur, "Int", yTxt, "Str", tok, "Int", StrLen(tok))
                    xCur += tokW + gap
                }

                ; Checkmark al extremo derecho si está seleccionado
                if (data.marca != "") {
                    DllCall("SetTextColor", "Ptr", hdc, "UInt", 0x00FF88)
                    DllCall("TextOut", "Ptr", hdc, "Int", w - 16, "Int", yTxt, "Str", "✓", "Int", 1)
                }

                DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
                DllCall("DeleteObject", "Ptr", hFont)
            }
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

; ===== TARJETAS DE TEMA (GDI+) — preview rico por cada tema =====
global temaCardData := Map()       ; hwnd -> { tema, nombre, esActivo, esSecreto }
; UN solo callback compartido por todas las cards y todas las aperturas del panel.
; Antes se creaba un CallbackCreate por card (~65) en CADA apertura sin liberarlos
; nunca → fuga acumulativa que terminaba crasheando el macro al cambiar mucho de tema.
global temaCardCb := 0

InstalarSubclassTemaCard(btn, entry, esActivo) {
    global temaCardData, temaCardCb
    temaCardData[btn.Hwnd] := {
        tema: entry.tema,
        nombre: entry.nombre,
        esActivo: esActivo,
        hovered: false
    }
    if (!temaCardCb)
        temaCardCb := CallbackCreate(TemaCardSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", btn.Hwnd, "Ptr", temaCardCb, "Ptr", 14, "Ptr", 0)
}

TemaCardSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    static WM_MOUSEMOVE := 0x0200, WM_MOUSELEAVE := 0x02A3
    if (uMsg = WM_ERASEBKGND)
        return 1
    if (uMsg = WM_MOUSEMOVE) {
        global temaCardData
        data := temaCardData.Get(hWnd, "")
        if (IsObject(data) && !data.hovered) {
            data.hovered := true
            DllCall("InvalidateRect", "Ptr", hWnd, "Ptr", 0, "Int", 1)
            tme := Buffer(24, 0)
            NumPut("UInt", 24, tme, 0)
            NumPut("UInt", 0x02, tme, 4)
            NumPut("Ptr", hWnd, tme, 8)
            DllCall("TrackMouseEvent", "Ptr", tme)
        }
    }
    if (uMsg = WM_MOUSELEAVE) {
        global temaCardData
        data := temaCardData.Get(hWnd, "")
        if (IsObject(data) && data.hovered) {
            data.hovered := false
            DllCall("InvalidateRect", "Ptr", hWnd, "Ptr", 0, "Int", 1)
        }
    }
    if (uMsg = WM_PAINT) {
        global temaCardData
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            rc := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", hWnd, "Ptr", rc)
            w := NumGet(rc, 8, "Int")
            h := NumGet(rc, 12, "Int")
            data := temaCardData.Get(hWnd, "")
            if (IsObject(data))
                PintarTemaCard(hdc, w, h, data)
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

PintarTemaCard(hdc, w, h, data) {
    tema := data.tema
    fondoHex := tema.fondo
    if (data.hovered)
        fondoHex := AclararHex(fondoHex, 0.12)

    memDC  := DllCall("CreateCompatibleDC",     "Ptr", hdc, "Ptr")
    hbm    := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr")
    oldBmp := DllCall("SelectObject",           "Ptr", memDC, "Ptr", hbm, "Ptr")

    ; ── 1. Fondo del tema ──
    bgr := HexToBGR(fondoHex)
    brushBg := DllCall("CreateSolidBrush", "UInt", bgr, "Ptr")
    rc := Buffer(16, 0)
    NumPut("Int", 0, rc, 0)
    NumPut("Int", 0, rc, 4)
    NumPut("Int", w, rc, 8)
    NumPut("Int", h, rc, 12)
    DllCall("FillRect", "Ptr", memDC, "Ptr", rc, "Ptr", brushBg)
    DllCall("DeleteObject", "Ptr", brushBg)

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC",        "Ptr", memDC, "Ptr*", &g)
    if (!g) {
        DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
        DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
        DllCall("DeleteObject", "Ptr", hbm)
        DllCall("DeleteDC", "Ptr", memDC)
        return
    }
    DllCall("gdiplus\GdipSetSmoothingMode",     "Ptr", g, "Int", 4)
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)

    ; ── 2. Stripe de acento a la izquierda (más gruesa si está activo) ──
    rA := Integer("0x" SubStr(tema.logo, 1, 2))
    gA := Integer("0x" SubStr(tema.logo, 3, 2))
    bA := Integer("0x" SubStr(tema.logo, 5, 2))
    argbAcc := 0xFF000000 | (rA << 16) | (gA << 8) | bA
    brushAcc := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbAcc, "Ptr*", &brushAcc)
    stripeW := data.esActivo ? 6.0 : 3.0
    DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", brushAcc, "Float", 0.0, "Float", 0.0, "Float", stripeW, "Float", h * 1.0)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushAcc)

    ; ── 3. Nombre del tema ──
    family := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI", "Ptr", 0, "Ptr*", &family)
    if (family) {
        font := 0
        DllCall("gdiplus\GdipCreateFont", "Ptr", family, "Float", 11.0, "Int", 1, "Int", 0, "Ptr*", &font)
        if (font) {
            fmt := 0
            DllCall("gdiplus\GdipCreateStringFormat",       "Int", 0, "Int", 0, "Ptr*", &fmt)
            DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", fmt, "Int", 0)  ; izquierda
            DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", fmt, "Int", 1)  ; centrado vertical

            xText := stripeW + 10.0
            wText := w - xText - 75.0

            rT := Integer("0x" SubStr(tema.texto, 1, 2))
            gT := Integer("0x" SubStr(tema.texto, 3, 2))
            bT := Integer("0x" SubStr(tema.texto, 5, 2))
            argbT := 0xFF000000 | (rT << 16) | (gT << 8) | bT
            brushT := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbT, "Ptr*", &brushT)
            txtRc := Buffer(16, 0)
            NumPut("Float", xText, txtRc, 0)
            NumPut("Float", 0.0,   txtRc, 4)
            NumPut("Float", wText, txtRc, 8)
            NumPut("Float", h * 1.0, txtRc, 12)
            DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", data.nombre, "Int", StrLen(data.nombre), "Ptr", font, "Ptr", txtRc, "Ptr", fmt, "Ptr", brushT)
            DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushT)

            DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmt)
            DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
        }
        DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", family)
    }

    ; ── 4. Swatches (barra, boton, hover) ──
    swatches := [tema.barra, tema.boton, tema.hover]
    swSize := 11.0
    swGap := 4.0
    totalSw := swSize * swatches.Length + swGap * (swatches.Length - 1)
    swStartX := w - totalSw - 24.0
    swY := (h - swSize) / 2.0
    for i, swHex in swatches {
        rS := Integer("0x" SubStr(swHex, 1, 2))
        gS := Integer("0x" SubStr(swHex, 3, 2))
        bS := Integer("0x" SubStr(swHex, 5, 2))
        argbS := 0xFF000000 | (rS << 16) | (gS << 8) | bS
        brushS := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbS, "Ptr*", &brushS)
        swX := swStartX + (i - 1) * (swSize + swGap)
        DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brushS, "Float", swX, "Float", swY, "Float", swSize, "Float", swSize)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushS)
    }

    ; ── 5. Check si está activo ──
    if (data.esActivo) {
        familyChk := 0
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI Symbol", "Ptr", 0, "Ptr*", &familyChk)
        if (!familyChk)
            DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI", "Ptr", 0, "Ptr*", &familyChk)
        if (familyChk) {
            fontChk := 0
            DllCall("gdiplus\GdipCreateFont", "Ptr", familyChk, "Float", 12.0, "Int", 1, "Int", 0, "Ptr*", &fontChk)
            if (fontChk) {
                fmtChk := 0
                DllCall("gdiplus\GdipCreateStringFormat",       "Int", 0, "Int", 0, "Ptr*", &fmtChk)
                DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", fmtChk, "Int", 1)
                DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", fmtChk, "Int", 1)
                brushChk := 0
                DllCall("gdiplus\GdipCreateSolidFill", "UInt", 0xFF00DD66, "Ptr*", &brushChk)
                rChk := Buffer(16, 0)
                NumPut("Float", w - 22.0, rChk, 0)
                NumPut("Float", 0.0,      rChk, 4)
                NumPut("Float", 20.0,     rChk, 8)
                NumPut("Float", h * 1.0,  rChk, 12)
                chkTxt := Chr(0x2713)
                DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", chkTxt, "Int", 1, "Ptr", fontChk, "Ptr", rChk, "Ptr", fmtChk, "Ptr", brushChk)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushChk)
                DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmtChk)
                DllCall("gdiplus\GdipDeleteFont", "Ptr", fontChk)
            }
            DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", familyChk)
        }
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)

    DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC",     "Ptr", memDC)
}

; ===== TRANSICIÓN DE TEMA — GDI crossfade directo, sin flickering =====
global temaTransOrigen := ""
global temaOverlayM := "", temaOverlayH := ""

; ===== TRANSICION DE TEMA SUAVE =====
; Patron: WM_SETREDRAW disable → set props → WM_SETREDRAW enable → 1 RedrawWindow sync.
; - Lerp basado en tiempo real (A_TickCount) — si frames se pierden, no se nota.
; - Duracion TRANSICION_MS con easing cubic in/out, a ~60fps.
; - Todos los colores interpolan en paralelo, todos los controles repintan en el mismo frame.
; - Cubre TODO: ventana principal, historial, mini mode, tutorial, ciclo y acentos.

global temaTransInicio := 0
global TRANSICION_MS   := 1200    ; duracion total transicion (ms)

TransicionTema(tema, guardar := true) {
    global temaTransInicio, temaTransTema, temaTransGuardar, temaEnTransicion
    global temaTransOrigen, modoMini
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBotonHover, colorLogoMacro, colorBtnTexto
    global colorFondoHistorial, colorCooldown, colorAFK
    global colorLuzActiva, colorLuzAccion, colorLuzApagado
    global colorHist1, colorHist2, colorHist3

    if (temaEnTransicion)
        return

    ; Si estamos en mini mode, aplicar tema al mini sin tocar el macro principal
    if (modoMini) {
        AplicarTemaAlMini(tema)
        if (guardar)
            GuardarTema()
        return
    }

    temaTransOrigen := {
        fondo:      colorFondoPrincipal,
        texto:      colorTextoPrincipal,
        barra:      colorBarra,
        textoBarra: colorTextoBarra,
        boton:      colorBotonNormal,
        hover:      colorBotonHover,
        logo:       colorLogoMacro,
        btnTexto:   colorBtnTexto,
        historial:  colorFondoHistorial,
        cooldown:   colorCooldown,
        afk:        colorAFK,
        luzOn:      colorLuzActiva,
        luzAccion:  colorLuzAccion,
        luzOff:     colorLuzApagado,
        histColor1: colorHist1,
        histColor2: colorHist2,
        histColor3: colorHist3
    }

    temaEnTransicion := true
    temaTransInicio  := A_TickCount
    temaTransTema    := tema
    temaTransGuardar := guardar

    ; ~30fps: para un fundido de color de 1.2s es visualmente idéntico a 60fps,
    ; pero hace la MITAD de repintados síncronos de toda la ventana (RedrawWindow
    ; con UPDATENOW es lo más pesado del macro y bajo carga puede atascar a DWM).
    SetTimer(TransicionPaso, 33)
}

TransicionPaso() {
    global temaTransInicio, temaTransTema, temaTransGuardar, temaEnTransicion
    global temaTransOrigen, miGui, historialGui, TRANSICION_MS
    global barra, barraHistorial, colorBarraOverride
    global tituloMacro, timerLabel, cooldownText, afkText, secuenciasLabel, destruccionesLabel, contadorLabel, logoMacro
    global presetLabel, fpsLabel
    global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose
    global btnUpdate, btnOverlay, btnStatsBtn, btnWebhook, btnLogros, btnPerfil
    global colorLogoEnTransicion, colorFondoEnTransicion, colorTextoBarra
    global luzActiva, luzAccion, luzApagado, historialBox, separadorHistorial
    global glowTitulo, glowTituloL, glowTituloR, sepEstado, sepEstadoL, sepEstadoR, sepAccion, sepAccionL, sepAccionR, activo
    global btnTutorial, cicloLabel
    global hoverAccent, hoverAccentTop, hoverAccentBot, hoverAccentRight
    global hoverAccentHist, hoverAccentBotHist, hoverAccentRightHist
    global modoMini, miniGui, btnMiniIniciar, btnMiniParar, btnMiniCerrar, logoMacroMini
    global historialVisible

    static WM_SETREDRAW := 0x000B
    static RDW_FLAGS    := 0x0001 | 0x0004 | 0x0080 | 0x0100   ; INVALIDATE | ERASE | ALLCHILDREN | UPDATENOW

    ; t basado en tiempo real (asi frames perdidos no rompen la animacion)
    elapsed := A_TickCount - temaTransInicio
    t  := Min(elapsed / TRANSICION_MS, 1.0)
    ; Easing cubic in/out — empieza/termina suave, acelera en medio
    t2 := t < 0.5 ? 4*t*t*t : 1 - (-2*t+2)**3/2

    TestTrace("TP> t=" Round(t, 2))
    ; Blindaje anti-crash: si CUALQUIER paso falla (p. ej. un control destruido a
    ; mitad de transición), el catch del final cierra la transición limpiamente en
    ; vez de dejar el timer vivo lanzando el mismo error 60 veces por segundo.
    try {

    ; LERP de TODOS los colores
    cFondo      := LerpHex(temaTransOrigen.fondo,      temaTransTema.fondo,      t2)
    cTexto      := LerpHex(temaTransOrigen.texto,      temaTransTema.texto,      t2)
    cBarra      := LerpHex(temaTransOrigen.barra,      temaTransTema.barra,      t2)
    cTextoBarra := LerpHex(temaTransOrigen.textoBarra, temaTransTema.textoBarra, t2)
    cBoton      := LerpHex(temaTransOrigen.boton,      temaTransTema.boton,      t2)
    cHover      := LerpHex(temaTransOrigen.hover,      temaTransTema.hover,      t2)
    cBtnTexto   := LerpHex(temaTransOrigen.btnTexto,   temaTransTema.btnTexto,   t2)
    cFondoHist  := LerpHex(temaTransOrigen.historial,  temaTransTema.historial,  t2)
    cCooldown   := LerpHex(temaTransOrigen.cooldown,   temaTransTema.cooldown,   t2)
    cAFK        := LerpHex(temaTransOrigen.afk,        temaTransTema.afk,        t2)
    cLuzOn      := LerpHex(temaTransOrigen.luzOn,      temaTransTema.luzOn,      t2)
    cLuzOff     := LerpHex(temaTransOrigen.luzOff,     temaTransTema.luzOff,     t2)
    colorLogoEnTransicion  := LerpHex(temaTransOrigen.logo, temaTransTema.logo, t2)
    colorFondoEnTransicion := cFondo
    colorBarraOverride     := cBarra
    colorTextoBarra        := cTextoBarra  ; para que el titulo de la barra lerpee

    ; ── PASO 1: deshabilitar repaints en ambas ventanas ──
    ; Usamos DllCall directo (no SendMessage de AHK) porque AHK resuelve el
    ; WinTitle cada vez y con redraws deshabilitados puede fallar el lookup.
    ; Si el historial está OCULTO no hace falta repintarlo por frame (los Opt()
    ; de colores se aplican igual y el AplicarTema final lo deja perfecto).
    DllCall("SendMessageW", "Ptr", miGui.Hwnd,        "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)
    if (historialVisible)
        DllCall("SendMessageW", "Ptr", historialGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)

    ; ── PASO 2: aplicar TODOS los cambios via Opt() / BackColor (sin pintar) ──
    try miGui.BackColor       := cFondo
    try historialGui.BackColor := cFondo

    ; Fondo del RichEdit del historial (EM_SETBKGNDCOLOR)
    if (IsObject(historialBox)) {
        DllCall("SendMessageW", "Ptr", historialBox.Hwnd, "UInt", 0x0443, "Ptr", 0, "Ptr", HexToBGR(cFondoHist))
    }

    ; Botones — fondo + texto (AplicarRegion después de Opt para mantener curvas)
    for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnStatsBtn, btnWebhook, btnLogros, btnMini, btnPersonalizar] {
        if (IsObject(btn)) {
            btn.Opt("Background" cBoton " c" cBtnTexto)
            AplicarRegion(btn)
        }
    }
    if (IsObject(btnPerfil)) {
        btnPerfil.Opt("Background" cBoton " c" cBtnTexto)
        AplicarRegion(btnPerfil)
    }

    ; Labels con bg sólido en miGui — fondo + texto
    for ctrl in [tituloMacro, timerLabel, presetLabel, fpsLabel] {
        if (IsObject(ctrl))
            ctrl.Opt("Background" cFondo " c" cTexto)
    }

    ; Labels con bg en la ventana del historial
    for ctrl in [secuenciasLabel, destruccionesLabel, contadorLabel] {
        if (IsObject(ctrl))
            ctrl.Opt("Background" cFondoHist " c" cTexto)
    }
    if (IsObject(cooldownText))
        cooldownText.Opt("Background" cFondoHist " c" cCooldown)
    if (IsObject(afkText))
        afkText.Opt("Background" cFondoHist " c" cAFK)

    ; Luces (controles Text) — AplicarRegion tras Opt para conservar la forma redondeada.
    if (activo) {
        if (IsObject(luzActiva)) {
            luzActiva.Opt("Background" cLuzOn)
            AplicarRegion(luzActiva)
        }
        if (IsObject(luzAccion)) {
            luzAccion.Opt("Background" cBoton)
            AplicarRegion(luzAccion)
        }
        if (IsObject(luzApagado)) {
            luzApagado.Opt("Background" cBoton)
            AplicarRegion(luzApagado)
        }
    } else {
        if (IsObject(luzActiva)) {
            luzActiva.Opt("Background" cBoton)
            AplicarRegion(luzActiva)
        }
        if (IsObject(luzAccion)) {
            luzAccion.Opt("Background" cBoton)
            AplicarRegion(luzAccion)
        }
        if (IsObject(luzApagado)) {
            luzApagado.Opt("Background" cLuzOff)
            AplicarRegion(luzApagado)
        }
    }

    ; Separadores + polish visual (no parpadea porque va dentro del WM_SETREDRAW)
    if (IsObject(separadorHistorial)) {
        separadorHistorial.Opt("Background" MezclarHex(cBarra, cFondo, 0.45))
    }
    if (IsObject(glowTitulo)) {
        _cG := AclararHex(cBarra, 0.35)
        glowTitulo.Opt("Background" _cG)
        if (IsObject(glowTituloL))
            glowTituloL.Opt("Background" MezclarHex(_cG, cFondo, 0.8))
        if (IsObject(glowTituloR))
            glowTituloR.Opt("Background" MezclarHex(_cG, cFondo, 0.8))
    }
    if (IsObject(sepEstado)) {
        _cS := MezclarHex(cBarra, cFondo, 0.55)
        sepEstado.Opt("Background" _cS)
        if (IsObject(sepEstadoL))
            sepEstadoL.Opt("Background" MezclarHex(cBarra, cFondo, 0.11))
        if (IsObject(sepEstadoR))
            sepEstadoR.Opt("Background" MezclarHex(cBarra, cFondo, 0.11))
    }
    if (IsObject(sepAccion)) {
        _cA := MezclarHex(cBarra, cFondo, 0.55)
        sepAccion.Opt("Background" _cA)
        if (IsObject(sepAccionL))
            sepAccionL.Opt("Background" MezclarHex(cBarra, cFondo, 0.11))
        if (IsObject(sepAccionR))
            sepAccionR.Opt("Background" MezclarHex(cBarra, cFondo, 0.11))
    }

    ; Scrollbar personalizado

    ; Controles que antes NO transicionaban (saltaban de golpe al final)
    if (IsObject(btnTutorial)) {
        btnTutorial.Opt("Background" cBarra " c" cBtnTexto)
        AplicarRegion(btnTutorial)
    }
    if (IsObject(btnParches)) {
        btnParches.Opt("Background" cBarra " c" cBtnTexto)
        AplicarRegion(btnParches)
    }
    if (IsObject(cicloLabel)) {
        cicloLabel.Opt("Background" cFondo " c" cTexto)
    }
    for acc in [hoverAccent, hoverAccentTop, hoverAccentBot, hoverAccentRight, hoverAccentHist, hoverAccentBotHist, hoverAccentRightHist] {
        if (IsObject(acc))
            acc.Opt("Background" cBarra)
    }

    ; ── PASO 3: re-habilitar repaints ──
    DllCall("SendMessageW", "Ptr", miGui.Hwnd,        "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
    if (historialVisible)
        DllCall("SendMessageW", "Ptr", historialGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)

    ; ── PASO 4: UN solo repaint sincronico de TODO (ventana + hijos) ──
    TestTrace("TP4")
    DllCall("RedrawWindow", "Ptr", miGui.Hwnd,        "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
    if (historialVisible)
        DllCall("RedrawWindow", "Ptr", historialGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
    TestTrace("TP4 ok")

    ; ── Mini mode: lerp también (antes el mini saltaba de golpe al final) ──
    if (modoMini && IsObject(miniGui)) {
        DllCall("SendMessageW", "Ptr", miniGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)
        try miniGui.BackColor := cFondo
        for b in [btnMiniIniciar, btnMiniParar, btnMiniCerrar] {
            if (IsObject(b)) {
                b.Opt("Background" cBoton " c" cBtnTexto)
                AplicarRegion(b)
            }
        }
        if (IsObject(logoMacroMini))
            logoMacroMini.Opt("c" colorLogoEnTransicion)
        DllCall("SendMessageW", "Ptr", miniGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
        DllCall("RedrawWindow", "Ptr", miniGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
    }

    if (t >= 1.0) {
        TestTrace("TPfin>")
        colorBarraOverride := ""
        AplicarTema(temaTransTema, temaTransGuardar, true)
        TestTrace("TPfin AT ok")
        SetTimer(TransicionPaso, 0)
        temaEnTransicion := false
        ; Tras el cambio de tema, re-redondear TODO con la secuencia probada
        ; (los Opt() de la transición dejan los controles cuadrados). Dos pasadas
        ; escalonadas: la de -40ms a veces corre antes de que el RedrawWindow final
        ; de AplicarTema/partículas termine de asentarse y vuelve a exponer esquinas
        ; cuadradas. La segunda pasada (-220ms) gana esa carrera. NO es un bucle
        ; periódico (eso parpadea/cuadra, ver memoria): son 2 eventos puntuales.
        SetTimer(RedondearFuerteTodos, -40)
        SetTimer(RedondearFuerteTodos, -220)
    }

    } catch as e {
        ; Cierre de emergencia: parar el timer, restaurar redraws y aplicar el
        ; tema final directamente. Así un fallo puntual nunca tumba el macro.
        TestTrace("TPcatch: " e.Message " @" e.Line)
        SetTimer(TransicionPaso, 0)
        temaEnTransicion := false
        colorBarraOverride := ""
        try DllCall("SendMessageW", "Ptr", miGui.Hwnd,        "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
        try DllCall("SendMessageW", "Ptr", historialGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
        if (modoMini && IsObject(miniGui))
            try DllCall("SendMessageW", "Ptr", miniGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
        try AplicarTema(temaTransTema, temaTransGuardar)
        try DllCall("RedrawWindow", "Ptr", miGui.Hwnd,        "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
        try DllCall("RedrawWindow", "Ptr", historialGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
    }
}

LerpHex(hexA, hexB, t) {
    rA := "0x" SubStr(hexA,1,2), gA := "0x" SubStr(hexA,3,2), bA := "0x" SubStr(hexA,5,2)
    rB := "0x" SubStr(hexB,1,2), gB := "0x" SubStr(hexB,3,2), bB := "0x" SubStr(hexB,5,2)
    return Format("{:02X}{:02X}{:02X}",
        Round(rA + (rB-rA)*t),
        Round(gA + (gB-gA)*t),
        Round(bA + (bB-bA)*t))
}

AplicarTema(tema, guardar := true, fromTrans := false) {
    TestTrace("AT> " tema.nombre)
    global miGui, historialGui, historialBox, barra, barraHistorial, logoMacro, tituloMacro, timerLabel
    global cooldownText, afkText, secuenciasLabel, destruccionesLabel, luzActiva, luzAccion, luzApagado
    global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorVentanaHistorial, colorFondoHistorial, colorCooldown, colorAFK
    global colorBotonNormal, colorBotonHover, colorLogoMacro, colorLuzActiva, colorLuzAccion, colorLuzApagado
    global colorBtnTexto, colorHist1, colorHist2, colorHist3
    global activo
    global glowTitulo, glowTituloL, glowTituloR, sepEstado, sepEstadoL, sepEstadoR, sepAccion, sepAccionL, sepAccionR
    global temaPremiumActivo, rgbActivo, rgbBarra, rgbBotones, rgbLogo, rgbTexto

    ; ── Estilo de efecto de acción según el tema: misma categoría elemental
    ; que las partículas de fondo (EfectoDeTema), para que la ráfaga al
    ; detectar "represente" al tema (agua→lluvia, verde→viento de hojas...)
    ; en vez de una forma geométrica genérica sin relación con el tema.
    global efAccionEstilo
    efAccionEstilo := InStr(tema.nombre, "P R E M I U M") ? "premium"
        : InStr(tema.nombre, "Miel") ? "abejas" : EfectoDeTema(tema)

    ; ── Detección del tema PREMIUM (multi-hue RGB en todo) ──
    temaPremiumActivo := InStr(tema.nombre, "P R E M I U M") > 0
    if (temaPremiumActivo) {
        rgbActivo := true
        SetTimer(ActualizarRGB, presetRGB)
    } else {
        ; Al salir de premium, restaurar rgbActivo según los flags reales del usuario
        rgbActivo := rgbBarra || rgbBotones || rgbLogo || rgbTexto
        if (!rgbActivo)
            SetTimer(ActualizarRGB, 0)
    }

    ; Congelar redraws mientras se aplican todos los cambios — evita el frame en blanco
    if (fromTrans) {
        DllCall("SendMessage", "Ptr", miGui.Hwnd,        "UInt", 0xB, "Ptr", 0, "Ptr", 0)
        DllCall("SendMessage", "Ptr", historialGui.Hwnd, "UInt", 0xB, "Ptr", 0, "Ptr", 0)
    }

    colorFondoPrincipal := tema.fondo
    colorTextoPrincipal := tema.texto
    colorBarra := tema.barra
    colorTextoBarra := tema.textoBarra
    colorVentanaHistorial := tema.fondo
    colorFondoHistorial := tema.historial
    colorCooldown := tema.cooldown
    colorAFK := tema.afk
    colorBotonNormal := tema.boton
    colorBotonHover := tema.hover
    colorLogoMacro := tema.logo
    colorLuzActiva := tema.luzOn
    colorLuzAccion := tema.luzAccion
    colorLuzApagado := tema.luzOff
    colorBtnTexto := tema.btnTexto
    colorHist1 := tema.histColor1
    colorHist2 := tema.histColor2
    colorHist3 := tema.histColor3

    ; NOTA: aquí solo se usa Opt("c...") para recolorear — nada de SetFont.
    ; Las fuentes (familia/tamaño/peso) se fijan UNA vez al crear los controles;
    ; re-llamar SetFont en cada cambio de tema provoca repintados extra (el
    ; "salto" feo al final de la transición) y trabajo inútil acumulado.
    miGui.BackColor := colorFondoPrincipal
    historialGui.BackColor := colorVentanaHistorial
    barra.Opt("Background" colorBarra " c" colorTextoBarra)
    barraHistorial.Opt("Background" colorBarra " c" colorTextoBarra)
    if (IsObject(btnTutorial)) {
        btnTutorial.Opt("Background" colorBarra " c" colorBtnTexto)
        AplicarRegion(btnTutorial)
        DllCall("InvalidateRect", "Ptr", btnTutorial.Hwnd, "Ptr", 0, "Int", 1)
    }
    if (IsObject(btnParches)) {
        btnParches.Opt("Background" colorBarra " c" colorBtnTexto)
        AplicarRegion(btnParches)
        DllCall("InvalidateRect", "Ptr", btnParches.Hwnd, "Ptr", 0, "Int", 1)
    }
    if (IsObject(separadorHistorial))
        separadorHistorial.Opt("Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.45))
    if (IsObject(hoverAccent))
        hoverAccent.Opt("Background" colorBarra)
    if (IsObject(hoverAccentTop))
        hoverAccentTop.Opt("Background" colorBarra)
    if (IsObject(hoverAccentBot))
        hoverAccentBot.Opt("Background" colorBarra)
    if (IsObject(hoverAccentRight))
        hoverAccentRight.Opt("Background" colorBarra)
    if (IsObject(hoverAccentHist))
        hoverAccentHist.Opt("Background" colorBarra)
    if (IsObject(hoverAccentBotHist))
        hoverAccentBotHist.Opt("Background" colorBarra)
    if (IsObject(hoverAccentRightHist))
        hoverAccentRightHist.Opt("Background" colorBarra)
    ; Polish visual: glow bajo el título + separadores de sección (mezclados al fondo)
    if (IsObject(glowTitulo)) {
        _cG := AclararHex(colorBarra, 0.35)
        glowTitulo.Opt("Background" _cG)
        if (IsObject(glowTituloL))
            glowTituloL.Opt("Background" MezclarHex(_cG, colorFondoPrincipal, 0.8))
        if (IsObject(glowTituloR))
            glowTituloR.Opt("Background" MezclarHex(_cG, colorFondoPrincipal, 0.8))
    }
    if (IsObject(sepEstado)) {
        _cS := MezclarHex(colorBarra, colorFondoPrincipal, 0.55)
        sepEstado.Opt("Background" _cS)
        if (IsObject(sepEstadoL))
            sepEstadoL.Opt("Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.11))
        if (IsObject(sepEstadoR))
            sepEstadoR.Opt("Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.11))
    }
    if (IsObject(sepAccion)) {
        _cA := MezclarHex(colorBarra, colorFondoPrincipal, 0.55)
        sepAccion.Opt("Background" _cA)
        if (IsObject(sepAccionL))
            sepAccionL.Opt("Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.11))
        if (IsObject(sepAccionR))
            sepAccionR.Opt("Background" MezclarHex(colorBarra, colorFondoPrincipal, 0.11))
    }
    logoMacro.Opt("c" colorLogoMacro)
    ; Cambiar el carácter del logo si el tema define uno especial (Gojo=∞, Sukuna=⛩)
    try logoMacro.Text := (tema.HasProp("logoChar") ? tema.logoChar : Chr(9881))
    DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
    tituloMacro.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    timerLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    if (IsObject(presetLabel))
        presetLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    if (IsObject(fpsLabel))
        fpsLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    if (IsObject(cicloLabel))
        cicloLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    if (IsObject(contadorLabel))
        contadorLabel.Opt("Background" colorVentanaHistorial " c" colorTextoPrincipal)
    secuenciasLabel.Opt("Background" colorVentanaHistorial " c" colorTextoPrincipal)
    if (IsObject(destruccionesLabel))
        destruccionesLabel.Opt("Background" colorVentanaHistorial " c" colorTextoPrincipal)
    cooldownText.Opt("Background" colorVentanaHistorial " c" colorCooldown)
    afkText.Opt("Background" colorVentanaHistorial " c" colorAFK)
    ; (Las luces, controles Text, las recolorea ActualizarEstadoVisual() más abajo
    ;  según el estado activo — su color es su Background.)
    SendMessage(0x0443, 0, HexToBGR(colorFondoHistorial), , "ahk_id " historialBox.Hwnd)
    for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnStatsBtn, btnWebhook, btnLogros, btnMini, btnPersonalizar] {
        btn.Opt("Background" colorBotonNormal " c" colorBtnTexto)
        AplicarRegion(btn)
        if (!fromTrans) {
            DllCall("InvalidateRect", "Ptr", btn.Hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", btn.Hwnd)
        }
    }
    btnPerfil.Opt("Background" colorBotonNormal " c" colorBtnTexto)
    AplicarRegion(btnPerfil)
    if (!fromTrans) {
        DllCall("InvalidateRect", "Ptr", btnPerfil.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", btnPerfil.Hwnd)
    }
    ActualizarEstadoVisual()
    ; Actualizar mini mode si está activo — recrear con colores nuevos
    if (modoMini && IsObject(miniGui)) {
        miniGui.GetPos(&miniX, &miniY)
        if (IsObject(overlayPartMini))
            try overlayPartMini.Destroy()
        overlayPartMini := ""
        if (IsObject(overlayDecoMini))
            try overlayDecoMini.Destroy()
        overlayDecoMini := ""
        ; Purgar del registro de hover los botones del mini que van a morir —
        ; si no, el Map crece con hwnd huérfanos en cada cambio de tema.
        try LimpiarHoverGui(miniGui)
        try miniGui.Destroy()
        miniGui := ""
        logoMacroMini := ""
        barraMini := ""
        CrearMiniGui(miniX, miniY)
    }
    if (fromTrans) {
        ; Reactivar redraws y forzar un único repintado atómico — sin frame en blanco
        DllCall("SendMessage", "Ptr", miGui.Hwnd,        "UInt", 0xB, "Ptr", 1, "Ptr", 0)
        DllCall("SendMessage", "Ptr", historialGui.Hwnd, "UInt", 0xB, "Ptr", 1, "Ptr", 0)
        DllCall("RedrawWindow", "Ptr", miGui.Hwnd,        "Ptr", 0, "Ptr", 0, "UInt", 0x85)
        DllCall("RedrawWindow", "Ptr", historialGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x85)
    }
    ; Limpiar el overlay de decoraciones (Gojo Six Eyes / Sukuna kanji): al salir de un
    ; tema secreto, TickDecoracionesPermanentes deja de invalidar el overlay, así que los
    ; detalles quedaban congelados pegados. Forzamos un repintado que borra el frame previo.
    InvalidarOverlayDeco()
    ; Repintar YA el overlay de partículas/escena (overlayPartMain) con el tema NUEVO:
    ; si no, se queda con el último frame pintado del tema ANTERIOR hasta el próximo
    ; tick del timer (visible como decoración "pegada" del tema viejo al cambiar).
    if (!modoMini) {
        if (particulasActivas && presetParticulas > 0) {
            try ActualizarParticulas()
        } else if (optEscena) {
            try ActualizarEscenaSola()
        }
    }
    TestTrace("AT ok")
}

AplicarTemaAlMini(tema) {
    global miniGui, modoMini, particulasActivas, particulasMini
    global colorFondoPrincipal, colorBarra, colorTextoBarra, colorLogoMacro, colorBotonNormal, colorBtnTexto, colorTextoPrincipal
    global barraMini, logoMacroMini, btnMiniIniciar, btnMiniParar, btnMiniCerrar, btnMiniTema
    global overlayPartMini, overlayDecoMini, MINI_W, MINI_H, BAR_H, MINI_OVL_H, DECO_COLORKEY_HEX, DECO_COLORKEY_BGR

    if (!IsObject(miniGui) || !modoMini)
        return

    ; Guardar posición actual
    miniGui.GetPos(&miniX, &miniY)

    ; Actualizar colores globales
    colorFondoPrincipal := tema.fondo
    colorBarra := tema.barra
    colorTextoBarra := tema.textoBarra
    colorLogoMacro := tema.logo
    colorBotonNormal := tema.boton
    colorBtnTexto := tema.btnTexto
    colorTextoPrincipal := tema.texto

    ; Cambiar color de fondo del GUI
    miniGui.BackColor := colorFondoPrincipal

    ; Actualizar barra: necesita recrearse porque es Text con Background
    try barraMini.Destroy()
    barraMini := miniGui.Add("Text", "x0 y0 w" MINI_W " h" BAR_H " Background" colorBarra " Center +0x201", "Smart")
    barraMini.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barraMini.OnEvent("Click", ArrastrarMiniVentana)
    barraMini.OnEvent("DoubleClick", ToggleMiniMode)
    estiloBarraMini := DllCall("GetWindowLong", "Ptr", barraMini.Hwnd, "Int", -16, "Int")
    DllCall("SetWindowLong", "Ptr", barraMini.Hwnd, "Int", -16, "Int", estiloBarraMini | 0x04000000)

    ; Reinstalar subclass de ondas en la barra (reutilizar callback)
    if (!miniBarraSubclassCb)
        miniBarraSubclassCb := CallbackCreate(BarraSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", barraMini.Hwnd, "Ptr", miniBarraSubclassCb, "Ptr", 10, "Ptr", 0)

    ; barraMini se acaba de recrear → queda ARRIBA de logoMacroMini en el z-order
    ; (los controles nuevos siempre nacen al frente). El logo solapa 3px con la
    ; barra (y = BAR_H-3) a propósito; si la barra queda encima, su repintado
    ; (shimmer de ondas) pinta sobre esa franja del logo y compiten por ella en
    ; cada frame → parpadeo. Subir el logo de vuelta al frente restaura el orden
    ; original (logo encima, barra con WS_CLIPSIBLINGS se recorta sola).
    if (IsObject(logoMacroMini))
        DllCall("SetWindowPos", "Ptr", logoMacroMini.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)

    ; Actualizar botones (también necesitan recrearse)
    try btnMiniIniciar.Destroy()
    try btnMiniParar.Destroy()
    try btnMiniTema.Destroy()
    try btnMiniCerrar.Destroy()

    btnMiniIniciar := miniGui.Add("Text", "x27 y114 w30 h18 +0x201 Center Background" colorBotonNormal " c" colorBtnTexto, Chr(9654))
    btnMiniParar   := miniGui.Add("Text", "x63 y114 w30 h18 +0x201 Center Background" colorBotonNormal " c" colorBtnTexto, Chr(9632))
    for b in [btnMiniIniciar, btnMiniParar]
        b.SetFont("s9 c" colorBtnTexto " Bold", "Segoe UI Symbol")
    btnMiniIniciar.OnEvent("Click", Iniciar)
    btnMiniParar.OnEvent("Click", Parar)
    RegistrarHover(btnMiniIniciar, () => (rgbBotones ? colorRGBActual : colorBotonNormal))
    RegistrarHover(btnMiniParar,   () => (rgbBotones ? colorRGBActual : colorBotonNormal),
                                   () => MezclarHex(colorCooldown, colorBotonNormal, 0.45))

    btnMiniTema := miniGui.Add("Text", "x2 y" (BAR_H + 2) " w10 h11 +0x201 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x1F3A8))
    btnMiniTema.SetFont("s6 c" colorTextoPrincipal, "Segoe UI Emoji")
    btnMiniTema.OnEvent("Click", AbrirPanelTemas)
    RegistrarHover(btnMiniTema, () => (rgbBotones ? colorRGBActual : colorBotonNormal))

    btnMiniCerrar := miniGui.Add("Text", "x" (MINI_W - 13) " y" (BAR_H + 2) " w10 h11 +0x201 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(215))
    btnMiniCerrar.SetFont("s6 c" colorTextoPrincipal " Bold", "Segoe UI")
    btnMiniCerrar.OnEvent("Click", Cerrar)
    RegistrarHover(btnMiniCerrar, () => colorFondoPrincipal, () => "C42B1C")
    for _btn in [btnMiniIniciar, btnMiniParar]
        RedondearControl(_btn, 8)
    for _btn in [btnMiniTema, btnMiniCerrar]
        RedondearControl(_btn, 4)

    ; Logo NO se toca — mantiene su posición exacta
    logoMacroMini.SetFont("s48 c" colorLogoMacro " Bold", "Segoe UI Symbol")

    ; Recrear overlays (decoración y partículas)
    if (IsObject(overlayPartMini))
        try overlayPartMini.Destroy()
    overlayPartMini := ""
    if (IsObject(overlayDecoMini))
        try overlayDecoMini.Destroy()
    overlayDecoMini := ""

    if (particulasActivas) {
        try WinSetStyle("+0x02000000", "ahk_id " miniGui.Hwnd)
        overlayPartMini := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
        overlayPartMini.Opt("+Owner" miniGui.Hwnd)
        overlayPartMini.Show("x" miniX " y" (miniY + BAR_H) " w" MINI_W " h" MINI_OVL_H " NoActivate")
        InicializarParticulas(particulasMini, MINI_W, MINI_OVL_H, 15)
    }

    overlayDecoMini := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
    overlayDecoMini.Opt("+Owner" miniGui.Hwnd)
    overlayDecoMini.BackColor := DECO_COLORKEY_HEX
    overlayDecoMini.Show("x" miniX " y" (miniY + BAR_H) " w" MINI_W " h" MINI_OVL_H " NoActivate")
    DllCall("SetLayeredWindowAttributes", "Ptr", overlayDecoMini.Hwnd, "UInt", DECO_COLORKEY_BGR, "UChar", 255, "UInt", 1)
    if (!overlayDecoMiniSubCb)
        overlayDecoMiniSubCb := CallbackCreate(DecoOverlaySubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", overlayDecoMini.Hwnd, "Ptr", overlayDecoMiniSubCb, "Ptr", 27, "Ptr", 0)

    ; Redibujar y actualizar GUI
    miniGui.Show("NoActivate")
    ; Reaplicar el redondeo de la VENTANA (no solo de los controles): recrear
    ; barraMini/botones arriba puede dejar la región de la ventana sin tocar,
    ; pero por seguridad se reasienta aquí también (igual que al crearla).
    RedondearVentana(miniGui.Hwnd, 14)

    static WM_SETREDRAW := 0x000B
    static RDW_FLAGS    := 0x0001 | 0x0004 | 0x0080 | 0x0100
    DllCall("SendMessageW", "Ptr", miniGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
    DllCall("RedrawWindow", "Ptr", miniGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
}

ActualizarRGB(*) {
    global barra, barraHistorial, logoMacro, tituloMacro, timerLabel
    global cooldownText, afkText, secuenciasLabel, destruccionesLabel
    global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose
    global rgbBarraHue, colorRGBActual, rgbActivo
    global rgbBarra, rgbBotones, rgbLogo, rgbTexto
    global rgbVelocidad, rgbSaturacion, rgbBrillo, rgbDireccion
    global rgbPreviewCtrl, rgbGuiVisible
    global temaPremiumActivo, miGui

    ; OPTIMIZACIÓN: si la ventana principal está minimizada no se ve nada, no merece
    ; la pena gastar CPU + GDI handles cambiando colores. Crítico en premium mode.
    try if (IsObject(miGui) && DllCall("IsIconic", "Ptr", miGui.Hwnd, "Int"))
        return

    ; THROTTLE: con varias opciones activas, cada tick hace decenas de calls GDI.
    ; A 60ms eso satura el limite de handles del proceso en minutos → freeze.
    ; Mas opciones activas → mas espaciado entre updates (degradacion suave).
    static lastTick := 0
    activosRGB := (rgbBarra ? 1 : 0) + (rgbBotones ? 1 : 0) + (rgbLogo ? 1 : 0) + (rgbTexto ? 1 : 0)
    if (temaPremiumActivo)
        activosRGB := 4
    ; 1 activo: 60ms (smooth). 2: 80ms. 3: 110ms. 4 o premium: 150ms.
    intervalo := 60
    if (activosRGB = 2)
        intervalo := 80
    else if (activosRGB = 3)
        intervalo := 110
    else if (activosRGB >= 4)
        intervalo := 150
    if (A_TickCount - lastTick < intervalo)
        return
    lastTick := A_TickCount

    ; Todo el cuerpo en try para que un control destruido / hwnd basura no tumbe el timer.
    try {

    ; Timer va a 60ms ahora → 0.4 mantiene velocidad similar al antiguo 0.2 a 30ms
    rgbBarraHue += rgbVelocidad * rgbDireccion * 0.4
    if (rgbBarraHue >= 360)
        rgbBarraHue -= 360
    else if (rgbBarraHue < 0)
        rgbBarraHue += 360
    colorRGBActual := HSVaHex(rgbBarraHue, rgbSaturacion, rgbBrillo)

    ; ── MODO PREMIUM: multi-hue en todos los elementos con offsets de fase ──
    if (temaPremiumActivo) {
        cBarra := HSVaHex(rgbBarraHue, 1.0, 1.0)
        cBoton := HSVaHex(Mod(rgbBarraHue + 120, 360), 1.0, 1.0)
        cLogo  := HSVaHex(Mod(rgbBarraHue + 240, 360), 1.0, 1.0)
        cTexto := HSVaHex(Mod(rgbBarraHue + 60, 360), 1.0, 1.0)

        ; OPTIMIZACIÓN: NADA de SetFont aquí. SetFont crea un HFONT cada llamada,
        ; y a 33+ veces/seg eso fuga handles GDI y eventualmente revienta el proceso.
        ; La fuente ya está aplicada por AplicarTema una sola vez. Solo cambiamos colores.
        barra.Opt("Background" cBarra)
        DllCall("InvalidateRect", "Ptr", barra.Hwnd, "Ptr", 0, "Int", 1)
        barraHistorial.Opt("Background" cBarra)
        DllCall("InvalidateRect", "Ptr", barraHistorial.Hwnd, "Ptr", 0, "Int", 1)

        logoMacro.Opt("c" cLogo)
        DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)

        tituloMacro.Opt("c" cTexto)
        timerLabel.Opt("c" cTexto)
        cooldownText.Opt("c" cTexto)
        secuenciasLabel.Opt("c" cTexto)
        if (IsObject(destruccionesLabel))
            destruccionesLabel.Opt("c" cTexto)

        for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnStatsBtn, btnWebhook, btnLogros, btnPerfil, btnMini, btnPersonalizar] {
            btn.Opt("Background" cBoton " c000000")
            AplicarRegion(btn, false)   ; ciclo RGB rápido: solo re-set región, no repintar padre (evita flicker)
        }

        ; Actualizar preview RGB si está abierto
        if (rgbGuiVisible && IsObject(rgbPreviewCtrl)) {
            try {
                rgbPreviewCtrl.Opt("Background" cBarra)
                DllCall("InvalidateRect", "Ptr", rgbPreviewCtrl.Hwnd, "Ptr", 0, "Int", 1)
            }
        }
        return
    }

    ; ── Actualizar preview animado en el panel RGB si está abierto ─────
    if (rgbGuiVisible && IsObject(rgbPreviewCtrl)) {
        try {
            rgbPreviewCtrl.Opt("Background" colorRGBActual)
            DllCall("InvalidateRect", "Ptr", rgbPreviewCtrl.Hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", rgbPreviewCtrl.Hwnd)
        }
    }

    ; OPTIMIZACIÓN: sin SetFont aquí tampoco — la fuente la pone AplicarTema una vez.
    if (rgbBarra) {
        barra.Opt("Background" colorRGBActual)
        DllCall("InvalidateRect", "Ptr", barra.Hwnd, "Ptr", 0, "Int", 1)
        barraHistorial.Opt("Background" colorRGBActual)
        DllCall("InvalidateRect", "Ptr", barraHistorial.Hwnd, "Ptr", 0, "Int", 1)
        global glowTitulo, glowTituloL, glowTituloR, sepEstado, sepEstadoL, sepEstadoR, sepAccion, sepAccionL, sepAccionR
        if (IsObject(glowTitulo)) {
            _cG := AclararHex(colorRGBActual, 0.35)
            glowTitulo.Opt("Background" _cG)
            DllCall("InvalidateRect", "Ptr", glowTitulo.Hwnd, "Ptr", 0, "Int", 1)
            if (IsObject(glowTituloL)) {
                glowTituloL.Opt("Background" MezclarHex(_cG, colorFondoPrincipal, 0.8))
                DllCall("InvalidateRect", "Ptr", glowTituloL.Hwnd, "Ptr", 0, "Int", 1)
            }
            if (IsObject(glowTituloR)) {
                glowTituloR.Opt("Background" MezclarHex(_cG, colorFondoPrincipal, 0.8))
                DllCall("InvalidateRect", "Ptr", glowTituloR.Hwnd, "Ptr", 0, "Int", 1)
            }
        }
        if (IsObject(sepEstado)) {
            _cS := MezclarHex(colorRGBActual, colorFondoPrincipal, 0.55)
            sepEstado.Opt("Background" _cS)
            DllCall("InvalidateRect", "Ptr", sepEstado.Hwnd, "Ptr", 0, "Int", 1)
            if (IsObject(sepEstadoL)) {
                sepEstadoL.Opt("Background" MezclarHex(colorRGBActual, colorFondoPrincipal, 0.11))
                DllCall("InvalidateRect", "Ptr", sepEstadoL.Hwnd, "Ptr", 0, "Int", 1)
            }
            if (IsObject(sepEstadoR)) {
                sepEstadoR.Opt("Background" MezclarHex(colorRGBActual, colorFondoPrincipal, 0.11))
                DllCall("InvalidateRect", "Ptr", sepEstadoR.Hwnd, "Ptr", 0, "Int", 1)
            }
        }
        if (IsObject(sepAccion)) {
            _cA := MezclarHex(colorRGBActual, colorFondoPrincipal, 0.55)
            sepAccion.Opt("Background" _cA)
            DllCall("InvalidateRect", "Ptr", sepAccion.Hwnd, "Ptr", 0, "Int", 1)
            if (IsObject(sepAccionL)) {
                sepAccionL.Opt("Background" MezclarHex(colorRGBActual, colorFondoPrincipal, 0.11))
                DllCall("InvalidateRect", "Ptr", sepAccionL.Hwnd, "Ptr", 0, "Int", 1)
            }
            if (IsObject(sepAccionR)) {
                sepAccionR.Opt("Background" MezclarHex(colorRGBActual, colorFondoPrincipal, 0.11))
                DllCall("InvalidateRect", "Ptr", sepAccionR.Hwnd, "Ptr", 0, "Int", 1)
            }
        }
    }
    if (rgbLogo) {
        logoMacro.Opt("c" colorRGBActual)
        DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
    }
    if (rgbTexto) {
        tituloMacro.Opt("c" colorRGBActual)
        timerLabel.Opt("c" colorRGBActual)
        cooldownText.Opt("c" colorRGBActual)
        afkText.Opt("c" colorRGBActual)
        secuenciasLabel.Opt("c" colorRGBActual)
        if (IsObject(destruccionesLabel))
            destruccionesLabel.Opt("c" colorRGBActual)
    }
    if (rgbBotones) {
        for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnStatsBtn, btnWebhook, btnLogros, btnPerfil, btnMini, btnPersonalizar] {
            btn.Opt("Background" colorRGBActual " c000000")
            AplicarRegion(btn, false)   ; ciclo RGB rápido: solo re-set región, no repintar padre (evita flicker)
        }
    }

    }  ; fin del try que envuelve todo el cuerpo de ActualizarRGB
}

HSVaHex(h, s, v) {
    c := v * s
    x := c * (1 - Abs(Mod(h / 60, 2) - 1))
    m := v - c

    if (h < 60) {
        r := c, g := x, b := 0
    } else if (h < 120) {
        r := x, g := c, b := 0
    } else if (h < 180) {
        r := 0, g := c, b := x
    } else if (h < 240) {
        r := 0, g := x, b := c
    } else if (h < 300) {
        r := x, g := 0, b := c
    } else {
        r := c, g := 0, b := x
    }

    return Format("{:02X}{:02X}{:02X}", Round((r + m) * 255), Round((g + m) * 255), Round((b + m) * 255))
}

ActualizarEstadoVisual() {
    global activo, btnIniciar, btnParar
    global luzActiva, luzAccion, luzApagado
    global colorBotonNormal, colorBotonHover, colorLuzActiva, colorLuzApagado
    global rgbBotones, colorRGBActual, colorBtnTexto

    if (activo) {
        ; Activo → Iniciar se tiñe con la luz "on" del tema (verde/acento), mezclada
        ; con el botón para no romper el contraste del texto en temas extremos.
        btnIniciar.Opt("Background" (rgbBotones ? colorRGBActual : MezclarHex(colorLuzActiva, colorBotonNormal, 0.45)) " c" colorBtnTexto)
        AplicarRegion(btnIniciar)
        btnParar.Opt("Background"   (rgbBotones ? colorRGBActual : colorBotonNormal) " c" colorBtnTexto)
        AplicarRegion(btnParar)
        SetLuz(luzActiva, colorLuzActiva)
        SetLuz(luzAccion, colorBotonNormal)
        SetLuz(luzApagado, colorBotonNormal)
    } else {
        btnIniciar.Opt("Background" (rgbBotones ? colorRGBActual : colorBotonNormal) " c" colorBtnTexto)
        AplicarRegion(btnIniciar)
        btnParar.Opt("Background"   (rgbBotones ? colorRGBActual : colorBotonNormal) " c" colorBtnTexto)
        AplicarRegion(btnParar)
        SetLuz(luzActiva, colorBotonNormal)
        SetLuz(luzAccion, colorBotonNormal)
        SetLuz(luzApagado, colorLuzApagado)
    }
    for btn in [btnIniciar, btnParar] {
        DllCall("InvalidateRect", "Ptr", btn.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", btn.Hwnd)
    }
}

ArrastrarVentana(*) {
    PostMessage(0xA1, 2,,, "A")
}

Minimizar(*) {
    global miGui
    miGui.Minimize()
}

Cerrar(*) {
    global miGui, historialGui, overlayPartMain, overlayPartHist, heartbeatPath, miniGui, modoMini
    global perfilActivo, configPath, historialVisible
    ResetearCicloEstado()
    GuardarStats()
    GuardarRGBs()
    IniWrite(historialVisible ? 1 : 0, configPath, "UI", "HistorialVisible")
    IniWrite(perfilActivo, configPath, "UI", "PerfilActivo")
    GuardarPosiciones()
    ; Borrar heartbeat para que el watchdog externo NO nos reinicie (cierre intencionado)
    try FileDelete(heartbeatPath)
    ; Cerrar miniGui y sus overlays si están activos
    if (modoMini) {
        if (IsObject(overlayPartMini))
            try overlayPartMini.Destroy()
        if (IsObject(overlayDecoMini))
            try overlayDecoMini.Destroy()
        if (IsObject(miniGui))
            try miniGui.Destroy()
    }
    ; Ocultar los overlays de partículas para que no se vean flotando durante el fade
    if (IsObject(overlayPartMain))
        try overlayPartMain.Hide()
    if (IsObject(overlayPartHist))
        try overlayPartHist.Hide()
    ; Fade-out ambas ventanas
    loop 12 {
        op := Round(255 * (1 - A_Index / 12))
        try WinSetTransparent(op, "ahk_id " miGui.Hwnd)
        try WinSetTransparent(op, "ahk_id " historialGui.Hwnd)
        Sleep(14)
    }
    ExitApp()
}

Reiniciar(*) {
    global perfilActivo, configPath, historialVisible
    ResetearCicloEstado()
    GuardarStats()
    GuardarRGBs()
    IniWrite(historialVisible ? 1 : 0, configPath, "UI", "HistorialVisible")
    IniWrite(perfilActivo, configPath, "UI", "PerfilActivo")
    GuardarPosiciones()
    Reload()
}

AbrirCodigo(*) {
    Run('notepad.exe "' A_ScriptDir '\brawlmacrotct.ahk"')
}

; Perfiles que NO gestionan Brawlhalla: sin anti-AFK, sin modo destrucción,
; sin ciclo de descanso, sin relanzamientos ni Alt+F4. Son frt(3), dstv(4) y
; los dos perfiles vacíos extra (5 y 6, "macro base lista para configurar").
PerfilSinGestion(idx := 0) {
    global perfilActivo
    if (idx = 0)
        idx := perfilActivo
    return (idx >= 3)
}

; Devuelve solo el emoji del perfil (para el boton visible).
EmojiPerfil(idx := 0) {
    global perfilActivo
    if (idx = 0)
        idx := perfilActivo
    if (idx = 1)
        return Chr(0x1F310)  ; 🌐 publico
    if (idx = 2)
        return Chr(0x1F512)  ; 🔒 privado
    if (idx = 3)
        return Chr(0x2694)   ; ⚔ frt (spam mode)
    if (idx = 4)
        return Chr(0x2205)   ; ∅ dstv (detector circular)
    if (idx = 5)
        return Chr(0x2464)   ; ⑤ perfil vacío extra A
    return Chr(0x2465)        ; ⑥ perfil vacío extra B
}

; Devuelve el nombre legible completo (emoji + nombre) para el historial.
NombrePerfil(idx := 0) {
    global perfilActivo
    if (idx = 0)
        idx := perfilActivo
    if (idx = 1)
        return Chr(0x1F310) " tct"    ; 🌐 tct (publico)
    if (idx = 2)
        return Chr(0x1F512) " sp"      ; 🔒 sp (privado)
    if (idx = 3)
        return Chr(0x2694) " frt"      ; ⚔ frt (spam clicks + 1-7)
    if (idx = 4)
        return Chr(0x2205) " dstv"      ; ∅ dstv (detector circular)
    if (idx = 5)
        return Chr(0x2464) " base 1"    ; ⑤ perfil vacío extra A (sin timers/AFK/AltF4)
    return Chr(0x2465) " base 2"        ; ⑥ perfil vacío extra B (sin timers/AFK/AltF4)
}

; Cicla 1 → 2 → 3 → 4 → 5 → 6 → 1 → ...
CambiarPerfil(*) {
    global perfilActivo, btnPerfil, configPath, brawlhallaLanzado
    global ultimoCambio, modoDestruccion, tiempoUltimoLanzamiento, ultimoPasoEjecutado
    perfilActivo := (perfilActivo >= 6) ? 1 : perfilActivo + 1
    btnPerfil.Value := EmojiPerfil()
    DllCall("InvalidateRect", "Ptr", btnPerfil.Hwnd, "Ptr", 0, "Int", 1)
    DllCall("UpdateWindow",   "Ptr", btnPerfil.Hwnd)
    IniWrite(perfilActivo, configPath, "UI", "PerfilActivo")
    AgregarHistorial("Perfil activo: " NombrePerfil(), "")
    ; Resetea la flag para que al pulsar Iniciar en el nuevo perfil se lance SU juego
    brawlhallaLanzado := false
    ; Resetear estado rancio del perfil anterior: sin esto, al volver de frt/dstv
    ; a tct/sp el anti-AFK o el modo destrucción saltaban al instante porque
    ; ultimoCambio llevaba parado todo el rato que estuviste en el otro perfil.
    ultimoCambio := A_TickCount
    modoDestruccion := false
    tiempoUltimoLanzamiento := 0
    ultimoPasoEjecutado := ""
    ; Si estamos en macro activo y cambiamos a/desde frt, actualizar los timers de spam
    ActualizarTimersFrt()
    ; Mostrar u ocultar labels AFK/secuencias/destruccion segun el perfil
    ActualizarVisibilidadFrt()
}

ToggleHistorial(*) {
    global historialGui, historialVisible, configPath, overlayPartHist
    hwnd := historialGui.Hwnd
    if historialVisible {
        historialGui.Hide()
        if (IsObject(overlayPartHist))
            try overlayPartHist.Hide()
        historialVisible := false
    } else {
        historialGui.Show("NoActivate")
        if (IsObject(overlayPartHist)) {
            historialGui.GetPos(&_hgx, &_hgy, &_hgw, &_hgh)
            try overlayPartHist.Show("x" _hgx " y" (_hgy + 25) " w" _hgw " h" (_hgh - 25) " NoActivate")
        }
        ; Forzar repintado completo: necesario porque WS_CLIPCHILDREN (de partículas)
        ; puede impedir que los hijos se invaliden al reaparecer la ventana
        DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0585)
        ; Invalidar individualmente cada hijo para asegurar repaint completo
        cb := DllCall("GetWindow", "Ptr", hwnd, "UInt", 5, "Ptr")  ; GW_CHILD
        while (cb) {
            DllCall("InvalidateRect", "Ptr", cb, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", cb)
            cb := DllCall("GetWindow", "Ptr", cb, "UInt", 2, "Ptr")  ; GW_HWNDNEXT
        }
        historialVisible := true
    }
    IniWrite(historialVisible ? 1 : 0, configPath, "UI", "HistorialVisible")
}

RedondearVentana(hwnd, curva := 14) {
    ; Si la ventana no existe o el hwnd es invalido, salir sin error.
    ; (Antes este escenario tiraba "Gui has no window" cuando alguien
    ; llamaba justo despues de un Destroy o si Show fallaba.)
    if (!hwnd || !WinExist("ahk_id " hwnd))
        return
    x := y := w := h := 0
    try {
        WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
        rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w + 1, "Int", h + 1, "Int", curva, "Int", curva, "Ptr")
        DllCall("SetWindowRgn", "Ptr", hwnd, "Ptr", rgn, "Int", true)
    }
}

; ── LA CLAVE del redondeo real ──
; SetWindowRgn solo cambia la FORMA de recorte de la ventana; NO borra los
; píxeles que ya estaban pintados. Al recortar un control cuadrado a una región
; redondeada, las 4 esquinas quedan "fuera" del hijo (el hijo ya no las pinta),
; pero siguen mostrando el relleno cuadrado que el control pintó al crearse.
; Normalmente el PADRE repintaría esas esquinas con su fondo — pero miGui tiene
; WS_CLIPCHILDREN (para el overlay de partículas), que excluye el rectángulo del
; hijo del repintado del padre. Resultado: nadie repinta las esquinas y se quedan
; cuadradas para siempre. La cura: invalidar el rect del PADRE bajo el control con
; erase=TRUE, así el padre rellena esas esquinas con su brocha de fondo.
; (Misma técnica que ya se usa en ToggleHistorial para el mismo problema.)
; forzarYa=true fuerza el repintado AHORA (UpdateWindow, síncrono) — usar en
; transiciones discretas (arranque, entrar/salir de hover). forzarYa=false solo
; encola el invalidate (deja que el próximo ciclo del mensaje lo pinte) — usar
; en rutas de ALTA frecuencia (HoverBreath, ciclo RGB) para no forzar un
; repintado síncrono del padre cada pocos ms (eso sí causaría parpadeo visible).
InvalidarEsquinasEnPadre(ctrl, forzarYa := true) {
    hParent := DllCall("GetParent", "Ptr", ctrl.Hwnd, "Ptr")
    if (!hParent)
        return
    rc := Buffer(16, 0)
    DllCall("GetWindowRect", "Ptr", ctrl.Hwnd, "Ptr", rc)            ; rc = pantalla (L,T,R,B)
    ; Mapear las 2 esquinas (L,T)/(R,B) de pantalla a cliente del padre (DPI-agnóstico).
    DllCall("MapWindowPoints", "Ptr", 0, "Ptr", hParent, "Ptr", rc, "UInt", 2)
    DllCall("InvalidateRect", "Ptr", hParent, "Ptr", rc, "Int", 1)   ; erase=TRUE → brocha de fondo
    if (forzarYa)
        DllCall("UpdateWindow", "Ptr", hParent)
}

; Re-aplica el SetWindowRgn redondeado almacenado en _ctrlRadios.
; DEBE llamarse después de cualquier ctrl.Opt("Background...") para que
; Windows no descarte la región al cambiar el color/estilo de fondo.
; invalidarPadre=true borra las esquinas expuestas (necesario en cambios de
; color/estado y al arranque); false solo re-asienta la región (barrido de 2s).
AplicarRegion(ctrl, invalidarPadre := true) {
    global _ctrlRadios
    if (_ctrlRadios.Has(ctrl)) {
        _ri := _ctrlRadios[ctrl]
        rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0,
                       "Int", _ri.rw + 1, "Int", _ri.rh + 1,
                       "Int", _ri.radio, "Int", _ri.radio, "Ptr")
        DllCall("SetWindowRgn", "Ptr", ctrl.Hwnd, "Ptr", rgn, "Int", true)
        if (invalidarPadre)
            InvalidarEsquinasEnPadre(ctrl)
    }
}

; Redondeo "fuerte" — replica EXACTAMENTE la secuencia del hover (HoverPoll), que
; es la única confirmada que deja los controles redondos de verdad: dance de
; WM_SETREDRAW (bloquea el repintado cuadrado interno de Opt) + SetWindowRgn con
; bRedraw=0 + repintar el control + limpiar las esquinas del padre de forma
; SÍNCRONA (InvalidarEsquinasEnPadre con forzarYa=true → UpdateWindow inmediato).
; Pensado para eventos PUNTUALES (iniciar, cambiar tema, restaurar, salir de mini),
; NUNCA en bucles periódicos: la limpieza síncrona de esquinas en bucle parpadea.
RedondearControlFuerte(ctrl) {
    global _ctrlRadios
    if (!_ctrlRadios.Has(ctrl))
        return
    _ri := _ctrlRadios[ctrl]
    DllCall("SendMessageW", "Ptr", ctrl.Hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
    rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0,
                   "Int", _ri.rw + 1, "Int", _ri.rh + 1,
                   "Int", _ri.radio, "Int", _ri.radio, "Ptr")
    DllCall("SetWindowRgn", "Ptr", ctrl.Hwnd, "Ptr", rgn, "Int", 0)
    DllCall("SendMessageW", "Ptr", ctrl.Hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
    DllCall("InvalidateRect", "Ptr", ctrl.Hwnd, "Ptr", 0, "Int", 1)
    DllCall("UpdateWindow",   "Ptr", ctrl.Hwnd)
    InvalidarEsquinasEnPadre(ctrl)
}

RedondearFuerteTodos() {
    global _ctrlRadios
    for ctrl, info in _ctrlRadios {
        try RedondearControlFuerte(ctrl)
    }
}

; Re-aplica la región a TODOS los controles redondeados conocidos. Ver el
; comentario en la llamada de arranque (SetTimer ReaplicarTodasLasRegiones)
; para el porqué: los controles sin hover/click nunca se autocorrigen solos.
; Pasa invalidarPadre=false: solo re-asienta la región sin repintar el padre
; cada 2s (las esquinas ya quedaron limpias al arranque / cambio de color).
ReaplicarTodasLasRegiones() {
    global _ctrlRadios
    ; SOLO re-asentar la región redonda (SetWindowRgn). NO se invalida el padre
    ; aquí: hacerlo cada 2s repintaba el rect completo de cada control con la
    ; brocha de fondo y los dejaba cuadrados. La limpieza de esquinas se hace de
    ; forma puntual (cambio de tema, hover, restaurar) con forzarYa=TRUE.
    for ctrl, info in _ctrlRadios {
        try AplicarRegion(ctrl, false)
    }
}

; Evento Size de miGui. MinMax: -1=minimizado, 1=maximizado, 0=restaurado/normal.
; Al RESTAURAR desde minimizado, Windows resetea las regiones redondeadas (ventana
; y controles vuelven a cuadrados). Reaplicar TODO una sola vez, no en bucle.
GuiPrincipalSize(guiObj, minMax, w, h) {
    if (minMax != 0)
        return
    ; Pequeño delay para que el restore termine de asentarse antes de redondear.
    SetTimer(RestaurarRedondeoCompleto, -80)
}

RestaurarRedondeoCompleto() {
    global miGui, historialGui, historialVisible
    ; Redondear ventanas + TODOS los controles con la secuencia probada del hover.
    try if (IsObject(miGui))
        RedondearVentana(miGui.Hwnd, 20)
    try if (IsObject(historialGui) && historialVisible)
        RedondearVentana(historialGui.Hwnd, 14)
    RedondearFuerteTodos()
}

RedondearControl(ctrl, radio := 10) {
    global _ctrlRadios
    ; Usamos GetClientRect (píxeles FÍSICOS reales del control) en vez de
    ; ctrl.GetPos (que devuelve coords lógicas escaladas por +DPIScale). Así la
    ; región redondeada coincide EXACTAMENTE con el control en cualquier escala
    ; de Windows. El radio es una esquina curva moderada (cuadrado redondeado),
    ; NO un círculo/píldora completo — el diámetro de curva se limita a la
    ; mitad del lado menor como tope para que nunca llegue a verse circular.
    rc := Buffer(16, 0)
    DllCall("GetClientRect", "Ptr", ctrl.Hwnd, "Ptr", rc)
    w := NumGet(rc, 8, "Int"), h := NumGet(rc, 12, "Int")
    if (w <= 0 || h <= 0) {   ; fallback si el control aún no tiene tamaño
        ctrl.GetPos(,, &w, &h)
    }
    rr := Min(Round(radio * (A_ScreenDPI / 96.0)), Round(Min(w, h) / 2))
    rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w + 1, "Int", h + 1, "Int", rr, "Int", rr, "Ptr")
    DllCall("SetWindowRgn", "Ptr", ctrl.Hwnd, "Ptr", rgn, "Int", true)
    _ctrlRadios[ctrl] := {radio: rr, rw: w, rh: h}
    InvalidarEsquinasEnPadre(ctrl)   ; borra las esquinas cuadradas YA, sin esperar al timer de 2s
}

MostrarAviso(*) {
    global avisoGui, colorFondoPrincipal, colorTextoPrincipal
    avisoGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    avisoGui.BackColor := colorFondoPrincipal
    avisoGui.SetFont("s12 c" colorTextoPrincipal " Bold", "Segoe UI")
    avisoGui.Add("Text", "Center w260 h60", "PON EL MACRO EN ABAJO A LA IZQUIERDA")
    avisoGui.Show("AutoSize Center")
    RedondearVentana(avisoGui.Hwnd, 14)
    SetTimer(() => avisoGui.Destroy(), -3000)
}

ExportarSesion(*) {
    global tiempoAcumulado, tiempoInicio, timerActivo
    global contadorSecuencias, horaInicioSesion
    global contadorDestruccion, totalDestruccionGuardada

    tiempoSesion := tiempoAcumulado
    if (timerActivo)
        tiempoSesion += (A_TickCount - tiempoInicio)

    h := Floor(tiempoSesion / 3600000)
    m := Floor((tiempoSesion - h*3600000) / 60000)
    s := Floor((tiempoSesion - h*3600000 - m*60000) / 1000)
    seqHora := (tiempoSesion > 0 && contadorSecuencias > 0)
               ? Round(contadorSecuencias / (tiempoSesion/3600000), 1) : 0

    txt  := "══════════════════════════════`n"
    txt .= "     AFK MACRO — RESUMEN DE SESIÓN`n"
    txt .= "══════════════════════════════`n"
    txt .= "Fecha inicio : " horaInicioSesion "`n"
    txt .= "Fecha fin    : " FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "`n"
    txt .= "Duración     : " Format("{:02}h {:02}m {:02}s", h, m, s) "`n"
    txt .= "──────────────────────────────`n"
    txt .= "Secuencias   : " contadorSecuencias "`n"
    txt .= "Seqs/hora    : " seqHora "`n"
    txt .= "Destrucción  : " (totalDestruccionGuardada + contadorDestruccion) "`n"
    txt .= "══════════════════════════════`n"

    ruta := A_ScriptDir "\sesion_" FormatTime(A_Now, "yyyy-MM-dd_HH-mm") ".txt"
    FileAppend(txt, ruta, "UTF-8")
    ToolTip("Exportado: " ruta)
    SetTimer(() => ToolTip(), -3000)
}

; ===== LUCES =====
; Las luces son controles Text: su color es el Background. Repintamos al cambiar.
; AplicarRegion() re-aplica SetWindowRgn tras Opt() para mantener el borde redondeado.
SetLuz(control, color) {
    global _ctrlRadios
    ; Misma secuencia probada del hover, para que las luces NO se cuadren al
    ; iniciar/parar/cambiar de estado (AplicarRegion suelto no bastaba).
    try {
        DllCall("SendMessageW", "Ptr", control.Hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
        control.Opt("Background" color)
        if (_ctrlRadios.Has(control)) {
            _ri := _ctrlRadios[control]
            rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0,
                           "Int", _ri.rw + 1, "Int", _ri.rh + 1,
                           "Int", _ri.radio, "Int", _ri.radio, "Ptr")
            DllCall("SetWindowRgn", "Ptr", control.Hwnd, "Ptr", rgn, "Int", 0)
        }
        DllCall("SendMessageW", "Ptr", control.Hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
        DllCall("InvalidateRect", "Ptr", control.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", control.Hwnd)
        InvalidarEsquinasEnPadre(control)
    }
}

LuzAccionFlash(catColor := "") {
    global luzAccion, colorLuzAccion, colorBotonNormal
    EfectoAccion(catColor)   ; efectos dinámicos (glow/fade/zoom/slide) — no bloqueante
    flashColor := (catColor != "" ? catColor : colorLuzAccion)
    SetLuz(luzAccion, "FFFFFF")
    Sleep(35)
    SetLuz(luzAccion, flashColor)
    Sleep(90)
    SetLuz(luzAccion, colorBotonNormal)
}

OndaBarra() {
    global barraOndaOffset, barraExtraBrillo
    barraOndaOffset := 70.0
    if (barraExtraBrillo < 55)
        barraExtraBrillo := 55
}

; ===== ANIMACIONES VISUALES =====

; Pulso suave de la barra título mientras el macro está activo
PulsoBarraActivo(*) {
    global activo, temaEnTransicion, rgbBarra, optPulsoBarra
    global pulsoBrilloDir, pulsoBrilloT
    global barraOndaOffset, barraExtraBrillo
    if (!activo || temaEnTransicion || !optPulsoBarra) {
        barraOndaOffset := 0.0
        if (!activo)
            barraExtraBrillo := 0
        return
    }
    pulsoBrilloT += 0.04 * pulsoBrilloDir
    if (pulsoBrilloT >= 1.0) {
        pulsoBrilloT := 1.0
        pulsoBrilloDir := -1
    } else if (pulsoBrilloT <= 0.0) {
        pulsoBrilloT := 0.0
        pulsoBrilloDir := 1
    }
    delta := Round(28 * Sin(pulsoBrilloT * 3.14159))
    onda := Round(barraOndaOffset)
    if (barraOndaOffset > 0)
        barraOndaOffset := Max(0.0, barraOndaOffset - 6.0)
    barraExtraBrillo := delta + onda
}

; Pulso de brillo del logo mientras el macro está activo
PulsoLogoActivo(*) {
    global activo, logoMacro, colorLogoMacro, temaEnTransicion, optPulsoLogo
    global logosPulsoDir, logosPulsoT
    if (!activo || temaEnTransicion || !optPulsoLogo)
        return
    logosPulsoT += 0.05 * logosPulsoDir
    if (logosPulsoT >= 1.0) {
        logosPulsoT := 1.0
        logosPulsoDir := -1
    } else if (logosPulsoT <= 0.0) {
        logosPulsoT := 0.0
        logosPulsoDir := 1
    }
    rL := Integer("0x" SubStr(colorLogoMacro, 1, 2))
    gL := Integer("0x" SubStr(colorLogoMacro, 3, 2))
    bL := Integer("0x" SubStr(colorLogoMacro, 5, 2))
    delta := Round(55 * Sin(logosPulsoT * 3.14159))
    rN := Max(0, Min(255, rL + delta))
    gN := Max(0, Min(255, gL + delta))
    bN := Max(0, Min(255, bL + delta))
    c := Format("{:02X}{:02X}{:02X}", rN, gN, bN)
    logoMacro.Opt("c" c)
    DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
}

; Flash de error en barra (rojo y vuelta)
InterpolarHex(hexA, hexB, t) {
    rA := Integer("0x" SubStr(hexA, 1, 2))
    gA := Integer("0x" SubStr(hexA, 3, 2))
    bA := Integer("0x" SubStr(hexA, 5, 2))
    rB := Integer("0x" SubStr(hexB, 1, 2))
    gB := Integer("0x" SubStr(hexB, 3, 2))
    bB := Integer("0x" SubStr(hexB, 5, 2))
    return Format("{:02X}{:02X}{:02X}",
        Round(rA + (rB - rA) * t),
        Round(gA + (gB - gA) * t),
        Round(bA + (bB - bA) * t))
}

; ════════════════════════════════════════════════════════════════════════
; OVERLAY DE DECORACIONES TEMÁTICAS — encima de toda la GUI del macro
; Window topmost + layered + transparent + color-key. Click-through.
; Comparte para Sukuna (slashes) y Gojo (aura del Limitless).
; (Las globals se declaran en el auto-execute al inicio del script)
; ════════════════════════════════════════════════════════════════════════
CrearOverlayDecoraciones() {
    global miGui, overlayDecoraciones, overlayDecoSubclassCb, DECO_COLORKEY_HEX, DECO_COLORKEY_BGR
    static BAR_H := 25
    if (IsObject(overlayDecoraciones))
        return
    ; +E0x80020 = WS_EX_LAYERED | WS_EX_TRANSPARENT (clicks pasan a través)
    overlayDecoraciones := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
    overlayDecoraciones.Opt("+Owner" miGui.Hwnd)
    overlayDecoraciones.BackColor := DECO_COLORKEY_HEX
    miGui.GetPos(&mx, &my, &mw, &mh)
    overlayDecoraciones.Show("x" mx " y" (my + BAR_H) " w" mw " h" (mh - BAR_H) " NoActivate")
    ; Color key transparente
    DllCall("SetLayeredWindowAttributes", "Ptr", overlayDecoraciones.Hwnd, "UInt", DECO_COLORKEY_BGR, "UChar", 255, "UInt", 1)
    ; Subclase para WM_PAINT — pinta el contenido decorativo
    overlayDecoSubclassCb := CallbackCreate(DecoOverlaySubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", overlayDecoraciones.Hwnd, "Ptr", overlayDecoSubclassCb, "Ptr", 27, "Ptr", 0)
}

DecoOverlaySubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND)
        return 1
    if (uMsg = WM_PAINT) {
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            rc := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", hWnd, "Ptr", rc)
            w := NumGet(rc, 8, "Int")
            h := NumGet(rc, 12, "Int")
            ; Fondo con color key (todo transparente)
            global DECO_COLORKEY_BGR
            brushKey := DllCall("CreateSolidBrush", "UInt", DECO_COLORKEY_BGR, "Ptr")
            DllCall("FillRect", "Ptr", hdc, "Ptr", rc, "Ptr", brushKey)
            DllCall("DeleteObject", "Ptr", brushKey)
            ; ¿Es el overlay del mini-modo? → coordenadas/escala distintas
            global overlayDecoMini
            esMini := (IsObject(overlayDecoMini) && hWnd = overlayDecoMini.Hwnd)
            ; Dibujar decoración según tema activo + estado de animación
            PintarDecoracionesEnHDC(hdc, w, h, esMini)
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

PintarDecoracionesEnHDC(hdc, w, h, esMini := false) {
    global temas, temaActual, sukunaSlashFrame, gojoAuraFrame, efAccionFrame, efAccionMaxFrame, gojoDominioFrame

    unlock := ""
    decoTema := ""
    if (temas[temaActual].HasProp("unlock"))
        unlock := temas[temaActual].unlock
    if (temas[temaActual].HasProp("deco"))
        decoTema := temas[temaActual].deco

    ; Centro del logo EN COORDENADAS DEL OVERLAY (resta BAR_H=25 a la y del logo):
    ;   Principal: logo x19 y31 w95 h95 en miGui → centro (66, 78) → overlay (66, 53)
    ;   Mini:      logo x15 y30 w80 h80 en miniGui → centro (55, 70) → overlay (55, 45)
    if (esMini) {
        lcx := 55.0, lcy := 45.0
        radioOjos := 40.0, radioAnillo := 33.0
    } else {
        lcx := 66.0, lcy := 53.0
        radioOjos := 52.0, radioAnillo := 38.0
    }

    ; ── EFECTO DE ACCIÓN UNIVERSAL (todos los temas): onda glow/zoom al detectar ──
    if (efAccionFrame > 0)
        try PintarEfectoAccion(hdc, lcx, lcy, efAccionFrame, efAccionMaxFrame)

    if (!unlock && !decoTema)
        return

    ; ── DECORACIONES PERMANENTES (cada frame mientras el tema esté activo) ──
    if (unlock = "sukuna") {
        ; El nombre 両面宿儺 solo en el GUI grande (en el mini no cabe bien)
        if (!esMini)
            PintarNombreSukuna(hdc, w, h)
    } else if (unlock = "gojo") {
        PintarSixEyesGojo(hdc, lcx, lcy, radioOjos)   ; 6 ojos orbitando el logo
        PintarAnilloGojo(hdc, lcx, lcy, radioAnillo)  ; anillo Limitless
    } else if (decoTema = "azul") {
        PintarAuraAzul(hdc, lcx, lcy, radioAnillo)    ; aura azul brillante
    } else if (decoTema = "rojo") {
        PintarAuraRojo(hdc, lcx, lcy, radioAnillo)    ; aura rojo brillante
    }

    ; ── ANIMACIONES PUNTUALES (al detectar) ──
    if (unlock = "sukuna" && sukunaSlashFrame > 0) {
        PintarSlashSukunaEnHDC(hdc, w, h, sukunaSlashFrame)
    } else if (unlock = "gojo" && gojoAuraFrame > 0) {
        PintarAuraGojoEnHDC(hdc, lcx, lcy, gojoAuraFrame, 14)
    }

    ; ── EXPANSIÓN DE DOMINIO GOJO: Vacío Ilimitado (無量空処) — se pinta encima de todo ──
    if (unlock = "gojo" && gojoDominioFrame > 0)
        PintarDominioGojoEnHDC(hdc, w, h, lcx, lcy, gojoDominioFrame, 30)
}

; ═══════════════════ DECORACIONES PERMANENTES SUKUNA ═══════════════════

; "両面宿儺" (Ryomen Sukuna) escrito en columna vertical a la derecha del logo,
; en zona vacía entre el título y los botones. Uso el font cacheado.
PintarNombreSukuna(hdc, w, h) {
    global sukunaFont
    if (!sukunaFont)
        return
    ; Fase basada en tiempo real → respiración independiente del framerate.
    fase := Mod(A_TickCount / 1000.0 * 0.9, 6.2831853)
    ; Respiración suave del alpha (0.55 - 1.0)
    alpha := Round(120 + 60 * Sin(fase))

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", g, "Int", 4)

    argbCol := (alpha << 24) | 0xB30000   ; rojo sangre Sukuna
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbCol, "Ptr*", &brush)
    fmt := 0
    DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &fmt)
    DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", fmt, "Int", 1)  ; centro horizontal
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", fmt, "Int", 0)  ; top

    ; Columna vertical "両面宿儺" en una zona libre — esquina inferior izq del overlay,
    ; debajo del logo. Cada char en su propia caja de 18px de alto.
    static chars := [Chr(0x4E21), Chr(0x9762), Chr(0x5BBF), Chr(0x5132)]  ; 両 面 宿 儺
    baseX := 8.0
    baseY := h - 78.0   ; arriba de los botones inferiores
    Loop 4 {
        rc := Buffer(16, 0)
        NumPut("Float", baseX,                 rc, 0)
        NumPut("Float", baseY + (A_Index - 1) * 17.0, rc, 4)
        NumPut("Float", 18.0,                  rc, 8)
        NumPut("Float", 18.0,                  rc, 12)
        DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", chars[A_Index], "Int", 1, "Ptr", sukunaFont, "Ptr", rc, "Ptr", fmt, "Ptr", brush)
    }

    DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmt)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

; Anillo de aura roja oscura alrededor del logo — la presencia siniestra
; constante del Rey de las Maldiciones. Similar al anillo de Gojo pero
; rojo y con doble anillo (los 2 pares de ojos / brazos).
PintarAnilloSukuna(hdc, w, h) {
    static fase := 0.0
    fase += 0.05
    if (fase > 6.28)
        fase -= 6.28

    cx := 66.0
    cy := 53.0
    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    ; Dos anillos rojos contrarrotantes con pulso desfasado
    Loop 2 {
        i := A_Index - 1
        signo := (i = 0) ? 1 : -1
        ondaFase := fase * signo + i * 3.14159
        radio := 36.0 + 3.0 * Sin(ondaFase)
        alpha := Round(50 + 40 * Sin(ondaFase))
        if (alpha < 25)
            alpha := 25
        ; Tono rojo profundo, ligeramente variable
        cR := 200 + Round(40 * Sin(ondaFase * 0.5))
        cG := 30
        cB := 40
        argbRing := (alpha << 24) | (cR << 16) | (cG << 8) | cB
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", argbRing, "Float", 1.5, "Int", 2, "Ptr*", &pen)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", pen, "Float", cx - radio, "Float", cy - radio, "Float", radio * 2.0, "Float", radio * 2.0)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

; ═══════════════════ DECORACIONES PERMANENTES GOJO ═══════════════════

; Six Eyes (六眼): 6 puntos cyan brillantes orbitando alrededor del logo.
; Representan los Six Eyes que dan a Gojo su capacidad de ver toda la
; energía maldita perfectamente.
PintarSixEyesGojo(hdc, cx, cy, radioOrbit) {
    ; Fase basada en TIEMPO REAL (no en nº de frames) → la velocidad de órbita
    ; es idéntica a 12fps o a 60fps, solo cambia la suavidad. ~0.45 rad/s.
    fase := Mod(A_TickCount / 1000.0 * 0.45, 6.2831853)

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    Loop 6 {
        i := A_Index - 1
        ang := fase + (i * 1.0472)   ; 60° entre ojos
        ox := cx + Cos(ang) * radioOrbit
        oy := cy + Sin(ang) * radioOrbit
        ; Cada ojo: brillo individual (parpadeo desfasado)
        intensidad := 0.5 + 0.5 * Sin(fase * 2 + i * 0.8)
        alpha := Round(180 + 75 * intensidad)
        ; Color azul cielo de Limitless con un toque cyan
        cR := 79, cG := 195, cB := 247
        argbOjo := (alpha << 24) | (cR << 16) | (cG << 8) | cB
        ; Ojo grande exterior (glow)
        brushExt := 0
        argbGlow := (Round(40 * intensidad) << 24) | (cR << 16) | (cG << 8) | cB
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbGlow, "Ptr*", &brushExt)
        rExt := 6.0
        DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brushExt, "Float", ox - rExt, "Float", oy - rExt, "Float", rExt * 2, "Float", rExt * 2)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushExt)
        ; Ojo interior brillante
        brushOjo := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argbOjo, "Ptr*", &brushOjo)
        rInt := 2.5 + intensidad * 1.0
        DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brushOjo, "Float", ox - rInt, "Float", oy - rInt, "Float", rInt * 2, "Float", rInt * 2)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushOjo)
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

; Anillo Limitless: anillo azul claro pulsante alrededor del logo.
; Representa la barrera del Infinito que rodea a Gojo siempre.
PintarAnilloGojo(hdc, cx, cy, radioBase) {
    ; Fase basada en tiempo real → independiente del framerate. ~0.7 rad/s.
    fase := Mod(A_TickCount / 1000.0 * 0.7, 6.2831853)

    ; Tres anillos concentricos con fases desfasadas → efecto de ondas
    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    Loop 3 {
        i := A_Index - 1
        ondaFase := fase + i * 2.0944  ; 120° desfase
        radio := radioBase + 4.0 * Sin(ondaFase)
        alpha := Round(60 + 30 * Sin(ondaFase))
        if (alpha < 20)
            alpha := 20
        ; Azul cielo con toque de morado Hollow Purple
        cR := 100 + Round(50 * Sin(ondaFase * 0.7))
        cG := 150
        cB := 240
        argbRing := (alpha << 24) | (cR << 16) | (cG << 8) | cB
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", argbRing, "Float", 1.5, "Int", 2, "Ptr*", &pen)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", pen, "Float", cx - radio, "Float", cy - radio, "Float", radio * 2.0, "Float", radio * 2.0)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

PintarAuraAzul(hdc, cx, cy, radioBase) {
    ; Aura azul brillante con ondas suaves
    fase := Mod(A_TickCount / 1000.0 * 0.8, 6.2831853)

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    Loop 3 {
        i := A_Index - 1
        ondaFase := fase + i * 2.0944
        radio := radioBase + 3.0 * Sin(ondaFase)
        alpha := Round(70 + 40 * Sin(ondaFase))
        if (alpha < 20)
            alpha := 20
        ; Azul brillante
        cR := 0
        cG := 150
        cB := 255
        argbRing := (alpha << 24) | (cR << 16) | (cG << 8) | cB
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", argbRing, "Float", 2.0, "Int", 2, "Ptr*", &pen)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", pen, "Float", cx - radio, "Float", cy - radio, "Float", radio * 2.0, "Float", radio * 2.0)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

PintarAuraRojo(hdc, cx, cy, radioBase) {
    ; Aura rojo brillante con ondas suaves
    fase := Mod(A_TickCount / 1000.0 * 0.8, 6.2831853)

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    Loop 3 {
        i := A_Index - 1
        ondaFase := fase + i * 2.0944
        radio := radioBase + 3.0 * Sin(ondaFase)
        alpha := Round(70 + 40 * Sin(ondaFase))
        if (alpha < 20)
            alpha := 20
        ; Rojo brillante
        cR := 255
        cG := 50
        cB := 50
        argbRing := (alpha << 24) | (cR << 16) | (cG << 8) | cB
        pen := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", argbRing, "Float", 2.0, "Int", 2, "Ptr*", &pen)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", pen, "Float", cx - radio, "Float", cy - radio, "Float", radio * 2.0, "Float", radio * 2.0)
        DllCall("gdiplus\GdipDeletePen", "Ptr", pen)
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

PintarSlashSukunaEnHDC(hdc, w, h, frame) {
    ; ═══════════════════════════════════════════════════════════════════
    ; CORTES SUKUNA — barridos curvos tipo katana en posiciones, ángulos y
    ; curvaturas ALEATORIAS (generadas por GenerarCortesSukunaAleatorios al
    ; inicio de cada secuencia). Curvas bezier rasterizadas como SEGMENTOS DE
    ; LÍNEA continuos (no ellipses dotted, no sparks circulares, no halos en
    ; la punta — eso parecía "explosión"). Solo la trayectoria del filo +
    ; marcas perpendiculares cortas (las cicatrices del corte).
    ; ═══════════════════════════════════════════════════════════════════
    global sukunaCortesActuales
    static MAX_FRAME := 8
    t := (MAX_FRAME - frame + 1) / MAX_FRAME   ; 0.125 → 1.0 (tiempo normalizado)

    cortes := sukunaCortesActuales
    if (!IsObject(cortes) || cortes.Length = 0)
        return
    nCortes := cortes.Length

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    ; Cada corte se rasteriza como segmentos de línea consecutivos a lo largo
    ; de la curva bezier — visualmente continuo, sin "puntitos" tipo explosión.
    Loop nCortes {
        c := cortes[A_Index]
        pasos := 26
        ; Calculamos todos los puntos de la curva una vez
        pts := []
        Loop pasos {
            tc := (A_Index - 1) / (pasos - 1)
            u := 1.0 - tc
            x := u*u*c.sx + 2*u*tc*c.cx + tc*tc*c.ex
            y := u*u*c.sy + 2*u*tc*c.cy + tc*tc*c.ey
            pts.Push({ x: x, y: y, t: tc })
        }

        ; Dibujamos los segmentos solo hasta el progreso t (avance del filo).
        ; Alpha más alto en la PUNTA del barrido (donde el filo está cortando ahora),
        ; degradado hacia la cola. Grosor también afina hacia la cola.
        Loop pasos - 1 {
            p1 := pts[A_Index]
            p2 := pts[A_Index + 1]
            if (p1.t > t)
                break
            distDesdePunta := t - p1.t
            alphaF := 1.0 - distDesdePunta * 1.8
            if (alphaF <= 0)
                continue
            grosorCore := 2.5 - p1.t * 1.3   ; filo más grueso, cola más fina
            ; ── HALO rojo translúcido (filo de sangre) ──
            alphaHalo := Round(255 * alphaF * 0.45)
            if (alphaHalo >= 25) {
                argbHalo := (alphaHalo << 24) | 0xFFFF2A2A
                penHalo := 0
                DllCall("gdiplus\GdipCreatePen1", "UInt", argbHalo, "Float", grosorCore + 2.0, "Int", 2, "Ptr*", &penHalo)
                DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", penHalo,
                    "Float", p1.x, "Float", p1.y, "Float", p2.x, "Float", p2.y)
                DllCall("gdiplus\GdipDeletePen", "Ptr", penHalo)
            }
            ; ── NÚCLEO BLANCO INCANDESCENTE (nitidez del filo) ──
            alphaCore := Round(255 * alphaF)
            argbCore := (alphaCore << 24) | 0xFFFFFFFF
            penCore := 0
            DllCall("gdiplus\GdipCreatePen1", "UInt", argbCore, "Float", grosorCore, "Int", 2, "Ptr*", &penCore)
            DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", penCore,
                "Float", p1.x, "Float", p1.y, "Float", p2.x, "Float", p2.y)
            DllCall("gdiplus\GdipDeletePen", "Ptr", penCore)
        }
    }

    ; ── MARCAS PERPENDICULARES en el trazo (las "cicatrices" que deja el
    ;    katana al morder la superficie) — perpendiculares a la dirección del
    ;    filo en cada punto. La derivada de la bezier da la dirección. ──
    if (frame <= 5 && frame > 0) {
        Loop nCortes {
            c := cortes[A_Index]
            Loop 3 {
                ti := 0.30 + (A_Index - 1) * 0.20
                if (ti > t)
                    continue
                u2 := 1.0 - ti
                mpx := u2*u2*c.sx + 2*u2*ti*c.cx + ti*ti*c.ex
                mpy := u2*u2*c.sy + 2*u2*ti*c.cy + ti*ti*c.ey
                dx := 2*u2*(c.cx - c.sx) + 2*ti*(c.ex - c.cx)
                dy := 2*u2*(c.cy - c.sy) + 2*ti*(c.ey - c.cy)
                lenD := Sqrt(dx*dx + dy*dy)
                if (lenD < 0.01)
                    continue
                px := -dy / lenD
                py := dx / lenD
                marcaLen := 3.0 + frame * 0.4
                alphaMarca := Round(170 * (frame / 5.0))
                if (alphaMarca < 30)
                    continue
                argbMarca := (alphaMarca << 24) | 0xFF1A1A
                penMarca := 0
                DllCall("gdiplus\GdipCreatePen1", "UInt", argbMarca, "Float", 1.0, "Int", 2, "Ptr*", &penMarca)
                DllCall("gdiplus\GdipDrawLine", "Ptr", g, "Ptr", penMarca,
                    "Float", mpx - px * marcaLen, "Float", mpy - py * marcaLen,
                    "Float", mpx + px * marcaLen, "Float", mpy + py * marcaLen)
                DllCall("gdiplus\GdipDeletePen", "Ptr", penMarca)
            }
        }
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

PintarAuraGojoEnHDC(hdc, cx, cy, frame, maxFrame) {
    ; ANIMACION HOLLOW PURPLE de Gojo. La técnica más icónica.
    ; Aka (rojo, atracción) + Aoi (azul, repulsión) chocan → Murasaki (morado).
    ; cx, cy = centro del logo EN COORDENADAS DEL OVERLAY (lo pasa el llamador
    ; según sea GUI principal o mini).
    ;
    ; Fases (frame va de maxFrame=14 → 0):
    ;   Fase 1 (14-11): aparecen Aka y Aoi en lados opuestos del logo
    ;   Fase 2 (10-7):  Aka y Aoi se acercan al centro
    ;   Fase 3 (6-5):   colisionan en el centro → flash blanco
    ;   Fase 4 (4-0):   onda Hollow Purple expande hacia afuera
    static AKA_BGR  := 0x3030FF   ; FF3030 — rojo Aka (Reverse Cursed Technique)
    static AOI_BGR  := 0xFF8030   ; 3080FF — azul Aoi (Cursed Technique)
    static MOR_BGR  := 0xE22B8A   ; 8A2BE2 — morado Hollow Purple
    static WHT_BGR  := 0xFFFFFF
    nullBrush := DllCall("GetStockObject", "Int", 5, "Ptr")

    if (frame >= 11) {
        ; Fase 1: Aka y Aoi aparecen y crecen
        crece := (14 - frame) / 3.0  ; 0 → 1
        radio := Round(3 + crece * 6)  ; 3 → 9
        offsetXMax := 38               ; distancia inicial del centro
        ; Aka a la izquierda
        DibujarBolaSolida(hdc, cx - offsetXMax, cy, radio, AKA_BGR, nullBrush)
        ; Aoi a la derecha
        DibujarBolaSolida(hdc, cx + offsetXMax, cy, radio, AOI_BGR, nullBrush)
    } else if (frame >= 7) {
        ; Fase 2: Aka y Aoi convergen al centro
        avance := (10 - frame) / 3.0  ; 0 → 1
        offset := Round(38 * (1 - avance))  ; 38 → 0
        radio := 9
        DibujarBolaSolida(hdc, cx - offset, cy, radio, AKA_BGR, nullBrush)
        DibujarBolaSolida(hdc, cx + offset, cy, radio, AOI_BGR, nullBrush)
    } else if (frame >= 5) {
        ; Fase 3: colisión → flash blanco grande
        radio := 18 + (6 - frame) * 5  ; 18 → 23
        DibujarBolaSolida(hdc, cx, cy, radio, WHT_BGR, nullBrush)
    } else {
        ; Fase 4: onda Hollow Purple expandiéndose hacia afuera
        avance := (4 - frame) / 4.0   ; 0 → 1
        radio := Round(22 + avance * 50)  ; 22 → 72
        ; Anillo morado con grosor decreciente
        grosor := Max(2, Round(5 * (1 - avance)))
        hPen := DllCall("CreatePen", "Int", 0, "Int", grosor, "UInt", MOR_BGR, "Ptr")
        oldPen := DllCall("SelectObject", "Ptr", hdc, "Ptr", hPen)
        oldBrush := DllCall("SelectObject", "Ptr", hdc, "Ptr", nullBrush)
        DllCall("Ellipse", "Ptr", hdc, "Int", cx - radio, "Int", cy - radio, "Int", cx + radio, "Int", cy + radio)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldPen)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldBrush)
        DllCall("DeleteObject", "Ptr", hPen)
        ; Núcleo morado denso en el centro que se desvanece
        if (frame >= 2) {
            radioCentro := Max(4, 14 - (4 - frame) * 4)
            DibujarBolaSolida(hdc, cx, cy, radioCentro, MOR_BGR, nullBrush)
        }
    }
}

; Helper: dibuja un círculo relleno en (cx,cy) con radio r y color BGR.
DibujarBolaSolida(hdc, cx, cy, r, colorBGR, nullBrush) {
    brush := DllCall("CreateSolidBrush", "UInt", colorBGR, "Ptr")
    oldBrush := DllCall("SelectObject", "Ptr", hdc, "Ptr", brush)
    hPenNul := DllCall("CreatePen", "Int", 5, "Int", 1, "UInt", colorBGR, "Ptr")  ; PS_NULL pen
    oldPen := DllCall("SelectObject", "Ptr", hdc, "Ptr", hPenNul)
    DllCall("Ellipse", "Ptr", hdc, "Int", Round(cx - r), "Int", Round(cy - r), "Int", Round(cx + r), "Int", Round(cy + r))
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldBrush)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldPen)
    DllCall("DeleteObject", "Ptr", brush)
    DllCall("DeleteObject", "Ptr", hPenNul)
}

; ═══════════════════ EXPANSIÓN DE DOMINIO GOJO ═══════════════════
; "Vacío Ilimitado" (無量空処, Muryōkū). El dominio se despliega desde el ∞:
; una esfera de vacío azul-morado cósmico llena la ventana, aparece el símbolo
; del Infinito, estrellas (información infinita) y los anillos de la barrera;
; luego colapsa. Se pinta sobre el overlay topmost (color-key), encima de todo.
PintarDominioGojoEnHDC(hdc, w, h, cx, cy, frame, maxFrame) {
    static stars := ""
    t := (maxFrame - frame) / (maxFrame * 1.0)   ; 0 → 1 (avance)
    radioMax := 430.0
    if (t < 0.30)
        radio := radioMax * (t / 0.30)            ; despliegue
    else if (t > 0.82)
        radio := radioMax * (1 - (t - 0.82) / 0.18)  ; colapso
    else
        radio := radioMax
    if (radio < 2)
        radio := 2
    ; Alpha global del dominio (fade-in / fade-out)
    if (t < 0.12)
        aDom := Round(232 * (t / 0.12))
    else if (t > 0.85)
        aDom := Round(232 * (1 - (t - 0.85) / 0.15))
    else
        aDom := 232
    if (aDom < 1)
        return

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    ; Cuerpo del Vacío: elipses concéntricas (azul profundo → morado Hollow → núcleo)
    DibujarEllipseGdip(g, cx, cy, radio,        (aDom << 24) | 0x0A0A2A)
    DibujarEllipseGdip(g, cx, cy, radio * 0.72, (aDom << 24) | 0x140A33)
    DibujarEllipseGdip(g, cx, cy, radio * 0.45, (aDom << 24) | 0x1A1048)
    DibujarEllipseGdip(g, cx, cy, radio * 0.22, (Round(aDom * 0.92) << 24) | 0x0A0520)

    ; Estrellas (información infinita): posiciones fijas por lanzamiento, titilan.
    if (!IsObject(stars)) {
        stars := []
        Loop 72
            stars.Push({ x: Random(0.0, w * 1.0), y: Random(0.0, h * 1.0), ph: Random(0.0, 6.28), sp: Random(2.0, 6.0), r: Random(0.6, 1.9) })
    }
    fase := A_TickCount / 1000.0
    for s in stars {
        dx := s.x - cx, dy := s.y - cy
        if (dx * dx + dy * dy > radio * radio)
            continue
        tw := 0.5 + 0.5 * Sin(fase * s.sp + s.ph)
        aSt := Round(aDom / 255.0 * (85 + 150 * tw))
        col := (Mod(A_Index, 3) = 0) ? 0x9D7BFF : 0x9CE0FF
        DibujarEllipseGdip(g, s.x, s.y, s.r + tw * 0.6, (aSt << 24) | col)
    }

    ; Anillos de la barrera del dominio, girando lento hacia afuera.
    Loop 3 {
        i := A_Index - 1
        rr := radio * (0.50 + i * 0.17)
        penR := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (Round(aDom * 0.5) << 24) | 0x7B5CFF, "Float", 1.6, "Int", 2, "Ptr*", &penR)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", penR, "Float", cx - rr, "Float", cy - rr, "Float", rr * 2, "Float", rr * 2)
        DllCall("gdiplus\GdipDeletePen", "Ptr", penR)
    }

    ; Símbolo del Infinito (∞) brillante en el centro — dos anillos contiguos.
    if (t > 0.24 && t < 0.86) {
        aInf := Round(aDom * (0.72 + 0.28 * Sin(fase * 3)))
        sep := 11.5, rInf := 8.5
        DibujarEllipseGdip(g, cx - sep, cy, rInf + 3, (Round(aInf * 0.38) << 24) | 0x5DC8FF)
        DibujarEllipseGdip(g, cx + sep, cy, rInf + 3, (Round(aInf * 0.38) << 24) | 0x9D4EDD)
        penL := 0
        DllCall("gdiplus\GdipCreatePen1", "UInt", (aInf << 24) | 0xBFD8FF, "Float", 2.4, "Int", 2, "Ptr*", &penL)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", penL, "Float", cx - sep - rInf, "Float", cy - rInf, "Float", rInf * 2, "Float", rInf * 2)
        DllCall("gdiplus\GdipDrawEllipse", "Ptr", g, "Ptr", penL, "Float", cx + sep - rInf, "Float", cy - rInf, "Float", rInf * 2, "Float", rInf * 2)
        DllCall("gdiplus\GdipDeletePen", "Ptr", penL)
    }

    ; Destello blanco al alcanzar pleno despliegue.
    if (t >= 0.27 && t <= 0.37) {
        aFl := Round(170 * (1 - Abs(t - 0.32) / 0.05))
        if (aFl > 0)
            DibujarEllipseGdip(g, cx, cy, radio, (aFl << 24) | 0xFFFFFF)
    }

    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
}

; Dispara la Expansión de Dominio (solo si el tema Gojo está activo).
LanzarDominioGojo() {
    global temas, temaActual, gojoDominioFrame, presetDecoraciones, optDecoraciones
    if (!presetDecoraciones || !optDecoraciones)
        return
    if (!temas[temaActual].HasProp("unlock") || temas[temaActual].unlock != "gojo")
        return
    if (gojoDominioFrame > 0)
        return   ; ya desplegándose
    gojoDominioFrame := 30
    try ReposicionarOverlayDeco()
    AgregarHistorial(Chr(0x267E) " 領域展開 · 無量空処 — Expansión de Dominio: Vacío Ilimitado", "8A2BE2")
    SetTimer(AnimarDominioGojo, 40)
}

AnimarDominioGojo() {
    global gojoDominioFrame
    if (gojoDominioFrame <= 0) {
        SetTimer(AnimarDominioGojo, 0)
        try InvalidarOverlayDeco()
        return
    }
    gojoDominioFrame -= 1
    try InvalidarOverlayDeco()
}

ReposicionarOverlayDeco() {
    global miGui, overlayDecoraciones
    static BAR_H := 25
    if (!IsObject(overlayDecoraciones))
        return
    miGui.GetPos(&mx, &my, &mw, &mh)
    overlayDecoraciones.GetPos(&ox, &oy, &ow, &oh)
    if (ox != mx || oy != my + BAR_H || ow != mw || oh != mh - BAR_H)
        overlayDecoraciones.Move(mx, my + BAR_H, mw, mh - BAR_H)
}

; WM_MOVE de la ventana principal → pegar los overlays (decoración + partículas)
; a la nueva posición EN VIVO, incluso durante el arrastre (el bucle modal de
; arrastre suspende los timers, así que sin esto los overlays se "congelan").
OnMiGuiMove(wParam, lParam, msg, hwnd) {
    global miGui, overlayDecoraciones, overlayPartMain, modoMini
    static BAR_H := 25
    if (modoMini || !IsObject(miGui) || hwnd != miGui.Hwnd)
        return
    try {
        miGui.GetPos(&mx, &my, &mw, &mh)
        if (IsObject(overlayDecoraciones))
            overlayDecoraciones.Move(mx, my + BAR_H, mw, mh - BAR_H)
        if (IsObject(overlayPartMain))
            overlayPartMain.Move(mx, my + BAR_H, mw, mh - BAR_H)
    }
}

InvalidarOverlayDeco() {
    global overlayDecoraciones, overlayDecoMini, modoMini
    if (IsObject(overlayDecoraciones))
        DllCall("InvalidateRect", "Ptr", overlayDecoraciones.Hwnd, "Ptr", 0, "Int", 1)
    if (modoMini && IsObject(overlayDecoMini))
        DllCall("InvalidateRect", "Ptr", overlayDecoMini.Hwnd, "Ptr", 0, "Int", 1)
}

; ── SUKUNA: cortes diagonales rojos al detectar ──
LanzarSlashSukuna() {
    global temas, temaActual, sukunaSlashFrame, presetDecoraciones, optDecoraciones
    if (!presetDecoraciones || !optDecoraciones)
        return
    if (!temas[temaActual].HasProp("unlock") || temas[temaActual].unlock != "sukuna")
        return
    GenerarCortesSukunaAleatorios()   ; ★ posiciones aleatorias nuevas cada secuencia
    sukunaSlashFrame := 8     ; +frames = animación más fluida y vistosa
    ReposicionarOverlayDeco()
    SetTimer(AnimarSlashSukuna, 30)
}

; Genera 3-5 cortes con ángulos, posiciones y curvaturas ALEATORIAS que cruzan
; todo el GUI. Se guarda en sukunaCortesActuales y se reutiliza durante todos
; los frames de la secuencia (si se regenerara cada frame, saltarían caóticos).
GenerarCortesSukunaAleatorios() {
    global sukunaCortesActuales, overlayDecoraciones, overlayDecoMini, modoMini
    ; Usar el overlay ACTIVO (mini si está minimizado, principal si no).
    ; Si generáramos con las dimensiones del principal pero pintáramos en el
    ; mini, los cortes saldrían fuera de pantalla.
    overlayAct := (modoMini && IsObject(overlayDecoMini)) ? overlayDecoMini : overlayDecoraciones
    w := 400.0, h := 215.0
    if (IsObject(overlayAct)) {
        try {
            overlayAct.GetPos(,, &ow, &oh)
            if (ow > 0)
                w := ow + 0.0
            if (oh > 0)
                h := oh + 0.0
        }
    }
    cx := w / 2.0
    cy := h / 2.0
    diag := Sqrt(w*w + h*h)        ; longitud para garantizar cruce total
    n := Random(3, 5)               ; cantidad aleatoria de cortes
    cortes := []
    Loop n {
        ; Ángulo del corte: cualquier diagonal (evita exactamente vertical/horizontal puro)
        ang := Random(0.0, 6.2831853)
        dirX := Cos(ang)
        dirY := Sin(ang)
        ; Punto por el que pasa el corte: cerca del centro pero desplazado al azar
        offX := Random(-w * 0.32, w * 0.32)
        offY := Random(-h * 0.32, h * 0.32)
        midX := cx + offX
        midY := cy + offY
        ; Extremos: bien fuera del GUI en ambos sentidos
        sx := midX - dirX * diag
        sy := midY - dirY * diag
        ex := midX + dirX * diag
        ey := midY + dirY * diag
        ; Curvatura aleatoria: el control point se desvía perpendicular al corte
        perpX := -dirY
        perpY := dirX
        curva := Random(-1.0, 1.0) * (diag * 0.10)   ; ±10% de curva (sutil, tipo katana)
        ctrlX := midX + perpX * curva
        ctrlY := midY + perpY * curva
        cortes.Push({ sx: sx, sy: sy, ex: ex, ey: ey, cx: ctrlX, cy: ctrlY })
    }
    sukunaCortesActuales := cortes
}

; Auto-Desmantelamiento (解): se llama cada 4s desde el timer global.
; Solo dispara LanzarSlashSukuna si el tema actual ES Sukuna. Chequeo
; rapidísimo (1 lookup + 1 compare) → coste cero para otros temas.
SukunaAutoDismantle() {
    global temas, temaActual, sukunaSlashFrame
    if (!temas[temaActual].HasProp("unlock") || temas[temaActual].unlock != "sukuna")
        return
    if (sukunaSlashFrame > 0)
        return  ; no encadenar si una secuencia sigue en marcha
    LanzarSlashSukuna()
}

AnimarSlashSukuna() {
    global sukunaSlashFrame
    if (sukunaSlashFrame <= 0) {
        SetTimer(AnimarSlashSukuna, 0)
        InvalidarOverlayDeco()
        return
    }
    sukunaSlashFrame -= 1
    InvalidarOverlayDeco()
}

; ── GOJO: Hollow Purple cada 4s — Aka + Aoi convergen y explotan en morado ──
TickAuraGojo() {
    global temas, temaActual, gojoAuraFrame, presetDecoraciones, optDecoraciones
    if (!presetDecoraciones || !optDecoraciones)
        return
    if (!temas[temaActual].HasProp("unlock") || temas[temaActual].unlock != "gojo")
        return
    if (gojoAuraFrame > 0)
        return  ; secuencia anterior aún en marcha
    gojoAuraFrame := 14   ; 4 fases × ~3-4 frames cada una
    ReposicionarOverlayDeco()
    SetTimer(AnimarAuraGojo, 50)
}

; Tick a 20fps que refresca el overlay de decoraciones cuando el tema actual
; es Gojo o Sukuna — anima las decoraciones permanentes (Six Eyes orbitando,
; marcas con pulso, kanji respirando, anillos del Infinito).
TickDecoracionesPermanentes() {
    global temas, temaActual, presetDecoraciones, optDecoraciones
    global overlayDecoraciones, overlayDecoMini, modoMini
    if (!presetDecoraciones || !optDecoraciones)
        return
    if (!temas[temaActual].HasProp("unlock"))
        return
    unlock := temas[temaActual].unlock
    if (unlock != "gojo" && unlock != "sukuna")
        return
    ; Invalidar el overlay ACTIVO (mini si está minimizado, principal si no).
    if (modoMini) {
        if (IsObject(overlayDecoMini))
            DllCall("InvalidateRect", "Ptr", overlayDecoMini.Hwnd, "Ptr", 0, "Int", 1)
    } else if (IsObject(overlayDecoraciones)) {
        ReposicionarOverlayDeco()  ; asegura posición (el GUI pudo moverse)
        DllCall("InvalidateRect", "Ptr", overlayDecoraciones.Hwnd, "Ptr", 0, "Int", 1)
    }
}

AnimarAuraGojo() {
    global gojoAuraFrame
    if (gojoAuraFrame <= 0) {
        SetTimer(AnimarAuraGojo, 0)
        InvalidarOverlayDeco()
        return
    }
    gojoAuraFrame -= 1
    InvalidarOverlayDeco()
}

; Flash de sangre brillante en la barra — efecto único del tema SUKUNA al completar secuencia.
; Representa el corte de Cleave: sangre saltando tras una victoria.
BarraFlashFuga() {
    global colorBarra, colorBarraOverride, rgbBarra
    if (rgbBarra)
        return
    colorSangre := "FF3030"  ; rojo brillante (sangre fresca)
    pasos := 10
    loop pasos {
        t := A_Index / pasos
        colorBarraOverride := InterpolarHex(colorBarra, colorSangre, t)
        Sleep(20)
    }
    loop pasos {
        t := A_Index / pasos
        colorBarraOverride := InterpolarHex(colorSangre, colorBarra, t)
        Sleep(20)
    }
    colorBarraOverride := ""
}

; Pulso morado Hollow Purple en el timer — efecto único del tema GOJO.
; Cada 4 segundos parpadea sutil, representando el Infinito latente.
GojoPulsoHollowPurple() {
    global temas, temaActual, timerLabel, colorTextoPrincipal, presetDecoraciones
    if (!presetDecoraciones)
        return  ; preset Eco — sin pulso
    if !IsObject(timerLabel)
        return
    if (!temas[temaActual].HasProp("unlock") || temas[temaActual].unlock != "gojo")
        return  ; solo si el tema activo es Gojo
    c := colorTextoPrincipal
    timerLabel.Opt("c8A2BE2")  ; Hollow Purple
    DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)
    SetTimer(() => (timerLabel.Opt("c" c), DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)), -300)
}

BarraFlashError() {
    global colorBarra, colorBarraOverride, rgbBarra
    if (rgbBarra)
        return
    colorError := "CC2222"
    pasos := 8
    loop pasos {
        t := A_Index / pasos
        colorBarraOverride := InterpolarHex(colorBarra, colorError, t)
        Sleep(18)
    }
    loop pasos {
        t := A_Index / pasos
        colorBarraOverride := InterpolarHex(colorError, colorBarra, t)
        Sleep(18)
    }
    colorBarraOverride := ""
}

; Shimmer de barra al iniciar/parar — barrido rápido de brillo
BarraShimmer(colorBase) {
    global rgbBarra, rgbActivo, barraExtraBrillo
    if (rgbBarra || rgbActivo)
        return
    pasos := 10
    loop pasos {
        barraExtraBrillo := Round(85 * (A_Index / pasos))
        Sleep(12)
    }
    loop pasos {
        barraExtraBrillo := Round(85 * (1 - A_Index / pasos))
        Sleep(12)
    }
    barraExtraBrillo := 0
}

; ===== TIMER =====
IniciarTimer(*) {
    global tiempoInicio, timerActivo, avisoMostrado, horaInicioSesion
    if (timerActivo)
        return
    horaInicioSesion := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    tiempoInicio := A_TickCount
    timerActivo := true
    SetTimer(ActualizarTimer, 1000)
    if (!avisoMostrado) {
        avisoMostrado := true
        SetTimer(ActualizarAFK, 100)
    }
}

PararTimer(*) {
    global tiempoInicio, tiempoAcumulado, timerActivo
    if (!timerActivo)
        return
    tiempoAcumulado += (A_TickCount - tiempoInicio)
    timerActivo := false
    SetTimer(ActualizarTimer, 0)
    SetTimer(ActualizarAFK, 0)
}

ActualizarTimer(*) {
    global tiempoInicio, tiempoAcumulado, timerActivo, timerLabel
    total := tiempoAcumulado
    if (timerActivo)
        total += (A_TickCount - tiempoInicio)
    minutos := Floor(total / 60000)
    segundos := Floor(total / 1000) - (minutos * 60)
    timerLabel.Value := Chr(0x23F0) " " Format("{:02}:{:02}", minutos, segundos)
}

ArrastrarHistorial(*) {
    PostMessage(0xA1, 2,,, "A")
}

; ===== HISTORIAL =====
ObtenerColorHistorial() {
    global histColorIndex, colorHist1, colorHist2, colorHist3
    histColorIndex += 1
    if (histColorIndex > 3)
        histColorIndex := 1
    if (histColorIndex = 1)
        return colorHist1
    else if (histColorIndex = 2)
        return colorHist2
    else
        return colorHist3
}

ObtenerColorCategoria(categoria) {
    global temas, temaActual
    tema := temas[temaActual]
    switch categoria {
        case 1: return tema.histColor1
        case 2: return tema.histColor2
        case 3: return tema.histColor3
        case 4: return tema.texto
        case 5: return tema.luzAccion
        case 6: return tema.afk
    }
    return tema.histColor1
}

; Variables globales para acumulación del historial
global histUltimoTexto := "", histUltimoCount := 0, histUltimoLongLinea := 0

; Escribe cada entrada del historial a un archivo de log persistente.
; Sirve para investigar despues si algo raro pasa (ej. Brawlhalla cerrado misteriosamente).
; Rota automaticamente a .old si pasa de 5MB.
GuardarHistorialLog(texto) {
    global historialLogPath
    static contadorRotacion := 0

    contadorRotacion += 1
    if (contadorRotacion >= 500) {
        contadorRotacion := 0
        try {
            if (FileExist(historialLogPath)) {
                size := FileGetSize(historialLogPath)
                if (size > 5 * 1024 * 1024) {  ; 5 MB
                    oldPath := historialLogPath ".old"
                    try FileDelete(oldPath)
                    try FileMove(historialLogPath, oldPath)
                }
            }
        }
    }

    try {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        FileAppend("[" timestamp "] " texto "`r`n", historialLogPath, "UTF-8")
    }
}

AgregarHistorial(texto, CH := "") {
    global historialBox, histUltimoTexto, histUltimoCount, histUltimoLongLinea
    global contadorAcciones, histFlashStep
    global modoMini, miniHistLabel, miniHistBuffer
    local hora := FormatTime(A_Now, "HH:mm:ss")
    local colorHex := (CH != "" ? CH : ObtenerColorHistorial())

    ; Guardar SIEMPRE en archivo de log persistente (con fecha completa)
    ; Asi se puede revisar despues que paso si Brawlhalla se cerro misteriosamente.
    GuardarHistorialLog(texto)

    ; Limitar historial a ~5000 líneas para evitar que el RichEdit colapse
    ; tras muchas horas de uso. Cada ~500 entradas comprobamos y recortamos.
    static contadorAddes := 0
    contadorAddes += 1
    if (contadorAddes >= 500) {
        contadorAddes := 0
        try {
            static EM_GETLINECOUNT := 0x00BA
            totalLines := SendMessage(EM_GETLINECOUNT, 0, 0, , "ahk_id " historialBox.Hwnd)
            if (totalLines > 5000) {
                ; Borrar las líneas más antiguas (del final) dejando las 4000 más recientes
                static EM_LINEINDEX := 0x00BB
                static EM_SETSEL := 0x00B1
                static EM_REPLACESEL := 0x00C2
                cutFromLine := 4000
                cutIdx := SendMessage(EM_LINEINDEX, cutFromLine, 0, , "ahk_id " historialBox.Hwnd)
                totalLen := SendMessage(0x000E, 0, 0, , "ahk_id " historialBox.Hwnd)  ; WM_GETTEXTLENGTH
                if (cutIdx > 0 && cutIdx < totalLen) {
                    SendMessage(EM_SETSEL, cutIdx, totalLen, , "ahk_id " historialBox.Hwnd)
                    SendMessage(EM_REPLACESEL, 0, StrPtr(""), , "ahk_id " historialBox.Hwnd)
                }
            }
        }
    }

    if (texto = histUltimoTexto && histUltimoCount < 5) {
        ; Mismo paso: incrementar y reemplazar la primera línea (posición 0)
        histUltimoCount += 1
        local sufijo := " (x" histUltimoCount ")"
        local lineaNueva := "[" hora "] " texto sufijo "`r`n"
        ReemplazarPrimeraLineaRich(historialBox.Hwnd, lineaNueva, histUltimoLongLinea, colorHex)
        histUltimoLongLinea := StrLen(lineaNueva)
    } else {
        ; Paso nuevo: insertar al principio normalmente
        histUltimoTexto     := texto
        histUltimoCount     := 1
        local linea         := "[" hora "] " texto "`r`n"
        histUltimoLongLinea := StrLen(linea)
        IniciarTypingReveal(historialBox.Hwnd, linea, colorHex)
        ; Contador de acciones en vivo + flash de barra
        contadorAcciones += 1
        ActualizarContadorAcciones()
        histFlashStep := 5
        SetTimer(FlashBarraHistorial, -1)
    }
}

ReemplazarPrimeraLineaRich(hRich, textoNuevo, longAnterior, hexColor) {
    static EM_SETSEL        := 0x00B1
    static EM_REPLACESEL    := 0x00C2
    static EM_SETCHARFORMAT := 0x0444
    static WM_VSCROLL       := 0x0115
    static SB_TOP           := 6
    static SCF_SELECTION    := 0x0001
    static CFM_COLOR        := 0x40000000
    static EM_GETFIRSTVISIBLELINE := 0x00CE
    static EM_LINESCROLL    := 0x00B6

    ; ¿Dónde estaba el usuario ANTES de tocar el texto? Si está leyendo abajo,
    ; no hay que devolverlo al tope (cada "(xN)" lo hacía → scrollbar "rota").
    local firstVisAntes := SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, , "ahk_id " hRich)

    ; La entrada más reciente siempre está en posición 0
    SendMessage(EM_SETSEL, 0, longAnterior, , "ahk_id " hRich)
    SendMessage(EM_REPLACESEL, 0, StrPtr(textoNuevo), , "ahk_id " hRich)

    ; Aplicar color
    local newLen := StrLen(textoNuevo)
    SendMessage(EM_SETSEL, 0, newLen, , "ahk_id " hRich)
    cf := Buffer(60, 0)
    NumPut("UInt", 60,                 cf, 0)
    NumPut("UInt", CFM_COLOR,          cf, 4)
    NumPut("UInt", 0,                  cf, 8)
    NumPut("UInt", HexToBGR(hexColor), cf, 20)
    SendMessage(EM_SETCHARFORMAT, SCF_SELECTION, cf.Ptr, , "ahk_id " hRich)
    SendMessage(EM_SETSEL, 0, 0, , "ahk_id " hRich)
    global ultimoScrollManual
    if (firstVisAntes = 0 || (A_TickCount - ultimoScrollManual) >= 10000) {
        ; Estaba arriba (o ya dejó de leer hace 10s+) → al tope: lo nuevo SIEMPRE arriba
        SendMessage(WM_VSCROLL, SB_TOP, 0, , "ahk_id " hRich)
    } else {
        ; Está leyendo abajo (rueda hace <10s) → devolverlo exactamente a su línea
        local firstVisAhora := SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, , "ahk_id " hRich)
        if (firstVisAntes != firstVisAhora)
            SendMessage(EM_LINESCROLL, 0, firstVisAntes - firstVisAhora, , "ahk_id " hRich)
    }
}

AppendRichText(hRich, texto, hexColor) {
    static EM_SETSEL        := 0x00B1
    static EM_REPLACESEL    := 0x00C2
    static EM_SETCHARFORMAT := 0x0444
    static EM_GETSCROLLPOS  := 0x04DD
    static EM_SETSCROLLPOS  := 0x04DE
    static WM_VSCROLL       := 0x0115
    static SB_TOP           := 6
    static SCF_SELECTION    := 0x0001
    static CFM_COLOR        := 0x40000000

    ; Capturar posición Y actual ANTES de insertar
    ptBuf := Buffer(8, 0)
    SendMessage(EM_GETSCROLLPOS, 0, ptBuf.Ptr, , "ahk_id " hRich)
    scrollYAntes := NumGet(ptBuf, 4, "Int")

    SendMessage(EM_SETSEL, 0, 0, , "ahk_id " hRich)
    SendMessage(EM_REPLACESEL, 0, StrPtr(texto), , "ahk_id " hRich)
    textLen := StrLen(texto)
    SendMessage(EM_SETSEL, 0, textLen, , "ahk_id " hRich)
    cf := Buffer(60, 0)
    NumPut("UInt", 60, cf, 0)
    NumPut("UInt", CFM_COLOR, cf, 4)
    NumPut("UInt", 0, cf, 8)
    NumPut("UInt", HexToBGR(hexColor), cf, 20)
    SendMessage(EM_SETCHARFORMAT, SCF_SELECTION, cf.Ptr, , "ahk_id " hRich)
    SendMessage(EM_SETSEL, 0, 0, , "ahk_id " hRich)

    ; Scroll animado: deslizar desde scrollYAntes hasta 0 en ~10 pasos
    if (scrollYAntes > 2) {
        pasos := 10
        loop pasos {
            t  := A_Index / pasos
            te := 1 - (1 - t) ** 3          ; ease-out cúbico
            y  := Round(scrollYAntes * (1 - te))
            ptAnim := Buffer(8, 0)
            NumPut("Int", 0, ptAnim, 0)
            NumPut("Int", y, ptAnim, 4)
            SendMessage(EM_SETSCROLLPOS, 0, ptAnim.Ptr, , "ahk_id " hRich)
            Sleep(12)
        }
    }
    ; Garantizar que llega exactamente a 0
    ptFinal := Buffer(8, 0)
    NumPut("Int", 0, ptFinal, 0)
    NumPut("Int", 0, ptFinal, 4)
    SendMessage(EM_SETSCROLLPOS, 0, ptFinal.Ptr, , "ahk_id " hRich)
    ; El RichEdit re-muestra su scrollbar nativa al cambiar contenido — re-ocultarla
    DllCall("ShowScrollBar", "Ptr", hRich, "Int", 1, "Int", 0)
}

HexToBGR(hex) {
    hex := RegExReplace(hex, "^#")
    if (StrLen(hex) != 6)
        return 0x000000
    r := Integer("0x" SubStr(hex, 1, 2))
    g := Integer("0x" SubStr(hex, 3, 2))
    b := Integer("0x" SubStr(hex, 5, 2))
    return (b << 16) | (g << 8) | r
}

; ===== COOLDOWNS =====
; Visor de detección EN VIVO: muestra qué pasos busca y cuáles están en cooldown.
ActualizarCooldowns(*) {
    global pasosPrioridad, pasosNormales, cooldownText, activo

    if (!activo) {
        out := "Detenido — pulsa Iniciar"
        if (cooldownText.Value != out)
            cooldownText.Value := out
        return
    }

    enEspera := ""
    restanteGlobal := BloqueoGlobalRestante()
    if (restanteGlobal > 0)
        enEspera .= "  " Chr(0x1F512) " GLOBAL  " Round(restanteGlobal / 1000, 1) "s`n"
    for paso in pasosPrioridad {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0
        if (!PasoActivoEnPerfil(paso) || !paso.HasProp("cooldown"))
            continue
        restante := paso.cooldown - (A_TickCount - paso.lastUsed)
        if (restante > 0)
            enEspera .= "  " paso.nombre "  " Round(restante / 1000, 1) "s`n"
    }
    for paso in pasosNormales {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0
        if (!PasoActivoEnPerfil(paso) || !paso.HasProp("cooldown"))
            continue
        restante := paso.cooldown - (A_TickCount - paso.lastUsed)
        if (restante > 0)
            enEspera .= "  " paso.nombre "  " Round(restante / 1000, 1) "s`n"
    }
    out := (enEspera != "") ? Chr(0x23F3) " En cooldown:`n" enEspera : "Sin cooldowns activos"
    if (cooldownText.Value != out)
        cooldownText.Value := out
}

ActualizarAFK(*) {
    global ultimoCambio, afkText, colorAFK, rgbActivo, modoDestruccion
    global timerLabel, colorTextoPrincipal, afkAlertaFlash, perfilActivo, enDescanso
    ; En modo frt y dstv no hay anti-AFK ni modo destruccion
    if (PerfilSinGestion())
        return
    ; Durante el descanso del ciclo NO se arma el modo destrucción ni el anti-AFK
    ; (el contador lleva parado a propósito desde el Alt+F4) — solo mostrar cuánto falta.
    if (enDescanso) {
        texto := Chr(0x1F4A4) " " TextoDormir()
        if (afkText.Value != texto)
            afkText.Value := texto
        if (!rgbActivo)
            afkText.Opt("c" colorAFK)
        return
    }
    tiempo := A_TickCount - ultimoCambio
    restante := 360000 - tiempo

    ; Activar Modo Destruccion cuando el contador llega a 0
    if (restante <= 0 && !modoDestruccion) {
        modoDestruccion := true
        ResetStreak()
        AgregarHistorial("⚠️ MODO DESTRUCCION ACTIVADO", "FF4444")
        EnviarWebhookEvento("destruccion")
    }

    if (modoDestruccion) {
        ; Mostrar cuenta atras del minuto extra antes de Alt+F4
        restanteDestru := 420000 - tiempo
        if (restanteDestru < 0)
            restanteDestru := 0
        segsDestru := Round(restanteDestru / 1000, 1)
        texto := "MODO DESTRUCCION en: " segsDestru "s"
        if (afkText.Value != texto)
            afkText.Value := texto
        if (!rgbActivo)
            afkText.Opt("cFF0000")
        return
    }

    if (restante < 0)
        restante := 0
    segundos := Round(restante / 1000, 1)
    texto := "Anti AFK en: " segundos "s"
    ; "dormir: Xh" compacto al lado del contador anti-AFK
    dormir := TextoDormir()
    if (dormir != "")
        texto .= "  " Chr(0x1F4A4) " " dormir
    if (afkText.Value != texto)
        afkText.Value := texto
    if (rgbActivo)
        return

    ; Escalada de color: 4 niveles según urgencia
    if (segundos < 15) {
        ; Parpadeo crítico — alterna rojo/naranja
        afkAlertaFlash := !afkAlertaFlash
        if (afkAlertaFlash) {
            afkText.Opt("cFF1100")
            timerLabel.Opt("cFF2200")
        } else {
            afkText.Opt("cFF6600")
            timerLabel.Opt("c" colorTextoPrincipal)
        }
        DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)
    } else if (segundos < 30) {
        afkText.Opt("cFF3300")
        timerLabel.Opt("cFF6600")
        DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)
    } else if (segundos < 60) {
        afkText.Opt("cEE8800")
        timerLabel.Opt("c" colorTextoPrincipal)
        DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)
    } else {
        afkText.Opt("c" colorAFK)
        timerLabel.Opt("c" colorTextoPrincipal)
        DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)
    }
}

ActualizarSecuencias(*) {
    global contadorSecuencias, secuenciasLabel
    oroSes := Round(contadorSecuencias * OroPorSecuencia())
    secuenciasLabel.Value := Chr(0x276E) "  Secuencias: " contadorSecuencias "  •  ~" FormatearMiles(oroSes) " " Chr(0x1FA99) "  " Chr(0x276F)
    VerificarMilestone(contadorSecuencias)
}

ActualizarDestrucciones(*) {
    global contadorDestruccion, destruccionesLabel
    if (!IsObject(destruccionesLabel))
        return
    destruccionesLabel.Value := Chr(0x276E) "  Destrucciones: " contadorDestruccion "  " Chr(0x276F)
}

; Devuelve true si el paso debe ejecutarse en el perfil activo.
; Convención:
;   - paso.tct:true → 🌐 tct (publico, perfilActivo=1)
;   - paso.sp:true  → 🔒 sp  (privado, perfilActivo=2)
;   - paso.frt:true → ⚔ frt  (spam mode, perfilActivo=3)
;   - sin marcar    → comun, vale para tct y sp (NO para frt — frt es modo spam puro)
; Retrocompat: p1/p2 funcionan como alias de tct/sp.
PasoActivoEnPerfil(paso) {
    global perfilActivo
    tieneTct := (paso.HasProp("tct") && paso.tct) || (paso.HasProp("p1") && paso.p1)
    tieneSp  := (paso.HasProp("sp")  && paso.sp)  || (paso.HasProp("p2") && paso.p2)
    tieneFrt  := paso.HasProp("frt") && paso.frt
    tieneDstv := paso.HasProp("dstv") && paso.dstv
    ; Paso sin marcar = común a tct/sp pero NO a frt ni a dstv
    if (!tieneTct && !tieneSp && !tieneFrt && !tieneDstv)
        return (perfilActivo = 1 || perfilActivo = 2)
    if (perfilActivo = 1)
        return tieneTct
    if (perfilActivo = 2)
        return tieneSp
    if (perfilActivo = 3)
        return tieneFrt
    if (perfilActivo = 4)
        return tieneDstv
    return false
}

BuscarPixel(paso, &x, &y) {
    global scaleX, scaleY
    x1 := Round(paso.x1 * scaleX)
    y1 := Round(paso.y1 * scaleY)
    x2 := Round(paso.x2 * scaleX)
    y2 := Round(paso.y2 * scaleY)
    x := ""
    y := ""
    ; PixelSearch lee la pantalla vía un DC del escritorio. Si la pantalla no está
    ; disponible un instante (bloqueo de sesión, salvapantallas, escritorio seguro
    ; de UAC, RDP, suspensión) lanza "(6) Controlador no válido". Antes ese error
    ; se propagaba y floodeaba el log; ahora se traga y se trata como "no detectado"
    ; — el siguiente tick reintenta cuando la pantalla vuelve.
    try {
        if PixelSearch(&foundX, &foundY, x1, y1, x2, y2, paso.color, paso.tolerancia) {
            x := foundX
            y := foundY
            return true
        }
    }
    return false
}

; ╔══════════════════════════════════════════════════════════════════════════╗
; ║  DETECTOR CIRCULAR (perfil dstv)                                          ║
; ║  100 cruces repartidas en círculo (radio configurable). Cada cruz se      ║
; ║  muestrea como un cuadrado 3×3 = 9 píxeles (centro + 8 vecinos):          ║
; ║       X X X                                                               ║
; ║       X X X                                                               ║
; ║       X X X                                                               ║
; ║  Basta detectar 1 píxel del color buscado en cualquiera de las 100        ║
; ║  cruces para ENGANCHARSE; al hacerlo guarda los 9 colores del cuadrado    ║
; ║  3×3 como "foto" de referencia. Después vigila ese 3×3 y, en cuanto UN    ║
; ║  solo píxel cambia de color respecto a la foto (dentro de                 ║
; ║  paso.tolerancia), dispara {Space} de inmediato.                          ║
; ║                                                                           ║
; ║  Para que esto sea viable a alta frecuencia, NO se hacen 900              ║
; ║  PixelGetColor por frame: se captura la región que cubre el círculo       ║
; ║  completo UNA sola vez (BitBlt+GetDIBits a un buffer en memoria) y los    ║
; ║  900 píxeles se leen de ahí (simples lecturas de memoria, ~instantáneo).  ║
; ╚══════════════════════════════════════════════════════════════════════════╝

; Genera (o regenera si cambian paso/escala/resolución) las posiciones de las
; cruces sobre la circunferencia y dimensiona el buffer de captura para que
; cubra el círculo completo + 1px de margen para los brazos de cada cruz.
PrepararCirculoDetector(paso) {
    global scaleX, scaleY, circuloPuntos, circuloPuntosOrigen, circuloLockIdx
    global circuloBufW, circuloBufH, circuloBufOX, circuloBufOY

    offsetY := paso.HasProp("circuloOffsetY") ? paso.circuloOffsetY : 0
    offsetX := paso.HasProp("circuloOffsetX") ? paso.circuloOffsetX : 0

    clave := paso.nombre "|" paso.x1 "," paso.y1 "," paso.x2 "," paso.y2
        . "|" paso.circuloRadio "|" paso.circuloCantidad
        . "|" offsetX "," offsetY
        . "|" Round(scaleX, 4) "|" Round(scaleY, 4)
    if (circuloPuntosOrigen = clave)
        return

    ; El offset se aplica en píxeles de pantalla YA escalados (no en unidades
    ; base) — así "bajar 8px" mueve el círculo 8px reales en TU pantalla,
    ; sin importar la resolución/escala.
    cx := (paso.x1 + paso.x2) / 2 * scaleX + offsetX
    cy := (paso.y1 + paso.y2) / 2 * scaleY + offsetY
    radioX := paso.circuloRadio * scaleX
    radioY := paso.circuloRadio * scaleY
    cantidad := paso.circuloCantidad

    circuloPuntos := []
    Loop cantidad {
        ang := (A_Index - 1) * (2 * 3.14159 / cantidad)
        circuloPuntos.Push({ x: Round(cx + radioX * Cos(ang)), y: Round(cy + radioY * Sin(ang)) })
    }

    minX := circuloPuntos[1].x, maxX := circuloPuntos[1].x
    minY := circuloPuntos[1].y, maxY := circuloPuntos[1].y
    for p in circuloPuntos {
        minX := Min(minX, p.x), maxX := Max(maxX, p.x)
        minY := Min(minY, p.y), maxY := Max(maxY, p.y)
    }
    ; Margen = distancia de los brazos (escalada) a cada lado, para que los
    ; brazos arriba/abajo/izq/der quepan dentro del buffer capturado.
    margenX := Max(1, Round(scaleX))
    margenY := Max(1, Round(scaleY))
    circuloBufOX := minX - margenX
    circuloBufOY := minY - margenY
    circuloBufW := (maxX - minX) + 2 * margenX + 1
    circuloBufH := (maxY - minY) + 2 * margenY + 1

    PrepararBufferGDI(circuloBufW, circuloBufH)
    circuloPuntosOrigen := clave
    circuloLockIdx := 0
}

; Crea (o recrea si cambia el tamaño) los recursos GDI reutilizables: se piden
; UNA vez y se reusan en cada frame — pedirlos/soltarlos cada tick sería
; demasiado costoso para correr a 60fps.
PrepararBufferGDI(w, h) {
    global circuloHDCMem, circuloHBMP, circuloHBMPOld, circuloHDCScreen, circuloBuf

    if (circuloHDCMem && circuloBuf && circuloBuf.Size = w * h * 4)
        return

    LiberarBufferGDI()

    circuloHDCScreen := DllCall("GetDC", "Ptr", 0, "Ptr")
    circuloHDCMem    := DllCall("CreateCompatibleDC", "Ptr", circuloHDCScreen, "Ptr")
    circuloHBMP      := DllCall("CreateCompatibleBitmap", "Ptr", circuloHDCScreen, "Int", w, "Int", h, "Ptr")
    circuloHBMPOld   := DllCall("SelectObject", "Ptr", circuloHDCMem, "Ptr", circuloHBMP, "Ptr")
    circuloBuf := Buffer(w * h * 4, 0)
}

LiberarBufferGDI() {
    global circuloHDCMem, circuloHBMP, circuloHBMPOld, circuloHDCScreen
    if (circuloHDCMem && circuloHBMPOld) {
        ; Restaurar el bitmap original del DC antes de borrar — si no, DeleteObject
        ; sobre un bitmap todavía seleccionado puede fallar o dejar el handle filtrado.
        DllCall("SelectObject", "Ptr", circuloHDCMem, "Ptr", circuloHBMPOld)
        circuloHBMPOld := 0
    }
    if circuloHBMP {
        DllCall("DeleteObject", "Ptr", circuloHBMP)
        circuloHBMP := 0
    }
    if circuloHDCMem {
        DllCall("DeleteDC", "Ptr", circuloHDCMem)
        circuloHDCMem := 0
    }
    if circuloHDCScreen {
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", circuloHDCScreen)
        circuloHDCScreen := 0
    }
}

; Captura la región (sx,sy)-(sx+w,sy+h) de pantalla a un buffer en memoria
; (32bpp BGRA, filas top-down) reutilizando los handles GDI ya preparados.
CapturarCirculo(sx, sy, w, h) {
    global circuloHDCMem, circuloHDCScreen, circuloHBMP, circuloBuf

    DllCall("BitBlt"
        , "Ptr", circuloHDCMem, "Int", 0, "Int", 0, "Int", w, "Int", h
        , "Ptr", circuloHDCScreen, "Int", sx, "Int", sy
        , "UInt", 0x00CC0020)  ; SRCCOPY

    bmi := Buffer(40, 0)
    NumPut("UInt",   40, bmi,  0)   ; biSize
    NumPut("Int",     w, bmi,  4)   ; biWidth
    NumPut("Int",   -h, bmi,  8)   ; biHeight negativo = filas en orden top-down
    NumPut("UShort",  1, bmi, 12)   ; biPlanes
    NumPut("UShort", 32, bmi, 14)   ; biBitCount = 32bpp BGRA
    NumPut("UInt",    0, bmi, 16)   ; biCompression = BI_RGB

    DllCall("GetDIBits"
        , "Ptr", circuloHDCMem, "Ptr", circuloHBMP
        , "UInt", 0, "UInt", h
        , "Ptr", circuloBuf, "Ptr", bmi, "UInt", 0)
}

; Lee un color 0xRRGGBB del buffer capturado, en coordenadas LOCALES (relativas
; a la esquina superior-izquierda de la región capturada).
PixelDelCirculo(bx, by) {
    global circuloBuf, circuloBufW, circuloBufH
    if (bx < 0 || by < 0 || bx >= circuloBufW || by >= circuloBufH)
        return -1
    off := (by * circuloBufW + bx) * 4
    b := NumGet(circuloBuf, off,     "UChar")
    g := NumGet(circuloBuf, off + 1, "UChar")
    r := NumGet(circuloBuf, off + 2, "UChar")
    return (r << 16) | (g << 8) | b
}

; ¿c1 (o -1 si fuera de rango) está dentro de "tol" de c2 en los 3 canales?
ColorEnTolerancia(c1, c2, tol) {
    if (c1 = -1)
        return false
    return Abs(((c1 >> 16) & 0xFF) - ((c2 >> 16) & 0xFF)) <= tol
        && Abs(((c1 >> 8)  & 0xFF) - ((c2 >> 8)  & 0xFF)) <= tol
        && Abs(( c1        & 0xFF) - ( c2        & 0xFF)) <= tol
}

; ¿el píxel c cambió de color respecto a ref, más allá de tol? Maneja el caso
; "fuera de buffer" (-1): -1 vs -1 = sin cambio; -1 vs válido = cambio.
PixelCambioDeColor(c, ref, tol) {
    if (c = ref)
        return false
    if (c = -1 || ref = -1)
        return true
    return !ColorEnTolerancia(c, ref, tol)
}

; Los 9 offsets (px de pantalla ya escalados) del cuadrado 3×3 de un punto:
; centro + sus 8 vecinos. Compartido por el detector y el overlay para que
; muestreen EXACTAMENTE los mismos 9 píxeles.
OffsetsCuadrado3x3(bx, by) {
    return [[-bx,-by],[0,-by],[bx,-by],[-bx,0],[0,0],[bx,0],[-bx,by],[0,by],[bx,by]]
}

; Revisa las "cantidad" cruces de este frame contra el buffer ya capturado y
; devuelve cuántos de sus 9 píxeles (cuadrado 3×3: centro + 8 vecinos, CON
; diagonales) hacen match con paso.color dentro de paso.tolerancia — un
; array paralelo a circuloPuntos con un número de 0 a 9 por cada cruz.
; Sólo se usa para el ENGANCHE (encontrar una cruz con ≥1 acierto); una vez
; enganchado, el disparo compara colores contra la foto, no recuenta matches.
ContarMatchesCruces(paso) {
    global circuloPuntos, circuloBufOX, circuloBufOY, scaleX, scaleY
    ; Distancia de cada vecino ESCALADA con la resolución (mín 1 px). En 1080p
    ; (scale=1.0) el cuadrado mide 3×3 px; en 4K (scale=2.0) los vecinos van a 2 px.
    bx := Max(1, Round(scaleX))
    by := Max(1, Round(scaleY))
    offsets := OffsetsCuadrado3x3(bx, by)

    conteos := []
    for idx, p in circuloPuntos {
        ok := 0
        for off in offsets {
            col := PixelDelCirculo(p.x - circuloBufOX + off[1], p.y - circuloBufOY + off[2])
            if ColorEnTolerancia(col, paso.color, paso.tolerancia)
                ok += 1
        }
        conteos.Push(ok)
    }
    return conteos
}

; Lee los 9 colores (0xRRGGBB) del cuadrado 3×3 de la cruz idx desde el buffer
; ya capturado este frame — mismos 9 offsets que usa el detector para contar.
LeerColoresCruz(idx) {
    global circuloPuntos, circuloBufOX, circuloBufOY, scaleX, scaleY
    bx := Max(1, Round(scaleX))
    by := Max(1, Round(scaleY))
    p := circuloPuntos[idx]
    cols := []
    for off in OffsetsCuadrado3x3(bx, by)
        cols.Push(PixelDelCirculo(p.x - circuloBufOX + off[1], p.y - circuloBufOY + off[2]))
    return cols
}

; Lógica principal: prepara/captura y aplica el enganche en DOS fases:
;   • ENGANCHE: basta detectar 1 píxel del color buscado en cualquiera de las
;     100 cruces (su cuadrado 3×3 con ≥1 acierto). Al enganchar GUARDA los 9
;     colores de ese 3×3 como "foto" de referencia.
;   • DISPARO: mientras está enganchado compara el 3×3 actual contra esa foto;
;     en cuanto UN SOLO píxel cambia de color respecto a entonces (dentro de
;     paso.tolerancia) dispara {Space} al INSTANTE, sin confirmaciones.
; Devuelve true si la cruz vigilada cambió y ya se envió {Space}.
RevisarCirculoDetector(paso) {
    global circuloBufOX, circuloBufOY, circuloBufW, circuloBufH, circuloLockIdx, circuloLockColores
    static UMBRAL_ENGANCHE := 1   ; basta 1 píxel detectado para enganchar la cruz

    PrepararCirculoDetector(paso)
    CapturarCirculo(circuloBufOX, circuloBufOY, circuloBufW, circuloBufH)

    if (circuloLockIdx != 0) {
        ; Comparar el 3×3 actual contra la foto tomada al engancharse: si UN
        ; solo píxel cambió de color respecto a entonces, reaccionar YA.
        actuales := LeerColoresCruz(circuloLockIdx)
        for i, ref in circuloLockColores {
            if PixelCambioDeColor(actuales[i], ref, paso.tolerancia) {
                SendInput "{Space}"
                circuloLockIdx := 0
                circuloLockColores := []
                return true
            }
        }
        return false
    }

    ; Sin enganche todavía: engancha en cuanto una cruz tenga ≥1 acierto y
    ; fotografía sus 9 colores como referencia para detectar el cambio.
    conteos := ContarMatchesCruces(paso)
    for idx, ok in conteos {
        if (ok >= UMBRAL_ENGANCHE) {
            circuloLockIdx := idx
            circuloLockColores := LeerColoresCruz(idx)
            break
        }
    }
    return false
}

ActivarBloqueoGlobal(paso) {
    global bloqueoGlobalHasta
    if paso.HasProp("bloqueoGlobal") && (paso.bloqueoGlobal > 0)
        bloqueoGlobalHasta := A_TickCount + paso.bloqueoGlobal
}

BloqueoGlobalRestante() {
    global bloqueoGlobalHasta
    restante := bloqueoGlobalHasta - A_TickCount
    return restante > 0 ? restante : 0
}

BloqueoGlobalActivo() {
    return BloqueoGlobalRestante() > 0
}

; ===== CHECK PRIORIDAD =====
; ===== SCHEDULER POR PASO =====
; Cada paso escanea su píxel a su PROPIA cadencia, independiente del tick de
; 50ms (que pasa a ser solo el "scheduler" que decide qué pasos tocan revisión
; este tick — ya NO se hace PixelSearch de todos los pasos en cada tick).
; Cadencia base: derivada del cooldown del paso (pasos críticos escanean rápido,
; pasos raros despacio), o fijada a mano con la propiedad scan:ms en el paso.
; El botón de velocidad (🐢 lento ×2 / 🚶 medio ×1 / ⚡ rápido ×0.5) multiplica
; esa cadencia — EXCEPTO en pasos con cooldown >= 10s, que quedan fijos.
IntervaloScanPaso(paso) {
    global velocidadPasos
    cd := paso.HasProp("cooldown") ? paso.cooldown : 500
    base := paso.HasProp("scan") ? paso.scan
        : cd <= 200 ? 50      ; pasos críticos (play/ingame): cada tick
        : cd <= 1000 ? 150    ; navegación/lobby: ~7 escaneos/seg
        : cd < 10000 ? 250    ; estados largos: 4 escaneos/seg
        : 400                 ; pasos raros (cooldown 10s+): 2.5 escaneos/seg
    if (cd >= 10000)
        return base   ; cadencia fija: el botón de velocidad NO toca estos pasos
    factor := velocidadPasos = 1 ? 2.0 : (velocidadPasos = 3 ? 0.5 : 1.0)
    return Max(50, Round(base * factor))
}

; ¿Le toca escanear a este paso en este tick? (y si le toca, programa el próximo)
PasoTocaEscanear(paso) {
    if (A_TickCount < (paso.HasProp("proxScan") ? paso.proxScan : 0))
        return false
    paso.proxScan := A_TickCount + IntervaloScanPaso(paso)
    return true
}

CheckPrioridad() {
    global pasosPrioridad, pasosNormales, activo, accionEnCurso, ultimoCambio, contadorSecuencias
    global modoDestruccion, ultimaDeteccionReal

    if BloqueoGlobalActivo()
        return false
    if !IsObject(pasosPrioridad)
        return false

    for paso in pasosPrioridad {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0
        if !PasoActivoEnPerfil(paso)
            continue
        if paso.HasProp("cooldown") && (A_TickCount - paso.lastUsed < paso.cooldown)
            continue
        ; Scheduler por paso (solo pasos con cooldown — "xxx" de frt queda intacto)
        if paso.HasProp("cooldown") && !PasoTocaEscanear(paso)
            continue

        if BuscarPixel(paso, &x, &y) {
            MouseMove(x, y, 5)
            Click

            if paso.HasProp("esperarA") {
                tiempoLimite := A_TickCount + 2000
                loop {
                    if (!activo) {
                        accionEnCurso := false
                        return false
                    }

                    for p in pasosNormales {
                        if (p.nombre = paso.esperarA) {
                            if BuscarPixel(p, &x2, &y2) {
                                paso.lastUsed := A_TickCount
                                ActivarBloqueoGlobal(paso)
                                ultimoCambio := A_TickCount
                                ultimaDeteccionReal := A_TickCount
                                ; Recuperación de modo destrucción si detectamos algo
                                if (modoDestruccion) {
                                    modoDestruccion := false
                                    AgregarHistorial(Chr(0x2705) " Detección recuperada - saliendo de modo destrucción", "00CC44")
                                }
                                ; FIX: antes se comparaba con "LEAVINGGAME..." literal, pero los
                                ; pasos se llaman LEAVINGGAME1.../LEAVINGGAME2... → NUNCA entraba:
                                ; ni contaba secuencias ni mandaba el webhook (Stats siempre a 0).
                                if (InStr(paso.nombre, "LEAVINGGAME")) {
                                    contadorSecuencias += 1
                                    ActualizarSecuencias()
                                    AgregarHistorial(paso.nombre " -> COOLDOWN " Round(paso.cooldown/1000) "s | Secuencias: " contadorSecuencias, paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                                    EnviarWebhookEvento("secuencia")
                                    DespuesDeAccion(true)
                                    ; ── Efecto único de SUKUNA: Fuga (flame arrow) en la barra al completar secuencia ──
                                    if (temas[temaActual].HasProp("unlock") && temas[temaActual].unlock = "sukuna")
                                        SetTimer(BarraFlashFuga, -1)
                                    ; ── Efecto único de GOJO: Expansión de Dominio (Vacío Ilimitado) al completar secuencia ──
                                    else if (temas[temaActual].HasProp("unlock") && temas[temaActual].unlock = "gojo")
                                        SetTimer(LanzarDominioGojo, -1)
                                } else {
                                    AgregarHistorial(paso.nombre " -> COOLDOWN " Round(paso.cooldown/1000) "s", paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                                    DespuesDeAccion(false)
                                }
                                LuzAccionFlash()
                                return true
                            }
                        }
                    }

                    if (A_TickCount > tiempoLimite) {
                        AgregarHistorial(paso.nombre " -> timeout espera", paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                        SetTimer(BarraFlashError, -1)
                                        return false
                    }

                    if paso.HasProp("accion") {
                        if paso.HasProp("hold") {
                            SendInput "{" paso.accion " down}"
                            Sleep paso.hold
                            SendInput "{" paso.accion " up}"
                        } else {
                            SendInput "{" paso.accion "}"
                            AgregarHistorial(paso.nombre " (spam Esc)", paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                            SetTimer(BarraFlashError, -1)
                        }
                        ultimoCambio := A_TickCount
                    }
                    Sleep 1500
                }
            } else {
                if paso.HasProp("accion")
                    SendInput "{" paso.accion "}"
                paso.lastUsed := A_TickCount
                ActivarBloqueoGlobal(paso)
                ultimoCambio := A_TickCount
                ultimaDeteccionReal := A_TickCount
                LuzAccionFlash()
                return true
            }
        }
    }
    return false
}

EjecutarMacro(*) {
    global activo, pasosNormales, accionEnCurso, ultimoCambio, contadorEsc
    global modoCadena, pasoCadena, finCadena
    global ultimoPasoEjecutado
    global modoDestruccion, contadorDestruccion
    global tiempoUltimoLanzamiento, tiempoLanzamientoSteam
    global ultimoAfkMove, ultimaDeteccionReal, perfilActivo, enDescanso
    static PASOS_ENTRE_PRIO := 5   ; CheckPrioridad cada N pasos normales revisados

    ; Proof-of-life para el watchdog ANTES de cualquier return.
    ; Si el timer está corriendo, el macro está vivo — punto. Esto debe estar arriba
    ; del guard porque si accionEnCurso o BloqueoGlobalActivo nos hacen salir
    ; temprano, el ultimoAfkMove tampoco se actualizaba → watchdog Reload() falso.
    ultimoAfkMove := A_TickCount

    ; Descanso del ciclo (SOLO tct/sp): el macro sigue ENCENDIDO, pero con la
    ; detección en pausa — el juego está cerrado a propósito, así que no hay
    ; nada que detectar, ni anti-AFK, ni modo destrucción, ni relanzamientos.
    if (enDescanso && (perfilActivo = 1 || perfilActivo = 2))
        return

    if (!activo || accionEnCurso || BloqueoGlobalActivo())
        return
    accionEnCurso := true

    if (modoCadena) {
        if (A_TickCount > finCadena) {
            modoCadena := false
        } else {
            for p in pasosNormales {
                if (p.nombre = pasoCadena) {
                    if !PasoActivoEnPerfil(p)
                        continue
                    encontrado := BuscarPixel(p, &x, &y)
                    if (encontrado) {
                        MouseMove(x, y, 5)
                        Click
                        if p.HasProp("accion")
                            SendInput "{" p.accion "}"
                        p.lastUsed := A_TickCount
                        ActivarBloqueoGlobal(p)
                        ultimaDeteccionReal := A_TickCount
                        ; Recuperación de modo destrucción si detectamos algo
                        if (modoDestruccion) {
                            modoDestruccion := false
                            AgregarHistorial(Chr(0x2705) " Detección recuperada - saliendo de modo destrucción", "00CC44")
                        }
                        AgregarHistorial(p.nombre " (chain)", p.HasProp("CH") ? p.CH : "")
                        LuzAccionFlash()
                        if p.HasProp("siguiente") {
                            pasoCadena := p.siguiente
                            finCadena := A_TickCount + (p.HasProp("tiempoEspera") ? p.tiempoEspera : 3000)
                        } else {
                            modoCadena := false
                        }
                        accionEnCurso := false
                        return
                    }
                }
            }
            accionEnCurso := false
            return
        }
    }

    pasoRevisado := 0
    for paso in pasosNormales {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0

        if !PasoActivoEnPerfil(paso)
            continue

        ; Detector circular dstv: lo vigila su propio timer de alta frecuencia
        ; (TickCirculoDetectorDstv) — aquí se ignora por completo para que NO
        ; corra en paralelo con la lógica vieja de "pixel blanco → rojo".
        if paso.HasProp("circuloDetector") && paso.circuloDetector
            continue

        pasoRevisado += 1
        ; Cada 5 pasos → comprobar prioridad
        if (!modoCadena && Mod(pasoRevisado, PASOS_ENTRE_PRIO) = 0) {
            if CheckPrioridad() {
                accionEnCurso := false
                return
            }
        }

        if paso.HasProp("cooldown") && (A_TickCount - paso.lastUsed < paso.cooldown)
            continue

        ; Scheduler por paso: si a este paso aún no le toca escanear, saltarlo.
        ; Así cada paso tiene su propio "tiempo de reacción" y el tick de 50ms
        ; deja de ejecutar PixelSearch de TODOS los píxeles en cada pasada.
        if !PasoTocaEscanear(paso)
            continue

        encontrado := BuscarPixel(paso, &x, &y)

        if (encontrado) {
            if paso.HasProp("tiempoNecesario") {
                if !paso.HasProp("tiempoDetectando") || paso.tiempoDetectando = 0
                    paso.tiempoDetectando := A_TickCount
                tiempoDetectado := A_TickCount - paso.tiempoDetectando
                if (tiempoDetectado < paso.tiempoNecesario) {
                    accionEnCurso := false
                    continue
                }
            } else {
                paso.tiempoDetectando := 0
            }

            contadorEsc := 0
            modo := paso.HasProp("modo") ? paso.modo : "click+tecla"
            MouseMove(x, y, 5)
            tiempoUltimoLanzamiento := 0

            if (modo = "click" or modo = "click+tecla") {
                Click
                if paso.HasProp("delayClick")
                    Sleep paso.delayClick
                if (!activo) {
                    accionEnCurso := false
                    return
                }
            }

            if (modo = "tecla" or modo = "click+tecla") {
                if paso.HasProp("accion") {
                    if paso.HasProp("hold") {
                        SendInput "{" paso.accion " down}"
                        Sleep paso.hold
                        SendInput "{" paso.accion " up}"
                        if (!activo) {
                            accionEnCurso := false
                            return
                        }
                    } else {
                        SendInput "{" paso.accion "}"
                        if paso.HasProp("delayTecla")
                            Sleep paso.delayTecla
                        if (!activo) {
                            accionEnCurso := false
                            return
                        }
                    }
                }
            }

            paso.lastUsed := A_TickCount
            ActivarBloqueoGlobal(paso)
            ultimaDeteccionReal := A_TickCount
            if (paso.nombre != ultimoPasoEjecutado) {
                ultimoCambio := A_TickCount
                ultimoPasoEjecutado := paso.nombre
            }
            ; Si el macro estaba en modo destrucción y acaba de detectar algo, salir del modo.
            ; Antes se quedaba pegado en "MODO DESTRUCCION en: Xs" para siempre si
            ; el juego se recuperaba durante la ventana de 60s antes del Alt+F4.
            if (modoDestruccion) {
                modoDestruccion := false
                AgregarHistorial(Chr(0x2705) " Detección recuperada - saliendo de modo destrucción", "00CC44")
            }
            ; NO registrar cada paso suelto en el historial (play/ingame/enteringroom...
            ; inundaban el panel). El historial muestra SOLO los cooldowns y eventos
            ; relevantes (-> COOLDOWN Xs, secuencias, sleep, etc.). La luz/onda siguen
            ; dando feedback visual en vivo de cada acción detectada.
            LuzAccionFlash(paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
            OndaBarra()
            DespuesDeAccion(false)

            if paso.HasProp("siguiente") {
                modoCadena := true
                pasoCadena := paso.siguiente
                finCadena := A_TickCount + (paso.HasProp("tiempoEspera") ? paso.tiempoEspera : 3000)
            }

            accionEnCurso := false
            return
        } else {
            paso.tiempoDetectando := 0
        }
    }

    accionEnCurso := false

    ; frt y dstv: sin anti-AFK, sin modo destrucción, sin relanzamientos, sin
    ; MouseMove — todo eso es SOLO para tct/sp (frt tiene su propio spam y el
    ; Esc/c del anti-AFK le estorbaría al juego).
    if (PerfilSinGestion())
        return

    tiempoSinCambios := A_TickCount - ultimoCambio

    ; ===== PAUSA TOTAL EN MODO DESCANSO (pero mantener PC despierta) =====
    if (!enDescanso) {
    ; ===== MODO DESTRUCCION =====
    ; Evaluar ANTES del anti-AFK para que el reset de ultimoCambio a los 400s
    ; no impida alcanzar los 420s necesarios para el Alt+F4.
    if (modoDestruccion && tiempoSinCambios > 420000) {
        modoDestruccion := false
        contadorDestruccion += 1
        ActualizarDestrucciones()
        ultimoCambio := A_TickCount
        ultimoPasoEjecutado := ""

        AgregarHistorial("💀 Terminando proceso de Brawlhalla", "FF0000")
        EnviarWebhookEvento("altf4")

        ; Antes usabamos Alt+F4 pero es lento (animacion de cierre) y poco fiable
        ; (si la ventana esta en un menu o dialogo, no cierra). Mejor matar el proceso
        ; directamente — instantaneo y 100% fiable.
        if ProcessExist("Brawlhalla.exe") {
            try ProcessClose("Brawlhalla.exe")
            ; Backup: taskkill /F por si ProcessClose no tiene permisos
            if ProcessExist("Brawlhalla.exe") {
                try Run(A_ComSpec ' /c taskkill /F /IM Brawlhalla.exe', , "Hide")
            }
        }

        ; Esperar a que el proceso muera realmente (hasta 5s)
        ; Abortar si el usuario para el macro durante la espera.
        cierreT0 := A_TickCount
        while (ProcessExist("Brawlhalla.exe") && (A_TickCount - cierreT0) < 5000) {
            if (!activo)
                return
            Sleep 200
        }

        ; Dar tiempo al sistema antes de relanzar, partido en chunks de 100ms
        ; para poder abortar si el usuario para el macro.
        Loop 15 {
            if (!activo)
                return
            Sleep 100
        }
        if (!activo)
            return  ; no relanzar si pararon
        LanzarBrawlhallaConFoco()
        tiempoUltimoLanzamiento := A_TickCount
    }

    ; ===== ANTI-AFK (solo si NO estamos en modo destruccion) =====
    if (!modoDestruccion && tiempoSinCambios > 400000) {
        ultimoCambio := A_TickCount
        Loop 1 {
            if (!activo)
                return
            SendInput "{Esc}"
            Sleep 1500
        }
        Loop 2 {
            if (!activo)
                return
            SendInput "c"
            Sleep 1500
        }
    }

    ; ===== REINTENTO LANZAMIENTO =====

    if (activo && tiempoUltimoLanzamiento > 0 && (A_TickCount - tiempoUltimoLanzamiento) > 60000
        && ultimaDeteccionReal <= tiempoLanzamientoSteam) {
        tiempoUltimoLanzamiento := A_TickCount
        ultimoCambio := A_TickCount
        AgregarHistorial("⚠️ Sin detección tras 2 min - relanzando secuencia Steam + Win + 'brawlhalla'", "FF8800")
        LanzarBrawlhallaConFoco()
    }
    }  ; cierre del bloque if (!enDescanso)

    ; Anti-sleep: mover ratón 1px incluso en modo dormir para que PC no se duerma
    MouseMove(1, 0, 0, "R")
    MouseMove(-1, 0, 0, "R")
    global ultimoAfkMove
    ultimoAfkMove := A_TickCount   ; watchdog: marca que el AFK acaba de moverse
    accionEnCurso := false
}

; ═════ CICLO AUTOMÁTICO JUGAR / DESCANSO ═════
; Tras CICLO_SEG jugando: Alt+F4 a Brawlhalla + descanso de DESCANSO_SEG. Luego vuelve a
; entrar a Brawlhalla y se repite. Usa marcas de tiempo reales (A_Now) guardadas en el
; config, así el contador SIGUE IGUAL aunque pares el macro, lo cierres o se crashee.
TickCicloDescanso() {
    global cicloActivo, cicloInicio, enDescanso, descansoInicio, activo, CICLO_SEG, DESCANSO_SEG
    global brawlhallaLanzado, ultimoCambio, ultimaDeteccionReal, tiempoUltimoLanzamiento, modoDestruccion
    global perfilActivo
    if (!cicloActivo)
        return
    ; El ciclo jugar/descanso es SOLO para tct (1) y sp (2) — Brawlhalla.
    ; En frt y dstv no se acumula tiempo ni se dispara el descanso; el reloj
    ; es de pared (A_Now), así que al volver a tct/sp el ciclo sigue donde iba.
    if (PerfilSinGestion())
        return
    if (enDescanso) {
        ; Durante el descanso el macro NO se apaga: sigue encendido en pausa de
        ; detección (gates de enDescanso en EjecutarMacro/ActualizarAFK/frt/dstv).
        ; Solo el juego está cerrado. Guardia anti-bloqueo: si el timestamp del
        ; descanso se perdió, reiniciar el contador en vez de terminar al instante.
        if (descansoInicio = "") {
            descansoInicio := A_Now
            GuardarCicloEstado()
            return
        }
        if (DateDiff(A_Now, descansoInicio, "Seconds") >= DESCANSO_SEG) {
            ; fin del descanso → reabrir Brawlhalla y seguir jugando
            enDescanso := false
            cicloInicio := A_Now
            GuardarCicloEstado()
            AgregarHistorial(Chr(0x1F3AE) " " TextoDormir(), "00C853")
            try EnviarWebhookEvento("iniciado")
            ; Resetear el flag de "ya lancé Brawlhalla" — sin esto el lanzamiento
            ; se salta (quedó en true de la sesión anterior) y el juego no se
            ; reabre hasta el respaldo de 7 min.
            brawlhallaLanzado := false
            if (activo) {
                ; El macro siguió encendido durante la hora de descanso → los
                ; contadores llevan 1h congelados: resetearlos para que el
                ; anti-AFK/destrucción no salten al instante, y relanzar el juego.
                ultimoCambio := A_TickCount
                ultimaDeteccionReal := A_TickCount
                tiempoUltimoLanzamiento := A_TickCount
                modoDestruccion := false
                LanzarJuegoDelPerfil()
            } else {
                Iniciar()
            }
        }
        return
    }
    ; El ciclo arranca cuando el macro empieza a jugar por primera vez
    if (cicloInicio = "") {
        if (activo) {
            cicloInicio := A_Now
            GuardarCicloEstado()
        }
        return
    }
    ; ¿se cumplieron las horas de juego? → iniciar descanso
    if (DateDiff(A_Now, cicloInicio, "Seconds") >= CICLO_SEG)
        IniciarDescansoCiclo()
}

IniciarDescansoCiclo() {
    global enDescanso, descansoInicio, activo, CICLO_SEG, DESCANSO_SEG
    enDescanso := true
    descansoInicio := A_Now
    GuardarCicloEstado()
    AgregarHistorial(Chr(0x1F4A4) " " TextoDormir(), "FF8800")
    try EnviarWebhookEvento("altf4")
    ; OJO: el macro NO se para — solo se cierra el juego con Alt+F4. La detección
    ; queda en pausa por el gate de enDescanso y se reanuda sola al acabar la hora.
    CerrarBrawlhallaAltF4()
}

; Guarda el estado del ciclo en el config para que sobreviva a cierres/crashes
GuardarCicloEstado() {
    global configPath, cicloInicio, enDescanso, descansoInicio
    try IniWrite(cicloInicio, configPath, "Ciclo", "InicioTS")
    try IniWrite(descansoInicio, configPath, "Ciclo", "DescansoTS")
    try IniWrite(enDescanso ? 1 : 0, configPath, "Ciclo", "EnDescanso")
}

; Reinicia el ciclo de dormir desde cero (solo si el usuario cierra/reinicia manualmente)
ResetearCicloEstado() {
    global cicloInicio, enDescanso, descansoInicio
    cicloInicio := ""
    enDescanso := false
    descansoInicio := ""
    GuardarCicloEstado()
}

; Cierre directo del proceso de Brawlhalla (sin Alt+F4)
; Instantáneo y 100% fiable, sin animaciones de cierre.
CerrarBrawlhallaAltF4() {
    ; Matar el proceso directamente — instantáneo y fiable
    if (!ProcessExist("Brawlhalla.exe"))
        return
    try ProcessClose("Brawlhalla.exe")
    Sleep 500
    ; Backup: taskkill /F por si ProcessClose no tiene permisos
    if (ProcessExist("Brawlhalla.exe")) {
        try Run(A_ComSpec ' /c taskkill /F /IM Brawlhalla.exe', , "Hide")
        Sleep 500
    }
    if (ProcessExist("Brawlhalla.exe"))
        AgregarHistorial(Chr(0x26A0) " No se pudo cerrar Brawlhalla (¿permisos de administrador?)", "FF4444")
}

; ===== DETECTOR CIRCULAR DSTV — TICK DE ALTA FRECUENCIA =====
; Corre en su PROPIO SetTimer (independiente del loop de 50ms de EjecutarMacro,
; que para el perfil dstv no hace nada más que mantener vivo el watchdog) para
; poder vigilar el círculo de cruces a ~60fps sin esperar la cadencia del loop
; principal — clave para reaccionar "al instante" cuando la cruz cambia.
TickCirculoDetectorDstv() {
    global activo, perfilActivo, pasosNormales
    global ultimoCambio, ultimaDeteccionReal

    if (!activo || perfilActivo != 4)
        return

    paso := 0
    for p in pasosNormales {
        if (p.HasProp("circuloDetector") && p.circuloDetector && p.HasProp("dstv") && p.dstv) {
            paso := p
            break
        }
    }
    if !IsObject(paso)
        return

    if paso.HasProp("cooldown") && (A_TickCount - paso.lastUsed < paso.cooldown)
        return

    if RevisarCirculoDetector(paso) {
        paso.lastUsed := A_TickCount
        ActivarBloqueoGlobal(paso)
        ultimaDeteccionReal := A_TickCount
        ultimoCambio := A_TickCount
        AgregarHistorial(paso.nombre " → Space (círculo)", paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
        LuzAccionFlash()
        OndaBarra()
        DespuesDeAccion(false)
    }
}

; ===== DINAMISMO — FUNCIONES =====

ActualizarContadorAcciones() {
    global contadorAcciones, contadorLabel, streakActual
    if !IsObject(contadorLabel)
        return
    if (contadorAcciones > 0) {
        txt := Chr(0x25B8) " " contadorAcciones " acciones"
        if (streakActual >= 3)
            txt .= "   " Chr(0x1F525) " " streakActual " en racha"
        contadorLabel.Value := txt
    } else {
        contadorLabel.Value := ""
    }
}

AnimarLucesEncendido() {
    global luzActiva, luzAccion, luzApagado, colorLuzActiva, colorLuzAccion, colorLuzApagado, colorFondoPrincipal
    SetLuz(luzActiva,  colorFondoPrincipal)
    SetLuz(luzAccion,  colorFondoPrincipal)
    SetLuz(luzApagado, colorFondoPrincipal)
    SetTimer(() => SetLuz(luzActiva,  colorLuzActiva),  -100)
    SetTimer(() => SetLuz(luzAccion,  colorLuzAccion),  -200)
    SetTimer(() => SetLuz(luzApagado, colorLuzApagado), -300)
}

MostrarToast(texto, duracion := 3000, colorFondo := "", colorTexto := "") {
    global toastGui, toastX, toastStartY, toastTargetY, toastStep, toastDuracion
    global colorBarra, colorTextoBarra, miGui
    if IsObject(toastGui) {
        try toastGui.Destroy()
        toastGui := ""
    }
    if (colorFondo = "")
        colorFondo := colorBarra
    if (colorTexto = "")
        colorTexto := colorTextoBarra
    miGui.GetPos(&mx, &my, &mw, &mh)
    toastX      := mx
    toastStartY := my + mh + 4
    toastTargetY := my + mh - 30
    toastStep    := 0
    toastDuracion := duracion
    tGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    tGui.BackColor := colorFondo
    lbl := tGui.Add("Text", "x10 y7 w280 h20 Center c" colorTexto " Background" colorFondo, texto)
    lbl.SetFont("s9 c" colorTexto " Bold", "Segoe UI Semibold")
    tGui.Show("x" toastX " y" toastStartY " w300 h34 NoActivate")
    RedondearVentana(tGui.Hwnd, 10)
    toastGui := tGui
    SetTimer(AnimarToast, 30)
}

AnimarToast() {
    global toastGui, toastX, toastStartY, toastTargetY, toastStep, toastDuracion
    if !IsObject(toastGui) {
        SetTimer(AnimarToast, 0)
        return
    }
    toastStep += 1
    if (toastStep <= 10) {
        t := toastStep / 10.0
        t2 := t < 0.5 ? 4*t*t*t : 1 - (-2*t+2)**3/2
        cy := Round(toastStartY + (toastTargetY - toastStartY) * t2)
        try toastGui.Move(toastX, cy)
    } else if (toastStep = 11) {
        SetTimer(AnimarToast, 0)
        SetTimer(CerrarToastActual, -toastDuracion)
    }
}

CerrarToastActual() {
    global toastGui
    if IsObject(toastGui) {
        try toastGui.Destroy()
        toastGui := ""
    }
}

VerificarMilestone(n) {
    global milestonesVistos, milestonesList, totalSecuenciasGuardadas
    total := n + totalSecuenciasGuardadas
    for m in milestonesList {
        if (total = m) {
            yaVisto := false
            for v in milestonesVistos {
                if (v = m) {
                    yaVisto := true
                    break
                }
            }
            if (!yaVisto) {
                milestonesVistos.Push(m)
                MostrarToast(Chr(0x1F3C6) "  ¡" m " secuencias — hito!", 3500)
                EnviarWebhookMilestone(m)
            }
            return
        }
    }
}

; ===== DINAMISMO EXTRA — SPEED LINES / STREAK / CRITICOS / CONFETI =====

TriggerSpeedLines() {
    global logoSpeedLinesUntil, logoMacro
    logoSpeedLinesUntil := A_TickCount + 200
    if (IsObject(logoMacro))
        DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 0)
}

IncrementarStreak() {
    global streakActual, streakMax, contadorAcciones
    streakActual += 1
    if (streakActual > streakMax)
        streakMax := streakActual
    ActualizarContadorAcciones()
}

ResetStreak() {
    global streakActual
    if (streakActual > 0) {
        streakActual := 0
        ActualizarContadorAcciones()
    }
}

DespuesDeAccion(esSecuencia := false) {
    global contadorSecuencias, totalCriticos
    TriggerSpeedLines()
    IncrementarStreak()
    ; ── Decoración visual SUKUNA: cortes diagonales en cada detección (no-op en otros temas)
    LanzarSlashSukuna()

    ; ── Crítico aleatorio (1% por acción) ──
    if (Random(1, 100) = 1) {
        totalCriticos += 1
        MostrarToastCritico()
        LanzarConfeti()
    }

    ; ── Confeti cada 5 secuencias ──
    if (esSecuencia && contadorSecuencias > 0 && Mod(contadorSecuencias, 5) = 0)
        LanzarConfeti()

    VerificarLogros()
}

MostrarToastCritico() {
    global miGui
    miGui.GetPos(&mx, &my, &mw, &mh)
    tGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    tGui.BackColor := "000000"
    lbl := tGui.Add("Text", "x10 y6 w280 h26 Center cFFD700 Background111111", Chr(0x2728) "  ¡CRÍTICO!  " Chr(0x2728))
    lbl.SetFont("s14 cFFD700 Bold", "Segoe UI Semibold")
    tx := mx + (mw - 300) // 2
    ty := my - 36
    tGui.Show("x" tx " y" ty " w300 h38 NoActivate")
    RedondearVentana(tGui.Hwnd, 12)
    SetTimer(() => (tGui.Destroy()), -1800)
}

; ───── CONFETI ─────
LanzarConfeti() {
    global confetiGui, confetiParticles, confetiActivo, miGui, optConfeti

    if (!optConfeti || !IsObject(miGui))
        return
    if (confetiActivo) {
        ; Re-spawn — añadir más partículas al burst existente
        SpawnConfetiParticles()
        return
    }
    confetiActivo := true

    miGui.GetPos(&mx, &my, &mw, &mh)
    confetiGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")  ; layered+transparent
    confetiGui.BackColor := "010203"
    try WinSetTransColor("010203", confetiGui)
    confetiGui.Show("x" mx " y" my " w" mw " h" mh " NoActivate")

    confetiParticles := []
    SpawnConfetiParticles()
    InstalarSubclassConfeti()
    SetTimer(ActualizarConfeti, 30)
}

SpawnConfetiParticles() {
    global confetiParticles, miGui
    miGui.GetPos(,, &mw, &mh)
    Loop 35 {
        confetiParticles.Push({
            x:     mw / 2.0 + Random(-40, 40),
            y:     mh / 2.0 + Random(-25, 25),
            vx:    Random(-50, 50) / 12.0,
            vy:    Random(-70, -15) / 10.0,
            r:     Random(18, 42) / 10.0,
            color: HSVaHex(Random(0, 359), 1.0, 1.0),
            life:  1.0
        })
    }
}

ActualizarConfeti() {
    global confetiGui, confetiParticles, confetiActivo, confetiSubclassCb
    if (!confetiActivo || !IsObject(confetiGui)) {
        SetTimer(ActualizarConfeti, 0)
        return
    }
    gravity := 0.28
    drag := 0.985
    allDead := true
    for p in confetiParticles {
        p.vy += gravity
        p.vx *= drag
        p.x += p.vx
        p.y += p.vy
        p.life -= 0.018
        if (p.life > 0)
            allDead := false
    }
    if (allDead) {
        SetTimer(ActualizarConfeti, 0)
        ; Liberar subclass callback ANTES de destruir el GUI
        ; (sino se filtra un handle de callback en cada crítico → tras N críticos el proceso muere por handles GDI)
        if (confetiSubclassCb) {
            try DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", confetiGui.Hwnd, "Ptr", confetiSubclassCb, "Ptr", 33)
            try CallbackFree(confetiSubclassCb)
            confetiSubclassCb := 0
        }
        try confetiGui.Destroy()
        confetiGui := ""
        confetiActivo := false
        confetiParticles := []
        return
    }
    DllCall("RedrawWindow", "Ptr", confetiGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x45)
}

PintarConfeti(hdc, w, h) {
    global confetiParticles

    memDC := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
    hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr")
    oldBmp := DllCall("SelectObject", "Ptr", memDC, "Ptr", hbm, "Ptr")

    ; Fondo con color clave para transparencia
    brushBg := DllCall("CreateSolidBrush", "UInt", 0x030201, "Ptr")
    rc := Buffer(16, 0)
    NumPut("Int", 0, rc, 0), NumPut("Int", 0, rc, 4), NumPut("Int", w, rc, 8), NumPut("Int", h, rc, 12)
    DllCall("FillRect", "Ptr", memDC, "Ptr", rc, "Ptr", brushBg)
    DllCall("DeleteObject", "Ptr", brushBg)

    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", memDC, "Ptr*", &g)
    if (g) {
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)
        for p in confetiParticles {
            if (p.life <= 0)
                continue
            alpha := Round(p.life * 255)
            rC := Integer("0x" SubStr(p.color, 1, 2))
            gC := Integer("0x" SubStr(p.color, 3, 2))
            bC := Integer("0x" SubStr(p.color, 5, 2))
            argb := (alpha << 24) | (rC << 16) | (gC << 8) | bC
            brush := 0
            DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &brush)
            DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", brush, "Float", p.x - p.r, "Float", p.y - p.r, "Float", p.r * 2, "Float", p.r * 2)
            DllCall("gdiplus\GdipDeleteBrush", "Ptr", brush)
        }
        DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    }

    DllCall("BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", memDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
    DllCall("SelectObject", "Ptr", memDC, "Ptr", oldBmp)
    DllCall("DeleteObject", "Ptr", hbm)
    DllCall("DeleteDC", "Ptr", memDC)
}

ConfetiSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND)
        return 1
    if (uMsg = WM_PAINT) {
        ps := Buffer(72, 0)
        hdc := DllCall("BeginPaint", "Ptr", hWnd, "Ptr", ps, "Ptr")
        if (hdc) {
            rc := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", hWnd, "Ptr", rc)
            w := NumGet(rc, 8, "Int")
            h := NumGet(rc, 12, "Int")
            PintarConfeti(hdc, w, h)
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

InstalarSubclassConfeti() {
    global confetiGui, confetiSubclassCb
    if (!IsObject(confetiGui))
        return
    ; Si por cualquier motivo había un callback previo huérfano, liberarlo antes
    if (confetiSubclassCb) {
        try CallbackFree(confetiSubclassCb)
        confetiSubclassCb := 0
    }
    confetiSubclassCb := CallbackCreate(ConfetiSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", confetiGui.Hwnd, "Ptr", confetiSubclassCb, "Ptr", 33, "Ptr", 0)
}

; ===== LOGROS / ACHIEVEMENTS =====

DefinirLogros() {
    global logros
    logros := [
        { id: "primera",      nombre: "Primera secuencia",    desc: "Completa tu primera secuencia",    icono: Chr(0x1F947), desbloqueado: false },
        { id: "centurion",    nombre: "Centurión",            desc: "100 secuencias totales",           icono: Chr(0x1F948), desbloqueado: false },
        { id: "millennium",   nombre: "Millennium",           desc: "1000 secuencias totales",          icono: Chr(0x1F947), desbloqueado: false },
        { id: "resistencia",  nombre: "Resistencia",          desc: "24 horas totales acumuladas",      icono: Chr(0x23F0), desbloqueado: false },
        { id: "marathon",     nombre: "Marathon",             desc: "8 horas en una sola sesión",       icono: Chr(0x1F3C3), desbloqueado: false },
        { id: "phantom",      nombre: "Fantasma",             desc: "50 acciones seguidas sin AFK",     icono: Chr(0x1F47B), desbloqueado: false },
        { id: "destructor",   nombre: "Destructor",           desc: "10 destrucciones totales",         icono: Chr(0x1F4A5), desbloqueado: false },
        { id: "lucky",        nombre: "Suertudo",             desc: "Tu primer crítico",                icono: Chr(0x2728), desbloqueado: false },
        { id: "luckyMax",     nombre: "Premio mayor",         desc: "50 críticos acumulados",           icono: Chr(0x1F340), desbloqueado: false },
        { id: "coleccionista", nombre: "Coleccionista",       desc: "Desbloquea 3 temas secretos",      icono: Chr(0x1F31F), desbloqueado: false },
        { id: "godmode",      nombre: "God Mode",             desc: "Desbloquea TODOS los temas",       icono: Chr(0x1F451), desbloqueado: false, pagina: 0 },
        { id: "themeShadow",  nombre: "Eclipse del tiempo",    desc: "??? (el ⏱ timer responde si insistes)",                       icono: Chr(0x2728), desbloqueado: false, pagina: 0 },
        { id: "themeCosmos",  nombre: "Viajero estelar",       desc: "??? (gira y gira )",                            icono: Chr(0x2728), desbloqueado: false, pagina: 0 },
        { id: "themeVoid",    nombre: "Abrazo del vacío",      desc: "??? (Tal vez algo AFK )",                icono: Chr(0x26A1), desbloqueado: false, pagina: 0 },
        { id: "themeSolar",   nombre: "Renacer de las cenizas",desc: "??? (las 3 luces tienen un orden secreto: izq → centro → der)", icono: Chr(0x1F525), desbloqueado: false, pagina: 0 },
        { id: "themeBlanco",  nombre: "Pureza absoluta",       desc: "??? (el historial guarda un secreto AFK)",              icono: Chr(0x2728), desbloqueado: false, pagina: 0 },
        { id: "themePremium", nombre: "El elegido",            desc: "??? (consigue TODOS los demás secretos primero)",             icono: Chr(0x1F48E), desbloqueado: false, pagina: 0 },
        { id: "gamerpack",    nombre: "Pack Gamer",            desc: "??? (Las SECUENCIAS son el camino)",     icono: Chr(0x1F3AE), desbloqueado: false, pagina: 0 },
        { id: "leyendaspack", nombre: "Pack Leyendas",         desc: "??? (el medidor ⚡ gira en bucle... no pares de tocarlo)", icono: Chr(0x1F4FA), desbloqueado: false, pagina: 0 },
        { id: "kiko",         nombre: "kiko",                  desc: "Llega a 67 secuencias",            icono: Chr(0x1F60E), desbloqueado: false, pagina: 1 },
        { id: "jbs",          nombre: "JBS",                   desc: "Llega a 5000 secuencias",          icono: Chr(0x1F3C6), desbloqueado: false, pagina: 1 },
        { id: "primera",      nombre: "Primera secuencia",    desc: "Completa tu primera secuencia",    icono: Chr(0x1F947), desbloqueado: false, pagina: 1 },
        { id: "centurion",    nombre: "Centurión",            desc: "100 secuencias totales",           icono: Chr(0x1F948), desbloqueado: false, pagina: 1 },
        { id: "millennium",   nombre: "Millennium",           desc: "1000 secuencias totales",          icono: Chr(0x1F947), desbloqueado: false, pagina: 1 },
        { id: "lucky",        nombre: "Suertudo",             desc: "Tu primer crítico",                icono: Chr(0x2728), desbloqueado: false, pagina: 1 },
        { id: "luckyMax",     nombre: "Premio mayor",         desc: "50 críticos acumulados",           icono: Chr(0x1F340), desbloqueado: false, pagina: 1 },
        { id: "phantom",      nombre: "Fantasma",             desc: "50 acciones seguidas sin AFK",     icono: Chr(0x1F47B), desbloqueado: false, pagina: 1 },
        { id: "fruitMaster",  nombre: "Maestro de Frutas",    desc: "Completa 100 acciones en FRT",    icono: Chr(0x1F349), desbloqueado: false, pagina: 2 },
        { id: "fruitLegend",  nombre: "Leyenda de Frutas",    desc: "Completa 500 acciones en FRT",    icono: Chr(0x1F95D), desbloqueado: false, pagina: 2 },
        { id: "spamMaster",   nombre: "Spam Master",          desc: "10 minutos sin parar en FRT",     icono: Chr(0x26A1), desbloqueado: false, pagina: 2 },
        { id: "generador",    nombre: "Generador",            desc: "Completa 50 detecciones en DSTV", icono: Chr(0x26A1), desbloqueado: false, pagina: 3 },
        { id: "generadorPro", nombre: "Generador Pro",        desc: "Completa 200 detecciones en DSTV",icono: Chr(0x1F60E), desbloqueado: false, pagina: 3 },
        { id: "resistencia",  nombre: "Resistencia",          desc: "24 horas totales acumuladas",      icono: Chr(0x23F0), desbloqueado: false, pagina: -1 },
        { id: "marathon",     nombre: "Marathon",             desc: "8 horas en una sola sesión",       icono: Chr(0x1F3C3), desbloqueado: false, pagina: -1 },
        { id: "destructor",   nombre: "Destructor",           desc: "10 destrucciones totales",         icono: Chr(0x1F4A5), desbloqueado: false, pagina: -1 },
        { id: "coleccionista", nombre: "Coleccionista",       desc: "Desbloquea 3 temas secretos",      icono: Chr(0x1F31F), desbloqueado: false, pagina: 0 }
    ]
}

CargarLogros() {
    global configPath, logros
    for l in logros
        l.desbloqueado := Integer(IniRead(configPath, "Logros", l.id, "0")) = 1
}

GuardarLogro(id) {
    global configPath
    IniWrite(1, configPath, "Logros", id)
}

VerificarLogros() {
    global logros
    global totalSecuenciasGuardadas, contadorSecuencias
    global totalHorasGuardadas, totalDestruccionGuardada, contadorDestruccion
    global streakMax, tiempoAcumulado, tiempoInicio, timerActivo, totalCriticos
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado, eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggGamerDesbloqueado, eggLeyendasDesbloqueado

    totalSecs := totalSecuenciasGuardadas + contadorSecuencias
    totalDestru := totalDestruccionGuardada + contadorDestruccion
    sesionHoras := tiempoAcumulado / 3600000.0
    if (timerActivo)
        sesionHoras += (A_TickCount - tiempoInicio) / 3600000.0
    eggsCount := (eggDesbloqueado ? 1 : 0) + (eggVoidDesbloqueado ? 1 : 0) + (eggShadowDesbloqueado ? 1 : 0)
                 + (eggSolarDesbloqueado ? 1 : 0) + (eggBlancoDesbloqueado ? 1 : 0) + (eggPremiumDesbloqueado ? 1 : 0)
                 + (eggGamerDesbloqueado ? 1 : 0) + (eggLeyendasDesbloqueado ? 1 : 0)
    cumplidos := Map(
        "primera",       totalSecs >= 1,
        "centurion",     totalSecs >= 100,
        "millennium",    totalSecs >= 1000,
        "kiko",          totalSecs >= 67,
        "jbs",           totalSecs >= 5000,
        "resistencia",   totalHorasGuardadas >= 24,
        "marathon",      sesionHoras >= 8,
        "phantom",       streakMax >= 50,
        "destructor",    totalDestru >= 10,
        "lucky",         totalCriticos >= 1,
        "luckyMax",      totalCriticos >= 50,
        "coleccionista", eggsCount >= 3,
        "godmode",       eggsCount >= 8,
        "gamerpack",     eggGamerDesbloqueado,
        "leyendaspack",  eggLeyendasDesbloqueado,
        "themeShadow",   eggShadowDesbloqueado,
        "themeCosmos",   eggDesbloqueado,
        "themeVoid",     eggVoidDesbloqueado,
        "themeSolar",    eggSolarDesbloqueado,
        "themeBlanco",   eggBlancoDesbloqueado,
        "themePremium",  eggPremiumDesbloqueado
    )
    for l in logros {
        if (!l.desbloqueado && cumplidos.Has(l.id) && cumplidos[l.id]) {
            l.desbloqueado := true
            GuardarLogro(l.id)
            MostrarToast(Chr(0x1F3C5) "  LOGRO: " l.nombre, 4000, "FFD700", "1A1A00")
        }
    }
}

AbrirPanelLogros(*) {
    global logros, logrosGui, logrosGuiVisible, logrosPagina
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto

    if (logrosGuiVisible && IsObject(logrosGui)) {
        try LimpiarHoverGui(logrosGui)
        try logrosGui.Destroy()
        logrosGuiVisible := false
        return
    }

    logrosPagina := 0
    MostrarPaginaLogrosGrid(logrosPagina)
}

MostrarPaginaLogrosGrid(pagina) {
    global logros, logrosGui, logrosGuiVisible, logrosPagina
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto

    if (IsObject(logrosGui)) {
        try LimpiarHoverGui(logrosGui)
        try logrosGui.Destroy()
    }

    ; Filtrar logros por página
    logrosEnPagina := []
    for l in logros {
        if (l.HasProp("pagina") && l.pagina = pagina)
            logrosEnPagina.Push(l)
    }

    ; Nombres de páginas
    paginas := ["🎨 TEMAS", "🌐 TCT & 🔒 SP", "⚔ FRT", "∅ DSTV"]
    nombrePagina := paginas[pagina + 1]

    ; Tamaño FIJO como el libro de parches
    W := 400
    H := 328

    cols    := 3
    cellW   := 129
    cellH   := 40
    gap     := 2
    padding := 4

    logrosGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    logrosGui.BackColor := colorFondoPrincipal

    desbloqueadosCount := 0
    for l in logrosEnPagina
        if (l.desbloqueado)
            desbloqueadosCount += 1

    barr := logrosGui.Add("Text", "x0 y0 w" W " h30 Background" colorBarra " Center +0x200", Chr(0x1F3C5) "  " nombrePagina "  " Chr(0x2022) "  " desbloqueadosCount "/" logrosEnPagina.Length)
    barr.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => (LimpiarHoverGui(logrosGui), logrosGui.Destroy(), logrosGuiVisible := false))

    ; Layout en grid 3×N compacto — cabe en altura fija
    startY := 30 + padding
    contentH := H - 30 - padding - 40  ; altura disponible para logros
    for i, l in logrosEnPagina {
        col := Mod(i - 1, cols)
        row := (i - 1) // cols
        cx := padding + col * (cellW + gap)
        cy := startY + row * (cellH + gap)

        ; No mostrar si está fuera del área visible
        if (cy + cellH > startY + contentH)
            break

        if (l.desbloqueado) {
            cBg := colorBotonNormal
            cFg := colorBtnTexto
            iconC := "FFD700"
        } else {
            cBg := "2A2A2A"
            cFg := "888888"
            iconC := "666666"
        }
        cell := logrosGui.Add("Text", "x" cx " y" cy " w" cellW " h" cellH " Background" cBg, "")
        lblIcon := logrosGui.Add("Text", "x" (cx + 3) " y" (cy + 3) " w20 h" (cellH - 6) " Center Background" cBg " c" iconC, l.icono)
        lblIcon.SetFont("s11", "Segoe UI Emoji")
        lblName := logrosGui.Add("Text", "x" (cx + 25) " y" (cy + 2) " w" (cellW - 28) " h12 Background" cBg " c" cFg, l.nombre)
        lblName.SetFont("s7 Bold", "Segoe UI Semibold")
        lblDesc := logrosGui.Add("Text", "x" (cx + 25) " y" (cy + 16) " w" (cellW - 28) " h18 Background" cBg " c" cFg, l.desc)
        lblDesc.SetFont("s5 Italic", "Segoe UI")
    }

    ; Botones de navegación (como el libro de parches)
    btnPrev := logrosGui.Add("Text", "x20 y286 w120 h30 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                          Chr(0x25C0) "  Anterior")
    btnPrev.SetFont("s10 Bold", "Segoe UI Semibold")
    btnPrev.OnEvent("Click", (*) => CambiarPaginaLogrosGrid(pagina - 1))
    RegistrarHover(btnPrev, () => colorBotonNormal)

    lblCount := logrosGui.Add("Text", "x140 y292 w" (W - 280) " h20 +0x201 Background" colorFondoPrincipal " c" colorTextoPrincipal " Center")
    lblCount.SetFont("s10 Bold", "Segoe UI")
    lblCount.Value := (pagina + 1) " / 4"

    btnNext := logrosGui.Add("Text", "x" (W - 20 - 120) " y286 w120 h30 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center",
                          "Siguiente  " Chr(0x25B6))
    btnNext.SetFont("s10 Bold", "Segoe UI Semibold")
    btnNext.OnEvent("Click", (*) => CambiarPaginaLogrosGrid(pagina + 1))
    RegistrarHover(btnNext, () => colorBotonNormal)

    ; Deshabilitar botones en primera/última página
    if (pagina = 0) {
        btnPrev.Opt("Background888888 c666666")
    }
    if (pagina = 3) {
        btnNext.Opt("Background888888 c666666")
    }

    logrosGui.Show("w" W " h" H " Center")
    try RedondearVentana(logrosGui.Hwnd, 14)
    logrosGuiVisible := true
    logrosPagina := pagina
    RegistrarAutoCierre(logrosGui, (*) => (LimpiarHoverGui(logrosGui), logrosGui.Destroy(), logrosGuiVisible := false))
}

CambiarPaginaLogrosGrid(nuevaPagina) {
    if (nuevaPagina >= 0 && nuevaPagina <= 3)
        MostrarPaginaLogrosGrid(nuevaPagina)
}

FlashBarraHistorial() {
    global histFlashStep, historialBox, colorFondoHistorial
    if (histFlashStep <= 0) {
        SendMessage(0x0443, 0, HexToBGR(colorFondoHistorial), , "ahk_id " historialBox.Hwnd)
        DllCall("InvalidateRect", "Ptr", historialBox.Hwnd, "Ptr", 0, "Int", 1)
        return
    }
    t := histFlashStep / 5.0
    c := LerpHex(colorFondoHistorial, "FFFFFF", t * 0.35)
    SendMessage(0x0443, 0, HexToBGR(c), , "ahk_id " historialBox.Hwnd)
    DllCall("InvalidateRect", "Ptr", historialBox.Hwnd, "Ptr", 0, "Int", 1)
    histFlashStep -= 1
    SetTimer(FlashBarraHistorial, -50)
}

; (El scrollbar custom del historial se quitó en 30.7.6 — el scroll va solo
;  con la rueda, igual que el panel de temas, y así no tapa la decoración.)

PrependRichSilent(hRich, texto, hexColor) {
    static EM_SETSEL        := 0x00B1
    static EM_REPLACESEL    := 0x00C2
    static EM_SETCHARFORMAT := 0x0444
    static SCF_SELECTION    := 0x0001
    static CFM_COLOR        := 0x40000000
    SendMessage(EM_SETSEL, 0, 0, , "ahk_id " hRich)
    SendMessage(EM_REPLACESEL, 0, StrPtr(texto), , "ahk_id " hRich)
    textLen := StrLen(texto)
    SendMessage(EM_SETSEL, 0, textLen, , "ahk_id " hRich)
    cf := Buffer(60, 0)
    NumPut("UInt", 60, cf, 0)
    NumPut("UInt", CFM_COLOR, cf, 4)
    NumPut("UInt", 0, cf, 8)
    NumPut("UInt", HexToBGR(hexColor), cf, 20)
    SendMessage(EM_SETCHARFORMAT, SCF_SELECTION, cf.Ptr, , "ahk_id " hRich)
    SendMessage(EM_SETSEL, 0, 0, , "ahk_id " hRich)
    ; El RichEdit re-muestra su scrollbar nativa al cambiar contenido — re-ocultarla
    DllCall("ShowScrollBar", "Ptr", hRich, "Int", 1, "Int", 0)
}

RecolorRango(hRich, desde, hasta, hexColor) {
    static EM_SETSEL        := 0x00B1
    static EM_SETCHARFORMAT := 0x0444
    static SCF_SELECTION    := 0x0001
    static CFM_COLOR        := 0x40000000
    SendMessage(EM_SETSEL, desde, hasta, , "ahk_id " hRich)
    cf := Buffer(60, 0)
    NumPut("UInt", 60, cf, 0)
    NumPut("UInt", CFM_COLOR, cf, 4)
    NumPut("UInt", 0, cf, 8)
    NumPut("UInt", HexToBGR(hexColor), cf, 20)
    SendMessage(EM_SETCHARFORMAT, SCF_SELECTION, cf.Ptr, , "ahk_id " hRich)
    SendMessage(EM_SETSEL, 0, 0, , "ahk_id " hRich)
}

IniciarTypingReveal(hRich, linea, colorHex) {
    global typeRevealHwnd, typeRevealTotal, typeRevealPos, typeRevealColor, typeRevealActivo
    global colorFondoHistorial, optTypeReveal, ultimoScrollManual
    static EM_GETSCROLLPOS := 0x04DD, EM_SETSCROLLPOS := 0x04DE
    static EM_GETFIRSTVISIBLELINE := 0x00CE, EM_LINESCROLL := 0x00B6
    static EM_GETLINECOUNT := 0x00BA

    ; ¿El usuario está scrolleado hacia abajo Y movió la rueda hace <10s?
    ; Entonces está leyendo: no robarle la vista (se inserta la línea ya
    ; coloreada y se compensa el scroll). Pasados 10s sin tocar la rueda,
    ; el historial vuelve a su comportamiento normal: lo nuevo SIEMPRE arriba.
    firstVisAntes := SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, , "ahk_id " hRich)
    if (firstVisAntes > 0 && (A_TickCount - ultimoScrollManual) < 10000) {
        if (typeRevealActivo && typeRevealPos < typeRevealTotal)
            RecolorRango(typeRevealHwnd, typeRevealPos, typeRevealTotal, typeRevealColor)
        typeRevealActivo := false
        totalAntes := SendMessage(EM_GETLINECOUNT, 0, 0, , "ahk_id " hRich)
        PrependRichSilent(hRich, linea, colorHex)
        totalAhora := SendMessage(EM_GETLINECOUNT, 0, 0, , "ahk_id " hRich)
        firstVisAhora := SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, , "ahk_id " hRich)
        delta := (firstVisAntes + (totalAhora - totalAntes)) - firstVisAhora
        if (delta != 0)
            SendMessage(EM_LINESCROLL, 0, delta, , "ahk_id " hRich)
        return
    }

    if (!optTypeReveal) {
        if (typeRevealActivo && typeRevealPos < typeRevealTotal)
            RecolorRango(typeRevealHwnd, typeRevealPos, typeRevealTotal, typeRevealColor)
        typeRevealActivo := false
        PrependRichSilent(hRich, linea, colorHex)
        return
    }
    ; Flush anterior si sigue en curso
    if (typeRevealActivo && typeRevealPos < typeRevealTotal)
        RecolorRango(typeRevealHwnd, typeRevealPos, typeRevealTotal, typeRevealColor)
    ; Capturar scroll antes de insertar
    ptBuf := Buffer(8, 0)
    SendMessage(EM_GETSCROLLPOS, 0, ptBuf.Ptr, , "ahk_id " hRich)
    scrollYAntes := NumGet(ptBuf, 4, "Int")
    ; Insertar línea invisible (color = fondo)
    PrependRichSilent(hRich, linea, colorFondoHistorial)
    ; Scroll animado igual que AppendRichText
    if (scrollYAntes > 2) {
        pasos := 10
        loop pasos {
            t  := A_Index / pasos
            te := 1 - (1 - t) ** 3
            y  := Round(scrollYAntes * (1 - te))
            ptAnim := Buffer(8, 0)
            NumPut("Int", 0, ptAnim, 0)
            NumPut("Int", y, ptAnim, 4)
            SendMessage(EM_SETSCROLLPOS, 0, ptAnim.Ptr, , "ahk_id " hRich)
            Sleep(12)
        }
    }
    ptFinal := Buffer(8, 0)
    NumPut("Int", 0, ptFinal, 0)
    NumPut("Int", 0, ptFinal, 4)
    SendMessage(EM_SETSCROLLPOS, 0, ptFinal.Ptr, , "ahk_id " hRich)
    ; Estado reveal
    typeRevealHwnd  := hRich
    typeRevealTotal := StrLen(linea)
    typeRevealPos   := 0
    typeRevealColor := colorHex
    if (!typeRevealActivo) {
        typeRevealActivo := true
        SetTimer(TickTypingReveal, -20)
    }
}

TickTypingReveal() {
    global typeRevealHwnd, typeRevealTotal, typeRevealPos, typeRevealColor, typeRevealActivo
    chunkSize := 4
    newPos := Min(typeRevealPos + chunkSize, typeRevealTotal)
    if (newPos > typeRevealPos)
        RecolorRango(typeRevealHwnd, typeRevealPos, newPos, typeRevealColor)
    typeRevealPos := newPos
    if (typeRevealPos >= typeRevealTotal) {
        typeRevealActivo := false
        return
    }
    SetTimer(TickTypingReveal, -20)
}

; ===== FUNCIONES PRINCIPALES =====
; Lanza Brawlhalla — solo una vez por sesión del script.
; El flag se resetea automáticamente al reiniciar el script.
global brawlhallaLanzado := false

; ===== MODO FRT — spam clicks + cycle de teclas =====
; FrtClick: timer cada 50ms → 20 clicks/seg en (frtClickX, frtClickY)
FrtClick() {
    global activo, perfilActivo, frtClickX, frtClickY, scaleX, scaleY
    if (!activo || perfilActivo != 3)
        return
    x := Round(frtClickX * scaleX)
    y := Round(frtClickY * scaleY)
    MouseMove(x, y, 0)
    Click
}

; FrtKeyCycle: timer cada 150ms → cicla teclas 1,2,3,4,5,6,7
FrtKeyCycle() {
    global activo, perfilActivo, frtTeclas, frtIdxTecla
    if (!activo || perfilActivo != 3)
        return
    if (frtIdxTecla < 1 || frtIdxTecla > frtTeclas.Length)
        frtIdxTecla := 1
    Send "{" frtTeclas[frtIdxTecla] "}"
    frtIdxTecla++
    if (frtIdxTecla > frtTeclas.Length)
        frtIdxTecla := 1
}

; Activa o desactiva los timers de frt segun el estado actual.
ActualizarTimersFrt() {
    global activo, perfilActivo, frtIdxTecla
    if (activo && perfilActivo = 3) {
        frtIdxTecla := 1   ; reset al arrancar
        SetTimer(FrtClick, 50)       ; 20 clicks/seg
        SetTimer(FrtKeyCycle, 150)   ; tecla nueva cada 150ms
    } else {
        SetTimer(FrtClick, 0)
        SetTimer(FrtKeyCycle, 0)
    }
}

; Muestra/oculta los labels del historial relacionados con anti-AFK,
; secuencias, destrucciones y cooldowns segun el perfil activo.
; En frt (solo spam) y dstv (perfil vacio) esos labels son irrelevantes.
ActualizarVisibilidadFrt() {
    global perfilActivo, afkText, secuenciasLabel, destruccionesLabel
    global contadorLabel, cooldownText
    ocultar := (PerfilSinGestion())
    for ctrl in [afkText, secuenciasLabel, destruccionesLabel, contadorLabel, cooldownText] {
        if (IsObject(ctrl)) {
            try ctrl.Visible := !ocultar
        }
    }
}

; Lanza el juego asociado al perfil activo cuando se presiona Iniciar.
;   🌐 tct  (perfilActivo=1) → Brawlhalla via Steam
;   🔒 sp   (perfilActivo=2) → Brawlhalla via Steam (mismo juego, distinto layout/pasos)
;   ⚔ frt  (perfilActivo=3) → NO lanza nada, solo spam de clicks + teclas
;   ∅ dstv (perfilActivo=4) → NO lanza nada, sin pasos, sin spam (perfil vacio)
LanzarJuegoDelPerfil() {
    global brawlhallaLanzado, perfilActivo
    if (brawlhallaLanzado)
        return
    brawlhallaLanzado := true

    if (perfilActivo = 1 || perfilActivo = 2) {
        ; ── tct y sp ambos abren Brawlhalla ──
        ; Sin detectar si esta abierto: SIEMPRE ejecutar la secuencia Steam + Win + typing
        LanzarBrawlhallaConFoco()
        return
    }
    ; frt y dstv no lanzan ningun juego
}

; Secuencia robusta de lanzamiento (condicional):
; 1. Run steam://rungameid/291550 → Steam abre Brawlhalla (o lo trae al frente si ya esta)
; 2. Espera 30s — durante ese tiempo el macro sigue detectando pixeles normalmente
; 3. Si en esos 30s hubo deteccion REAL → Brawlhalla esta enfocado, no hacer nada
; 4. Si NO hubo deteccion → pulsa Windows + espera 5s + escribe "brawlhalla"
; Todo en timers encadenados (no bloquea el thread principal — heartbeat sigue vivo).
LanzarBrawlhallaConFoco() {
    global tiempoLanzamientoSteam, activo
    if (!activo)
        return  ; macro parado — no lanzar
    AgregarHistorial(Chr(0x1F504) " Abriendo Brawlhalla por Steam...", "FF8800")
    try Run("steam://rungameid/291550")
    tiempoLanzamientoSteam := A_TickCount
    SetTimer(LanzarBrawlhalla_CheckYEnfocar, -30000)  ; 30s despues
}

LanzarBrawlhalla_CheckYEnfocar() {
    global tiempoLanzamientoSteam, ultimaDeteccionReal, activo
    if (!activo)
        return  ; macro parado — abortar cadena
    ; Si el macro detecto algo durante los 30s, Brawlhalla esta enfocado y funcionando.
    if (ultimaDeteccionReal > tiempoLanzamientoSteam) {
        AgregarHistorial(Chr(0x2705) " Detección ", "00CC44")
        return
    }
    AgregarHistorial(Chr(0x26A0) " Sin detección tras 30s — forzando foco via Win + typing", "FF8800")
    try Send "{LWin}"
    SetTimer(LanzarBrawlhalla_TypeName, -5000)  ; 5s despues
}

LanzarBrawlhalla_TypeName() {
    global tiempoLanzamientoSteam, ultimaDeteccionReal, activo
    if (!activo) {
        ; Macro parado — cerrar menú Inicio que abrimos con Win y abortar
        try Send "{Escape}"
        return
    }
    ; Otra comprobacion: si en los ultimos 5s aparecio deteccion, abortar (cerrar menu Inicio)
    if (ultimaDeteccionReal > tiempoLanzamientoSteam) {
        AgregarHistorial(Chr(0x2705) " Detección recuperada — cerrando menú Inicio sin escribir", "00CC44")
        try Send "{Escape}"
        return
    }
    AgregarHistorial(Chr(0x2328) " Escribiendo 'brawlhalla' en Windows search...", "FF8800")
    try SendInput "brawlhalla"
    Sleep 1000
    if (!activo) {
        ; Pararon durante el Sleep — abortar antes del Enter para no abrir el juego
        try Send "{Escape}"
        return
    }
    try SendInput "{Enter}"
    ; BUCLE de reintento: si en 30s sigue sin detectar nada, repetir la secuencia
    ; Win + "brawlhalla" + Enter, y así hasta que el juego esté abierto de verdad.
    ; (CheckYEnfocar aborta solo si hay detección o si paran el macro, y Parar()
    ; cancela este timer — no se queda colgado.)
    SetTimer(LanzarBrawlhalla_CheckYEnfocar, -30000)
}

CheckBrawlhallaMinimizado() {
    global activo, perfilActivo, enDescanso
    ; frt (3) y dstv (4) no manejan Brawlhalla; en descanso el juego está cerrado a propósito
    if (!activo || PerfilSinGestion() || enDescanso)
        return
    try {
        if !ProcessExist("Brawlhalla.exe")
            return
        hwndBH := WinGetID("ahk_exe Brawlhalla.exe")
        if DllCall("IsIconic", "Ptr", hwndBH, "Int") {
            WinRestore("ahk_exe Brawlhalla.exe")
            AgregarHistorial("🔄 Brawlhalla estaba minimizado — restaurado", "FF8800")
        }
    }
}

; ═════ DESTRABAR CON 'c' (solo tct/sp) ═════
; Si Brawlhalla está ABIERTO pero el macro lleva >5s sin detectar NINGÚN pixel,
; está atascado en una pantalla que tapa todo (típico al despertar del descanso:
; el juego abre en un popup de noticias / "qué hay de nuevo"). Pulsar 'c' cada 5s
; confirma/cierra esos diálogos hasta que vuelve a detectar algo y sigue solo.
; Gates: solo tct(1)/sp(2); nunca en descanso (el juego está cerrado a propósito);
; nunca durante una partida (bloqueo global activo) para no estorbar al juego.
TickDestrabarC() {
    global activo, perfilActivo, enDescanso, ultimaDeteccionReal
    static avisado := false
    if (!activo || enDescanso || (perfilActivo != 1 && perfilActivo != 2)
        || BloqueoGlobalActivo() || !ProcessExist("Brawlhalla.exe")
        || (A_TickCount - ultimaDeteccionReal < 5000)) {
        avisado := false
        return
    }
    if (!avisado) {
        AgregarHistorial(Chr(0x2328) " Brawlhalla abierto sin detección — pulsando 'c' para destrabar", "FF8800")
        avisado := true
    }
    try SendInput "c"
}

; Alias retrocompatible
LanzarBrawlhalla() => LanzarJuegoDelPerfil()

Iniciar(*) {
    global activo, ultimoCambio, modoDestruccion, ultimoPasoEjecutado
    global pulsoBrilloDir, pulsoBrilloT, logosPulsoDir, logosPulsoT, colorBarra
    global logoVelObjetivo, logoVelMax
    global histUltimoTexto
    global enDescanso, cicloInicio, descansoInicio, brawlhallaLanzado
    global abrirBrawlAlIniciar
    ; Si el usuario inicia DURANTE el descanso del ciclo (solo tct/sp), manda
    ; el usuario: se cancela el descanso y arranca un ciclo nuevo de 8h.
    if (enDescanso && (perfilActivo = 1 || perfilActivo = 2)) {
        enDescanso := false
        cicloInicio := A_Now
        descansoInicio := ""
        brawlhallaLanzado := false   ; el juego está cerrado (descanso) — permitir relanzarlo
        GuardarCicloEstado()
        AgregarHistorial(Chr(0x23F0) " Descanso cancelado a mano — nuevo ciclo de 8h", "FF8800")
    }
    activo := true
    logoVelObjetivo := logoVelMax
    ultimoCambio := A_TickCount
    modoDestruccion := false
    ultimoPasoEjecutado := ""
    histUltimoTexto := ""
    pulsoBrilloT := 0.0
    pulsoBrilloDir := 1
    logosPulsoT := 0.0
    logosPulsoDir := 1
    ActualizarEstadoVisual()
    AnimarLucesEncendido()
    ; La animación de luces termina a ~300ms; re-redondear TODO después con la
    ; secuencia probada para que ni luces ni botones queden cuadrados al iniciar.
    SetTimer(RedondearFuerteTodos, -360)

    ; dstv (perfil 4) = solo detector, sin AFK ni Brawlhalla
    if (perfilActivo = 4) {
        SetTimer(EjecutarMacro, 50)
        SetTimer(ActualizarCooldowns, 100)
        SetTimer(TickCirculoDetectorDstv, 16)   ; detector circular ~60fps, en su propio timer
        IniciarTimer()
        EscribirHeartbeat()   ; capturar activo=1 al instante (no esperar 5s)
        EnviarWebhookEvento("iniciado")
        return
    }

    ; Lanzar Brawlhalla AHORA, antes de los timers que envían teclas (Esc/c)
    ; — si EjecutarMacro corre durante el Win+brawlhalla puede mandar Esc y cerrar el menú.
    ; Solo si el usuario tiene activada la opción (Personalizar → "Abrir Brawlhalla
    ; al iniciar"). Si está apagada, el macro arranca sin tocar Brawlhalla.
    if (abrirBrawlAlIniciar)
        LanzarJuegoDelPerfil()
    ultimoCambio := A_TickCount  ; resetea AFK contando desde DESPUÉS del lanzamiento

    SetTimer(EjecutarMacro, 50)
    SetTimer(ActualizarCooldowns, 100)
    SetTimer(ActualizarAFK, 200)
    if (perfilActivo = 1 || perfilActivo = 2)
        SetTimer(CheckBrawlhallaMinimizado, 10000)
    if (presetPulsoBar > 0)
        SetTimer(PulsoBarraActivo, presetPulsoBar)
    if (presetPulsoLogo > 0)
        SetTimer(PulsoLogoActivo, presetPulsoLogo)
    SetTimer(() => BarraShimmer(colorBarra), -1)
    IniciarTimer()
    ActualizarTimersFrt()  ; arranca timers de spam si perfilActivo=3
    EscribirHeartbeat()   ; capturar activo=1 al instante (no esperar 5s)
    EnviarWebhookEvento("iniciado")
}

Parar(*) {
    global activo, accionEnCurso, bloqueoGlobalHasta, modoDestruccion, ultimoPasoEjecutado
    global tiempoUltimoLanzamiento, barra, barraHistorial, colorBarra, logoMacro, colorLogoMacro
    global logoVelObjetivo
    global afkAlertaFlash, afkText, colorAFK, timerLabel, colorTextoPrincipal
    global circuloLockIdx
    activo := false
    circuloLockIdx := 0   ; soltar el enganche del detector circular — re-detectar fresco al reiniciar
    logoVelObjetivo := 0.0
    accionEnCurso := false
    bloqueoGlobalHasta := 0
    modoDestruccion := false
    ultimoPasoEjecutado := ""
    tiempoUltimoLanzamiento := 0
    ActualizarEstadoVisual()
    SetTimer(EjecutarMacro, 0)
    SetTimer(TickCirculoDetectorDstv, 0)
    SetTimer(ActualizarCooldowns, 0)
    try cooldownText.Value := "Detenido — pulsa Iniciar"   ; limpiar el visor de detección
    SetTimer(ActualizarAFK, 0)
    SetTimer(PulsoBarraActivo, 0)
    SetTimer(PulsoLogoActivo, 0)
    SetTimer(CheckBrawlhallaMinimizado, 0)
    ; Cancelar timers encadenados de lanzamiento de Brawlhalla (pueden estar
    ; programados para dispararse 30s/5s después y harían Win+typing aunque
    ; el macro ya esté parado)
    SetTimer(LanzarBrawlhalla_CheckYEnfocar, 0)
    SetTimer(LanzarBrawlhalla_TypeName, 0)
    ActualizarTimersFrt()  ; apaga los timers de spam si estaban activos
    ; Restaurar colores del timer AFK
    afkAlertaFlash := false
    afkText.Opt("c" colorAFK)
    timerLabel.Opt("c" colorTextoPrincipal)
    DllCall("InvalidateRect", "Ptr", timerLabel.Hwnd, "Ptr", 0, "Int", 1)
    ; Restaurar logo al color del tema
    logoMacro.SetFont("s49 c" colorLogoMacro " Bold", "Segoe UI Symbol")
    DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
    ; Shimmer de apagado y restaurar barra
    SetTimer(() => (BarraShimmer(colorBarra), barra.Opt("Background" colorBarra), barraHistorial.Opt("Background" colorBarra), DllCall("InvalidateRect", "Ptr", barra.Hwnd, "Ptr", 0, "Int", 1)), -1)
    PararTimer()
    EscribirHeartbeat()   ; capturar activo=0 al instante (el watchdog no debe re-arrancar)
    EnviarWebhookEvento("parado")
    ; Al parar cambian las luces (SetLuz) y el shimmer de la barra repinta encima:
    ; re-redondear TODO con la secuencia probada para que botones/luces no se cuadren.
    ; Igual que hace Iniciar(). Puntual (evento), nunca en bucle.
    SetTimer(RedondearFuerteTodos, -120)
}

; ===== ACTUALIZADOR =====
AbrirVentanaActualizacion(*) {
    global updateGui, updateGuiVisible
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBotonHover, colorBtnTexto, VERSION_ACTUAL
    global colorVentanaHistorial, colorFondoHistorial

    if (updateGuiVisible && IsObject(updateGui)) {
        try LimpiarHoverGui(updateGui)
        try updateGui.Destroy()
        updateGuiVisible := false
        return
    }

    updateGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    updateGui.BackColor := colorFondoPrincipal
    W := 340

    ; ── Barra superior (click = cerrar) ──
    barrUpd := updateGui.Add("Text", "x0 y0 w" W " h30 Background" colorBarra " Center +0x200", "  " Chr(0x1F504) "  Actualizador AFK Macro")
    barrUpd.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barrUpd.OnEvent("Click", (*) => (LimpiarHoverGui(updateGui), updateGui.Destroy(), updateGuiVisible := false))

    ; ── Cards de versión: INSTALADA → DISPONIBLE ──
    cardY := 44
    cardW := 118
    cardH := 66
    gap := 40
    startX := Round((W - (cardW * 2 + gap)) / 2)

    ; Card 1: INSTALADA
    updateGui.Add("Text", "x" startX " y" cardY " w" cardW " h" cardH " Background" colorBotonNormal, "")
    updateGui.Add("Text", "x" startX " y" (cardY + 6) " w" cardW " h14 Center Background" colorBotonNormal " c" colorBtnTexto, "INSTALADA").SetFont("s8 Bold", "Segoe UI")
    lblVerActual := updateGui.Add("Text", "x" startX " y" (cardY + 24) " w" cardW " h32 Center Background" colorBotonNormal " c" colorBtnTexto, "v" VERSION_ACTUAL)
    lblVerActual.SetFont("s16 Bold", "Segoe UI Semibold")

    ; Flecha entre cards
    arrowX := startX + cardW
    lblFlecha := updateGui.Add("Text", "x" arrowX " y" (cardY + Round(cardH / 2) - 14) " w" gap " h28 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x2192))
    lblFlecha.SetFont("s18", "Segoe UI Semibold")

    ; Card 2: DISPONIBLE
    card2X := startX + cardW + gap
    updateGui.Add("Text", "x" card2X " y" cardY " w" cardW " h" cardH " Background" colorBotonNormal, "")
    updateGui.Add("Text", "x" card2X " y" (cardY + 6) " w" cardW " h14 Center Background" colorBotonNormal " c" colorBtnTexto, "DISPONIBLE").SetFont("s8 Bold", "Segoe UI")
    lblVerRemota := updateGui.Add("Text", "x" card2X " y" (cardY + 24) " w" cardW " h32 Center Background" colorBotonNormal " c" colorBtnTexto, "...")
    lblVerRemota.SetFont("s16 Bold", "Segoe UI Semibold")

    ; ── Línea de estado con icono ──
    estadoY := cardY + cardH + 16
    lblEstado := updateGui.Add("Text", "x16 y" estadoY " w" (W - 32) " h36 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x23F3) "  Comprobando versión en GitHub...")
    lblEstado.SetFont("s10", "Segoe UI")

    ; ── Botón actualizar (deshabilitado por defecto) ──
    btnY := estadoY + 44
    btnActualizar := updateGui.Add("Text", "x16 y" btnY " w" (W - 32) " h38 +0x201 Background" colorBotonNormal " c555555 Center", Chr(0x2B07) "   Descargar e instalar")
    btnActualizar.SetFont("s11 c555555 Bold", "Segoe UI Semibold")
    btnActualizar._habilitado := false
    RegistrarHover(btnActualizar, () => colorBotonNormal)

    ; ── Link al repo de GitHub (para instalación directa por amigos) ──
    linkY := btnY + 38 + 12
    lblRepo := updateGui.Add("Text", "x16 y" linkY " w" (W - 32) " h16 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x1F517) "  Repo: github.com/mike305-droid/brawlmacro")
    lblRepo.SetFont("s9 Underline", "Segoe UI")
    lblRepo.OnEvent("Click", (*) => Run("https://github.com/mike305-droid/brawlmacro"))

    H := linkY + 16 + 14
    updateGui.Show("w" W " h" H " Center")
    RedondearVentana(updateGui.Hwnd, 14)
    updateGuiVisible := true
    RegistrarAutoCierre(updateGui, (*) => (LimpiarHoverGui(updateGui), updateGui.Destroy(), updateGuiVisible := false))

    ; Comprobar versión en segundo plano
    SetTimer(() => ComprobarVersionRemota(lblVerRemota, lblEstado, btnActualizar), -100)
}

ArrastrarVentanaActualizacion(*) {
    PostMessage(0xA1, 2,,, "A")
}

ComprobarVersionRemota(lblVer, lblEstado, btnAct) {
    global GITHUB_VERSION_URL, VERSION_ACTUAL, colorBotonNormal, colorBtnTexto, updateGuiVisible

    ; Helper: verifica si la ventana del actualizador sigue viva antes de tocar sus controles.
    ; Si el usuario cerró la ventana (manualmente o por auto-cierre 7s) mientras la request
    ; HTTP estaba en vuelo, los controles ya están destruidos y escribir en ellos peta.
    UIviva() {
        global updateGuiVisible, updateGui
        return updateGuiVisible && IsObject(updateGui)
    }

    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.SetTimeouts(5000, 5000, 5000, 5000)
        urlConTimestamp := GITHUB_VERSION_URL "?t=" A_TickCount
        whr.Open("GET", urlConTimestamp, false)
        whr.Send()

        if (!UIviva())
            return  ; el usuario cerró la ventana mientras la request estaba en vuelo

        if (whr.Status != 200) {
            try {
                lblVer.Value := "—"
                lblVer.Opt("cFF5555")
                lblEstado.Value := Chr(0x26A0) "  Sin conexión con GitHub. Revisa tu internet."
                lblEstado.Opt("cFF5555")
            }
            return
        }
        verRemota := Trim(whr.ResponseText, " `t`r`n")

        try lblVer.Value := "v" verRemota

        if (VersionMayor(verRemota, VERSION_ACTUAL)) {
            try {
                lblVer.Opt("c00DD66")
                lblEstado.Value := Chr(0x1F389) "  ¡Nueva versión disponible! Pulsa para instalar."
                lblEstado.Opt("c00DD66")
                btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
                btnAct.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Semibold")
                btnAct._habilitado := true
                btnAct.OnEvent("Click", (*) => DescargarYActualizar(verRemota, lblEstado, btnAct))
            }
        } else {
            try {
                lblVer.Opt("c" (ColorEsClaro(lblVer) ? "007733" : "88FFAA"))
                lblEstado.Value := Chr(0x2705) "  Estás al día con la última versión."
                lblEstado.Opt("c" (ColorEsClaro(lblEstado) ? "007733" : "88FFAA"))
            }
        }
    } catch Error as e {
        ; Si el catch ocurre PORQUE los controles ya están destruidos, no hacer nada.
        if (!UIviva())
            return
        try {
            lblVer.Value := "—"
            lblVer.Opt("cFF5555")
            lblEstado.Value := Chr(0x26A0) "  Error: " e.Message
            lblEstado.Opt("cFF5555")
        }
    }
}

VersionMayor(nueva, actual) {
    ; Compara versiones tipo "1.2.3"
    n := StrSplit(nueva,  ".")
    a := StrSplit(actual, ".")
    loop 3 {
        nv := (n.Length >= A_Index) ? Integer(n[A_Index]) : 0
        av := (a.Length >= A_Index) ? Integer(a[A_Index]) : 0
        if (nv > av)
            return true
        if (nv < av)
            return false
    }
    return false
}

ColorEsClaro(ctrl) {
    global colorFondoPrincipal
    r := Integer("0x" SubStr(colorFondoPrincipal, 1, 2))
    g := Integer("0x" SubStr(colorFondoPrincipal, 3, 2))
    b := Integer("0x" SubStr(colorFondoPrincipal, 5, 2))
    return ((r * 299 + g * 587 + b * 114) / 1000) > 128
}

DescargarYActualizar(verRemota, lblEstado, btnAct) {
    global GITHUB_SCRIPT_URL, updateGui, updateGuiVisible, configPath, perfilActivo, historialVisible

    lblEstado.Value := Chr(0x2B07) "  Descargando v" verRemota " desde GitHub..."
    lblEstado.Opt("cFFAA00")
    btnAct.Opt("Background" colorBotonNormal " c555555")
    btnAct.SetFont("s10 c555555 Bold", "Segoe UI Semibold")
    btnAct._habilitado := false

    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        ; Timeout más generoso para descargas grandes: 30s
        whr.SetTimeouts(5000, 5000, 30000, 30000)
        ; Añadir timestamp para evitar caché
        urlConTimestamp := GITHUB_SCRIPT_URL "?t=" A_TickCount
        whr.Open("GET", urlConTimestamp, false)
        whr.Send()
        if (whr.Status != 200) {
            lblEstado.Value := "Error al descargar (HTTP " whr.Status ")"
            lblEstado.Opt("cFF5555")
            btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
            btnAct.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
            btnAct._habilitado := true
            return
        }

        ; Obtener ruta del script de forma segura
        rutaScript := A_ScriptFullPath
        if (rutaScript = "" || !FileExist(rutaScript))
            rutaScript := A_ScriptDir "\" A_ScriptName
        if (rutaScript = "" || !FileExist(rutaScript)) {
            lblEstado.Value := "Error: no se encontró la ruta del script."
            lblEstado.Opt("cFF5555")
            btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
            btnAct.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
            btnAct._habilitado := true
            return
        }

        rutaTemp := A_ScriptDir "\~macro_update_temp.ahk"

        try FileDelete(rutaTemp)

        ; Escribir los BYTES crudos del response, no el texto decodificado.
        ; Si usáramos whr.ResponseText con encoding "UTF-8", AHK duplicaba el BOM
        ; (porque ResponseText ya devuelve U+FEFF al inicio, y "UTF-8" añade otro)
        ; → el archivo guardado empezaba con EF BB BF EF BB BF → AHK error en línea 1.
        try {
            stream := ComObject("ADODB.Stream")
            stream.Type := 1  ; adTypeBinary
            stream.Open()
            stream.Write(whr.ResponseBody)
            stream.SaveToFile(rutaTemp, 2)  ; adSaveCreateOverWrite
            stream.Close()
        } catch Error as eStream {
            ; Fallback por si ADODB.Stream falla: usar UTF-8-RAW para no duplicar el BOM
            FileAppend(whr.ResponseText, rutaTemp, "UTF-8-RAW")
        }

        if (!FileExist(rutaTemp)) {
            lblEstado.Value := "Error: no se pudo escribir el archivo temporal."
            lblEstado.Opt("cFF5555")
            btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
            btnAct.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
            btnAct._habilitado := true
            return
        }

        ; ── Guardia anti-caché: raw.githubusercontent puede servir una copia VIEJA
        ; durante unos minutos tras un push. Si la versión del archivo descargado
        ; es menor que la anunciada en parches.txt, NO instalar (antes esto podía
        ; hacer downgrade silencioso del macro y perder mejoras).
        verDescargada := ""
        try {
            contTemp := FileRead(rutaTemp, "UTF-8")
            if RegExMatch(contTemp, 'VERSION_ACTUAL\s*:=\s*"([\d.]+)"', &mV)
                verDescargada := mV[1]
        }
        if (verDescargada = "" || VersionMayor(verRemota, verDescargada)) {
            try FileDelete(rutaTemp)
            lblEstado.Value := Chr(0x23F3) " GitHub aún sirve la versión vieja (caché). Prueba en 2-3 min."
            lblEstado.Opt("cFFAA00")
            btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
            btnAct.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
            btnAct._habilitado := true
            return
        }

        FileCopy(rutaTemp, rutaScript, 1)
        try FileDelete(rutaTemp)

        ; Nueva versión → el egg COSMOS debe ganarse de nuevo

        ; Guardar estado antes de reiniciar (perfil, stats, posiciones, etc.)
        GuardarStats()
        GuardarRGBs()
        IniWrite(historialVisible ? 1 : 0, configPath, "UI", "HistorialVisible")
        IniWrite(perfilActivo, configPath, "UI", "PerfilActivo")
        GuardarPosiciones()

        lblEstado.Value := Chr(0x2728) "  Actualizado a v" verRemota " — reiniciando..."
        lblEstado.Opt("c00DD66")
        Sleep 1500
        try updateGui.Destroy()
        updateGuiVisible := false
        Reload()
    } catch Error as e {
        lblEstado.Value := "Error al guardar: " e.Message
        lblEstado.Opt("cFF5555")
        btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
            btnAct.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
            btnAct._habilitado := true
    }
}

; ===== OVERLAY DE PIXELES =====
ToggleOverlayPixeles(*) {
    global overlayPixeles, overlayVisible, btnOverlay, colorBotonNormal, colorBotonHover, colorBtnTexto

    if (overlayVisible) {
        SetTimer(OverlayHoverCheck, 0)
        try overlayPixeles.Destroy()
        overlayPixeles := ""
        overlayVisible := false
        ToolTip()
        btnOverlay.Opt("Background" colorBotonNormal " c" colorBtnTexto)
        DllCall("InvalidateRect", "Ptr", btnOverlay.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", btnOverlay.Hwnd)
    } else {
        DibujarOverlayPixeles()
        overlayVisible := true
        SetTimer(OverlayHoverCheck, 50)
        btnOverlay.Opt("Background" colorBotonHover " cFFFFFF")
        DllCall("InvalidateRect", "Ptr", btnOverlay.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", btnOverlay.Hwnd)
    }
}

DibujarOverlayPixeles() {
    global overlayPixeles, pasosPrioridad, pasosNormales, scaleX, scaleY, circuloPuntos

    try {
        if IsObject(overlayPixeles)
            overlayPixeles.Destroy()
    }

    sw := A_ScreenWidth
    sh := A_ScreenHeight

    overlayPixeles := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20")
    overlayPixeles.BackColor := "010101"
    WinSetTransColor("010101 160", overlayPixeles)   ; un poco más transparente que antes (era 200/255)
    overlayPixeles.Show("x0 y0 w" sw " h" sh " NoActivate")

    hWnd := overlayPixeles.Hwnd
    hDC  := DllCall("GetDC", "Ptr", hWnd, "Ptr")

    DibujarCuadrado(hDC, x1s, y1s, x2s, y2s, rgbColor) {
        ; Tamaño real del área de búsqueda, mínimo 4×4 para que se vea
        minSize := 4
        ancho := Max(x2s - x1s + 1, minSize)
        alto  := Max(y2s - y1s + 1, minSize)
        ; Centrar el mínimo sobre el punto si era 1px
        rx := x1s - Max(0, Round((minSize - (x2s - x1s + 1)) / 2))
        ry := y1s - Max(0, Round((minSize - (y2s - y1s + 1)) / 2))

        ; Convertir paso.color (0xRRGGBB) a COLORREF de GDI (0x00BBGGRR)
        r := (rgbColor >> 16) & 0xFF
        g := (rgbColor >> 8)  & 0xFF
        b := rgbColor & 0xFF
        ; Evitar el color 010101 exacto (es el TransColor de la overlay → invisible)
        if (r = 1 && g = 1 && b = 1)
            b := 2
        colorRef := (b << 16) | (g << 8) | r

        hBrush := DllCall("CreateSolidBrush", "UInt", colorRef, "Ptr")
        rect   := Buffer(16, 0)
        NumPut("Int", rx,          rect, 0)
        NumPut("Int", ry,          rect, 4)
        NumPut("Int", rx + ancho,  rect, 8)
        NumPut("Int", ry + alto,   rect, 12)
        DllCall("FillRect", "Ptr", hDC, "Ptr", rect, "Ptr", hBrush)
        DllCall("DeleteObject", "Ptr", hBrush)
        ; (borde removido — ahora el color del cuadrado ES el color del paso a detectar)
    }

    ; Dibuja el cuadrado 3×3 de 9 puntos (centro + sus 8 vecinos, CON diagonales)
    ; — réplica visual EXACTA del patrón que vigila el detector circular, en las
    ; mismas coordenadas de pantalla, para poder calibrar la alineación del
    ; círculo de 100 cruces a simple vista.
    DibujarCruz(hDC, cx, cy, rgbColor) {
        global scaleX, scaleY
        ; Vecinos escalados igual que el detector real (ContarMatchesCruces)
        bx := Max(1, Round(scaleX))
        by := Max(1, Round(scaleY))
        offsets := OffsetsCuadrado3x3(bx, by)
        tam := 3

        r := (rgbColor >> 16) & 0xFF
        g := (rgbColor >> 8)  & 0xFF
        b := rgbColor & 0xFF
        if (r = 1 && g = 1 && b = 1)
            b := 2
        colorRef := (b << 16) | (g << 8) | r
        hBrush := DllCall("CreateSolidBrush", "UInt", colorRef, "Ptr")

        for off in offsets {
            px := cx + off[1] - 1
            py := cy + off[2] - 1
            rect := Buffer(16, 0)
            NumPut("Int", px,          rect, 0)
            NumPut("Int", py,          rect, 4)
            NumPut("Int", px + tam,    rect, 8)
            NumPut("Int", py + tam,    rect, 12)
            DllCall("FillRect", "Ptr", hDC, "Ptr", rect, "Ptr", hBrush)
        }
        DllCall("DeleteObject", "Ptr", hBrush)
    }

    for paso in pasosPrioridad {
        if !PasoActivoEnPerfil(paso)
            continue
        x1s := Round(paso.x1 * scaleX)
        y1s := Round(paso.y1 * scaleY)
        x2s := Round(paso.x2 * scaleX)
        y2s := Round(paso.y2 * scaleY)
        colorPaso := paso.HasProp("color") ? paso.color : 0xFF00FF  ; magenta fallback
        DibujarCuadrado(hDC, x1s, y1s, x2s, y2s, colorPaso)
    }

    for paso in pasosNormales {
        if !PasoActivoEnPerfil(paso)
            continue
        colorPaso := paso.HasProp("color") ? paso.color : 0xFF00FF

        ; Detector circular dstv: en vez del cuadrado de búsqueda, dibujar las
        ; 100 cruces (cuadrados 3×3) exactamente donde el detector real las vigila
        ; (mismas coordenadas de pantalla — sirve para calibrar el radio/centro).
        if (paso.HasProp("circuloDetector") && paso.circuloDetector) {
            PrepararCirculoDetector(paso)
            for p in circuloPuntos
                DibujarCruz(hDC, p.x, p.y, colorPaso)
            continue
        }

        x1s := Round(paso.x1 * scaleX)
        y1s := Round(paso.y1 * scaleY)
        x2s := Round(paso.x2 * scaleX)
        y2s := Round(paso.y2 * scaleY)
        DibujarCuadrado(hDC, x1s, y1s, x2s, y2s, colorPaso)
    }

    DllCall("ReleaseDC", "Ptr", hWnd, "Ptr", hDC)
}

OverlayHoverCheck(*) {
    global pasosPrioridad, pasosNormales, scaleX, scaleY, overlayVisible
    static ultimoNombre := ""

    if (!overlayVisible)
        return

    MouseGetPos(&mx, &my)
    margen := 6   ; radio de detección extra alrededor del cuadrado

    encontrado := ""
    for paso in pasosPrioridad {
        if !PasoActivoEnPerfil(paso)
            continue
        x1s := Round(paso.x1 * scaleX) - margen
        y1s := Round(paso.y1 * scaleY) - margen
        x2s := Round(paso.x2 * scaleX) + margen
        y2s := Round(paso.y2 * scaleY) + margen
        if (mx >= x1s && mx <= x2s && my >= y1s && my <= y2s) {
            encontrado := paso.nombre
            break
        }
    }
    if (encontrado = "") {
        for paso in pasosNormales {
            if !PasoActivoEnPerfil(paso)
                continue
            x1s := Round(paso.x1 * scaleX) - margen
            y1s := Round(paso.y1 * scaleY) - margen
            x2s := Round(paso.x2 * scaleX) + margen
            y2s := Round(paso.y2 * scaleY) + margen
            if (mx >= x1s && mx <= x2s && my >= y1s && my <= y2s) {
                encontrado := paso.nombre
                break
            }
        }
    }

    if (encontrado != ultimoNombre) {
        ultimoNombre := encontrado
        if (encontrado != "")
            ToolTip(encontrado, mx + 14, my + 14)
        else
            ToolTip()
    }
}

; ════════════════════════════════════════════════════════════════════════
;  MEJORAS v31.2 — funciones nuevas
;    (1) Efectos de acción dinámicos   (2) Tema totalmente personalizable
;    (7) Hotkeys reasignables          Centro de Personalización
; ════════════════════════════════════════════════════════════════════════

; Helper GDI+: círculo relleno ARGB en (cx,cy) radio r.
DibujarEllipseGdip(g, cx, cy, r, argb) {
    br := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
    if (!br)
        return
    DllCall("gdiplus\GdipFillEllipse", "Ptr", g, "Ptr", br, "Float", cx - r, "Float", cy - r, "Float", r * 2.0, "Float", r * 2.0)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

; ─────────────────────── (1) EFECTOS DE ACCIÓN ───────────────────────
; Onda glow/zoom/fade que se dispara al detectar una acción (hook en LuzAccionFlash).
; Se pinta sobre el overlay de decoraciones (topmost, click-through), así funciona
; en CUALQUIER tema. No bloquea: solo arranca un timer que invalida el overlay.
EfectoAccion(catColor := "") {
    global efectosAccionActivos, efAccionFrame, efAccionMaxFrame, efAccionColor, colorLuzAccion, modoMini, efAccionEstilo
    global temas, temaActual
    if (!efectosAccionActivos)
        return
    try OndaBarra()   ; onda + brillo en la barra (glow/slide)
    if (modoMini)
        return
    ; Gojo y Sukuna tienen sus PROPIAS animaciones de acción (anillo Hollow Purple
    ; / cortes 解) — no lanzar la ráfaga elemental genérica de partículas para ellos.
    ; OndaBarra (arriba) y sus auras/cortes/partículas de fondo siguen funcionando.
    tmaAct := temas[temaActual]
    if (tmaAct.HasProp("unlock") && (tmaAct.unlock = "gojo" || tmaAct.unlock = "sukuna"))
        return
    efAccionColor := (catColor != "" && StrLen(catColor) = 6) ? catColor : colorLuzAccion
    ; Cada estilo tiene su propia duración (los que cruzan/caen necesitan más
    ; frames; los estallidos cortos menos). Ver FramesDeEstilo().
    efAccionMaxFrame := FramesDeEstilo(efAccionEstilo)
    efAccionFrame := efAccionMaxFrame
    try GenerarBurstAccion(efAccionEstilo)
    try ReposicionarOverlayDeco()
    SetTimer(AnimarEfectoAccion, 22)
}

AnimarEfectoAccion() {
    global efAccionFrame
    if (efAccionFrame <= 0) {
        SetTimer(AnimarEfectoAccion, 0)
        try InvalidarOverlayDeco()
        return
    }
    try ActualizarBurstAccion()
    efAccionFrame -= 1
    try InvalidarOverlayDeco()
}

; Crea la ráfaga de partículas para el estilo dado (categoría elemental del
; tema activo — la misma que EfectoDeTema). Se llama una vez al arrancar el
; efecto. Cada partícula representa el elemento del tema: gotas para agua,
; hojas para viento, abejas para miel, etc.
; Duración (frames) de la ráfaga según el estilo. Los que cruzan/caen o tienen
; ciclo de vida (subir+estallar, caer+salpicar) necesitan más frames.
FramesDeEstilo(estilo) {
    switch estilo {
        case "burbujas", "petalos": return 48
        case "nieve", "premium":    return 46
        case "lluvia", "matrix", "abejas": return 44
        case "hojas":    return 42
        case "estrellas", "brasas": return 40
        case "chispas":  return 34
        default:         return 32
    }
}

; ── Helpers de dibujo GDI para las ráfagas (color en BGR) ──
EscalarBGR(bgr, f) {   ; oscurece (f<1) hacia negro
    r := bgr & 0xFF, g := (bgr >> 8) & 0xFF, b := (bgr >> 16) & 0xFF
    f := Max(0.0, f)
    return (Round(b*f) << 16) | (Round(g*f) << 8) | Round(r*f)
}
AclararBGR(bgr, f) {   ; aclara (f en 0..1) hacia blanco
    r := bgr & 0xFF, g := (bgr >> 8) & 0xFF, b := (bgr >> 16) & 0xFF
    return (Round(b+(255-b)*f) << 16) | (Round(g+(255-g)*f) << 8) | Round(r+(255-r)*f)
}
LineaGDI(hdc, x1, y1, x2, y2, ancho, bgr) {
    p  := DllCall("CreatePen", "Int", 0, "Int", Max(1, Round(ancho)), "UInt", bgr, "Ptr")
    op := DllCall("SelectObject", "Ptr", hdc, "Ptr", p)
    DllCall("MoveToEx", "Ptr", hdc, "Int", Round(x1), "Int", Round(y1), "Ptr", 0)
    DllCall("LineTo",   "Ptr", hdc, "Int", Round(x2), "Int", Round(y2))
    DllCall("SelectObject", "Ptr", hdc, "Ptr", op)
    DllCall("DeleteObject", "Ptr", p)
}
AnilloGDI(hdc, cx, cy, r, ancho, bgr) {   ; círculo hueco
    nb := DllCall("GetStockObject", "Int", 5, "Ptr")   ; NULL_BRUSH
    p  := DllCall("CreatePen", "Int", 0, "Int", Max(1, Round(ancho)), "UInt", bgr, "Ptr")
    ob := DllCall("SelectObject", "Ptr", hdc, "Ptr", nb)
    op := DllCall("SelectObject", "Ptr", hdc, "Ptr", p)
    DllCall("Ellipse", "Ptr", hdc, "Int", Round(cx-r), "Int", Round(cy-r), "Int", Round(cx+r), "Int", Round(cy+r))
    DllCall("SelectObject", "Ptr", hdc, "Ptr", ob)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", op)
    DllCall("DeleteObject", "Ptr", p)
}
PoligonoGDI(hdc, pts, bgr) {   ; pts = array de [x,y]
    n := pts.Length
    if (n < 2)
        return
    buf := Buffer(n*8, 0)
    for i, pt in pts {
        NumPut("Int", Round(pt[1]), buf, (i-1)*8)
        NumPut("Int", Round(pt[2]), buf, (i-1)*8 + 4)
    }
    br  := DllCall("CreateSolidBrush", "UInt", bgr, "Ptr")
    ob  := DllCall("SelectObject", "Ptr", hdc, "Ptr", br)
    np  := DllCall("CreatePen", "Int", 5, "Int", 1, "UInt", bgr, "Ptr")   ; PS_NULL
    opn := DllCall("SelectObject", "Ptr", hdc, "Ptr", np)
    DllCall("Polygon", "Ptr", hdc, "Ptr", buf, "Int", n)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", ob)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", opn)
    DllCall("DeleteObject", "Ptr", br)
    DllCall("DeleteObject", "Ptr", np)
}

; Crea la ráfaga de partículas para el estilo dado. Cada estilo tiene su PROPIA
; coreografía (no un estallido genérico): estrellas fugaces con estela, rayos
; eléctricos quebrados, brasas que ascienden ondulando, copos de 6 brazos,
; lluvia con salpicadura, burbujas que suben y estallan, pétalos en espiral,
; código matrix con estela degradada, confeti arcoíris (premium)...
GenerarBurstAccion(estilo) {
    global efAccionParticulas, EFACCION_W, EFACCION_H
    efAccionParticulas := []
    w := EFACCION_W, h := EFACCION_H
    cx0 := w/2, cy0 := h*0.42
    switch estilo {
        case "lluvia":
            ; Lluvia que cae en diagonal y SALPICA al tocar el suelo
            loop 22
                efAccionParticulas.Push({ tipo:"gotalluvia", x:Random(0.0, w*1.0), y:Random(-h*0.5, h*0.4),
                    vx:Random(-2, 2)/10.0, vy:Random(11.0, 16.0), len:Random(10, 18), age:-1 })
        case "burbujas":
            ; Burbujas que SUBEN ondulando y ESTALLAN (anillo + esquirlas)
            loop 16
                efAccionParticulas.Push({ tipo:"burbuja", x:Random(0.0, w*1.0), y:Random(h*0.55, h*1.05),
                    vy:-Random(2.5, 5.0), amp:Random(5, 14)/10.0, ph:Random(0.0, 6.28),
                    r:Random(3, 8), popAt:Random(5, 60)*1.0, popped:false, popAge:0 })
        case "hojas":
            ; Hojas que cruzan REVOLOTEANDO (aleteo sinusoidal + giro)
            loop 16 {
                dir := (Mod(A_Index, 2) = 0) ? 1 : -1
                efAccionParticulas.Push({ tipo:"hoja", x:(dir = 1) ? -Random(0,40)*1.0 : w + Random(0,40),
                    y:Random(0.0, h*0.9), vx:Random(6.0, 11.0)*dir, drift:Random(2, 8)/10.0,
                    fph:Random(0.0, 6.28), rot:Random(0.0, 6.28), vrot:Random(-20, 20)/10.0, r:Random(5, 9) })
            }
        case "petalos":
            ; Pétalos que caen en ESPIRAL (sakura), giro suave
            loop 16
                efAccionParticulas.Push({ tipo:"petalo", bx:Random(0.0, w*1.0), x:0.0, y:Random(-h*0.3, h*0.2),
                    vy:Random(2.0, 3.8), amp:Random(14, 30)*1.0, sph:Random(0.0, 6.28), vsp:Random(15, 30)/100.0,
                    rot:Random(0.0, 6.28), vrot:Random(-15, 15)/100.0, r:Random(5, 8) })
        case "nieve":
            ; Copos de 6 brazos que derivan con vaivén y giran lento
            loop 22
                efAccionParticulas.Push({ tipo:"copo", x:Random(0.0, w*1.0), y:Random(-h*0.4, h*0.2),
                    vy:Random(2.5, 4.5), amp:Random(6, 16)/10.0, ph:Random(0.0, 6.28),
                    r:Random(3, 6), rot:Random(0.0, 6.28), vrot:Random(-15, 15)/100.0 })
        case "brasas":
            ; Brasas de fogata: ascienden ONDULANDO, encogen y se apagan
            loop 20
                efAccionParticulas.Push({ tipo:"ember", x:cx0 + Random(-70, 70), y:h*0.8 + Random(-15, 15),
                    vy:-Random(3.5, 7.5), amp:Random(4, 12)/10.0, ph:Random(0.0, 6.28), r:Random(3, 6)*1.0 })
        case "estrellas":
            ; Estrellas FUGACES con estela + destellos de 4 puntas que titilan
            loop 4
                efAccionParticulas.Push({ tipo:"fugaz", x:Random(0.0, w*0.6), y:Random(-10.0, h*0.3),
                    vx:Random(9.0, 15.0), vy:Random(5.0, 9.0), r:Random(2, 4)*1.0 })
            loop 12
                efAccionParticulas.Push({ tipo:"destello", x:Random(0.0, w*1.0), y:Random(0.0, h*0.85),
                    r:Random(3, 7)*1.0, ph:Random(0.0, 6.28), sp:Random(8, 16)/10.0 })
        case "chispas":
            ; RAYOS eléctricos quebrados saliendo del centro (parpadean) + chispas
            loop 5 {
                ang := Random(0.0, 6.28)
                seg := Random(4, 6)
                step := Random(16, 26)*1.0
                pts := []
                px := cx0, py := cy0
                loop seg {
                    px += Cos(ang)*step + Random(-8, 8)
                    py += Sin(ang)*step + Random(-8, 8)
                    pts.Push([px, py])
                }
                efAccionParticulas.Push({ tipo:"rayo", pts:pts, ox:cx0, oy:cy0, seed:A_Index })
            }
            loop 10 {
                a2 := Random(0.0, 6.28), s2 := Random(7.0, 12.0)
                efAccionParticulas.Push({ tipo:"chispa", x:cx0, y:cy0, vx:Cos(a2)*s2, vy:Sin(a2)*s2, len:Random(6, 12) })
            }
        case "matrix":
            ; Columnas de código con cabeza brillante y estela degradada
            loop 14
                efAccionParticulas.Push({ tipo:"matrix", x:Random(0, Round(w/12))*12.0, y:Random(-h*0.5, 0.0),
                    vy:Random(7.0, 12.0), len:Random(30, 60), segs:Random(5, 8) })
        case "abejas":
            ; Abejas zumbando alrededor del logo (centro 66,53 en la ventana)
            loop 9
                efAccionParticulas.Push({ tipo:"abeja", x:66.0 + Random(-18, 18), y:53.0 + Random(-18, 18),
                    ang:Random(0.0, 6.28), spd:Random(4.5, 8.0), wob:Random(0.0, 6.28) })
        case "premium":
            ; Confeti ARCOÍRIS: salen hacia arriba, giran y caen por gravedad
            loop 22 {
                hue := Mod(A_Index*16, 360)
                efAccionParticulas.Push({ tipo:"confeti", x:cx0 + Random(-40, 40), y:cy0 + Random(-20, 20),
                    vx:Random(-30, 30)/10.0, vy:Random(-40, 0)/10.0, rot:Random(0.0, 6.28), vrot:Random(-30, 30)/10.0,
                    w:Random(4, 8)*1.0, h:Random(6, 12)*1.0, bgr:HexToBGR(HSVaHex(hue, 1.0, 1.0)) })
            }
        default:
            ; Fallback: destellos titilantes (suave, no estallido)
            loop 12
                efAccionParticulas.Push({ tipo:"destello", x:Random(0.0, w*1.0), y:Random(0.0, h*0.85),
                    r:Random(3, 7)*1.0, ph:Random(0.0, 6.28), sp:Random(8, 16)/10.0 })
    }
}

; Avanza la simulación de la ráfaga un frame (posiciones/rotación).
ActualizarBurstAccion() {
    global efAccionParticulas, EFACCION_H
    for p in efAccionParticulas {
        switch p.tipo {
            case "abeja":
                p.wob += 0.7
                p.x += Cos(p.ang) * p.spd + Sin(p.wob) * 2.2
                p.y += Sin(p.ang) * p.spd + Cos(p.wob * 1.3) * 2.2
            case "hoja":
                p.fph += 0.5
                p.x += p.vx
                p.y += Sin(p.fph) * 2.0 + p.drift
                p.rot += p.vrot
            case "petalo":
                p.sph += p.vsp
                p.x := p.bx + Sin(p.sph) * p.amp
                p.y += p.vy
                p.rot += p.vrot
            case "copo":
                p.ph += 0.3
                p.x += Sin(p.ph) * p.amp
                p.y += p.vy
                p.rot += p.vrot
            case "ember":
                p.ph += 0.4
                p.x += Sin(p.ph) * p.amp
                p.y += p.vy
                p.vy *= 0.97
                p.r  *= 0.96
            case "burbuja":
                if (!p.popped) {
                    p.ph += 0.3
                    p.x += Sin(p.ph) * p.amp
                    p.y += p.vy
                    if (p.y <= p.popAt)
                        p.popped := true
                } else {
                    p.popAge += 1
                }
            case "gotalluvia":
                if (p.age < 0) {
                    p.x += p.vx
                    p.y += p.vy
                    if (p.y >= 185)   ; suelo ~ h*0.86 → empieza la salpicadura
                        p.age := 0
                } else {
                    p.age += 1
                }
            case "confeti":
                if (p.y < EFACCION_H*0.92) {
                    p.vy += 0.4
                    p.x += p.vx
                    p.y += p.vy
                    p.rot += p.vrot
                } else {
                    ; aterriza: se asienta en el "suelo" y deja de moverse
                    p.y := EFACCION_H*0.92
                    p.vx *= 0.85
                    p.vrot *= 0.85
                    p.x += p.vx
                    p.rot += p.vrot
                }
            case "matrix":
                p.y += p.vy
            case "rayo":
                ; estáticos: parpadean en el dibujo
            default:
                ; fugaz / chispa / destello (destello no tiene vx → queda fijo)
                if (p.HasProp("vx"))
                    p.x += p.vx, p.y += p.vy
        }
    }
}

; Dibuja la ráfaga actual en el HDC del overlay — cada categoría dibuja su
; propio elemento (gota/hoja/copo/brasa/estrella/chispa/matrix/abeja).
PintarEfectoAccion(hdc, cx, cy, frame, maxFrame) {
    global efAccionColor, efAccionEstilo, efAccionParticulas
    baseBgr := HexToBGR(efAccionColor)
    avance := (maxFrame - frame) / (maxFrame * 1.0)
    fade := 1.0 - avance   ; 1.0 al arrancar -> 0.0 al final
    nullBrush := DllCall("GetStockObject", "Int", 5, "Ptr")
    if (fade <= 0.02)
        return
    bright := AclararBGR(baseBgr, 0.55)
    dim    := EscalarBGR(baseBgr, 0.45)

    for p in efAccionParticulas {
        bgr := p.HasProp("bgr") ? p.bgr : baseBgr

        switch p.tipo {
            case "fugaz":
                ; estrella fugaz: estela degradada (larga tenue + corta viva) + cabeza
                LineaGDI(hdc, p.x - p.vx*1.6, p.y - p.vy*1.6, p.x, p.y, Max(1, Round(2*fade)), dim)
                LineaGDI(hdc, p.x - p.vx*0.8, p.y - p.vy*0.8, p.x, p.y, Max(1, Round(2*fade)), bgr)
                DibujarBolaSolida(hdc, p.x, p.y, Max(1.2, p.r*fade), bright, nullBrush)

            case "destello":
                s := p.r * fade * (0.35 + 0.65*(0.5 + 0.5*Sin(frame*p.sp + p.ph)))
                if (s < 0.6)
                    continue
                d := s*0.6
                LineaGDI(hdc, p.x - s, p.y, p.x + s, p.y, 1, bgr)
                LineaGDI(hdc, p.x, p.y - s, p.x, p.y + s, 1, bgr)
                LineaGDI(hdc, p.x - d, p.y - d, p.x + d, p.y + d, 1, dim)
                LineaGDI(hdc, p.x - d, p.y + d, p.x + d, p.y - d, 1, dim)
                DibujarBolaSolida(hdc, p.x, p.y, Max(0.8, s*0.28), bright, nullBrush)

            case "rayo":
                ; parpadeo eléctrico: saltar algunos frames
                if (Mod(frame + p.seed, 3) = 0)
                    continue
                px := p.ox, py := p.oy           ; halo ancho tenue
                for pt in p.pts {
                    LineaGDI(hdc, px, py, pt[1], pt[2], Max(2, Round(4*fade)), dim)
                    px := pt[1], py := pt[2]
                }
                px := p.ox, py := p.oy           ; núcleo fino brillante
                for pt in p.pts {
                    LineaGDI(hdc, px, py, pt[1], pt[2], Max(1, Round(2*fade)), bright)
                    px := pt[1], py := pt[2]
                }

            case "chispa":
                LineaGDI(hdc, p.x, p.y, p.x + (p.vx >= 0 ? 1 : -1)*p.len*0.4 + p.vx, p.y + p.vy, Max(1, Round(2*fade)), bgr)

            case "ember":
                DibujarBolaSolida(hdc, p.x, p.y, Max(0.8, p.r*(0.5 + fade*0.5)), dim, nullBrush)
                DibujarBolaSolida(hdc, p.x, p.y, Max(0.6, p.r*0.55*fade), bright, nullBrush)

            case "copo":
                rr := p.r * fade
                loop 3 {
                    a := p.rot + (A_Index-1) * 1.0472   ; 3 ejes a 60° → 6 brazos
                    LineaGDI(hdc, p.x - Cos(a)*rr, p.y - Sin(a)*rr, p.x + Cos(a)*rr, p.y + Sin(a)*rr, 1, bgr)
                }
                DibujarBolaSolida(hdc, p.x, p.y, Max(0.6, rr*0.2), bright, nullBrush)

            case "gotalluvia":
                if (p.age < 0) {
                    LineaGDI(hdc, p.x, p.y, p.x + p.vx*0.4, p.y + p.len, Max(1, Round(2*fade)), bgr)
                } else if (p.age <= 5) {
                    sr := 2 + p.age*1.6   ; salpicadura: dos brazos que se abren + gotita
                    LineaGDI(hdc, p.x - sr, 185 - sr*0.3, p.x - sr*0.4, 185 - sr*0.9, 1, bgr)
                    LineaGDI(hdc, p.x + sr, 185 - sr*0.3, p.x + sr*0.4, 185 - sr*0.9, 1, bgr)
                    DibujarBolaSolida(hdc, p.x, 185, Max(0.6, (5-p.age)*0.4), bright, nullBrush)
                }

            case "burbuja":
                if (!p.popped) {
                    AnilloGDI(hdc, p.x, p.y, Max(1, p.r*fade), 1, bgr)
                    DibujarBolaSolida(hdc, p.x - p.r*0.3, p.y - p.r*0.3, Max(0.5, p.r*0.18*fade), bright, nullBrush)
                } else if (p.popAge <= 5) {
                    er := p.r + p.popAge*2.2     ; anillo que estalla + 4 esquirlas
                    AnilloGDI(hdc, p.x, p.y, er, 1, dim)
                    loop 4 {
                        a := (A_Index/4) * 6.2831853
                        DibujarBolaSolida(hdc, p.x + Cos(a)*er*0.8, p.y + Sin(a)*er*0.8, Max(0.5, (5-p.popAge)*0.4), bgr, nullBrush)
                    }
                }

            case "hoja", "petalo":
                ratio := (p.tipo = "petalo") ? 0.7 : 0.45
                dx  := Cos(p.rot)*p.r,            dy  := Sin(p.rot)*p.r
                dx2 := Cos(p.rot + 1.5708)*(p.r*ratio), dy2 := Sin(p.rot + 1.5708)*(p.r*ratio)
                PoligonoGDI(hdc, [[p.x+dx, p.y+dy], [p.x+dx2, p.y+dy2], [p.x-dx, p.y-dy], [p.x-dx2, p.y-dy2]], bgr)
                if (p.tipo = "hoja")
                    LineaGDI(hdc, p.x-dx, p.y-dy, p.x+dx, p.y+dy, 1, dim)   ; vena central

            case "matrix":
                segLen := p.len / p.segs
                loop p.segs {
                    sy  := p.y - (A_Index-1)*segLen
                    col := (A_Index = 1) ? bright : EscalarBGR(baseBgr, 0.7 - (A_Index/p.segs)*0.55)
                    LineaGDI(hdc, p.x, sy, p.x, sy - segLen*0.6, (A_Index = 1) ? 3 : 2, col)
                }

            case "abeja":
                DibujarBolaSolida(hdc, p.x, p.y, 3.0 * fade, bgr, nullBrush)
                LineaGDI(hdc, p.x - 2, p.y, p.x + 2, p.y, 1, 0x000000)   ; raya
                LineaGDI(hdc, p.x - 1, p.y - 1, p.x - 3, p.y - 3, 1, bright)   ; alas
                LineaGDI(hdc, p.x + 1, p.y - 1, p.x + 3, p.y - 3, 1, bright)

            case "confeti":
                hw := p.w/2, hh := p.h/2
                ca := Cos(p.rot), sa := Sin(p.rot)
                PoligonoGDI(hdc, [
                    [p.x + (-hw*ca + hh*sa), p.y + (-hw*sa - hh*ca)],
                    [p.x + ( hw*ca + hh*sa), p.y + ( hw*sa - hh*ca)],
                    [p.x + ( hw*ca - hh*sa), p.y + ( hw*sa + hh*ca)],
                    [p.x + (-hw*ca - hh*sa), p.y + (-hw*sa + hh*ca)]], bgr)

            default:
                DibujarBolaSolida(hdc, p.x, p.y, Max(0.8, (p.HasProp("r") ? p.r : 3)*fade), bgr, nullBrush)
        }
    }
}

ToggleEfectosAccion() {
    global efectosAccionActivos, configPath
    efectosAccionActivos := !efectosAccionActivos
    IniWrite(efectosAccionActivos ? 1 : 0, configPath, "Efectos", "Accion")
}

ToggleAbrirBrawl() {
    global abrirBrawlAlIniciar, configPath
    abrirBrawlAlIniciar := !abrirBrawlAlIniciar
    IniWrite(abrirBrawlAlIniciar ? 1 : 0, configPath, "UI", "AbrirBrawlAlIniciar")
}

; ──────────────── CENTRO DE PERSONALIZACIÓN (hub) ────────────────
AbrirCentroPersonalizacion(*) {
    global centroPersGui, centroPersVisible, efectosAccionActivos, abrirBrawlAlIniciar
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto
    if (centroPersVisible && IsObject(centroPersGui)) {
        try LimpiarHoverGui(centroPersGui)
        try centroPersGui.Destroy()
        centroPersVisible := false
        return
    }
    centroPersGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    centroPersGui.BackColor := colorFondoPrincipal
    W := 250
    barr := centroPersGui.Add("Text", "x0 y0 w" W " h28 Background" colorBarra " Center +0x200", "  " Chr(0x1F58C) "  Personalización")
    barr.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " centroPersGui.Hwnd))
    barr.OnEvent("DoubleClick", (*) => CerrarCentroPersonalizacion())

    items := [
        {lbl: Chr(0x1F3A8) " Editor de tema",        fn: "tema"},
        {lbl: Chr(0x1F308) " RGB y Colores",          fn: "rgb"},
        {lbl: Chr(0x2728)  " Partículas",             fn: "part"},
        {lbl: Chr(0x2328)  " Atajos de teclado",      fn: "hotkeys"},
        {lbl: Chr(0x2699)  " Optimización",           fn: "opt"},
        {lbl: Chr(0x26A1)  " Velocidad del macro",    fn: "vel"},
    ]
    y := 38
    for it in items {
        b := centroPersGui.Add("Text", "x16 y" y " w" (W-32) " h32 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", it.lbl)
        b.SetFont("s10 Bold", "Segoe UI Semibold")
        accion := it.fn
        b.OnEvent("Click", CentroPersAbrir.Bind(accion))
        RegistrarHover(b, () => colorBotonNormal)
        y += 38
    }

    ; Toggle ON/OFF: abrir Brawlhalla al pulsar Iniciar (icono + color según estado)
    bBrawl := centroPersGui.Add("Text", "x16 y" y " w" (W-32) " h32 +0x201 Background" (abrirBrawlAlIniciar ? colorBarra : colorBotonNormal) " c" colorBtnTexto " Center",
        (abrirBrawlAlIniciar ? Chr(0x2714) : Chr(0x2716)) " Abrir Brawlhalla al iniciar")
    bBrawl.SetFont("s10 Bold", "Segoe UI Semibold")
    bBrawl.OnEvent("Click", (*) => (ToggleAbrirBrawl(), SetTimer(() => (CerrarCentroPersonalizacion(), AbrirCentroPersonalizacion()), -1)))
    RegistrarHover(bBrawl, () => (abrirBrawlAlIniciar ? colorBarra : colorBotonNormal))
    y += 38

    centroPersGui.Show("w" W " h" y " Center")
    RedondearVentana(centroPersGui.Hwnd, 12)
    centroPersVisible := true
    RegistrarAutoCierre(centroPersGui, CerrarCentroPersonalizacion)
}

CentroPersAbrir(accion, *) {
    switch accion {
        case "tema":    AbrirEditorTema()
        case "rgb":     AbrirPanelRGB()
        case "part":    AbrirPanelParticulas()
        case "hotkeys": AbrirEditorHotkeys()
        case "opt":     AbrirPanelOptimizacion()
        case "vel":     CiclarVelocidadPasos()
    }
}

CerrarCentroPersonalizacion(*) {
    global centroPersGui, centroPersVisible
    if (IsObject(centroPersGui)) {
        try LimpiarHoverGui(centroPersGui)
        try centroPersGui.Destroy()
    }
    centroPersVisible := false
}

RefrescarCentroPers() {
    global centroPersVisible
    if (centroPersVisible) {
        AbrirCentroPersonalizacion()
        AbrirCentroPersonalizacion()
    }
}

; ─────────────────────── (7) HOTKEYS REASIGNABLES ───────────────────────
; Acciones disponibles y la función que disparan.
HotkeyFnDe(accion) {
    switch accion {
        case "Iniciar":   return Iniciar
        case "Parar":     return Parar
        case "Historial": return ToggleHistorial
        case "Tema":      return CambiarTema
        case "Perfil":    return CambiarPerfil
        case "Mini":      return ToggleMiniMode
    }
    return ""
}

NombreAccionHotkey(accion) {
    switch accion {
        case "Iniciar":   return Chr(0x25B6) " Iniciar macro"
        case "Parar":     return Chr(0x25A0) " Parar macro"
        case "Historial": return Chr(0x1F4CB) " Mostrar/ocultar historial"
        case "Tema":      return Chr(0x25D0) " Cambiar tema"
        case "Perfil":    return "Cambiar perfil"
        case "Mini":      return Chr(0x25A3) " Modo mini"
    }
    return accion
}

; Lee del config y registra todas las hotkeys del usuario al arrancar.
RegistrarHotkeysUsuario() {
    global configPath
    _AplicarHotkey("Iniciar", IniRead(configPath, "Hotkeys", "Iniciar", "F1"))
    _AplicarHotkey("Parar",   IniRead(configPath, "Hotkeys", "Parar",   "F2"))
    _AplicarHotkey("Mini",    IniRead(configPath, "Hotkeys", "Mini",    ""))
    ActualizarLabelsHotkeys()
}

; Registra/reasigna una hotkey: apaga la tecla anterior de esa acción y enciende la nueva.
_AplicarHotkey(accion, tecla) {
    global hkRegistradas
    fn := HotkeyFnDe(accion)
    if (fn = "")
        return
    if (hkRegistradas.Has(accion)) {
        prev := hkRegistradas[accion]
        if (prev != "")
            try Hotkey(prev, fn, "Off")
    }
    hkRegistradas[accion] := tecla
    if (tecla = "")
        return
    try Hotkey(tecla, fn, "On")
}

; Texto legible de la tecla asignada a una acción ("F1", "L", "(sin asignar)").
MostrarTeclaHotkey(accion) {
    global hkRegistradas
    if (hkRegistradas.Has(accion) && hkRegistradas[accion] != "")
        return hkRegistradas[accion]
    return "(sin asignar)"
}

; Actualiza el texto de los botones Iniciar/Parar para reflejar su tecla actual.
ActualizarLabelsHotkeys() {
    global btnIniciar, btnParar, hkRegistradas
    tIni := (hkRegistradas.Has("Iniciar") && hkRegistradas["Iniciar"] != "") ? hkRegistradas["Iniciar"] : "-"
    tPar := (hkRegistradas.Has("Parar")   && hkRegistradas["Parar"]   != "") ? hkRegistradas["Parar"]   : "-"
    try btnIniciar.Text := Chr(9654) " Iniciar (" tIni ")"
    try btnParar.Text   := Chr(9632) " Parar (" tPar ")"
}

AbrirEditorHotkeys(*) {
    global hotkeysGui, hotkeysGuiVisible
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto, colorCooldown
    if (hotkeysGuiVisible && IsObject(hotkeysGui)) {
        try LimpiarHoverGui(hotkeysGui)
        try hotkeysGui.Destroy()
        hotkeysGuiVisible := false
        return
    }
    hotkeysGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    hotkeysGui.BackColor := colorFondoPrincipal
    W := 320
    barr := hotkeysGui.Add("Text", "x0 y0 w" W " h28 Background" colorBarra " Center +0x200", "  " Chr(0x2328) "  Atajos de teclado")
    barr.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " hotkeysGui.Hwnd))
    barr.OnEvent("DoubleClick", (*) => CerrarEditorHotkeys())

    acciones := ["Iniciar", "Parar", "Mini"]
    y := 38
    for accion in acciones {
        hotkeysGui.Add("Text", "x14 y" (y+4) " w150 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal, NombreAccionHotkey(accion)).SetFont("s9 Bold", "Segoe UI")
        lblKey := hotkeysGui.Add("Text", "x168 y" (y+4) " w64 h18 +0x201 Center c" colorCooldown " Background" colorFondoPrincipal, MostrarTeclaHotkey(accion))
        lblKey.SetFont("s9 Bold", "Consolas")
        bCambiar := hotkeysGui.Add("Text", "x236 y" y " w50 h24 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", "Cambiar")
        bCambiar.SetFont("s8 Bold", "Segoe UI")
        bCambiar.OnEvent("Click", CambiarHotkeyAccion.Bind(accion))
        RegistrarHover(bCambiar, () => colorBotonNormal)
        bQuitar := hotkeysGui.Add("Text", "x290 y" y " w20 h24 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(0x2716))
        bQuitar.SetFont("s8 Bold", "Segoe UI")
        bQuitar.OnEvent("Click", QuitarHotkeyAccion.Bind(accion))
        RegistrarHover(bQuitar, () => colorBotonNormal, () => "C42B1C")
        y += 30
    }
    hotkeysGui.Add("Text", "x14 y" (y+2) " w" (W-28) " h30 c" MezclarHex(colorTextoPrincipal, colorFondoPrincipal, 0.4) " Background" colorFondoPrincipal,
        "Pulsa 'Cambiar' y luego la tecla nueva (ej. L). Se guarda automáticamente.").SetFont("s7", "Segoe UI")
    hTot := y + 38
    hotkeysGui.Show("w" W " h" hTot " Center")
    RedondearVentana(hotkeysGui.Hwnd, 12)
    hotkeysGuiVisible := true
    RegistrarAutoCierre(hotkeysGui, CerrarEditorHotkeys, 20)
}

CerrarEditorHotkeys(*) {
    global hotkeysGui, hotkeysGuiVisible
    if (IsObject(hotkeysGui)) {
        try LimpiarHoverGui(hotkeysGui)
        try hotkeysGui.Destroy()
    }
    hotkeysGuiVisible := false
}

; Captura la siguiente tecla pulsada y la asigna a la acción.
CambiarHotkeyAccion(accion, *) {
    global configPath
    ToolTip("Pulsa la tecla nueva para '" accion "'...  (Esc cancela)")
    ih := InputHook("T5")     ; timeout 5s
    ih.KeyOpt("{All}", "E")   ; cualquier tecla termina la captura
    ih.Start()
    ih.Wait()
    ToolTip()
    key := ih.EndKey
    if (key = "" || key = "Escape")
        return
    ; EndKey puede venir como "vkXXscYYY" para teclas raras; quedarse con el nombre simple.
    _AplicarHotkey(accion, key)
    IniWrite(key, configPath, "Hotkeys", accion)
    ActualizarLabelsHotkeys()
    SetTimer(RefrescarEditorHotkeys, -1)
}

QuitarHotkeyAccion(accion, *) {
    global configPath
    _AplicarHotkey(accion, "")
    IniWrite("", configPath, "Hotkeys", accion)
    ActualizarLabelsHotkeys()
    SetTimer(RefrescarEditorHotkeys, -1)
}

RefrescarEditorHotkeys() {
    global hotkeysGuiVisible
    if (hotkeysGuiVisible) {
        AbrirEditorHotkeys()
        AbrirEditorHotkeys()
    }
}

; ─────────────────────── (2) TEMA PERSONALIZABLE ───────────────────────
; Genera la paleta COMPLETA de un tema a partir de solo 2 parámetros: el tono
; (hue, 0-360 — de qué color es) y la oscuridad (0-100 — 0=tema claro, 100=tema
; oscuro). Todo lo demás se deriva matemáticamente en HSV: nadie tiene que
; buscar ni escribir códigos hexadecimales. La barra/botón siempre es el color
; vívido que más destaca, independientemente de si el tema es claro u oscuro.
; Val/Sat del fondo según oscuridad — compartido con la tira de gradiente del
; slider para que la vista previa sea EXACTAMENTE el mismo cálculo.
ValSatFondo(oscuridad) {
    darkFrac := oscuridad / 100.0
    return [0.97 - 0.93 * darkFrac, 0.12 + 0.24 * darkFrac]
}

GenerarTemaPersonalizado(t, hue, oscuridad, deco := "", accion := "") {
    darkFrac := oscuridad / 100.0
    esOscuro := (darkFrac > 0.5)

    ; Fondo: casi negro si es oscuro, casi blanco si es claro. Más tinte que
    ; antes (sat hasta 0.36) para que el tono se note también en el fondo.
    vs := ValSatFondo(oscuridad)
    fondoVal := vs[1], fondoSat := vs[2]
    t.fondo := HSVaHex(hue, fondoSat, fondoVal)

    ; Texto: contraste fuerte contra el fondo (con personalidad: tiñe del tono en vez de gris puro).
    t.texto := esOscuro ? HSVaHex(hue, 0.08, 0.94) : HSVaHex(hue, 0.45, 0.16)

    ; Barra/botón: el acento que siempre destaca. AHORA también responde a la
    ; oscuridad (más suave/pastel en temas claros, más profundo/neón en
    ; oscuros) además de rotar con el tono — así los 2 sliders dan variedad real.
    accSat := 0.55 + 0.35 * darkFrac
    accVal := 0.92 - 0.20 * darkFrac
    t.barra := HSVaHex(hue, accSat, accVal)
    t.boton := t.barra

    ; Texto sobre la barra/botón: blanco salvo que la barra sea muy clara (entonces oscuro).
    t.textoBarra := LuminanciaHex(t.barra) > 180 ? "1A1A1A" : "FFFFFF"
    t.btnTexto   := t.textoBarra

    t.hover := MezclarHex(t.barra, "FFFFFF", 0.22)

    ; Historial: un paso más en la misma dirección que el fondo (separación sutil).
    t.historial := esOscuro ? HSVaHex(hue, fondoSat, Max(0.0, fondoVal - 0.04))
                             : HSVaHex(hue, fondoSat, Min(1.0, fondoVal + 0.035))

    ; Acentos secundarios: tono desplazado para distinguirse del principal,
    ; también con más rango de saturación/brillo entre claro y oscuro.
    t.afk      := HSVaHex(Mod(hue + 40, 360), 0.60 + 0.30 * darkFrac, 0.95 - 0.15 * darkFrac)
    t.cooldown := HSVaHex(Mod(hue + 180, 360), 0.80, 0.95)

    t.logo       := t.texto
    t.histColor1 := t.texto
    t.histColor2 := t.afk
    t.histColor3 := t.barra

    ; Derivados ya usados por el resto del macro (luces, panel).
    t.panel     := MezclarHex(t.fondo, t.barra, 0.18)
    t.luzOn     := t.afk
    t.luzAccion := t.barra
    t.luzOff    := t.fondo

    ; Decoración (escena del borde) y efecto de acción/partículas elegidos por
    ; el usuario. "" = automático: DecoDeTema/EfectoDeTema los infieren del color.
    ; Se guardan SIEMPRE (aunque sea "") para poder volver a "automático".
    t.deco     := deco
    t.efAccion := accion
}

; ── Tiras de gradiente para los sliders (que "las líneas cambien de color") ──
; Hue: arcoíris completo 0-360°, fijo (no depende de la oscuridad).
CrearTiraHue(w, h) {
    bmp := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", w, "Int", h, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &bmp)
    if (!bmp)
        return 0
    g := 0
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", &g)
    loop w {
        x := A_Index - 1
        argb := 0xFF000000 | Integer("0x" HSVaHex(x / w * 360, 1.0, 1.0))
        br := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
        DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", br, "Float", x, "Float", 0, "Float", 1.2, "Float", h)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
    }
    hbm := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bmp, "Ptr*", &hbm, "UInt", 0)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)
    return hbm
}

; Oscuridad: claro→oscuro usando el tono actual (se regenera si cambia el hue).
CrearTiraOscuridad(w, h, hue) {
    bmp := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "Int", w, "Int", h, "Int", 0, "Int", 0x26200A, "Ptr", 0, "Ptr*", &bmp)
    if (!bmp)
        return 0
    g := 0
    DllCall("gdiplus\GdipGetImageGraphicsContext", "Ptr", bmp, "Ptr*", &g)
    loop w {
        x := A_Index - 1
        vs := ValSatFondo(x / w * 100)
        argb := 0xFF000000 | Integer("0x" HSVaHex(hue, vs[2], vs[1]))
        br := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
        DllCall("gdiplus\GdipFillRectangle", "Ptr", g, "Ptr", br, "Float", x, "Float", 0, "Float", 1.2, "Float", h)
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
    }
    hbm := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", bmp, "Ptr*", &hbm, "UInt", 0)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", bmp)
    return hbm
}

; Carga tono/oscuridad/decoración/acción guardados y regenera la paleta custom.
CargarTemaCustom() {
    global configPath, temas, temaCustomIdx, temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion
    if (!temaCustomIdx)
        return
    temaCustomHue       := Integer(IniRead(configPath, "TemaCustom", "Hue", "207"))
    temaCustomOscuridad := Integer(IniRead(configPath, "TemaCustom", "Oscuridad", "75"))
    temaCustomDeco      := IniRead(configPath, "TemaCustom", "Deco", "")
    temaCustomAccion    := IniRead(configPath, "TemaCustom", "Accion", "")
    GenerarTemaPersonalizado(temas[temaCustomIdx], temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion)
}

GuardarTemaCustom() {
    global configPath, temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion
    IniWrite(temaCustomHue, configPath, "TemaCustom", "Hue")
    IniWrite(temaCustomOscuridad, configPath, "TemaCustom", "Oscuridad")
    IniWrite(temaCustomDeco, configPath, "TemaCustom", "Deco")
    IniWrite(temaCustomAccion, configPath, "TemaCustom", "Accion")
}

; ── Opciones de los 2 selectores del editor (decoración + acción) ──
; Decoraciones = escenas del borde inferior con case real en PintarEscenaTema.
; "" (primera) = automática (DecoDeTema la infiere del color del tema).
TemaCustomDecoOpciones() {
    return ["", "hielo","iglu","gotas","menta","pasto","vainilla","ajedrez","mostaza","palmera"
        ,"nubes","luna","cielo","cactus","atardecer","melocoton","naranja","lavanda","lila"
        ,"sakura","rosa","chicle","miel","bambu","jungla","pinos","olas","submarino"
        ,"aurora","ceniza","grafito","abisal","cafe","portal","tundra","gema","neon","oro"
        ,"lava","sangre","vino","veneno","cobre","electrico","glitch","circuito","ciudadneon"
        ,"planeta","eclipse","void","fenix","diamantes","solnika","espadas","retrowave","chat"
        ,"spotify","mira","bloques","pokebola","naruto","onepiece","matrixlluvia"
        ,"nieve","hojas","brasas","burbujas","petalos","estrellas","matrix","chispas","lluvia"]
}

; Acciones = estilo de la ráfaga al detectar + las partículas flotantes (mismo
; vocabulario elemental). "" = automática (se infiere del color del tema).
TemaCustomAccionOpciones() {
    return ["", "nieve","brasas","estrellas","chispas","lluvia","matrix","burbujas","petalos","hojas"]
}

; Etiqueta legible de un estilo interno ("" → "Automática", resto capitalizado).
EtiquetaEstilo(s) {
    if (s = "")
        return "Automática"
    mapa := Map("matrixlluvia","Lluvia Matrix", "ciudadneon","Ciudad Neón", "solnika","Sol Nika"
        , "onepiece","One Piece", "abisal","Abismo")
    if (mapa.Has(s))
        return mapa[s]
    return Format("{:U}", SubStr(s, 1, 1)) SubStr(s, 2)
}

AplicarTransparencia(alpha) {
    global miGui, historialGui
    if (alpha > 255)
        alpha := 255
    if (alpha < 120)
        alpha := 120
    if (alpha >= 255) {
        try WinSetTransparent("Off", "ahk_id " miGui.Hwnd)
        if (IsObject(historialGui))
            try WinSetTransparent("Off", "ahk_id " historialGui.Hwnd)
    } else {
        try WinSetTransparent(alpha, "ahk_id " miGui.Hwnd)
        if (IsObject(historialGui))
            try WinSetTransparent(alpha, "ahk_id " historialGui.Hwnd)
    }
}

AplicarTransparenciaGuardada() {
    global configPath
    AplicarTransparencia(Integer(IniRead(configPath, "TemaCustom", "Alpha", "255")))
}

; Crea las 2 muestras (marco negro + relleno blanco) que marcan la posición
; actual sobre una tira de gradiente. Devuelve {outer, inner} para moverlas.
CrearMarcadorSlider(gui, y, h) {
    outer := gui.Add("Text", "x12 y" y " w4 h" h " Background000000", "")
    inner := gui.Add("Text", "x13 y" (y+1) " w2 h" (h-2) " BackgroundFFFFFF", "")
    return {outer: outer, inner: inner}
}

MoverMarcadorSlider(m, x) {
    try m.outer.Move(x)
    try m.inner.Move(x + 1)
}

AbrirEditorTema(*) {
    global editorTemaGui, editorTemaVisible, editorTemaCampos, configPath
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto
    global temaCustomHue, temaCustomOscuridad, editorTemaHbmHue, editorTemaHbmOsc
    if (editorTemaVisible && IsObject(editorTemaGui)) {
        try LimpiarHoverGui(editorTemaGui)
        try editorTemaGui.Destroy()
        editorTemaVisible := false
        return
    }
    ; Liberar tiras de una apertura anterior (no se borran solas con la Gui).
    if (editorTemaHbmHue) {
        try DllCall("DeleteObject", "Ptr", editorTemaHbmHue)
        editorTemaHbmHue := 0
    }
    if (editorTemaHbmOsc) {
        try DllCall("DeleteObject", "Ptr", editorTemaHbmOsc)
        editorTemaHbmOsc := 0
    }
    editorTemaGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    editorTemaGui.BackColor := colorFondoPrincipal
    editorTemaGui.SetFont("s9 c" colorTextoPrincipal, "Segoe UI")
    editorTemaCampos := Map()
    W := 400
    cSep := MezclarHex(colorBarra, colorFondoPrincipal, 0.55)   ; color de los separadores
    barr := editorTemaGui.Add("Text", "x0 y0 w" W " h30 Background" colorBarra " Center +0x200", "  " Chr(0x1F3A8) "  Editor de tema personalizado")
    barr.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => PostMessage(0xA1, 2,,, "ahk_id " editorTemaGui.Hwnd))
    barr.OnEvent("DoubleClick", (*) => CerrarEditorTema())

    ; Todo el tema se controla con 2 sliders: de qué COLOR es (tono) y qué tan
    ; OSCURO es (oscuridad). Cada slider tiene su tira de gradiente debajo
    ; (arcoíris / claro-oscuro) con una marca que indica la posición actual,
    ; así "la línea" sí cambia/muestra el color en todo momento.
    ; Line1/Page8: el clic en la barra del slider avanza de a poco (antes
    ; saltaba 1/5 del rango = 72° de golpe, lo que molestaba).
    yT := 40
    lblHue := editorTemaGui.Add("Text", "x14 y" yT " w372 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal,
        Chr(0x1F308) " Color: " temaCustomHue "°")
    lblHue.SetFont("s9 Bold", "Segoe UI")
    yT += 18
    editorTemaHbmHue := CrearTiraHue(376, 13)
    editorTemaGui.Add("Picture", "x12 y" yT " w376 h13", "HBITMAP:" editorTemaHbmHue)
    mHue := CrearMarcadorSlider(editorTemaGui, yT, 13)
    yT += 15
    sHue := editorTemaGui.Add("Slider", "x12 y" yT " w376 h22 NoTicks Line1 Page8 Range0-360", temaCustomHue)
    yT += 28

    lblOsc := editorTemaGui.Add("Text", "x14 y" yT " w372 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal,
        Chr(0x1F311) " Oscuridad: " temaCustomOscuridad "%")
    lblOsc.SetFont("s9 Bold", "Segoe UI")
    yT += 18
    editorTemaHbmOsc := CrearTiraOscuridad(376, 13, temaCustomHue)
    picOsc := editorTemaGui.Add("Picture", "x12 y" yT " w376 h13", "HBITMAP:" editorTemaHbmOsc)
    mOsc := CrearMarcadorSlider(editorTemaGui, yT, 13)
    yT += 15
    sOsc := editorTemaGui.Add("Slider", "x12 y" yT " w376 h22 NoTicks Line1 Page4 Range0-100", temaCustomOscuridad)
    yT += 30

    editorTemaCampos["sHue"]    := sHue
    editorTemaCampos["sOsc"]    := sOsc
    editorTemaCampos["lblHue"]  := lblHue
    editorTemaCampos["lblOsc"]  := lblOsc
    editorTemaCampos["picOsc"]  := picOsc
    editorTemaCampos["mHue"]    := mHue
    editorTemaCampos["mOsc"]    := mOsc
    MoverMarcadorSlider(mHue, 12 + Round(temaCustomHue / 360 * 372))
    MoverMarcadorSlider(mOsc, 12 + Round(temaCustomOscuridad / 100 * 372))
    sHue.OnEvent("Change", EditorTemaSliderChange)
    sOsc.OnEvent("Change", EditorTemaSliderChange)

    ; ── Separador + selectores de decoración y efecto de acción ──
    editorTemaGui.Add("Text", "x12 y" yT " w376 h1 Background" cSep, "")
    yT += 9
    dCic := CrearCicladorTema(editorTemaGui, Chr(0x2728) " Decoración", yT, EtiquetaEstilo(temaCustomDeco),
        colorTextoPrincipal, colorFondoPrincipal, colorBotonNormal, colorBtnTexto)
    dCic.prev.OnEvent("Click", EditorTemaCiclarDeco.Bind(-1))
    dCic.next.OnEvent("Click", EditorTemaCiclarDeco.Bind(1))
    RegistrarHover(dCic.prev, () => colorBotonNormal)
    RegistrarHover(dCic.next, () => colorBotonNormal)
    editorTemaCampos["dName"] := dCic.name
    yT += 30
    aCic := CrearCicladorTema(editorTemaGui, Chr(0x1F4A5) " Acción", yT, EtiquetaEstilo(temaCustomAccion),
        colorTextoPrincipal, colorFondoPrincipal, colorBotonNormal, colorBtnTexto)
    aCic.prev.OnEvent("Click", EditorTemaCiclarAccion.Bind(-1))
    aCic.next.OnEvent("Click", EditorTemaCiclarAccion.Bind(1))
    RegistrarHover(aCic.prev, () => colorBotonNormal)
    RegistrarHover(aCic.next, () => colorBotonNormal)
    editorTemaCampos["aName"] := aCic.name
    yT += 34

    editorTemaGui.Add("Text", "x12 y" yT " w376 h1 Background" cSep, "")
    yT += 9

    ; Vista previa: una mini-ventana de mentira con el header, el fondo, un
    ; botón y 2 líneas de historial — para ver cómo queda todo junto. Los
    ; colores se actualizan en vivo; la decoración/acción se ven en la ventana
    ; real del macro (se aplican en vivo al mover cualquier control).
    prev := {}
    GenerarTemaPersonalizado(prev, temaCustomHue, temaCustomOscuridad)
    mY := yT
    mHeader := editorTemaGui.Add("Text", "x12 y" mY " w376 h24 Center Background" prev.barra " c" prev.textoBarra, "Vista previa")
    mHeader.SetFont("s9 Bold", "Segoe UI")
    mBody := editorTemaGui.Add("Text", "x12 y" (mY+24) " w376 h54 Background" prev.fondo, "")
    mTxt := editorTemaGui.Add("Text", "x20 y" (mY+32) " w160 h18 Background" prev.fondo " c" prev.texto, "Texto de ejemplo")
    mBtn := editorTemaGui.Add("Text", "x20 y" (mY+54) " w90 h18 Center Background" prev.boton " c" prev.btnTexto, "Botón")
    mBtn.SetFont("s8 Bold", "Segoe UI")
    mHist := editorTemaGui.Add("Text", "x196 y" (mY+30) " w180 h42 Background" prev.historial, "")
    mH1 := editorTemaGui.Add("Text", "x202 y" (mY+34) " w168 h16 Background" prev.historial " c" prev.histColor1, Chr(0x25CF) " Evento detectado")
    mH1.SetFont("s7", "Segoe UI")
    mH2 := editorTemaGui.Add("Text", "x202 y" (mY+52) " w168 h16 Background" prev.historial " c" prev.cooldown, Chr(0x23F3) " Cooldown 5s")
    mH2.SetFont("s7", "Segoe UI")
    editorTemaCampos["mHeader"] := mHeader
    editorTemaCampos["mBody"]   := mBody
    editorTemaCampos["mTxt"]    := mTxt
    editorTemaCampos["mBtn"]    := mBtn
    editorTemaCampos["mHist"]   := mHist
    editorTemaCampos["mH1"]     := mH1
    editorTemaCampos["mH2"]     := mH2
    yT += 24 + 54 + 10

    ; Transparencia
    editorTemaGui.Add("Text", "x14 y" yT " w110 h18 c" colorTextoPrincipal " Background" colorFondoPrincipal, "Transparencia:").SetFont("s8 Bold", "Segoe UI")
    transp := [{lbl:"100%", v:255}, {lbl:"95%", v:242}, {lbl:"90%", v:230}, {lbl:"80%", v:204}]
    xb := 132.0
    actualA := Integer(IniRead(configPath, "TemaCustom", "Alpha", "255"))
    for it in transp {
        bg := (actualA = it.v) ? colorBarra : colorBotonNormal
        b := editorTemaGui.Add("Text", "x" Round(xb) " y" (yT-2) " w56 h22 +0x201 Background" bg " c" colorBtnTexto " Center", it.lbl)
        b.SetFont("s8 Bold", "Segoe UI")
        vv := it.v
        b.OnEvent("Click", SetTransparenciaCustom.Bind(vv))
        RegistrarHover(b, MakeColorFn(bg))
        xb += 60
    }
    yT += 32

    ; Botones de acción
    bAplicar := editorTemaGui.Add("Text", "x12 y" yT " w118 h30 +0x201 Background" colorBarra " c" colorBtnTexto " Center", Chr(0x2714) " Aplicar")
    bAplicar.SetFont("s9 Bold", "Segoe UI Semibold")
    bAplicar.OnEvent("Click", (*) => EditorTemaAplicar())
    RegistrarHover(bAplicar, () => colorBarra)
    bGuardar := editorTemaGui.Add("Text", "x136 y" yT " w128 h30 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(0x1F4BE) " Activar tema")
    bGuardar.SetFont("s9 Bold", "Segoe UI Semibold")
    bGuardar.OnEvent("Click", (*) => EditorTemaActivar())
    RegistrarHover(bGuardar, () => colorBotonNormal)
    bReset := editorTemaGui.Add("Text", "x270 y" yT " w118 h30 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(0x21BA) " Restablecer")
    bReset.SetFont("s9 Bold", "Segoe UI Semibold")
    bReset.OnEvent("Click", (*) => EditorTemaReset())
    RegistrarHover(bReset, () => colorBotonNormal)
    yT += 40

    editorTemaGui.Show("w" W " h" yT " Center")
    RedondearVentana(editorTemaGui.Hwnd, 12)
    editorTemaVisible := true
    RegistrarAutoCierre(editorTemaGui, CerrarEditorTema, 30)
}

; Crea un selector ◀ [nombre] ▶ (mismo idioma visual que el resto del macro).
CrearCicladorTema(gui, etiqueta, y, valorActual, lblColor, fondoColor, btnColor, btnTextoColor) {
    gui.Add("Text", "x14 y" (y+5) " w94 h18 c" lblColor " Background" fondoColor, etiqueta).SetFont("s8 Bold", "Segoe UI")
    bPrev := gui.Add("Text", "x112 y" y " w26 h26 +0x201 Background" btnColor " c" btnTextoColor " Center", Chr(0x25C0))
    bPrev.SetFont("s9 Bold", "Segoe UI")
    name := gui.Add("Text", "x142 y" y " w216 h26 +0x201 Background" btnColor " c" btnTextoColor " Center", valorActual)
    name.SetFont("s9", "Segoe UI")
    bNext := gui.Add("Text", "x362 y" y " w26 h26 +0x201 Background" btnColor " c" btnTextoColor " Center", Chr(0x25B6))
    bNext.SetFont("s9 Bold", "Segoe UI")
    return {prev: bPrev, next: bNext, name: name}
}

; Cicla la decoración (escena) elegida y dispara el preview en vivo.
EditorTemaCiclarDeco(dir, *) {
    global temaCustomDeco, editorTemaCampos
    ops := TemaCustomDecoOpciones()
    idx := 1
    for i, v in ops {
        if (v = temaCustomDeco) {
            idx := i
            break
        }
    }
    idx := Mod(idx - 1 + dir + ops.Length, ops.Length) + 1
    temaCustomDeco := ops[idx]
    try editorTemaCampos["dName"].Text := EtiquetaEstilo(temaCustomDeco)
    EditorTemaLiveTrigger()
}

; Cicla el efecto de acción (ráfaga + partículas) elegido y dispara el preview.
EditorTemaCiclarAccion(dir, *) {
    global temaCustomAccion, editorTemaCampos
    ops := TemaCustomAccionOpciones()
    idx := 1
    for i, v in ops {
        if (v = temaCustomAccion) {
            idx := i
            break
        }
    }
    idx := Mod(idx - 1 + dir + ops.Length, ops.Length) + 1
    temaCustomAccion := ops[idx]
    try editorTemaCampos["aName"].Text := EtiquetaEstilo(temaCustomAccion)
    EditorTemaLiveTrigger()
}

; Throttle del preview en vivo: aplica el tema a la ventana REAL como mucho cada
; ~40ms aunque el slider dispare decenas de eventos al arrastrar (evita lag).
EditorTemaLiveTrigger() {
    global editorTemaLiveArmed
    if (!editorTemaLiveArmed) {
        editorTemaLiveArmed := true
        SetTimer(EditorTemaLiveApply, -40)
    }
}

EditorTemaLiveApply() {
    global editorTemaLiveArmed, editorTemaCampos, editorTemaVisible, temas, temaCustomIdx, temaActual
    global temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion
    editorTemaLiveArmed := false
    ; Si el editor se cerró entre el arme del timer y este disparo, los controles
    ; ya no existen — abortar para no leer .Value de un control destruido.
    if (!editorTemaVisible || !editorTemaCampos.Has("sHue") || !editorTemaCampos.Has("sOsc"))
        return
    try {
        temaCustomHue       := editorTemaCampos["sHue"].Value
        temaCustomOscuridad := editorTemaCampos["sOsc"].Value
    } catch
        return
    GenerarTemaPersonalizado(temas[temaCustomIdx], temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion)
    temaActual := temaCustomIdx
    AplicarTema(temas[temaCustomIdx], false)
}

; Se dispara al mover cualquiera de los 2 sliders: recalcula etiquetas,
; marcas de posición, la tira de oscuridad (depende del tono) y la
; vista previa en vivo, sin tocar aún el tema activo (eso lo hacen los botones).
EditorTemaSliderChange(*) {
    global editorTemaCampos, editorTemaHbmOsc
    if (!editorTemaCampos.Has("sHue") || !editorTemaCampos.Has("sOsc"))
        return
    hue := editorTemaCampos["sHue"].Value
    osc := editorTemaCampos["sOsc"].Value
    try editorTemaCampos["lblHue"].Text := Chr(0x1F308) " Color: " hue "°"
    try editorTemaCampos["lblOsc"].Text := Chr(0x1F311) " Oscuridad: " osc "%"
    MoverMarcadorSlider(editorTemaCampos["mHue"], 12 + Round(hue / 360 * 372))
    MoverMarcadorSlider(editorTemaCampos["mOsc"], 12 + Round(osc / 100 * 372))

    ; La tira de oscuridad se tiñe del tono actual — regenerarla al vuelo.
    nuevoHbm := CrearTiraOscuridad(376, 13, hue)
    if (nuevoHbm) {
        try editorTemaCampos["picOsc"].Value := "HBITMAP:" nuevoHbm
        if (editorTemaHbmOsc)
            try DllCall("DeleteObject", "Ptr", editorTemaHbmOsc)
        editorTemaHbmOsc := nuevoHbm
    }

    prev := {}
    GenerarTemaPersonalizado(prev, hue, osc)
    try editorTemaCampos["mHeader"].Opt("Background" prev.barra " c" prev.textoBarra)
    try editorTemaCampos["mBody"].Opt("Background" prev.fondo)
    try editorTemaCampos["mTxt"].Opt("Background" prev.fondo " c" prev.texto)
    try editorTemaCampos["mBtn"].Opt("Background" prev.boton " c" prev.btnTexto)
    try editorTemaCampos["mHist"].Opt("Background" prev.historial)
    try editorTemaCampos["mH1"].Opt("Background" prev.historial " c" prev.histColor1)
    try editorTemaCampos["mH2"].Opt("Background" prev.historial " c" prev.cooldown)

    ; Aplicar en vivo a la ventana real del macro (throttled) para verlo de verdad.
    EditorTemaLiveTrigger()
}

CerrarEditorTema(*) {
    global editorTemaGui, editorTemaVisible, editorTemaHbmHue, editorTemaHbmOsc, editorTemaLiveArmed
    ; Cancelar cualquier preview en vivo pendiente para que no se dispare tras cerrar.
    SetTimer(EditorTemaLiveApply, 0)
    editorTemaLiveArmed := false
    if (IsObject(editorTemaGui)) {
        try LimpiarHoverGui(editorTemaGui)
        try editorTemaGui.Destroy()
    }
    editorTemaVisible := false
    if (editorTemaHbmHue) {
        try DllCall("DeleteObject", "Ptr", editorTemaHbmHue)
        editorTemaHbmHue := 0
    }
    if (editorTemaHbmOsc) {
        try DllCall("DeleteObject", "Ptr", editorTemaHbmOsc)
        editorTemaHbmOsc := 0
    }
}

; Lee los sliders, genera la paleta completa, la activa y la guarda.
EditorTemaAplicar() {
    global editorTemaCampos, temas, temaCustomIdx, temaActual, temaCustomHue, temaCustomOscuridad
    global temaCustomDeco, temaCustomAccion
    if (!editorTemaCampos.Has("sHue") || !editorTemaCampos.Has("sOsc"))
        return
    temaCustomHue       := editorTemaCampos["sHue"].Value
    temaCustomOscuridad := editorTemaCampos["sOsc"].Value
    GenerarTemaPersonalizado(temas[temaCustomIdx], temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion)
    GuardarTemaCustom()
    ; Activar el tema custom para ver el resultado de inmediato
    temaActual := temaCustomIdx
    AplicarTema(temas[temaCustomIdx], false)
    GuardarTema()
    AgregarHistorial(Chr(0x1F3A8) " Tema personalizado aplicado", "")
}

EditorTemaActivar() {
    global temas, temaCustomIdx, temaActual
    temaActual := temaCustomIdx
    AplicarTema(temas[temaCustomIdx], false)
    GuardarTema()
    AgregarHistorial(Chr(0x1F3A8) " Tema personalizado activado", "")
}

EditorTemaReset() {
    global configPath, temas, temaCustomIdx, temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion
    temaCustomHue := 207
    temaCustomOscuridad := 75
    temaCustomDeco := ""
    temaCustomAccion := ""
    GenerarTemaPersonalizado(temas[temaCustomIdx], temaCustomHue, temaCustomOscuridad, temaCustomDeco, temaCustomAccion)
    try IniDelete(configPath, "TemaCustom")
    GuardarTemaCustom()
    AplicarTransparencia(255)
    IniWrite(255, configPath, "TemaCustom", "Alpha")
    SetTimer(RefrescarEditorTema, -1)
}

SetTransparenciaCustom(v, *) {
    global configPath
    AplicarTransparencia(v)
    IniWrite(v, configPath, "TemaCustom", "Alpha")
    SetTimer(RefrescarEditorTema, -1)
}

RefrescarEditorTema() {
    global editorTemaVisible
    if (editorTemaVisible) {
        AbrirEditorTema()
        AbrirEditorTema()
    }
}


; Atajos de teclado: ahora TOTALMENTE personalizables (v31.2). Por defecto F1=Iniciar,
; F2=Parar, pero el usuario puede reasignar cualquier tecla desde el editor de atajos
; (botón ⌨ del Centro de Personalización). Se registran dinámicamente con Hotkey().
RegistrarHotkeysUsuario()

; ═════ SCROLL DEL HISTORIAL POR TECLADO Y RUEDA ═════
; Activos cuando el ratón está sobre la ventana del historial.
#HotIf RatonSobreHistorial()
WheelUp::ScrollHistorial(-3)
WheelDown::ScrollHistorial(3)
#HotIf

RatonSobreHistorial() {
    global historialGui, historialVisible
    if (!historialVisible || !IsObject(historialGui))
        return false
    try {
        MouseGetPos(&mx, &my,, &winHwnd)
        return winHwnd = historialGui.Hwnd
    }
    return false
}

ScrollHistorial(lineas) {
    global historialBox, ultimoScrollManual
    if (!IsObject(historialBox))
        return
    static EM_LINESCROLL := 0x00B6
    ultimoScrollManual := A_TickCount   ; el usuario está leyendo — respetar su vista un rato
    try SendMessage(EM_LINESCROLL, 0, lineas, , "ahk_id " historialBox.Hwnd)
}


; ===== TEST TEMPORAL AUTOMATIZADO (se elimina tras la prueba) =====
global testTraceOn := false
if (A_Args.Length && A_Args[1] = "testtemas") {
    testTraceOn := true
    SetTimer(TestCicloTemas, 1400)
}

TestTrace(s) {
    global testTraceOn
    if (IsSet(testTraceOn) && testTraceOn)
        try FileAppend(A_TickCount " " s "`n", A_ScriptDir "\test_trace.log")
}

TestCicloTemas() {
    static ciclo := 0
    global temas, temaActual, temaEnTransicion
    if (temaEnTransicion)
        return
    ciclo++
    idx := Mod(ciclo + 24, 40) + 1
    temaActual := idx
    hProc := DllCall("GetCurrentProcess", "Ptr")
    gdi := DllCall("GetGuiResources", "Ptr", hProc, "UInt", 0, "UInt")
    usr := DllCall("GetGuiResources", "Ptr", hProc, "UInt", 1, "UInt")
    FileAppend(A_Now " ciclo=" ciclo " tema=" idx " (" temas[idx].nombre ") GDI=" gdi " USER=" usr "`n", A_ScriptDir "\test_temas.log")
    TransicionTema(temas[idx], false)
    if (ciclo >= 80) {
        SetTimer(TestCicloTemas, 0)
        FileAppend("FIN_OK`n", A_ScriptDir "\test_temas.log")
        ExitApp()
    }
}
