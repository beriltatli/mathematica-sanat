(* ::Package:: *)

(* ::Title:: *)
(*Ruh Katmanları — Altın Oranla Kurulmuş Üretken Resim*)


(* ::Text:: *)
(*Ekspresif, katmanlı akrilik resimlerden esinlenen bir üretken sanat çalışması. Üç mod:*)
(*  • Ruh Katmanları  (ruhKatmanlari, Bölüm 4): akan fırça darbeleri, üst üste binen saydam formlar,*)
(*    merkezden yayılan ışık patlaması ve noktalı dokular.*)
(*  • Işık Kafesi     (isikKafesi, Bölüm 10): neon kaburga kafesi ve omurga, göğüste altın-beyaz ışık patlaması.*)
(*  • Eriyen Maskeler (eriyenMaskeler, Bölüm 11): pastel sis içinde aşağı doğru eriyip akan hayalet maskeler.*)
(*Mathematica'da açıp "Run All Code" ile çalıştır. Mathematica 12 veya üstü önerilir. Ortak stüdyo: Bölüm 12.*)
(**)
(*ALTIN ORAN NEREDE?*)
(*Üç modda ortak:*)
(*  • Tuval oranı 1 : φ (dikey altın dikdörtgen).*)
(*  • Tuval ardışık karelere bölünür; bu karelerin yaylarından altın spiral çizilir, kesimler spiralin kutbuna yakınsar.*)
(*Ruh Katmanları:*)
(*  • Işık patlaması spiralin kutbuna (gözüne) yerleşir: kompozisyonun odağı.*)
(*  • Ana girdap kutupta, iki ikincil girdap spiral üzerinde; güçleri 1, 1/φ, 1/φ² ve dönüş yönleri dönüşümlü.*)
(*  • Saydam kürelerin yarıçapları her adımda φ'ye bölünür.*)
(*  • Nokta dokuları altın açıyla (≈137.5°) dizilir — ayçiçeği tohumları gibi —*)
(*    ve tuvalin altın bölüm çizgilerinin (0.618, 0.786, 0.236 …) kesişimlerine konur.*)
(*  • Yıldız boyutları φ'nin kuvvetleridir.*)
(*Işık Kafesi:*)
(*  • Altın yapı dikeyde aynalanır (tohuma göre yatayda da): kutup tuval yüksekliğinin 0.724'üne, göğüs hizasına*)
(*    çıkar. Aynalanan yapı yine aynı altın spiraldir. Işık patlaması tam kutupta.*)
(*  • Omurga kutuptan geçen hafif bir S eğrisi. Omurlar aşağıdan yukarıya φ^(-1/8) oranıyla küçülür: her 8 omurda*)
(*    bir boyut tam φ'ye bölünür (her adımda φ'ye bölmek omurgayı 4-5 omurda bitirirdi).*)
(*  • Kaburga çiftlerinin uzunlukları ve aralıkları φ kuvvetleriyle değişir; ortadakiler en uzun.*)
(*  • Patlama ışınları altın açının katlarında; sarmal dokular altın bölüm çizgilerinin kesişimlerinde.*)
(*Eriyen Maskeler:*)
(*  • Aynı aynalama: kutup yukarıda kalır, maskelerin aşağı doğru akacak yeri olur.*)
(*  • Maske merkezleri altın spiral üzerinde; en büyüğü kutupta, yarıçaplar sırayla φ'ye bölünür.*)
(*  • Kenardaki patlıcan moru girdaplar tuval kenarlarının altın bölüm noktalarında (0.382, 0.618);*)
(*    güçleri 1, 1/φ, 1/φ², 1/φ³.*)


(* ::Section:: *)
(*1. Sabitler ve paletler*)


phi = N[GoldenRatio];
goldenAngle = N[Pi (3 - Sqrt[5])];      (* ≈ 2.39996 rad ≈ 137.5° *)

hex[s_String] := RGBColor @@ (IntegerDigits[FromDigits[StringDrop[s, 1], 16], 256, 3]/255.);

(* Her palet koyudan açığa/sıcağa dizilir: 0 = zemin tonu, 1 = ışık tonu *)
palettes = <|
   "Toprak"  -> hex /@ {"#24363d", "#3f6f73", "#8fbcbc", "#e3b04b", "#ec7a3c", "#c8423a", "#f4cdbd"},
   "Hayalet" -> hex /@ {"#2a1240", "#6b2d8f", "#e0569a", "#f6a8c6", "#f7e27a", "#b6f25c", "#45d6b0"},
   "Kozmik"  -> hex /@ {"#0b1150", "#2337c6", "#5aa2ff", "#8a2be2", "#e5207f", "#ff6a3d", "#ffd84a"},
   (* Işık Kafesi modu için: koyu lacivert, kobalt, açık mavi, turkuaz, macenta, sıcak pembe, turuncu, sarı, altın-beyaz *)
   "NeonGece" -> hex /@ {"#0a0f2e", "#1d3bd1", "#6cb6ff", "#33e0d0", "#d61a8f", "#ff3d6e", "#ff7a2a", "#ffd23f", "#fff4d6"},
   (* Eriyen Maskeler modu için: patlıcan moru, lila, toz pembe, şeftali, tereyağı sarısı, asit yeşili, turkuaz *)
   "PastelRuh" -> hex /@ {"#3b1840", "#b39ddb", "#f4b6c6", "#ffcba4", "#fbe8a6", "#b6f23a", "#3fd8c6"}
   |>;

palColor[pal_, t_] := Blend[pal, Clip[t, {0., 1.}]];
scaleColor[c_, k_] := RGBColor @@ Clip[k (List @@ ColorConvert[c, "RGB"])[[;; 3]], {0., 1.}];


(* ::Section:: *)
(*2. Altın dikdörtgen, altın spiral ve kutup*)


(* ::Text:: *)
(*1 × φ'lik tuvalden sırayla üstten, sağdan, alttan, soldan kare kesilir. Kalan dikdörtgen yine altın dikdörtgendir.*)
(*Her karenin içine çeyrek daire çizilince yaylar kesintisiz bir altın spiral oluşturur.*)
(*Kesimler sonsuza giderken kalan küçük dikdörtgen tek bir noktaya, spiralin kutbuna yakınsar.*)


goldenConstruction[n_Integer : 14] := Module[
  {x = 0., y = 0., w = 1., h = phi, s, sq = {}, arcs = {}, spiral},
  Do[
   Switch[Mod[k, 4],
    0, s = w; AppendTo[sq, {x, y + h - s, s}]; AppendTo[arcs, {{x, y + h - s}, s, 90.}]; h -= s,
    1, s = h; AppendTo[sq, {x + w - s, y, s}]; AppendTo[arcs, {{x + w - s, y + h}, s, 0.}]; w -= s,
    2, s = w; AppendTo[sq, {x, y, s}]; AppendTo[arcs, {{x + s, y + s}, s, -90.}]; y += s; h -= s,
    3, s = h; AppendTo[sq, {x, y, s}]; AppendTo[arcs, {{x + s, y}, s, 180.}]; x += s; w -= s
    ],
   {k, 0, n - 1}];
  spiral = Join @@ Map[
     Function[arc, Table[arc[[1]] + arc[[2]] {Cos[t Degree], Sin[t Degree]},
       {t, Subdivide[arc[[3]], arc[[3]] - 90., 79]}]],
     arcs];
  <|"Squares" -> sq, "Spiral" -> spiral, "Pole" -> {x + w/2, y + h/2}|>
  ];


(* ::Section:: *)
(*3. Akış alanı ve fırça izi takibi (derlenmiş)*)


(* ::Text:: *)
(*Her fırça darbesi bir noktadan başlar ve bir vektör alanını adım adım takip eder.*)
(*Alan iki parçadan oluşur:*)
(*  (a) "alan bükme" uygulanmış sinüs gürültüsü: organik, düzensiz akış,*)
(*  (b) altın spiral üzerine yerleştirilmiş girdaplar: kompozisyonu odağa çeken dönüş.*)
(*Compile sayesinde binlerce darbe birkaç saniyede hesaplanır.*)


traceStrokes = Compile[
   {{seeds, _Real, 2}, {vc, _Real, 2}, {vs, _Real, 1}, {vd, _Real, 1},
    {swirl, _Real}, {ph, _Real, 1}, {steps, _Integer}, {dt, _Real}},
   Module[{n = Length[seeds], out, p, x, y, wx, wy, nz, vx, vy, dx, dy, r, g, ang, nrm},
    out = Table[0., {n}, {steps}, {2}];
    Do[
     p = seeds[[i]];
     out[[i, 1]] = p;
     Do[
      x = p[[1]]; y = p[[2]];
      wx = x + 0.22 Sin[3.3 y + ph[[1]]];
      wy = y + 0.22 Sin[2.9 x + ph[[2]]];
      nz = Sin[4.1 wx + ph[[3]]] + Cos[3.4 wy - ph[[1]]] + 0.6 Sin[8.5 (wx - 0.7 wy) + ph[[2]]];
      vx = Cos[1.4 nz]; vy = Sin[1.4 nz];
      Do[
       dx = x - vc[[j, 1]]; dy = y - vc[[j, 2]];
       r = Sqrt[dx^2 + dy^2] + 0.001;
       g = 2.2 swirl vs[[j]] Exp[-r/(0.5 Sqrt[vs[[j]]])];
       ang = ArcTan[dx, dy] + vd[[j]] (Pi/2 + 0.3);
       vx += g Cos[ang]; vy += g Sin[ang],
       {j, Length[vs]}];
      nrm = Sqrt[vx^2 + vy^2] + 10.^-9;
      p = p + dt {vx, vy}/nrm;
      out[[i, k]] = p,
      {k, 2, steps}],
     {i, n}];
    out],
   RuntimeOptions -> "Speed"];


(* ::Section:: *)
(*4. Resmi kuran ana fonksiyon*)


(* ::Text:: *)
(*ruhKatmanlari[tohum, palet, girdap, yoğunluk, kılavuz]*)
(*  tohum    : rastgelelik tohumu — her sayı farklı bir resim*)
(*  palet    : "Toprak", "Hayalet" veya "Kozmik"*)
(*  girdap   : girdapların gücü (0 = sadece akış, 2 = çok güçlü dönüş)*)
(*  yoğunluk : fırça darbesi sayısı çarpanı (önizleme için 0.3–0.5, son hali için 1–1.5)*)
(*  kılavuz  : True ise altın dikdörtgen kareleri ve kutup üzerine çizilir*)
(*Katmanlar aşağıdan yukarıya sırayla çizilir; listedeki sıra resimdeki derinliktir.*)


ruhKatmanlari[seed_Integer : 11, palName_String : "Kozmik", swirl_?NumericQ : 1.,
   density_?NumericQ : 1., guide_ : False] := Module[
  {pal, gc, sp, pole, vc, vs, vd, ph, cph, ctone, nz, lineLayer, seedsIn, lw,
   bg, wide, veins, ribbons, bubbles, dabs, phyllo, spiralLines, burst, stars, guideLayer, cnt},

  SeedRandom[seed];
  pal = palettes[palName];
  gc = goldenConstruction[14];
  sp = gc["Spiral"]; pole = gc["Pole"];

  (* girdaplar: kutup + spiral üzerinde iki nokta; güçler 1, 1/φ, 1/φ²; yönler +, −, + *)
  vc = {pole, sp[[61]], sp[[201]]};
  vs = {1., 1/phi, 1/phi^2};
  vd = {1., -1., 1.};
  ph = RandomReal[{0, 2 Pi}, 3];
  cph = RandomReal[{0, 2 Pi}, 3];

  (* renk alanı: tuvali büyük renk kütlelerine böler, odağa yaklaştıkça paletin ışık ucuna kayar *)
  ctone[{x_, y_}] := Module[{v, d},
    v = Sin[2.3 x + cph[[1]]] Cos[1.7 y + cph[[2]]] + 0.5 Sin[3.1 (x + y) + cph[[3]]];
    v = (Tanh[1.8 v] + 1)/2;
    d = Norm[{x, y} - pole];
    Clip[0.75 v + 0.5 Exp[-d/0.28], {0., 1.}]];

  nz[n_, s_] := RandomVariate[NormalDistribution[0, s], n];
  lw[px_] := Thickness[0.0015 px];        (* kalınlık tuval genişliğine oranlı: her çözünürlükte aynı görünüm *)
  seedsIn[n_] := Transpose[{RandomReal[{0, 1}, n], RandomReal[{0, phi}, n]}];
  cnt[n_] := Max[10, Round[n density]];

  (* bir grup fırça darbesini çizgilere çevirir *)
  lineLayer[seeds_, steps_, dt_, {w1_, w2_}, alpha_, shift_, jitter_, {b1_, b2_}] := Module[
    {S = traceStrokes[seeds, vc, vs, vd, N[swirl], ph, steps, dt], n = Length[seeds], ts},
    ts = Clip[(ctone /@ seeds) + shift + nz[n, jitter], {0., 1.}];
    MapThread[
     {scaleColor[palColor[pal, #2], #3], Opacity[alpha], lw[#4], Line[#1]} &,
     {S, ts, RandomReal[{b1, b2}, n], RandomReal[{w1, w2}, n]}]];

  (* 1) zemin: büyük, yumuşak renk lekeleri *)
  bg = Table[With[{c = {RandomReal[], RandomReal[{0, phi}]}},
     {palColor[pal, ctone[c] + RandomVariate[NormalDistribution[0, 0.1]]], Opacity[0.25],
      Disk[c, RandomReal[{0.06, 0.28}]]}], {90}];

  (* 2) geniş, yarı saydam fırça darbeleri *)
  wide = lineLayer[seedsIn[cnt[1300]], 18, 0.013, {7, 18}, 0.28, 0., 0.07, {0.85, 1.15}];

  (* 3) ince damarlar *)
  veins = lineLayer[seedsIn[cnt[1800]], 34, 0.006, {0.5, 2.0}, 0.6, 0.12, 0.12, {0.85, 1.15}];

  (* 4) kalın kurdeleler: koyu kenar + gövde + ince parlak sırt *)
  ribbons = Module[{starts, S},
    starts = sp[[RandomInteger[{1, Length[sp]}, 7]]] + RandomVariate[NormalDistribution[0, 0.15], {7, 2}];
    S = traceStrokes[starts, vc, vs, vd, N[swirl], ph, 90, 0.008];
    Table[With[{t = ctone[starts[[k]]] + RandomVariate[NormalDistribution[0, 0.15]], w = RandomReal[{18, 34}]},
      {{scaleColor[palColor[pal, t - 0.3], 0.7], Opacity[0.45], lw[w + 5], Line[S[[k]]]},
       {palColor[pal, t], Opacity[0.55], lw[w], Line[S[[k]]]},
       {palColor[pal, t + 0.25], Opacity[0.5], lw[0.25 w], Line[(# + 0.004) & /@ S[[k]]]}}],
     {k, Length[S]}]];

  (* 5) saydam küreler: spiral boyunca, yarıçap her adımda φ'ye bölünür; eskiz gibi çift kontur *)
  bubbles = MapIndexed[
    Function[{i, k}, With[{c = sp[[i]], r = 0.34/phi^(k[[1]] - 1), kk = k[[1]] - 1},
      {{palColor[pal, 0.55 + 0.06 kk], Opacity[0.16], Disk[c, r]},
       Table[{palColor[pal, 0.85], Opacity[0.5], lw[0.9],
         Circle[c + RandomVariate[NormalDistribution[0, 0.02 r], 2], r (1 + 0.015 j)]}, {j, 0, 1}]}]],
    Round[Subdivide[21, Length[sp] - 119, 6]]];

  (* 6) kısa, opak boya lekeleri *)
  dabs = lineLayer[seedsIn[cnt[600]], 4, 0.008, {2, 5}, 0.5, nz[cnt[600], 0.05], 0.15, {0.9, 1.3}];

  (* 7) fillotaksis: altın açıyla dizilmiş noktalar, altın bölüm çizgilerinin kesişimlerinde *)
  phyllo = Function[{cen, R, m},
      Table[With[{rr = R Sqrt[i/m], th = i goldenAngle},
        {palColor[pal, 0.95 - 0.5 i/m], Opacity[0.8],
         Disk[cen + rr {Cos[th], Sin[th]}, 0.00077 Sqrt[(1 - i/m) 22 + 2]]}], {i, 0, m - 1}]] @@@
    {{{0.618, 0.786 phi}, 0.2, 520}, {{0.786, 0.236 phi}, 0.15, 300}};

  (* 8) altın spiralin kendisi: üç katmanlı fırça izi *)
  spiralLines = Table[{palColor[pal, 0.9], Opacity[wa[[2]]], lw[wa[[1]]], CapForm["Round"], Line[sp]},
    {wa, {{10, 0.10}, {3.5, 0.3}, {1.1, 0.85}}}];

  (* 9) kutupta ışık patlaması: ışın açıları altın açının katları *)
  burst = {
    Table[With[{a = k goldenAngle + RandomVariate[NormalDistribution[0, 0.04]],
        len = RandomReal[{0.08, 0.32}] If[Mod[k, 5] == 0, 1.5, 1.],
        w0 = RandomReal[{0.006, 0.02}]},
       With[{u = {Cos[a], Sin[a]}, nv = w0 {-Sin[a], Cos[a]}},
        {{palColor[pal, RandomReal[{0.8, 1.}]], Opacity[0.5], Polygon[{pole + nv, pole + len u, pole - nv}]},
         {RGBColor[1, 1, 0.9], Opacity[0.6], Polygon[{pole + 0.3 nv, pole + 0.8 len u, pole - 0.3 nv}]}}]],
     {k, 0, 47}],
    Table[{RGBColor[1, 0.97, 0.85], Opacity[ro[[2]]], Disk[pole, ro[[1]]]},
     {ro, {{0.12, 0.12}, {0.07, 0.25}, {0.035, 0.6}, {0.015, 0.95}}}]};

  (* 10) dört kollu yıldızlar: boyutları φ'nin kuvvetleri *)
  stars = Table[With[{c = {RandomReal[], RandomReal[{0, phi}]}, s = 0.08/phi^RandomInteger[{0, 3}],
      col = palColor[pal, RandomReal[{0.7, 1.}]]},
     Table[With[{a = j Pi/4 + RandomVariate[NormalDistribution[0, 0.06]]},
       With[{u = If[EvenQ[j], s, 0.45 s] {Cos[a], Sin[a]}},
        {col, Opacity[0.8], Polygon[{c + 0.08 {-u[[2]], u[[1]]}, c + u, c - 0.08 {-u[[2]], u[[1]]}}]}]],
      {j, 0, 7}]], {10}];

  guideLayer = If[TrueQ[guide],
    {White, Opacity[0.8], lw[0.8], EdgeForm[Directive[White, Opacity[0.8], lw[0.8]]], FaceForm[None],
     Rectangle[#[[;; 2]], #[[;; 2]] + #[[3]]] & /@ gc["Squares"],
     Red, Disk[pole, 0.006]},
    {}];

  Graphics[
   {CapForm["Round"], JoinForm["Round"],
    bg, wide, veins, ribbons, bubbles, dabs, phyllo, spiralLines, burst, stars, guideLayer},
   PlotRange -> {{0, 1}, {0, phi}}, PlotRangePadding -> None, AspectRatio -> Automatic,
   Background -> Darker[pal[[1]], 0.2], ImageSize -> 600]
  ];


(* ::Section:: *)
(*5. Son işlem: parlama ve tuval dokusu*)


(* ::Text:: *)
(*Görüntünün bulanık kopyası "ekran" karışımıyla eklenir: parlak bölgeler ışık saçar.*)
(*Ardından ince bir gren eklenerek dijital düzlük kırılır, boya/tuval hissi verilir.*)


finish[g_Graphics, px_Integer : 900, glowAmt_ : 0.3, grain_ : 0.024] := Module[{img, a, b, noise},
   img = ColorConvert[Rasterize[g, "Image", RasterSize -> px], "RGB"];
   a = ImageData[img][[All, All, ;; 3]];
   b = ImageData[GaussianFilter[img, Round[px/35]]][[All, All, ;; 3]];
   noise = RandomVariate[NormalDistribution[0, grain], Dimensions[a][[;; 2]]];
   Image[Clip[1 - (1 - a) (1 - glowAmt b) + noise, {0., 1.}]]
   ];


(* ::Section:: *)
(*6. Üç örnek*)


eser1 = finish[ruhKatmanlari[11, "Toprak"]]


eser2 = finish[ruhKatmanlari[4, "Hayalet"]]


eser3 = finish[ruhKatmanlari[23, "Kozmik"]]


(* Altın oran kılavuzunu üstüne çizerek kompozisyonu gör *)
finish[ruhKatmanlari[23, "Kozmik", 1., 0.5, True], 600]


(* ::Section:: *)
(*7. Canlı stüdyo*)


(* ::Text:: *)
(*Stüdyo, üç modu tek panelde birleştiren ortak stüdyoya dönüştü: Bölüm 12.*)
(*Tüm modların tanımları yüklendikten sonra çalışabilmesi için dosyanın sonunda duruyor.*)


(* ::Section:: *)
(*8. Baskı kalitesinde dışa aktarma*)


(* ::Text:: *)
(*3000 px genişlik ≈ 25 × 40 cm baskı (300 dpi'da 25 cm genişlik). Yoğunluğu 1.4'e çıkarmak büyük boyutta dokuyu zenginleştirir.*)


(*
Export[FileNameJoin[{$HomeDirectory, "Desktop", "ruh_katmanlari_kozmik.png"}],
  finish[ruhKatmanlari[23, "Kozmik", 1., 1.4], 3000]];
*)


(* ::Section:: *)
(*9. Yeni eser modları — ortak fırça araçları*)


(* ::Text:: *)
(*Bu bölümden sonraki modlar ekspresyonist akrilik resimlerin görsel ÖZELLİKLERİNİ (görünür fırça, neon kontur,*)
(*ışık patlaması, noktalı dokular) prosedürel olarak üretir; hiçbir resmi kopyalamaz. Mevcut parçaları yeniden kullanır:*)
(*  • goldenConstruction → kutup ve altın spiral (kompozisyonun odağı),*)
(*  • traceStrokes → akış alanı fırça darbeleri (arka plan),*)
(*  • palColor / scaleColor → palet renkleri,*)
(*  • finish → parlama ve tuval greni.*)
(*Önce düşük ayarla (önizleme) dene; beğendiğin tohumu yüksek kalite ayarıyla dışa aktar.*)


kalinlik[px_] := Thickness[0.0015 px];      (* ruhKatmanlari içindeki lw ile aynı ölçek: tuval genişliğine oranlı *)

(* iki nokta arasında n parçalı düz çizgi (titrekFirca en az 3 nokta ister) *)
dogruParca[p_, q_, n_Integer : 12] := Table[p + s (q - p), {s, Subdivide[0., 1., n]}];

(* eğrinin her noktasındaki birim normal *)
egriNormalleri[pts_] := Module[{tg},
   tg = Join[{pts[[2]] - pts[[1]]}, pts[[3 ;;]] - pts[[;; -3]], {pts[[-1]] - pts[[-2]]}];
   Normalize[{-#[[2]], #[[1]]}] & /@ tg];

(* yumuşak gürültü: üç rastgele sinüsün toplamı + biraz titreşim — elin titremesi gibi *)
dalgalanma[n_Integer, amp_] := Module[{t = Subdivide[0., 1., n - 1], f, p, a},
   f = RandomReal[{1., 4.5}, 3]; p = RandomReal[{0, 2 Pi}, 3]; a = RandomReal[{0.4, 1.}, 3];
   amp (Total[MapThread[#1 Sin[2 Pi #2 t + #3] &, {a, f, p}]]/Total[a] +
      RandomVariate[NormalDistribution[0, 0.15], n])];


(* ::Text:: *)
(*titrekFirca[noktalar, renkler, genişlik, hale, sapma]*)
(*Bir eğriyi tek çizgi yerine, normal yönünde yumuşak gürültüyle kaydırılmış 3-5 kopya olarak çizer.*)
(*  renkler  : koyudan açığa renk listesi; alttaki kopya ilk renk, en üstteki son renk*)
(*  genişlik : piksel cinsinden fırça kalınlığı (600 px genişliğe göre); kopyalar yukarı çıktıkça incelir*)
(*  hale     : {renk1, renk2} verilirse en altta geniş, düşük opaklıkta neon hale ve iki kenarda çift kontur*)
(*             (renk1 bir yanda, renk2 öbür yanda); {} ise hale çizilmez*)
(*  sapma    : kopyaların ortalama kayması (tuval birimi); Automatic = fırça genişliğinin %30'u*)
(*Kopyaların uçları rastgele kırpılır: kuru fırçanın yırtık bitişi.*)


titrekFirca[pts_List, renkler_List, w_?NumericQ, hale_List : {}, sapma_ : Automatic] := Module[
   {n = Length[pts], nrm, kenar = 0.0015 w, s, c, e, kopya},
   nrm = egriNormalleri[pts];
   s = If[sapma === Automatic, 0.3 kenar, sapma];
   c = RandomInteger[{3, 5}];
   e = Floor[0.08 n];
   kopya[off_] := pts + off nrm;
   {
    If[hale === {}, {},
     {{hale[[1]], Opacity[0.1], kalinlik[3.2 w], Line[kopya[dalgalanma[n, s]]]},
      {hale[[1]], Opacity[0.55], kalinlik[0.35 w], Line[kopya[0.62 kenar + dalgalanma[n, 0.5 s]]]},
      {hale[[-1]], Opacity[0.55], kalinlik[0.35 w], Line[kopya[-0.62 kenar + dalgalanma[n, 0.5 s]]]}}],
    Table[
     {Blend[renkler, (j - 1)/(c - 1)], Opacity[RandomReal[{0.55, 0.85}]], kalinlik[w (1 - 0.6 (j - 1)/(c - 1))],
      Line[kopya[dalgalanma[n, s]][[1 + RandomInteger[e] ;; n - RandomInteger[e]]]]},
     {j, c}]
    }];


(* ::Text:: *)
(*sarmalDoku[merkez, açı, uzunluk, genlik, {renk1, renk2}, basamakRenkleri]*)
(*DNA sarmalını andıran doku: aynı eksen boyunca yarım tur kaymış iki sinüs eğrisi, noktalarla çizilir;*)
(*aralarına kısa basamak çizgileri atılır. Öndeki kolun noktaları büyük, arkadakinin küçük: derinlik hissi.*)


sarmalDoku[c_, aci_, L_, A_, {r1_, r2_}, basamak_List] := Module[
   {u = {Cos[aci], Sin[aci]}, v = {-Sin[aci], Cos[aci]}, f = RandomReal[{2.2, 3.4}], kol},
   kol[t_, fz_] := c + (t - 0.5) L u + A Sin[2 Pi f t + fz] v;
   {
    Table[If[EvenQ[i] && RandomReal[] < 0.9,
      With[{t = i/160., on = Cos[2 Pi f i/160.]},
       {{If[Mod[i, 4] == 0, r2, r1], Opacity[0.9], Disk[kol[t, 0.], 0.0026 (1.2 + 0.5 on)]},
        {If[Mod[i, 4] == 0, r1, r2], Opacity[0.9], Disk[kol[t, N[Pi]], 0.0026 (1.2 - 0.5 on)]}}],
      {}], {i, 0, 160}],
    Table[With[{p1 = kol[i/160., 0.], p2 = kol[i/160., N[Pi]],
       a0 = RandomReal[{0.12, 0.25}], a1 = RandomReal[{0.75, 0.88}]},
      {RandomChoice[basamak], Opacity[0.85], kalinlik[RandomReal[{1.2, 2.2}]], CapForm["Butt"],
       Line[{p1 + a0 (p2 - p1), p1 + a1 (p2 - p1)}]}], {i, 9, 159, 9}]
    }];


(* k kollu sivri yıldız: kollar dönüşümlü uzun/kısa ince üçgenler, ortada parlak çekirdek *)
sivriYildiz[c_, s_, k_Integer, renk_, cekirdek_] := Module[{r0 = RandomReal[{0, 2 Pi}]},
   {Table[With[{a = r0 + 2 Pi j/k + RandomVariate[NormalDistribution[0, 0.08]],
        len = s If[EvenQ[j], 1., 0.55] RandomReal[{0.8, 1.1}]},
      With[{u = {Cos[a], Sin[a]}, nv = 0.07 s {-Sin[a], Cos[a]}},
       {renk, Opacity[0.85], Polygon[{c + nv, c + len u, c - nv}]}]], {j, 0, k - 1}],
    {cekirdek, Opacity[0.9], Disk[c, 0.12 s]}}];


(* ::Section:: *)
(*10. Mod 1 — Işık Kafesi (neon anatomi + ışık patlaması)*)


(* ::Text:: *)
(*Kobalt bir kaburga kafesi ve omurga; kemikler açık mavi-turkuaz, kenarlarında sarı-macenta neon hale.*)
(*Göğsün ortasında altın-beyaz bir ışık patlaması; ışınlar kaburgaların ÖNÜNDEN geçer.*)
(*Arka planda sıcak akış alanı kütleleri, köşelerde sivri yıldızlar, altın bölüm noktalarında DNA sarmalları.*)
(**)
(*ALTIN ORAN NEREDE?*)
(*  • Tuval 1 : φ. Altın dikdörtgen yapısı dikeyde aynalanır (tohuma göre yatayda da): kutup göğüs hizasına,*)
(*    tuvalin yüksekliğinin 0.724'üne çıkar. Aynalanmış yapı yine aynı altın spiraldir. Patlama tam kutupta.*)
(*  • Omurga kutuptan geçen hafif bir S eğrisidir. Omurlar aşağıdan yukarıya küçülür: adım oranı φ^(-1/8),*)
(*    yani her 8 omurda bir boyut tam olarak φ'ye bölünür (her adımda φ'ye bölmek omurgayı 4-5 omurda bitirirdi).*)
(*  • Kaburga çiftleri kutbun iki yanına simetrik dizilir: j. çiftin yarı genişliği wMax·φ^(-|j|/2), komşu çiftler*)
(*    arası d0·φ^(-(|j|-1/2)/2). Ortadaki kaburgalar en uzun ve en seyrek; uçlara doğru φ kuvvetleriyle kısalır, sıklaşır.*)
(*  • Patlama ışınlarının açıları altın açının katları; yıldız boyutları φ'nin kuvvetleri.*)
(*  • Sarmal dokular tuvalin altın bölüm çizgilerinin (0.236, 0.382, 0.618 …) kesişimlerine konur.*)
(**)
(*isikKafesi[tohum, palet, yoğunluk, kılavuz] — palet varsayılanı "NeonGece"; diğer paletlerle de çalışır.*)


(* önizleme ve yüksek kalite ayarları ayrı: önce hızlı dene, sonra HQ ile dışa aktar *)
kafesOnizleme = <|"yogunluk" -> 0.35, "px" -> 600|>;
kafesHQ = <|"yogunluk" -> 1.4, "px" -> 3000|>;


isikKafesi[seed_Integer : 7, palName_String : "NeonGece", density_?NumericQ : 1., guide_ : False] := Module[
  {pal, pc, koyu, kobalt, mavi, turkuaz, macenta, pembe, turuncu, sari, altin, kemik, hale,
   gc, flip, ayna, sp, pole, vc, vs, vd, ph, cph, ton, karart, nz, seedsIn, cnt, akisKatmani, omurgaX,
   yAlt, yUst, nOmur = 20, q = phi^(-1/8), h0, omurH, omurY, m = 4, wMax = 0.29, d0 = 0.15, kaburgaY, kaburgaW,
   bg, wide, veins, kalin, cizgiler, sarmallar, yildizlar, omurlar, kaburgalar, sternum, patlama, guideLayer},

  SeedRandom[seed];
  pal = palettes[palName];
  pc = palColor[pal, #] &;
  (* NeonGece'nin 9 rengi sırayla 0, 1/8, …, 1 konumlarında *)
  {koyu, kobalt, mavi, turkuaz, macenta, pembe, turuncu, sari, altin} = pc /@ Range[0., 1., 1/8];
  kemik = {kobalt, mavi, turkuaz};        (* kemik fırçası: koyu kobalttan açık turkuaza *)
  hale = {sari, macenta};                 (* neon çift kontur *)

  (* altın yapı dikeyde (ve tohuma göre yatayda) aynalanır: kutup göğüs hizasına çıkar *)
  gc = goldenConstruction[14];
  flip = RandomReal[] < 0.5;
  ayna[{x_, y_}] := {If[flip, 1 - x, x], phi - y};
  sp = ayna /@ gc["Spiral"];
  pole = ayna[gc["Pole"]];

  (* akış alanı: ruhKatmanlari'yla aynı kurgu — girdaplar kutupta ve spiral üzerinde *)
  vc = {pole, sp[[61]], sp[[201]]};
  vs = {1., 1/phi, 1/phi^2};
  vd = {1., -1., 1.};
  ph = RandomReal[{0, 2 Pi}, 3];
  cph = RandomReal[{0, 2 Pi}, 3];

  (* renk alanı: kütlelerin ~%30'u lacivert-kobalt, geri kalanı macenta → kırmızı → turuncu *)
  ton[{x_, y_}, e_ : 0.] := Module[{v},
    v = Sin[2.1 x + cph[[1]]] Cos[1.9 y + cph[[2]]] + 0.5 Sin[3.3 (x - y) + cph[[3]]];
    v = Clip[(Tanh[1.6 v] + 1)/2 + e, {0., 1.}];
    If[v < 0.3, 0.02 + 0.13 v/0.3, 0.5 + 0.3 (v - 0.3)/0.7]];
  (* köşelere doğru kararma: kütleler kenarda koyulaşır, ışık ortada toplanır *)
  karart[{x_, y_}] := 1.1 - 0.65 Norm[{(x - 0.5)/0.5, (y - phi/2)/(phi/2)}]^2/2;

  nz[n_, s_] := RandomVariate[NormalDistribution[0, s], n];
  seedsIn[n_] := Transpose[{RandomReal[{0, 1}, n], RandomReal[{0, phi}, n]}];
  cnt[n_] := Max[10, Round[n density]];

  (* ruhKatmanlari'ndaki lineLayer'ın sıcak tonlu eşi: traceStrokes'u aynen kullanır *)
  akisKatmani[seeds_, steps_, dt_, {w1_, w2_}, alpha_, jitter_] := Module[
    {S = traceStrokes[seeds, vc, vs, vd, 1., ph, steps, dt], n = Length[seeds]},
    MapThread[
     {scaleColor[pc[ton[#2, #3]], karart[#2] #4], Opacity[alpha], kalinlik[#5], Line[#1]} &,
     {S, seeds, nz[n, jitter], RandomReal[{0.85, 1.15}, n], RandomReal[{w1, w2}, n]}]];

  (* omurga ekseni: kutuptan geçen hafif S eğrisi *)
  omurgaX = With[{A = RandomChoice[{-1, 1}] RandomReal[{0.025, 0.045}], px = pole[[1]], py = pole[[2]]},
    Function[y, px + A Sin[2 Pi (y - py)/2.]]];

  (* 1) zemin: büyük, yumuşak sıcak/koyu lekeler *)
  bg = Table[With[{c = {RandomReal[], RandomReal[{0, phi}]}},
     {scaleColor[pc[ton[c, RandomVariate[NormalDistribution[0, 0.1]]]], karart[c]], Opacity[0.28],
      Disk[c, RandomReal[{0.06, 0.3}]]}], {80}];

  (* 2) geniş, yarı saydam akış darbeleri  3) ince damarlar *)
  wide = akisKatmani[seedsIn[cnt[1100]], 18, 0.014, {8, 20}, 0.3, 0.08];
  veins = akisKatmani[seedsIn[cnt[1500]], 30, 0.006, {0.6, 2.2}, 0.55, 0.12];

  (* 4) birkaç kalın sıcak darbe: koyu gölge + üst üste üç saydam kat *)
  kalin = Module[{starts, S},
    starts = sp[[RandomSample[Range[700], 6]]] + nz[{6, 2}, 0.2];
    S = traceStrokes[starts, vc, vs, vd, 1., ph, 70, 0.009];
    Table[With[{t = ton[starts[[k]], 0.25], w = RandomReal[{18, 32}]},
      {{scaleColor[pc[t], 0.6], Opacity[0.35], kalinlik[w + 6], Line[S[[k]]]},
       Table[{pc[t + 0.06 i], Opacity[0.4], kalinlik[w (1 - 0.3 i)], Line[S[[k]] + nz[{Length[S[[k]]], 2}, 0.002]]},
        {i, 0, 2}]}],
     {k, Length[S]}]];

  (* 5) kısa çizgili doku: pembe-sarı kısa darbeler, tarama gibi *)
  cizgiler = {pc[RandomChoice[{0.62, 0.66, 0.86, 0.9}]], Opacity[0.75], kalinlik[RandomReal[{1.2, 3.5}]], Line[#]} & /@
    traceStrokes[seedsIn[cnt[700]], vc, vs, vd, 1., ph, 4, 0.009];

  (* 6) sarmal dokular: altın bölüm çizgilerinin kesişimlerinden kafesten ve omurgadan uzak olan 2-3 tanesi *)
  sarmallar = Module[{aday, secilen = {}},
    aday = Select[Tuples[{{0.236, 0.382, 0.618, 0.764}, phi {0.146, 0.236, 0.382, 0.618, 0.854}}],
      Norm[# - pole] > 0.45 && Abs[#[[1]] - omurgaX[#[[2]]]] > 0.2 &];
    Scan[Function[p, If[AllTrue[secilen, Norm[p - #] > 0.4 &], AppendTo[secilen, p]]], RandomSample[aday]];
    Table[sarmalDoku[c, Pi/2 + RandomChoice[{-1, 1}] RandomReal[{0.25, 1.3}], RandomReal[{0.3, 0.48}],
      RandomReal[{0.025, 0.04}], {pembe, sari}, {pembe, sari, macenta}],
     {c, Take[secilen, UpTo[RandomInteger[{2, 3}]]]}]];

  (* 7) köşelerde dağınık 4-8 kollu sivri yıldızlar; boyutları φ'nin kuvvetleri *)
  yildizlar = Table[With[{k = RandomChoice[{{0, 0}, {1, 0}, {0, 1}, {1, 1}}]},
     sivriYildiz[{Abs[k[[1]] - RandomReal[{0.02, 0.3}]], phi Abs[k[[2]] - RandomReal[{0.01, 0.2}]]},
      0.075/phi^RandomInteger[{0, 3}], RandomInteger[{4, 8}], pc[RandomReal[{0.85, 1.}]], altin]], {14}];

  (* 8) omurlar: aşağıdan yukarıya istiflenir, her adımda boyut q = φ^(-1/8) ile çarpılır *)
  yAlt = -0.03; yUst = Min[phi - 0.03, pole[[2]] + 0.42];
  h0 = (yUst - yAlt) (1 - q)/(1 - q^nOmur);
  omurH = h0 q^Range[0, nOmur - 1];
  omurY = yAlt + Accumulate[omurH] - omurH/2;
  omurlar = MapThread[Function[{yc, h}, Module[{xc, eg, ux, vy, a = 0.62 h, b = 0.34 h, govde},
      xc = omurgaX[yc];
      eg = (omurgaX[yc + 0.001] - omurgaX[yc - 0.001])/0.002;
      ux = Normalize[{1, -eg}]; vy = {-ux[[2]], ux[[1]]};    (* ux omurgaya dik, vy omurga boyunca *)
      govde = Table[{xc, yc} + a Sign[Cos[t]] Abs[Cos[t]]^0.6 ux + b Sign[Sin[t]] Abs[Sin[t]]^0.6 vy,
        {t, Subdivide[0., 2. Pi, 40]}];
      {{kobalt, Opacity[0.75], Polygon[govde]},
       titrekFirca[govde, kemik, 3 + 30 h, hale],
       Table[titrekFirca[dogruParca[{xc, yc} + sg 0.75 a ux + 0.1 h vy, {xc, yc} + sg (a + 0.45 h) ux + 0.25 h vy],
         kemik, 2 + 22 h, hale], {sg, {-1, 1}}]}]],
    {omurY, omurH}];

  (* 9) kaburgalar: kutbun iki yanına simetrik çiftler; aralık ve uzunluk φ kuvvetleriyle *)
  kaburgaY = With[{acc = Accumulate[d0 phi^(-(Range[m] - 0.5)/2)]},
    pole[[2]] + Join[-Reverse[acc], {0.}, acc]];
  kaburgaW = wMax phi^(-Abs[Range[-m, m]]/2);
  kaburgalar = MapThread[Function[{y0, w}, With[{x0 = omurgaX[y0], dd = 0.7 w},
      Table[titrekFirca[
        Table[{x0 + sg (0.012 + w Cos[th]), y0 - dd + dd Sin[th]}, {th, Subdivide[0.5 Pi, -Pi/6., 60]}],
        Append[kemik, altin], 6 + 14 w/wMax, hale], {sg, {-1, 1}}]]],
    {kaburgaY, kaburgaW}];

  (* 10) göğüs kemiği: ön orta hatta, en üst kaburgadan kutbun altına *)
  sternum = With[{yt = kaburgaY[[-1]] + 0.01, yb = kaburgaY[[m]] - 0.7 kaburgaW[[m]]},
    titrekFirca[dogruParca[{omurgaX[yt], yt}, {omurgaX[yb], yb}, 20], kemik, 14, hale]];

  (* 11) ışık patlaması — kafesin ÖNÜNDE; ışın açıları altın açının katları *)
  patlama = {
    Table[With[{a = k goldenAngle + RandomVariate[NormalDistribution[0, 0.04]],
        len = RandomReal[{0.12, 0.5}] If[Mod[k, 5] == 0, 1.4, 1.], w0 = RandomReal[{0.005, 0.018}]},
      With[{u = {Cos[a], Sin[a]}, nv = w0 {-Sin[a], Cos[a]}},
       {{pc[RandomReal[{0.82, 1.}]], Opacity[0.45], Polygon[{pole + nv, pole + len u, pole - nv}]},
        {altin, Opacity[0.7], Polygon[{pole + 0.3 nv, pole + 0.85 len u, pole - 0.3 nv}]}}]],
     {k, 0, 59}],
    (* fırçayla çekilmiş birkaç ışın: patlama da boyalı görünsün *)
    Table[With[{a = RandomReal[{0, 2 Pi}]},
      titrekFirca[dogruParca[pole + 0.03 {Cos[a], Sin[a]}, pole + RandomReal[{0.15, 0.38}] {Cos[a], Sin[a]}],
       {sari, altin, RGBColor[1, 1, 1]}, RandomReal[{4, 9}]]], {12}],
    Table[{altin, Opacity[ro[[2]]], Disk[pole, ro[[1]]]},
     {ro, {{0.16, 0.12}, {0.09, 0.25}, {0.045, 0.6}, {0.02, 0.95}}}]};

  (* kılavuz: aynalanmış kareler, spiral ve kutup *)
  guideLayer = If[TrueQ[guide],
    {White, Opacity[0.8], kalinlik[0.8],
     Line[ayna /@ {#[[;; 2]], #[[;; 2]] + {#[[3]], 0}, #[[;; 2]] + #[[3]], #[[;; 2]] + {0, #[[3]]}, #[[;; 2]]}] & /@
      gc["Squares"],
     Line[sp],
     Red, Opacity[1], Disk[pole, 0.006]},
    {}];

  Graphics[
   {CapForm["Round"], JoinForm["Round"],
    bg, wide, veins, kalin, cizgiler, sarmallar, yildizlar, omurlar, kaburgalar, sternum, patlama, guideLayer},
   PlotRange -> {{0, 1}, {0, phi}}, PlotRangePadding -> None, AspectRatio -> Automatic,
   Background -> Darker[koyu, 0.2], ImageSize -> 600]
  ];


(* ::Text:: *)
(*Önizleme ayarlarıyla iki örnek (birkaç saniye). Neon görünüm için parlama 0.3 yerine 0.4.*)


kafes1 = finish[isikKafesi[7, "NeonGece", kafesOnizleme["yogunluk"]], kafesOnizleme["px"], 0.4]


kafes2 = finish[isikKafesi[40, "NeonGece", kafesOnizleme["yogunluk"]], kafesOnizleme["px"], 0.4]


(* Altın oran kılavuzu: aynalanmış kareler, spiral ve kutup *)
isikKafesi[7, "NeonGece", kafesOnizleme["yogunluk"], True]


(* Baskı kalitesi (≈ 25 × 40 cm, 300 dpi) *)
(*
Export[FileNameJoin[{$HomeDirectory, "Desktop", "isik_kafesi_7.png"}],
  finish[isikKafesi[7, "NeonGece", kafesHQ["yogunluk"]], kafesHQ["px"], 0.4]];
*)


(* ::Section:: *)
(*11. Mod 2 — Eriyen Maskeler (hayalet yüzler, akan yağlıboya)*)


(* ::Text:: *)
(*Pembe-lila-sarı pastel, sisli bir zemin; kenarlarda patlıcan moru girdaplar. Üstünde 3-5 asit yeşili / turkuaz*)
(*hayalet maske: yamuk yüz silüetleri, koyu mor yarık gözler ve ağız. Biri koyu mor ve tek mavi gözlü.*)
(*Maskeler aşağı doğru eriyor: alt kenarlarından uzun dikey damlalar ve sürüntüler iniyor.*)
(*Yağlıboya hissi iki adımda gelir: geniş, saydam, üst üste sürülmüş fırça katmanları ve sonda "smear" işlemi.*)
(*İnce damar katmanı yok: keskin çizgi istemiyoruz.*)
(**)
(*ALTIN ORAN NEREDE?*)
(*  • Işık Kafesi'ndeki gibi altın yapı dikeyde (tohuma göre yatayda da) aynalanır: kutup yukarıda kalır,*)
(*    maskelerin aşağı akacak yeri olur.*)
(*  • En büyük maske kutupta; diğer merkezler altın spiral üzerinden seçilir, yarıçaplar sırayla φ'ye bölünür.*)
(*  • Zemin girdapları tuval kenarlarının altın bölüm noktalarında (0.382, 0.618); güçleri 1, 1/φ, 1/φ², 1/φ³.*)
(**)
(*Maske şekli: r(θ) = r0 (1 + Σ a_k Sin[kθ + φ_k]), k = 2…5; alt yarı uzatılır, hafifçe eğilip yamultulur.*)
(*Erime: maskenin alt kenarındaki noktalar traceStrokes ile akış alanında kısa bir yol izler; bu yolun en çok*)
(*%30'u alınır (küçük maskelerde daha az) ve üzerine aşağı (negatif y) doğru bir iniş eklenir —*)
(*damla hem düşer hem hafifçe akışa kapılır.*)


(* ::Text:: *)
(*smear[görüntü, kayma, bulanıklık] — yağlıboya sürüntüsü son işlemi:*)
(*  1) düşük frekanslı iki gürültü alanı (küçük rastgele ızgara, görüntü boyutuna büyütülmüş) her pikseli birkaç*)
(*     piksel kaydırır: boya ıslakken sürülmüş gibi;*)
(*  2) dikey çizgi çekirdeğiyle (ImageConvolve) hafif hareket bulanıklığı: aşağı akış hissi.*)
(*kayma ve bulanıklık 600 px genişliğe göre piksel cinsindendir; büyük çıktıda kendiliğinden ölçeklenir.*)
(*Her moda uygulanabilir, ör. smear[finish[ruhKatmanlari[11, "Toprak"]]].*)


(* her pikseli (dx, dy) kadar ötedeki pikselden okur — derlenmiş, 3000 px'te de hızlı *)
smearKaydir = Compile[{{a, _Real, 3}, {dx, _Real, 2}, {dy, _Real, 2}},
   Module[{h = Length[a], w = Length[a[[1]]], out = a, si = 1, sj = 1},
    Do[
     si = Min[h, Max[1, Round[i + dy[[i, j]]]]];
     sj = Min[w, Max[1, Round[j + dx[[i, j]]]]];
     out[[i, j]] = a[[si, sj]],
     {i, h}, {j, w}];
    out],
   RuntimeOptions -> "Speed"];

smear[img_Image, amp_ : 4., blur_ : 6] := Module[{a, h, w, k, alan, dx, dy, n, ker, b},
   a = ImageData[ColorConvert[RemoveAlphaChannel[img], "RGB"], "Real"];
   {h, w} = Dimensions[a][[;; 2]];
   k = w/600.;                                  (* 600 px'e göre ölçek *)
   (* düşük frekanslı gürültü: 5 × 8'lik rastgele ızgara görüntü boyutuna büyütülür, değerler −1…1 *)
   alan[] := 2 ImageData[ImageResize[Image[RandomReal[1, {8, 5}]], {w, h}], "Real"] - 1;
   dx = amp k alan[];
   dy = amp k alan[];
   a = smearKaydir[a, dx, dy];
   (* dikey hareket bulanıklığı: tek sütunlu, Gauss ağırlıklı çizgi çekirdeği *)
   n = Max[1, Round[blur k]];
   ker = Transpose[{Normalize[Table[Exp[-(i/(0.5 n))^2], {i, -n, n}], Total]}];
   b = ImageData[ImageConvolve[Image[a], ker], "Real"];
   Image[Clip[0.45 a + 0.55 b, {0., 1.}]]
   ];


(* önizleme ve yüksek kalite ayarları ayrı: önce hızlı dene, sonra HQ ile dışa aktar *)
maskeOnizleme = <|"yogunluk" -> 0.35, "px" -> 600|>;
maskeHQ = <|"yogunluk" -> 1.4, "px" -> 3000|>;


eriyenMaskeler[seed_Integer : 5, palName_String : "PastelRuh", density_?NumericQ : 1., guide_ : False] := Module[
  {pal, pc, koyu, lila, pembe, seftali, sari, yesil, turkuaz, maviGoz = hex["#4f86ff"], beyaz = RGBColor[1, 1, 1],
   gc, flip, ayna, sp, pole, vc, vs, vd, ph, cph, ton, kenar, renk, nz, seedsIn, cnt, sisKatmani,
   r0, merkezler, nMaske, koyuMaske, maske,
   bg, sis, genis, orta, maskeler, ustSis, guideLayer},

  SeedRandom[seed];
  pal = palettes[palName];
  pc = palColor[pal, #] &;
  (* PastelRuh'un 7 rengi sırayla 0, 1/6, …, 1 konumlarında *)
  {koyu, lila, pembe, seftali, sari, yesil, turkuaz} = pc /@ (Range[0, 6]/6.);

  (* altın yapı: Işık Kafesi'ndeki gibi aynalanır *)
  gc = goldenConstruction[14];
  flip = RandomReal[] < 0.5;
  ayna[{x_, y_}] := {If[flip, 1 - x, x], phi - y};
  sp = ayna /@ gc["Spiral"];
  pole = ayna[gc["Pole"]];

  (* zemin girdapları kenarların altın bölüm noktalarında; güçler φ'nin kuvvetleri, yönler dönüşümlü *)
  vc = ayna /@ {{0., 0.382 phi}, {1., 0.618 phi}, {0.618, 0.}, {0.382, phi}};
  vs = 1./phi^Range[0, 3];
  vd = {1., -1., 1., -1.};
  ph = RandomReal[{0, 2 Pi}, 3];
  cph = RandomReal[{0, 2 Pi}, 3];

  (* pastel renk alanı: lila → toz pembe → şeftali → tereyağı sarısı *)
  ton[{x_, y_}, e_ : 0.] := Module[{v},
    v = Sin[1.7 x + cph[[1]]] Cos[1.3 y + cph[[2]]] + 0.5 Sin[2.6 (x + y) + cph[[3]]];
    1/6. + 0.5 Clip[(Tanh[1.4 v] + 1)/2 + e, {0., 1.}]];
  (* kenara yaklaştıkça patlıcan moruna kayış *)
  kenar[{x_, y_}] := Clip[1.15 Exp[-Min[x, 1 - x, y, phi - y]/0.08], {0., 0.95}];
  renk[p_, e_ : 0.] := Blend[{pc[ton[p, e]], koyu}, kenar[p]];

  nz[n_, s_] := RandomVariate[NormalDistribution[0, s], n];
  seedsIn[n_] := Transpose[{RandomReal[{0, 1}, n], RandomReal[{0, phi}, n]}];
  cnt[n_] := Max[10, Round[n density]];

  (* yumuşak akış darbeleri: traceStrokes'u kenar girdaplarıyla kullanır *)
  sisKatmani[seeds_, steps_, dt_, {w1_, w2_}, alpha_, jitter_] := Module[
    {S = traceStrokes[seeds, vc, vs, vd, 0.8, ph, steps, dt], n = Length[seeds]},
    MapThread[{renk[#2, #3], Opacity[alpha], kalinlik[#4], Line[#1]} &,
     {S, seeds, nz[n, jitter], RandomReal[{w1, w2}, n]}]];

  (* 1) zemin lekeleri  2) sis: büyük, çok saydam, açık lekeler *)
  bg = Table[With[{c = {RandomReal[], RandomReal[{0, phi}]}},
     {renk[c, RandomVariate[NormalDistribution[0, 0.1]]], Opacity[0.25], Disk[c, RandomReal[{0.08, 0.32}]]}], {110}];
  sis = Table[{Blend[{RandomChoice[{pembe, sari, lila}], beyaz}, 0.4], Opacity[0.08],
     Disk[{RandomReal[], RandomReal[{0, phi}]}, RandomReal[{0.15, 0.4}]]}, {40}];

  (* 3) geniş sürülmüş darbeler  4) orta kalınlıkta, yine yumuşak darbeler *)
  genis = sisKatmani[seedsIn[cnt[1000]], 20, 0.013, {12, 30}, 0.22, 0.08];
  orta = sisKatmani[seedsIn[cnt[1300]], 26, 0.008, {4, 10}, 0.3, 0.1];

  (* 5) maske merkezleri: en büyüğü kutupta, diğerleri altın spiral üzerinde; yarıçap her maskede φ'ye bölünür *)
  r0 = 0.21/phi^Range[0, RandomInteger[{3, 5}] - 1];
  merkezler = {pole};
  Do[
   With[{aday = Select[sp[[;; ;; 8]], Function[p,
        AllTrue[Range[Length[merkezler]], Norm[p - merkezler[[#]]] > 0.85 (r0[[#]] + r0[[k]]) &] &&
         r0[[k]] < p[[1]] < 1 - r0[[k]] && 0.3 < p[[2]] < phi - 1.1 r0[[k]]]]},
    If[aday =!= {}, AppendTo[merkezler, RandomChoice[aday]], Break[]]],
   {k, 2, Length[r0]}];
  nMaske = Length[merkezler];
  r0 = Take[r0, nMaske];
  koyuMaske = If[nMaske >= 2, RandomInteger[{2, Min[3, nMaske]}], 0];     (* koyu mor, tek mavi gözlü maske *)

  maske[k_] := Module[
    {c = merkezler[[k]], r = r0[[k]], koyuMu = (k == koyuMaske), rot, loc, a, fz, sh, sekil,
     govde, isik, parilti, damlaRengi, alt, bas, S, damlalar, yarik, gozler, agiz},
    rot = RotationMatrix[RandomReal[{-0.25, 0.25}]];
    loc[{u_, v_}] := c + rot.{u, v};                 (* maskenin yerel koordinatından tuvale *)
    a = RandomReal[{0.03, 0.12}, 4]/{1., 1.3, 1.7, 2.2};
    fz = RandomReal[{0, 2 Pi}, 4];
    sh = RandomReal[{-0.2, 0.2}];                     (* yamukluk: yüksekliğe oranlı yatay kayma *)
    (* r(θ) = r0 (1 + Σ a_k Sin[kθ + φ_k]); alt yarı (Sin θ < 0) uzatılır, genişlik daraltılır *)
    sekil[s_] := Table[With[{rr = s r (1 + Total[a Sin[Range[2, 5] th + fz]]), yv = (1.12 - 0.28 Sin[th]) Sin[th]},
       loc[rr {0.82 Cos[th] + sh yv, yv}]], {th, Subdivide[0., 2. Pi, 72]}];

    govde = If[koyuMu, Blend[{koyu, lila}, 0.15], pc[RandomReal[{5/6., 1.}]]];    (* asit yeşili ↔ turkuaz *)
    isik = Blend[{govde, If[koyuMu, lila, sari]}, 0.45];
    parilti = If[koyuMu, lila, govde];
    damlaRengi := If[koyuMu, Blend[{koyu, lila}, RandomReal[{0., 0.3}]], Blend[{yesil, turkuaz}, RandomReal[]]];

    (* erime: alt kenardan (Sin θ < −0.25) başlayan damlalar; akış payı en çok %30 (küçük maskede daha az),*)
    (* gerisi aşağı iniş *)
    alt = Select[Transpose[{Most[Subdivide[0., 2. Pi, 72]], Most[sekil[0.9]]}], Sin[#[[1]]] < -0.25 &][[All, 2]];
    bas = RandomChoice[alt, Round[4 + 50 r]];
    bas = bas + Transpose[{nz[Length[bas], 0.05 r], ConstantArray[0., Length[bas]]}];
    S = traceStrokes[bas, vc, vs, vd, 0.8, ph, 40, 0.004];
    damlalar = Table[
      With[{L = Max[0.05, Min[bas[[i, 2]] - 0.02, r RandomReal[{0.5, 3.2}]]], w = RandomReal[{0.08, 0.2}] r/0.0015,
        dr = damlaRengi},
       With[{yol = Map[Function[q, bas[[i]] + Min[0.3, 1.4 r] (q - bas[[i]])], S[[i]]] +
           Transpose[{ConstantArray[0., 40], -L Subdivide[0., 1., 39]}]},
        {(* arkada: geniş, çok saydam sürüntü *)
         {dr, Opacity[0.12], kalinlik[2.4 w], Line[yol]},
         (* önde: yukarıda kalın, aşağı doğru incelen damla ve uçta damlacık *)
         {{dr, Opacity[0.4], kalinlik[w], Line[yol[[;; 26]]]},
          {dr, Opacity[0.45], kalinlik[0.65 w], Line[yol[[;; 36]]]},
          {Blend[{dr, sari}, 0.3], Opacity[0.45], kalinlik[0.3 w], Line[yol]},
          {dr, Opacity[0.55], Disk[Last[yol], 0.0015 0.4 w]}}}]],
      {i, Length[bas]}];

    (* yarık: ince, eğik elips; yumuşak kenar için önce geniş-saydam, sonra koyu çekirdek *)
    yarik[m_, {ax_, ay_}, ang_, col_] := Table[
      {col, Opacity[so[[2]]], Polygon[Table[loc[m + so[[1]] RotationMatrix[ang].{ax Cos[t], ay Sin[t]}],
          {t, Subdivide[0., 2. Pi, 30]}]]},
      {so, {{1.7, 0.2}, {1., 0.85}}}];

    gozler = If[koyuMu,
      (* koyu maske: tek, mavi göz *)
      With[{m = {RandomChoice[{-1, 1}] 0.3 r, 0.14 r}},
       {yarik[m, {0.13 r, 0.08 r}, RandomReal[{-0.3, 0.3}], maviGoz],
        {beyaz, Opacity[0.7], Disk[loc[m + {0.03 r, 0.025 r}], 0.018 r]}}],
      (* yeşil maskeler: iki eğik yarık, hafif asimetrik *)
      With[{al = RandomChoice[{-1, 1}] RandomReal[{0.1, 0.4}]},
       Table[yarik[{sg 0.32 r + RandomVariate[NormalDistribution[0, 0.04 r]],
          0.14 r + RandomVariate[NormalDistribution[0, 0.04 r]]},
         {0.2 r RandomReal[{0.8, 1.2}], 0.04 r RandomReal[{0.7, 1.4}]},
         sg al + RandomVariate[NormalDistribution[0, 0.12]], koyu], {sg, {-1, 1}}]]];

    agiz = With[{my = -RandomReal[{0.36, 0.48}] r, mx = RandomVariate[NormalDistribution[0, 0.05 r]],
       egri = RandomReal[{-0.1, 0.1}] r, eg = RandomReal[{-0.15, 0.15}],
       col = If[koyuMu, Blend[{koyu, RGBColor[0, 0, 0]}, 0.5], koyu]},
      If[RandomReal[] < 0.5,
       (* kısa, kalın fırça yayı *)
       titrekFirca[Table[loc[{mx + 0.26 r u, my + egri u^2 + eg 0.26 r u}], {u, Subdivide[-1., 1., 24]}],
        {col, col, Blend[{col, lila}, 0.3]}, 0.07 r/0.0015],
       (* ya da geniş, ince bir yarık *)
       yarik[{mx, my}, {0.27 r, 0.045 r}, eg, col]]];

    {
     (* arka: hayalet parıltısı ve damla sürüntüleri *)
     {parilti, Opacity[0.1], Polygon[sekil[1.3]]},
     {parilti, Opacity[0.16], Polygon[sekil[1.12]]},
     damlalar[[All, 1]],
     (* gövde: dolgu + iç içe, yumuşak sürülmüş halkalar; içe doğru açılır *)
     {govde, Opacity[0.7], Polygon[sekil[1.]]},
     Table[titrekFirca[sekil[s], {Blend[{govde, koyu}, 0.2], govde, Blend[{govde, isik}, 1 - s]}, 150 r],
      {s, {0.92, 0.72, 0.52, 0.32}}],
     damlalar[[All, 2]],
     gozler,
     agiz
     }];

  (* küçükten büyüğe: en büyük maske (kutuptaki) en önde *)
  maskeler = maske /@ Reverse[Range[nMaske]];

  (* 6) her şeyin üstünde ince bir sis *)
  ustSis = Table[{Blend[{pembe, beyaz}, 0.5], Opacity[0.05],
     Disk[{RandomReal[], RandomReal[{0, phi}]}, RandomReal[{0.2, 0.45}]]}, {18}];

  (* kılavuz: aynalanmış kareler, spiral, kutup ve maske yarıçapları *)
  guideLayer = If[TrueQ[guide],
    {White, Opacity[0.8], kalinlik[0.8],
     Line[ayna /@ {#[[;; 2]], #[[;; 2]] + {#[[3]], 0}, #[[;; 2]] + #[[3]], #[[;; 2]] + {0, #[[3]]}, #[[;; 2]]}] & /@
      gc["Squares"],
     Line[sp],
     Dashing[{0.01, 0.01}], MapThread[Circle, {merkezler, r0}],
     Red, Opacity[1], Disk[pole, 0.006]},
    {}];

  Graphics[
   {CapForm["Round"], JoinForm["Round"],
    bg, sis, genis, orta, maskeler, ustSis, guideLayer},
   PlotRange -> {{0, 1}, {0, phi}}, PlotRangePadding -> None, AspectRatio -> Automatic,
   Background -> pembe, ImageSize -> 600]
  ];


(* ::Text:: *)
(*Önizleme ayarlarıyla iki örnek. Pastel zeminde parlama düşük tutulur (0.2); smear en sonda.*)


maske1 = smear[finish[eriyenMaskeler[5, "PastelRuh", maskeOnizleme["yogunluk"]], maskeOnizleme["px"], 0.2]]


maske2 = smear[finish[eriyenMaskeler[18, "PastelRuh", maskeOnizleme["yogunluk"]], maskeOnizleme["px"], 0.2]]


(* Altın oran kılavuzu: aynalanmış kareler, spiral, kutup ve maske yarıçapları (kesikli daireler) *)
eriyenMaskeler[5, "PastelRuh", maskeOnizleme["yogunluk"], True]


(* Baskı kalitesi (≈ 25 × 40 cm, 300 dpi) *)
(*
Export[FileNameJoin[{$HomeDirectory, "Desktop", "eriyen_maskeler_5.png"}],
  smear[finish[eriyenMaskeler[5, "PastelRuh", maskeHQ["yogunluk"]], maskeHQ["px"], 0.2]]];
*)


(* ::Section:: *)
(*12. Ortak stüdyo — üç mod tek panelde*)


(* ::Text:: *)
(*mod   : Ruh Katmanları / Işık Kafesi / Eriyen Maskeler*)
(*palet : "Otomatik" ise modun kendi paleti (Kozmik / NeonGece / PastelRuh); istenirse başka palet seçilebilir*)
(*girdap yalnız Ruh Katmanları'nı etkiler.*)
(*"önizleme" açıkken her mod kendi önizleme yoğunluğuyla, son işlem olmadan hızlı çizer.*)
(*Kaydırıcıyı bırakınca resim yeniden çizilir (her çizim birkaç saniye sürebilir).*)
(*"Kaydet" en son ayarları her modun HQ yoğunluğuyla 3000 piksel genişlikte masaüstüne PNG olarak yazar.*)


(* her mod için: varsayılan palet, önizleme/HQ yoğunluk çarpanı, dosya adı, çizim ve son işlem *)
modlar = <|
   "Ruh Katmanları" -> <|"palet" -> "Kozmik", "onizleme" -> 0.35, "hq" -> 1.4, "dosya" -> "ruh_katmanlari_",
     "ciz" -> (ruhKatmanlari[#1, #2, #3, #4, #5] &), "bitir" -> (finish[#1, #2] &)|>,
   "Işık Kafesi" -> <|"palet" -> "NeonGece", "onizleme" -> kafesOnizleme["yogunluk"], "hq" -> kafesHQ["yogunluk"],
     "dosya" -> "isik_kafesi_", "ciz" -> (isikKafesi[#1, #2, #4, #5] &), "bitir" -> (finish[#1, #2, 0.4] &)|>,
   "Eriyen Maskeler" -> <|"palet" -> "PastelRuh", "onizleme" -> maskeOnizleme["yogunluk"], "hq" -> maskeHQ["yogunluk"],
     "dosya" -> "eriyen_maskeler_", "ciz" -> (eriyenMaskeler[#1, #2, #4, #5] &),
     "bitir" -> (smear[finish[#1, #2, 0.2]] &)|>
   |>;

modPalet[mod_, pal_] := If[pal === "Otomatik", modlar[mod]["palet"], pal];

(* ciz argümanları: tohum, palet, girdap, yoğunluk, kılavuz *)
eserCiz[mod_, seed_, pal_, swirl_, density_, guide_] :=
  modlar[mod]["ciz"][seed, modPalet[mod, pal], N[swirl], N[density], guide];

eserBitir[mod_, g_, px_] := modlar[mod]["bitir"][g, px];


Manipulate[
 If[preview,
  eserCiz[mod, seed, pal, swirl, modlar[mod]["onizleme"] density, guide],
  eserBitir[mod, eserCiz[mod, seed, pal, swirl, density, guide], 700]],
 {{mod, "Ruh Katmanları", "mod"}, Keys[modlar]},
 {{seed, 11, "tohum"}, 1, 500, 1, Appearance -> "Labeled"},
 {{pal, "Otomatik", "palet"}, Prepend[Keys[palettes], "Otomatik"]},
 {{swirl, 1., "girdap (Ruh Katmanları)"}, 0., 2.5, Appearance -> "Labeled"},
 {{density, 1., "yoğunluk"}, 0.3, 1.6, Appearance -> "Labeled"},
 {{guide, False, "altın oran kılavuzu"}, {False, True}},
 {{preview, True, "önizleme"}, {True, False}},
 Delimiter,
 Row[{
   Button["Rastgele", seed = RandomInteger[{1, 500}]],
   Spacer[10],
   Button["Kaydet (3000 px)",
    Export[FileNameJoin[{$HomeDirectory, "Desktop",
       modlar[mod]["dosya"] <> modPalet[mod, pal] <> "_" <> ToString[seed] <> ".png"}],
     eserBitir[mod, eserCiz[mod, seed, pal, swirl, modlar[mod]["hq"] density, False], 3000]],
    Method -> "Queued"]}],
 ControlPlacement -> Left,
 ContinuousAction -> False,
 SynchronousUpdating -> False,
 SaveDefinitions -> True]
