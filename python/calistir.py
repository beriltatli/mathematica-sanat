"""calistir.wls karşılığı: üç modun örnek çıktılarını ciktilar/ klasörüne PNG olarak yazar.

Kullanım (proje klasöründen):  .venv/bin/python python/calistir.py
"""

import time
from pathlib import Path

from ruh_katmanlari import (ruh_katmanlari, isik_kafesi, eriyen_maskeler, finish, smear,
                            kafes_onizleme, maske_onizleme)
from tuval import kaydet

cikti = Path(__file__).resolve().parent.parent / "ciktilar"
cikti.mkdir(exist_ok=True)


def yaz(ad, img):
    yol = cikti / f"{ad}.png"
    kaydet(yol, img)
    print("  yazıldı:", yol)


baslangic = time.time()
ky, kp = kafes_onizleme["yogunluk"], kafes_onizleme["px"]
my, mp = maske_onizleme["yogunluk"], maske_onizleme["px"]

print("Ruh Katmanları")
yaz("eser1_toprak_11", finish(ruh_katmanlari(11, "Toprak")))
yaz("eser2_hayalet_4", finish(ruh_katmanlari(4, "Hayalet")))
yaz("eser3_kozmik_23", finish(ruh_katmanlari(23, "Kozmik")))
yaz("eser_kilavuz_23", finish(ruh_katmanlari(23, "Kozmik", 1.0, 0.5, True), 600))

print("Işık Kafesi")
yaz("kafes1_7", finish(isik_kafesi(7, "NeonGece", ky), kp, 0.4))
yaz("kafes2_40", finish(isik_kafesi(40, "NeonGece", ky), kp, 0.4))
yaz("kafes_kilavuz_7", isik_kafesi(7, "NeonGece", ky, True).resim(600))

print("Eriyen Maskeler")
yaz("maske1_5", smear(finish(eriyen_maskeler(5, "PastelRuh", my), mp, 0.2), tohum=5))
yaz("maske2_18", smear(finish(eriyen_maskeler(18, "PastelRuh", my), mp, 0.2), tohum=18))
yaz("maske_kilavuz_5", eriyen_maskeler(5, "PastelRuh", my, True).resim(600))

print(f"Bitti ({time.time() - baslangic:.0f} sn).")
