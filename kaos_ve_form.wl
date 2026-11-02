(* ::Package:: *)

(* ::Title:: *)
(*Kaos ve Form \[LongDash] Mathematica ile \[CapitalUDoubleDot]retken Sanat*)


(* ::Text:: *)
(*Mathematica'da a\[CCedilla]\:0131n ve \[UDoubleDot]stteki "Run All Code" d\[UDoubleDot]\:011fmesine bas, ya da her b\[ODoubleDot]l\[UDoubleDot]m\[UDoubleDot] tek tek \[CCedilla]al\:0131\:015ft\:0131r.*)
(*Mathematica 12 veya \[UDoubleDot]st\[UDoubleDot] gerekir (ComplexPlot i\[CCedilla]in).*)
(*Son b\[ODoubleDot]l\[UDoubleDot]m (6. Animasyonlar) nefes alan bir Gyroid, d\[ODoubleDot]n\[UDoubleDot]\:015fen bir Clifford \[CCedilla]ekicisi ve d\[ODoubleDot]nen bir karma\:015f\:0131k d\[UDoubleDot]zlem i\[CCedilla]erir: her biri notebook i\[CCedilla]inde \[ODoubleDot]nizlenir, MP4 olarak d\:0131\:015fa aktarma kodu da yorum i\[CCedilla]inde haz\:0131rd\:0131r (Mathematica 12.1 veya \[UDoubleDot]st\[UDoubleDot]). Bu \[ODoubleDot]nizlemeler "Run All Code" ile birlikte birka\[CCedilla] dakika s\[UDoubleDot]rebilir.*)


(* ::Section:: *)
(*1. Clifford \[CapitalCCedilla]ekicisi \[LongDash] Yo\:011funluk Haritas\:0131*)


(* ::Text:: *)
(*\:0130ki basit trigonometrik denklem milyonlarca kez yinelenir. Noktalar ayn\:0131 yerlere tekrar tekrar d\[UDoubleDot]\:015fer; her pikselin ka\[CCedilla] kez ziyaret edildi\:011fi say\:0131l\:0131r ve logaritmik \[ODoubleDot]l\[CCedilla]ekle renge \[CCedilla]evrilir. Sonu\[CCedilla] ipek ya da duman gibi g\[ODoubleDot]r\[UDoubleDot]nen bir doku.*)


cliffordPoints = Compile[{{a, _Real}, {b, _Real}, {c, _Real}, {d, _Real}, {n, _Integer}},
   Module[{x = 0.1, y = 0.1, xn = 0.},
    Table[
     xn = Sin[a y] + c Cos[a x];
     y = Sin[b x] + d Cos[b y];
     x = xn;
     {x, y}, {n}]
    ],
   RuntimeOptions -> "Speed"];

(* \[CapitalODoubleDot]zel renk ge\[CCedilla]i\:015fleri: siyahtan ba\:015flamalar\:0131 \[ODoubleDot]nemli, b\[ODoubleDot]ylece bo\:015fluk karanl\:0131k kal\:0131r *)
gradients = <|
   "Ate\:015f"    -> (Blend[{Black, RGBColor[0.35, 0, 0.25], RGBColor[0.9, 0.25, 0.1], RGBColor[1, 0.8, 0.3], White}, #] &),
   "Okyanus" -> (Blend[{Black, RGBColor[0, 0.1, 0.3], RGBColor[0, 0.55, 0.7], RGBColor[0.6, 1, 0.95], White}, #] &),
   "Aurora"  -> (Blend[{Black, RGBColor[0.1, 0, 0.3], RGBColor[0.3, 0.2, 0.9], RGBColor[0.2, 0.95, 0.6], White}, #] &),
   "G\[UDoubleDot]n bat\:0131m\:0131" -> ColorData["SunsetColors"]
   |>;

attractorArt[{a_, b_, c_, d_}, n_Integer : 3000000, res_Integer : 1000, grad_String : "Ate\:015f", gamma_ : 0.55] :=
  Module[{pts, xr, yr, counts, m},
   pts = cliffordPoints[a, b, c, d, n];
   xr = 1. + Abs[c]; yr = 1. + Abs[d];
   counts = BinCounts[pts, {-xr, xr, 2 xr/res}, {-yr, yr, 2 yr/res}];
   m = Log[1. + counts];
   m = (m/Max[m])^gamma;                       (* gamma < 1 -> daha parlak, "\:0131\:015f\:0131ldayan" g\[ODoubleDot]r\[UDoubleDot]n\[UDoubleDot]m *)
   ArrayPlot[Reverse@Transpose@m,
    ColorFunction -> gradients[grad], ColorFunctionScaling -> False,
    Frame -> False, PlotRangePadding -> None, ImageSize -> 800, Background -> Black]
   ];


(* \[CapitalUDoubleDot]\[CCedilla] farkl\:0131 parametre seti \[LongDash] her biri bamba\:015fka bir form *)
art1 = attractorArt[{-1.4, 1.6, 1.0, 0.7}, 3000000, 1000, "Ate\:015f"]


art2 = attractorArt[{1.7, 1.7, 0.6, 1.2}, 3000000, 1000, "Okyanus"]


art3 = attractorArt[{-1.7, 1.3, -0.1, -1.2}, 3000000, 1000, "Aurora"]


(* ::Section:: *)
(*2. Karma\:015f\:0131k D\[UDoubleDot]zlem \[LongDash] Alan Renklendirmesi*)


(* ::Text:: *)
(*Her nokta z bir karma\:015f\:0131k say\:0131d\:0131r. Fonksiyonun \[ADoubleDot]\[CCedilla]\:0131s\:0131 (arg\[UDoubleDot]man) renk tonunu, b\[UDoubleDot]y\[UDoubleDot]kl\[UDoubleDot]\:011f\[UDoubleDot]n\[UDoubleDot]n logaritmas\:0131 parlakl\:0131k halkalar\:0131n\:0131 belirler. Sin[1/z] terimi s\:0131f\:0131r\:0131n \[CCedilla]evresinde sonsuz ince ayr\:0131nt\:0131 \[UDoubleDot]reten "esasl\:0131 tekillik" yarat\:0131r.*)


art4 = ComplexPlot[(z^5 - 1)/(z^2 + 0.3 I) + Sin[1/z],
  {z, -2 - 2 I, 2 + 2 I},
  ColorFunction -> "CyclicLogAbsArg",
  PlotPoints -> 120, MaxRecursion -> 3,
  Frame -> False, ImageSize -> 800]


(* ::Section:: *)
(*3. Gyroid K\[UDoubleDot]re \[LongDash] 3B \[CapitalODoubleDot]rt\[UDoubleDot]k Y\[UDoubleDot]zey*)


(* ::Text:: *)
(*Gyroid, kelebek kanatlar\:0131ndaki nano-yap\:0131larda da g\[ODoubleDot]r\[UDoubleDot]len, kendini hi\[CCedilla] kesmeyen sonsuz bir y\[UDoubleDot]zeydir. Burada bir k\[UDoubleDot]reyle k\:0131rp\:0131l\:0131p merkezden d\:0131\:015far\:0131 renk ge\[CCedilla]i\:015fiyle boyan\:0131yor. Fareyle s\[UDoubleDot]r\[UDoubleDot]kleyerek d\[ODoubleDot]nd\[UDoubleDot]rebilirsin.*)


art5 = ContourPlot3D[
  Sin[x] Cos[y] + Sin[y] Cos[z] + Sin[z] Cos[x] == 0,
  {x, -2 Pi, 2 Pi}, {y, -2 Pi, 2 Pi}, {z, -2 Pi, 2 Pi},
  RegionFunction -> Function[{x, y, z}, x^2 + y^2 + z^2 < (2 Pi)^2],
  ColorFunction -> Function[{x, y, z},
    Blend[{RGBColor[1, 0.85, 0.4], RGBColor[0.95, 0.3, 0.35], RGBColor[0.3, 0.15, 0.6]},
     Norm[{x, y, z} - {0.5, 0.5, 0.5}]/0.87]],
  ColorFunctionScaling -> True,
  Mesh -> None, PlotPoints -> 60, MaxRecursion -> 1,
  Lighting -> "Neutral",
  PlotStyle -> Directive[Specularity[White, 30]],
  Boxed -> False, Axes -> False, Background -> Black,
  ViewPoint -> {2.2, -1.6, 1.4}, ImageSize -> 800]


(* ::Section:: *)
(*4. Canl\:0131 St\[UDoubleDot]dyo \[LongDash] \:0130nteraktif Aray\[UDoubleDot]z*)


(* ::Text:: *)
(*Kayd\:0131r\:0131c\:0131larla \[CCedilla]ekicinin d\[ODoubleDot]rt parametresini de\:011fi\:015ftir. S\[UDoubleDot]r\[UDoubleDot]klerken d\[UDoubleDot]\:015f\[UDoubleDot]k \[CCedilla]\[ODoubleDot]z\[UDoubleDot]n\[UDoubleDot]rl\[UDoubleDot]kte h\:0131zl\:0131 \[ODoubleDot]nizleme g\[ODoubleDot]r\[UDoubleDot]rs\[UDoubleDot]n, b\:0131rak\:0131nca tam kalitede \[CCedilla]izilir. "Rastgele" ke\:015ffetmek, "Kaydet" PNG olarak d\:0131\:015fa aktarmak i\[CCedilla]in.*)


(* "Rastgele" d\[UDoubleDot]\:011fmesi i\[CCedilla]in: baz\:0131 parametreler (\[ODoubleDot]r. a ya da b s\:0131f\:0131ra yak\:0131nken) \[CCedilla]ekiciyi birka\[CCedilla] noktaya \[CCedilla]\[ODoubleDot]kertir
   ve ekran siyah kal\:0131r. canliMi, 100 \[Times] 100 \:0131zgarada en az 300 h\[UDoubleDot]cre dolu mu diye bakar (kaotik \[CCedilla]ekiciler
   binlercesini doldurur); canliParametre bu s\:0131nav\:0131 ge\[CCedilla]en bir set bulana kadar en \[CCedilla]ok 50 kez yeniden \[CCedilla]eker. *)
canliMi[{a_, b_, c_, d_}] := Module[{pts = Drop[cliffordPoints[a, b, c, d, 21000], 1000]},
   Count[Flatten@BinCounts[pts, {-1 - Abs[c], 1 + Abs[c], (2 + 2 Abs[c])/100},
      {-1 - Abs[d], 1 + Abs[d], (2 + 2 Abs[d])/100}], _?Positive] > 300];
canliParametre[] := Module[{p, k = 0},
   While[k++ < 50, p = RandomReal[{-2.5, 2.5}, 4]; If[canliMi[p], Break[]]];
   p];


Manipulate[
 attractorArt[{a, b, c, d},
  ControlActive[150000, n], ControlActive[350, 800], grad, gamma],
 {{a, -1.4}, -3, 3, Appearance -> "Labeled"},
 {{b, 1.6}, -3, 3, Appearance -> "Labeled"},
 {{c, 1.0}, -3, 3, Appearance -> "Labeled"},
 {{d, 0.7}, -3, 3, Appearance -> "Labeled"},
 Delimiter,
 {{n, 1000000, "nokta say\:0131s\:0131"}, {300000, 1000000, 3000000}},
 {{grad, "Ate\:015f", "palet"}, Keys[gradients]},
 {{gamma, 0.55, "parlakl\:0131k"}, 0.25, 1.2, Appearance -> "Labeled"},
 Delimiter,
 Row[{
   Button["Rastgele", {a, b, c, d} = canliParametre[]],
   Spacer[10],
   Button["Kaydet (PNG)",
    Export[FileNameJoin[{$HomeDirectory, "clifford_" <> ToString[Round[AbsoluteTime[]]] <> ".png"}],
     attractorArt[{a, b, c, d}, 6000000, 2000, grad, gamma], ImageResolution -> 300],
    Method -> "Queued"]
   }],
 ControlPlacement -> Left,
 SaveDefinitions -> True]


(* ::Section:: *)
(*5. D\:0131\:015fa Aktarma*)


(* ::Text:: *)
(*Y\[UDoubleDot]ksek \[CCedilla]\[ODoubleDot]z\[UDoubleDot]n\[UDoubleDot]rl\[UDoubleDot]kl\[UDoubleDot] bask\:0131 i\[CCedilla]in (\[ODoubleDot]r. 2000\[Times]2000, 8 milyon nokta). Dosyalar ev klas\[ODoubleDot]r\[UDoubleDot]ne kaydedilir.*)


(*
Export[FileNameJoin[{$HomeDirectory, "kaos_ates.png"}],
  attractorArt[{-1.4, 1.6, 1.0, 0.7}, 8000000, 2000, "Ate\:015f"], ImageResolution -> 300];
Export[FileNameJoin[{$HomeDirectory, "gyroid.png"}], art5, ImageResolution -> 300];
*)


(* ::Section:: *)
(*6. Animasyonlar*)


(* ::Text:: *)
(*\[CapitalUDoubleDot]\[CCedilla] animasyon: nefes alan Gyroid, d\[ODoubleDot]n\[UDoubleDot]\:015fen Clifford \[CCedilla]ekicisi ve d\[ODoubleDot]nen karma\:015f\:0131k d\[UDoubleDot]zlem. Her biri \[ODoubleDot]nce 60 karelik bir \[ODoubleDot]nizleme olarak burada oynat\:0131l\:0131r; kareler Table ile \[ODoubleDot]nceden \[UDoubleDot]retilip resme \[CCedilla]evrilir, b\[ODoubleDot]ylece oynatma ak\:0131c\:0131 olur. \[CapitalUDoubleDot]\[CCedilla] d\[ODoubleDot]ng\[UDoubleDot] de kesintisizdir: son kareden sonra ilk kareye p\[UDoubleDot]r\[UDoubleDot]zs\[UDoubleDot]zce geri d\[ODoubleDot]n\[UDoubleDot]l\[UDoubleDot]r. \[CapitalODoubleDot]nizlemelerin \[UDoubleDot]retilmesi birka\[CCedilla] dakika s\[UDoubleDot]rebilir.*)
(*Her animasyonun ard\:0131ndan gelen h\[UDoubleDot]crede, yorum i\[CCedilla]inde y\[UDoubleDot]ksek kaliteli MP4 d\:0131\:015fa aktarma kodu var (120 kare, saniyede 30 kare, Masa\[UDoubleDot]st\[UDoubleDot]'ne kaydedilir). \:0130stersen yorum i\:015faretlerini kald\:0131r\:0131p elle \[CCedilla]al\:0131\:015ft\:0131r. Video d\:0131\:015fa aktarma i\[CCedilla]in Mathematica 12.1 veya \[UDoubleDot]st\[UDoubleDot] gerekir; exportVideo s\[UDoubleDot]r\[UDoubleDot]m\[UDoubleDot] kendisi kontrol eder. Kare say\:0131s\:0131, boyut ve y\[UDoubleDot]ksek kalite de\:011ferleri a\:015fa\:011f\:0131daki animPreview ve animHQ i\[CCedilla]inde tek yerde durur.*)
(*Kare \[UDoubleDot]retimi yava\:015fsa Table yerine ParallelTable kullanabilirsin: kareler birbirinden ba\:011f\:0131ms\:0131z oldu\:011fu i\[CCedilla]in i\:015flemci \[CCedilla]ekirde\:011fi say\:0131s\:0131 kadar h\:0131zlan\:0131r. Her h\[UDoubleDot]crede bu se\[CCedilla]enek yorum olarak yaz\:0131l\:0131.*)


(* Ortak yard\:0131mc\:0131: grafi\:011fi sabit boyutlu, kare bi\[CCedilla]imli bir resme \[CCedilla]evirir.
   Sabit boyut hem ak\:0131c\:0131 \[ODoubleDot]nizleme hem de MP4 i\[CCedilla]in gerekli (H.264 kodlay\:0131c\:0131s\:0131 \[CCedilla]ift say\:0131da piksel ister). *)
animFrame[g_, size_Integer : 600] :=
  ImageResize[Rasterize[Show[g, ImageSize -> size], Background -> Black], {size, size}];

(* Kolayla\:015ft\:0131rma (easing) e\:011frisi: 0'dan 1'e yava\:015f ba\:015flay\:0131p yava\:015f biterek gider *)
ease[s_] := (1 - Cos[Pi s])/2;

(* D\[ODoubleDot]ng\[UDoubleDot]n\[UDoubleDot]n n karesi: s = 0, 1/n, ..., (n - 1)/n. s = 1 yaz\:0131lmaz \[CCedilla]\[UDoubleDot]nk\[UDoubleDot] s = 0 ile ayn\:0131 karedir; d\[ODoubleDot]ng\[UDoubleDot] b\[ODoubleDot]ylece tak\:0131lmadan akar. *)
loopPhases[n_Integer] := Range[0, n - 1]/n;

(* Kalite ayarlar\:0131 tek yerde. Animasyona \[ODoubleDot]zel \[ODoubleDot]nizleme de\:011ferleri (PlotPoints 40, 800000 nokta, ...)
   kare fonksiyonlar\:0131n\:0131n varsay\:0131lanlar\:0131d\:0131r. Y\[UDoubleDot]ksek kalite de\:011ferleri yaln\:0131zca d\:0131\:015fa aktarmada kullan\:0131l\:0131r. *)
animPreview = <|"Kare" -> 60, "Boyut" -> 600, "AnimationRate" -> 20|>;
animHQ = <|"Kare" -> 120, "Boyut" -> 1080, "FrameRate" -> 30,
   "GyroidPlotPoints" -> 60,
   "CliffordNokta" -> 2000000, "CliffordRes" -> 1080,
   "ComplexPlotPoints" -> 120, "ComplexMaxRecursion" -> 3|>;

(* MP4'\[UDoubleDot] Masa\[UDoubleDot]st\[UDoubleDot]'ne kaydeder. Video d\:0131\:015fa aktarma Mathematica 12.1 ile geldi; daha eski s\[UDoubleDot]r\[UDoubleDot]mde uyar\:0131p durur. *)
exportVideo[name_String, frames_List] :=
  If[$VersionNumber >= 12.1,
   Export[FileNameJoin[{$HomeDirectory, "Desktop", name}], frames, "FrameRate" -> animHQ["FrameRate"]],
   Print["MP4 d\:0131\:015fa aktarma i\[CCedilla]in Mathematica 12.1 veya \[UDoubleDot]st\[UDoubleDot] gerekir; bu s\[UDoubleDot]r\[UDoubleDot]m: ", $VersionNumber]; $Failed
   ];


(* ::Subsection:: *)
(*6.1 Nefes Alan Gyroid*)


(* ::Text:: *)
(*Gyroid denkleminin sa\:011f taraf\:0131 art\:0131k s\:0131f\:0131r de\:011fil, t. t de\:011feri -0.8 ile 0.8 aras\:0131nda Sin ile sal\:0131n\:0131r; y\[UDoubleDot]zeyin bir yan\:0131ndaki kanallar geni\:015flerken \[ODoubleDot]b\[UDoubleDot]r yan\:0131ndakiler daral\:0131r ve form "nefes al\:0131r". Ayn\:0131 anda kamera nesnenin etraf\:0131nda 360\[Degree] d\[ODoubleDot]ner. Renk ge\[CCedilla]i\:015fi, siyah zemin ve parlakl\:0131k (Specularity) art5 ile ayn\:0131. Kareler h\:0131zl\:0131 \[UDoubleDot]retilsin diye PlotPoints 40.*)


(* s, 0 ile 1 aras\:0131nda d\[ODoubleDot]ng\[UDoubleDot]deki konumdur. Kamera art5'in bak\:0131\:015f noktas\:0131ndan ba\:015flar ve ayn\:0131 y\[UDoubleDot]kseklikte tam tur d\[ODoubleDot]ner.
   SphericalRegion ve sabit PlotRange, d\[ODoubleDot]nerken ve y\[UDoubleDot]zey de\:011fi\:015firken g\[ODoubleDot]r\[UDoubleDot]nt\[UDoubleDot]n\[UDoubleDot]n z\:0131plamas\:0131n\:0131 engeller. *)
gyroidFrame[s_, pp_Integer : 40] :=
  Module[{t = 0.8 Sin[2 Pi s], r = Norm[{2.2, -1.6}], th = ArcTan[2.2, -1.6] + 2 Pi s},
   ContourPlot3D[
    Sin[x] Cos[y] + Sin[y] Cos[z] + Sin[z] Cos[x] == t,
    {x, -2 Pi, 2 Pi}, {y, -2 Pi, 2 Pi}, {z, -2 Pi, 2 Pi},
    RegionFunction -> Function[{x, y, z}, x^2 + y^2 + z^2 < (2 Pi)^2],
    ColorFunction -> Function[{x, y, z},
      Blend[{RGBColor[1, 0.85, 0.4], RGBColor[0.95, 0.3, 0.35], RGBColor[0.3, 0.15, 0.6]},
       Norm[{x, y, z} - {0.5, 0.5, 0.5}]/0.87]],
    ColorFunctionScaling -> True,
    Mesh -> None, PlotPoints -> pp, MaxRecursion -> 1,
    Lighting -> "Neutral",
    PlotStyle -> Directive[Specularity[White, 30]],
    Boxed -> False, Axes -> False, Background -> Black,
    PlotRange -> {{-2 Pi, 2 Pi}, {-2 Pi, 2 Pi}, {-2 Pi, 2 Pi}}, SphericalRegion -> True,
    ViewPoint -> {r Cos[th], r Sin[th], 1.4}]
   ];


(* \[CapitalODoubleDot]nizleme: animPreview ayarlar\:0131yla 60 kare, PlotPoints 40. *)
(* Se\[CCedilla]enek (daha h\:0131zl\:0131): Table yerine ParallelTable yaz. \:0130lk \[CCedilla]a\:011fr\:0131da alt \[CCedilla]ekirdekler kendili\:011finden ba\:015flar,
   gyroidFrame tan\:0131m\:0131 da otomatik da\:011f\:0131t\:0131l\:0131r (sorun \[CCedilla]\:0131karsa \[ODoubleDot]nce DistributeDefinitions[gyroidFrame] \[CCedilla]al\:0131\:015ft\:0131r).
   Rasterize \[ODoubleDot]n y\[UDoubleDot]z (front end) ister, o y\[UDoubleDot]zden animFrame ana \[CCedilla]ekirdekte kals\:0131n:
   gyroidPreview = animFrame[#, animPreview["Boyut"]] & /@
      ParallelTable[gyroidFrame[s], {s, loopPhases[animPreview["Kare"]]}]; *)
gyroidPreview = animFrame[#, animPreview["Boyut"]] & /@
   Table[gyroidFrame[s], {s, loopPhases[animPreview["Kare"]]}];
ListAnimate[gyroidPreview, AnimationRate -> animPreview["AnimationRate"]]


(* Y\[UDoubleDot]ksek kaliteli d\:0131\:015fa aktarma: animHQ ayarlar\:0131yla 120 kare, PlotPoints 60, 1080\[Times]1080 piksel. Yorum i\:015faretlerini kald\:0131r\:0131p \[CCedilla]al\:0131\:015ft\:0131r. *)
(*
gyroidHQ = animFrame[#, animHQ["Boyut"]] & /@
   Table[gyroidFrame[s, animHQ["GyroidPlotPoints"]], {s, loopPhases[animHQ["Kare"]]}];
(* ParallelTable se\[CCedilla]ene\:011fi:
   gyroidHQ = animFrame[#, animHQ["Boyut"]] & /@
      ParallelTable[gyroidFrame[s, animHQ["GyroidPlotPoints"]], {s, loopPhases[animHQ["Kare"]]}]; *)
exportVideo["gyroid_nefes.mp4", gyroidHQ]
*)


(* ::Subsection:: *)
(*6.2 D\[ODoubleDot]n\[UDoubleDot]\:015fen Clifford \[CapitalCCedilla]ekicisi*)


(* ::Text:: *)
(*art1'den {-1.4, 1.6, 1.0, 0.7} art2'ye {1.7, 1.7, 0.6, 1.2} yumu\:015fak\[CCedilla]a ge\[CCedilla]ilir, sonra geri d\[ODoubleDot]n\[UDoubleDot]l\[UDoubleDot]r. Ge\[CCedilla]i\:015f do\:011frusal de\:011fil: ease e\:011frisi u\[CCedilla]larda yava\:015flar, b\[ODoubleDot]ylece d\[ODoubleDot]ng\[UDoubleDot]n\[UDoubleDot]n d\[ODoubleDot]n\[UDoubleDot]\:015f noktalar\:0131nda sars\:0131nt\:0131 olmaz.*)
(*D\[ODoubleDot]n\[UDoubleDot]\:015ft\[UDoubleDot]r\[UDoubleDot]len parametreler de\:011fil NOKTALAR. Parametreleri do\:011frudan kayd\:0131rmak karelerin yakla\:015f\:0131k %40'\:0131n\:0131 karart\:0131yordu: Clifford haritas\:0131n\:0131n simetrileri (a, b, c, d) -> (a, b, -c, -d) -> (-a, -b, c, -d) a*b'nin i\:015faretini korur; art1'de a*b < 0, art2'de > 0. Bu y\[UDoubleDot]zden her parametre yolu a = 0 ya da b = 0 d\[UDoubleDot]zleminden ge\[CCedilla]er; orada koordinatlardan biri sabitlenir ve \[CCedilla]ekici birka\[CCedilla] noktaya \[CCedilla]\[ODoubleDot]ker.*)
(*Bunun yerine iki \[CCedilla]ekicinin noktalar\:0131 kendi \[CCedilla]izim alanlar\:0131na (-1...1 karesine) \[ODoubleDot]l\[CCedilla]eklenir, a\:011f\:0131rl\:0131k merkezine uzakl\:0131\:011fa g\[ODoubleDot]re s\:0131ralan\:0131r ve s\:0131ra s\:0131rayla e\:015fle\:015fir: i\[CCedilla]teki nokta i\[CCedilla]teki noktaya, d\:0131\:015ftaki d\:0131\:015ftakine akar. Her kare iki bulutun a\:011f\:0131rl\:0131kl\:0131 ortalamas\:0131d\:0131r; s = 0 karesi art1'in, s = 1/2 karesi art2'nin kendisidir ve hi\[CCedilla]bir kare \[CCedilla]\[ODoubleDot]kmez.*)


cliffordFrom = {-1.4, 1.6, 1.0, 0.7};
cliffordTo = {1.7, 1.7, 0.6, 1.2};

(* \[CapitalCCedilla]ekicinin n noktas\:0131: attractorArt'taki \[CCedilla]izim alan\:0131na g\[ODoubleDot]re (-1...1)^2 karesine \[ODoubleDot]l\[CCedilla]eklenir, a\:011f\:0131rl\:0131k merkezine
   uzakl\:0131\:011fa g\[ODoubleDot]re s\:0131ralan\:0131r. Sonu\[CCedilla] haf\:0131zaya al\:0131n\:0131r: b\[UDoubleDot]t\[UDoubleDot]n kareler ayn\:0131 iki bulutu kullan\:0131r. *)
cliffordBulut[{a_, b_, c_, d_}, n_Integer] := cliffordBulut[{a, b, c, d}, n] =
  Module[{p, r},
   p = Transpose[Transpose[cliffordPoints[a, b, c, d, n]]/{1. + Abs[c], 1. + Abs[d]}];
   r = Sqrt[Total[(Transpose[p] - Mean[p])^2]];
   p[[Ordering[r]]]
   ];

(* attractorArt'\:0131n \[CCedilla]izim yar\:0131s\:0131: (-1...1)^2 karesindeki noktalar\:0131 sayar, logaritmik \[ODoubleDot]l\[CCedilla]ekle renge \[CCedilla]evirir *)
yogunlukResmi[p_, res_Integer, grad_String : "Ate\:015f", gamma_ : 0.55] :=
  Module[{counts, m},
   counts = BinCounts[p, {-1, 1, 2/res}, {-1, 1, 2/res}];
   m = Log[1. + counts];
   m = (m/Max[m])^gamma;
   ArrayPlot[Reverse@Transpose@m,
    ColorFunction -> gradients[grad], ColorFunctionScaling -> False,
    Frame -> False, PlotRangePadding -> None, ImageSize -> 800, Background -> Black]
   ];

(* s, 0 ile 1 aras\:0131nda: ilk yar\:0131da gidi\:015f, ikinci yar\:0131da d\[ODoubleDot]n\[UDoubleDot]\:015f. 1 - Abs[1 - 2 s] \[UDoubleDot]\[CCedilla]gen dalgad\:0131r (0, 1, 0), ease onu yumu\:015fat\:0131r. *)
cliffordFrame[s_, n_Integer : 800000, res_Integer : 600, grad_String : "Ate\:015f"] :=
  Module[{w = N@ease[1 - Abs[1 - 2 s]]},
   yogunlukResmi[(1 - w) cliffordBulut[cliffordFrom, n] + w cliffordBulut[cliffordTo, n], res, grad]
   ];


(* \[CapitalODoubleDot]nizleme: animPreview ayarlar\:0131yla 60 kare, kare ba\:015f\:0131na 800000 nokta ve 600 \[CCedilla]\[ODoubleDot]z\[UDoubleDot]n\[UDoubleDot]rl\[UDoubleDot]k. *)
(* Se\[CCedilla]enek (daha h\:0131zl\:0131): Table yerine ParallelTable yaz; animFrame ana \[CCedilla]ekirdekte kals\:0131n:
   cliffordPreview = animFrame[#, animPreview["Boyut"]] & /@
      ParallelTable[cliffordFrame[s], {s, loopPhases[animPreview["Kare"]]}]; *)
cliffordPreview = animFrame[#, animPreview["Boyut"]] & /@
   Table[cliffordFrame[s], {s, loopPhases[animPreview["Kare"]]}];
ListAnimate[cliffordPreview, AnimationRate -> animPreview["AnimationRate"]]


(* Y\[UDoubleDot]ksek kaliteli d\:0131\:015fa aktarma: animHQ ayarlar\:0131yla 120 kare, kare ba\:015f\:0131na 2 milyon nokta, 1080\[Times]1080 piksel. Yorum i\:015faretlerini kald\:0131r\:0131p \[CCedilla]al\:0131\:015ft\:0131r. *)
(*
cliffordHQ = animFrame[#, animHQ["Boyut"]] & /@
   Table[cliffordFrame[s, animHQ["CliffordNokta"], animHQ["CliffordRes"]], {s, loopPhases[animHQ["Kare"]]}];
(* ParallelTable se\[CCedilla]ene\:011fi:
   cliffordHQ = animFrame[#, animHQ["Boyut"]] & /@
      ParallelTable[cliffordFrame[s, animHQ["CliffordNokta"], animHQ["CliffordRes"]], {s, loopPhases[animHQ["Kare"]]}]; *)
exportVideo["clifford_donusum.mp4", cliffordHQ]
*)


(* ::Subsection:: *)
(*6.3 D\[ODoubleDot]nen Karma\:015f\:0131k D\[UDoubleDot]zlem*)


(* ::Text:: *)
(*art4'teki fonksiyona z yerine z Exp[I t] verilir: bu, d\[UDoubleDot]zlemi t a\[CCedilla]\:0131s\:0131 kadar d\[ODoubleDot]nd\[UDoubleDot]r\[UDoubleDot]r. t, 0'dan 2Pi'ye giderken desen tam tur atar. Fonksiyon simetrik olmad\:0131\:011f\:0131 i\[CCedilla]in her karede renk halkalar\:0131 ve tekilli\:011fin \[CCedilla]evresindeki ince ayr\:0131nt\:0131lar yeniden bi\[CCedilla]imlenir.*)


(* art4'teki fonksiyonun ayn\:0131s\:0131 *)
art4Fn[w_] := (w^5 - 1)/(w^2 + 0.3 I) + Sin[1/w];

(* \[CapitalODoubleDot]nizlemede PlotPoints ve MaxRecursion art4'ten d\[UDoubleDot]\:015f\[UDoubleDot]k tutulur; d\:0131\:015fa aktarmada art4'\[UDoubleDot]n de\:011ferleri (120, 3) kullan\:0131l\:0131r *)
complexFrame[t_, pp_Integer : 80, mr_Integer : 2] :=
  With[{rot = N@Exp[I t]},
   ComplexPlot[art4Fn[z rot],
    {z, -2 - 2 I, 2 + 2 I},
    ColorFunction -> "CyclicLogAbsArg",
    PlotPoints -> pp, MaxRecursion -> mr,
    Frame -> False]
   ];


(* \[CapitalODoubleDot]nizleme: animPreview ayarlar\:0131yla 60 kare. t = 2Pi s, yani t = 0 ... 2Pi (2Pi, t = 0 ile ayn\:0131 kare oldu\:011fu i\[CCedilla]in yaz\:0131lmaz).
   ComplexPlot Mathematica 12 ile geldi; daha eski s\[UDoubleDot]r\[UDoubleDot]mde h\[UDoubleDot]cre uyar\:0131p durur. *)
(* Se\[CCedilla]enek (daha h\:0131zl\:0131): Table yerine ParallelTable yaz; animFrame ana \[CCedilla]ekirdekte kals\:0131n:
   complexPreview = animFrame[#, animPreview["Boyut"]] & /@
      ParallelTable[complexFrame[2 Pi s], {s, loopPhases[animPreview["Kare"]]}]; *)
If[$VersionNumber >= 12,
 complexPreview = animFrame[#, animPreview["Boyut"]] & /@
    Table[complexFrame[2 Pi s], {s, loopPhases[animPreview["Kare"]]}];
 ListAnimate[complexPreview, AnimationRate -> animPreview["AnimationRate"]],
 Print["ComplexPlot i\[CCedilla]in Mathematica 12 veya \[UDoubleDot]st\[UDoubleDot] gerekir; bu s\[UDoubleDot]r\[UDoubleDot]m: ", $VersionNumber]
 ]


(* Y\[UDoubleDot]ksek kaliteli d\:0131\:015fa aktarma: animHQ ayarlar\:0131yla 120 kare, PlotPoints 120, MaxRecursion 3, 1080\[Times]1080 piksel. Yorum i\:015faretlerini kald\:0131r\:0131p \[CCedilla]al\:0131\:015ft\:0131r. *)
(*
complexHQ = animFrame[#, animHQ["Boyut"]] & /@
   Table[complexFrame[2 Pi s, animHQ["ComplexPlotPoints"], animHQ["ComplexMaxRecursion"]], {s, loopPhases[animHQ["Kare"]]}];
(* ParallelTable se\[CCedilla]ene\:011fi:
   complexHQ = animFrame[#, animHQ["Boyut"]] & /@
      ParallelTable[complexFrame[2 Pi s, animHQ["ComplexPlotPoints"], animHQ["ComplexMaxRecursion"]], {s, loopPhases[animHQ["Kare"]]}]; *)
exportVideo["karmasik_donus.mp4", complexHQ]
*)
