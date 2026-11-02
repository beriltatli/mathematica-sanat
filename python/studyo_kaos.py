"""Canlı stüdyo — kaos_ve_form.wl Bölüm 4'teki Manipulate'in karşılığı: Clifford çekicisi.

Kullanım (proje klasöründen):  .venv/bin/python python/studyo_kaos.py

Kaydırıcılarla çekicinin dört parametresini (a, b, c, d) değiştir. Sürüklerken düşük çözünürlükte hızlı
önizleme görürsün (150 000 nokta, 350 px), bırakınca tam kalitede çizilir (seçili nokta sayısı, 800 px) —
Mathematica'daki ControlActive gibi. "Rastgele" keşfetmek, "Kaydet (PNG)" 6 milyon noktalı 2000 px
resmi ev klasörüne yazmak için.
"""

import time
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Button, RadioButtons, Slider

import kaos_ve_form as kf
from tuval import kaydet

NOKTA_SECENEKLERI = [300_000, 1_000_000, 3_000_000]


def canli_mi(p):
    """Çekici birkaç noktaya çökmüş mü? 100 × 100 ızgarada en az 300 hücre dolu olmalı.
    (Kaotik çekiciler binlercesini doldurur; çöken periyodik yörüngeler bir avuç.)"""
    a, b, c, d = p
    xs, ys = kf.clifford_points(a, b, c, d, 21_000)
    h, _, _ = np.histogram2d(xs[1000:], ys[1000:], bins=100,
                             range=[[-1 - abs(c), 1 + abs(c)], [-1 - abs(d), 1 + abs(d)]])
    return (h > 0).sum() > 300


def canli_parametre(deneme=50):
    """Rastgele düğmesi: −2.5…2.5 aralığından, çökmemiş bir çekici verene kadar yeniden çeker."""
    for _ in range(deneme):
        p = np.random.uniform(-2.5, 2.5, 4)
        if canli_mi(p):
            break
    return p


class StudyoKaos:
    def __init__(self):
        self.fig = fig = plt.figure(figsize=(11, 7.6))
        try:
            fig.canvas.manager.set_window_title("Kaos ve Form — Canlı Stüdyo")
        except AttributeError:
            pass
        fig.patch.set_facecolor("white")

        self.ax_img = fig.add_axes([0.36, 0.02, 0.62, 0.96])
        self.ax_img.axis("off")
        self.im = None

        self.s = {}
        for i, (ad, ilk) in enumerate(zip("abcd", (-1.4, 1.6, 1.0, 0.7))):
            self.s[ad] = Slider(fig.add_axes([0.07, 0.92 - 0.05 * i, 0.22, 0.03]), ad, -3, 3, valinit=ilk)

        fig.text(0.03, 0.68, "nokta sayısı", fontsize=10, weight="bold")
        self.r_n = RadioButtons(fig.add_axes([0.03, 0.55, 0.27, 0.12], frameon=False),
                                [f"{n:,}".replace(",", ".") for n in NOKTA_SECENEKLERI], active=1)
        fig.text(0.03, 0.52, "palet", fontsize=10, weight="bold")
        self.r_grad = RadioButtons(fig.add_axes([0.03, 0.35, 0.27, 0.16], frameon=False), list(kf.gradients),
                                   active=0)
        self.s_gamma = Slider(fig.add_axes([0.11, 0.30, 0.18, 0.03]), "parlaklık", 0.25, 1.2, valinit=0.55)

        self.b_rast = Button(fig.add_axes([0.03, 0.21, 0.12, 0.055]), "Rastgele")
        self.b_kaydet = Button(fig.add_axes([0.16, 0.21, 0.14, 0.055]), "Kaydet (PNG)")
        self.durum = fig.text(0.03, 0.15, "", fontsize=9, color="0.25")

        # sürüklerken hızlı önizleme; son değişiklikten 300 ms sonra tam kalite
        self.zamanlayici = fig.canvas.new_timer(interval=300)
        self.zamanlayici.single_shot = True
        self.zamanlayici.add_callback(self.ciz)

        for w in list(self.s.values()) + [self.s_gamma]:
            w.on_changed(lambda _: self.degisti())
        for w in (self.r_n, self.r_grad):
            w.on_clicked(lambda _: self.degisti())
        self.b_rast.on_clicked(lambda _: self.rastgele())
        self.b_kaydet.on_clicked(lambda _: self.kaydet())
        self._toplu = False

    def ayarlar(self):
        n = NOKTA_SECENEKLERI[[f"{x:,}".replace(",", ".") for x in NOKTA_SECENEKLERI].index(self.r_n.value_selected)]
        return [self.s[k].val for k in "abcd"], n, self.r_grad.value_selected, self.s_gamma.val

    def goster(self, img):
        if self.im is None:
            self.im = self.ax_img.imshow(img, extent=(0, 1, 0, 1), interpolation="antialiased")
        else:
            self.im.set_data(img)

    def degisti(self):
        if self._toplu:
            return
        p, _, grad, gamma = self.ayarlar()
        self.goster(kf.attractor_art(p, 150_000, 350, grad, gamma))       # ControlActive: hızlı önizleme
        self.fig.canvas.draw_idle()
        self.zamanlayici.stop()
        self.zamanlayici.start()

    def ciz(self):
        p, n, grad, gamma = self.ayarlar()
        self.goster(kf.attractor_art(p, n, 800, grad, gamma))
        self.durum.set_text("a, b, c, d = " + ", ".join(f"{v:.3f}" for v in p))
        self.fig.canvas.draw_idle()

    def rastgele(self):
        self._toplu = True                       # dört kaydırıcı tek seferde değişsin
        for k, v in zip("abcd", canli_parametre()):
            self.s[k].set_val(v)
        self._toplu = False
        self.degisti()

    def kaydet(self):
        p, _, grad, gamma = self.ayarlar()
        yol = Path.home() / f"clifford_{round(time.time())}.png"
        self.durum.set_text("6 milyon nokta, 2000 px kaydediliyor…")
        self.fig.canvas.draw()
        self.fig.canvas.flush_events()
        kaydet(yol, kf.attractor_art(p, 6_000_000, 2000, grad, gamma))
        self.durum.set_text(f"kaydedildi: {yol}")
        self.fig.canvas.draw_idle()


def main():
    st = StudyoKaos()
    st.ciz()
    plt.show()
    return st


if __name__ == "__main__":
    main()
