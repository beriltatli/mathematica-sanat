#!/usr/bin/env wolframscript
(* kaos_ve_form.wl'yi yükler; görselleri ve animasyon önizlemelerini ciktilar/kaos/ klasörüne yazar.
   Kullanım:  wolframscript -file calistir_kaos.wls
   Ana dosyaya dokunmaz; yalnızca okur. Animasyon önizlemeleri yüklenirken üretildiği için birkaç dakika sürer. *)

dizin = DirectoryName[$InputFileName];
cikti = FileNameJoin[{dizin, "ciktilar", "kaos"}];
If[! DirectoryQ[cikti], CreateDirectory[cikti, CreateIntermediateDirectories -> True]];

yaz[ad_String, x_] := Module[{yol = FileNameJoin[{cikti, ad}]},
   Export[yol, x];
   Print["  yazıldı: ", yol]];

(* animasyon önizlemesi: kareler zaten resim; GIF sonsuz döngüyle, notebook'taki hızda *)
gifYaz[ad_String, kareler_List] := Module[{yol = FileNameJoin[{cikti, ad}]},
   Export[yol, kareler, "DisplayDurations" -> 1./animPreview["AnimationRate"], "AnimationRepetitions" -> Infinity];
   Print["  yazıldı: ", yol]];

Print["kaos_ve_form.wl yükleniyor (görseller ve 3 × 60 karelik animasyon önizlemeleri çiziliyor)..."];
t = First@AbsoluteTiming[Get[FileNameJoin[{dizin, "kaos_ve_form.wl"}]]];
Print["  yüklendi: ", Round[t], " sn"];

Print["Görseller"];
yaz["art1_clifford_ates.png", art1];
yaz["art2_clifford_okyanus.png", art2];
yaz["art3_clifford_aurora.png", art3];
yaz["art4_karmasik_duzlem.png", art4];
yaz["art5_gyroid.png", art5];

Print["Animasyon önizlemeleri"];
gifYaz["gyroid_nefes.gif", gyroidPreview];
gifYaz["clifford_donusum.gif", cliffordPreview];
(* complexPreview yalnızca Mathematica 12 ve üstünde üretilir *)
If[ListQ[complexPreview], gifYaz["karmasik_donus.gif", complexPreview]];

Print["Bitti."];
