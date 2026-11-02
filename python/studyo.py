"""Ortak stüdyo — ruh_katmanlari.wl Bölüm 12'deki Manipulate'in karşılığı: üç mod tek pencerede.

Kullanım (proje klasöründen):  .venv/bin/python python/studyo.py

  mod       : Ruh Katmanları / Işık Kafesi / Eriyen Maskeler
  palet     : "Otomatik" ise modun kendi paleti (Kozmik / NeonGece / PastelRuh)
  girdap    : yalnız Ruh Katmanları'nı etkiler
  önizleme  : açıkken modun önizleme yoğunluğuyla, son işlemsiz hızlı çizim; kapalıyken tam yoğunluk
              + son işlem, 700 px
  Kaydet    : en son ayarları modun HQ yoğunluğuyla 3000 px genişlikte, kılavuzsuz olarak Masaüstüne yazar

Kaydırıcıyı bırakınca resim yeniden çizilir (Mathematica'daki ContinuousAction -> False gibi).
"""

import random
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.widgets import Button, CheckButtons, RadioButtons, Slider

import ruh_katmanlari as rk
from tuval import kaydet

# her mod için: varsayılan palet, önizleme/HQ yoğunluk çarpanı, dosya adı, çizim ve son işlem
modlar = {
    "Ruh Katmanları": dict(
        palet="Kozmik", onizleme=0.35, hq=1.4, dosya="ruh_katmanlari_",
        ciz=lambda t, p, g, y, k: rk.ruh_katmanlari(t, p, g, y, k),
        bitir=lambda c, px: rk.finish(c, px)),
    "Işık Kafesi": dict(
        palet="NeonGece", onizleme=rk.kafes_onizleme["yogunluk"], hq=rk.kafes_hq["yogunluk"], dosya="isik_kafesi_",
        ciz=lambda t, p, g, y, k: rk.isik_kafesi(t, p, y, k),
        bitir=lambda c, px: rk.finish(c, px, 0.4)),
    "Eriyen Maskeler": dict(
        palet="PastelRuh", onizleme=rk.maske_onizleme["yogunluk"], hq=rk.maske_hq["yogunluk"],
        dosya="eriyen_maskeler_",
        ciz=lambda t, p, g, y, k: rk.eriyen_maskeler(t, p, y, k),
        bitir=lambda c, px: rk.smear(rk.finish(c, px, 0.2), tohum=c.tohum)),
}


def mod_palet(mod, pal):
    return modlar[mod]["palet"] if pal == "Otomatik" else pal


def eser_ciz(mod, seed, pal, swirl, density, guide):
    return modlar[mod]["ciz"](int(seed), mod_palet(mod, pal), float(swirl), float(density), bool(guide))


def eser_bitir(mod, g, px):
    return modlar[mod]["bitir"](g, px)


class Studyo:
    def __init__(self):
        self.fig = fig = plt.figure(figsize=(11, 9.4))
        try:
            fig.canvas.manager.set_window_title("Ruh Katmanları — Stüdyo")
        except AttributeError:
            pass

        self.ax_img = fig.add_axes([0.35, 0.02, 0.63, 0.96])
        self.ax_img.axis("off")
        self.im = None

        def baslik(y, metin):
            fig.text(0.03, y, metin, fontsize=10, weight="bold")

        baslik(0.955, "mod")
        self.r_mod = RadioButtons(fig.add_axes([0.03, 0.835, 0.27, 0.115], frameon=False), list(modlar), active=0)
        self.s_tohum = Slider(fig.add_axes([0.10, 0.795, 0.17, 0.025]), "tohum", 1, 500, valinit=11, valstep=1)

        baslik(0.765, "palet")
        self.paletler = ["Otomatik"] + list(rk.palettes)
        self.r_pal = RadioButtons(fig.add_axes([0.03, 0.56, 0.27, 0.2], frameon=False), self.paletler, active=0)

        baslik(0.525, "girdap (Ruh Katmanları)")
        self.s_girdap = Slider(fig.add_axes([0.10, 0.49, 0.17, 0.025]), "girdap", 0.0, 2.5, valinit=1.0)
        self.s_yog = Slider(fig.add_axes([0.10, 0.45, 0.17, 0.025]), "yoğunluk", 0.3, 1.6, valinit=1.0)
        self.c_sec = CheckButtons(fig.add_axes([0.03, 0.34, 0.27, 0.09], frameon=False),
                                  ["altın oran kılavuzu", "önizleme"], [False, True])

        self.b_rast = Button(fig.add_axes([0.03, 0.27, 0.12, 0.045]), "Rastgele")
        self.b_kaydet = Button(fig.add_axes([0.16, 0.27, 0.14, 0.045]), "Kaydet (3000 px)")
        self.durum = fig.text(0.03, 0.22, "", fontsize=9, color="0.25", wrap=True)

        # Kaydırıcı sürüklenirken her olayda yeniden çizmemek için: son değişiklikten 300 ms sonra çiz
        self.zamanlayici = fig.canvas.new_timer(interval=300)
        self.zamanlayici.single_shot = True
        self.zamanlayici.add_callback(self.ciz)

        for w in (self.s_tohum, self.s_girdap, self.s_yog):
            w.on_changed(lambda _: self.degisti())
        for w in (self.r_mod, self.r_pal, self.c_sec):
            w.on_clicked(lambda _: self.degisti())
        self.b_rast.on_clicked(lambda _: self.s_tohum.set_val(random.randint(1, 500)))
        self.b_kaydet.on_clicked(lambda _: self.kaydet())

    # --- durum ---------------------------------------------------------------------------
    def ayarlar(self):
        kilavuz, onizleme = self.c_sec.get_status()
        return dict(mod=self.r_mod.value_selected, seed=int(self.s_tohum.val), pal=self.r_pal.value_selected,
                    swirl=self.s_girdap.val, density=self.s_yog.val, guide=kilavuz, preview=onizleme)

    def mesaj(self, metin):
        self.durum.set_text(metin)
        self.fig.canvas.draw()
        self.fig.canvas.flush_events()

    def degisti(self):
        self.zamanlayici.stop()
        self.zamanlayici.start()

    # --- çizim ---------------------------------------------------------------------------
    def ciz(self):
        a = self.ayarlar()
        mod = a["mod"]
        self.mesaj("çiziliyor…")
        if a["preview"]:
            img = eser_ciz(mod, a["seed"], a["pal"], a["swirl"], modlar[mod]["onizleme"] * a["density"],
                           a["guide"]).resim(600)
        else:
            img = eser_bitir(mod, eser_ciz(mod, a["seed"], a["pal"], a["swirl"], a["density"], a["guide"]), 700)
        if self.im is None:
            self.im = self.ax_img.imshow(img, extent=(0, 1, 0, rk.phi), interpolation="antialiased")
        else:
            self.im.set_data(img)
        self.mesaj(f"{mod} · {mod_palet(mod, a['pal'])} · tohum {a['seed']}")

    def kaydet(self):
        a = self.ayarlar()
        mod = a["mod"]
        yol = Path.home() / "Desktop" / f"{modlar[mod]['dosya']}{mod_palet(mod, a['pal'])}_{a['seed']}.png"
        self.mesaj("3000 px kaydediliyor (biraz sürebilir)…")
        g = eser_ciz(mod, a["seed"], a["pal"], a["swirl"], modlar[mod]["hq"] * a["density"], False)
        kaydet(yol, eser_bitir(mod, g, 3000))
        self.mesaj(f"kaydedildi:\n{yol}")


def main():
    st = Studyo()
    st.ciz()
    plt.show()
    return st


if __name__ == "__main__":
    main()
