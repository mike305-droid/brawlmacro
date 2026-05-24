# Genera 45 PNG individuales (uno por tema) en mockups_png/
# Cada PNG: 1740x800 px (2x supersampling, despues downscale a 870x400 para crispness)
# Cada PNG = mockup del macro + paleta de colores al lado
# Listos para subir a Canva como imagenes y armar el showcase.

import os, re
from PIL import Image, ImageDraw, ImageFont

# ============ TEMAS ============
TEMAS = [
    ("Hielo",      "E8F4FD","1A5276","85C1E9","FFFFFF","F0F9FF","D6EAF8","E74C3C","2980B9","85C1E9","AED6F1","1A5276","2471A3","2E86C1","1A5276","FFFFFF"),
    ("Polar",      "F0F8FF","0B2545","8ECAE6","0B2545","F8FCFF","D1E5F2","E63946","219EBC","8ECAE6","ADD8E6","0B2545","219EBC","95D5B2","5E8AAE","0B2545"),
    ("Agua",       "D8F3F0","064C55","2E9E9A","FFFFFF","ECFBF8","C7EDE8","D94848","1769AA","2E9E9A","4DB9B5","003C42","004A47","00635F","003236","FFFFFF"),
    ("Menta",      "FAF8F2","2C4A3E","A8E6CF","1B3A2E","FEFDF8","D4F1E0","E07A5F","81B29A","A8E6CF","BBEFD9","2C4A3E","81B29A","A8E6CF","2C4A3E","1B3A2E"),
    ("Verde",      "F0FFF4","1B5E20","66BB6A","FFFFFF","E8F5E9","C8E6C9","E53935","2E7D32","66BB6A","81C784","1B5E20","388E3C","66BB6A","1B5E20","FFFFFF"),
    ("Macaron",    "FFF0F5","6A3D70","AED9E0","2E4156","FFF6FA","F5C2C7","D8567A","8FB8C7","AED9E0","C5E3E8","6A3D70","95C8A8","F5B0D6","6A3D70","2E4156"),
    ("Nube",       "FAFAFA","37474F","B0BEC5","FFFFFF","FCFCFC","ECEFF1","EF5350","78909C","B0BEC5","CFD8DC","37474F","78909C","90A4AE","37474F","FFFFFF"),
    ("Lavanda",    "F8F4FF","5E3A8C","C8B6E2","FFFFFF","FCFAFF","E8DEFC","D87093","9370DB","C8B6E2","D4C5E8","5E3A8C","9370DB","BA9CDB","5E3A8C","FFFFFF"),
    ("Lila",       "EFE6FF","4A2C7A","7B61C9","FFFFFF","F7F1FF","E1D3FF","D94A6A","3D5AFE","7B61C9","9279DC","271052","3B1D78","4E279E","271052","FFFFFF"),
    ("Sakura",     "FFF5F8","8B2252","F48FB1","5D0030","FFF0F5","FCDDE8","C0392B","AD1457","F8BBD9","F48FB1","8B2252","C2185B","E91E8C","8B2252","5D0030"),
    ("Rosa",       "FFE8F0","7A1040","E8528A","FFFFFF","FFF0F5","FFDCEA","CC2244","D42070","E8528A","F07AAA","5A0028","C03060","E04080","5A0028","FFFFFF"),
    ("Atardecer",  "FFE5D4","6B2F4A","E0735C","FFF5EE","FFF2E8","F8C9A3","B91744","D4326B","E0735C","F08A6F","6B2F4A","A03A6E","D4326B","6B2F4A","FFF5EE"),
    ("Melocoton",  "FFF5EC","7A2E2E","FFAB91","FFFFFF","FFFAF3","FFD7BD","E63946","D86E3C","FFAB91","FFBFA8","7A2E2E","D86E3C","FFAB91","7A2E2E","FFFFFF"),
    ("Naranja",    "FFE7CC","7A3B00","F28C28","FFFFFF","FFF2E6","FFD9AD","CC3333","1D5BD7","F28C28","FFAA4D","4A2100","7A3600","994700","4A2100","FFFFFF"),
    ("Desierto",   "F5E6CB","4A2E0E","D2691E","FFF8E1","F9F0DC","EDD5A8","B22222","8B4513","D2691E","E07E2A","6B3410","A0522D","CD853F","6B3410","FFF8E1"),
    ("Vainilla",   "FFFCF2","6B5435","F4E1A6","4A3A20","FFFEF7","F8EDC8","D87333","B89464","F4E1A6","F8E9BD","6B5435","B89464","D8B470","6B5435","4A3A20"),
    ("Ceniza",     "2C2C2C","BDBDBD","424242","EEEEEE","242424","333333","EF5350","90A4AE","424242","555555","EEEEEE","9E9E9E","BDBDBD","212121","EEEEEE"),
    ("Grafito",    "26313D","EAF2FC","3E78B2","FFFFFF","1E2730","303D4A","FF6B6B","73A7FF","3E78B2","5591CC","FFFFFF","9DD2FF","C7E6FF","FFFFFF","FFFFFF"),
    ("Noche",      "0D0D0D","E8E8E8","222222","FFFFFF","111111","1A1A1A","FF5555","7EB8FF","1E1E1E","2E2E2E","FFFFFF","AAAAAA","FFFFFF","333333","CCCCCC"),
    ("Profundo",   "020A12","4FC3F7","021825","81D4FA","010609","031020","FF4444","00BCD4","021825","033040","4FC3F7","00BCD4","4FC3F7","021825","81D4FA"),
    ("Oceano",     "0A1929","9CDCEB","1B4D6B","E0F7FF","050D1A","0F2438","FF6B6B","FFB347","1B4D6B","2C6E92","5EE5D6","00B4D8","90E0EF","03455A","E0F7FF"),
    ("Aurora",     "060A12","80FFDB","0A1E30","80FFDB","040810","0C1C28","FF3366","00FFCC","0A1E30","163050","80FFDB","00FFCC","AA80FF","0A1E30","80FFDB"),
    ("Cyber",      "030D06","00FF88","001A0D","00FF88","020B05","041208","FF3355","00FFCC","002211","004422","00FF88","00CC66","00FF88","001A0D","00FF88"),
    ("Neon",       "050F03","39FF14","0A1F06","39FF14","030A02","081A04","FF003C","CCFF00","0A1F06","133D0A","39FF14","39FF14","CCFF00","0A1F06","39FF14"),
    ("Esmeralda",  "010F08","A8FFD0","003320","C8FFE8","000A05","001A0F","FF4444","00FF88","002218","004430","FFD700","00CC66","FFD700","010F08","C8FFE8"),
    ("Jungla",     "0F1E0F","B4E197","1F4D2F","E0FFCB","081108","152618","FF7043","FFB300","1F4D2F","2E6B3F","F4C430","4CAF50","FFB300","0F1E0F","E0FFCB"),
    ("Bosque",     "1C1208","C8A96E","2D1E0A","E8C97A","140E06","231508","FF5533","8BC34A","3B2610","5A3D18","8BC34A","6D9B2A","C8A96E","1C1208","E8C97A"),
    ("Cafe",       "1A1008","DEB887","3D2010","F5D5A0","120B04","251508","FF5533","C8963C","3D2010","5A3018","F5D5A0","C8963C","F5D5A0","3D2010","F5D5A0"),
    ("Dorado",     "0A0800","FFD700","1E0F00","FFE55C","070500","140C00","FF4422","FFA500","1A0F00","2E1A00","FFD700","CC8800","FF6600","0A0800","FFE55C"),
    ("Magma",      "0E0400","FF6B35","1E0800","FF9A5C","080200","180600","FF1744","FF6B35","1E0800","330D00","FF9A5C","FF4500","FF6B35","1E0800","FF9A5C"),
    ("Sangre",     "0A0000","F5DDD0","2A0000","FFD0C0","060000","160000","FF0000","FF6644","1A0000","3A0000","FF2222","CC0000","FF3322","0A0000","FFD0C0"),
    ("Abismo",     "0A0010","D8C8FF","120020","E0D0FF","0D0018","140025","FF4477","AA88FF","1A0030","280050","C8A8FF","9966FF","BB88FF","1A0030","D8C8FF"),
    ("Electrico",  "0A0A1A","E040FB","4A148C","EA80FC","080812","0D0D22","FF1744","7B1FA2","4A148C","6A1EB0","E040FB","AA00FF","E040FB","1A0030","EA80FC"),
    ("Eclipse",    "050508","C8A060","0D0A20","FFB347","030306","0A0818","FF2244","00FFCC","14102A","221840","FFB347","FF6600","FFD700","080520","FFB347"),
    ("Cosmos",     "03000F","E2C9FF","180040","FFD700","020008","0D001E","FF1493","00E5FF","12002E","1E0050","FFD700","BF00FF","FF69B4","080020","FFD700"),
    ("Void",       "000000","FFFFFF","0A0A0A","FF0000","050505","0D0D0D","FF0000","FF0000","111111","1C1C1C","FF0000","FF0000","FFFFFF","000000","FF0000"),
    ("Fenix",      "FFF8EC","8B3A00","FF6B00","FFFFFF","FFFBF5","FFE5C0","00C9B7","00C9B7","FFB347","FF8C00","00C9B7","00C9B7","FF6B00","FFB347","FFFFFF"),
    ("Nika",       "FFFFFF","CC0000","CC0000","FFFFFF","FFFFFF","FFF2F2","990000","CC0000","FFF2F2","FFE0E0","CC0000","DD0000","FF2222","CC0000","CC0000"),
    ("Premium",    "050008","FFFFFF","0F0020","FFFFFF","030005","0A0015","FF0066","00FFCC","15002A","25004A","FFFFFF","FF00FF","FFD700","0A0015","FFFFFF"),
    ("Brawl",      "000000","FFFFFF","0050D5","FFFFFF","000000","0A1A30","FF4444","4FC3F7","0050D5","1976D2","FFFFFF","00B0FF","FFFFFF","050E1C","FFFFFF"),
    ("Cyberpunk",  "0D0B1F","00FFFF","FF00AA","FFFF00","070518","130E2E","FFFF00","00FFFF","FF00AA","FF33BB","FFFF00","FF00AA","00FFFF","1A1240","FFFFFF"),
    ("Retrowave",  "1A0833","FF6EC7","7A1FA2","00E5FF","0F051F","23104D","FF4081","FF8A50","7A1FA2","9C27B0","FF8A50","FF6EC7","00E5FF","1A0833","FFFFFF"),
    ("Akuma",      "0A0000","FFD700","8B0000","FFD700","050000","110000","FFFFFF","FF4444","8B0000","B00000","FFD700","8B0000","FFD700","0A0000","FFD700"),
    ("Sky",        "E1F5FE","0277BD","FFFFFF","0277BD","F0FAFE","B3E5FC","F06292","81D4FA","FFFFFF","F5F9FB","0277BD","81D4FA","F8BBD9","0277BD","0277BD"),
    ("Matrix",     "000000","00FF00","002200","00FF00","000800","001100","FF0000","00FF00","002200","003800","00FF00","00FF00","FFFFFF","001100","00FF00"),
]
KEYS = ["nombre","fondo","texto","barra","textoBarra","historial","panel","cooldown","afk","boton","hover","logo","luzOn","luzAccion","luzOff","btnTexto"]
PALETA_KEYS = [("fondo","Fondo"),("barra","Barra"),("texto","Texto"),("textoBarra","Texto barra"),
               ("boton","Boton"),("btnTexto","Texto boton"),("logo","Logo"),("cooldown","Cooldown")]

def aclarar(h, f=0.35):
    r=int(h[0:2],16); g=int(h[2:4],16); b=int(h[4:6],16)
    return (min(255,r+round((255-r)*f)), min(255,g+round((255-g)*f)), min(255,b+round((255-b)*f)))

def hr(h):
    return (int(h[0:2],16), int(h[2:4],16), int(h[4:6],16))

# ============ FUENTES ============
FONTS_DIR = r"C:\Windows\Fonts"
FONT_REG  = os.path.join(FONTS_DIR, "segoeui.ttf")
FONT_BOLD = os.path.join(FONTS_DIR, "segoeuib.ttf")
FONT_SBI  = os.path.join(FONTS_DIR, "segoeuisl.ttf")  # Semilight, fallback
FONT_SYM  = os.path.join(FONTS_DIR, "seguisym.ttf")
FONT_MONO = os.path.join(FONTS_DIR, "consola.ttf")

def f(path, size):
    try: return ImageFont.truetype(path, size)
    except: return ImageFont.load_default()

# ============ Helpers de dibujo ============
def draw_rect(draw, x, y, w, h, color, radius=0):
    if radius > 0:
        draw.rounded_rectangle([x, y, x+w-1, y+h-1], radius=radius, fill=color)
    else:
        draw.rectangle([x, y, x+w-1, y+h-1], fill=color)

def draw_text(draw, x, y, w, h, text, font, color, anchor="ml"):
    # anchor: ml (middle-left), mm (middle-middle), mr (middle-right)
    bbox = draw.textbbox((0,0), text, font=font, anchor="lt")
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    if anchor == "mm":
        tx = x + (w - tw)/2 - bbox[0]
        ty = y + (h - th)/2 - bbox[1]
    elif anchor == "ml":
        tx = x - bbox[0]
        ty = y + (h - th)/2 - bbox[1]
    elif anchor == "mr":
        tx = x + w - tw - bbox[0]
        ty = y + (h - th)/2 - bbox[1]
    else: # tl
        tx = x - bbox[0]
        ty = y - bbox[1]
    draw.text((tx, ty), text, font=font, fill=color)

def draw_icon_text(draw, x, y, w, h, icon, label, icon_font, text_font, color, gap_px=8):
    """Dibuja icono + label centrados juntos en la caja (x,y,w,h).
    El icono va con icon_font (ej. FONT_SYM) y el label con text_font (ej. FONT_BOLD).
    Asi cada uno se renderiza con la fuente que tiene sus glifos."""
    ibb = draw.textbbox((0,0), icon, font=icon_font, anchor="lt")
    tbb = draw.textbbox((0,0), label, font=text_font, anchor="lt")
    iw = ibb[2] - ibb[0]; ih = ibb[3] - ibb[1]
    tw = tbb[2] - tbb[0]; th = tbb[3] - tbb[1]
    total_w = iw + gap_px + tw
    # Centrado horizontal en la caja
    start_x = x + (w - total_w) / 2
    # Centrado vertical de cada elemento (alineado a media linea)
    cy = y + h / 2
    iy = cy - ih / 2 - ibb[1]
    ty = cy - th / 2 - tbb[1]
    draw.text((start_x - ibb[0], iy), icon, font=icon_font, fill=color)
    draw.text((start_x + iw + gap_px - tbb[0], ty), label, font=text_font, fill=color)

# ============ Dimensiones (en pixeles ya supersampleados 2x) ============
SCALE = 2
W = 870 * SCALE
H = 400 * SCALE
MX = 15 * SCALE
MY = 15 * SCALE
MW = 630 * SCALE
MH = 370 * SCALE
PX_S = 670 * SCALE   # palette x
PY_S = 15 * SCALE    # palette y

def s(v):
    """Escalar coordenadas/tamaños"""
    return int(round(v * SCALE))

def hacer_png(t, idx):
    d = dict(zip(KEYS, t))
    nombre = d["nombre"]
    glow = aclarar(d["barra"], 0.35)
    fondo_rgb = hr(d["fondo"])
    barra_rgb = hr(d["barra"])
    texto_rgb = hr(d["texto"])
    textoBarra_rgb = hr(d["textoBarra"])
    boton_rgb = hr(d["boton"])
    btnTexto_rgb = hr(d["btnTexto"])
    logo_rgb = hr(d["logo"])
    luzOn_rgb = hr(d["luzOn"])
    luzAccion_rgb = hr(d["luzAccion"])
    luzOff_rgb = hr(d["luzOff"])

    img = Image.new("RGB", (W, H), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    # === MOCKUP ===
    # Fondo (redondeado)
    draw_rect(draw, MX, MY, MW, MH, fondo_rgb, radius=s(22))
    # Barra titulo
    draw_rect(draw, MX, MY, MW, s(39), barra_rgb)
    # Glow
    draw_rect(draw, MX, MY+s(39), MW, s(3), glow)

    # Badge P1
    draw_rect(draw, MX+s(8), MY+s(6), s(38), s(27), textoBarra_rgb, radius=s(4))
    draw_text(draw, MX+s(8), MY+s(6), s(38), s(27), "P1", f(FONT_BOLD, s(14)), barra_rgb, anchor="mm")

    # Titulo
    draw_text(draw, MX+s(150), MY+s(8), s(330), s(24), "BrawlMacro V30",
              f(FONT_BOLD, s(18)), textoBarra_rgb, anchor="mm")

    # Botones Reset/Min/Close
    for bx, ch, name_id in [(485, "↻", "btnReset"), (532, "−", "btnMin"), (580, "✕", "btnClose")]:
        draw_rect(draw, MX+s(bx), MY+s(52), s(32), s(31), boton_rgb)
        draw_text(draw, MX+s(bx), MY+s(52), s(32), s(31), ch,
                  f(FONT_SYM, s(17)), btnTexto_rgb, anchor="mm")

    # Logo (engranaje)
    draw_text(draw, MX+s(50), MY+s(53), s(110), s(110), "⚙",
              f(FONT_SYM, s(80)), logo_rgb, anchor="mm")

    # AFK Smart
    draw_text(draw, MX+s(270), MY+s(110), s(130), s(24), "AFK Smart",
              f(FONT_BOLD, s(18)), texto_rgb, anchor="ml")

    # 4 botones personalizacion (◐ ◆ ★ ▤ — chars BMP)
    for bx, ch, name_id in [(378, "◐", "tema"), (428, "◆", "rgb"),
                              (479, "★", "part"), (529, "▤", "hist")]:
        draw_rect(draw, MX+s(bx), MY+s(93), s(41), s(41), boton_rgb)
        draw_text(draw, MX+s(bx), MY+s(93), s(41), s(41), ch,
                  f(FONT_SYM, s(18)), btnTexto_rgb, anchor="mm")

    # Separador 1
    draw_rect(draw, MX+s(47), MY+s(154), s(535), s(2), barra_rgb)

    # Luces
    draw_rect(draw, MX+s(63), MY+s(205), s(32), s(31), luzOn_rgb)
    draw_rect(draw, MX+s(110), MY+s(205), s(32), s(31), luzAccion_rgb)
    draw_rect(draw, MX+s(158), MY+s(205), s(32), s(31), luzOff_rgb)

    # Timer (icono ⏰ con FONT_SYM + texto con FONT_BOLD)
    draw_icon_text(draw, MX+s(360), MY+s(208), s(200), s(28),
                   "⏰", "00:00",
                   f(FONT_SYM, s(18)), f(FONT_BOLD, s(18)),
                   texto_rgb, gap_px=s(6))

    # Separador 2
    draw_rect(draw, MX+s(47), MY+s(268), s(535), s(2), barra_rgb)

    # Botones grandes (iconos con FONT_SYM + label con FONT_BOLD)
    draw_rect(draw, MX+s(63), MY+s(280), s(220), s(57), boton_rgb)
    draw_icon_text(draw, MX+s(63), MY+s(280), s(220), s(57),
                   "▶", "Iniciar (F1)",
                   f(FONT_SYM, s(15)), f(FONT_BOLD, s(15)),
                   btnTexto_rgb, gap_px=s(8))
    draw_rect(draw, MX+s(347), MY+s(280), s(220), s(57), boton_rgb)
    draw_icon_text(draw, MX+s(347), MY+s(280), s(220), s(57),
                   "■", "Parar (F2)",
                   f(FONT_SYM, s(15)), f(FONT_BOLD, s(15)),
                   btnTexto_rgb, gap_px=s(8))

    # Borde sutil del mockup
    bx, by, bw, bh = MX, MY, MW, MH
    draw.rounded_rectangle([bx, by, bx+bw-1, by+bh-1], radius=s(22),
                           outline=(0,0,0), width=max(1, int(SCALE*0.5)))

    # === PALETA ===
    draw_text(draw, PX_S, PY_S, s(180), s(24), nombre,
              f(FONT_BOLD, s(20)), (34,34,34), anchor="ml")
    draw_text(draw, PX_S, PY_S+s(28), s(180), s(14), "Paleta del tema",
              f(FONT_REG, s(10)), (136,136,136), anchor="ml")
    draw_rect(draw, PX_S, PY_S+s(46), s(180), s(1), (221,221,221))

    swatch_h = 38
    sw = 26
    start_y = PY_S + s(54)
    for i, (key, label) in enumerate(PALETA_KEYS):
        sy = start_y + i * s(swatch_h)
        # Borde sutil
        draw_rect(draw, PX_S-s(1), sy-s(1), s(sw+2), s(sw+2), (221,221,221), radius=s(5))
        # Color
        draw_rect(draw, PX_S, sy, s(sw), s(sw), hr(d[key]), radius=s(4))
        # Label
        draw_text(draw, PX_S+s(sw+12), sy+s(2), s(140), s(14), label,
                  f(FONT_BOLD, s(11)), (51,51,51), anchor="ml")
        # Hex
        draw_text(draw, PX_S+s(sw+12), sy+s(15), s(140), s(12), f"#{d[key]}",
                  f(FONT_MONO, s(10)), (119,119,119), anchor="ml")

    # Downsample a 870x400 con anti-aliasing para crispness
    final = img.resize((W//SCALE, H//SCALE), Image.LANCZOS)
    return final

def slug(s_):
    repl = {"á":"a","é":"e","í":"i","ó":"o","ú":"u","ñ":"n",
            "Á":"A","É":"E","Í":"I","Ó":"O","Ú":"U","Ñ":"N"}
    for k,v in repl.items():
        s_ = s_.replace(k,v)
    return re.sub(r"[^A-Za-z0-9_-]","",s_)

# Salida
out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mockups_png")
os.makedirs(out_dir, exist_ok=True)
# Limpiar PNGs viejos
for fn in os.listdir(out_dir):
    if fn.endswith(".png"):
        os.remove(os.path.join(out_dir, fn))

for idx, t in enumerate(TEMAS, start=1):
    img = hacer_png(t, idx)
    fname = f"{idx:02d}-{slug(t[0])}.png"
    img.save(os.path.join(out_dir, fname), "PNG", optimize=True)

print(f"Generados {len(TEMAS)} PNGs en {out_dir}")
print(f"Tamaño: 870x400 px (renderizados a 1740x800 y downscaled para crispness)")
