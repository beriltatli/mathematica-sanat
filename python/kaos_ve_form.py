"""Kaos ve Form — kaos_ve_form.wl dosyasının Python karşılığı.

  1. Clifford çekicisi  → attractor_art (numba ile derlenmiş yineleme)
  2. Karmaşık düzlem    → art4 (alan renklendirmesi; ComplexPlot "CyclicLogAbsArg" yaklaşımı)
  3. Gyroid küre        → art5 (pyvista / VTK ile 3B yüzey)
  6. Animasyonlar       → gyroid_frame, clifford_frame, complex_frame ve loop_phases

Her fonksiyon 0…1 aralığında RGB dizisi (yükseklik, genişlik, 3) döndürür.
"""

import math

import numpy as np
from numba import njit

# =====================================================================================
# 1. Clifford çekicisi — yoğunluk haritası
# =====================================================================================


@njit(cache=True)
def clifford_points(a, b, c, d, n):
    xs = np.empty(n)
    ys = np.empty(n)
    x, y = 0.1, 0.1
    for i in range(n):
        xn = math.sin(a * y) + c * math.cos(a * x)
        y = math.sin(b * x) + d * math.cos(b * y)
        x = xn
        xs[i] = x
        ys[i] = y
    return xs, ys


def _gecis(*renkler):
    """Blend[{...}, t] karşılığı: eşit aralıklı renkler arasında doğrusal geçiş."""
    r = np.asarray(renkler, float)

    def f(t):
        t = np.clip(np.asarray(t, float), 0, 1)
        k = len(r) - 1
        x = t * k
        i = np.minimum(np.floor(x).astype(int), k - 1)
        w = (x - i)[..., None]
        return r[i] * (1 - w) + r[i + 1] * w
    return f


# Özel renk geçişleri: siyahtan başlamaları önemli, böylece boşluk karanlık kalır
gradients = {
    "Ateş": _gecis((0, 0, 0), (0.35, 0, 0.25), (0.9, 0.25, 0.1), (1, 0.8, 0.3), (1, 1, 1)),
    "Okyanus": _gecis((0, 0, 0), (0, 0.1, 0.3), (0, 0.55, 0.7), (0.6, 1, 0.95), (1, 1, 1)),
    "Aurora": _gecis((0, 0, 0), (0.1, 0, 0.3), (0.3, 0.2, 0.9), (0.2, 0.95, 0.6), (1, 1, 1)),
    # ColorData["SunsetColors"] yaklaşığı
    "Gün batımı": _gecis((0, 0, 0), (0.33, 0.12, 0.47), (0.82, 0.26, 0.29), (0.99, 0.55, 0.15),
                         (1, 0.87, 0.45), (1, 1, 1)),
}


def attractor_art(params, n=3_000_000, res=1000, grad="Ateş", gamma=0.55):
    a, b, c, d = map(float, params)
    xs, ys = clifford_points(a, b, c, d, int(n))
    xr, yr = 1.0 + abs(c), 1.0 + abs(d)
    counts, _, _ = np.histogram2d(xs, ys, bins=res, range=[[-xr, xr], [-yr, yr]])
    m = np.log1p(counts)
    m = (m / m.max()) ** gamma               # gamma < 1 → daha parlak, "ışıldayan" görünüm
    return gradients[grad](m.T[::-1])       # Reverse@Transpose: y yukarı


def art1():
    return attractor_art((-1.4, 1.6, 1.0, 0.7), 3_000_000, 1000, "Ateş")


def art2():
    return attractor_art((1.7, 1.7, 0.6, 1.2), 3_000_000, 1000, "Okyanus")


def art3():
    return attractor_art((-1.7, 1.3, -0.1, -1.2), 3_000_000, 1000, "Aurora")


# =====================================================================================
# 2. Karmaşık düzlem — alan renklendirmesi
# =====================================================================================


def art4_fn(w):
    return (w ** 5 - 1) / (w ** 2 + 0.3j) + np.sin(1 / w)


def cyclic_log_abs_arg(F):
    """Ton = argüman; parlaklık log|f| ve argümanın döngüsel bantlarıyla gölgelenir.
    Bant genişlikleri eşit (2π/12) seçildi: hücreler konform kareler gibi görünür."""
    from matplotlib.colors import hsv_to_rgb
    P = 2 * np.pi / 12
    ang = np.angle(F)
    la = np.log(np.abs(F) + 1e-300)
    s_abs = np.mod(la / P, 1.0)
    s_arg = np.mod(ang / P, 1.0)
    hue = np.mod(ang / (2 * np.pi), 1.0)
    sat = 0.55 + 0.4 * (1 - 0.6 * s_abs)
    val = (0.5 + 0.5 * s_abs) * (0.8 + 0.2 * s_arg)
    rgb = hsv_to_rgb(np.stack([hue, np.clip(sat, 0, 1), np.clip(val, 0, 1)], -1))
    rgb[~np.isfinite(F)] = 1.0
    return rgb


def complex_plot(f, boyut=800, ss=3, aralik=2.0):
    """f'yi {-aralik-aralik i, aralik+aralik i} karesinde boyut×boyut piksele çizer.
    ss×ss alt örnekleme, sin(1/z)'nin sıfır çevresindeki ince ayrıntısını yumuşatır."""
    n = boyut * ss
    t = (np.arange(n) + 0.5) / n * 2 * aralik - aralik
    Z = t[None, :] + 1j * t[::-1, None]
    with np.errstate(all="ignore"):
        rgb = cyclic_log_abs_arg(f(Z))
    return rgb.reshape(boyut, ss, boyut, ss, 3).mean((1, 3))


def art4(boyut=800):
    return complex_plot(art4_fn, boyut)


# =====================================================================================
# 3. Gyroid küre — 3B örtük yüzey
# =====================================================================================

L = 2 * np.pi
_GYROID_RENK = _gecis((1, 0.85, 0.4), (0.95, 0.3, 0.35), (0.3, 0.15, 0.6))


def gyroid_mesh(t=0.0, n=120):
    """sin x cos y + sin y cos z + sin z cos x = t yüzeyi, 2π yarıçaplı küreyle kırpılmış."""
    import pyvista as pv
    s = 2 * L / (n - 1)
    g = pv.ImageData(dimensions=(n, n, n), spacing=(s, s, s), origin=(-L, -L, -L))
    x, y, z = g.points.T
    g["f"] = np.sin(x) * np.cos(y) + np.sin(y) * np.cos(z) + np.sin(z) * np.cos(x)
    surf = g.contour([t], scalars="f")
    surf["r"] = np.linalg.norm(surf.points, axis=1)
    surf = surf.clip_scalar(scalars="r", value=L, invert=True)
    # ColorFunctionScaling: koordinatlar 0…1'e ölçeklenir, merkezden uzaklık / 0.87 renge çevrilir
    surf["renk"] = _GYROID_RENK(np.linalg.norm(surf.points, axis=1) / (2 * L) / 0.87)
    return surf


def gyroid_resim(surf, boyut, goz, kure_sigdir=False):
    import pyvista as pv
    pl = pv.Plotter(off_screen=True, window_size=(boyut, boyut), lighting="none")
    pl.background_color = "black"
    # tek ana ışık (kameraya göre sol üstten): VTK'nın 5 ışıklı düzeni gyroidin her tümseğinde
    # ayrı bir parlama lekesi bırakıyordu. Specularity[White, 30] → specular_power 30.
    pl.add_light(pv.Light(position=(-1, 1, 1), focal_point=(0, 0, 0), intensity=0.9, light_type="camera light"))
    pl.add_mesh(surf, scalars="renk", rgb=True, smooth_shading=True,
                ambient=0.22, diffuse=0.8, specular=0.3, specular_power=30)
    goz = np.asarray(goz, float)
    if kure_sigdir:
        # SphericalRegion: kutunun çevrel küresi kareye sığar → döndürürken görüntü zıplamaz
        R = L * np.sqrt(3)
        dist = R / np.sin(np.radians(pl.camera.view_angle / 2))
        pl.camera_position = [tuple(goz / np.linalg.norm(goz) * dist), (0, 0, 0), (0, 0, 1)]
    else:
        pl.camera_position = [tuple(goz * 10), (0, 0, 0), (0, 0, 1)]
        pl.reset_camera()
        pl.camera.zoom(1.45)        # reset_camera çevrel küreye boşluk bırakır; Mathematica kutuyu sığdırır
    img = pl.screenshot(return_img=True)
    pl.close()
    return img.astype(float) / 255.0


def art5(boyut=800):
    return gyroid_resim(gyroid_mesh(0.0, 120), boyut, (2.2, -1.6, 1.4))


# =====================================================================================
# 6. Animasyonlar
# =====================================================================================

def ease(s):
    """Kolaylaştırma eğrisi: 0'dan 1'e yavaş başlayıp yavaş biter."""
    return (1 - np.cos(np.pi * s)) / 2


def loop_phases(n):
    """Döngünün n karesi: 0, 1/n, …, (n−1)/n. s = 1 yazılmaz çünkü s = 0 ile aynı karedir."""
    return np.arange(n) / n


anim_preview = {"Kare": 60, "Boyut": 600, "AnimationRate": 20}
anim_hq = {"Kare": 120, "Boyut": 1080, "FrameRate": 30, "GyroidPlotPoints": 60,
           "CliffordNokta": 2_000_000, "CliffordRes": 1080, "ComplexSS": 3}


def anim_frame(img, size=600):
    """Kareyi sabit boyutlu, kare biçimli resme çevirir (MP4 çift sayıda piksel ister)."""
    from skimage.transform import resize
    if img.shape[:2] == (size, size):
        return img
    return np.clip(resize(img, (size, size), order=1, anti_aliasing=True), 0, 1)


# 6.1 Nefes alan gyroid: t = 0.8 sin(2π s); kamera aynı yükseklikte tam tur döner
def gyroid_frame(s, size=600, pp=40):
    t = 0.8 * np.sin(2 * np.pi * s)
    r = np.hypot(2.2, -1.6)
    th = np.arctan2(-1.6, 2.2) + 2 * np.pi * s
    return gyroid_resim(gyroid_mesh(t, 2 * pp), size, (r * np.cos(th), r * np.sin(th), 1.4), kure_sigdir=True)


# 6.2 Dönüşen Clifford çekicisi: art1 → art2 → art1, ease ile yumuşatılmış
clifford_from = np.array([-1.4, 1.6, 1.0, 0.7])
clifford_to = np.array([1.7, 1.7, 0.6, 1.2])


def clifford_frame(s, n=800_000, res=600, grad="Ateş"):
    w = ease(1 - abs(1 - 2 * s))
    return attractor_art((1 - w) * clifford_from + w * clifford_to, n, res, grad)


# 6.3 Dönen karmaşık düzlem: z yerine z e^{it}
def complex_frame(t, size=600, ss=2):
    rot = np.exp(1j * t)
    return complex_plot(lambda z: art4_fn(z * rot), size, ss)
