#!/usr/bin/env python3
"""README diyagramlarını üretir: docs/altin_spiral.svg, docs/fillotaksis.svg, docs/paletler.svg.

Mathematica gerekmez; yalnızca Python standart kütüphanesi.
Kullanım (repo kökünden):  python3 docs/araclar/diyagramlar.py

Sayılar ruh_katmanlari.wl'den alınır: paletlerin hex kodları dosyadan okunur,
kare kesimi goldenConstruction'ı, fillotaksis Bölüm 4'teki phyllo katmanını birebir izler.
"""

import math
import re
from pathlib import Path

KOK = Path(__file__).resolve().parents[2]
DOCS = KOK / "docs"
WL = KOK / "ruh_katmanlari.wl"

PHI = (1 + math.sqrt(5)) / 2
ALTIN_ACI = math.pi * (3 - math.sqrt(5))  # goldenAngle

# kendi koyu arka planı olan SVG'ler: açık ve koyu GitHub temasında aynı görünür
ZEMIN = "#0f1220"
CERCEVE = "#2a2f45"
YAZI = "#e8e6f0"
SONUK = "#9aa0b8"
ALTIN = "#e3b04b"
KUTUP = "#ff5a5a"
FONT = "-apple-system, 'Segoe UI', Helvetica, Arial, sans-serif"
MONO = "ui-monospace, SFMono-Regular, Menlo, Consolas, monospace"

UST = str.maketrans("0123456789-", "⁰¹²³⁴⁵⁶⁷⁸⁹⁻")


def svg_bas(w, h, baslik):
    return [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" '
        f'font-family="{FONT}">',
        f"<title>{baslik}</title>",
        f'<rect x="0.5" y="0.5" width="{w - 1}" height="{h - 1}" rx="14" fill="{ZEMIN}" stroke="{CERCEVE}"/>',
    ]


def yazi(x, y, metin, boy=14, renk=YAZI, hiza="start", kalin=False, font=None):
    agirlik = ' font-weight="600"' if kalin else ""
    aile = f' font-family="{font}"' if font else ""
    return (f'<text x="{x:.1f}" y="{y:.1f}" font-size="{boy}" fill="{renk}" '
            f'text-anchor="{hiza}"{agirlik}{aile}>{metin}</text>')


def kaydet(ad, parcalar):
    (DOCS / ad).write_text("\n".join(parcalar + ["</svg>"]) + "\n", encoding="utf-8")
    print("yazıldı:", DOCS / ad)


# ---------------------------------------------------------------- paletler ve Blend

def paletleri_oku():
    metin = WL.read_text(encoding="utf-8")
    blok = re.search(r"palettes = <\|(.*?)\|>;", metin, re.S).group(1)
    return {ad: re.findall(r'"(#[0-9a-fA-F]{6})"', renkler)
            for ad, renkler in re.findall(r'"(\w+)"\s*->\s*hex\s*/@\s*\{([^}]*)\}', blok)}


def rgb(hx):
    return [int(hx[i:i + 2], 16) / 255 for i in (1, 3, 5)]


def blend(hexler, t):
    """Mathematica'daki Blend[liste, t]: eşit aralıklı renkler arasında doğrusal geçiş (palColor)."""
    t = min(max(t, 0.0), 1.0)
    renkler = [rgb(h) for h in hexler]
    u = t * (len(renkler) - 1)
    i = min(int(u), len(renkler) - 2)
    f = u - i
    c = [a + (b - a) * f for a, b in zip(renkler[i], renkler[i + 1])]
    return "#" + "".join(f"{round(v * 255):02x}" for v in c)


# ---------------------------------------------------------------- altın spiral

def golden_construction(n=14):
    """ruh_katmanlari.wl'deki goldenConstruction: üst, sağ, alt, sol sırasıyla kare kesimi."""
    x, y, w, h = 0.0, 0.0, 1.0, PHI
    kareler, yaylar = [], []
    for k in range(n):
        m = k % 4
        if m == 0:
            s = w; kareler.append((x, y + h - s, s)); yaylar.append(((x, y + h - s), s, 90.0)); h -= s
        elif m == 1:
            s = h; kareler.append((x + w - s, y, s)); yaylar.append(((x + w - s, y + h), s, 0.0)); w -= s
        elif m == 2:
            s = w; kareler.append((x, y, s)); yaylar.append(((x + s, y + s), s, -90.0)); y += s; h -= s
        else:
            s = h; kareler.append((x, y, s)); yaylar.append(((x + s, y), s, 180.0)); x += s; w -= s
    spiral = []
    for (cx, cy), r, a0 in yaylar:
        for i in range(80):
            t = math.radians(a0 - 90.0 * i / 79)
            spiral.append((cx + r * math.cos(t), cy + r * math.sin(t)))
    return kareler, spiral, (x + w / 2, y + h / 2)


def altin_spiral():
    kareler, spiral, kutup = golden_construction(14)
    W, H = 760, 660
    p = svg_bas(W, H, "Altın dikdörtgen, altın spiral ve kutup")
    p.append(yazi(30, 40, "Altın dikdörtgen → altın spiral → kutup", 20, kalin=True))
    p.append(yazi(30, 63, "goldenConstruction[14]: 1 × φ tuvalden sırayla üst, sağ, alt, sol kare kesilir; "
                          "kare kenarları φ⁻ᵏ.", 13, SONUK))

    def panel(ox, oy, olcek, ayna, etiketle):
        def T(pt):
            x, y = pt
            if ayna:
                y = PHI - y
            return ox + x * olcek, oy + (PHI - y) * olcek

        out = [f'<rect x="{ox}" y="{oy}" width="{olcek:.1f}" height="{PHI * olcek:.1f}" '
               f'fill="#161a2e" stroke="{SONUK}" stroke-width="1.2"/>']
        yonler = ["üst", "sağ", "alt", "sol"]
        for k, (x, y, s) in enumerate(kareler):
            (x1, y1), (x2, y2) = T((x, y)), T((x + s, y + s))
            out.append(f'<rect x="{min(x1, x2):.2f}" y="{min(y1, y2):.2f}" width="{abs(x2 - x1):.2f}" '
                       f'height="{abs(y2 - y1):.2f}" fill="none" stroke="#5a6488" stroke-width="0.9"/>')
            kenar = s * olcek
            if etiketle and kenar > 35:
                mx, my = (x1 + x2) / 2, (y1 + y2) / 2
                deger = "1" if k == 0 else ("1/φ" if k == 1 else "1/φ" + str(k).translate(UST))
                out.append(yazi(mx, my + kenar * 0.07, deger, max(10, min(30, kenar * 0.2)), ALTIN, "middle"))
                if kenar > 60:
                    out.append(yazi(min(x1, x2) + 6, min(y1, y2) + 15, f"{k + 1}. {yonler[k % 4]}",
                                    max(9, min(12, kenar * 0.09)), SONUK))
        yol = " ".join(f"{a:.2f},{b:.2f}" for a, b in map(T, spiral))
        out.append(f'<polyline points="{yol}" fill="none" stroke="{ALTIN}" stroke-width="2.2" '
                   f'stroke-linecap="round" stroke-linejoin="round"/>')
        kx, ky = T(kutup)
        out.append(f'<circle cx="{kx:.2f}" cy="{ky:.2f}" r="5" fill="{KUTUP}" stroke="{ZEMIN}" stroke-width="1.5"/>')
        return out, (kx, ky)

    # sol panel: Ruh Katmanları'nın yapısı
    ox, oy, olcek = 40, 95, 320
    parca, (kx, ky) = panel(ox, oy, olcek, False, True)
    p += parca
    # etiket kutbun sağ altına, kısa bir çizgiyle: küçük karelerin üstüne binmesin
    p.append(f'<line x1="{kx + 4:.2f}" y1="{ky + 4:.2f}" x2="{kx + 44:.2f}" y2="{ky + 34:.2f}" '
             f'stroke="{KUTUP}" stroke-width="1.2"/>')
    p.append(yazi(kx + 48, ky + 40, "kutup", 13, KUTUP, kalin=True))
    p.append(yazi(ox, oy + PHI * olcek + 26, "Ruh Katmanları: kutup ≈ (0.276, 0.447) → ışık patlaması burada",
                  12.5, SONUK))

    # sağ panel: aynalanmış yapı, kutup %72 yükseklikte
    ox2, oy2, olcek2 = 470, 175, 200
    p.append(yazi(ox2, 130, "Işık Kafesi ve Eriyen Maskeler", 15, kalin=True))
    p.append(yazi(ox2, 150, "y → φ − y  (tohuma göre x → 1 − x de)", 12.5, SONUK))
    parca, (kx2, ky2) = panel(ox2, oy2, olcek2, True, False)
    p += parca
    alt = oy2 + PHI * olcek2
    p.append(f'<line x1="{ox2}" y1="{ky2:.2f}" x2="{ox2 + olcek2}" y2="{ky2:.2f}" stroke="{KUTUP}" '
             f'stroke-width="1" stroke-dasharray="4 4"/>')
    ax = ox2 + olcek2 + 22
    p.append(f'<line x1="{ax}" y1="{alt:.2f}" x2="{ax}" y2="{ky2 + 6:.2f}" stroke="{YAZI}" stroke-width="1.2"/>')
    p.append(f'<path d="M{ax - 5},{ky2 + 10:.2f} L{ax},{ky2 + 2:.2f} L{ax + 5},{ky2 + 10:.2f}" fill="none" '
             f'stroke="{YAZI}" stroke-width="1.2"/>')
    oran = (PHI - kutup[1]) / PHI
    p.append(yazi(ax + 8, (alt + ky2) / 2 - 6, f"%{oran * 100:.1f}", 15, KUTUP, kalin=True))
    p.append(yazi(ax + 8, (alt + ky2) / 2 + 12, "yükseklik", 12, SONUK))
    p.append(yazi(ox2, alt + 26, "kutup göğüs hizasına çıkar;", 12.5, SONUK))
    p.append(yazi(ox2, alt + 44, "maskelerin aşağı akacak yeri olur", 12.5, SONUK))
    kaydet("altin_spiral.svg", p)


# ---------------------------------------------------------------- fillotaksis

def fillotaksis(paletler):
    W, H = 760, 475
    pal = paletler["Kozmik"]
    p = svg_bas(W, H, "Fillotaksis: altın açıyla dizilmiş noktalar")
    p.append(yazi(30, 40, "Fillotaksis: ayçiçeği gibi dizilim", 20, kalin=True))
    p.append(yazi(30, 63, "rₙ = R·√(n/N),  θₙ = n·θg   (N = 400; ruhKatmanlari'ndaki phyllo katmanı 520 ve 300 nokta)",
                  13, SONUK))

    cx, cy, R = 215, 255, 165
    m = 400
    for i in range(m):
        rr = R * math.sqrt(i / m)
        th = i * ALTIN_ACI
        # koddaki nokta boyutu 0.00077·√((1 − i/m)·22 + 2), R = 0.2 tuval birimine göre ölçeklenmiş
        r = 0.00077 * math.sqrt((1 - i / m) * 22 + 2) / 0.2 * R * 1.25
        p.append(f'<circle cx="{cx + rr * math.cos(th):.2f}" cy="{cy - rr * math.sin(th):.2f}" r="{r:.2f}" '
                 f'fill="{blend(pal, 0.95 - 0.5 * i / m)}" fill-opacity="0.9"/>')

    # açı çizimi: çember φ oranında ikiye bölünür, küçük yay altın açı
    ax, ay, ar = 560, 225, 95
    th_g = math.degrees(ALTIN_ACI)

    def nokta(deg, r=ar):
        return ax + r * math.cos(math.radians(deg)), ay - r * math.sin(math.radians(deg))

    x1, y1 = nokta(0)
    x2, y2 = nokta(th_g)
    p.append(f'<circle cx="{ax}" cy="{ay}" r="{ar}" fill="#1b2140" stroke="#5a6488" stroke-width="1.2"/>')
    p.append(f'<path d="M{ax},{ay} L{x1:.2f},{y1:.2f} A{ar},{ar} 0 0 0 {x2:.2f},{y2:.2f} Z" '
             f'fill="{ALTIN}" fill-opacity="0.35" stroke="{ALTIN}" stroke-width="1.6"/>')
    p.append(f'<line x1="{ax}" y1="{ay}" x2="{x1:.2f}" y2="{y1:.2f}" stroke="{YAZI}" stroke-width="1.4"/>')
    p.append(f'<line x1="{ax}" y1="{ay}" x2="{x2:.2f}" y2="{y2:.2f}" stroke="{YAZI}" stroke-width="1.4"/>')
    lx, ly = nokta(th_g / 2, ar * 0.55)
    p.append(yazi(lx, ly + 5, "θg", 15, ALTIN, "middle", kalin=True))
    bx, by = nokta(th_g + (360 - th_g) / 2, ar * 0.55)
    p.append(yazi(bx, by + 5, "360°/φ", 13, SONUK, "middle"))

    tx = 455
    satirlar = [
        (f"θg = 360°/φ² ≈ {th_g:.2f}°", ALTIN, True),
        (f"360° − θg = 360°/φ ≈ {360 - th_g:.2f}°", YAZI, False),
        (f"büyük yay / küçük yay = φ ≈ {PHI:.3f}", YAZI, False),
        ("Her yeni nokta bir öncekinden θg kadar döner:", SONUK, False),
        ("açı hiçbir kesirle tekrarlanmadığı için", SONUK, False),
        ("noktalar boşluk bırakmadan yayılır.", SONUK, False),
    ]
    for j, (s, renk, kalin) in enumerate(satirlar):
        p.append(yazi(tx, 345 + 19 * j, s, 13.5 if j < 3 else 12.5, renk, kalin=kalin))
    kaydet("fillotaksis.svg", p)


# ---------------------------------------------------------------- paletler

def paletler_svg(paletler):
    W = 760
    sol, sag = 30, 30
    satir = 128
    H = 80 + satir * len(paletler)
    p = svg_bas(W, H, "Paletler")
    p.append(yazi(sol, 40, "Paletler", 20, kalin=True))
    p.append(yazi(sol, 63, "ruh_katmanlari.wl → palettes. Renkler koyudan açığa dizilir; "
                           "palColor[pal, t] aralarında geçiş yapar (alttaki şerit).", 13, SONUK))
    p.append("<defs>")
    for ad, renkler in paletler.items():
        n = len(renkler)
        duraklar = "".join(f'<stop offset="{i / (n - 1):.4f}" stop-color="{r}"/>' for i, r in enumerate(renkler))
        p.append(f'<linearGradient id="g_{ad}" x1="0" x2="1" y1="0" y2="0">{duraklar}</linearGradient>')
    p.append("</defs>")
    y = 85
    for ad, renkler in paletler.items():
        n = len(renkler)
        p.append(yazi(sol, y + 14, ad, 15, kalin=True))
        p.append(yazi(W - sag, y + 14, f"{n} renk", 12, SONUK, "end"))
        gw = (W - sol - sag) / n
        for i, r in enumerate(renkler):
            x = sol + i * gw
            p.append(f'<rect x="{x + 2:.1f}" y="{y + 24}" width="{gw - 4:.1f}" height="44" rx="6" fill="{r}" '
                     f'stroke="#ffffff" stroke-opacity="0.12"/>')
            p.append(yazi(x + gw / 2, y + 86, r, 11.5, SONUK, "middle", font=MONO))
        p.append(f'<rect x="{sol + 2}" y="{y + 96}" width="{W - sol - sag - 4}" height="10" rx="5" '
                 f'fill="url(#g_{ad})"/>')
        y += satir
    kaydet("paletler.svg", p)


if __name__ == "__main__":
    pal = paletleri_oku()
    altin_spiral()
    fillotaksis(pal)
    paletler_svg(pal)
