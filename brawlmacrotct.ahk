#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode("Pixel", "Screen")
CoordMode("Mouse", "Screen")

; ===== CONFIGURACION =====
configPath := A_ScriptDir "\brawlmacro_config.ini"
global eggsBackupPath := A_ScriptDir "\brawlmacro_eggs.txt"
global VERSION_ACTUAL := "26.6.8"

; ===== TEMAS =====
temas := [
    { nombre:"Hielo",      fondo:"E8F4FD", texto:"1A5276", barra:"85C1E9", textoBarra:"FFFFFF", historial:"F0F9FF", panel:"D6EAF8", cooldown:"E74C3C", afk:"2980B9", boton:"85C1E9", hover:"AED6F1", logo:"1A5276", luzOn:"2471A3", luzAccion:"2E86C1", luzOff:"1A5276",  btnTexto:"FFFFFF", histColor1:"1A5276", histColor2:"2E86C1", histColor3:"85C1E9" },
    { nombre:"Agua",       fondo:"D8F3F0", texto:"064C55", barra:"2E9E9A", textoBarra:"FFFFFF", historial:"ECFBF8", panel:"C7EDE8", cooldown:"D94848", afk:"1769AA", boton:"2E9E9A", hover:"4DB9B5", logo:"003C42", luzOn:"004A47", luzAccion:"00635F", luzOff:"003236",  btnTexto:"FFFFFF", histColor1:"064C55", histColor2:"00635F", histColor3:"2E9E9A" },
    { nombre:"Sakura",     fondo:"FFF5F8", texto:"8B2252", barra:"F48FB1", textoBarra:"5D0030", historial:"FFF0F5", panel:"FCDDE8", cooldown:"C0392B", afk:"AD1457", boton:"F8BBD9", hover:"F48FB1", logo:"8B2252", luzOn:"C2185B", luzAccion:"E91E8C", luzOff:"8B2252",  btnTexto:"5D0030", histColor1:"8B2252", histColor2:"C2185B", histColor3:"F06292" },
    { nombre:"Rosa",       fondo:"FFE8F0", texto:"7A1040", barra:"E8528A", textoBarra:"FFFFFF", historial:"FFF0F5", panel:"FFDCEA", cooldown:"CC2244", afk:"D42070", boton:"E8528A", hover:"F07AAA", logo:"5A0028", luzOn:"C03060", luzAccion:"E04080", luzOff:"5A0028",  btnTexto:"FFFFFF", histColor1:"7A1040", histColor2:"E04080", histColor3:"CC3366" },
    { nombre:"Naranja",    fondo:"FFE7CC", texto:"7A3B00", barra:"F28C28", textoBarra:"FFFFFF", historial:"FFF2E6", panel:"FFD9AD", cooldown:"CC3333", afk:"1D5BD7", boton:"F28C28", hover:"FFAA4D", logo:"4A2100", luzOn:"7A3600", luzAccion:"994700", luzOff:"4A2100",  btnTexto:"FFFFFF", histColor1:"7A3B00", histColor2:"994700", histColor3:"CC6600" },
    { nombre:"Verde",      fondo:"F0FFF4", texto:"1B5E20", barra:"66BB6A", textoBarra:"FFFFFF", historial:"E8F5E9", panel:"C8E6C9", cooldown:"E53935", afk:"2E7D32", boton:"66BB6A", hover:"81C784", logo:"1B5E20", luzOn:"388E3C", luzAccion:"66BB6A", luzOff:"1B5E20",  btnTexto:"FFFFFF", histColor1:"1B5E20", histColor2:"388E3C", histColor3:"66BB6A" },
    { nombre:"Lila",       fondo:"EFE6FF", texto:"4A2C7A", barra:"7B61C9", textoBarra:"FFFFFF", historial:"F7F1FF", panel:"E1D3FF", cooldown:"D94A6A", afk:"3D5AFE", boton:"7B61C9", hover:"9279DC", logo:"271052", luzOn:"3B1D78", luzAccion:"4E279E", luzOff:"271052",  btnTexto:"FFFFFF", histColor1:"4A2C7A", histColor2:"4E279E", histColor3:"7B61C9" },
    { nombre:"Ceniza",     fondo:"2C2C2C", texto:"BDBDBD", barra:"424242", textoBarra:"EEEEEE", historial:"242424", panel:"333333", cooldown:"EF5350", afk:"90A4AE", boton:"424242", hover:"555555", logo:"EEEEEE", luzOn:"9E9E9E", luzAccion:"BDBDBD", luzOff:"212121",  btnTexto:"EEEEEE", histColor1:"BDBDBD", histColor2:"9E9E9E", histColor3:"EEEEEE" },
    { nombre:"Grafito",    fondo:"26313D", texto:"EAF2FC", barra:"3E78B2", textoBarra:"FFFFFF", historial:"1E2730", panel:"303D4A", cooldown:"FF6B6B", afk:"73A7FF", boton:"3E78B2", hover:"5591CC", logo:"FFFFFF", luzOn:"9DD2FF", luzAccion:"C7E6FF", luzOff:"FFFFFF",  btnTexto:"FFFFFF", histColor1:"EAF2FC", histColor2:"9DD2FF", histColor3:"5591CC" },
    { nombre:"Bosque",     fondo:"1C1208", texto:"C8A96E", barra:"2D1E0A", textoBarra:"E8C97A", historial:"140E06", panel:"231508", cooldown:"FF5533", afk:"8BC34A", boton:"3B2610", hover:"5A3D18", logo:"8BC34A", luzOn:"6D9B2A", luzAccion:"C8A96E", luzOff:"1C1208",  btnTexto:"E8C97A", histColor1:"C8A96E", histColor2:"8BC34A", histColor3:"D4944A" },
    { nombre:"Cafe",       fondo:"1A1008", texto:"DEB887", barra:"3D2010", textoBarra:"F5D5A0", historial:"120B04", panel:"251508", cooldown:"FF5533", afk:"C8963C", boton:"3D2010", hover:"5A3018", logo:"F5D5A0", luzOn:"C8963C", luzAccion:"F5D5A0", luzOff:"3D2010",  btnTexto:"F5D5A0", histColor1:"DEB887", histColor2:"C8963C", histColor3:"F5D5A0" },
    { nombre:"Noche",      fondo:"0D0D0D", texto:"E8E8E8", barra:"222222", textoBarra:"FFFFFF", historial:"111111", panel:"1A1A1A", cooldown:"FF5555", afk:"7EB8FF", boton:"1E1E1E", hover:"2E2E2E", logo:"FFFFFF", luzOn:"AAAAAA", luzAccion:"FFFFFF", luzOff:"333333",  btnTexto:"CCCCCC", histColor1:"E8E8E8", histColor2:"AAAAAA", histColor3:"FFFFFF" },
    { nombre:"Profundo",   fondo:"020A12", texto:"4FC3F7", barra:"021825", textoBarra:"81D4FA", historial:"010609", panel:"031020", cooldown:"FF4444", afk:"00BCD4", boton:"021825", hover:"033040", logo:"4FC3F7", luzOn:"00BCD4", luzAccion:"4FC3F7", luzOff:"021825",  btnTexto:"81D4FA", histColor1:"4FC3F7", histColor2:"00BCD4", histColor3:"0288D1" },
    { nombre:"Aurora",     fondo:"060A12", texto:"80FFDB", barra:"0A1E30", textoBarra:"80FFDB", historial:"040810", panel:"0C1C28", cooldown:"FF3366", afk:"00FFCC", boton:"0A1E30", hover:"163050", logo:"80FFDB", luzOn:"00FFCC", luzAccion:"AA80FF", luzOff:"0A1E30",  btnTexto:"80FFDB", histColor1:"80FFDB", histColor2:"AA80FF", histColor3:"40C4FF" },
    { nombre:"Esmeralda",  fondo:"010F08", texto:"A8FFD0", barra:"003320", textoBarra:"C8FFE8", historial:"000A05", panel:"001A0F", cooldown:"FF4444", afk:"00FF88", boton:"002218", hover:"004430", logo:"FFD700", luzOn:"00CC66", luzAccion:"FFD700", luzOff:"010F08",  btnTexto:"C8FFE8", histColor1:"00FF88", histColor2:"FFD700", histColor3:"00CC66" },
    { nombre:"Cyber",      fondo:"030D06", texto:"00FF88", barra:"001A0D", textoBarra:"00FF88", historial:"020B05", panel:"041208", cooldown:"FF3355", afk:"00FFCC", boton:"002211", hover:"004422", logo:"00FF88", luzOn:"00CC66", luzAccion:"00FF88", luzOff:"001A0D",  btnTexto:"00FF88", histColor1:"00FF88", histColor2:"00CC66", histColor3:"00FFCC" },
    { nombre:"Neon",       fondo:"050F03", texto:"39FF14", barra:"0A1F06", textoBarra:"39FF14", historial:"030A02", panel:"081A04", cooldown:"FF003C", afk:"CCFF00", boton:"0A1F06", hover:"133D0A", logo:"39FF14", luzOn:"39FF14", luzAccion:"CCFF00", luzOff:"0A1F06",  btnTexto:"39FF14", histColor1:"39FF14", histColor2:"CCFF00", histColor3:"00FF66" },
    { nombre:"Electrico",  fondo:"0A0A1A", texto:"E040FB", barra:"4A148C", textoBarra:"EA80FC", historial:"080812", panel:"0D0D22", cooldown:"FF1744", afk:"7B1FA2", boton:"4A148C", hover:"6A1EB0", logo:"E040FB", luzOn:"AA00FF", luzAccion:"E040FB", luzOff:"1A0030",  btnTexto:"EA80FC", histColor1:"E040FB", histColor2:"AA00FF", histColor3:"CE93D8" },
    { nombre:"Abismo",     fondo:"0A0010", texto:"D8C8FF", barra:"120020", textoBarra:"E0D0FF", historial:"0D0018", panel:"140025", cooldown:"FF4477", afk:"AA88FF", boton:"1A0030", hover:"280050", logo:"C8A8FF", luzOn:"9966FF", luzAccion:"BB88FF", luzOff:"1A0030",  btnTexto:"D8C8FF", histColor1:"D8C8FF", histColor2:"9966FF", histColor3:"BB88FF" },
    { nombre:"Dorado",     fondo:"0A0800", texto:"FFD700", barra:"1E0F00", textoBarra:"FFE55C", historial:"070500", panel:"140C00", cooldown:"FF4422", afk:"FFA500", boton:"1A0F00", hover:"2E1A00", logo:"FFD700", luzOn:"CC8800", luzAccion:"FF6600", luzOff:"0A0800",  btnTexto:"FFE55C", histColor1:"FFD700", histColor2:"FF6600", histColor3:"FFA500" },
    { nombre:"Magma",      fondo:"0E0400", texto:"FF6B35", barra:"1E0800", textoBarra:"FF9A5C", historial:"080200", panel:"180600", cooldown:"FF1744", afk:"FF6B35", boton:"1E0800", hover:"330D00", logo:"FF9A5C", luzOn:"FF4500", luzAccion:"FF6B35", luzOff:"1E0800",  btnTexto:"FF9A5C", histColor1:"FF6B35", histColor2:"FF4500", histColor3:"FF9A5C" },
    { nombre:"Sangre",     fondo:"0A0000", texto:"F5DDD0", barra:"2A0000", textoBarra:"FFD0C0", historial:"060000", panel:"160000", cooldown:"FF0000", afk:"FF6644", boton:"1A0000", hover:"3A0000", logo:"FF2222", luzOn:"CC0000", luzAccion:"FF3322", luzOff:"0A0000",  btnTexto:"FFD0C0", histColor1:"F5DDD0", histColor2:"CC0000", histColor3:"FF3322" },
    { nombre:"✦ E C L I P S E ✦", fondo:"050508", texto:"C8A060", barra:"0D0A20", textoBarra:"FFB347", historial:"030306", panel:"0A0818", cooldown:"FF2244", afk:"00FFCC", boton:"14102A", hover:"221840", logo:"FFB347", luzOn:"FF6600", luzAccion:"FFD700", luzOff:"080520",  btnTexto:"FFB347", histColor1:"FFD700", histColor2:"FF6600", histColor3:"00FFCC" },
    { nombre:"✦ C O S M O S ✦", fondo:"03000F", texto:"E2C9FF", barra:"180040", textoBarra:"FFD700", historial:"020008", panel:"0D001E", cooldown:"FF1493", afk:"00E5FF", boton:"12002E", hover:"1E0050", logo:"FFD700", luzOn:"BF00FF", luzAccion:"FF69B4", luzOff:"080020",  btnTexto:"FFD700", histColor1:"FF69B4", histColor2:"BF00FF", histColor3:"00E5FF" },
    { nombre:"⚡ V O I D ⚡", fondo:"000000", texto:"FFFFFF", barra:"0A0A0A", textoBarra:"FF0000", historial:"050505", panel:"0D0D0D", cooldown:"FF0000", afk:"FF0000", boton:"111111", hover:"1C1C1C", logo:"FF0000", luzOn:"FF0000", luzAccion:"FFFFFF", luzOff:"000000",  btnTexto:"FF0000", histColor1:"FFFFFF", histColor2:"FF0000", histColor3:"CC0000" },
    { nombre:"🔥 F E N I X 🔥", fondo:"FFF8EC", texto:"8B3A00", barra:"FF6B00", textoBarra:"FFFFFF", historial:"FFFBF5", panel:"FFE5C0", cooldown:"00C9B7", afk:"00C9B7", boton:"FFB347", hover:"FF8C00", logo:"00C9B7", luzOn:"00C9B7", luzAccion:"FF6B00", luzOff:"FFB347",  btnTexto:"FFFFFF", histColor1:"FFD700", histColor2:"FF6B00", histColor3:"00C9B7" },
    { nombre:"✦ N I K A ✦", fondo:"FFFFFF", texto:"CC0000", barra:"CC0000", textoBarra:"FFFFFF", historial:"FFFFFF", panel:"FFF2F2", cooldown:"990000", afk:"CC0000", boton:"FFF2F2", hover:"FFE0E0", logo:"CC0000", luzOn:"DD0000", luzAccion:"FF2222", luzOff:"CC0000",  btnTexto:"CC0000", histColor1:"CC0000", histColor2:"DD0000", histColor3:"FF2222" },
    { nombre:"💎 P R E M I U M 💎", fondo:"050008", texto:"FFFFFF", barra:"0F0020", textoBarra:"FFFFFF", historial:"030005", panel:"0A0015", cooldown:"FF0066", afk:"00FFCC", boton:"15002A", hover:"25004A", logo:"FFFFFF", luzOn:"FF00FF", luzAccion:"FFD700", luzOff:"0A0015",  btnTexto:"FFFFFF", histColor1:"FF00FF", histColor2:"00FFFF", histColor3:"FFFF00" }
]

temaActual := LeerTemaGuardado()
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
pasosPrioridad.Push({ tipo:"pimg", nombre:"LEAVINGGAME...", color:0xFFFFFF, categoria:1, accion:"Esc", hold:1000, tolerancia:1, delayClick:3000, delayTecla:1000, cooldown:190000, lastUsed:0, x1:1445, y1:65, x2:1448, y2:69, esperarA:"leaving..." })

; ===== PIXEL PASOS NORMALES =====
pasosNormales.Push({ tipo:"pimg", nombre:"play",          color:0xF6F7F8, categoria:2, hold:400, tolerancia:1, delayClick:30,  delayTecla:80, cooldown:200, lastUsed:0, x1:37, y1:271, x2:37, y2:271 })
pasosNormales.Push({ tipo:"pimg", nombre:"playbob",       color:0xFED511, categoria:2, tolerancia:1, hold:100, delayClick:500, delayTecla:500, cooldown:100, lastUsed:0, x1:36, y1:264, x2:36, y2:264 })
pasosNormales.Push({ tipo:"pimg", nombre:"playwhite",     color:0xFFFFFF, categoria:2, tolerancia:1, hold:400, delayClick:500, delayTecla:500, cooldown:500, lastUsed:0, x1:34, y1:269, x2:34, y2:269 })


pasosNormales.Push({ tipo:"pimg", nombre:"ingame...",     color:0x70C9D3, categoria:4, accion:"c", hold:100, tolerancia:1, delayClick:10, delayTecla:10, cooldown:10, lastUsed:0, x1:32, y1:266, x2:35, y2:268 })
pasosNormales.Push({ tipo:"pimg", nombre:"glitch1",       color:0x0059A2, categoria:6, tiempoNecesario:4000, tiempoDetectando:0, accion:"Esc", hold:400, tolerancia:1, delayClick:30, delayTecla:250, cooldown:500, lastUsed:0, x1:38, y1:252, x2:53, y2:259 })
pasosNormales.Push({ tipo:"pimg", nombre:"featured",      color:0x0E2C45, categoria:6, tiempoNecesario:4000, tiempoDetectando:0, accion:"Esc", hold:400, tolerancia:1, delayClick:30, delayTecla:250, cooldown:500, lastUsed:0, x1:166, y1:262, x2:166, y2:269 })

pasosNormales.Push({ tipo:"pimg", nombre:"gamedone1",     color:0x000033, categoria:1, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, lastUsed:0, x1:941, y1:40, x2:959, y2:43 })
pasosNormales.Push({ tipo:"pimg", nombre:"gamedone2",     color:0xF7F9F9, categoria:1, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, lastUsed:0, x1:900, y1:43, x2:900, y2:43 })
pasosNormales.Push({ tipo:"pimg", nombre:"gamedone3",     color:0xF7F9F9, categoria:1, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, lastUsed:0, x1:876, y1:51, x2:876, y2:51 })
pasosNormales.Push({ tipo:"pimg", nombre:"INTHEGAME",     color:0x38373E, categoria:3, accion:"c", hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:5000, bloqueoGlobal:170000, lastUsed:0, x1:792, y1:488, x2:794, y2:496 })

pasosNormales.Push({ tipo:"pimg", nombre:"closing...",    color:0xD7D554, categoria:5, hold:400, tolerancia:1, delayClick:30, delayTecla:400, cooldown:300000, lastUsed:0, x1:742, y1:515, x2:743, y2:518 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringroom1", color:0xFF89D0, categoria:3, hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, lastUsed:0, x1:389, y1:566, x2:393, y2:567 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringroom2", color:0x3F7F96, categoria:3, hold:400, tolerancia:1, delayClick:30, delayTecla:80, cooldown:500, lastUsed:0, x1:366, y1:549, x2:366, y2:549 })
pasosNormales.Push({ tipo:"pimg", nombre:"leaving...",    color:0x30F1DD, categoria:5, hold:400, tolerancia:1, delayClick:30, delayTecla:300, cooldown:500, bloqueoGlobal:3000, lastUsed:0, x1:859, y1:928, x2:863, y2:931 })

; ===== GLOBALES =====
global pasosPrioridad, pasosNormales, activo := false
global luzActiva, luzAccion, luzApagado, historialGui, historialBox, cooldownText, afkText
global tiempoInicio := 0, tiempoAcumulado := 0, timerActivo := false
global avisoMostrado := false, avisoGui := "", ultimoCambio := 0
global ultimoPasoEjecutado := ""
global modoDestruccion := false
global historialVisible := true, accionEnCurso := false, contadorEsc := 0
global histUltimoTexto := "", histUltimoCount := 0, histUltimoLongLinea := 0
global separadorHistorial := ""
global temaTransStep := 0, temaTransTema := "", temaTransGuardar := true, temaEnTransicion := false
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
global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros
global hoverAccent := "", hoverAnimStep := 0, hoverAccentTop := "", hoverAccentHist := ""
global hoverAccentBot := "", hoverAccentRight := "", hoverAccentBotHist := "", hoverAccentRightHist := ""
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
global scrollTrack := "", scrollThumb := ""
global ultimoThumbY := -1, ultimoThumbH := -1
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

; ===== BARRA GRADIENTE / ANILLO COOLDOWN / STATS (GDI+) =====
global barraGradPhase := 0.0
global barraSubclassCbM := 0, barraSubclassCbH := 0
global colorBarraOverride := ""   ; "" = base; HEX = override total (flash error)
global barraExtraBrillo := 0      ; pulso/shimmer aditivo
global statsGuiActive := "", statsBarsData := [], statsBarsSubclassCbs := []

; ===== ACTUALIZADOR =====
global GITHUB_VERSION_URL := "https://raw.githubusercontent.com/johantakuma2009-bit/brawlmacro/main/parches.txt"
global GITHUB_SCRIPT_URL  := "https://raw.githubusercontent.com/johantakuma2009-bit/brawlmacro/main/brawlmacrotct.ahk"
global updateGui := "", updateGuiVisible := false

; ===== GUARDAR STATS =====
global statsPath := A_ScriptDir "\brawlmacro_stats.ini"
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
    "milestone",   true
)

CargarStats() {
    global statsPath, totalHorasGuardadas, totalSecuenciasGuardadas, totalDestruccionGuardada
    totalHorasGuardadas := Float(IniRead(statsPath, "Stats", "Horas", "0.0"))
    totalSecuenciasGuardadas := Integer(IniRead(statsPath, "Stats", "Secuencias", "0"))
    totalDestruccionGuardada := Integer(IniRead(statsPath, "Stats", "Destruccion", "0"))
}

GuardarStats() {
    global statsPath, totalHorasGuardadas, totalSecuenciasGuardadas, totalDestruccionGuardada
    global tiempoAcumulado, tiempoInicio, timerActivo, contadorSecuencias
    global contadorDestruccion
    tiempoSesion := tiempoAcumulado
    if (timerActivo)
        tiempoSesion += (A_TickCount - tiempoInicio)
    horasSesion := tiempoSesion / 3600000.0
    totalGuardar := totalHorasGuardadas + horasSesion
    secGuardar := totalSecuenciasGuardadas + contadorSecuencias
    IniWrite(Round(totalGuardar, 4), statsPath, "Stats", "Horas")
    IniWrite(secGuardar, statsPath, "Stats", "Secuencias")
    IniWrite(totalDestruccionGuardada + contadorDestruccion, statsPath, "Stats", "Destruccion")
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
    lblHdr := sg.Add("Text", "x16 y38 w" (W - 32) " h14 Center BackgroundTrans c" colorTextoPrincipal, Chr(0x23F0) "  Tiempo total")
    lblHdr.SetFont("s9", "Segoe UI")
    lblT := sg.Add("Text", "x16 y54 w" (W - 32) " h30 Center BackgroundTrans c" colorTextoPrincipal, horas "h " mins "m")
    lblT.SetFont("s18 Bold", "Segoe UI Semibold")

    ; Separador
    sg.Add("Text", "x35 y92 w" (W - 70) " h1 Background" colorBarra, "")

    ; Bloque secuencias
    halfW := Round(W / 2)
    lblSHdr := sg.Add("Text", "x10 y102 w" (halfW - 10) " h14 Center BackgroundTrans c" colorTextoPrincipal, Chr(0x1F504) " Secuencias")
    lblSHdr.SetFont("s9", "Segoe UI")
    lblS := sg.Add("Text", "x10 y118 w" (halfW - 10) " h26 Center BackgroundTrans c" colorHist2, totalS)
    lblS.SetFont("s15 Bold", "Segoe UI Semibold")

    ; Bloque destrucciones
    lblDHdr := sg.Add("Text", "x" halfW " y102 w" (halfW - 10) " h14 Center BackgroundTrans c" colorTextoPrincipal, Chr(0x1F4A5) " Destrucciones")
    lblDHdr.SetFont("s9", "Segoe UI")
    lblD := sg.Add("Text", "x" halfW " y118 w" (halfW - 10) " h26 Center BackgroundTrans c" colorCooldown, totalD)
    lblD.SetFont("s15 Bold", "Segoe UI Semibold")

    ; Separador
    sg.Add("Text", "x35 y152 w" (W - 70) " h1 Background" colorBarra, "")

    ; Sesión actual
    lblSesHdr := sg.Add("Text", "x16 y162 w" (W - 32) " h14 Center BackgroundTrans c" colorTextoPrincipal, "Sesión actual")
    lblSesHdr.SetFont("s8 Italic", "Segoe UI")
    lblSes := sg.Add("Text", "x16 y178 w" (W - 32) " h20 Center BackgroundTrans c" colorTextoPrincipal,
        Chr(0x1F4C5) " " sesMin " min  •  " contadorSecuencias " seqs  •  " seqHora "/h")
    lblSes.SetFont("s9 Bold", "Segoe UI")

    ; Botón exportar
    btnExp := sg.Add("Text", "x16 y210 w" (W - 32) " h32 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(128190) "  Exportar sesión")
    btnExp.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
    btnExp.OnEvent("Click", ExportarSesion)
    RegistrarHover(btnExp, () => colorBotonNormal)

    sg.Show("w" W " h254 Center")
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
    global gdipToken, gdipInited, logoFontFamily, logoStringFormat
    if (gdipInited)
        return
    DllCall("LoadLibrary", "Str", "gdiplus.dll")
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &gdipToken, "Ptr", si, "Ptr", 0)
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI Symbol", "Ptr", 0, "Ptr*", &logoFontFamily)
    DllCall("gdiplus\GdipCreateStringFormat", "Int", 0, "Int", 0, "Ptr*", &logoStringFormat)
    DllCall("gdiplus\GdipSetStringFormatAlign",     "Ptr", logoStringFormat, "Int", 1)  ; center horizontal
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", logoStringFormat, "Int", 1)  ; center vertical
    gdipInited := true
}

; Pinta el engranaje rotado directamente sobre el HDC dado, usando GDI para el fondo y GDI+ para
; el texto rotado. No crea bitmap intermedio. Lo invoca ManejarLogoOwnerDraw en respuesta a WM_DRAWITEM.
DibujarGearEnDC(hdc, w, h, angulo, colorHex, fondoHex) {
    static gearCX := "", gearCY := ""

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

    family := 0
    DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI Symbol", "Ptr", 0, "Ptr*", &family)
    if (!family)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI Emoji", "Ptr", 0, "Ptr*", &family)
    if (!family)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Segoe UI", "Ptr", 0, "Ptr*", &family)
    if (!family)
        DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "Arial", "Ptr", 0, "Ptr*", &family)

    if (family) {
        font := 0
        DllCall("gdiplus\GdipCreateFont", "Ptr", family, "Float", 58, "Int", 1, "Int", 0, "Ptr*", &font)
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
                DllCall("gdiplus\GdipMeasureString", "Ptr", g, "WStr", Chr(9881), "Int", 1,
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
                    DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", Chr(9881), "Int", 1, "Ptr", font, "Ptr", tRc, "Ptr", fmt, "Ptr", tBrush)
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
                DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", Chr(9881), "Int", 1, "Ptr", font, "Ptr", ghostRc, "Ptr", fmt, "Ptr", ghostBrush)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", ghostBrush)
            }

            DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", Chr(9881), "Int", 1, "Ptr", font, "Ptr", drawRect, "Ptr", fmt, "Ptr", brushG)

            DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", fmt)
            if (brushG)
                DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushG)
            DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
        }
        DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", family)
    }
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", g)
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
    global logoMacro
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


; Timer: actualiza velocidad/ángulo/pulso y pinta el logo directamente sobre su DC.
ActualizarLogoAnimacion() {
    global activo, logoAngulo, logoVelActual, logoVelObjetivo, logoNeedsRedraw
    global logosPulsoT, logosPulsoDir
    global modoDestruccion, logoGlitchActivo, logoGlitchHasta, logoGlitchOffX, logoGlitchOffY
    global logoTrailAngulos

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

                ; Bandas de brillo (3 fases desplazadas) — gauss columna a columna
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
                        if (alpha < 4)
                            continue
                        argbHi := (alpha << 24) | 0x00FFFFFF
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
    global barraGradPhase, barra, barraHistorial, activo, temaEnTransicion
    if (temaEnTransicion)
        return
    vel := activo ? 0.013 : 0.005
    barraGradPhase += vel
    if (barraGradPhase >= 1000)
        barraGradPhase -= 1000
    if (IsObject(barra))
        DllCall("InvalidateRect", "Ptr", barra.Hwnd, "Ptr", 0, "Int", 0)
    if (IsObject(barraHistorial))
        DllCall("InvalidateRect", "Ptr", barraHistorial.Hwnd, "Ptr", 0, "Int", 0)
}

; ===== PARTICULAS DE FONDO (GDI+) =====
global particulasMain := [], particulasHist := []
global miGuiPartCb := 0, histGuiPartCb := 0
global particulasInited := false
global overlayPartMain := "", overlayPartHist := ""

InicializarParticulas(arr, w, h, n := 35) {
    global particulasCantidad, particulasVelocidad, particulasTamano, particulasOpacidad
    while (arr.Length > 0)
        arr.Pop()
    ; Aplicar multiplicadores de cantidad sobre el baseN
    realN := Max(0, Round(n * particulasCantidad / 100))
    factorVel := particulasVelocidad / 100
    factorTam := particulasTamano / 100
    factorAlpha := particulasOpacidad / 100
    loop realN {
        arr.Push({
            x:     Random(0.0, w * 1.0),
            y:     Random(0.0, h * 1.0),
            vx:    (Random(-100, 100) / 500.0) * factorVel,
            vy:    (Random(-100, 100) / 650.0) * factorVel,
            r:     (Random(20, 45) / 10.0) * factorTam,
            alpha: Min(255, Round(Random(45, 110) * factorAlpha))
        })
    }
}

; Aplica la config actual: re-inicializa los arrays con los nuevos multiplicadores
; y muestra/oculta los overlays según el toggle de activadas.
AplicarConfigParticulas() {
    global particulasMain, particulasHist, miGui, historialGui, historialVisible
    global overlayPartMain, overlayPartHist, particulasActivas
    static BAR_H := 25

    if (IsObject(miGui) && IsObject(overlayPartMain)) {
        miGui.GetPos(,, &mw, &mh)
        InicializarParticulas(particulasMain, mw, mh - BAR_H, 32)
        if (particulasActivas) {
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

ActualizarParticulas() {
    global particulasMain, particulasHist, miGui, historialGui, historialVisible, particulasInited
    global overlayPartMain, overlayPartHist
    global temaEnTransicion, particulasActivas
    if (!particulasInited || temaEnTransicion || !particulasActivas)
        return

    static BAR_H := 25  ; alto de la barra de título excluida del overlay
    ; Sincronizar overlay con la ventana padre (sigue el drag) y repintar.
    ; Saltar actualización si el padre está minimizado — GetPos devolvería coords
    ; basura del estado minimizado y las partículas se apiñarían ahí.
    ; Todo dentro de try/catch porque durante minimize/restore Windows puede dejar
    ; las ventanas en estados transitorios donde GetPos/Move tiran excepciones.
    try if (IsObject(miGui) && IsObject(overlayPartMain) && !DllCall("IsIconic", "Ptr", miGui.Hwnd, "Int")) {
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
        PintarOverlayParticulas(overlayPartMain.Hwnd, mw, targetH, particulasMain)
    }
    try if (IsObject(historialGui) && IsObject(overlayPartHist) && historialVisible
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
        ; Excluir el rect del scrollbar custom (x=243 w=17, y=35 h=110 en historialGui →
        ; en coords del overlay: y = 35 - BAR_H = 10). Así las partículas no pintan sobre el thumb.
        PintarOverlayParticulas(overlayPartHist.Hwnd, hw, targetH, particulasHist,
            { x: 243, y: 35 - BAR_H, w: 17, h: 110 })
    }
}

; ===== WATCHDOG AFK =====
; Si el macro está activo pero el AFK (MouseMove ±1px) no se ha disparado en > 3 min,
; algo se atascó (diálogo de error, deadlock, fuga, lo que sea). Re-lanzamos el script
; para que la AFK vuelva a funcionar antes de que Windows considere el PC inactivo.
WatchdogAFK() {
    global activo, ultimoAfkMove, configPath
    if (!activo)
        return
    elapsed := A_TickCount - ultimoAfkMove
    if (elapsed > 90000) {  ; 90 s sin AFK = algo se atascó
        try {
            IniWrite(FormatTime(, "yyyy-MM-dd HH:mm:ss"), configPath, "Watchdog", "UltimoReinicio")
            IniWrite(elapsed, configPath, "Watchdog", "MsSinAFK")
            IniWrite(1,       configPath, "Watchdog", "AutoStart")
        }
        Reload()
    }
}


; Pinta partículas con alpha por píxel (PARGB) sobre la overlay layered y las muestra
; vía UpdateLayeredWindow. Así cada partícula se mezcla contra los píxeles reales que
; hay detrás (sin halo y respetando el fondo), no contra una color-key negra.
PintarOverlayParticulas(overlayHwnd, w, h, particulas, excludeRect := "") {
    global colorLogoMacro, colorFondoPrincipal, temaPremiumActivo, rgbBarraHue

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
    if ((rF * 299 + gF * 587 + bF * 114) / 1000 > 180) {  ; luminancia > 180/255 ≈ claro
        rC := (rC + 255) // 2
        gC := (gC + 255) // 2
        bC := (bC + 255) // 2
    }

    for i, p in particulas {
        if (temaPremiumActivo) {
            huePart := Mod(rgbBarraHue * 3 + i * 25, 360)
            cHex := HSVaHex(huePart, 1.0, 1.0)
            rPi := Integer("0x" SubStr(cHex, 1, 2))
            gPi := Integer("0x" SubStr(cHex, 3, 2))
            bPi := Integer("0x" SubStr(cHex, 5, 2))
            alphaP := Min(255, p.alpha + 50)
            argb := (alphaP << 24) | (rPi << 16) | (gPi << 8) | bPi
        } else {
            argb := (p.alpha << 24) | (rC << 16) | (gC << 8) | bC
        }
        brush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &brush)
        DllCall("gdiplus\GdipFillEllipse",     "Ptr", g, "Ptr", brush,
                "Float", p.x - p.r, "Float", p.y - p.r,
                "Float", p.r * 2, "Float", p.r * 2)
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
    global activo, modoDestruccion, ultimoCambio
    if (modoDestruccion) {
        EstablecerTrayIcon("FF2222")
        return
    }
    if (activo) {
        restante := 270000 - (A_TickCount - ultimoCambio)
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

miGui := Gui("+AlwaysOnTop -Caption")
miGui.BackColor := colorFondoPrincipal
miGui.SetFont("s13 c" colorTextoPrincipal, "Segoe UI")

historialGui := Gui("+AlwaysOnTop +ToolWindow -Caption")
historialGui.Opt("+Owner" miGui.Hwnd)
historialGui.BackColor := colorVentanaHistorial
historialGui.SetFont("s11 c" colorTextoPrincipal, "Segoe UI")

barraHistorial := historialGui.Add("Text", "x0 y0 w270 h25 Background" colorBarra " Center", "Historial AFK Macro")
barraHistorial.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI")
; Combinado: primero registra el click para el egg de Nika, LUEGO arrastra
; (si arrastra antes, el drag modal de Windows bloquea el segundo handler)
barraHistorial.OnEvent("Click", (*) => (ClickBarraHistorialNika(), ArrastrarHistorial()))

; Sin WS_VSCROLL (0x200000): el RichEdit no dibuja scrollbar nativa nunca,
; ni al hacer wheel, ni al re-pintar, ni al reflowar el texto. El scroll por
; mensajes (EM_SETSCROLLPOS) y la rueda siguen funcionando igual.
historialBox := historialGui.Add("Custom", "ClassRICHEDIT50W x10 y35 w250 h110 +0x4 +0x10 +0x40 +0x800 vHistorial")
historialBox.Opt("+ReadOnly -TabStop")
SendMessage(0x00CF, 0, 0, historialBox)
SendMessage(0x0443, 0, HexToBGR(colorFondoHistorial), , "ahk_id " historialBox.Hwnd)

; ── Scrollbar custom encima del RichEdit (sin WS_VSCROLL no hay nativa que tape) ──
; Track de fondo + thumb que se mueve. Los colores siguen al tema.
scrollTrack := historialGui.Add("Text", "x243 y35 w17 h110 +0x201 Background" colorBotonNormal, "")
scrollThumb := historialGui.Add("Text", "x244 y35 w15 h26 +0x201 Background" colorBotonHover, "")
scrollTrack.OnEvent("Click", ClickScrollbar)
scrollThumb.OnEvent("Click", ClickScrollbar)

; Ocultar la barra nativa blanca del RichEdit (la mantiene internamente para scroll pero sin pintarla)
DllCall("ShowScrollBar", "Ptr", historialBox.Hwnd, "Int", 1, "Int", 0)  ; SB_VERT=1, bShow=0
; Llevar nuestro overlay AL FRENTE en z-order para que cubra cualquier resto de pintado
DllCall("SetWindowPos", "Ptr", scrollTrack.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)  ; HWND_TOP, NOMOVE|NOSIZE|NOACTIVATE
DllCall("SetWindowPos", "Ptr", scrollThumb.Hwnd, "Ptr", 0, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)

cooldownText := historialGui.Add("Text", "x10 y155 w250 h88 vCooldownText c" colorCooldown " Background" colorVentanaHistorial)
separadorHistorial := historialGui.Add("Text", "x0 y148 w270 h2 Background" colorBarra, "")
secuenciasLabel := historialGui.Add("Text", "x10 y245 w250 h20 +0x201 vSecuenciasLabel c" colorTextoPrincipal " Background" colorVentanaHistorial)
destruccionesLabel := historialGui.Add("Text", "x10 y265 w250 h20 +0x201 vDestruccionesLabel c" colorTextoPrincipal " Background" colorVentanaHistorial)
contadorLabel := historialGui.Add("Text", "x10 y285 w250 h18 +0x201 vContadorLabel c" colorTextoPrincipal " Background" colorVentanaHistorial, "")
contadorLabel.SetFont("s9 c" colorTextoPrincipal, "Segoe UI")
afkText      := historialGui.Add("Text", "x10 y305 w250 h18 vAfkText c" colorAFK " Background" colorVentanaHistorial)
secuenciasLabel.SetFont("s10 Bold", "Segoe UI")
destruccionesLabel.SetFont("s10 Bold", "Segoe UI")
secuenciasLabel.Value := Chr(0x276E) "  Secuencias: 0  " Chr(0x276F)
destruccionesLabel.Value := Chr(0x276E) "  Destrucciones: 0  " Chr(0x276F)

btnUpdate := historialGui.Add("Text", "x244 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(8593))
btnUpdate.SetFont("s8 c" colorBtnTexto, "Segoe UI Symbol")
btnUpdate.OnEvent("Click", AbrirVentanaActualizacion)
btnOverlay := historialGui.Add("Text", "x218 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F441))
btnOverlay.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnOverlay.OnEvent("Click", ToggleOverlayPixeles)
btnRGBBtn := historialGui.Add("Text", "x192 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F3A8))
btnRGBBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnRGBBtn.OnEvent("Click", AbrirPanelRGB)
btnStatsBtn := historialGui.Add("Text", "x166 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F4CA))
btnStatsBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnStatsBtn.OnEvent("Click", MostrarEstadisticas)
btnWebhook := historialGui.Add("Text", "x140 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F514))
btnWebhook.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnWebhook.OnEvent("Click", AbrirPanelWebhook)
btnLogros := historialGui.Add("Text", "x114 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F3C5))
btnLogros.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnLogros.OnEvent("Click", AbrirPanelLogros)
btnPart := historialGui.Add("Text", "x88 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x2728))
btnPart.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnPart.OnEvent("Click", AbrirPanelParticulas)
; Acentos hover para botones del historial (viven en historialGui)
hoverAccentHist      := historialGui.Add("Text", "x-20 y-20 w5 h0  Background" colorBarra, "")
hoverAccentBotHist   := historialGui.Add("Text", "x-20 y-20 w0 h4  Background" colorBarra, "")
hoverAccentRightHist := historialGui.Add("Text", "x-20 y-20 w5 h0  Background" colorBarra, "")

historialGui.Show("x" (A_ScreenWidth-270) " y100 w270 h352")
RedondearVentana(historialGui.Hwnd, 14)

; Restaurar posición guardada del historial
_savedHistX := IniRead(configPath, "Pos", "HistX", "")
_savedHistY := IniRead(configPath, "Pos", "HistY", "")
if (_savedHistX != "" && _savedHistY != "")
    historialGui.Move(Integer(_savedHistX), Integer(_savedHistY))

; Restaurar estado del historial guardado
historialVisible := Integer(IniRead(configPath, "UI", "HistorialVisible", "1")) = 1
if (!historialVisible)
    historialGui.Hide()

; Cargar config de partículas
particulasActivas   := Integer(IniRead(configPath, "Particulas", "Activas",    "1")) = 1
particulasCantidad  := Integer(IniRead(configPath, "Particulas", "Cantidad",   "100"))
particulasVelocidad := Integer(IniRead(configPath, "Particulas", "Velocidad",  "100"))
particulasTamano    := Integer(IniRead(configPath, "Particulas", "Tamano",     "100"))
particulasOpacidad  := Integer(IniRead(configPath, "Particulas", "Opacidad",   "100"))

barra := miGui.Add("Text", "x0 y0 w400 h25 Background" colorBarra " Center", "AFK MACRO")
barra.SetFont("s13 c" colorTextoBarra " Bold", "Segoe UI Semibold")
barra.OnEvent("Click", ArrastrarVentana)
barra.OnEvent("DoubleClick", ClickTitulo)

btnMin      := miGui.Add("Text", "x338 y33 w20 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(8722))
btnClose    := miGui.Add("Text", "x368 y33 w20 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(215))
btnMin.OnEvent("Click", Minimizar)
btnClose.OnEvent("Click", Cerrar)

logoMacro := miGui.Add("Text", "x19 y31 w95 h95 Center BackgroundTrans c" colorLogoMacro " +0x1", Chr(9881))
logoMacro.SetFont("s58 c" colorLogoMacro " Bold", "Segoe UI Symbol")
logoMacro.OnEvent("Click", ClickLogo)
InstalarSubclassLogo()
texto := "AFK Smart"
tituloMacro := miGui.Add("Text", "x120 y70 w110 h20 Background" colorFondoPrincipal " c" colorTextoPrincipal, texto)
tituloMacro.SetFont("s13 Bold", "Segoe UI Semibold")

luzActiva := miGui.Add("Progress", "x40 y130 w20 h20 c" colorBotonNormal " Background" colorFondoPrincipal, 100)
luzAccion := miGui.Add("Progress", "x70 y130 w20 h20 c" colorBotonNormal " Background" colorFondoPrincipal, 100)
luzApagado := miGui.Add("Progress", "x100 y130 w20 h20 c" colorLuzApagado " Background" colorFondoPrincipal, 100)
OnMessage(0x0201, ManejarClickLuces)

btnTema      := miGui.Add("Text", "x240 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9680))
btnHistorial := miGui.Add("Text", "x272 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(128203))
btnCodigo    := miGui.Add("Text", "x304 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9000))
btnReset     := miGui.Add("Text", "x336 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(8635))
btnIniciar   := miGui.Add("Text", "x40 y178 w140 h36 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9654) " Iniciar (F1)")
btnParar     := miGui.Add("Text", "x220 y178 w140 h36 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9632) " Parar (F2)")
; Franjas de acento para hover — 4 lados (izquierda, derecha, arriba, abajo)
hoverAccent      := miGui.Add("Text", "x-20 y-20 w5 h0 Background" colorBarra, "")
hoverAccentTop   := miGui.Add("Text", "x-20 y-20 w0 h4 Background" colorBarra, "")
hoverAccentBot   := miGui.Add("Text", "x-20 y-20 w0 h4 Background" colorBarra, "")
hoverAccentRight := miGui.Add("Text", "x-20 y-20 w5 h0 Background" colorBarra, "")

for btn in [btnTema, btnHistorial, btnCodigo, btnReset, btnMin, btnClose]
    btn.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")
for btn in [btnIniciar, btnParar]
    btn.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
for btn in [btnTema, btnHistorial, btnCodigo, btnReset, btnMin, btnClose]
    btn.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")

btnTema.OnEvent("Click", CambiarTema)
btnHistorial.OnEvent("Click", ToggleHistorial)
btnIniciar.OnEvent("Click", Iniciar)
btnParar.OnEvent("Click", Parar)
btnReset.OnEvent("Click", Reiniciar)
btnCodigo.OnEvent("Click", AbrirCodigo)

; ── Registro de hover para los botones principales ──
RegistrarHover(btnIniciar,   () => (activo ? (rgbBotones ? colorRGBActual : colorBotonHover) : (rgbBotones ? colorRGBActual : colorBotonNormal)))
RegistrarHover(btnParar,     () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnTema,      () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnHistorial, () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnCodigo,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnReset,     () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnMin,       () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnClose,     () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnUpdate,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnOverlay,   () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnRGBBtn,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnStatsBtn,  () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnWebhook,   () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnLogros,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnPart,      () => (rgbBotones ? colorRGBActual : colorBotonNormal))

timerLabel := miGui.Add("Text", "x220 y130 w140 h25 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x23F0) " 00:00")
timerLabel.SetFont("s13 c" colorTextoPrincipal " Bold", "Segoe UI Semibold")
timerLabel.OnEvent("Click", ClickTimer)

miGui.Show("w400 h240")
RedondearVentana(miGui.Hwnd, 14)
logoVelObjetivo := 0.0
SetTimer(ActualizarLogoAnimacion, 33)

; Restaurar posición guardada de la ventana principal
_savedMainX := IniRead(configPath, "Pos", "MainX", "")
_savedMainY := IniRead(configPath, "Pos", "MainY", "")
if (_savedMainX != "" && _savedMainY != "")
    miGui.Move(Integer(_savedMainX), Integer(_savedMainY))
AplicarTema(temas[temaActual], false)
InstalarSubclassBarras()
InstalarSubclassParticulas()
SetTimer(AnimarBarras, 33)
SetTimer(ActualizarParticulas, 50)
EstablecerTrayIcon("888888")
SetTimer(ActualizarTrayIcon, 1000)
SetTimer(VerificarLogros, 5000)
SetTimer(ActualizarScrollbar, 150)
SetTimer(WatchdogAFK, 30000)     ; cada 30 s; si activo && > 90 s sin AFK → Reload()

; Si la instancia anterior se reinició por watchdog, auto-arrancar el macro.
; Pequeño delay para que la GUI termine de asentarse antes de Iniciar().
if (IniRead(configPath, "Watchdog", "AutoStart", "0") = "1") {
    try IniDelete(configPath, "Watchdog", "AutoStart")  ; consumir flag (single-shot)
    SetTimer(() => Iniciar(), -1500)
}
if (rgbActivo)
    SetTimer(ActualizarRGB, 60)

; ===== HOVER via polling — efecto respiratorio =====
global hoverActual := ""
SetTimer(HoverPoll, 16)
SetTimer(HoverBreath, 40)

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
    if (hoverActual != "") {
        try {
            info := hoverBotones[hoverActual.Hwnd]
            base := info.baseFn.Call()
            hoverActual.Opt("Background" base)
            DllCall("InvalidateRect", "Ptr", hoverActual.Hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", hoverActual.Hwnd)
        }
    }

    ; ── Aplicar hover al nuevo botón ─────────────────────────────────────
    if (encontrado != "") {
        info := hoverBotones[encontrado.Hwnd]
        if (IsObject(info.hoverFn))
            hoverBg := info.hoverFn.Call()
        else
            hoverBg := (rgbBotones ? colorRGBActual : colorBotonHover)
        encontrado.Opt("Background" hoverBg)
        DllCall("InvalidateRect", "Ptr", encontrado.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", encontrado.Hwnd)
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
    global rgbBotones, temaEnTransicion

    ; RGB no respira (se ve mal combinado con el ciclo de hue)
    if (hoverActual = "" || hoverBreathBase = "" || temaEnTransicion || rgbBotones)
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

    hoverActual.Opt("Background" c)
    DllCall("InvalidateRect", "Ptr", hoverActual.Hwnd, "Ptr", 0, "Int", 1)
}

ClickLogo(*) {
    global eggClicks, eggUltimo, eggDesbloqueado, logoMacro, colorLogoMacro
    global eggVoidDesbloqueado, eggShadowDesbloqueado, eggSolarDesbloqueado, eggBlancoDesbloqueado
    global eggPremiumDesbloqueado, eggPremiumClicks, eggPremiumUltimo

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
    temaActual := temas.Length
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
    popup.Add("Text", "x10 y68 w340 h24 Center cFFFFFF", "Has desbloqueado  💎 P R E M I U M 💎")
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
    temaActual := temas.Length - 3
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
    temaActual := temas.Length - 5
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

; ===== FUNCIONES GUI =====
; ===== BACKUP ROBUSTO DE EGGS (UTF-8 — inmune a problemas de codificación del .ini) =====
CargarEggsBackup() {
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggsBackupPath
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
    }
}

GuardarEggsBackup() {
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggsBackupPath
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
    try FileDelete(eggsBackupPath)
    try FileAppend(txt, eggsBackupPath, "UTF-8")
}

LeerTemaGuardado() {
    global configPath, temas, eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, VERSION_ACTUAL
    eggDesbloqueado        := Integer(IniRead(configPath, "Egg",        "Desbloqueado", "0")) = 1
    eggVoidDesbloqueado    := Integer(IniRead(configPath, "EggVoid",    "Desbloqueado", "0")) = 1
    eggShadowDesbloqueado  := Integer(IniRead(configPath, "EggShadow",  "Desbloqueado", "0")) = 1
    eggSolarDesbloqueado   := Integer(IniRead(configPath, "EggSolar",   "Desbloqueado", "0")) = 1
    eggBlancoDesbloqueado  := Integer(IniRead(configPath, "EggBlanco",  "Desbloqueado", "0")) = 1
    eggPremiumDesbloqueado := Integer(IniRead(configPath, "EggPremium", "Desbloqueado", "0")) = 1
    ; Fallback: si el .ini está corrupto o en UTF-16, leer del backup UTF-8
    CargarEggsBackup()
    ; Re-guardar al backup para mantenerlo sincronizado
    GuardarEggsBackup()
    valor := Integer(IniRead(configPath, "Tema", "Actual", "1"))
    if (valor < 1 || valor > temas.Length)
        valor := 1
    if (valor = temas.Length     && !eggPremiumDesbloqueado)
        valor := 1
    if (valor = temas.Length - 1 && !eggBlancoDesbloqueado)
        valor := 1
    if (valor = temas.Length - 2 && !eggSolarDesbloqueado)
        valor := 1
    if (valor = temas.Length - 3 && !eggVoidDesbloqueado)
        valor := 1
    if (valor = temas.Length - 4 && !eggDesbloqueado)
        valor := 1
    if (valor = temas.Length - 5 && !eggShadowDesbloqueado)
        valor := 1
    return valor
}

GuardarTema() {
    global configPath, temaActual
    IniWrite(temaActual, configPath, "Tema", "Actual")
}

; ===== WEBHOOK DISCORD =====
LeerWebhook() {
    global configPath, webhookURL, webhookEnabled, webhookEventos
    webhookURL := IniRead(configPath, "Webhook", "URL", "")
    webhookEnabled := Integer(IniRead(configPath, "Webhook", "Enabled", "0")) = 1
    for k, _ in webhookEventos.Clone()
        webhookEventos[k] := Integer(IniRead(configPath, "Webhook", "Evt_" k, "1")) = 1
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
    colorInt := Integer("0x" colorHex)
    titulo := EscapeJson(titulo)
    mensaje := EscapeJson(mensaje)
    json := '{"embeds":[{"title":"' titulo '","description":"' mensaje '","color":' colorInt ',"footer":{"text":"AFK Macro"}}]}'
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", webhookURL, false)
        whr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
        whr.Send(json)
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
    rutaFoto := A_Temp "\brawlmacro_shot_" A_TickCount ".png"
    if (!TomarScreenshot(rutaFoto)) {
        ; Si falla la screenshot, manda solo texto
        EnviarWebhookSync(titulo, mensaje, colorHex)
        return
    }

    colorInt := Integer("0x" colorHex)
    tEsc := EscapeJson(titulo)
    mEsc := EscapeJson(mensaje)
    json := '{"embeds":[{"title":"' tEsc '","description":"' mEsc '","color":' colorInt ',"image":{"url":"attachment://screenshot.png"},"footer":{"text":"AFK Macro"}}]}'

    payloadFile := A_Temp "\brawlmacro_payload_" A_TickCount ".json"
    try FileDelete(payloadFile)
    try FileAppend(json, payloadFile, "UTF-8")

    ; Usa curl.exe (incluido en Windows 10 1803+) para multipart/form-data
    cmd := A_ComSpec ' /c curl.exe -s -X POST'
         . ' -F "payload_json=<' payloadFile '"'
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
    for cb in [cbInic, cbPar, cbDest, cbAlt, cbMile]
        cb.SetFont("s9", "Segoe UI")

    lblStatus := wg.Add("Text", "x12 y226 w" (W - 24) " h16 c" colorTextoPrincipal " Background" colorFondoPrincipal, "")
    lblStatus.SetFont("s9 Italic", "Segoe UI")

    btnW := Round((W - 36) / 2)
    btnTest := wg.Add("Text", "x12 y248 w" btnW " h28 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(0x1F9EA) " Probar")
    btnSave := wg.Add("Text", "x" (24 + btnW) " y248 w" btnW " h28 +0x201 Background" colorBotonNormal " c" colorBtnTexto " Center", Chr(0x1F4BE) " Guardar")
    for b in [btnTest, btnSave]
        b.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI")

    aplicarEstado := (*) => (
        webhookURL := urlEdit.Value,
        webhookEnabled := cbEnable.Value,
        webhookEventos["iniciado"]   := cbInic.Value,
        webhookEventos["parado"]     := cbPar.Value,
        webhookEventos["destruccion"] := cbDest.Value,
        webhookEventos["altf4"]      := cbAlt.Value,
        webhookEventos["milestone"]  := cbMile.Value,
        GuardarWebhook()
    )

    btnTest.OnEvent("Click", (*) => (
        aplicarEstado(),
        (webhookURL = "" ? (lblStatus.Value := "Pon una URL antes de probar.", lblStatus.Opt("cFF5555"))
            : (EnviarWebhookForce("🧪 Test desde AFK Macro", "Si ves este mensaje, el webhook funciona correctamente.", "5865F2"),
               lblStatus.Value := "Mensaje enviado — revisa Discord.", lblStatus.Opt("c00CC44")))
    ))
    btnSave.OnEvent("Click", (*) => (aplicarEstado(), LimpiarHoverGui(wg), wg.Destroy(), webhookGuiRef := ""))
    RegistrarHover(btnTest, () => colorBotonNormal)
    RegistrarHover(btnSave, () => colorBotonNormal)

    wg.Show("w" W " h288 Center")
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
    global configPath, miGui, historialGui
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
    dirs := [{lbl:"Normal →", d:1}, {lbl:"← Inverso", d:-1}]
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
    RedondearVentana(rgbGui.Hwnd, 14)
    rgbGuiVisible := true
    ; Asegurar que el timer corre para animar el preview (aunque no haya elementos activos)
    SetTimer(ActualizarRGB, 60)
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
    AbrirPanelRGB()
    AbrirPanelRGB()
}

RGBSetDireccion(val, *) {
    global rgbDireccion
    rgbDireccion := val
    GuardarRGBs()
    AbrirPanelRGB()
    AbrirPanelRGB()
}

RGBSetSaturacion(val, *) {
    global rgbSaturacion
    rgbSaturacion := val
    GuardarRGBs()
    AbrirPanelRGB()
    AbrirPanelRGB()
}

RGBSetBrillo(val, *) {
    global rgbBrillo
    rgbBrillo := val
    GuardarRGBs()
    AbrirPanelRGB()
    AbrirPanelRGB()
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
        SetTimer(ActualizarRGB, 60)
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
        if (i = temas.Length     && !eggPremiumDesbloqueado)
            continue
        if (i = temas.Length - 1 && !eggBlancoDesbloqueado)
            continue
        if (i = temas.Length - 2 && !eggSolarDesbloqueado)
            continue
        if (i = temas.Length - 3 && !eggVoidDesbloqueado)
            continue
        if (i = temas.Length - 4 && !eggDesbloqueado)
            continue
        if (i = temas.Length - 5 && !eggShadowDesbloqueado)
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
        isSecret := (entry.idx >= temas.Length - 5)
        esActivo := (entry.idx = temaActual)

        btn := temaGui.Add("Text",
            "x0 y" yShow " w" anchoPnl " h" alturaItem
            " +0x201 Background" entry.tema.fondo, "")
        local capturedEntry := entry
        btn.OnEvent("Click", MakeTemaClosure(capturedEntry))
        RegistrarHover(btn, MakeColorFn(entry.tema.fondo), MakeColorFn(AclararHex(entry.tema.fondo, 0.12)))
        InstalarSubclassTemaCard(btn, entry, esActivo, isSecret)
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
    global temaActual, temaBotones, temasVisiblesGlobal
    global temaGui, colorBarra, colorTextoBarra
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
        temaBarraCtrl.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
        DllCall("InvalidateRect", "Ptr", temaBarraCtrl.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", temaBarraCtrl.Hwnd)
    }
    ; Marcar la card activa
    for i, btn in temaBotones {
        e := temasVisiblesGlobal[i]
        if (temaCardData.Has(btn.Hwnd)) {
            temaCardData[btn.Hwnd].esActivo := (e.idx = temaActual)
            DllCall("InvalidateRect", "Ptr", btn.Hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", btn.Hwnd)
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
        temaBarraCtrl.SetFont("s11 c" t.textoBarra " Bold", "Segoe UI Semibold")
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
    temaActual := temas.Length - 4
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

; Trigger LIGHT: clic izq→centro→der una sola vez (3 clics en orden)
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
    temaActual := temas.Length - 2
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
    temaActual := temas.Length - 1
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
global temaCardCbs := []

InstalarSubclassTemaCard(btn, entry, esActivo, esSecreto := false) {
    global temaCardData, temaCardCbs
    temaCardData[btn.Hwnd] := {
        tema: entry.tema,
        nombre: entry.nombre,
        esActivo: esActivo,
        esSecreto: esSecreto
    }
    cb := CallbackCreate(TemaCardSubclassProc, "F", 6)
    temaCardCbs.Push(cb)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", btn.Hwnd, "Ptr", cb, "Ptr", 14, "Ptr", 0)
}

TemaCardSubclassProc(hWnd, uMsg, wParam, lParam, idSubclass, refData) {
    static WM_PAINT := 0x000F, WM_ERASEBKGND := 0x0014
    if (uMsg = WM_ERASEBKGND)
        return 1
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

    memDC  := DllCall("CreateCompatibleDC",     "Ptr", hdc, "Ptr")
    hbm    := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr")
    oldBmp := DllCall("SelectObject",           "Ptr", memDC, "Ptr", hbm, "Ptr")

    ; ── 1. Fondo del tema ──
    bgr := HexToBGR(tema.fondo)
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
            wText := w - xText - 75.0  ; deja espacio para swatches + check

            if (data.esSecreto) {
                ; Renderizado arcoíris token-a-token para temas secretos
                palette := [0xFF4040FF, 0xFF0088FF, 0xFF00DDFF, 0xFF44DD44, 0xFFDDDD00, 0xFFFF44DD, 0xFFFF4488]
                tokens := StrSplit(data.nombre, " ")
                ; Medir total
                totalTok := 0.0
                tokWs := []
                for j, tok in tokens {
                    bb := Buffer(16, 0)
                    rRect := Buffer(16, 0)
                    NumPut("Float", 0.0, rRect, 0), NumPut("Float", 0.0, rRect, 4)
                    NumPut("Float", 500.0, rRect, 8), NumPut("Float", 50.0, rRect, 12)
                    cp := 0, ln := 0
                    DllCall("gdiplus\GdipMeasureString", "Ptr", g, "WStr", tok, "Int", StrLen(tok), "Ptr", font, "Ptr", rRect, "Ptr", fmt, "Ptr", bb, "Int*", &cp, "Int*", &ln)
                    tw := NumGet(bb, 8, "Float")
                    tokWs.Push(tw)
                    totalTok += tw + 4.0
                }
                totalTok -= 4.0
                xCur := xText
                for j, tok in tokens {
                    col := palette[Mod(j - 1, palette.Length) + 1]
                    brushT := 0
                    DllCall("gdiplus\GdipCreateSolidFill", "UInt", col, "Ptr*", &brushT)
                    rTok := Buffer(16, 0)
                    NumPut("Float", xCur, rTok, 0)
                    NumPut("Float", 0.0,  rTok, 4)
                    NumPut("Float", tokWs[j] + 4.0, rTok, 8)
                    NumPut("Float", h * 1.0, rTok, 12)
                    DllCall("gdiplus\GdipDrawString", "Ptr", g, "WStr", tok, "Int", StrLen(tok), "Ptr", font, "Ptr", rTok, "Ptr", fmt, "Ptr", brushT)
                    DllCall("gdiplus\GdipDeleteBrush", "Ptr", brushT)
                    xCur += tokWs[j] + 4.0
                }
            } else {
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
            }

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

TransicionTema(tema, guardar := true) {
    global temaTransStep, temaTransTema, temaTransGuardar, temaEnTransicion
    global temaTransOrigen
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra
    global colorBotonNormal, colorBotonHover, colorLogoMacro, colorBtnTexto
    global colorFondoHistorial, colorCooldown, colorAFK
    global colorLuzActiva, colorLuzAccion, colorLuzApagado
    global colorHist1, colorHist2, colorHist3

    if (temaEnTransicion)
        return

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
    temaTransStep    := 0
    temaTransTema    := tema
    temaTransGuardar := guardar
    SetTimer(TransicionPaso, 16)
}

; Pinta un rectángulo de color sobre el HDC de una ventana
_PintarRect(hwnd, hexColor, x, y, w, h) {
    hDC := DllCall("GetDC", "Ptr", hwnd, "Ptr")
    r   := "0x" SubStr(hexColor,1,2)
    g   := "0x" SubStr(hexColor,3,2)
    b   := "0x" SubStr(hexColor,5,2)
    colorRef := (b << 16) | (g << 8) | r
    hBrush := DllCall("CreateSolidBrush", "UInt", colorRef, "Ptr")
    rc := Buffer(16,0)
    NumPut("Int", x,   rc,  0)
    NumPut("Int", y,   rc,  4)
    NumPut("Int", x+w, rc,  8)
    NumPut("Int", y+h, rc, 12)
    DllCall("FillRect", "Ptr", hDC, "Ptr", rc, "Ptr", hBrush)
    DllCall("DeleteObject", "Ptr", hBrush)
    DllCall("ReleaseDC", "Ptr", hwnd, "Ptr", hDC)
}

TransicionPaso() {
    global temaTransStep, temaTransTema, temaTransGuardar, temaEnTransicion
    global temaTransOrigen, miGui, historialGui
    global barra, barraHistorial, colorBarraOverride
    global tituloMacro, timerLabel, cooldownText, afkText, secuenciasLabel, destruccionesLabel, contadorLabel, logoMacro
    global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose
    global btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros
    global colorLogoEnTransicion, colorFondoEnTransicion
    global luzActiva, luzAccion, luzApagado, historialBox, separadorHistorial
    global scrollTrack, scrollThumb

    pasos := 22
    temaTransStep += 1

    t  := Min(temaTransStep / pasos, 1.0)
    t2 := t < 0.5 ? 4*t*t*t : 1 - (-2*t+2)**3/2

    ; Colores interpolados para este frame
    cFondo     := LerpHex(temaTransOrigen.fondo,      temaTransTema.fondo,      t2)
    cBarra     := LerpHex(temaTransOrigen.barra,      temaTransTema.barra,      t2)
    cBoton     := LerpHex(temaTransOrigen.boton,      temaTransTema.boton,      t2)
    cHover     := LerpHex(temaTransOrigen.hover,      temaTransTema.hover,      t2)
    cFondoHist := LerpHex(temaTransOrigen.historial,  temaTransTema.historial,  t2)
    colorLogoEnTransicion  := LerpHex(temaTransOrigen.logo, temaTransTema.logo, t2)
    colorFondoEnTransicion := cFondo
    colorBarraOverride     := cBarra

    ; Dimensiones
    miGui.GetPos(,, &mw, &mh)
    historialGui.GetPos(,, &hw, &hh)
    barra.GetPos(,, , &bh)
    barraHistorial.GetPos(,, , &hbh)

    ; Repintar fondo de ambas ventanas
    _PintarRect(miGui.Hwnd,        cFondo,     0, bh,  mw, mh - bh)
    _PintarRect(historialGui.Hwnd, cFondo,     0, hbh, hw, hh - hbh)

    ; Bg del RichEdit del historial (interpolado de historial color)
    if (IsObject(historialBox))
        SendMessage(0x0443, 0, HexToBGR(cFondoHist), , "ahk_id " historialBox.Hwnd)

    ; Forzar repaint de las barras subclasseadas
    DllCall("InvalidateRect", "Ptr", barra.Hwnd, "Ptr", 0, "Int", 0)
    DllCall("InvalidateRect", "Ptr", barraHistorial.Hwnd, "Ptr", 0, "Int", 0)

    ; TODOS los botones
    for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros] {
        if (IsObject(btn)) {
            btn.Opt("Background" cBoton)
            DllCall("InvalidateRect", "Ptr", btn.Hwnd, "Ptr", 0, "Int", 1)
        }
    }

    ; Labels con bg sólido
    for ctrl in [tituloMacro, timerLabel, cooldownText, afkText, secuenciasLabel, destruccionesLabel, contadorLabel] {
        if (IsObject(ctrl)) {
            ctrl.Opt("Background" cFondo)
            DllCall("InvalidateRect", "Ptr", ctrl.Hwnd, "Ptr", 0, "Int", 1)
        }
    }

    ; Luces (bg de los Progress controls)
    for luz in [luzActiva, luzAccion, luzApagado] {
        if (IsObject(luz)) {
            luz.Opt("Background" cFondo)
            DllCall("InvalidateRect", "Ptr", luz.Hwnd, "Ptr", 0, "Int", 1)
        }
    }

    ; Separador del historial (sigue al colorBarra)
    if (IsObject(separadorHistorial)) {
        separadorHistorial.Opt("Background" cBarra)
        DllCall("InvalidateRect", "Ptr", separadorHistorial.Hwnd, "Ptr", 0, "Int", 1)
    }

    ; Scrollbar personalizado
    if (IsObject(scrollTrack)) {
        scrollTrack.Opt("Background" cBoton)
        DllCall("InvalidateRect", "Ptr", scrollTrack.Hwnd, "Ptr", 0, "Int", 1)
    }
    if (IsObject(scrollThumb)) {
        scrollThumb.Opt("Background" cHover)
        DllCall("InvalidateRect", "Ptr", scrollThumb.Hwnd, "Ptr", 0, "Int", 1)
    }

    if (IsObject(logoMacro))
        DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 0)

    if (temaTransStep > pasos) {
        colorBarraOverride := ""
        AplicarTema(temaTransTema, temaTransGuardar, true)
        SetTimer(TransicionPaso, 0)
        temaEnTransicion := false
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
    global miGui, historialGui, historialBox, barra, barraHistorial, logoMacro, tituloMacro, timerLabel
    global cooldownText, afkText, secuenciasLabel, destruccionesLabel, luzActiva, luzAccion, luzApagado
    global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorVentanaHistorial, colorFondoHistorial, colorCooldown, colorAFK
    global colorBotonNormal, colorBotonHover, colorLogoMacro, colorLuzActiva, colorLuzAccion, colorLuzApagado
    global colorBtnTexto, colorHist1, colorHist2, colorHist3
    global activo
    global temaPremiumActivo, rgbActivo, rgbBarra, rgbBotones, rgbLogo, rgbTexto

    ; ── Detección del tema PREMIUM (multi-hue RGB en todo) ──
    temaPremiumActivo := InStr(tema.nombre, "P R E M I U M") > 0
    if (temaPremiumActivo) {
        rgbActivo := true
        SetTimer(ActualizarRGB, 60)
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

    miGui.BackColor := colorFondoPrincipal
    historialGui.BackColor := colorVentanaHistorial
    barra.Opt("Background" colorBarra)
    barra.SetFont("s13 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barraHistorial.Opt("Background" colorBarra)
    barraHistorial.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    if (IsObject(separadorHistorial))
        separadorHistorial.Opt("Background" colorBarra)
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
    logoMacro.Opt("c" colorLogoMacro)
    logoMacro.SetFont("s49 c" colorLogoMacro " Bold", "Segoe UI Symbol")
    DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
    tituloMacro.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    tituloMacro.SetFont("s13 c" colorTextoPrincipal " Bold", "Segoe UI Semibold")
    timerLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    timerLabel.SetFont("s13 c" colorTextoPrincipal " Bold", "Segoe UI Semibold")
    if (IsObject(contadorLabel))
        contadorLabel.Opt("Background" colorVentanaHistorial " c" colorTextoPrincipal)
    secuenciasLabel.Opt("Background" colorVentanaHistorial " c" colorTextoPrincipal)
    if (IsObject(destruccionesLabel))
        destruccionesLabel.Opt("Background" colorVentanaHistorial " c" colorTextoPrincipal)
    cooldownText.Opt("Background" colorVentanaHistorial " c" colorCooldown)
    afkText.Opt("Background" colorVentanaHistorial " c" colorAFK)
    global scrollTrack, scrollThumb
    if (IsObject(scrollTrack)) {
        scrollTrack.Opt("Background" colorBotonNormal)
        DllCall("InvalidateRect", "Ptr", scrollTrack.Hwnd, "Ptr", 0, "Int", 1)
    }
    if (IsObject(scrollThumb)) {
        scrollThumb.Opt("Background" colorBotonHover)
        DllCall("InvalidateRect", "Ptr", scrollThumb.Hwnd, "Ptr", 0, "Int", 1)
    }
    luzActiva.Opt("Background" colorFondoPrincipal)
    luzAccion.Opt("Background" colorFondoPrincipal)
    luzApagado.Opt("Background" colorFondoPrincipal)
    SendMessage(0x0443, 0, HexToBGR(colorFondoHistorial), , "ahk_id " historialBox.Hwnd)
    for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros] {
        btn.Opt("Background" colorBotonNormal " c" colorBtnTexto)
        btn.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")
        if (!fromTrans) {
            DllCall("InvalidateRect", "Ptr", btn.Hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", btn.Hwnd)
        }
    }
    for btn in [btnIniciar, btnParar]
        btn.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
    btnUpdate.SetFont("s8 c" colorBtnTexto, "Segoe UI Symbol")
    btnOverlay.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnRGBBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnStatsBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnWebhook.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnLogros.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    ActualizarEstadoVisual()
    if (fromTrans) {
        ; Reactivar redraws y forzar un único repintado atómico — sin frame en blanco
        DllCall("SendMessage", "Ptr", miGui.Hwnd,        "UInt", 0xB, "Ptr", 1, "Ptr", 0)
        DllCall("SendMessage", "Ptr", historialGui.Hwnd, "UInt", 0xB, "Ptr", 1, "Ptr", 0)
        DllCall("RedrawWindow", "Ptr", miGui.Hwnd,        "Ptr", 0, "Ptr", 0, "UInt", 0x85)
        DllCall("RedrawWindow", "Ptr", historialGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x85)
    }
    ; Actualizar borde de color en todas las ventanas abiertas
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

        for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook]
            btn.Opt("Background" cBoton " c000000")

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
        for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros]
            btn.Opt("Background" colorRGBActual " c000000")
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
        btnIniciar.Opt("Background" (rgbBotones ? colorRGBActual : colorBotonHover) " c" colorBtnTexto)
        btnParar.Opt("Background"   (rgbBotones ? colorRGBActual : colorBotonNormal) " c" colorBtnTexto)
        SetLuz(luzActiva, colorLuzActiva)
        SetLuz(luzAccion, colorBotonNormal)
        SetLuz(luzApagado, colorBotonNormal)
    } else {
        btnIniciar.Opt("Background" (rgbBotones ? colorRGBActual : colorBotonNormal) " c" colorBtnTexto)
        btnParar.Opt("Background"   (rgbBotones ? colorRGBActual : colorBotonNormal) " c" colorBtnTexto)
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
    global miGui, historialGui, overlayPartMain, overlayPartHist
    GuardarStats()
    GuardarRGBs()
    IniWrite(historialVisible ? 1 : 0, configPath, "UI", "HistorialVisible")
    GuardarPosiciones()
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
    GuardarStats()
    GuardarRGBs()
    IniWrite(historialVisible ? 1 : 0, configPath, "UI", "HistorialVisible")
    GuardarPosiciones()
    Reload()
}

AbrirCodigo(*) {
    Run('notepad.exe "' A_ScriptDir '\brawlmacrotct.ahk"')
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
    x := y := w := h := 0
    WinGetPos(&x, &y, &w, &h, "ahk_id " hwnd)
    rgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w + 1, "Int", h + 1, "Int", curva, "Int", curva, "Ptr")
    DllCall("SetWindowRgn", "Ptr", hwnd, "Ptr", rgn, "Int", true)
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
SetLuz(control, color) {
    control.Opt("c" color)
}

LuzAccionFlash(catColor := "") {
    global luzAccion, colorLuzAccion, colorBotonNormal
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
    global activo, temaEnTransicion, rgbBarra
    global pulsoBrilloDir, pulsoBrilloT
    global barraOndaOffset, barraExtraBrillo
    if (!activo || temaEnTransicion) {
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
    global activo, logoMacro, colorLogoMacro, temaEnTransicion
    global logosPulsoDir, logosPulsoT
    if (!activo || temaEnTransicion)
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
    logoMacro.SetFont("s49 c" c " Bold", "Segoe UI Symbol")
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
        MostrarAviso()
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

AgregarHistorial(texto, CH := "") {
    global historialBox, histUltimoTexto, histUltimoCount, histUltimoLongLinea
    global contadorAcciones, histFlashStep
    local hora := FormatTime(A_Now, "HH:mm:ss")
    local colorHex := (CH != "" ? CH : ObtenerColorHistorial())

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
    SendMessage(WM_VSCROLL, SB_TOP, 0, , "ahk_id " hRich)
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
ActualizarCooldowns(*) {
    global pasosPrioridad, pasosNormales, cooldownText
    textoCooldown := ""

    restanteGlobal := BloqueoGlobalRestante()
    if (restanteGlobal > 0)
        textoCooldown .= "[GLOBAL] bloqueo: " Round(restanteGlobal / 1000, 1) "s`n"

    for paso in pasosPrioridad {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0
        if paso.HasProp("cooldown") {
            restante := paso.cooldown - (A_TickCount - paso.lastUsed)
            if (restante > 0)
                textoCooldown .= "[P] " paso.nombre ": " Round(restante / 1000, 1) "s`n"
        }
    }

    for paso in pasosNormales {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0
        if paso.HasProp("cooldown") {
            restante := paso.cooldown - (A_TickCount - paso.lastUsed)
            if (restante > 0)
                textoCooldown .= "[N] " paso.nombre ": " Round(restante / 1000, 1) "s`n"
        }
    }

    if textoCooldown = ""
        textoCooldown := "Sin cooldowns activos"
    if cooldownText.Value != textoCooldown
        cooldownText.Value := textoCooldown
}

ActualizarAFK(*) {
    global ultimoCambio, afkText, colorAFK, rgbActivo, modoDestruccion
    global timerLabel, colorTextoPrincipal, afkAlertaFlash
    tiempo := A_TickCount - ultimoCambio
    restante := 270000 - tiempo

    ; Activar Modo Destruccion cuando el contador llega a 0
    if (restante <= 0 && !modoDestruccion) {
        modoDestruccion := true
        ResetStreak()
        AgregarHistorial("⚠️ MODO DESTRUCCION ACTIVADO", "FF4444")
        EnviarWebhookEvento("destruccion")
    }

    if (modoDestruccion) {
        ; Mostrar cuenta atras del minuto extra antes de Alt+F4
        restanteDestru := 330000 - tiempo
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
    secuenciasLabel.Value := Chr(0x276E) "  Secuencias: " contadorSecuencias "  " Chr(0x276F)
    VerificarMilestone(contadorSecuencias)
}

ActualizarDestrucciones(*) {
    global contadorDestruccion, destruccionesLabel
    if (!IsObject(destruccionesLabel))
        return
    destruccionesLabel.Value := Chr(0x276E) "  Destrucciones: " contadorDestruccion "  " Chr(0x276F)
}

BuscarPixel(paso, &x, &y) {
    global scaleX, scaleY
    x1 := Round(paso.x1 * scaleX)
    y1 := Round(paso.y1 * scaleY)
    x2 := Round(paso.x2 * scaleX)
    y2 := Round(paso.y2 * scaleY)
    x := ""
    y := ""
    if PixelSearch(&foundX, &foundY, x1, y1, x2, y2, paso.color, paso.tolerancia) {
        x := foundX
        y := foundY
        return true
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
CheckPrioridad() {
    global pasosPrioridad, pasosNormales, activo, accionEnCurso, ultimoCambio, contadorSecuencias

    if BloqueoGlobalActivo()
        return false
    if !IsObject(pasosPrioridad)
        return false

    for paso in pasosPrioridad {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0
        if paso.HasProp("cooldown") && (A_TickCount - paso.lastUsed < paso.cooldown)
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
                                if (paso.nombre = "LEAVINGGAME..." && paso.cooldown = 190000) {
                                    contadorSecuencias += 1
                                    ActualizarSecuencias()
                                    AgregarHistorial(paso.nombre " -> COOLDOWN " Round(paso.cooldown/1000) "s | Secuencias: " contadorSecuencias, paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                                    DespuesDeAccion(true)
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
    global tiempoUltimoLanzamiento
    static PASOS_ENTRE_PRIO := 5   ; CheckPrioridad cada N pasos normales revisados

    if (!activo || accionEnCurso || BloqueoGlobalActivo())
        return
    accionEnCurso := true

    if (modoCadena) {
        if (A_TickCount > finCadena) {
            modoCadena := false
        } else {
            for p in pasosNormales {
                if (p.nombre = pasoCadena) {
                    encontrado := BuscarPixel(p, &x, &y)
                    if (encontrado) {
                        MouseMove(x, y, 5)
                        Click
                        if p.HasProp("accion")
                            SendInput "{" p.accion "}"
                        p.lastUsed := A_TickCount
                        ActivarBloqueoGlobal(p)
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
            if (paso.nombre != ultimoPasoEjecutado) {
                ultimoCambio := A_TickCount
                ultimoPasoEjecutado := paso.nombre
            }
            AgregarHistorial(paso.nombre, paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
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
    tiempoSinCambios := A_TickCount - ultimoCambio
    if (tiempoSinCambios > 400000) {
        ultimoCambio := A_TickCount
        Loop 1 {
            SendInput "{Esc}"
            Sleep 1500
        }
        Loop 2 {
            SendInput "c"
            Sleep 1500
        }
    }

    ; ===== MODO DESTRUCCION =====
    if (modoDestruccion && tiempoSinCambios > 330000) {
        modoDestruccion := false
        contadorDestruccion += 1
        ActualizarDestrucciones()
        ultimoCambio := A_TickCount
        ultimoPasoEjecutado := ""

        AgregarHistorial("💀 Alt+F4 ejecutado - reiniciando Brawlhalla", "FF0000")
        EnviarWebhookEvento("altf4")
        SendInput "!{F4}"
        Sleep 7000

        AgregarHistorial("🔄 Abriendo Brawlhalla...", "FF8800")
        SendInput "{LWin}"
        Sleep 4000
        SendInput "brawlhalla"
        Sleep 1500
        SendInput "{Enter}"
        tiempoUltimoLanzamiento := A_TickCount
    }

    ; ===== REINTENTO LANZAMIENTO =====

    if (tiempoUltimoLanzamiento > 0 && (A_TickCount - tiempoUltimoLanzamiento) > 60000) {
        tiempoUltimoLanzamiento := A_TickCount
        ultimoCambio := A_TickCount
        AgregarHistorial("⚠️ Sin detección tras 2 min - reintentando lanzamiento...", "FF8800")
        SendInput "{LWin}"
        Sleep 4000
        SendInput "brawlhalla"
        Sleep 1500
        SendInput "{Enter}"
    }

    MouseMove(1, 0, 0, "R")
    MouseMove(-1, 0, 0, "R")
    global ultimoAfkMove
    ultimoAfkMove := A_TickCount   ; watchdog: marca que el AFK acaba de moverse
    accionEnCurso := false
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
    global confetiGui, confetiParticles, confetiActivo, miGui

    if (!IsObject(miGui))
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
    global confetiGui, confetiParticles, confetiActivo
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
        { id: "godmode",      nombre: "God Mode",             desc: "Desbloquea TODOS los temas",       icono: Chr(0x1F451), desbloqueado: false }
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
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado, eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado

    totalSecs := totalSecuenciasGuardadas + contadorSecuencias
    totalDestru := totalDestruccionGuardada + contadorDestruccion
    sesionHoras := tiempoAcumulado / 3600000.0
    if (timerActivo)
        sesionHoras += (A_TickCount - tiempoInicio) / 3600000.0
    eggsCount := (eggDesbloqueado ? 1 : 0) + (eggVoidDesbloqueado ? 1 : 0) + (eggShadowDesbloqueado ? 1 : 0)
                 + (eggSolarDesbloqueado ? 1 : 0) + (eggBlancoDesbloqueado ? 1 : 0) + (eggPremiumDesbloqueado ? 1 : 0)
    cumplidos := Map(
        "primera",      totalSecs >= 1,
        "centurion",    totalSecs >= 100,
        "millennium",   totalSecs >= 1000,
        "resistencia",  totalHorasGuardadas >= 24,
        "marathon",     sesionHoras >= 8,
        "phantom",      streakMax >= 50,
        "destructor",   totalDestru >= 10,
        "lucky",        totalCriticos >= 1,
        "luckyMax",     totalCriticos >= 50,
        "coleccionista", eggsCount >= 3,
        "godmode",      eggsCount >= 6
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
    global logros, logrosGui, logrosGuiVisible
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto

    if (logrosGuiVisible && IsObject(logrosGui)) {
        try LimpiarHoverGui(logrosGui)
        try logrosGui.Destroy()
        logrosGuiVisible := false
        return
    }

    W := 340
    rowH := 42
    H := 36 + logros.Length * rowH + 12

    logrosGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    logrosGui.BackColor := colorFondoPrincipal

    desbloqueadosCount := 0
    for l in logros
        if (l.desbloqueado)
            desbloqueadosCount += 1

    barr := logrosGui.Add("Text", "x0 y0 w" W " h32 Background" colorBarra " Center +0x200", Chr(0x1F3C5) "  Logros  " Chr(0x2022) "  " desbloqueadosCount "/" logros.Length)
    barr.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => (LimpiarHoverGui(logrosGui), logrosGui.Destroy(), logrosGuiVisible := false))

    yPos := 38
    for l in logros {
        if (l.desbloqueado) {
            cBg := colorBotonNormal
            cFg := colorBtnTexto
            iconC := "FFD700"
        } else {
            cBg := "2A2A2A"
            cFg := "888888"
            iconC := "666666"
        }
        ; Icono a la izquierda
        lblIcon := logrosGui.Add("Text", "x10 y" yPos " w36 h" (rowH - 6) " Center Background" cBg " c" iconC, l.icono)
        lblIcon.SetFont("s16", "Segoe UI Emoji")
        ; Nombre
        lblName := logrosGui.Add("Text", "x46 y" (yPos + 2) " w" (W - 56) " h18 Background" cBg " c" cFg, "  " l.nombre)
        lblName.SetFont("s10 Bold", "Segoe UI Semibold")
        ; Descripción
        lblDesc := logrosGui.Add("Text", "x46 y" (yPos + 20) " w" (W - 56) " h14 Background" cBg " c" cFg, "  " l.desc)
        lblDesc.SetFont("s8 Italic", "Segoe UI")
        yPos += rowH
    }

    logrosGui.Show("w" W " h" H " Center")
    RedondearVentana(logrosGui.Hwnd, 14)
    logrosGuiVisible := true
    RegistrarAutoCierre(logrosGui, (*) => (LimpiarHoverGui(logrosGui), logrosGui.Destroy(), logrosGuiVisible := false))
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

; ===== SCROLLBAR CUSTOM (sin WS_VSCROLL en el RichEdit → no hay barra nativa que se pelee) =====
; Usamos EM_GETLINECOUNT / EM_GETFIRSTVISIBLELINE en lugar de GetScrollInfo porque
; los EM_ messages funcionan siempre, aunque el control no tenga WS_VSCROLL.
ActualizarScrollbar() {
    global historialBox, scrollTrack, scrollThumb, historialVisible
    global ultimoThumbY, ultimoThumbH
    if (!historialVisible || !IsObject(historialBox) || !IsObject(scrollTrack) || !IsObject(scrollThumb))
        return

    static EM_GETLINECOUNT        := 0x00BA
    static EM_GETFIRSTVISIBLELINE := 0x00CE

    totalLines   := SendMessage(EM_GETLINECOUNT,        0, 0, , "ahk_id " historialBox.Hwnd)
    firstVisLine := SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, , "ahk_id " historialBox.Hwnd)

    ; Líneas visibles: la box es h=110 y la fuente s11 ≈ 18-19 px/línea → ~6 visibles
    visibleLines := 6

    scrollTrack.GetPos(&trackX, &trackY, &trackW, &trackH)

    if (totalLines <= visibleLines || totalLines <= 0) {
        nuevoY := trackY
        nuevoH := trackH
    } else {
        ratioVisible := visibleLines / totalLines
        nuevoH := Max(20, Round(trackH * ratioVisible))
        maxFirstLine := totalLines - visibleLines
        if (maxFirstLine <= 0)
            maxFirstLine := 1
        ratioPos := firstVisLine / maxFirstLine
        if (ratioPos < 0)
            ratioPos := 0
        if (ratioPos > 1)
            ratioPos := 1
        nuevoY := trackY + Round((trackH - nuevoH) * ratioPos)
    }

    ; Sólo mover si cambió — evita parpadeo por repaint redundante cada 150 ms
    if (nuevoY != ultimoThumbY || nuevoH != ultimoThumbH) {
        scrollThumb.Move(trackX + 1, nuevoY, trackW - 2, nuevoH)
        ultimoThumbY := nuevoY
        ultimoThumbH := nuevoH
    }
}

ClickScrollbar(*) {
    global historialBox, scrollTrack, scrollThumb, historialGui
    if (!IsObject(historialBox) || !IsObject(scrollTrack) || !IsObject(scrollThumb))
        return

    static EM_GETLINECOUNT        := 0x00BA
    static EM_GETFIRSTVISIBLELINE := 0x00CE
    static EM_LINESCROLL          := 0x00B6
    static visibleLines           := 6

    historialGui.GetPos(&hgX, &hgY)
    scrollTrack.GetPos(, &trackYGui,, &trackH)
    scrollThumb.GetPos(, &thumbYGui,, &thumbH)
    trackScreenY := hgY + trackYGui
    thumbScreenY := hgY + thumbYGui

    ; Offset del click dentro del thumb (clave para que el drag no "salte"):
    ; si el click cayó dentro del thumb, mantenemos ese offset durante el drag.
    ; Si cayó en el track (fuera del thumb), centramos el thumb bajo el cursor.
    MouseGetPos(,, &mYInit)
    clickOffset := mYInit - thumbScreenY
    if (clickOffset < 0 || clickOffset > thumbH)
        clickOffset := thumbH / 2

    ; Recorrido máximo del thumb: trackH - thumbH (el thumb no puede salirse del track)
    effectiveRange := trackH - thumbH
    if (effectiveRange < 1)
        effectiveRange := 1

    while (GetKeyState("LButton", "P")) {
        MouseGetPos(,, &mY)

        ; Nueva posición del top del thumb relativa al top del track
        newThumbTopRel := (mY - clickOffset) - trackScreenY
        if (newThumbTopRel < 0)
            newThumbTopRel := 0
        if (newThumbTopRel > effectiveRange)
            newThumbTopRel := effectiveRange

        ratio := newThumbTopRel / effectiveRange

        totalLines   := SendMessage(EM_GETLINECOUNT,        0, 0, , "ahk_id " historialBox.Hwnd)
        firstVisLine := SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, , "ahk_id " historialBox.Hwnd)
        maxFirstLine := totalLines - visibleLines
        if (maxFirstLine <= 0)
            maxFirstLine := 1

        targetLine := Round(maxFirstLine * ratio)
        delta := targetLine - firstVisLine
        if (delta != 0)
            SendMessage(EM_LINESCROLL, 0, delta, , "ahk_id " historialBox.Hwnd)

        ActualizarScrollbar()
        Sleep(16)
    }
}

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
    global colorFondoHistorial
    static EM_GETSCROLLPOS := 0x04DD, EM_SETSCROLLPOS := 0x04DE
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

LanzarBrawlhalla() {
    global brawlhallaLanzado
    if (brawlhallaLanzado)
        return  ; ya se lanzó esta sesión, no relanzar al pulsar Iniciar otra vez
    brawlhallaLanzado := true
    AgregarHistorial(Chr(0x1F504) " Abriendo Brawlhalla...", "FF8800")

    ; Método Windows: Win → espera 3s → escribir → espera 2s → Enter
    SendInput "{LWin}"
    Sleep 3000
    SendInput "brawlhalla"
    Sleep 2000
    SendInput "{Enter}"
}

Iniciar(*) {
    global activo, ultimoCambio, modoDestruccion, ultimoPasoEjecutado
    global pulsoBrilloDir, pulsoBrilloT, logosPulsoDir, logosPulsoT, colorBarra
    global logoVelObjetivo, logoVelMax
    global histUltimoTexto
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

    ; Lanzar Brawlhalla AHORA, antes de los timers que envían teclas (Esc/c)
    ; — si EjecutarMacro corre durante el Win+brawlhalla puede mandar Esc y cerrar el menú
    LanzarBrawlhalla()
    ultimoCambio := A_TickCount  ; resetea AFK contando desde DESPUÉS del lanzamiento

    SetTimer(EjecutarMacro, 50)
    SetTimer(ActualizarCooldowns, 100)
    SetTimer(ActualizarAFK, 200)
    SetTimer(PulsoBarraActivo, 40)
    SetTimer(PulsoLogoActivo, 50)
    SetTimer(() => BarraShimmer(colorBarra), -1)
    IniciarTimer()
    EnviarWebhookEvento("iniciado")
}

Parar(*) {
    global activo, accionEnCurso, bloqueoGlobalHasta, modoDestruccion, ultimoPasoEjecutado
    global tiempoUltimoLanzamiento, barra, barraHistorial, colorBarra, logoMacro, colorLogoMacro
    global logoVelObjetivo
    global afkAlertaFlash, afkText, colorAFK, timerLabel, colorTextoPrincipal
    activo := false
    logoVelObjetivo := 0.0
    accionEnCurso := false
    bloqueoGlobalHasta := 0
    modoDestruccion := false
    ultimoPasoEjecutado := ""
    tiempoUltimoLanzamiento := 0
    ActualizarEstadoVisual()
    SetTimer(EjecutarMacro, 0)
    SetTimer(ActualizarCooldowns, 0)
    SetTimer(ActualizarAFK, 0)
    SetTimer(PulsoBarraActivo, 0)
    SetTimer(PulsoLogoActivo, 0)
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
    EnviarWebhookEvento("parado")
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
    lblRepo := updateGui.Add("Text", "x16 y" linkY " w" (W - 32) " h16 Center Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x1F517) "  Repo: github.com/johantakuma2009-bit/brawlmacro")
    lblRepo.SetFont("s9 Underline", "Segoe UI")
    lblRepo.OnEvent("Click", (*) => Run("https://github.com/johantakuma2009-bit/brawlmacro"))

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
    global GITHUB_VERSION_URL, VERSION_ACTUAL, colorBotonNormal, colorBtnTexto

    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        urlConTimestamp := GITHUB_VERSION_URL "?t=" A_TickCount
        whr.Open("GET", urlConTimestamp, false)
        whr.Send()
        if (whr.Status != 200) {
            lblVer.Value := "—"
            lblVer.Opt("cFF5555")
            lblEstado.Value := Chr(0x26A0) "  Sin conexión con GitHub. Revisa tu internet."
            lblEstado.Opt("cFF5555")
            return
        }
        verRemota := Trim(whr.ResponseText, " `t`r`n")
        lblVer.Value := "v" verRemota

        if (VersionMayor(verRemota, VERSION_ACTUAL)) {
            lblVer.Opt("c00DD66")
            lblEstado.Value := Chr(0x1F389) "  ¡Nueva versión disponible! Pulsa para instalar."
            lblEstado.Opt("c00DD66")
            btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
            btnAct.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Semibold")
            btnAct._habilitado := true
            btnAct.OnEvent("Click", (*) => DescargarYActualizar(verRemota, lblEstado, btnAct))
        } else {
            lblVer.Opt("c" (ColorEsClaro(lblVer) ? "007733" : "88FFAA"))
            lblEstado.Value := Chr(0x2705) "  Estás al día con la última versión."
            lblEstado.Opt("c" (ColorEsClaro(lblEstado) ? "007733" : "88FFAA"))
        }
    } catch Error as e {
        lblVer.Value := "—"
        lblVer.Opt("cFF5555")
        lblEstado.Value := Chr(0x26A0) "  Error: " e.Message
        lblEstado.Opt("cFF5555")
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
    global GITHUB_SCRIPT_URL, updateGui, updateGuiVisible, configPath

    lblEstado.Value := Chr(0x2B07) "  Descargando v" verRemota " desde GitHub..."
    lblEstado.Opt("cFFAA00")
    btnAct.Opt("Background" colorBotonNormal " c555555")
    btnAct.SetFont("s10 c555555 Bold", "Segoe UI Semibold")
    btnAct._habilitado := false

    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
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

        FileAppend(whr.ResponseText, rutaTemp, "UTF-8")

        if (!FileExist(rutaTemp)) {
            lblEstado.Value := "Error: no se pudo escribir el archivo temporal."
            lblEstado.Opt("cFF5555")
            btnAct.Opt("Background" colorBotonNormal " c" colorBtnTexto)
            btnAct.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
            btnAct._habilitado := true
            return
        }

        FileCopy(rutaTemp, rutaScript, 1)
        try FileDelete(rutaTemp)

        ; Nueva versión → el egg COSMOS debe ganarse de nuevo

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
    global overlayPixeles, pasosPrioridad, pasosNormales, scaleX, scaleY, temas, temaActual

    try {
        if IsObject(overlayPixeles)
            overlayPixeles.Destroy()
    }

    sw := A_ScreenWidth
    sh := A_ScreenHeight

    overlayPixeles := Gui("-Caption +ToolWindow +AlwaysOnTop +E0x20")
    overlayPixeles.BackColor := "010101"
    WinSetTransColor("010101 200", overlayPixeles)
    overlayPixeles.Show("x0 y0 w" sw " h" sh " NoActivate")

    hWnd := overlayPixeles.Hwnd
    hDC  := DllCall("GetDC", "Ptr", hWnd, "Ptr")

    tema := temas[temaActual]

    ColoresCategoria(cat) {
        switch cat {
            case 1: return tema.histColor1
            case 2: return tema.histColor2
            case 3: return tema.histColor3
            case 4: return tema.texto
            case 5: return tema.luzAccion
            case 6: return tema.afk
        }
        return tema.histColor1
    }

    HexToColorRef(hex) {
        r := Integer("0x" SubStr(hex, 1, 2))
        g := Integer("0x" SubStr(hex, 3, 2))
        b := Integer("0x" SubStr(hex, 5, 2))
        return (b << 16) | (g << 8) | r
    }

    DibujarCuadrado(hDC, x1s, y1s, x2s, y2s, hexColor) {
        ; Tamaño real del área de búsqueda, mínimo 4×4 para que se vea
        minSize := 4
        ancho := Max(x2s - x1s + 1, minSize)
        alto  := Max(y2s - y1s + 1, minSize)
        ; Centrar el mínimo sobre el punto si era 1px
        rx := x1s - Max(0, Round((minSize - (x2s - x1s + 1)) / 2))
        ry := y1s - Max(0, Round((minSize - (y2s - y1s + 1)) / 2))

        colorRef := HexToColorRef(hexColor)

        hBrush := DllCall("CreateSolidBrush", "UInt", colorRef, "Ptr")
        rect   := Buffer(16, 0)
        NumPut("Int", rx,          rect, 0)
        NumPut("Int", ry,          rect, 4)
        NumPut("Int", rx + ancho,  rect, 8)
        NumPut("Int", ry + alto,   rect, 12)
        DllCall("FillRect", "Ptr", hDC, "Ptr", rect, "Ptr", hBrush)
        DllCall("DeleteObject", "Ptr", hBrush)

        ; Borde blanco fino para que se vea sobre cualquier fondo
        hPen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", 0xFFFFFF, "Ptr")
        hOldPen := DllCall("SelectObject", "Ptr", hDC, "Ptr", hPen)
        hNoBrush := DllCall("GetStockObject", "Int", 5, "Ptr")
        DllCall("SelectObject", "Ptr", hDC, "Ptr", hNoBrush)
        DllCall("Rectangle", "Ptr", hDC, "Int", rx, "Int", ry, "Int", rx + ancho, "Int", ry + alto)
        DllCall("SelectObject", "Ptr", hDC, "Ptr", hOldPen)
        DllCall("DeleteObject", "Ptr", hPen)
    }

    for paso in pasosPrioridad {
        x1s := Round(paso.x1 * scaleX)
        y1s := Round(paso.y1 * scaleY)
        x2s := Round(paso.x2 * scaleX)
        y2s := Round(paso.y2 * scaleY)
        cat := paso.HasProp("categoria") ? paso.categoria : 1
        DibujarCuadrado(hDC, x1s, y1s, x2s, y2s, ColoresCategoria(cat))
    }

    for paso in pasosNormales {
        x1s := Round(paso.x1 * scaleX)
        y1s := Round(paso.y1 * scaleY)
        x2s := Round(paso.x2 * scaleX)
        y2s := Round(paso.y2 * scaleY)
        cat := paso.HasProp("categoria") ? paso.categoria : 1
        DibujarCuadrado(hDC, x1s, y1s, x2s, y2s, ColoresCategoria(cat))
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

^w::AbrirPanelWebhook()
F1::Iniciar()
F2::Parar()
^r::AbrirPanelRGB()
!h::MostrarEstadisticas()

