#!/usr/bin/env wolframscript
(* ruh_katmanlari.wl'yi yükler ve örnek çıktıları ciktilar/ klasörüne PNG olarak yazar.
   Kullanım:  wolframscript -file calistir.wls
   Ana dosyaya dokunmaz; yalnızca okur. *)

dizin = DirectoryName[$InputFileName];
cikti = FileNameJoin[{dizin, "ciktilar"}];
If[! DirectoryQ[cikti], CreateDirectory[cikti]];

yaz[ad_String, img_] := Module[{yol = FileNameJoin[{cikti, ad <> ".png"}]},
   Export[yol, img];
   Print["  yazıldı: ", yol]];

(* kılavuz görünümleri Graphics döndürür; PNG'ye çevirmek için rasterleştir *)
kilavuz[g_Graphics] := Rasterize[g, "Image", RasterSize -> 600];

Print["ruh_katmanlari.wl yükleniyor (bütün örnekler çiziliyor, birkaç dakika sürebilir)..."];
t = First@AbsoluteTiming[Get[FileNameJoin[{dizin, "ruh_katmanlari.wl"}]]];
Print["  yüklendi: ", Round[t], " sn"];

(* dosya yüklenirken hesaplanan örnekler yeniden çizilmeden yazılır *)
Print["Ruh Katmanları"];
yaz["eser1_toprak_11", eser1];
yaz["eser2_hayalet_4", eser2];
yaz["eser3_kozmik_23", eser3];

Print["Işık Kafesi"];
yaz["kafes1_7", kafes1];
yaz["kafes2_40", kafes2];
yaz["kafes_kilavuz_7", kilavuz[isikKafesi[7, "NeonGece", kafesOnizleme["yogunluk"], True]]];

Print["Eriyen Maskeler"];
yaz["maske1_5", maske1];
yaz["maske2_18", maske2];
yaz["maske_kilavuz_5", kilavuz[eriyenMaskeler[5, "PastelRuh", maskeOnizleme["yogunluk"], True]]];

Print["Bitti."];
