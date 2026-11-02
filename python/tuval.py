"""Mathematica'daki Graphics + Rasterize ikilisinin küçük bir karşılığı.

Cizim ilkelleri (çizgi, çokgen, disk, çember) sırayla kaydeder; resim(px) onları istenen
genişlikte matplotlib (Agg) ile rasterleştirir. Sıra derinliktir: sonra eklenen öne geçer.

Kalınlıklar Mathematica'daki gibi tuval genişliğine oranlıdır: w birimi Thickness[0.0015 w]
demektir, yani her çözünürlükte aynı görünüm.
"""

import numpy as np
from matplotlib.figure import Figure
from matplotlib.backends.backend_agg import FigureCanvasAgg
from matplotlib.collections import LineCollection, PolyCollection
from PIL import Image

PHI = (1 + 5 ** 0.5) / 2
_DPI = 100.0


def _rgba(renk, alfa):
    r = np.clip(np.asarray(renk, float)[:3], 0.0, 1.0)
    return (r[0], r[1], r[2], float(alfa))


class Cizim:
    """Graphics[...] karşılığı. Tuval x: 0…1, y: 0…yukseklik (varsayılan φ)."""

    def __init__(self, arkaplan, yukseklik=PHI, tohum=None):
        self.arkaplan = np.clip(np.asarray(arkaplan, float)[:3], 0, 1)
        self.yukseklik = yukseklik
        self.tohum = tohum
        self._ops = []

    # --- ilkeller -------------------------------------------------------------------------
    def cizgi(self, pts, renk, alfa, w, uc="round", kesikli=None):
        pts = np.asarray(pts, float)
        if len(pts) >= 2:
            self._ops.append((("cizgi", uc, kesikli), pts, _rgba(renk, alfa), float(w)))

    def cokgen(self, pts, renk, alfa):
        pts = np.asarray(pts, float)
        if len(pts) >= 3:
            self._ops.append((("dolgu",), pts, _rgba(renk, alfa), None))

    def disk(self, c, r, renk, alfa):
        self._ops.append((("dolgu",), ("disk", np.asarray(c, float), float(r)), _rgba(renk, alfa), None))

    def cember(self, c, r, renk, alfa, w, kesikli=None):
        t = np.linspace(0, 2 * np.pi, 121)
        c = np.asarray(c, float)
        self.cizgi(c + r * np.column_stack([np.cos(t), np.sin(t)]), renk, alfa, w, kesikli=kesikli)

    # --- rasterleştirme ---------------------------------------------------------------------
    def boyut(self, px):
        return int(px), int(round(px * self.yukseklik))

    def resim(self, px=600):
        """RGB float dizisi (yükseklik, genişlik, 3), değerler 0…1."""
        W, H = self.boyut(px)
        fig = Figure(figsize=(W / _DPI, H / _DPI), dpi=_DPI)
        canvas = FigureCanvasAgg(fig)
        fig.patch.set_facecolor(self.arkaplan)
        ax = fig.add_axes([0, 0, 1, 1])
        ax.set_xlim(0, 1)
        ax.set_ylim(0, self.yukseklik)
        ax.set_facecolor(self.arkaplan)
        ax.axis("off")

        pt = 0.0015 * W * 72.0 / _DPI          # w = 1 biriminin punto karşılığı

        def disk_kosleri(c, r):
            n = int(np.clip(np.pi * r * W, 12, 200))
            t = np.linspace(0, 2 * np.pi, n, endpoint=False)
            return c + r * np.column_stack([np.cos(t), np.sin(t)])

        z = 0
        i = 0
        ops = self._ops
        while i < len(ops):
            anahtar = ops[i][0]
            j = i
            while j < len(ops) and ops[j][0] == anahtar:
                j += 1
            grup = ops[i:j]
            renkler = [o[2] for o in grup]
            if anahtar[0] == "cizgi":
                _, uc, kesikli = anahtar
                gen = np.array([o[3] for o in grup]) * pt
                kw = {}
                if kesikli is not None:
                    # kesikli: (açık, kapalı) tuval genişliğine oranlı → çizgi kalınlığı biriminde
                    a, b = kesikli
                    kw["linestyles"] = [(0, (a * W * 72 / _DPI / g, b * W * 72 / _DPI / g)) for g in gen]
                col = LineCollection([o[1] for o in grup], colors=renkler, linewidths=gen,
                                     capstyle="butt" if uc == "butt" else "round",
                                     joinstyle="round", antialiaseds=True, zorder=z, **kw)
            else:
                kos = [disk_kosleri(o[1][1], o[1][2]) if isinstance(o[1], tuple) else o[1] for o in grup]
                col = PolyCollection(kos, facecolors=renkler, edgecolors="none", linewidths=0,
                                     antialiaseds=True, zorder=z)
            col.set_snap(False)
            ax.add_collection(col)
            z += 1
            i = j

        canvas.draw()
        buf = np.asarray(canvas.buffer_rgba())[..., :3].astype(float) / 255.0
        return buf


def kaydet(yol, img):
    """0…1 aralığındaki RGB dizisini (veya Cizim'i 600 px'te) PNG olarak yazar."""
    if isinstance(img, Cizim):
        img = img.resim(600)
    arr = (np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8)
    Image.fromarray(arr).save(yol)
