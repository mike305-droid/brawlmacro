#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode("Pixel", "Screen")
CoordMode("Mouse", "Screen")

; ===== CONFIGURACION =====
configPath := A_ScriptDir "\brawlmacro_config.ini"
global eggsBackupPath := A_ScriptDir "\brawlmacro_eggs.txt"
global heartbeatPath := A_ScriptDir "\brawlmacro_heartbeat.txt"
global historialLogPath := A_ScriptDir "\brawlmacro_historial.log"
global VERSION_ACTUAL := "30.0.9"

; ===== TEMAS =====
temas := [
    ; ─────────── CLAROS / PASTEL ───────────
    ; Azules y fríos claros
    { nombre:"Hielo",      fondo:"E8F4FD", texto:"1A5276", barra:"85C1E9", textoBarra:"FFFFFF", historial:"F0F9FF", panel:"D6EAF8", cooldown:"E74C3C", afk:"2980B9", boton:"85C1E9", hover:"AED6F1", logo:"1A5276", luzOn:"2471A3", luzAccion:"2E86C1", luzOff:"1A5276",  btnTexto:"FFFFFF", histColor1:"1A5276", histColor2:"2E86C1", histColor3:"85C1E9" },
    { nombre:"Polar",      fondo:"F0F8FF", texto:"0B2545", barra:"8ECAE6", textoBarra:"0B2545", historial:"F8FCFF", panel:"D1E5F2", cooldown:"E63946", afk:"219EBC", boton:"8ECAE6", hover:"ADD8E6", logo:"0B2545", luzOn:"219EBC", luzAccion:"95D5B2", luzOff:"5E8AAE",  btnTexto:"0B2545", histColor1:"0B2545", histColor2:"219EBC", histColor3:"95D5B2" },
    { nombre:"Agua",       fondo:"D8F3F0", texto:"064C55", barra:"2E9E9A", textoBarra:"FFFFFF", historial:"ECFBF8", panel:"C7EDE8", cooldown:"D94848", afk:"1769AA", boton:"2E9E9A", hover:"4DB9B5", logo:"003C42", luzOn:"004A47", luzAccion:"00635F", luzOff:"003236",  btnTexto:"FFFFFF", histColor1:"064C55", histColor2:"00635F", histColor3:"2E9E9A" },
    ; Verdes claros
    { nombre:"Menta",      fondo:"FAF8F2", texto:"2C4A3E", barra:"A8E6CF", textoBarra:"1B3A2E", historial:"FEFDF8", panel:"D4F1E0", cooldown:"E07A5F", afk:"81B29A", boton:"A8E6CF", hover:"BBEFD9", logo:"2C4A3E", luzOn:"81B29A", luzAccion:"A8E6CF", luzOff:"2C4A3E",  btnTexto:"1B3A2E", histColor1:"2C4A3E", histColor2:"81B29A", histColor3:"A8E6CF" },
    { nombre:"Verde",      fondo:"F0FFF4", texto:"1B5E20", barra:"66BB6A", textoBarra:"FFFFFF", historial:"E8F5E9", panel:"C8E6C9", cooldown:"E53935", afk:"2E7D32", boton:"66BB6A", hover:"81C784", logo:"1B5E20", luzOn:"388E3C", luzAccion:"66BB6A", luzOff:"1B5E20",  btnTexto:"FFFFFF", histColor1:"1B5E20", histColor2:"388E3C", histColor3:"66BB6A" },
    ; Pastel mixto / neutros
    { nombre:"Macaron",    fondo:"FFF0F5", texto:"6A3D70", barra:"AED9E0", textoBarra:"2E4156", historial:"FFF6FA", panel:"F5C2C7", cooldown:"D8567A", afk:"8FB8C7", boton:"AED9E0", hover:"C5E3E8", logo:"6A3D70", luzOn:"95C8A8", luzAccion:"F5B0D6", luzOff:"6A3D70",  btnTexto:"2E4156", histColor1:"6A3D70", histColor2:"95C8A8", histColor3:"F5B0D6" },
    { nombre:"Nube",       fondo:"FAFAFA", texto:"37474F", barra:"B0BEC5", textoBarra:"FFFFFF", historial:"FCFCFC", panel:"ECEFF1", cooldown:"EF5350", afk:"78909C", boton:"B0BEC5", hover:"CFD8DC", logo:"37474F", luzOn:"78909C", luzAccion:"90A4AE", luzOff:"37474F",  btnTexto:"FFFFFF", histColor1:"37474F", histColor2:"78909C", histColor3:"90A4AE" },
    ; Morados / lilas claros
    { nombre:"Lavanda",    fondo:"F8F4FF", texto:"5E3A8C", barra:"C8B6E2", textoBarra:"FFFFFF", historial:"FCFAFF", panel:"E8DEFC", cooldown:"D87093", afk:"9370DB", boton:"C8B6E2", hover:"D4C5E8", logo:"5E3A8C", luzOn:"9370DB", luzAccion:"BA9CDB", luzOff:"5E3A8C",  btnTexto:"FFFFFF", histColor1:"5E3A8C", histColor2:"9370DB", histColor3:"BA9CDB" },
    { nombre:"Lila",       fondo:"EFE6FF", texto:"4A2C7A", barra:"7B61C9", textoBarra:"FFFFFF", historial:"F7F1FF", panel:"E1D3FF", cooldown:"D94A6A", afk:"3D5AFE", boton:"7B61C9", hover:"9279DC", logo:"271052", luzOn:"3B1D78", luzAccion:"4E279E", luzOff:"271052",  btnTexto:"FFFFFF", histColor1:"4A2C7A", histColor2:"4E279E", histColor3:"7B61C9" },
    ; Rosas / corales claros
    { nombre:"Sakura",     fondo:"FFF5F8", texto:"8B2252", barra:"F48FB1", textoBarra:"5D0030", historial:"FFF0F5", panel:"FCDDE8", cooldown:"C0392B", afk:"AD1457", boton:"F8BBD9", hover:"F48FB1", logo:"8B2252", luzOn:"C2185B", luzAccion:"E91E8C", luzOff:"8B2252",  btnTexto:"5D0030", histColor1:"8B2252", histColor2:"C2185B", histColor3:"F06292" },
    { nombre:"Rosa",       fondo:"FFE8F0", texto:"7A1040", barra:"E8528A", textoBarra:"FFFFFF", historial:"FFF0F5", panel:"FFDCEA", cooldown:"CC2244", afk:"D42070", boton:"E8528A", hover:"F07AAA", logo:"5A0028", luzOn:"C03060", luzAccion:"E04080", luzOff:"5A0028",  btnTexto:"FFFFFF", histColor1:"7A1040", histColor2:"E04080", histColor3:"CC3366" },
    { nombre:"Atardecer",  fondo:"FFE5D4", texto:"6B2F4A", barra:"E0735C", textoBarra:"FFF5EE", historial:"FFF2E8", panel:"F8C9A3", cooldown:"B91744", afk:"D4326B", boton:"E0735C", hover:"F08A6F", logo:"6B2F4A", luzOn:"A03A6E", luzAccion:"D4326B", luzOff:"6B2F4A",  btnTexto:"FFF5EE", histColor1:"6B2F4A", histColor2:"D4326B", histColor3:"F08A6F" },
    ; Naranjas / cálidos claros
    { nombre:"Melocotón",  fondo:"FFF5EC", texto:"7A2E2E", barra:"FFAB91", textoBarra:"FFFFFF", historial:"FFFAF3", panel:"FFD7BD", cooldown:"E63946", afk:"D86E3C", boton:"FFAB91", hover:"FFBFA8", logo:"7A2E2E", luzOn:"D86E3C", luzAccion:"FFAB91", luzOff:"7A2E2E",  btnTexto:"FFFFFF", histColor1:"7A2E2E", histColor2:"D86E3C", histColor3:"FFAB91" },
    { nombre:"Naranja",    fondo:"FFE7CC", texto:"7A3B00", barra:"F28C28", textoBarra:"FFFFFF", historial:"FFF2E6", panel:"FFD9AD", cooldown:"CC3333", afk:"1D5BD7", boton:"F28C28", hover:"FFAA4D", logo:"4A2100", luzOn:"7A3600", luzAccion:"994700", luzOff:"4A2100",  btnTexto:"FFFFFF", histColor1:"7A3B00", histColor2:"994700", histColor3:"CC6600" },
    { nombre:"Desierto",   fondo:"F5E6CB", texto:"4A2E0E", barra:"D2691E", textoBarra:"FFF8E1", historial:"F9F0DC", panel:"EDD5A8", cooldown:"B22222", afk:"8B4513", boton:"D2691E", hover:"E07E2A", logo:"6B3410", luzOn:"A0522D", luzAccion:"CD853F", luzOff:"6B3410",  btnTexto:"FFF8E1", histColor1:"4A2E0E", histColor2:"A0522D", histColor3:"CD853F" },
    { nombre:"Vainilla",   fondo:"FFFCF2", texto:"6B5435", barra:"F4E1A6", textoBarra:"4A3A20", historial:"FFFEF7", panel:"F8EDC8", cooldown:"D87333", afk:"B89464", boton:"F4E1A6", hover:"F8E9BD", logo:"6B5435", luzOn:"B89464", luzAccion:"D8B470", luzOff:"6B5435",  btnTexto:"4A3A20", histColor1:"6B5435", histColor2:"B89464", histColor3:"D8B470" },
    ; Nuevos claros — paletas únicas no duplicadas
    { nombre:"Miel",       fondo:"FFF8E7", texto:"6B4D10", barra:"F0C040", textoBarra:"4A3500", historial:"FFFCF0", panel:"FFEEBB", cooldown:"D04030", afk:"C08520", boton:"F0C040", hover:"F5D060", logo:"6B4D10", luzOn:"C08520", luzAccion:"F0C040", luzOff:"6B4D10",  btnTexto:"4A3500", histColor1:"6B4D10", histColor2:"C08520", histColor3:"F0C040" },
    { nombre:"Bambú",      fondo:"F5F5E8", texto:"3D4A2C", barra:"98C46A", textoBarra:"FFFFFF", historial:"F8F8F0", panel:"E8ECD8", cooldown:"D05040", afk:"6D9840", boton:"98C46A", hover:"AAD080", logo:"3D4A2C", luzOn:"6D9840", luzAccion:"98C46A", luzOff:"3D4A2C",  btnTexto:"FFFFFF", histColor1:"3D4A2C", histColor2:"6D9840", histColor3:"98C46A" },
    { nombre:"Monocromo",  fondo:"F0F0F0", texto:"1A1A1A", barra:"808080", textoBarra:"FFFFFF", historial:"F5F5F5", panel:"E0E0E0", cooldown:"404040", afk:"606060", boton:"808080", hover:"A0A0A0", logo:"1A1A1A", luzOn:"606060", luzAccion:"808080", luzOff:"1A1A1A",  btnTexto:"FFFFFF", histColor1:"1A1A1A", histColor2:"606060", histColor3:"808080" },
    { nombre:"Chicle",     fondo:"FFE0F5", texto:"4B0046", barra:"E91E63", textoBarra:"FFFFFF", historial:"FFEEF8", panel:"FFC1E0", cooldown:"00BFA5", afk:"7B1FA2", boton:"E91E63", hover:"F06292", logo:"4B0046", luzOn:"AD1457", luzAccion:"00BFA5", luzOff:"4B0046",  btnTexto:"FFFFFF", histColor1:"4B0046", histColor2:"00BFA5", histColor3:"E91E63" },
    { nombre:"Mostaza",    fondo:"FFFDE7", texto:"5D4037", barra:"D4A017", textoBarra:"2C1810", historial:"FFFEF3", panel:"FFF59D", cooldown:"BF360C", afk:"6D4C41", boton:"D4A017", hover:"E5B82C", logo:"5D4037", luzOn:"795548", luzAccion:"D4A017", luzOff:"5D4037",  btnTexto:"2C1810", histColor1:"5D4037", histColor2:"795548", histColor3:"D4A017" },
    { nombre:"Tropical",   fondo:"E0F7FA", texto:"006064", barra:"FF6F00", textoBarra:"FFFFFF", historial:"E8FAFC", panel:"B2EBF2", cooldown:"D81B60", afk:"00897B", boton:"FF6F00", hover:"FF9100", logo:"006064", luzOn:"00ACC1", luzAccion:"FF6F00", luzOff:"006064",  btnTexto:"FFFFFF", histColor1:"006064", histColor2:"FF6F00", histColor3:"00ACC1" },
    ; ─────────── OSCUROS ───────────
    ; Grises
    { nombre:"Ceniza",     fondo:"2C2C2C", texto:"BDBDBD", barra:"424242", textoBarra:"EEEEEE", historial:"242424", panel:"333333", cooldown:"EF5350", afk:"90A4AE", boton:"424242", hover:"555555", logo:"EEEEEE", luzOn:"9E9E9E", luzAccion:"BDBDBD", luzOff:"212121",  btnTexto:"EEEEEE", histColor1:"BDBDBD", histColor2:"9E9E9E", histColor3:"EEEEEE" },
    { nombre:"Grafito",    fondo:"26313D", texto:"EAF2FC", barra:"3E78B2", textoBarra:"FFFFFF", historial:"1E2730", panel:"303D4A", cooldown:"FF6B6B", afk:"73A7FF", boton:"3E78B2", hover:"5591CC", logo:"FFFFFF", luzOn:"9DD2FF", luzAccion:"C7E6FF", luzOff:"FFFFFF",  btnTexto:"FFFFFF", histColor1:"EAF2FC", histColor2:"9DD2FF", histColor3:"5591CC" },
    { nombre:"Noche",      fondo:"0D0D0D", texto:"E8E8E8", barra:"222222", textoBarra:"FFFFFF", historial:"111111", panel:"1A1A1A", cooldown:"FF5555", afk:"7EB8FF", boton:"1E1E1E", hover:"2E2E2E", logo:"FFFFFF", luzOn:"AAAAAA", luzAccion:"FFFFFF", luzOff:"333333",  btnTexto:"CCCCCC", histColor1:"E8E8E8", histColor2:"AAAAAA", histColor3:"FFFFFF" },
    ; Azules oscuros
    { nombre:"Profundo",   fondo:"020A12", texto:"4FC3F7", barra:"021825", textoBarra:"81D4FA", historial:"010609", panel:"031020", cooldown:"FF4444", afk:"00BCD4", boton:"021825", hover:"033040", logo:"4FC3F7", luzOn:"00BCD4", luzAccion:"4FC3F7", luzOff:"021825",  btnTexto:"81D4FA", histColor1:"4FC3F7", histColor2:"00BCD4", histColor3:"0288D1" },
    { nombre:"Océano",     fondo:"0A1929", texto:"9CDCEB", barra:"1B4D6B", textoBarra:"E0F7FF", historial:"050D1A", panel:"0F2438", cooldown:"FF6B6B", afk:"FFB347", boton:"1B4D6B", hover:"2C6E92", logo:"5EE5D6", luzOn:"00B4D8", luzAccion:"90E0EF", luzOff:"03455A",  btnTexto:"E0F7FF", histColor1:"9CDCEB", histColor2:"5EE5D6", histColor3:"00B4D8" },
    { nombre:"Aurora",     fondo:"060A12", texto:"80FFDB", barra:"0A1E30", textoBarra:"80FFDB", historial:"040810", panel:"0C1C28", cooldown:"FF3366", afk:"00FFCC", boton:"0A1E30", hover:"163050", logo:"80FFDB", luzOn:"00FFCC", luzAccion:"AA80FF", luzOff:"0A1E30",  btnTexto:"80FFDB", histColor1:"80FFDB", histColor2:"AA80FF", histColor3:"40C4FF" },
    ; Verdes oscuros
    { nombre:"Cyber",      fondo:"030D06", texto:"00FF88", barra:"001A0D", textoBarra:"00FF88", historial:"020B05", panel:"041208", cooldown:"FF3355", afk:"00FFCC", boton:"002211", hover:"004422", logo:"00FF88", luzOn:"00CC66", luzAccion:"00FF88", luzOff:"001A0D",  btnTexto:"00FF88", histColor1:"00FF88", histColor2:"00CC66", histColor3:"00FFCC" },
    { nombre:"Neon",       fondo:"050F03", texto:"39FF14", barra:"0A1F06", textoBarra:"39FF14", historial:"030A02", panel:"081A04", cooldown:"FF003C", afk:"CCFF00", boton:"0A1F06", hover:"133D0A", logo:"39FF14", luzOn:"39FF14", luzAccion:"CCFF00", luzOff:"0A1F06",  btnTexto:"39FF14", histColor1:"39FF14", histColor2:"CCFF00", histColor3:"00FF66" },
    { nombre:"Esmeralda",  fondo:"010F08", texto:"A8FFD0", barra:"003320", textoBarra:"C8FFE8", historial:"000A05", panel:"001A0F", cooldown:"FF4444", afk:"00FF88", boton:"002218", hover:"004430", logo:"FFD700", luzOn:"00CC66", luzAccion:"FFD700", luzOff:"010F08",  btnTexto:"C8FFE8", histColor1:"00FF88", histColor2:"FFD700", histColor3:"00CC66" },
    { nombre:"Jungla",     fondo:"0F1E0F", texto:"B4E197", barra:"1F4D2F", textoBarra:"E0FFCB", historial:"081108", panel:"152618", cooldown:"FF7043", afk:"FFB300", boton:"1F4D2F", hover:"2E6B3F", logo:"F4C430", luzOn:"4CAF50", luzAccion:"FFB300", luzOff:"0F1E0F",  btnTexto:"E0FFCB", histColor1:"B4E197", histColor2:"F4C430", histColor3:"4CAF50" },
    { nombre:"Bosque",     fondo:"1C1208", texto:"C8A96E", barra:"2D1E0A", textoBarra:"E8C97A", historial:"140E06", panel:"231508", cooldown:"FF5533", afk:"8BC34A", boton:"3B2610", hover:"5A3D18", logo:"8BC34A", luzOn:"6D9B2A", luzAccion:"C8A96E", luzOff:"1C1208",  btnTexto:"E8C97A", histColor1:"C8A96E", histColor2:"8BC34A", histColor3:"D4944A" },
    ; Marrones / cálidos oscuros
    { nombre:"Cafe",       fondo:"1A1008", texto:"DEB887", barra:"3D2010", textoBarra:"F5D5A0", historial:"120B04", panel:"251508", cooldown:"FF5533", afk:"C8963C", boton:"3D2010", hover:"5A3018", logo:"F5D5A0", luzOn:"C8963C", luzAccion:"F5D5A0", luzOff:"3D2010",  btnTexto:"F5D5A0", histColor1:"DEB887", histColor2:"C8963C", histColor3:"F5D5A0" },
    { nombre:"Dorado",     fondo:"0A0800", texto:"FFD700", barra:"1E0F00", textoBarra:"FFE55C", historial:"070500", panel:"140C00", cooldown:"FF4422", afk:"FFA500", boton:"1A0F00", hover:"2E1A00", logo:"FFD700", luzOn:"CC8800", luzAccion:"FF6600", luzOff:"0A0800",  btnTexto:"FFE55C", histColor1:"FFD700", histColor2:"FF6600", histColor3:"FFA500" },
    ; Rojos / fuego oscuros
    { nombre:"Magma",      fondo:"0E0400", texto:"FF6B35", barra:"1E0800", textoBarra:"FF9A5C", historial:"080200", panel:"180600", cooldown:"FF1744", afk:"FF6B35", boton:"1E0800", hover:"330D00", logo:"FF9A5C", luzOn:"FF4500", luzAccion:"FF6B35", luzOff:"1E0800",  btnTexto:"FF9A5C", histColor1:"FF6B35", histColor2:"FF4500", histColor3:"FF9A5C" },
    { nombre:"Sangre",     fondo:"0A0000", texto:"F5DDD0", barra:"2A0000", textoBarra:"FFD0C0", historial:"060000", panel:"160000", cooldown:"FF0000", afk:"FF6644", boton:"1A0000", hover:"3A0000", logo:"FF2222", luzOn:"CC0000", luzAccion:"FF3322", luzOff:"0A0000",  btnTexto:"FFD0C0", histColor1:"F5DDD0", histColor2:"CC0000", histColor3:"FF3322" },
    { nombre:"Abismo",     fondo:"0A0010", texto:"D8C8FF", barra:"120020", textoBarra:"E0D0FF", historial:"0D0018", panel:"140025", cooldown:"FF4477", afk:"AA88FF", boton:"1A0030", hover:"280050", logo:"C8A8FF", luzOn:"9966FF", luzAccion:"BB88FF", luzOff:"1A0030",  btnTexto:"D8C8FF", histColor1:"D8C8FF", histColor2:"9966FF", histColor3:"BB88FF" },
    { nombre:"Electrico",  fondo:"0A0A1A", texto:"E040FB", barra:"4A148C", textoBarra:"EA80FC", historial:"080812", panel:"0D0D22", cooldown:"FF1744", afk:"7B1FA2", boton:"4A148C", hover:"6A1EB0", logo:"E040FB", luzOn:"AA00FF", luzAccion:"E040FB", luzOff:"1A0030",  btnTexto:"EA80FC", histColor1:"E040FB", histColor2:"AA00FF", histColor3:"CE93D8" },
    ; Nuevos oscuros — paletas únicas no duplicadas
    { nombre:"Glitch",     fondo:"050510", texto:"00FFFF", barra:"FF00FF", textoBarra:"00FFFF", historial:"030308", panel:"0A0A18", cooldown:"FFFF00", afk:"00FFFF", boton:"1A1A2A", hover:"FF00FF", logo:"00FFFF", luzOn:"FF00FF", luzAccion:"00FFFF", luzOff:"0A0A18",  btnTexto:"00FFFF", histColor1:"00FFFF", histColor2:"FF00FF", histColor3:"FFFF00" },
    { nombre:"Tundra",     fondo:"0C1A22", texto:"AED9E0", barra:"4F8A8B", textoBarra:"E0F4F5", historial:"081218", panel:"152A35", cooldown:"FF6B6B", afk:"79EAD0", boton:"4F8A8B", hover:"6BA8A9", logo:"FBD46D", luzOn:"79EAD0", luzAccion:"FBD46D", luzOff:"0C1A22",  btnTexto:"E0F4F5", histColor1:"AED9E0", histColor2:"FBD46D", histColor3:"79EAD0" },
    { nombre:"Veneno",     fondo:"0A1208", texto:"C8FF00", barra:"2A4505", textoBarra:"E5FF7A", historial:"060A04", panel:"131F0A", cooldown:"FF1493", afk:"00FF7F", boton:"2A4505", hover:"3D6010", logo:"C8FF00", luzOn:"7FFF00", luzAccion:"C8FF00", luzOff:"0A1208",  btnTexto:"E5FF7A", histColor1:"C8FF00", histColor2:"7FFF00", histColor3:"00FF7F" },
    { nombre:"Cobre",      fondo:"180F0A", texto:"D97849", barra:"4A2818", textoBarra:"F2A878", historial:"100A08", panel:"261810", cooldown:"FFD700", afk:"B85C2E", boton:"4A2818", hover:"6B3A22", logo:"D97849", luzOn:"B85C2E", luzAccion:"FFD700", luzOff:"180F0A",  btnTexto:"F2A878", histColor1:"D97849", histColor2:"B85C2E", histColor3:"FFD700" },
    { nombre:"Vino",       fondo:"180510", texto:"E8B7CC", barra:"5D0A2A", textoBarra:"F5D5DE", historial:"100308", panel:"260818", cooldown:"FF1744", afk:"D81B60", boton:"5D0A2A", hover:"7E1040", logo:"E8B7CC", luzOn:"AD1457", luzAccion:"E8B7CC", luzOff:"180510",  btnTexto:"F5D5DE", histColor1:"E8B7CC", histColor2:"AD1457", histColor3:"5D0A2A" },
    { nombre:"Submarino",  fondo:"001A26", texto:"7DE2D1", barra:"023E5C", textoBarra:"B3F0E8", historial:"00121A", panel:"002838", cooldown:"FF6B35", afk:"FFA600", boton:"023E5C", hover:"045A82", logo:"FFA600", luzOn:"00BCD4", luzAccion:"FFA600", luzOff:"001A26",  btnTexto:"B3F0E8", histColor1:"7DE2D1", histColor2:"FFA600", histColor3:"00BCD4" },
    ; ─────────── TEMÁTICOS ───────────
    { nombre:"Discord",    fondo:"2C2F33", texto:"DCDDDE", barra:"5865F2", textoBarra:"FFFFFF", historial:"23272A", panel:"36393F", cooldown:"ED4245", afk:"57F287", boton:"40444B", hover:"5865F2", logo:"FFFFFF", luzOn:"5865F2", luzAccion:"57F287", luzOff:"2C2F33",  btnTexto:"FFFFFF", histColor1:"DCDDDE", histColor2:"5865F2", histColor3:"57F287" },
    { nombre:"Spotify",    fondo:"121212", texto:"B3B3B3", barra:"1DB954", textoBarra:"FFFFFF", historial:"0A0A0A", panel:"1A1A1A", cooldown:"FF4444", afk:"1DB954", boton:"282828", hover:"1DB954", logo:"1DB954", luzOn:"1DB954", luzAccion:"1ED760", luzOff:"181818",  btnTexto:"FFFFFF", histColor1:"B3B3B3", histColor2:"1DB954", histColor3:"1ED760" },
    { nombre:"Valorant",   fondo:"0F1923", texto:"ECE8E1", barra:"FF4655", textoBarra:"FFFFFF", historial:"0A1018", panel:"162030", cooldown:"FFFF00", afk:"BD3944", boton:"1A2A3A", hover:"FF4655", logo:"FF4655", luzOn:"FF4655", luzAccion:"ECE8E1", luzOff:"0F1923",  btnTexto:"FFFFFF", histColor1:"ECE8E1", histColor2:"FF4655", histColor3:"BD3944" },
    { nombre:"Minecraft",  fondo:"3B2A1A", texto:"7CFC00", barra:"5D8A3C", textoBarra:"FFFFFF", historial:"2E2010", panel:"4A3620", cooldown:"FF3333", afk:"55FF55", boton:"5D8A3C", hover:"6FA04A", logo:"7CFC00", luzOn:"55FF55", luzAccion:"7CFC00", luzOff:"3B2A1A",  btnTexto:"FFFFFF", histColor1:"7CFC00", histColor2:"55FF55", histColor3:"5D8A3C" },
    { nombre:"One Piece",  fondo:"0A2540", texto:"FFE066", barra:"FF8C42", textoBarra:"2C1810", historial:"071E33", panel:"103056", cooldown:"E63946", afk:"06D6A0", boton:"FF8C42", hover:"FFA866", logo:"FFE066", luzOn:"FF8C42", luzAccion:"06D6A0", luzOff:"0A2540",  btnTexto:"2C1810", histColor1:"FFE066", histColor2:"FF8C42", histColor3:"06D6A0" },
    { nombre:"Naruto",     fondo:"1A1008", texto:"FF9020", barra:"FF6600", textoBarra:"FFFFFF", historial:"120A05", panel:"281A08", cooldown:"3366FF", afk:"4488FF", boton:"FF6600", hover:"FF8830", logo:"4488FF", luzOn:"FF6600", luzAccion:"4488FF", luzOff:"1A1008",  btnTexto:"FFFFFF", histColor1:"FF9020", histColor2:"FF6600", histColor3:"4488FF" },
    { nombre:"Pokémon",    fondo:"FFFFFF", texto:"1C2B43", barra:"FF1A1A", textoBarra:"FFFFFF", historial:"F5F7FA", panel:"E8EDF5", cooldown:"FFC107", afk:"3F7CE6", boton:"FF1A1A", hover:"E60000", logo:"FFC107", luzOn:"FF1A1A", luzAccion:"FFC107", luzOff:"1C2B43",  btnTexto:"FFFFFF", histColor1:"1C2B43", histColor2:"FF1A1A", histColor3:"FFC107" },
    ; ─────────── SECRETOS — PACK GAMER ───────────
    { nombre:"★ Brawl",       secreto:true, unlock:"gamer", fondo:"000000", texto:"FFFFFF", barra:"0050D5", textoBarra:"FFFFFF", historial:"000000", panel:"0A1A30", cooldown:"FF4444", afk:"4FC3F7", boton:"0050D5", hover:"1976D2", logo:"FFFFFF", luzOn:"00B0FF", luzAccion:"FFFFFF", luzOff:"050E1C",  btnTexto:"FFFFFF", histColor1:"FFFFFF", histColor2:"00B0FF", histColor3:"0050D5" },
    { nombre:"◆ Cyberpunk",   secreto:true, unlock:"gamer", fondo:"0D0B1F", texto:"00FFFF", barra:"FF00AA", textoBarra:"FFFF00", historial:"070518", panel:"130E2E", cooldown:"FFFF00", afk:"00FFFF", boton:"FF00AA", hover:"FF33BB", logo:"FFFF00", luzOn:"FF00AA", luzAccion:"00FFFF", luzOff:"1A1240",  btnTexto:"FFFFFF", histColor1:"00FFFF", histColor2:"FF00AA", histColor3:"FFFF00" },
    { nombre:"☀ Retrowave",   secreto:true, unlock:"gamer", fondo:"1A0833", texto:"FF6EC7", barra:"7A1FA2", textoBarra:"00E5FF", historial:"0F051F", panel:"23104D", cooldown:"FF4081", afk:"FF8A50", boton:"7A1FA2", hover:"9C27B0", logo:"FF8A50", luzOn:"FF6EC7", luzAccion:"00E5FF", luzOff:"1A0833",  btnTexto:"FFFFFF", histColor1:"FF6EC7", histColor2:"00E5FF", histColor3:"FF8A50" },
    { nombre:"☆ Sky",         secreto:true, unlock:"gamer", fondo:"E1F5FE", texto:"0277BD", barra:"FFFFFF", textoBarra:"0277BD", historial:"F0FAFE", panel:"B3E5FC", cooldown:"F06292", afk:"81D4FA", boton:"FFFFFF", hover:"F5F9FB", logo:"0277BD", luzOn:"81D4FA", luzAccion:"F8BBD9", luzOff:"0277BD",  btnTexto:"0277BD", histColor1:"0277BD", histColor2:"F06292", histColor3:"81D4FA" },
    { nombre:"▣ Matrix",      secreto:true, unlock:"gamer", fondo:"000000", texto:"00FF00", barra:"002200", textoBarra:"00FF00", historial:"000800", panel:"001100", cooldown:"FF0000", afk:"00FF00", boton:"002200", hover:"003800", logo:"00FF00", luzOn:"00FF00", luzAccion:"FFFFFF", luzOff:"001100",  btnTexto:"00FF00", histColor1:"00FF00", histColor2:"00FF88", histColor3:"FFFFFF" },
    ; Morados / magenta oscuros
    ; ─────────── SECRETOS — PACK ORIGINAL ───────────
    { nombre:"✦ E C L I P S E ✦", secreto:true, unlock:"shadow",  fondo:"050508", texto:"C8A060", barra:"0D0A20", textoBarra:"FFB347", historial:"030306", panel:"0A0818", cooldown:"FF2244", afk:"00FFCC", boton:"14102A", hover:"221840", logo:"FFB347", luzOn:"FF6600", luzAccion:"FFD700", luzOff:"080520",  btnTexto:"FFB347", histColor1:"FFD700", histColor2:"FF6600", histColor3:"00FFCC" },
    { nombre:"✦ C O S M O S ✦",   secreto:true, unlock:"cosmos",  fondo:"03000F", texto:"E2C9FF", barra:"180040", textoBarra:"FFD700", historial:"020008", panel:"0D001E", cooldown:"FF1493", afk:"00E5FF", boton:"12002E", hover:"1E0050", logo:"FFD700", luzOn:"BF00FF", luzAccion:"FF69B4", luzOff:"080020",  btnTexto:"FFD700", histColor1:"FF69B4", histColor2:"BF00FF", histColor3:"00E5FF" },
    { nombre:"⚡ V O I D ⚡",      secreto:true, unlock:"void",    fondo:"000000", texto:"FFFFFF", barra:"0A0A0A", textoBarra:"FF0000", historial:"050505", panel:"0D0D0D", cooldown:"FF0000", afk:"FF0000", boton:"111111", hover:"1C1C1C", logo:"FF0000", luzOn:"FF0000", luzAccion:"FFFFFF", luzOff:"000000",  btnTexto:"FF0000", histColor1:"FFFFFF", histColor2:"FF0000", histColor3:"CC0000" },
    { nombre:"🔥 F E N I X 🔥",   secreto:true, unlock:"solar",   fondo:"FFF8EC", texto:"8B3A00", barra:"FF6B00", textoBarra:"FFFFFF", historial:"FFFBF5", panel:"FFE5C0", cooldown:"00C9B7", afk:"00C9B7", boton:"FFB347", hover:"FF8C00", logo:"00C9B7", luzOn:"00C9B7", luzAccion:"FF6B00", luzOff:"FFB347",  btnTexto:"FFFFFF", histColor1:"FFD700", histColor2:"FF6B00", histColor3:"00C9B7" },
    { nombre:"✦ N I K A ✦",       secreto:true, unlock:"blanco",  fondo:"FFFFFF", texto:"CC0000", barra:"CC0000", textoBarra:"FFFFFF", historial:"FFFFFF", panel:"FFF2F2", cooldown:"990000", afk:"CC0000", boton:"FFF2F2", hover:"FFE0E0", logo:"CC0000", luzOn:"DD0000", luzAccion:"FF2222", luzOff:"CC0000",  btnTexto:"CC0000", histColor1:"CC0000", histColor2:"DD0000", histColor3:"FF2222" },
    { nombre:"💎 P R E M I U M 💎", secreto:true, unlock:"premium", fondo:"050008", texto:"FFFFFF", barra:"0F0020", textoBarra:"FFFFFF", historial:"030005", panel:"0A0015", cooldown:"FF0066", afk:"00FFCC", boton:"15002A", hover:"25004A", logo:"FFFFFF", luzOn:"FF00FF", luzAccion:"FFD700", luzOff:"0A0015",  btnTexto:"FFFFFF", histColor1:"FF00FF", histColor2:"00FFFF", histColor3:"FFFF00" },
    ; ── GOJO: el más fuerte. Uniforme negro + pelo blanco + Limitless beige + Six Eyes azul + Hollow Purple ──
    ; Logo: ∞ (Limitless). Negro azulado del uniforme, blanco del pelo, beige del Infinito, azul cielo, morado Hollow Purple.
    { nombre:"♾ G O J O ♾", secreto:true, unlock:"gojo", logoChar:Chr(0x221E),
      fondo:"0A0E1F", texto:"E8DEC4", barra:"5B2A8C", textoBarra:"FFFFFF",
      historial:"070B18", panel:"131A30", cooldown:"D4C8A8", afk:"4FC3F7",
      boton:"1A1F35", hover:"3D1F66", logo:"FFFFFF",
      luzOn:"4FC3F7", luzAccion:"8A2BE2", luzOff:"0A0E1F",
      btnTexto:"E8DEC4", histColor1:"E8DEC4", histColor2:"4FC3F7", histColor3:"8A2BE2" },
    ; ── SUKUNA: Rey de las Maldiciones. Negro + rojos + gris rojizo + blanco hueso ──
    ; Acentos en BLANCO (los huesos visibles del Rey). Paleta de alto contraste.
    { nombre:"⛩ S U K U N A ⛩", secreto:true, unlock:"sukuna", logoChar:Chr(0x26E9),
      fondo:"0A0000", texto:"D9D5D2", barra:"2E0506", textoBarra:"D9D5D2",
      historial:"070000", panel:"3D1A1A", cooldown:"FF3030", afk:"D00000",
      boton:"3A0808", hover:"5C1010", logo:"B30000",
      luzOn:"D00000", luzAccion:"FF3030", luzOff:"2A1010",
      btnTexto:"D9D5D2", histColor1:"D9D5D2", histColor2:"FF3030", histColor3:"6E3838" },
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
pasosNormales.Push({ tipo:"pimg", nombre:"dragonpurple",		   color:0x8B52FF, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, sp:true,  lastUsed:0, x1:49, y1:271, x2:49, y2:271 })
pasosNormales.Push({ tipo:"pimg", nombre:"dragonpurple",		   color:0x8B52FF, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, tct:true,  lastUsed:0, x1:49, y1:271, x2:49, y2:271 })
pasosNormales.Push({ tipo:"pimg", nombre:"dragonyellow",		   color:0xFFFF28, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, tct:true,  lastUsed:0, x1:49, y1:271, x2:49, y2:271 })
pasosNormales.Push({ tipo:"pimg", nombre:"dragonyellow",		   color:0xFFFF28, categoria:2, hold:400, tolerancia:1, delayClick:500, delayTecla:500, cooldown:200, sp:true,  lastUsed:0, x1:49, y1:271, x2:49, y2:271 })
; ─── FASE 2: NAVEGACION ENTRE PANTALLAS (cat 3) ────────────────────
pasosNormales.Push({ tipo:"pimg", nombre:"enteringsp1",   color:0x15171A, categoria:3, hold:200, tolerancia:1, delayClick:500, delayTecla:500, cooldown:500, sp:true, lastUsed:0, x1:465, y1:471, x2:466, y2:476 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringsp2",   color:0x9EA9BB, categoria:3, hold:200, tolerancia:1, delayClick:500, delayTecla:500, cooldown:500, sp:true, lastUsed:0, x1:734, y1:427, x2:738, y2:429 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringroom1", color:0xFF89D0, categoria:3, hold:400, tolerancia:1, delayClick:30,  delayTecla:80,  cooldown:500, tct:true, lastUsed:0, x1:389, y1:566, x2:393, y2:567 })
pasosNormales.Push({ tipo:"pimg", nombre:"enteringroom2", color:0x3F7F96, categoria:3, hold:400, tolerancia:1, delayClick:30,  delayTecla:80,  cooldown:500, tct:true, lastUsed:0, x1:366, y1:549, x2:366, y2:549 })

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
pasosNormales.Push({ tipo:"pimg", nombre:"detector",      color:0xFFFCFC, categoria:4, tolerancia:1, cooldown:500, tct:true, sp:true, lastUsed:0, x1:893, y1:483, x2:1025, y2:615, colorDisparo:0xBD4140, tolDisparo:5, detectorActivo:false })
pasosNormales.Push({ tipo:"pimg", nombre:"detector",      color:0xFFFCFC, categoria:4, tolerancia:1, cooldown:500, dstv:true, lastUsed:0, x1:893, y1:483, x2:1025, y2:615, colorDisparo:0xBD4140, tolDisparo:7, detectorActivo:false })

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
global luzActiva, luzAccion, luzApagado, historialGui, historialBox, cooldownText, afkText
global tiempoInicio := 0, tiempoAcumulado := 0, timerActivo := false
global avisoMostrado := false, avisoGui := "", ultimoCambio := 0
global ultimaDeteccionReal := 0   ; A_TickCount de la ULTIMA deteccion REAL de pixel (no resets/anti-AFK)
global tiempoLanzamientoSteam := 0 ; timestamp del Run Steam, para abortar Win+typing si hay deteccion en esos 30s
global ultimoPasoEjecutado := ""
global modoDestruccion := false
global historialVisible := true, accionEnCurso := false, contadorEsc := 0
global perfilActivo := 1  ; 1=tct, 2=sp, 3=frt — los pasos sin marcar valen para tct y sp

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
global barraMini := "", miniBarraSubclassCb := 0
global overlayPartMini := "", particulasMini := [], overlayDecoMini := "", overlayDecoMiniSubCb := 0
global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros, btnPart, btnPerfil, btnMini, btnOptimizar
global hoverAccent := "", hoverAnimStep := 0, hoverAccentTop := "", hoverAccentHist := ""
global hoverAccentBot := "", hoverAccentRight := "", hoverAccentBotHist := "", hoverAccentRightHist := ""
global glowTitulo := "", sepEstado := "", sepAccion := ""  ; polish visual estático
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
global eggGojoClicks := 0, eggGojoUltimo := 0       ; 6 clicks (Six Eyes) en secuenciasLabel
global eggSukunaClicks := 0, eggSukunaUltimo := 0   ; 4 clicks (cuatro brazos) en destruccionesLabel

; ── Decoraciones tematicas (overlay topmost) ──
global overlayDecoraciones := "", overlayDecoSubclassCb := 0
global sukunaSlashFrame := 0     ; > 0 = pintando cortes Sukuna
global sukunaCortesActuales := []  ; trayectorias aleatorias del slash actual (se regeneran por secuencia)
global gojoAuraFrame := 0        ; > 0 = pintando anillo Gojo
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
global optGui := "", optGuiVisible := false

; ===== PRESETS DE RENDIMIENTO =====
global presetRendimiento := 3
global fpsContador := 0
global fpsActual := 0
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

            ; Solo bloqueamos el cache en modos VISUALMENTE incompatibles (color por
            ; pixel distinto cada frame que no se puede pre-renderizar):
            ;  - rgbLogo → color cicla con RGB cada frame
            ;  - premium → anillos arcoíris animados encima del gear
            ;  - glitching → desplazamiento + color rojo distinto cada glitch
            ;  - temaEnTransicion → colorLogoEnTransicion lerpea cada frame
            puedeCachear := !rgbLogo && !temaPremiumActivo && !glitching && !temaEnTransicion

            ; Cuando activo, ignorar el pulso de color y cachear con el color base estable.
            colorParaCache := activo ? colorLogoMacro : colorHex
            global logoGearCacheFramesReales
            canUseCache := puedeCachear && (logoGearCache.Length > 0) && (logoGearCache.Length = logoGearCacheFramesReales) && (logoGearCacheColor = colorParaCache) && (logoGearCacheChar = charLogo)

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
    global logoMacro, modoMini, logoMacroMini
    if (!IsObject(logoMacro))
        return
    hdc := DllCall("GetDC", "Ptr", logoMacro.Hwnd, "Ptr")
    if (!hdc)
        return
    PintarLogoEnDC(hdc)
    DllCall("ReleaseDC", "Ptr", logoMacro.Hwnd, "Ptr", hdc)
    ; Pintar también el logo mini si está visible
    if (modoMini && IsObject(logoMacroMini)) {
        hdcMini := DllCall("GetDC", "Ptr", logoMacroMini.Hwnd, "Ptr")
        if (hdcMini) {
            PintarLogoMiniEnDC(hdcMini)
            DllCall("ReleaseDC", "Ptr", logoMacroMini.Hwnd, "Ptr", hdcMini)
        }
    }
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
    ; Limpiar callback anterior si existía
    if (miniSubclassCb) {
        try DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", logoMacroMini.Hwnd, "Ptr", miniSubclassCb, "Ptr", 2)
        miniSubclassCb := 0
    }
    miniSubclassCb := CallbackCreate(MiniLogoSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", logoMacroMini.Hwnd, "Ptr", miniSubclassCb, "Ptr", 2, "Ptr", 0)
}

ToggleMiniMode(*) {
    global modoMini, miGui, historialGui, historialVisible, miniGui, logoMacroMini, barraMini
    global colorFondoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto, colorLogoMacro
    global overlayPartMain, overlayPartHist, miniBarraSubclassCb
    global overlayPartMini, particulasMini, overlayDecoMini

    if (modoMini) {
        ; ── Salir de mini mode ──
        modoMini := false
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
        return
    }

    ; ── Entrar en mini mode ──
    modoMini := true
    miGui.GetPos(&mx, &my)
    miGui.Hide()
    historialGui.Hide()
    if (IsObject(overlayPartMain))
        try overlayPartMain.Hide()
    if (IsObject(overlayPartHist))
        try overlayPartHist.Hide()

    CrearMiniGui(mx, my)
}

CrearMiniGui(posX, posY) {
    global miniGui, logoMacroMini, barraMini, miniBarraSubclassCb
    global colorFondoPrincipal, colorBarra, colorTextoBarra, colorLogoMacro, colorBotonNormal, colorBtnTexto
    global overlayPartMini, particulasMini, particulasActivas
    global overlayDecoMini, overlayDecoMiniSubCb, DECO_COLORKEY_HEX, DECO_COLORKEY_BGR
    static MINI_W := 120, MINI_H := 125, BAR_H := 25

    miniGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    miniGui.BackColor := colorFondoPrincipal

    ; Barra superior completa con texto "Smart" y efecto ondas
    barraMini := miniGui.Add("Text", "x0 y0 w" MINI_W " h" BAR_H " Background" colorBarra " Center +0x201", "Smart")
    barraMini.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barraMini.OnEvent("Click", ArrastrarMiniVentana)

    ; Botón restaurar — pequeño 5x5 justo debajo de la barra, arriba-derecha
    btnRestore := miniGui.Add("Text", "x" (MINI_W - 10) " y" (BAR_H + 2) " w5 h5 +0x201 Background" colorBotonNormal, "")
    btnRestore.OnEvent("Click", ToggleMiniMode)

    ; Logo giratorio — posición original centrada a la izquierda
    logoMacroMini := miniGui.Add("Text", "x15 y" (BAR_H + 5) " w80 h80 Center BackgroundTrans c" colorLogoMacro " +0x1", Chr(9881))
    logoMacroMini.SetFont("s48 c" colorLogoMacro " Bold", "Segoe UI Symbol")
    InstalarSubclassMiniLogo()

    ; Instalar subclass de ondas en la barra mini (mismo efecto que la barra principal)
    if (miniBarraSubclassCb)
        miniBarraSubclassCb := 0
    miniBarraSubclassCb := CallbackCreate(BarraSubclassProc, "F", 6)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", barraMini.Hwnd, "Ptr", miniBarraSubclassCb, "Ptr", 10, "Ptr", 0)

    miniGui.Show("x" posX " y" posY " w" MINI_W " h" MINI_H)
    RedondearVentana(miniGui.Hwnd, 14)

    ; ── Overlay de partículas para mini ──
    if (particulasActivas) {
        try WinSetStyle("+0x02000000", "ahk_id " miniGui.Hwnd)
        overlayPartMini := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
        overlayPartMini.Opt("+Owner" miniGui.Hwnd)
        overlayPartMini.Show("x" posX " y" (posY + BAR_H) " w" MINI_W " h" (MINI_H - BAR_H) " NoActivate")
        InicializarParticulas(particulasMini, MINI_W, MINI_H - BAR_H, 15)
    }

    ; ── Overlay de decoraciones (Sukuna slashes / Gojo aura) para mini ──
    overlayDecoMini := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x80020")
    overlayDecoMini.Opt("+Owner" miniGui.Hwnd)
    overlayDecoMini.BackColor := DECO_COLORKEY_HEX
    overlayDecoMini.Show("x" posX " y" (posY + BAR_H) " w" MINI_W " h" (MINI_H - BAR_H) " NoActivate")
    DllCall("SetLayeredWindowAttributes", "Ptr", overlayDecoMini.Hwnd, "UInt", DECO_COLORKEY_BGR, "UChar", 255, "UInt", 1)
    if (overlayDecoMiniSubCb)
        overlayDecoMiniSubCb := 0
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

    ; ── Partículas + decoraciones del mini mode ──
    global modoMini, miniGui, overlayPartMini, particulasMini, overlayDecoMini
    try if (modoMini && IsObject(miniGui) && IsObject(overlayPartMini)) {
        miniGui.GetPos(&mnx, &mny, &mnw, &mnh)
        overlayPartMini.GetPos(&opx, &opy, &opw, &oph)
        tgtY := mny + BAR_H
        tgtH := mnh - BAR_H
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
        PintarOverlayParticulas(overlayPartMini.Hwnd, mnw, tgtH, particulasMini)
    }
    ; Reposicionar overlay deco mini
    try if (modoMini && IsObject(miniGui) && IsObject(overlayDecoMini)) {
        miniGui.GetPos(&mnx2, &mny2, &mnw2, &mnh2)
        overlayDecoMini.GetPos(&odx, &ody, &odw, &odh)
        tgtY2 := mny2 + BAR_H
        tgtH2 := mnh2 - BAR_H
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
barraHistorial.SetFont("s11 c" colorTextoBarra " Bold", "Segoe UI")
; Combinado: primero registra el click para el egg de Nika, LUEGO arrastra
; (si arrastra antes, el drag modal de Windows bloquea el segundo handler)
barraHistorial.OnEvent("Click", (*) => (ClickBarraHistorialNika(), ArrastrarHistorial()))

; Sin WS_VSCROLL: el RichEdit no dibuja NINGUNA scrollbar nativa.
; La rueda del ratón y las flechas se gestionan via hotkeys #HotIf más abajo,
; que envían EM_LINESCROLL directamente. El scrollbar custom (scrollTrack/Thumb)
; se actualiza por ActualizarScrollbarCustom().
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
secuenciasLabel.OnEvent("Click", ClickSecuenciasGamer)  ; egg secreto del pack Gamer
secuenciasLabel.Value := Chr(0x276E) "  Secuencias: 0  " Chr(0x276F)
destruccionesLabel.Value := Chr(0x276E) "  Destrucciones: 0  " Chr(0x276F)
; egg Sukuna (4 brazos / 4 clicks) en destruccionesLabel
destruccionesLabel.OnEvent("Click", ClickDestruccionesSukuna)

; Centrado: 7 botones × 22px + 6 gaps × 4px = 178px → x46 a x224 (centro de GUI 270)
btnStatsBtn := historialGui.Add("Text", "x46 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F4CA))
btnStatsBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnStatsBtn.OnEvent("Click", MostrarEstadisticas)
btnLogros := historialGui.Add("Text", "x72 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F3C5))
btnLogros.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnLogros.OnEvent("Click", AbrirPanelLogros)
btnCodigo := historialGui.Add("Text", "x98 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9000))
btnCodigo.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Symbol")
btnCodigo.OnEvent("Click", AbrirCodigo)
btnOverlay := historialGui.Add("Text", "x124 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F441))
btnOverlay.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnOverlay.OnEvent("Click", ToggleOverlayPixeles)
btnWebhook := historialGui.Add("Text", "x150 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F514))
btnWebhook.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnWebhook.OnEvent("Click", AbrirPanelWebhook)
btnUpdate := historialGui.Add("Text", "x176 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(8593))
btnUpdate.SetFont("s8 c" colorBtnTexto, "Segoe UI Symbol")
btnUpdate.OnEvent("Click", AbrirVentanaActualizacion)
global btnOptimizar
btnOptimizar := historialGui.Add("Text", "x202 y327 w22 h20 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x2699))
btnOptimizar.SetFont("s9 c" colorBtnTexto, "Segoe UI Symbol")
btnOptimizar.OnEvent("Click", AbrirPanelOptimizacion)

; (btnPerfil ahora vive en miGui — se crea más abajo en la sección de miGui)
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

; Restaurar perfil activo guardado (1=tct, 2=sp, 3=frt, 4=dstv)
perfilActivo := Integer(IniRead(configPath, "UI", "PerfilActivo", "1"))
if (perfilActivo < 1 || perfilActivo > 4)
    perfilActivo := 1

; Cargar config de partículas
particulasActivas   := Integer(IniRead(configPath, "Particulas", "Activas",    "1")) = 1
particulasCantidad  := Integer(IniRead(configPath, "Particulas", "Cantidad",   "100"))
particulasVelocidad := Integer(IniRead(configPath, "Particulas", "Velocidad",  "100"))
particulasTamano    := Integer(IniRead(configPath, "Particulas", "Tamano",     "100"))
particulasOpacidad  := Integer(IniRead(configPath, "Particulas", "Opacidad",   "100"))

; Cargar preset de rendimiento
presetRendimiento := Integer(IniRead(configPath, "UI", "PresetRendimiento", "3"))
if (presetRendimiento < 1 || presetRendimiento > 4)
    presetRendimiento := 3

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

barra := miGui.Add("Text", "x0 y0 w400 h25 Background" colorBarra " Center", "MacroSmart V29")
barra.SetFont("s13 c" colorTextoBarra " Bold", "Segoe UI Semibold")
barra.OnEvent("Click", ArrastrarVentana)
barra.OnEvent("DoubleClick", ClickTitulo)

; Boton de perfil — pequeñito al lado izquierdo del reset.
; Click cicla 🌐 tct → 🔒 sp → ⚔ frt → 🌐 tct... F3 hace lo mismo.
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
logoMacro.SetFont("s58 c" colorLogoMacro " Bold", "Segoe UI Symbol")
logoMacro.OnEvent("Click", ClickLogo)
InstalarSubclassLogo()
texto := "AFK Smart"
tituloMacro := miGui.Add("Text", "x120 y70 w110 h20 Background" colorFondoPrincipal " c" colorTextoPrincipal, texto)
tituloMacro.SetFont("s13 Bold", "Segoe UI Semibold")

presetLabel := miGui.Add("Text", "x125 y155 w80 h14 +0x201 Background" colorFondoPrincipal " c" colorTextoPrincipal, Chr(0x26A1) " " NombrePreset(presetRendimiento))
presetLabel.SetFont("s8 c" colorTextoPrincipal, "Segoe UI Semibold")
presetLabel.OnEvent("Click", CiclarPreset)
fpsLabel := miGui.Add("Text", "x335 y155 w55 h14 +0x201 Background" colorFondoPrincipal " c" colorTextoPrincipal, "-- fps")
fpsLabel.SetFont("s8 c" colorTextoPrincipal, "Segoe UI")

luzActiva := miGui.Add("Progress", "x40 y130 w20 h20 c" colorBotonNormal " Background" colorFondoPrincipal, 100)
luzAccion := miGui.Add("Progress", "x70 y130 w20 h20 c" colorBotonNormal " Background" colorFondoPrincipal, 100)
luzApagado := miGui.Add("Progress", "x100 y130 w20 h20 c" colorLuzApagado " Background" colorFondoPrincipal, 100)
OnMessage(0x0201, ManejarClickLuces)

; Barra principal: Apariencia (Temas, RGB, Partículas) · Toggle Historial
; Posiciones originales: tema(240), RGB y part ocupan los huecos de hist y notas, hist va al hueco que dejó reset
btnTema      := miGui.Add("Text", "x240 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9680))
btnRGBBtn    := miGui.Add("Text", "x272 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x1F3A8))
btnPart      := miGui.Add("Text", "x304 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x2728))
btnHistorial := miGui.Add("Text", "x336 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(128203))
btnMini      := miGui.Add("Text", "x368 y59 w26 h26 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(0x25A3))
btnIniciar   := miGui.Add("Text", "x40 y178 w140 h36 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9654) " Iniciar (F1)")
btnParar     := miGui.Add("Text", "x220 y178 w140 h36 +0x201 Background" colorBotonNormal " c" colorBtnTexto, Chr(9632) " Parar (F2)")
; ── Polish visual: línea glow bajo título + separadores de sección ──
glowTitulo := miGui.Add("Text", "x0 y25 w400 h2 Background" AclararHex(colorBarra, 0.35), "")
sepEstado  := miGui.Add("Text", "x120 y98 w250 h1 Background" colorBarra, "")
sepAccion  := miGui.Add("Text", "x30 y170 w340 h1 Background" colorBarra, "")

; Franjas de acento para hover — 4 lados (izquierda, derecha, arriba, abajo)
hoverAccent      := miGui.Add("Text", "x-20 y-20 w5 h0 Background" colorBarra, "")
hoverAccentTop   := miGui.Add("Text", "x-20 y-20 w0 h4 Background" colorBarra, "")
hoverAccentBot   := miGui.Add("Text", "x-20 y-20 w0 h4 Background" colorBarra, "")
hoverAccentRight := miGui.Add("Text", "x-20 y-20 w5 h0 Background" colorBarra, "")

for btn in [btnTema, btnHistorial, btnReset, btnMin, btnClose]
    btn.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")
btnRGBBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
btnPart.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
for btn in [btnIniciar, btnParar]
    btn.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")

btnTema.OnEvent("Click", CambiarTema)
btnHistorial.OnEvent("Click", ToggleHistorial)
btnIniciar.OnEvent("Click", Iniciar)
btnParar.OnEvent("Click", Parar)
btnRGBBtn.OnEvent("Click", AbrirPanelRGB)
btnPart.OnEvent("Click", AbrirPanelParticulas)
btnMini.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")
btnMini.OnEvent("Click", ToggleMiniMode)

; ── Registro de hover para los botones principales ──
RegistrarHover(btnIniciar,   () => (activo ? (rgbBotones ? colorRGBActual : colorBotonHover) : (rgbBotones ? colorRGBActual : colorBotonNormal)))
RegistrarHover(btnParar,     () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnTema,      () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnHistorial, () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnCodigo,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnReset,     () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnPerfil,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnMin,       () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnClose,     () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnUpdate,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnOverlay,   () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnRGBBtn,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnStatsBtn,  () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnWebhook,   () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnLogros,    () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnOptimizar, () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnPart,      () => (rgbBotones ? colorRGBActual : colorBotonNormal))
RegistrarHover(btnMini,      () => (rgbBotones ? colorRGBActual : colorBotonNormal))

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
global hoverActual := ""
AplicarPreset(presetRendimiento)
InstalarSubclassBarras()
InstalarSubclassParticulas()
CrearOverlayDecoraciones()   ; overlay topmost para slashes Sukuna + aura Gojo
; AnimarBarras, ActualizarTrayIcon y VerificarLogros los configura AplicarPreset
; (intervalos variables segun el preset Eco/Ligero/Normal/Ultra)
EstablecerTrayIcon("888888")
ActualizarVisibilidadFrt()  ; si arrancamos en frt, ocultar labels AFK/secuencias/destruccion
SetTimer(ActualizarScrollbar, 150)
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
if (IniRead(configPath, "Watchdog", "AutoStart", "0") = "1") {
    try IniDelete(configPath, "Watchdog", "AutoStart")  ; consumir flag (single-shot)
    SetTimer(() => Iniciar(), -1500)
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
    global fpsContador
    fpsContador++

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
        ; Defensa: si info no tiene hoverFn (entradas antiguas o malformadas)
        ; usamos el fallback. Asi no se rompe el hover.
        if (info.HasProp("hoverFn") && IsObject(info.hoverFn))
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
    global rgbBotones, temaEnTransicion, optHoverBreath

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
        hoverActual.Opt("Background" c)
        DllCall("InvalidateRect", "Ptr", hoverActual.Hwnd, "Ptr", 0, "Int", 1)
    }
}

; ===== PRESETS DE RENDIMIENTO =====
NombrePreset(p) {
    switch p {
        case 1: return "Eco"
        case 2: return "Ligero"
        case 3: return "Normal"
        case 4: return "Ultra"
        default: return "Normal"
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
    switch p {
        case 1:
            ; ECO — minimo consumo de CPU posible sin romper funcionalidad
            ; Apaga TODAS las animaciones cosmeticas. La deteccion sigue funcionando igual.
            presetHoverPoll := 150       ; 1s ~ 6fps (era 50)
            presetHoverBreath := 0       ; off — el boton hover no respira
            presetParticulas := 0        ; off — sin particulas
            presetPulsoBar := 0          ; off
            presetPulsoLogo := 0         ; off
            presetRGB := 500             ; lentisimo si esta on
            presetBarras := 200          ; AnimarBarras a 5fps (gradiente shimmer casi parado)
            presetDecoraciones := false  ; sin slashes/aura Gojo/Sukuna
            presetDecoFps := 120         ; ~8fps (apenas se usa, decoraciones off)
            presetTrayIcon := 3000       ; cada 3s (era 1s)
            presetLogros := 15000        ; cada 15s (era 5s)
        case 2:
            presetHoverPoll := 32
            presetHoverBreath := 80
            presetParticulas := 100
            presetPulsoBar := 80
            presetPulsoLogo := 100
            presetRGB := 120
            presetBarras := 50
            presetDecoraciones := true
            presetDecoFps := 50          ; ~20fps
            presetTrayIcon := 1500
            presetLogros := 8000
        case 3:
            presetHoverPoll := 16
            presetHoverBreath := 40
            presetParticulas := 50
            presetPulsoBar := 40
            presetPulsoLogo := 50
            presetRGB := 60
            presetBarras := 33
            presetDecoraciones := true
            presetDecoFps := 33          ; ~30fps
            presetTrayIcon := 1000
            presetLogros := 5000
        case 4:
            presetHoverPoll := 8
            presetHoverBreath := 20
            presetParticulas := 25
            presetPulsoBar := 20
            presetPulsoLogo := 25
            presetRGB := 30
            presetBarras := 16
            presetDecoraciones := true
            presetDecoFps := 16          ; ~60fps (Ultra — Six Eyes suaves)
            presetTrayIcon := 1000
            presetLogros := 5000
    }

    SetTimer(HoverPoll, presetHoverPoll)
    SetTimer(HoverBreath, presetHoverBreath > 0 ? presetHoverBreath : 0)
    SetTimer(ActualizarParticulas, presetParticulas > 0 ? presetParticulas : 0)
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
    if (p > 4)
        p := 1
    AplicarPreset(p)
}

ActualizarFPS() {
    global fpsContador, fpsActual, fpsLabel
    fpsActual := fpsContador
    fpsContador := 0
    if (IsObject(fpsLabel))
        try fpsLabel.Text := fpsActual " fps"
}

ClickLogo(*) {
    global eggClicks, eggUltimo, eggDesbloqueado, logoMacro, colorLogoMacro
    global eggVoidDesbloqueado, eggShadowDesbloqueado, eggSolarDesbloqueado, eggBlancoDesbloqueado
    global eggPremiumDesbloqueado, eggPremiumClicks, eggPremiumUltimo
    global eggGojoClicks, eggGojoUltimo, eggGojoDesbloqueado

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
; EGG GOJO — 6 clicks rápidos (Six Eyes) en secuenciasLabel
; ═══════════════════════════════════════════════════════════════
DesbloquearGojo() {
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
    global eggGojoDesbloqueado, eggSukunaDesbloqueado
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
        if (InStr(txt, "gojo"))
            eggGojoDesbloqueado := true
        if (InStr(txt, "sukuna"))
            eggSukunaDesbloqueado := true
    }
}

GuardarEggsBackup() {
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado
    global eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggGamerDesbloqueado, eggsBackupPath
    global eggGojoDesbloqueado, eggSukunaDesbloqueado
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
    global eggGojoDesbloqueado, eggSukunaDesbloqueado
    if (!t.HasProp("secreto") || !t.secreto)
        return true
    if (!t.HasProp("unlock"))
        return false
    switch t.unlock {
        case "shadow":  return eggShadowDesbloqueado
        case "cosmos":  return eggDesbloqueado
        case "void":    return eggVoidDesbloqueado
        case "solar":   return eggSolarDesbloqueado
        case "blanco":  return eggBlancoDesbloqueado
        case "premium": return eggPremiumDesbloqueado
        case "gamer":   return eggGamerDesbloqueado
        case "gojo":    return eggGojoDesbloqueado
        case "sukuna":  return eggSukunaDesbloqueado
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
    global eggGojoDesbloqueado, eggSukunaDesbloqueado
    eggDesbloqueado        := Integer(IniRead(configPath, "Egg",        "Desbloqueado", "0")) = 1
    eggVoidDesbloqueado    := Integer(IniRead(configPath, "EggVoid",    "Desbloqueado", "0")) = 1
    eggShadowDesbloqueado  := Integer(IniRead(configPath, "EggShadow",  "Desbloqueado", "0")) = 1
    eggSolarDesbloqueado   := Integer(IniRead(configPath, "EggSolar",   "Desbloqueado", "0")) = 1
    eggBlancoDesbloqueado  := Integer(IniRead(configPath, "EggBlanco",  "Desbloqueado", "0")) = 1
    eggPremiumDesbloqueado := Integer(IniRead(configPath, "EggPremium", "Desbloqueado", "0")) = 1
    eggGamerDesbloqueado   := Integer(IniRead(configPath, "EggGamer",   "Desbloqueado", "0")) = 1
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

    ; Enviar via ComObject (asíncrono via SetTimer, no bloquea el hilo principal)
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.SetTimeouts(5000, 5000, 10000, 10000)
        whr.Open("POST", webhookURL, true)
        whr.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
        whr.Send(json)
        whr.WaitForResponse(15)
        status := whr.Status
        if (status != 204 && status != 200) {
            respText := ""
            try respText := whr.ResponseText
            AgregarHistorial("⚠ Webhook HTTP " status ": " SubStr(respText, 1, 60), "FF5555")
        }
    } catch as e {
        AgregarHistorial("⚠ Webhook error: " SubStr(e.Message, 1, 60), "FF5555")
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
                "Secuencia completada: " contadorSecuencias " (sesión)`nTotal: " secs,
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
        webhookURL := urlEdit.Value,
        webhookEnabled := cbEnable.Value,
        webhookEventos["iniciado"]   := cbInic.Value,
        webhookEventos["parado"]     := cbPar.Value,
        webhookEventos["destruccion"] := cbDest.Value,
        webhookEventos["altf4"]      := cbAlt.Value,
        webhookEventos["milestone"]  := cbMile.Value,
        webhookEventos["secuencia"]  := cbSeq.Value,
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
    optGui.Show("w" W " h" y " Center")
    RedondearVentana(optGui.Hwnd, 12)
    optGuiVisible := true
    RegistrarAutoCierre(optGui, CerrarPanelOptimizacion)
}

OptGetValor(varName) {
    global optHoverAccent, optHoverBreath, optShimmerBarra, optPulsoBarra
    global optPulsoLogo, optLogoGiratorio, optDecoraciones, optConfeti, optTypeReveal
    switch varName {
        case "optHoverAccent":   return optHoverAccent
        case "optHoverBreath":   return optHoverBreath
        case "optShimmerBarra":  return optShimmerBarra
        case "optPulsoBarra":    return optPulsoBarra
        case "optPulsoLogo":     return optPulsoLogo
        case "optLogoGiratorio": return optLogoGiratorio
        case "optDecoraciones":  return optDecoraciones
        case "optConfeti":       return optConfeti
        case "optTypeReveal":    return optTypeReveal
    }
    return false
}

OptToggleCallback(varName, ctrl, *) {
    global configPath
    global optHoverAccent, optHoverBreath, optShimmerBarra, optPulsoBarra
    global optPulsoLogo, optLogoGiratorio, optDecoraciones, optConfeti, optTypeReveal
    val := ctrl.Value = 1
    switch varName {
        case "optHoverAccent":   optHoverAccent   := val
        case "optHoverBreath":   optHoverBreath   := val
        case "optShimmerBarra":  optShimmerBarra  := val
        case "optPulsoBarra":    optPulsoBarra    := val
        case "optPulsoLogo":     optPulsoLogo     := val
        case "optLogoGiratorio": optLogoGiratorio := val
        case "optDecoraciones":  optDecoraciones  := val
        case "optConfeti":       optConfeti       := val
        case "optTypeReveal":    optTypeReveal    := val
    }
    iniKey := StrReplace(varName, "opt", "")
    IniWrite(val ? 1 : 0, configPath, "Optimizacion", iniKey)
}

OptSetTodos(val) {
    global configPath
    global optHoverAccent, optHoverBreath, optShimmerBarra, optPulsoBarra
    global optPulsoLogo, optLogoGiratorio, optDecoraciones, optConfeti, optTypeReveal
    optHoverAccent   := val
    optHoverBreath   := val
    optShimmerBarra  := val
    optPulsoBarra    := val
    optPulsoLogo     := val
    optLogoGiratorio := val
    optDecoraciones  := val
    optConfeti       := val
    optTypeReveal    := val
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
}

OptTodoOn(*) {
    OptSetTodos(true)
    try {
        CerrarPanelOptimizacion()
        AbrirPanelOptimizacion()
    }
}

OptTodoOff(*) {
    OptSetTodos(false)
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
    popup.Add("Text", "x10 y40 w320 h20 Center cFF00AA", "★ ─ ◆ ─ ☀ ─ ⚔ ─ ☆ ─ ▣")
    popup.Add("Text", "x10 y64 w320 h22 Center c00FFFF", "Has desbloqueado el PACK GAMER")
    popup.Add("Text", "x10 y90 w320 h20 Center cFFFF00", "6 temas nuevos en el selector")
    popup.Add("Text", "x10 y112 w320 h20 Center cFF00AA", "★ ─ ◆ ─ ☀ ─ ⚔ ─ ☆ ─ ▣")
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

InstalarSubclassTemaCard(btn, entry, esActivo) {
    global temaCardData, temaCardCbs
    temaCardData[btn.Hwnd] := {
        tema: entry.tema,
        nombre: entry.nombre,
        esActivo: esActivo,
        hovered: false
    }
    cb := CallbackCreate(TemaCardSubclassProc, "F", 6)
    temaCardCbs.Push(cb)
    DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", btn.Hwnd, "Ptr", cb, "Ptr", 14, "Ptr", 0)
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
; - Duracion fija 400ms con easing cubic in/out.
; - Todos los colores interpolan en paralelo, todos los controles repintan en el mismo frame.

global temaTransInicio := 0
global TRANSICION_MS   := 1200    ; duracion total transicion (ms)
; WS_EX_COMPOSITED (0x02000000) hace double-buffering automatico a nivel OS:
; todos los hijos pintan a un buffer comun y se presentan como UN frame.
; Lo activamos solo durante la transicion para evitar overhead en steady state.
global WS_EX_COMPOSITED := 0x02000000

TransicionTema(tema, guardar := true) {
    global temaTransInicio, temaTransTema, temaTransGuardar, temaEnTransicion
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
    temaTransInicio  := A_TickCount
    temaTransTema    := tema
    temaTransGuardar := guardar

    ; Activar double-buffering OS-level durante la transicion: garantiza que TODOS
    ; los hijos (fondo + labels + luces + barra + logo) aparezcan en el MISMO frame.
    try miGui.Opt("+E" WS_EX_COMPOSITED)
    try historialGui.Opt("+E" WS_EX_COMPOSITED)

    SetTimer(TransicionPaso, 33)  ; ~30fps, suficiente para 1.2s = 36 frames
}

TransicionPaso() {
    global temaTransInicio, temaTransTema, temaTransGuardar, temaEnTransicion
    global temaTransOrigen, miGui, historialGui, TRANSICION_MS
    global barra, barraHistorial, colorBarraOverride
    global tituloMacro, timerLabel, cooldownText, afkText, secuenciasLabel, destruccionesLabel, contadorLabel, logoMacro
    global presetLabel, fpsLabel
    global btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose
    global btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros, btnPart, btnPerfil
    global colorLogoEnTransicion, colorFondoEnTransicion, colorTextoBarra
    global luzActiva, luzAccion, luzApagado, historialBox, separadorHistorial
    global scrollTrack, scrollThumb
    global glowTitulo, sepEstado, sepAccion, activo

    static WM_SETREDRAW := 0x000B
    static RDW_FLAGS    := 0x0001 | 0x0004 | 0x0080 | 0x0100   ; INVALIDATE | ERASE | ALLCHILDREN | UPDATENOW

    ; t basado en tiempo real (asi frames perdidos no rompen la animacion)
    elapsed := A_TickCount - temaTransInicio
    t  := Min(elapsed / TRANSICION_MS, 1.0)
    ; Easing cubic in/out — empieza/termina suave, acelera en medio
    t2 := t < 0.5 ? 4*t*t*t : 1 - (-2*t+2)**3/2

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
    DllCall("SendMessageW", "Ptr", miGui.Hwnd,        "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)
    DllCall("SendMessageW", "Ptr", historialGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 0, "Ptr", 0)

    ; ── PASO 2: aplicar TODOS los cambios via Opt() / BackColor (sin pintar) ──
    try miGui.BackColor       := cFondo
    try historialGui.BackColor := cFondo

    ; Fondo del RichEdit del historial (EM_SETBKGNDCOLOR)
    if (IsObject(historialBox)) {
        DllCall("SendMessageW", "Ptr", historialBox.Hwnd, "UInt", 0x0443, "Ptr", 0, "Ptr", HexToBGR(cFondoHist))
    }

    ; Botones — fondo + texto
    for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros, btnPart, btnMini, btnOptimizar] {
        if (IsObject(btn))
            btn.Opt("Background" cBoton " c" cBtnTexto)
    }
    if (IsObject(btnPerfil))
        btnPerfil.Opt("Background" cBoton " c" cBtnTexto)

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

    ; Luces — fondo + color de fill segun estado activo
    if (activo) {
        if (IsObject(luzActiva)) {
            luzActiva.Opt("Background" cFondo " c" cLuzOn)
        }
        if (IsObject(luzAccion)) {
            luzAccion.Opt("Background" cFondo " c" cBoton)
        }
        if (IsObject(luzApagado)) {
            luzApagado.Opt("Background" cFondo " c" cBoton)
        }
    } else {
        if (IsObject(luzActiva)) {
            luzActiva.Opt("Background" cFondo " c" cBoton)
        }
        if (IsObject(luzAccion)) {
            luzAccion.Opt("Background" cFondo " c" cBoton)
        }
        if (IsObject(luzApagado)) {
            luzApagado.Opt("Background" cFondo " c" cLuzOff)
        }
    }

    ; Separadores + polish visual (no parpadea porque va dentro del WM_SETREDRAW)
    if (IsObject(separadorHistorial)) {
        separadorHistorial.Opt("Background" cBarra)
    }
    if (IsObject(glowTitulo)) {
        glowTitulo.Opt("Background" AclararHex(cBarra, 0.35))
    }
    if (IsObject(sepEstado)) {
        sepEstado.Opt("Background" cBarra)
    }
    if (IsObject(sepAccion)) {
        sepAccion.Opt("Background" cBarra)
    }

    ; Scrollbar personalizado
    if (IsObject(scrollTrack)) {
        scrollTrack.Opt("Background" cBoton)
    }
    if (IsObject(scrollThumb)) {
        scrollThumb.Opt("Background" cHover)
    }

    ; ── PASO 3: re-habilitar repaints ──
    DllCall("SendMessageW", "Ptr", miGui.Hwnd,        "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)
    DllCall("SendMessageW", "Ptr", historialGui.Hwnd, "UInt", WM_SETREDRAW, "Ptr", 1, "Ptr", 0)

    ; ── PASO 4: UN solo repaint sincronico de TODO (ventana + hijos) ──
    DllCall("RedrawWindow", "Ptr", miGui.Hwnd,        "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)
    DllCall("RedrawWindow", "Ptr", historialGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", RDW_FLAGS)

    if (t >= 1.0) {
        colorBarraOverride := ""
        AplicarTema(temaTransTema, temaTransGuardar, true)
        SetTimer(TransicionPaso, 0)
        temaEnTransicion := false
        ; Desactivar el double-buffering (causa overhead y puede afectar
        ; subclasseados controles si se deja activo permanente).
        try miGui.Opt("-E" WS_EX_COMPOSITED)
        try historialGui.Opt("-E" WS_EX_COMPOSITED)
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
    ; Polish visual: glow bajo el título + separadores de sección
    if (IsObject(glowTitulo))
        glowTitulo.Opt("Background" AclararHex(colorBarra, 0.35))
    if (IsObject(sepEstado))
        sepEstado.Opt("Background" colorBarra)
    if (IsObject(sepAccion))
        sepAccion.Opt("Background" colorBarra)
    logoMacro.Opt("c" colorLogoMacro)
    logoMacro.SetFont("s49 c" colorLogoMacro " Bold", "Segoe UI Symbol")
    ; Cambiar el carácter del logo si el tema define uno especial (Gojo=∞, Sukuna=⛩)
    try logoMacro.Text := (tema.HasProp("logoChar") ? tema.logoChar : Chr(9881))
    DllCall("InvalidateRect", "Ptr", logoMacro.Hwnd, "Ptr", 0, "Int", 1)
    tituloMacro.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    tituloMacro.SetFont("s13 c" colorTextoPrincipal " Bold", "Segoe UI Semibold")
    timerLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
    timerLabel.SetFont("s13 c" colorTextoPrincipal " Bold", "Segoe UI Semibold")
    if (IsObject(presetLabel)) {
        presetLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
        presetLabel.SetFont("s8 c" colorTextoPrincipal, "Segoe UI Semibold")
    }
    if (IsObject(fpsLabel)) {
        fpsLabel.Opt("Background" colorFondoPrincipal " c" colorTextoPrincipal)
        fpsLabel.SetFont("s8 c" colorTextoPrincipal, "Segoe UI")
    }
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
    for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros, btnPart, btnMini, btnOptimizar] {
        btn.Opt("Background" colorBotonNormal " c" colorBtnTexto)
        btn.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Symbol")
        if (!fromTrans) {
            DllCall("InvalidateRect", "Ptr", btn.Hwnd, "Ptr", 0, "Int", 1)
            DllCall("UpdateWindow",   "Ptr", btn.Hwnd)
        }
    }
    ; btnPerfil ahora es boton visible con emoji → colores normales de boton
    btnPerfil.Opt("Background" colorBotonNormal " c" colorBtnTexto)
    if (!fromTrans) {
        DllCall("InvalidateRect", "Ptr", btnPerfil.Hwnd, "Ptr", 0, "Int", 1)
        DllCall("UpdateWindow",   "Ptr", btnPerfil.Hwnd)
    }
    for btn in [btnIniciar, btnParar]
        btn.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Semibold")
    btnUpdate.SetFont("s8 c" colorBtnTexto, "Segoe UI Symbol")
    btnOptimizar.SetFont("s9 c" colorBtnTexto, "Segoe UI Symbol")
    btnOverlay.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnRGBBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnStatsBtn.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnWebhook.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnLogros.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnPart.SetFont("s9 c" colorBtnTexto, "Segoe UI Emoji")
    btnCodigo.SetFont("s10 c" colorBtnTexto " Bold", "Segoe UI Symbol")
    btnPerfil.SetFont("s11 c" colorBtnTexto " Bold", "Segoe UI Emoji")
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

        for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros, btnPart, btnPerfil, btnMini, btnOptimizar]
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
        global glowTitulo, sepEstado, sepAccion
        if (IsObject(glowTitulo)) {
            glowTitulo.Opt("Background" AclararHex(colorRGBActual, 0.35))
            DllCall("InvalidateRect", "Ptr", glowTitulo.Hwnd, "Ptr", 0, "Int", 1)
        }
        if (IsObject(sepEstado)) {
            sepEstado.Opt("Background" colorRGBActual)
            DllCall("InvalidateRect", "Ptr", sepEstado.Hwnd, "Ptr", 0, "Int", 1)
        }
        if (IsObject(sepAccion)) {
            sepAccion.Opt("Background" colorRGBActual)
            DllCall("InvalidateRect", "Ptr", sepAccion.Hwnd, "Ptr", 0, "Int", 1)
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
        for btn in [btnIniciar, btnParar, btnCodigo, btnReset, btnHistorial, btnTema, btnMin, btnClose, btnUpdate, btnOverlay, btnRGBBtn, btnStatsBtn, btnWebhook, btnLogros, btnPart, btnPerfil, btnMini, btnOptimizar]
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
    global miGui, historialGui, overlayPartMain, overlayPartHist, heartbeatPath, miniGui, modoMini
    global perfilActivo, configPath, historialVisible
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
    return Chr(0x2205)        ; ∅ dstv (vacio, no hace nada)
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
    return Chr(0x2205) " dstv"          ; ∅ dstv (vacio - sin pasos ni acciones)
}

; Cicla 1 → 2 → 3 → 4 → 1 → ...
CambiarPerfil(*) {
    global perfilActivo, btnPerfil, configPath, brawlhallaLanzado
    perfilActivo := (perfilActivo >= 4) ? 1 : perfilActivo + 1
    btnPerfil.Value := EmojiPerfil()
    DllCall("InvalidateRect", "Ptr", btnPerfil.Hwnd, "Ptr", 0, "Int", 1)
    DllCall("UpdateWindow",   "Ptr", btnPerfil.Hwnd)
    IniWrite(perfilActivo, configPath, "UI", "PerfilActivo")
    AgregarHistorial("Perfil activo: " NombrePerfil(), "")
    ; Resetea la flag para que al pulsar Iniciar en el nuevo perfil se lance SU juego
    brawlhallaLanzado := false
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
            ; Dibujar decoración según tema activo + estado de animación
            PintarDecoracionesEnHDC(hdc, w, h)
            DllCall("EndPaint", "Ptr", hWnd, "Ptr", ps)
        }
        return 0
    }
    return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

PintarDecoracionesEnHDC(hdc, w, h) {
    global temas, temaActual, sukunaSlashFrame, gojoAuraFrame
    if (!temas[temaActual].HasProp("unlock"))
        return
    unlock := temas[temaActual].unlock

    ; ── DECORACIONES PERMANENTES (cada frame mientras el tema esté activo) ──
    if (unlock = "sukuna") {
        PintarNombreSukuna(hdc, w, h)        ; 両面宿儺 vertical bien colocado
        ; (Sin anillo — el usuario lo prefiere así, el logo respira solo)
    } else if (unlock = "gojo") {
        PintarSixEyesGojo(hdc, w, h)         ; 6 ojos cyan orbitando el logo
        PintarAnilloGojo(hdc, w, h)          ; anillo azul permanente
    }

    ; ── ANIMACIONES PUNTUALES (al detectar) ──
    if (unlock = "sukuna" && sukunaSlashFrame > 0) {
        PintarSlashSukunaEnHDC(hdc, w, h, sukunaSlashFrame)
    } else if (unlock = "gojo" && gojoAuraFrame > 0) {
        PintarAuraGojoEnHDC(hdc, w, h, gojoAuraFrame, 14)
    }
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
PintarSixEyesGojo(hdc, w, h) {
    ; Fase basada en TIEMPO REAL (no en nº de frames) → la velocidad de órbita
    ; es idéntica a 12fps o a 60fps, solo cambia la suavidad. ~0.45 rad/s.
    fase := Mod(A_TickCount / 1000.0 * 0.45, 6.2831853)

    cx := 66.0          ; centro X del logo en miGui
    cy := 53.0          ; centro Y del logo (78 - 25 barra)
    radioOrbit := 52.0  ; radio de la órbita

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
PintarAnilloGojo(hdc, w, h) {
    ; Fase basada en tiempo real → independiente del framerate. ~0.7 rad/s.
    fase := Mod(A_TickCount / 1000.0 * 0.7, 6.2831853)

    cx := 66.0
    cy := 53.0
    ; Tres anillos concentricos con fases desfasadas → efecto de ondas
    g := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &g)
    if (!g)
        return
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", g, "Int", 4)

    Loop 3 {
        i := A_Index - 1
        ondaFase := fase + i * 2.0944  ; 120° desfase
        radio := 38.0 + 4.0 * Sin(ondaFase)
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

PintarAuraGojoEnHDC(hdc, w, h, frame, maxFrame) {
    ; ANIMACION HOLLOW PURPLE de Gojo. La técnica más icónica.
    ; Aka (rojo, atracción) + Aoi (azul, repulsión) chocan → Murasaki (morado).
    ;
    ; Fases (frame va de maxFrame=14 → 0):
    ;   Fase 1 (14-11): aparecen Aka y Aoi en lados opuestos del logo
    ;   Fase 2 (10-7):  Aka y Aoi se acercan al centro
    ;   Fase 3 (6-5):   colisionan en el centro → flash blanco
    ;   Fase 4 (4-0):   onda Hollow Purple expande hacia afuera
    cx := 66           ; centro del logo (en miGui)
    cy := 78 - 25      ; -25 por offset de la overlay (debajo de la barra)
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
    global sukunaCortesActuales, overlayDecoraciones
    ; Dimensiones del overlay (cae a 400x215 si aún no existe)
    w := 400.0, h := 215.0
    if (IsObject(overlayDecoraciones)) {
        try {
            overlayDecoraciones.GetPos(,, &ow, &oh)
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
    global overlayDecoraciones
    if (!presetDecoraciones || !optDecoraciones)
        return
    if (!IsObject(overlayDecoraciones))
        return
    if (!temas[temaActual].HasProp("unlock"))
        return
    unlock := temas[temaActual].unlock
    if (unlock != "gojo" && unlock != "sukuna")
        return
    ; Asegurar que el overlay esté posicionado (puede haberse movido el GUI)
    ReposicionarOverlayDeco()
    DllCall("InvalidateRect", "Ptr", overlayDecoraciones.Hwnd, "Ptr", 0, "Int", 1)
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
        if !PasoActivoEnPerfil(paso)
            continue
        if paso.HasProp("cooldown") {
            restante := paso.cooldown - (A_TickCount - paso.lastUsed)
            if (restante > 0)
                textoCooldown .= "[P] " paso.nombre ": " Round(restante / 1000, 1) "s`n"
        }
    }

    for paso in pasosNormales {
        if !paso.HasProp("lastUsed")
            paso.lastUsed := 0
        if !PasoActivoEnPerfil(paso)
            continue
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
    global timerLabel, colorTextoPrincipal, afkAlertaFlash, perfilActivo
    ; En modo frt y dstv no hay anti-AFK ni modo destruccion
    if (perfilActivo = 3 || perfilActivo = 4)
        return
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
                                if (paso.nombre = "LEAVINGGAME..." && paso.cooldown = 190000) {
                                    contadorSecuencias += 1
                                    ActualizarSecuencias()
                                    AgregarHistorial(paso.nombre " -> COOLDOWN " Round(paso.cooldown/1000) "s | Secuencias: " contadorSecuencias, paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                                    EnviarWebhookEvento("secuencia")
                                    DespuesDeAccion(true)
                                    ; ── Efecto único de SUKUNA: Fuga (flame arrow) en la barra al completar secuencia ──
                                    if (temas[temaActual].HasProp("unlock") && temas[temaActual].unlock = "sukuna")
                                        SetTimer(BarraFlashFuga, -1)
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
    global tiempoUltimoLanzamiento
    global ultimoAfkMove, ultimaDeteccionReal, perfilActivo
    static PASOS_ENTRE_PRIO := 5   ; CheckPrioridad cada N pasos normales revisados

    ; Proof-of-life para el watchdog ANTES de cualquier return.
    ; Si el timer está corriendo, el macro está vivo — punto. Esto debe estar arriba
    ; del guard porque si accionEnCurso o BloqueoGlobalActivo nos hacen salir
    ; temprano, el ultimoAfkMove tampoco se actualizaba → watchdog Reload() falso.
    ultimoAfkMove := A_TickCount

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

        ; ── Detector: vigila pixel blanco 1x2 → Space cuando aparece rojo o desaparece blanco ──
        if paso.HasProp("colorDisparo") {
            if (encontrado) {
                ; Verificar bloque 1x2: pixel encontrado + el de abajo (y+1)
                confirmado := false
                try {
                    c2 := PixelGetColor(x, y + 1)
                    cVal := Integer(c2)
                    bR := (paso.color >> 16) & 0xFF
                    bG := (paso.color >> 8) & 0xFF
                    bB := paso.color & 0xFF
                    tol := paso.tolerancia
                    pR := (cVal >> 16) & 0xFF
                    pG := (cVal >> 8) & 0xFF
                    pB := cVal & 0xFF
                    if (Abs(pR - bR) <= tol && Abs(pG - bG) <= tol && Abs(pB - bB) <= tol)
                        confirmado := true
                }
                if (!confirmado) {
                    accionEnCurso := false
                    continue
                }
                ; 1x2 confirmado — NO mover cursor, solo vigilar
                paso.detectorActivo := true
                tmpPaso := {x1: paso.x1, y1: paso.y1, x2: paso.x2, y2: paso.y2, color: paso.colorDisparo, tolerancia: paso.HasProp("tolDisparo") ? paso.tolDisparo : 5}
                if BuscarPixel(tmpPaso, &xd, &yd) {
                    SendInput "{Space}"
                    paso.lastUsed := A_TickCount
                    paso.detectorActivo := false
                    ultimaDeteccionReal := A_TickCount
                    ultimoCambio := A_TickCount
                    AgregarHistorial(paso.nombre " → Space (rojo)", paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                    LuzAccionFlash()
                    OndaBarra()
                    DespuesDeAccion(false)
                }
                accionEnCurso := false
                return
            } else if (paso.HasProp("detectorActivo") && paso.detectorActivo) {
                SendInput "{Space}"
                paso.lastUsed := A_TickCount
                paso.detectorActivo := false
                ultimaDeteccionReal := A_TickCount
                ultimoCambio := A_TickCount
                AgregarHistorial(paso.nombre " → Space (desaparecio)", paso.HasProp("categoria") ? ObtenerColorCategoria(paso.categoria) : "")
                LuzAccionFlash()
                OndaBarra()
                DespuesDeAccion(false)
                accionEnCurso := false
                return
            }
            continue
        }

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

    ; dstv: sin anti-AFK, sin modo destrucción, sin MouseMove — solo detector
    if (perfilActivo = 4)
        return

    tiempoSinCambios := A_TickCount - ultimoCambio

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

    if (activo && tiempoUltimoLanzamiento > 0 && (A_TickCount - tiempoUltimoLanzamiento) > 60000) {
        tiempoUltimoLanzamiento := A_TickCount
        ultimoCambio := A_TickCount
        AgregarHistorial("⚠️ Sin detección tras 2 min - relanzando secuencia Steam + Win + 'brawlhalla'", "FF8800")
        LanzarBrawlhallaConFoco()
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
        { id: "godmode",      nombre: "God Mode",             desc: "Desbloquea TODOS los temas",       icono: Chr(0x1F451), desbloqueado: false },
        ; ── Logros por desbloqueo de tema secreto (con pista) ───────────
        { id: "themeShadow",  nombre: "Eclipse del tiempo",    desc: "??? (el ⏱ timer responde si insistes)",                       icono: Chr(0x2728), desbloqueado: false },
        { id: "themeCosmos",  nombre: "Viajero estelar",       desc: "??? (gira y gira )",                            icono: Chr(0x2728), desbloqueado: false },
        { id: "themeVoid",    nombre: "Abrazo del vacío",      desc: "??? (Tal vez algo AFK )",                icono: Chr(0x26A1), desbloqueado: false },
        { id: "themeSolar",   nombre: "Renacer de las cenizas",desc: "??? (las 3 luces tienen un orden secreto: izq → centro → der)", icono: Chr(0x1F525), desbloqueado: false },
        { id: "themeBlanco",  nombre: "Pureza absoluta",       desc: "??? (el historial guarda un secreto AFK)",              icono: Chr(0x2728), desbloqueado: false },
        { id: "themePremium", nombre: "El elegido",            desc: "??? (consigue TODOS los demás secretos primero)",             icono: Chr(0x1F48E), desbloqueado: false },
        { id: "gamerpack",    nombre: "Pack Gamer",            desc: "??? (Las SECUENCIAS son el camino)",     icono: Chr(0x1F3AE), desbloqueado: false },
        ; ── Logros de cifra ──────────────────────────────────────────
        { id: "kiko",         nombre: "kiko",                  desc: "Llega a 67 secuencias",            icono: Chr(0x1F60E), desbloqueado: false },
        { id: "jbs",          nombre: "JBS",                   desc: "Llega a 5000 secuencias",          icono: Chr(0x1F3C6), desbloqueado: false }
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
    global eggDesbloqueado, eggVoidDesbloqueado, eggShadowDesbloqueado, eggSolarDesbloqueado, eggBlancoDesbloqueado, eggPremiumDesbloqueado, eggGamerDesbloqueado

    totalSecs := totalSecuenciasGuardadas + contadorSecuencias
    totalDestru := totalDestruccionGuardada + contadorDestruccion
    sesionHoras := tiempoAcumulado / 3600000.0
    if (timerActivo)
        sesionHoras += (A_TickCount - tiempoInicio) / 3600000.0
    eggsCount := (eggDesbloqueado ? 1 : 0) + (eggVoidDesbloqueado ? 1 : 0) + (eggShadowDesbloqueado ? 1 : 0)
                 + (eggSolarDesbloqueado ? 1 : 0) + (eggBlancoDesbloqueado ? 1 : 0) + (eggPremiumDesbloqueado ? 1 : 0)
                 + (eggGamerDesbloqueado ? 1 : 0)
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
        "godmode",       eggsCount >= 7,
        "gamerpack",     eggGamerDesbloqueado,
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
    global logros, logrosGui, logrosGuiVisible
    global colorFondoPrincipal, colorTextoPrincipal, colorBarra, colorTextoBarra, colorBotonNormal, colorBtnTexto

    if (logrosGuiVisible && IsObject(logrosGui)) {
        try LimpiarHoverGui(logrosGui)
        try logrosGui.Destroy()
        logrosGuiVisible := false
        return
    }

    ; Layout 3 columnas compacto — panel mucho más pequeño que el 2-col anterior
    cols    := 3
    cellW   := 158
    cellH   := 40
    gap     := 5
    padding := 10
    W := padding * 2 + cols * cellW + (cols - 1) * gap
    filas := Ceil(logros.Length / cols)
    H := 30 + padding + filas * (cellH + gap) - gap + padding

    logrosGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    logrosGui.BackColor := colorFondoPrincipal

    desbloqueadosCount := 0
    for l in logros
        if (l.desbloqueado)
            desbloqueadosCount += 1

    barr := logrosGui.Add("Text", "x0 y0 w" W " h30 Background" colorBarra " Center +0x200", Chr(0x1F3C5) "  Logros  " Chr(0x2022) "  " desbloqueadosCount "/" logros.Length)
    barr.SetFont("s10 c" colorTextoBarra " Bold", "Segoe UI Semibold")
    barr.OnEvent("Click", (*) => (LimpiarHoverGui(logrosGui), logrosGui.Destroy(), logrosGuiVisible := false))

    ; Layout en grid 3×N compacto
    startY := 30 + padding
    for i, l in logros {
        col := Mod(i - 1, cols)
        row := (i - 1) // cols
        cx := padding + col * (cellW + gap)
        cy := startY + row * (cellH + gap)

        if (l.desbloqueado) {
            cBg := colorBotonNormal
            cFg := colorBtnTexto
            iconC := "FFD700"
        } else {
            cBg := "2A2A2A"
            cFg := "888888"
            iconC := "666666"
        }
        ; Fondo de la celda (un solo Text como contenedor del color)
        cell := logrosGui.Add("Text", "x" cx " y" cy " w" cellW " h" cellH " Background" cBg, "")
        ; Icono a la izquierda
        lblIcon := logrosGui.Add("Text", "x" (cx + 5) " y" (cy + 5) " w24 h" (cellH - 10) " Center Background" cBg " c" iconC, l.icono)
        lblIcon.SetFont("s13", "Segoe UI Emoji")
        ; Nombre
        lblName := logrosGui.Add("Text", "x" (cx + 33) " y" (cy + 4) " w" (cellW - 38) " h14 Background" cBg " c" cFg, l.nombre)
        lblName.SetFont("s8 Bold", "Segoe UI Semibold")
        ; Descripción
        lblDesc := logrosGui.Add("Text", "x" (cx + 33) " y" (cy + 20) " w" (cellW - 38) " h18 Background" cBg " c" cFg, l.desc)
        lblDesc.SetFont("s6 Italic", "Segoe UI")
    }

    logrosGui.Show("w" W " h" H " Center")
    try RedondearVentana(logrosGui.Hwnd, 14)
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
    global colorFondoHistorial, optTypeReveal
    static EM_GETSCROLLPOS := 0x04DD, EM_SETSCROLLPOS := 0x04DE
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
    ocultar := (perfilActivo = 3 || perfilActivo = 4)
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
}

CheckBrawlhallaMinimizado() {
    global activo, perfilActivo
    ; frt (3) y dstv (4) no manejan Brawlhalla
    if (!activo || perfilActivo = 3 || perfilActivo = 4)
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

; Alias retrocompatible
LanzarBrawlhalla() => LanzarJuegoDelPerfil()

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

    ; dstv (perfil 4) = solo detector, sin AFK ni Brawlhalla
    if (perfilActivo = 4) {
        SetTimer(EjecutarMacro, 50)
        SetTimer(ActualizarCooldowns, 100)
        IniciarTimer()
        EscribirHeartbeat()   ; capturar activo=1 al instante (no esperar 5s)
        EnviarWebhookEvento("iniciado")
        return
    }

    ; Lanzar Brawlhalla AHORA, antes de los timers que envían teclas (Esc/c)
    ; — si EjecutarMacro corre durante el Win+brawlhalla puede mandar Esc y cerrar el menú
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
    global overlayPixeles, pasosPrioridad, pasosNormales, scaleX, scaleY

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
        x1s := Round(paso.x1 * scaleX)
        y1s := Round(paso.y1 * scaleY)
        x2s := Round(paso.x2 * scaleX)
        y2s := Round(paso.y2 * scaleY)
        colorPaso := paso.HasProp("color") ? paso.color : 0xFF00FF
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

^w::AbrirPanelWebhook()
F1::Iniciar()
F2::Parar()
F3::CambiarPerfil()  ; Toggle perfil P1/P2 (zona de click invisible esta en esquina inf-izq)
^r::AbrirPanelRGB()
!h::MostrarEstadisticas()

; ═════ SCROLL DEL HISTORIAL POR TECLADO Y RUEDA ═════
; Activos cuando el ratón está sobre la ventana del historial.
#HotIf RatonSobreHistorial()
WheelUp::ScrollHistorial(-3)
WheelDown::ScrollHistorial(3)
PgUp::ScrollHistorial(-5)
PgDn::ScrollHistorial(5)
Up::ScrollHistorial(-1)
Down::ScrollHistorial(1)
Home::ScrollHistorial(-9999)
End::ScrollHistorial(9999)
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
    global historialBox
    if (!IsObject(historialBox))
        return
    static EM_LINESCROLL := 0x00B6
    try {
        SendMessage(EM_LINESCROLL, 0, lineas, , "ahk_id " historialBox.Hwnd)
        ActualizarScrollbar()  ; refresca el thumb custom inmediatamente
    }
}

