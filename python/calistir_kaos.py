"""calistir_kaos.wls karşılığı: görselleri ve animasyon önizlemelerini ciktilar/kaos/ klasörüne yazar.

Kullanım (proje klasöründen):  .venv/bin/python python/calistir_kaos.py
"""

import time
from pathlib import Path

import numpy as np
from PIL import Image

import kaos_ve_form as kf
from tuval import kaydet

cikti = Path(__file__).resolve().parent.parent / "ciktilar" / "kaos"
cikti.mkdir(parents=True, exist_ok=True)


def yaz(ad, img):
    yol = cikti / ad
    kaydet(yol, img)
    print("  yazıldı:", yol)


def gif_yaz(ad, kareler):
    """Sonsuz döngülü GIF, notebook'taki hızda (AnimationRate kare/sn)."""
    yol = cikti / ad
    resimler = [Image.fromarray((np.clip(k, 0, 1) * 255 + 0.5).astype(np.uint8)) for k in kareler]
    resimler[0].save(yol, save_all=True, append_images=resimler[1:], loop=0,
                     duration=round(1000 / kf.anim_preview["AnimationRate"]), optimize=False)
    print("  yazıldı:", yol)


def kareler(ad, f):
    t = time.time()
    n, boyut = kf.anim_preview["Kare"], kf.anim_preview["Boyut"]
    sonuc = [kf.anim_frame(f(s), boyut) for s in kf.loop_phases(n)]
    print(f"  {ad}: {n} kare, {time.time() - t:.0f} sn")
    return sonuc


baslangic = time.time()
print("Görseller")
yaz("art1_clifford_ates.png", kf.art1())
yaz("art2_clifford_okyanus.png", kf.art2())
yaz("art3_clifford_aurora.png", kf.art3())
yaz("art4_karmasik_duzlem.png", kf.art4())
yaz("art5_gyroid.png", kf.art5())

print("Animasyon önizlemeleri")
gif_yaz("gyroid_nefes.gif", kareler("gyroid", lambda s: kf.gyroid_frame(s)))
gif_yaz("clifford_donusum.gif", kareler("clifford", lambda s: kf.clifford_frame(s)))
gif_yaz("karmasik_donus.gif", kareler("karmaşık", lambda s: kf.complex_frame(2 * np.pi * s)))

print(f"Bitti ({time.time() - baslangic:.0f} sn).")
