"""Ruh Katmanları — ruh_katmanlari.wl dosyasının Python karşılığı.

Bölüm numaraları ve adlar .wl dosyasıyla aynı; her fonksiyonun üstünde Mathematica'daki adı yazıyor.
Üç mod bir Cizim döndürür (Graphics karşılığı); finish ve smear 0…1 aralığında RGB dizisi döndürür.

Not: Rastgele sayı üreteci Mathematica'dakinden farklı olduğu için aynı tohum aynı resmi vermez;
kompozisyon kuralları (altın yapı, kutup, girdaplar, katman sırası) birebir aynıdır.
"""

import numpy as np
from scipy.ndimage import gaussian_filter, convolve1d
from skimage.transform import resize

from tuval import Cizim, PHI

# =====================================================================================
# 1. Sabitler ve paletler
# =====================================================================================

phi = PHI
golden_angle = np.pi * (3 - 5 ** 0.5)          # ≈ 2.39996 rad ≈ 137.5°
BEYAZ = np.array([1.0, 1.0, 1.0])
SIYAH = np.array([0.0, 0.0, 0.0])


def hex_renk(s):
    v = int(s[1:], 16)
    return np.array([(v >> 16) & 255, (v >> 8) & 255, v & 255]) / 255.0


# Her palet koyudan açığa/sıcağa dizilir: 0 = zemin tonu, 1 = ışık tonu
palettes = {
    "Toprak": [hex_renk(h) for h in ["#24363d", "#3f6f73", "#8fbcbc", "#e3b04b", "#ec7a3c", "#c8423a", "#f4cdbd"]],
    "Hayalet": [hex_renk(h) for h in ["#2a1240", "#6b2d8f", "#e0569a", "#f6a8c6", "#f7e27a", "#b6f25c", "#45d6b0"]],
    "Kozmik": [hex_renk(h) for h in ["#0b1150", "#2337c6", "#5aa2ff", "#8a2be2", "#e5207f", "#ff6a3d", "#ffd84a"]],
    "NeonGece": [hex_renk(h) for h in ["#0a0f2e", "#1d3bd1", "#6cb6ff", "#33e0d0", "#d61a8f", "#ff3d6e",
                                       "#ff7a2a", "#ffd23f", "#fff4d6"]],
    "PastelRuh": [hex_renk(h) for h in ["#3b1840", "#b39ddb", "#f4b6c6", "#ffcba4", "#fbe8a6", "#b6f23a", "#3fd8c6"]],
}


def blend(renkler, t):
    """Blend[renkler, t]: eşit aralıklı renkler arasında doğrusal geçiş; t skaler ya da dizi."""
    renkler = np.asarray(renkler, float)
    t = np.clip(np.asarray(t, float), 0.0, 1.0)
    k = len(renkler) - 1
    x = t * k
    i = np.minimum(np.floor(x).astype(int), k - 1)
    f = (x - i)[..., None]
    return renkler[i] * (1 - f) + renkler[i + 1] * f


def pal_color(pal, t):
    return blend(pal, t)


def scale_color(c, k):
    return np.clip(np.asarray(k, float)[..., None] * np.asarray(c, float), 0.0, 1.0)


def darker(c, a):
    return np.asarray(c, float) * (1 - a)


# Mathematica'daki SeedRandom gibi: her mod başında tohumlanan ortak üreteç
R = np.random.default_rng()


def seed_random(s):
    global R
    R = np.random.default_rng(s)


def nz(shape, s):
    return R.normal(0.0, s, shape)


def seeds_in(n):
    return np.column_stack([R.uniform(0, 1, n), R.uniform(0, phi, n)])


def perp(u):
    return np.array([-u[1], u[0]])


def birim(a):
    return np.array([np.cos(a), np.sin(a)])


# =====================================================================================
# 2. Altın dikdörtgen, altın spiral ve kutup  (goldenConstruction)
# =====================================================================================

def golden_construction(n=14):
    x, y, w, h = 0.0, 0.0, 1.0, phi
    sq, arcs = [], []
    for k in range(n):
        m = k % 4
        if m == 0:
            s = w; sq.append((x, y + h - s, s)); arcs.append(((x, y + h - s), s, 90.0)); h -= s
        elif m == 1:
            s = h; sq.append((x + w - s, y, s)); arcs.append(((x + w - s, y + h), s, 0.0)); w -= s
        elif m == 2:
            s = w; sq.append((x, y, s)); arcs.append(((x + s, y + s), s, -90.0)); y += s; h -= s
        else:
            s = h; sq.append((x, y, s)); arcs.append(((x + s, y), s, 180.0)); x += s; w -= s
    spiral = np.concatenate([
        np.asarray(c) + s * np.column_stack([np.cos(np.radians(t)), np.sin(np.radians(t))])
        for c, s, a in arcs for t in [np.linspace(a, a - 90.0, 80)]])
    return {"Squares": sq, "Spiral": spiral, "Pole": np.array([x + w / 2, y + h / 2])}


def kare_cizgisi(sq, donustur=lambda p: p):
    x, y, s = sq
    return np.array([donustur(np.array(p)) for p in [(x, y), (x + s, y), (x + s, y + s), (x, y + s), (x, y)]])


# =====================================================================================
# 3. Akış alanı ve fırça izi takibi  (traceStrokes) — bütün darbeler aynı anda, numpy ile
# =====================================================================================

def trace_strokes(seeds, vc, vs, vd, swirl, ph, steps, dt):
    p = np.array(seeds, float).reshape(-1, 2)
    vc = np.asarray(vc, float).reshape(-1, 2)
    vs = np.asarray(vs, float)
    vd = np.asarray(vd, float)
    out = np.empty((len(p), steps, 2))
    out[:, 0] = p
    kok = 0.5 * np.sqrt(vs)
    for k in range(1, steps):
        x, y = p[:, 0], p[:, 1]
        wx = x + 0.22 * np.sin(3.3 * y + ph[0])
        wy = y + 0.22 * np.sin(2.9 * x + ph[1])
        n = np.sin(4.1 * wx + ph[2]) + np.cos(3.4 * wy - ph[0]) + 0.6 * np.sin(8.5 * (wx - 0.7 * wy) + ph[1])
        vx = np.cos(1.4 * n)
        vy = np.sin(1.4 * n)
        dx = x[:, None] - vc[:, 0]
        dy = y[:, None] - vc[:, 1]
        r = np.sqrt(dx ** 2 + dy ** 2) + 0.001
        g = 2.2 * swirl * vs * np.exp(-r / kok)
        ang = np.arctan2(dy, dx) + vd * (np.pi / 2 + 0.3)
        vx = vx + (g * np.cos(ang)).sum(1)
        vy = vy + (g * np.sin(ang)).sum(1)
        nrm = np.sqrt(vx ** 2 + vy ** 2) + 1e-9
        p = p + dt * np.column_stack([vx, vy]) / nrm[:, None]
        out[:, k] = p
    return out


# =====================================================================================
# 4. Ruh Katmanları  (ruhKatmanlari)
# =====================================================================================

def ruh_katmanlari(tohum=11, palet="Kozmik", girdap=1.0, yogunluk=1.0, kilavuz=False):
    seed_random(tohum)
    pal = palettes[palet]
    gc = golden_construction(14)
    sp, pole = gc["Spiral"], gc["Pole"]

    # girdaplar: kutup + spiral üzerinde iki nokta; güçler 1, 1/φ, 1/φ²; yönler +, −, +
    vc = [pole, sp[60], sp[200]]
    vs = [1.0, 1 / phi, 1 / phi ** 2]
    vd = [1.0, -1.0, 1.0]
    ph = R.uniform(0, 2 * np.pi, 3)
    cph = R.uniform(0, 2 * np.pi, 3)

    # renk alanı: tuvali büyük renk kütlelerine böler, odağa yaklaştıkça paletin ışık ucuna kayar
    def ctone(p):
        p = np.asarray(p, float)
        x, y = p[..., 0], p[..., 1]
        v = np.sin(2.3 * x + cph[0]) * np.cos(1.7 * y + cph[1]) + 0.5 * np.sin(3.1 * (x + y) + cph[2])
        v = (np.tanh(1.8 * v) + 1) / 2
        d = np.hypot(x - pole[0], y - pole[1])
        return np.clip(0.75 * v + 0.5 * np.exp(-d / 0.28), 0, 1)

    cnt = lambda n: max(10, round(n * yogunluk))
    g = Cizim(darker(pal[0], 0.2), tohum=tohum)

    def line_layer(seeds, steps, dt, w12, alpha, shift, jitter, b12):
        S = trace_strokes(seeds, vc, vs, vd, girdap, ph, steps, dt)
        n = len(seeds)
        ts = np.clip(ctone(seeds) + shift + nz(n, jitter), 0, 1)
        renk = scale_color(pal_color(pal, ts), R.uniform(*b12, n))
        gen = R.uniform(*w12, n)
        for i in range(n):
            g.cizgi(S[i], renk[i], alpha, gen[i])

    # 1) zemin: büyük, yumuşak renk lekeleri
    for _ in range(90):
        c = np.array([R.uniform(), R.uniform(0, phi)])
        g.disk(c, R.uniform(0.06, 0.28), pal_color(pal, ctone(c) + R.normal(0, 0.1)), 0.25)

    # 2) geniş, yarı saydam fırça darbeleri
    line_layer(seeds_in(cnt(1300)), 18, 0.013, (7, 18), 0.28, 0.0, 0.07, (0.85, 1.15))
    # 3) ince damarlar
    line_layer(seeds_in(cnt(1800)), 34, 0.006, (0.5, 2.0), 0.6, 0.12, 0.12, (0.85, 1.15))

    # 4) kalın kurdeleler: koyu kenar + gövde + ince parlak sırt
    starts = sp[R.integers(0, len(sp), 7)] + nz((7, 2), 0.15)
    S = trace_strokes(starts, vc, vs, vd, girdap, ph, 90, 0.008)
    for k in range(len(S)):
        t = ctone(starts[k]) + R.normal(0, 0.15)
        w = R.uniform(18, 34)
        g.cizgi(S[k], scale_color(pal_color(pal, t - 0.3), 0.7), 0.45, w + 5)
        g.cizgi(S[k], pal_color(pal, t), 0.55, w)
        g.cizgi(S[k] + 0.004, pal_color(pal, t + 0.25), 0.5, 0.25 * w)

    # 5) saydam küreler: spiral boyunca, yarıçap her adımda φ'ye bölünür; eskiz gibi çift kontur
    for kk, i in enumerate(np.round(np.linspace(21, len(sp) - 119, 7)).astype(int)):
        c, r = sp[i - 1], 0.34 / phi ** kk
        g.disk(c, r, pal_color(pal, 0.55 + 0.06 * kk), 0.16)
        for j in range(2):
            g.cember(c + nz(2, 0.02 * r), r * (1 + 0.015 * j), pal_color(pal, 0.85), 0.5, 0.9)

    # 6) kısa, opak boya lekeleri
    n6 = cnt(600)
    line_layer(seeds_in(n6), 4, 0.008, (2, 5), 0.5, nz(n6, 0.05), 0.15, (0.9, 1.3))

    # 7) fillotaksis: altın açıyla dizilmiş noktalar, altın bölüm çizgilerinin kesişimlerinde
    for cen, Rr, m in [((0.618, 0.786 * phi), 0.2, 520), ((0.786, 0.236 * phi), 0.15, 300)]:
        for i in range(m):
            rr, th = Rr * np.sqrt(i / m), i * golden_angle
            g.disk(np.array(cen) + rr * birim(th), 0.00077 * np.sqrt((1 - i / m) * 22 + 2),
                   pal_color(pal, 0.95 - 0.5 * i / m), 0.8)

    # 8) altın spiralin kendisi: üç katmanlı fırça izi
    for w, a in [(10, 0.10), (3.5, 0.3), (1.1, 0.85)]:
        g.cizgi(sp, pal_color(pal, 0.9), a, w)

    # 9) kutupta ışık patlaması: ışın açıları altın açının katları
    for k in range(48):
        a = k * golden_angle + R.normal(0, 0.04)
        ln = R.uniform(0.08, 0.32) * (1.5 if k % 5 == 0 else 1.0)
        w0 = R.uniform(0.006, 0.02)
        u, nv = birim(a), w0 * perp(birim(a))
        g.cokgen([pole + nv, pole + ln * u, pole - nv], pal_color(pal, R.uniform(0.8, 1.0)), 0.5)
        g.cokgen([pole + 0.3 * nv, pole + 0.8 * ln * u, pole - 0.3 * nv], (1, 1, 0.9), 0.6)
    for rad, op in [(0.12, 0.12), (0.07, 0.25), (0.035, 0.6), (0.015, 0.95)]:
        g.disk(pole, rad, (1, 0.97, 0.85), op)

    # 10) dört kollu yıldızlar: boyutları φ'nin kuvvetleri
    for _ in range(10):
        c = np.array([R.uniform(), R.uniform(0, phi)])
        s = 0.08 / phi ** R.integers(0, 4)
        col = pal_color(pal, R.uniform(0.7, 1.0))
        for j in range(8):
            a = j * np.pi / 4 + R.normal(0, 0.06)
            u = (s if j % 2 == 0 else 0.45 * s) * birim(a)
            g.cokgen([c + 0.08 * perp(u), c + u, c - 0.08 * perp(u)], col, 0.8)

    if kilavuz:
        for q in gc["Squares"]:
            g.cizgi(kare_cizgisi(q), BEYAZ, 0.8, 0.8)
        g.disk(pole, 0.006, (1, 0, 0), 1.0)
    return g


# =====================================================================================
# 5. Son işlem: parlama ve tuval dokusu  (finish)
# =====================================================================================

def finish(g, px=900, glow_amt=0.3, grain=0.024):
    a = g.resim(px)
    r = round(px / 35)
    # GaussianFilter[img, r]: yarıçap r, standart sapma r/2; kenarlar tekrar edilir
    b = gaussian_filter(a, sigma=(r / 2, r / 2, 0), truncate=2.0, mode="nearest")
    rng = np.random.default_rng(None if g.tohum is None else g.tohum + 10_000)
    noise = rng.normal(0, grain, a.shape[:2])[..., None]
    return np.clip(1 - (1 - a) * (1 - glow_amt * b) + noise, 0, 1)


# =====================================================================================
# 9. Ortak fırça araçları
# =====================================================================================

def dogru_parca(p, q, n=12):
    p, q = np.asarray(p, float), np.asarray(q, float)
    s = np.linspace(0, 1, n + 1)[:, None]
    return p + s * (q - p)


def egri_normalleri(pts):
    tg = np.vstack([pts[1] - pts[0], pts[2:] - pts[:-2], pts[-1] - pts[-2]])
    nr = np.column_stack([-tg[:, 1], tg[:, 0]])
    return nr / (np.linalg.norm(nr, axis=1, keepdims=True) + 1e-15)


def dalgalanma(n, amp):
    """Yumuşak gürültü: üç rastgele sinüsün toplamı + biraz titreşim — elin titremesi gibi."""
    t = np.linspace(0, 1, n)
    f = R.uniform(1.0, 4.5, 3); p = R.uniform(0, 2 * np.pi, 3); a = R.uniform(0.4, 1.0, 3)
    s = (a[:, None] * np.sin(2 * np.pi * f[:, None] * t + p[:, None])).sum(0) / a.sum()
    return amp * (s + R.normal(0, 0.15, n))


def titrek_firca(g, pts, renkler, w, hale=(), sapma=None):
    """titrekFirca: eğriyi normal yönünde kaydırılmış 3-5 titrek kopya olarak çizer."""
    pts = np.asarray(pts, float)
    n = len(pts)
    nrm = egri_normalleri(pts)
    kenar = 0.0015 * w
    s = 0.3 * kenar if sapma is None else sapma
    c = R.integers(3, 6)
    e = int(np.floor(0.08 * n))
    kopya = lambda off: pts + np.asarray(off)[..., None] * nrm
    if len(hale):
        g.cizgi(kopya(dalgalanma(n, s)), hale[0], 0.1, 3.2 * w)
        g.cizgi(kopya(0.62 * kenar + dalgalanma(n, 0.5 * s)), hale[0], 0.55, 0.35 * w)
        g.cizgi(kopya(-0.62 * kenar + dalgalanma(n, 0.5 * s)), hale[-1], 0.55, 0.35 * w)
    for j in range(c):
        f = j / (c - 1)
        k = kopya(dalgalanma(n, s))
        a, b = R.integers(0, e + 1), R.integers(0, e + 1)
        g.cizgi(k[a:n - b], blend(renkler, f), R.uniform(0.55, 0.85), w * (1 - 0.6 * f))


def sarmal_doku(g, c, aci, L, A, r12, basamak):
    """sarmalDoku: DNA sarmalını andıran, noktalarla çizilmiş iki kol ve aralarında basamaklar."""
    c = np.asarray(c, float)
    u, v = birim(aci), perp(birim(aci))
    f = R.uniform(2.2, 3.4)
    kol = lambda t, fz: c + (t - 0.5) * L * u + A * np.sin(2 * np.pi * f * t + fz) * v
    r1, r2 = r12
    for i in range(161):
        if i % 2 == 0 and R.uniform() < 0.9:
            t, on = i / 160, np.cos(2 * np.pi * f * i / 160)
            g.disk(kol(t, 0.0), 0.0026 * (1.2 + 0.5 * on), r2 if i % 4 == 0 else r1, 0.9)
            g.disk(kol(t, np.pi), 0.0026 * (1.2 - 0.5 * on), r1 if i % 4 == 0 else r2, 0.9)
    for i in range(9, 160, 9):
        p1, p2 = kol(i / 160, 0.0), kol(i / 160, np.pi)
        a0, a1 = R.uniform(0.12, 0.25), R.uniform(0.75, 0.88)
        g.cizgi([p1 + a0 * (p2 - p1), p1 + a1 * (p2 - p1)], basamak[R.integers(len(basamak))], 0.85,
                R.uniform(1.2, 2.2), uc="butt")


def sivri_yildiz(g, c, s, k, renk, cekirdek):
    """k kollu sivri yıldız: kollar dönüşümlü uzun/kısa ince üçgenler, ortada parlak çekirdek."""
    c = np.asarray(c, float)
    r0 = R.uniform(0, 2 * np.pi)
    for j in range(k):
        a = r0 + 2 * np.pi * j / k + R.normal(0, 0.08)
        ln = s * (1.0 if j % 2 == 0 else 0.55) * R.uniform(0.8, 1.1)
        u, nv = birim(a), 0.07 * s * perp(birim(a))
        g.cokgen([c + nv, c + ln * u, c - nv], renk, 0.85)
    g.disk(c, 0.12 * s, cekirdek, 0.9)


def aynala(flip):
    return lambda p: np.column_stack([1 - p[..., 0] if flip else p[..., 0], phi - p[..., 1]]).reshape(np.shape(p))


# =====================================================================================
# 10. Mod 1 — Işık Kafesi  (isikKafesi)
# =====================================================================================

kafes_onizleme = {"yogunluk": 0.35, "px": 600}
kafes_hq = {"yogunluk": 1.4, "px": 3000}


def isik_kafesi(tohum=7, palet="NeonGece", yogunluk=1.0, kilavuz=False):
    seed_random(tohum)
    pal = palettes[palet]
    pc = lambda t: pal_color(pal, t)
    koyu, kobalt, mavi, turkuaz, macenta, pembe, turuncu, sari, altin = [pc(t) for t in np.arange(9) / 8]
    kemik = [kobalt, mavi, turkuaz]
    hale = [sari, macenta]

    # altın yapı dikeyde (ve tohuma göre yatayda) aynalanır: kutup göğüs hizasına çıkar
    gc = golden_construction(14)
    flip = R.uniform() < 0.5
    ayna = aynala(flip)
    sp = ayna(gc["Spiral"])
    pole = ayna(gc["Pole"])

    vc = [pole, sp[60], sp[200]]
    vs = [1.0, 1 / phi, 1 / phi ** 2]
    vd = [1.0, -1.0, 1.0]
    ph = R.uniform(0, 2 * np.pi, 3)
    cph = R.uniform(0, 2 * np.pi, 3)

    # renk alanı: kütlelerin ~%30'u lacivert-kobalt, geri kalanı macenta → kırmızı → turuncu
    def ton(p, e=0.0):
        p = np.asarray(p, float)
        x, y = p[..., 0], p[..., 1]
        v = np.sin(2.1 * x + cph[0]) * np.cos(1.9 * y + cph[1]) + 0.5 * np.sin(3.3 * (x - y) + cph[2])
        v = np.clip((np.tanh(1.6 * v) + 1) / 2 + e, 0, 1)
        return np.where(v < 0.3, 0.02 + 0.13 * v / 0.3, 0.5 + 0.3 * (v - 0.3) / 0.7)

    # köşelere doğru kararma
    def karart(p):
        p = np.asarray(p, float)
        return 1.1 - 0.65 * (((p[..., 0] - 0.5) / 0.5) ** 2 + ((p[..., 1] - phi / 2) / (phi / 2)) ** 2) / 2

    cnt = lambda n: max(10, round(n * yogunluk))
    g = Cizim(darker(koyu, 0.2), tohum=tohum)

    def akis_katmani(seeds, steps, dt, w12, alpha, jitter):
        S = trace_strokes(seeds, vc, vs, vd, 1.0, ph, steps, dt)
        n = len(seeds)
        renk = scale_color(pc(ton(seeds, nz(n, jitter))), karart(seeds) * R.uniform(0.85, 1.15, n))
        gen = R.uniform(*w12, n)
        for i in range(n):
            g.cizgi(S[i], renk[i], alpha, gen[i])

    # omurga ekseni: kutuptan geçen hafif S eğrisi
    A = R.choice([-1, 1]) * R.uniform(0.025, 0.045)
    omurga_x = lambda y: pole[0] + A * np.sin(2 * np.pi * (y - pole[1]) / 2.0)

    # 1) zemin
    for _ in range(80):
        c = np.array([R.uniform(), R.uniform(0, phi)])
        g.disk(c, R.uniform(0.06, 0.3), scale_color(pc(ton(c, R.normal(0, 0.1))), karart(c)), 0.28)

    # 2) geniş akış darbeleri  3) ince damarlar
    akis_katmani(seeds_in(cnt(1100)), 18, 0.014, (8, 20), 0.3, 0.08)
    akis_katmani(seeds_in(cnt(1500)), 30, 0.006, (0.6, 2.2), 0.55, 0.12)

    # 4) birkaç kalın sıcak darbe: koyu gölge + üst üste üç saydam kat
    starts = sp[R.choice(700, 6, replace=False)] + nz((6, 2), 0.2)
    S = trace_strokes(starts, vc, vs, vd, 1.0, ph, 70, 0.009)
    for k in range(len(S)):
        t = ton(starts[k], 0.25)
        w = R.uniform(18, 32)
        g.cizgi(S[k], scale_color(pc(t), 0.6), 0.35, w + 6)
        for i in range(3):
            g.cizgi(S[k] + nz((len(S[k]), 2), 0.002), pc(t + 0.06 * i), 0.4, w * (1 - 0.3 * i))

    # 5) kısa çizgili doku
    for yol in trace_strokes(seeds_in(cnt(700)), vc, vs, vd, 1.0, ph, 4, 0.009):
        g.cizgi(yol, pc(R.choice([0.62, 0.66, 0.86, 0.9])), 0.75, R.uniform(1.2, 3.5))

    # 6) sarmal dokular: altın bölüm kesişimlerinden kafesten ve omurgadan uzak olan 2-3 tanesi
    aday = [np.array([x, y]) for x in [0.236, 0.382, 0.618, 0.764]
            for y in phi * np.array([0.146, 0.236, 0.382, 0.618, 0.854])]
    aday = [p for p in aday if np.linalg.norm(p - pole) > 0.45 and abs(p[0] - omurga_x(p[1])) > 0.2]
    secilen = []
    for i in R.permutation(len(aday)):
        if all(np.linalg.norm(aday[i] - q) > 0.4 for q in secilen):
            secilen.append(aday[i])
    for c in secilen[:R.integers(2, 4)]:
        sarmal_doku(g, c, np.pi / 2 + R.choice([-1, 1]) * R.uniform(0.25, 1.3), R.uniform(0.3, 0.48),
                    R.uniform(0.025, 0.04), (pembe, sari), [pembe, sari, macenta])

    # 7) köşelerde 4-8 kollu sivri yıldızlar; boyutları φ'nin kuvvetleri
    for _ in range(14):
        k = [(0, 0), (1, 0), (0, 1), (1, 1)][R.integers(4)]
        c = (abs(k[0] - R.uniform(0.02, 0.3)), phi * abs(k[1] - R.uniform(0.01, 0.2)))
        sivri_yildiz(g, c, 0.075 / phi ** R.integers(0, 4), R.integers(4, 9), pc(R.uniform(0.85, 1.0)), altin)

    # 8) omurlar: aşağıdan yukarıya, her adımda boyut q = φ^(-1/8) ile çarpılır
    n_omur, q = 20, phi ** (-1 / 8)
    y_alt, y_ust = -0.03, min(phi - 0.03, pole[1] + 0.42)
    h0 = (y_ust - y_alt) * (1 - q) / (1 - q ** n_omur)
    omur_h = h0 * q ** np.arange(n_omur)
    omur_y = y_alt + np.cumsum(omur_h) - omur_h / 2
    tt = np.linspace(0, 2 * np.pi, 41)
    for yc, h in zip(omur_y, omur_h):
        a, b = 0.62 * h, 0.34 * h
        xc = omurga_x(yc)
        eg = (omurga_x(yc + 0.001) - omurga_x(yc - 0.001)) / 0.002
        ux = np.array([1.0, -eg]) / np.hypot(1.0, eg)
        vy = perp(ux)
        m0 = np.array([xc, yc])
        govde = (m0 + (a * np.sign(np.cos(tt)) * np.abs(np.cos(tt)) ** 0.6)[:, None] * ux
                 + (b * np.sign(np.sin(tt)) * np.abs(np.sin(tt)) ** 0.6)[:, None] * vy)
        g.cokgen(govde, kobalt, 0.75)
        titrek_firca(g, govde, kemik, 3 + 30 * h, hale)
        for sg in (-1, 1):
            titrek_firca(g, dogru_parca(m0 + sg * 0.75 * a * ux + 0.1 * h * vy,
                                        m0 + sg * (a + 0.45 * h) * ux + 0.25 * h * vy),
                         kemik, 2 + 22 * h, hale)

    # 9) kaburgalar: kutbun iki yanına simetrik çiftler; aralık ve uzunluk φ kuvvetleriyle
    m, w_max, d0 = 4, 0.29, 0.15
    acc = np.cumsum(d0 * phi ** (-(np.arange(1, m + 1) - 0.5) / 2))
    kaburga_y = pole[1] + np.concatenate([-acc[::-1], [0.0], acc])
    kaburga_w = w_max * phi ** (-np.abs(np.arange(-m, m + 1)) / 2)
    th = np.linspace(0.5 * np.pi, -np.pi / 6, 61)
    for y0, w in zip(kaburga_y, kaburga_w):
        x0, dd = omurga_x(y0), 0.7 * w
        for sg in (-1, 1):
            titrek_firca(g, np.column_stack([x0 + sg * (0.012 + w * np.cos(th)), y0 - dd + dd * np.sin(th)]),
                         kemik + [altin], 6 + 14 * w / w_max, hale)

    # 10) göğüs kemiği
    yt = kaburga_y[-1] + 0.01
    yb = kaburga_y[m - 1] - 0.7 * kaburga_w[m - 1]
    titrek_firca(g, dogru_parca((omurga_x(yt), yt), (omurga_x(yb), yb), 20), kemik, 14, hale)

    # 11) ışık patlaması — kafesin ÖNÜNDE; ışın açıları altın açının katları
    for k in range(60):
        a = k * golden_angle + R.normal(0, 0.04)
        ln = R.uniform(0.12, 0.5) * (1.4 if k % 5 == 0 else 1.0)
        w0 = R.uniform(0.005, 0.018)
        u, nv = birim(a), w0 * perp(birim(a))
        g.cokgen([pole + nv, pole + ln * u, pole - nv], pc(R.uniform(0.82, 1.0)), 0.45)
        g.cokgen([pole + 0.3 * nv, pole + 0.85 * ln * u, pole - 0.3 * nv], altin, 0.7)
    for _ in range(12):
        a = R.uniform(0, 2 * np.pi)
        titrek_firca(g, dogru_parca(pole + 0.03 * birim(a), pole + R.uniform(0.15, 0.38) * birim(a)),
                     [sari, altin, BEYAZ], R.uniform(4, 9))
    for rad, op in [(0.16, 0.12), (0.09, 0.25), (0.045, 0.6), (0.02, 0.95)]:
        g.disk(pole, rad, altin, op)

    if kilavuz:
        for qd in gc["Squares"]:
            g.cizgi(kare_cizgisi(qd, ayna), BEYAZ, 0.8, 0.8)
        g.cizgi(sp, BEYAZ, 0.8, 0.8)
        g.disk(pole, 0.006, (1, 0, 0), 1.0)
    return g


# =====================================================================================
# 11. Mod 2 — Eriyen Maskeler  (eriyenMaskeler) ve smear
# =====================================================================================

def smear(img, amp=4.0, blur=6, tohum=None):
    """Yağlıboya sürüntüsü: düşük frekanslı gürültüyle piksel kaydırma + dikey hareket bulanıklığı."""
    rng = np.random.default_rng(tohum)
    a = np.asarray(img, float)
    h, w = a.shape[:2]
    k = w / 600.0
    # 5 × 8'lik rastgele ızgara görüntü boyutuna büyütülür, değerler −1…1
    alan = lambda: 2 * resize(rng.uniform(0, 1, (8, 5)), (h, w), order=3, mode="edge", anti_aliasing=False) - 1
    dx, dy = amp * k * alan(), amp * k * alan()
    ii, jj = np.indices((h, w))
    si = np.clip(np.rint(ii + dy), 0, h - 1).astype(int)
    sj = np.clip(np.rint(jj + dx), 0, w - 1).astype(int)
    a = a[si, sj]
    n = max(1, round(blur * k))
    ker = np.exp(-(np.arange(-n, n + 1) / (0.5 * n)) ** 2)
    b = convolve1d(a, ker / ker.sum(), axis=0, mode="nearest")
    return np.clip(0.45 * a + 0.55 * b, 0, 1)


maske_onizleme = {"yogunluk": 0.35, "px": 600}
maske_hq = {"yogunluk": 1.4, "px": 3000}


def rot_matris(a):
    return np.array([[np.cos(a), -np.sin(a)], [np.sin(a), np.cos(a)]])


def eriyen_maskeler(tohum=5, palet="PastelRuh", yogunluk=1.0, kilavuz=False):
    seed_random(tohum)
    pal = palettes[palet]
    pc = lambda t: pal_color(pal, t)
    koyu, lila, pembe, seftali, sari, yesil, turkuaz = [pc(t) for t in np.arange(7) / 6]
    mavi_goz = hex_renk("#4f86ff")

    gc = golden_construction(14)
    flip = R.uniform() < 0.5
    ayna = aynala(flip)
    sp = ayna(gc["Spiral"])
    pole = ayna(gc["Pole"])

    # zemin girdapları kenarların altın bölüm noktalarında; güçler φ'nin kuvvetleri, yönler dönüşümlü
    vc = ayna(np.array([[0.0, 0.382 * phi], [1.0, 0.618 * phi], [0.618, 0.0], [0.382, phi]]))
    vs = 1.0 / phi ** np.arange(4)
    vd = [1.0, -1.0, 1.0, -1.0]
    ph = R.uniform(0, 2 * np.pi, 3)
    cph = R.uniform(0, 2 * np.pi, 3)

    def ton(p, e=0.0):
        p = np.asarray(p, float)
        x, y = p[..., 0], p[..., 1]
        v = np.sin(1.7 * x + cph[0]) * np.cos(1.3 * y + cph[1]) + 0.5 * np.sin(2.6 * (x + y) + cph[2])
        return 1 / 6 + 0.5 * np.clip((np.tanh(1.4 * v) + 1) / 2 + e, 0, 1)

    def kenar(p):
        p = np.asarray(p, float)
        x, y = p[..., 0], p[..., 1]
        return np.clip(1.15 * np.exp(-np.minimum.reduce([x, 1 - x, y, phi - y]) / 0.08), 0, 0.95)

    def renk(p, e=0.0):
        k = np.asarray(kenar(p))[..., None]
        return pc(ton(p, e)) * (1 - k) + koyu * k

    cnt = lambda n: max(10, round(n * yogunluk))
    g = Cizim(pembe, tohum=tohum)

    def sis_katmani(seeds, steps, dt, w12, alpha, jitter):
        S = trace_strokes(seeds, vc, vs, vd, 0.8, ph, steps, dt)
        n = len(seeds)
        rk = renk(seeds, nz(n, jitter))
        gen = R.uniform(*w12, n)
        for i in range(n):
            g.cizgi(S[i], rk[i], alpha, gen[i])

    # 1) zemin lekeleri  2) sis
    for _ in range(110):
        c = np.array([R.uniform(), R.uniform(0, phi)])
        g.disk(c, R.uniform(0.08, 0.32), renk(c, R.normal(0, 0.1)), 0.25)
    for _ in range(40):
        col = blend([[pembe, sari, lila][R.integers(3)], BEYAZ], 0.4)
        g.disk((R.uniform(), R.uniform(0, phi)), R.uniform(0.15, 0.4), col, 0.08)

    # 3) geniş sürülmüş darbeler  4) orta kalınlıkta darbeler
    sis_katmani(seeds_in(cnt(1000)), 20, 0.013, (12, 30), 0.22, 0.08)
    sis_katmani(seeds_in(cnt(1300)), 26, 0.008, (4, 10), 0.3, 0.1)

    # 5) maske merkezleri: en büyüğü kutupta, diğerleri spiral üzerinde; yarıçap her maskede φ'ye bölünür
    r0 = 0.21 / phi ** np.arange(R.integers(3, 6))
    merkezler = [pole]
    for k in range(1, len(r0)):
        aday = [p for p in sp[::8]
                if all(np.linalg.norm(p - merkezler[i]) > 0.85 * (r0[i] + r0[k]) for i in range(len(merkezler)))
                and r0[k] < p[0] < 1 - r0[k] and 0.3 < p[1] < phi - 1.1 * r0[k]]
        if not aday:
            break
        merkezler.append(aday[R.integers(len(aday))])
    n_maske = len(merkezler)
    r0 = r0[:n_maske]
    koyu_maske = R.integers(2, min(3, n_maske) + 1) - 1 if n_maske >= 2 else -1   # koyu mor, tek mavi gözlü

    def maske(k):
        c, r, koyu_mu = merkezler[k], r0[k], k == koyu_maske
        rot = rot_matris(R.uniform(-0.25, 0.25))
        loc = lambda uv: c + np.asarray(uv, float) @ rot.T
        a = R.uniform(0.03, 0.12, 4) / np.array([1.0, 1.3, 1.7, 2.2])
        fz = R.uniform(0, 2 * np.pi, 4)
        sh = R.uniform(-0.2, 0.2)
        th = np.linspace(0, 2 * np.pi, 73)

        # r(θ) = r0 (1 + Σ a_k Sin[kθ + φ_k]); alt yarı uzatılır, genişlik daraltılır
        def sekil(s):
            rr = s * r * (1 + (a[:, None] * np.sin(np.arange(2, 6)[:, None] * th + fz[:, None])).sum(0))
            yv = (1.12 - 0.28 * np.sin(th)) * np.sin(th)
            return loc(rr[:, None] * np.column_stack([0.82 * np.cos(th) + sh * yv, yv]))

        govde = blend([koyu, lila], 0.15) if koyu_mu else pc(R.uniform(5 / 6, 1.0))
        isik = blend([govde, lila if koyu_mu else sari], 0.45)
        parilti = lila if koyu_mu else govde
        damla_rengi = lambda: (blend([koyu, lila], R.uniform(0, 0.3)) if koyu_mu
                               else blend([yesil, turkuaz], R.uniform()))

        # erime: alt kenardan başlayan damlalar; akış payı en çok %30, gerisi aşağı iniş
        s09 = sekil(0.9)[:-1]
        alt = s09[np.sin(th[:-1]) < -0.25]
        bas = alt[R.integers(0, len(alt), round(4 + 50 * r))]
        bas = bas + np.column_stack([nz(len(bas), 0.05 * r), np.zeros(len(bas))])
        S = trace_strokes(bas, vc, vs, vd, 0.8, ph, 40, 0.004)
        damlalar = []
        for i in range(len(bas)):
            L = max(0.05, min(bas[i, 1] - 0.02, r * R.uniform(0.5, 3.2)))
            w = R.uniform(0.08, 0.2) * r / 0.0015
            dr = damla_rengi()
            yol = bas[i] + min(0.3, 1.4 * r) * (S[i] - bas[i])
            yol = yol + np.column_stack([np.zeros(40), -L * np.linspace(0, 1, 40)])
            damlalar.append((yol, w, dr))

        def yarik(mm, ax_ay, ang, col):
            t = np.linspace(0, 2 * np.pi, 31)
            e = np.column_stack([ax_ay[0] * np.cos(t), ax_ay[1] * np.sin(t)]) @ rot_matris(ang).T
            for so, op in [(1.7, 0.2), (1.0, 0.85)]:
                g.cokgen(loc(np.asarray(mm) + so * e), col, op)

        # arka: hayalet parıltısı ve damla sürüntüleri
        g.cokgen(sekil(1.3), parilti, 0.1)
        g.cokgen(sekil(1.12), parilti, 0.16)
        for yol, w, dr in damlalar:
            g.cizgi(yol, dr, 0.12, 2.4 * w)
        # gövde: dolgu + iç içe, yumuşak sürülmüş halkalar
        g.cokgen(sekil(1.0), govde, 0.7)
        for s in (0.92, 0.72, 0.52, 0.32):
            titrek_firca(g, sekil(s), [blend([govde, koyu], 0.2), govde, blend([govde, isik], 1 - s)], 150 * r)
        # önde: yukarıda kalın, aşağı doğru incelen damla ve uçta damlacık
        for yol, w, dr in damlalar:
            g.cizgi(yol[:26], dr, 0.4, w)
            g.cizgi(yol[:36], dr, 0.45, 0.65 * w)
            g.cizgi(yol, blend([dr, sari], 0.3), 0.45, 0.3 * w)
            g.disk(yol[-1], 0.0015 * 0.4 * w, dr, 0.55)

        # gözler
        if koyu_mu:
            mm = np.array([R.choice([-1, 1]) * 0.3 * r, 0.14 * r])
            yarik(mm, (0.13 * r, 0.08 * r), R.uniform(-0.3, 0.3), mavi_goz)
            g.disk(loc(mm + np.array([0.03 * r, 0.025 * r])), 0.018 * r, BEYAZ, 0.7)
        else:
            al = R.choice([-1, 1]) * R.uniform(0.1, 0.4)
            for sg in (-1, 1):
                yarik((sg * 0.32 * r + R.normal(0, 0.04 * r), 0.14 * r + R.normal(0, 0.04 * r)),
                      (0.2 * r * R.uniform(0.8, 1.2), 0.04 * r * R.uniform(0.7, 1.4)),
                      sg * al + R.normal(0, 0.12), koyu)

        # ağız: kısa kalın fırça yayı ya da geniş, ince yarık
        my, mx = -R.uniform(0.36, 0.48) * r, R.normal(0, 0.05 * r)
        egri, eg = R.uniform(-0.1, 0.1) * r, R.uniform(-0.15, 0.15)
        col = blend([koyu, SIYAH], 0.5) if koyu_mu else koyu
        if R.uniform() < 0.5:
            u = np.linspace(-1, 1, 25)
            titrek_firca(g, loc(np.column_stack([mx + 0.26 * r * u, my + egri * u ** 2 + eg * 0.26 * r * u])),
                         [col, col, blend([col, lila], 0.3)], 0.07 * r / 0.0015)
        else:
            yarik((mx, my), (0.27 * r, 0.045 * r), eg, col)

    # küçükten büyüğe: en büyük maske (kutuptaki) en önde
    for k in reversed(range(n_maske)):
        maske(k)

    # 6) her şeyin üstünde ince bir sis
    for _ in range(18):
        g.disk((R.uniform(), R.uniform(0, phi)), R.uniform(0.2, 0.45), blend([pembe, BEYAZ], 0.5), 0.05)

    if kilavuz:
        for qd in gc["Squares"]:
            g.cizgi(kare_cizgisi(qd, ayna), BEYAZ, 0.8, 0.8)
        g.cizgi(sp, BEYAZ, 0.8, 0.8)
        for c, r in zip(merkezler, r0):
            g.cember(c, r, BEYAZ, 0.8, 0.8, kesikli=(0.01, 0.01))
        g.disk(pole, 0.006, (1, 0, 0), 1.0)
    return g
