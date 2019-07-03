#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd =!= Null,
  (* called as a notebook *)
  SetDirectory[NotebookDirectory[]];
  files = FileNames["x050/tab1_*.slha"];
  ,
  (* called as a script *)
  If[Length[$ScriptCommandLine] <= 1, Print["Usage: " $ScriptCommandLine[[1]] <> " files"]; Abort[]];
  files = $ScriptCommandLine[[1;;]];
];
<<gm2grid`
<<"plot_tools.wl"


slhas = Association[FileBaseName[#]->(If[FileExistsQ[#], ReadSLHA[#], Print["Not a file: " <> TextString[#]]; Abort[]]) &/@ files]


ListPlot[TemporalData[
    {#["mass"][1000022], #["mass"][1000023], #["mass"][1000025], #["mass"][1000035], #["mass"][1000024], #["mass"][1000037], #["mass"][1000013], #["mass"][1000014]} &/@ Values[slhas]// Abs,
    {#["mass"][1000024] &/@ Values[slhas]}], PlotStyle->{Black, Black, Black, Black, Red, Red, Blue, Green}]


ListPlot[TemporalData[
    {#["nmix"][1,1], #["nmix"][2,2], Sqrt[#["nmix"][2,3]^2 + #["nmix"][2,4]^2]} &/@ Values[slhas] // Abs,
    {#["mass"][1000024] &/@ Values[slhas]}], PlotStyle->Automatic]


ListPlot[TemporalData[
    {(#["mass"][1000013]-#["mass"][1000022]) / (#["mass"][1000024]-#["mass"][1000022])} &/@ Values[slhas],
    {#["mass"][1000024] &/@ Values[slhas]}], PlotStyle->{Black}]



xs = <|
"tab1_200_111.4"-> 1990,
"tab1_250_151.4"-> 761.2,
"tab1_300_190.4"-> 340.6,
"tab1_350_228.8"-> 169.4,
"tab1_400_267"-> 91.06,
"tab1_450_305"-> 52.01,
"tab1_500_342.9"-> 31.02,
"tab1_550_380.7"-> 19.18,
"tab1_600_418.5"-> 12.19,
"tab1_650_456.2"-> 7.960,
"tab1_700_493.9"-> 5.287,
"tab1_750_531.6"-> 3.583,
"tab1_800_569.2"-> 2.457,
"tab2_200_136"->   1585,
"tab2_250_176.4"-> 652.2,
"tab2_300_215.7"-> 309.3,
"tab2_350_254.5"-> 160.6,
"tab2_400_293"-> 89.28,
"tab2_450_331.3"-> 52.17,
"tab2_500_369.4"-> 31.75,
"tab2_550_407.4"-> 19.83,
"tab2_600_445.4"-> 12.75,
"tab2_650_483.2"-> 8.329,
"tab2_700_521"-> 5.543,
"tab2_750_558.8"-> 3.731,
"tab2_800_596.5"-> 2.549
|>
N2C1viaSlep[slha_]:=Module[{N2viaSlep, C1viaSlep}, 
  N2viaSlep = slha["decay", 1000023][Sequence@@#] &/@ {{11, -1000011}, {13, -1000013}, {-11, 1000011}, {-13, 1000013}};
  C1viaSlep = slha["decay", 1000024][Sequence@@#] &/@ {{12, -1000011}, {14, -1000013}, {-11, 1000012}, {-13, 1000014}};
  Print[N2viaSlep, C1viaSlep, slha["decay", 1000011][11, 1000022], slha["decay", 1000013][13, 1000022]];
  Total[N2viaSlep] * Total[C1viaSlep]
]
acceptance = N2C1viaSlep /@ slhas


Print /@ KeyValueMap["echo " <> #1 <> "; ./cms_xs_parse.py cms-slep-0.5 " <> TextString[(#2["mass"][1000024]+#2["mass"][1000023])/2] <> " " <> TextString[#2["mass"][1000022]] &,slhas]
xslimit = <|"tab1_200_111.4"-> 0.08667026980939313,
"tab1_250_151.4"-> 0.07949064445711672,
"tab1_300_190.4"-> 0.053888093029375604,
"tab1_350_228.8"-> 0.030467885922836425,
"tab1_400_267"-> 0.01177695269407666,
"tab1_450_305"-> 0.008113221438495487,
"tab1_500_342.9"-> 0.004032829983773939,
"tab1_550_380.7"-> 0.002478750284370034,
"tab1_600_418.5"-> 0.0018839757893357619,
"tab1_650_456.2"-> 0.001477129164180535,
"tab1_700_493.9"-> 0.0012581944245868089,
"tab1_750_531.6"-> 0.0010934524189960208,
"tab1_800_569.2"-> 0.0009925250227222136|>




xs
xslimit





(* ::InheritFromParent:: *)
(*xslimit=<|"tab1_400_267"->91.06`,"tab1_450_305"->52.01`,"tab1_500_342.9"->31.02`,"tab1_550_380.7"->19.18`,"tab1_600_418.5"->12.19`,"tab1_650_456.2"->7.96`,"tab1_700_493.9"->5.287`,"tab1_750_531.6"->3.583`,"tab1_800_569.2"->2.457`,"tab2_200_136"->1585,"tab2_250_176.4"->652.2`,"tab2_300_215.7"->309.3`,"tab2_350_254.5"->160.6`,"tab2_400_293"->89.28`,"tab2_450_331.3"->52.17`,"tab2_500_369.4"->31.75`,"tab2_550_407.4"->19.83`,"tab2_600_445.4"->12.75`,"tab2_650_483.2"->8.329`,"tab2_700_521"->5.543`,"tab2_750_558.8"->3.731`,"tab2_800_596.5"->2.549`|>*)


slhas


ListLogPlot[TemporalData[{xslimit[#], xs[#]/1000}&/@ Keys[xslimit], {slhas[#]["MASS"][1000024] &/@ Keys[xslimit]} ]]


>=>=>=>=>=



slhas[#]["MSOFT"][2] &/@ Keys[xslimit]


plot1=ListContourPlot[{#["extpar"][2], #["extpar"][32], #["mass"][1000024]} &/@ Values[slhas], ContourShading->None, ContourStyle->Red, ContourLabels->Function[{x, y, z}, Text[Style[z, Red], {x, y}]], FrameLabel->{"M2(soft)", "ML(soft)"}]
plot2=ListContourPlot[{#["extpar"][2], #["extpar"][32], #["mass"][1000013]} &/@ Values[slhas], ContourShading->None, ContourStyle->Blue, ContourLabels->Function[{x, y, z}, Text[Style[z, Blue], {x, y}]]]
plot3=ListContourPlot[{#["extpar"][2], #["extpar"][32], #["SPHENOLOWENERGY"][21]*10^10} &/@ Values[slhas], ContourShading->None, ContourStyle->Black, ContourLabels->True, FrameLabel->{"M2(soft)", "ML(soft)"}]
plot4=ListContourPlot[{#["extpar"][2], #["extpar"][32], #["GM2MASSINSERTION"][1]*10^10} &/@ Values[slhas], ContourShading->None, ContourStyle->Dotted, ContourLabels->True]





(* ::InheritFromParent:: *)
(*Graphics[{GraphicsComplex[CompressedData["*)
(*1:eJx1mV2IVVUUxyc1IoosiqIPccSXoJLpuaABsQjRpiBIshI1miHyDheuzW0+*)
(*jud0D3fOzLk5d3qQMCKzlMBwMqlMmwyifAhKDaKscUwiJEOjDw8p1c5c6/r/*)
(*lT64+bHP2Wud/117r7XXzFtZeuDxGW1tbaPhv3/Gs/8613f+79g9ptzRVC7A*)
(*e8eV23qwbgnPl5WnK3i/qtw+gPUi+Bdj/US5qwZ7qXJvHfYz5bER+JMrTzT+*)
(*HambMUfT07gAm57GpqevX8LzZWXT09+vKpuevl4E/2Ksnyibnm4vVTY93X6m*)
(*bHq6P7my6cm4o27GHAuw6Wlsevr6JTxfVjY9/f2qsunp60XwK8b6ibLp6fZS*)
(*ZdPT7WfKpqf7kyubnty3jDvqVlxgND0L6FlAzwJ6FtCzgJ4F9CygZwE9C+hZ*)
(*QM8CehbQs4CeBfQsoGcBPXnucd8y7qibMUfT09cv4bmysunp71eVTU9fL4J/*)
(*MdZPlE1Pt5cqm55uP1M2Pd2fXNn0ZN7gucd9y7ijbsYcTU9/vqxsevp7VWXT*)
(*09eL4F+M9RNl09Ptpcqmp9vPlE1P9ydXNj2Zd5k3eO5x3zLuqJuvj9Hz+zn2*)
(*/G7vV5U9v9s6kbLnd1s/Ufb8bvZSZc/vZj9T9vxu/uTKvt9RtzDvMm/w3OO+*)
(*ZdxRN38eo+93e7+q7Pvd1ouUfb/buomy73ezlyr7fjf7mbLvd/MnVzY9Wfex*)
(*bmHeZd7gucd9y7ijbsYcTU9j09PXi+BfjPUTZdPT7aTKpqfbz5RNT/cnV/bz*)
(*E3Uz6z7WLcy7zBs897hvGXfUzd/H6OenrRcp+/lp6yfKfn6avVTZz0+zmyn7*)
(*+Wn+5MqmJ+8drJtZ97FuYd5l3uC5x33LuKNuxhxNT/cvxvqJsunp9lJl09Pt*)
(*Z8qmp/uRK3s+wr2N9w7Wzaz7WLcw7zJv8NzjvmXcUTdfD6PnI1s/UfZ8ZPZS*)
(*Zc9HZj9T9nxk/uTKfj/CvZf3Nt47WDez7mPdwrzLvMFzj/uWcUfd3D+Mfj86*)
(*x34/Mnupst+PzH6m7Pcj8ydX9vx+zi77CLwH8x7HewjraNaBrGOYh5lHeA5y*)
(*HzMOqSNHz+9mL1X2/G72M2XP7+ZPrmx6su/CvgHvvby38d7Bupl1H+sW5l3m*)
(*DZ573LeMO+pmzNH0NDY93X6mbHq6P7my10voW7Hvwr4B7728t/HewbqZdR/r*)
(*FuZd5g2ee9y3jDvq5vYwer1k9jNlr5fMn1zZ9GTfj30r9l3YN+C9l/c23jtY*)
(*N7PuY93CvMu8wXOP+5ZxR92MOZqexqan+5Mre/2Jvin7fuxbse/CvgHvvby3*)
(*8d7Bupl1H+sW5l3mDZ573LeMO+rm9jF6/Wn+5MqmJ/vO7Juy78e+Ffsu7Bvw*)
(*3st7G+8drJtZ97FuYd5l3uC5x33LuKNuxhxNT2Ov59G3Z9+ZfVP2/di3Yt+F*)
(*fQPee3lv472DdTPrPtYtzLvMGzz3uG8Zd9TN/cFoenpdf4G/g7CPzz40+6js*)
(*A7KPxT4M+wi8B/Mex3sI62jWgaxjmIeZR3gOch8zDs/T8ao9y8dejVt941NX*)
(*167ZOdDqq+1asP/FjXtHOu/Zv2DV6qj1/Py+Xe33HsX7QX/jEws3lx6+tqnz*)
(*HS2uzL1h8FB5jc4He8bvzW5MPrWsDP/KOl+t6Px0Redf6NP58PvI/FdD8C92*)
(*/rZ+9+G3b6ph/VTnPx3W+aC3zA80VI+lY/je9To/Bb2Kps5vGcf39Oj37OrX*)
(*+RB/ai9S/86sU84T6A3uqunz26DHnXV9vhcc4lOeXw69jo/C/1w5xKvEZ4g3*)
(*4fD7GM84PfXHgZPDzvFgabBnRev5P2fNu/i2Dxo6f3NT1+sAn7c/Lj3e/+Pi*)
(*mSXnWb+//9trm8p4HhziUzjEo3D4vXT/RfAnxvqJcvh9hEM8ih4vQ78Qf/L9*)
(*J/G9RVPn38X5EOJPvv/DivKRPuWLBpTnRepfe6w8kSh31pQ/x++9oq7+9YJD*)
(*/Mnz66DPlTl+D3CIv5GPNi5d1t3qxxlPXbFs27E5TZ0P55nx2jtWv7nl6bLy*)
(*horyO33KX/Yrnxpy3j1nx0MHL4uVNybKt9SUd6fKi+vq/4Ot71n03ZKtt37R*)
(*0Pnv8X1hPxj/tHbfyiXb1+j6h4b1+RCPMj8KPUM8CnfAXtFUf94Y1/kQj+pf*)
(*WXm6guerymH/qT8R/ImxfqLcVYO9VLm3DvuZ6vEk9Dk9Cv9y5RCPl1+yp33x*)
(*QKu/IRz0Ew7xKBz0EQ76CAd9hIM+ul4EezHWT5SDPmovVQ76GD9zZlPp6/tb*)
(*33N2/Kbh9YjFg7xPDvFpfODo7MGDz63R98P3CvP7wu8jHOLX+Ndi4eGdz0L/*)
(*EL/i//VN5SPg18dhr8f52M/1yZ4nysr1ivLWPuVP+pV/GFJ/Z8bKzyfK82vK*)
(*b6XKC+vKB4eVV0GfX0YRP7nyROv33Ny94fYd9405nx2nMX9dU/kweOu4/p57*)
(*W3zjot15c7D1+zdeeeTjfY+WlYcqyi/1KU/2K08NaX381zrl9Yny3Jry9lT5*)
(*rrryZ8PKj40onxhF/ObKIR6Fu8eUO5rKIf70/RL0LOP5Kp6PsH6M9xPlrpry*)
(*dKrcW4e9THlsRHmi8Z96hfmJ8crfn/X235PKN6Q=*)
(*"], {{{}, {}, {}, {}, {}, {}}, {{}, {RGBColor[1, 0, 0], Line[{442, 468, 467, 466, 448, 447, 446, 464, 465, 445, 484, 463, 483, 482, 462, 481, 480, 461, 479, 478, 460, 477, 476, 459, 475, 474, 458, 473, 472, 457, 471, 470, 456, 455, 454, 453, 452, 451, 450, 449, 469}]}, {RGBColor[1, 0, 0], Line[{615, 614, 581, 613, 633, 612, 632, 610, 631, 611, 646, 444, 630, 629, 645, 628, 644, 627, 643, 626, 642, 625, 641, 624, 640, 623, 639, 622, 638, 621, 586, 620, 637, 619, 585, 618, 636, 617, 635, 616, 634}]}, {RGBColor[1, 0, 0], Line[{583, 593, 582, 592, 567, 591, 566, 579, 590, 580, 609, 589, 608, 607, 588, 606, 587, 605, 578, 604, 577, 603, 576, 602, 575, 601, 574, 600, 573, 599, 572, 598, 571, 597, 570, 596, 569, 595, 568, 584, 594}]}, {RGBColor[1, 0, 0], Line[{541, 549, 548, 540, 547, 526, 525, 538, 546, 539, 565, 545, 564, 563, 544, 562, 561, 543, 560, 537, 559, 536, 558, 535, 557, 534, 556, 533, 555, 532, 554, 531, 553, 530, 552, 529, 551, 528, 527, 542, 550}]}, {RGBColor[1, 0, 0], Line[{492, 508, 507, 506, 491, 490, 485, 488, 505, 489, 524, 504, 523, 522, 503, 521, 520, 487, 519, 518, 486, 517, 502, 516, 501, 515, 500, 514, 499, 513, 498, 512, 497, 511, 496, 510, 495, 494, 443, 493, 509}]}, {}, {}}, {Inset[Style[200, LineColor -> RGBColor[1, 0, 0], FrontFaceColor -> RGBColor[1, 0, 0], $CellContext`BackFaceColor -> RGBColor[1, 0, 0], GraphicsColor -> RGBColor[1, 0, 0], FontColor -> RGBColor[1, 0, 0]], {251.8969824390076, 1198.1030175609924`}], Inset[Style[400, LineColor -> RGBColor[1, 0, 0], FrontFaceColor -> RGBColor[1, 0, 0], $CellContext`BackFaceColor -> RGBColor[1, 0, 0], GraphicsColor -> RGBColor[1, 0, 0], FontColor -> RGBColor[1, 0, 0]], {454.5218034825017, 245.47819651749833`}], Inset[Style[600, LineColor -> RGBColor[1, 0, 0], FrontFaceColor -> RGBColor[1, 0, 0], $CellContext`BackFaceColor -> RGBColor[1, 0, 0], GraphicsColor -> RGBColor[1, 0, 0], FontColor -> RGBColor[1, 0, 0]], {655.5366835298205, 844.4633164701795}], Inset[Style[800, LineColor -> RGBColor[1, 0, 0], FrontFaceColor -> RGBColor[1, 0, 0], $CellContext`BackFaceColor -> RGBColor[1, 0, 0], GraphicsColor -> RGBColor[1, 0, 0], FontColor -> RGBColor[1, 0, 0]], {856.0759826986679, 343.92401730133207`}], Inset[Style[1000, LineColor -> RGBColor[1, 0, 0], FrontFaceColor -> RGBColor[1, 0, 0], $CellContext`BackFaceColor -> RGBColor[1, 0, 0], GraphicsColor -> RGBColor[1, 0, 0], FontColor -> RGBColor[1, 0, 0]], {1056.41070694826, 1193.58929305174}]}}], GraphicsComplex[CompressedData["*)
(*1:eJx1mXuMHVUdx1cxCFpqtQZT6SZbQR5pbRZa220KzUUMj1CgIlAQS0TQutpy*)
(*y222ZejF8Y57e5mbaffuGhXEoCYGAR/UYCgGK6sgRatV0wREBBobioaGV0kZ*)
(*5FGPA7/f8P2M7D8n3/zOPY/PnHN+j531+fr5X3hnX1/fikP6+v7XFn+1sdr/*)
(*bb/UUz04rjqHnpxQ3TeMcevo31C9ewS/j1QPNDFejPW1MH6ietko5murXtPB*)
(*/KnqXhfryVRv2fRGS26m2RpP0zm08TRtPH38Ovo3VBtP/32k2nj6eDHW18L4*)
(*iWrj6fO1VRtPnz9VbTx9PZlq48lzR26m2ebQxtO08fTx6+jfUG08/feRauPp*)
(*48VYVwvjJ6qNp8/XVm08ff5UtfH09WSqjSfvLc8dueVv0xrPHDxz8MzBMwfP*)
(*HDxz8MzBMwfPHDxz8MzBMwfPHDxz8MzBMwdPvnu8tzx35GaarfH08evo11Bt*)
(*PP33kWrj6ePFWF8L4yeqjafP11ZtPH3+VLXx9PVkqo0n/QbfPd5bnjtyM83W*)
(*eHr/hmrj6b+LVBtPHy/G+loYP1FtPH2+tmrj6fOnqo2nrydTbTzpd+k3+O7x*)
(*3vLckZuPj9b9+5va/bv9PlLt/t3GiVW7f7fxE9Xu322+tmr37zZ/qtr9u60n*)
(*U+33HXEL/S79Bt893lueO3Lz/mj9vtvvI9V+3228WLXfdxs3Ue333eZrq/b7*)
(*bvOnqv2+23oy1caTcR/jFvpd+g2+e7y3PHfkZpqt8TRtPH28GOtrYfxEtfH0*)
(*edqqjafPn6o2nr6eTLW/n4ibGfcxbqHfpd/gu8d7y3NHbv57tP5+2nixan8/*)
(*bfxEtb+fNl9btb+fNm+q2t9PW0+m2ngy72DczLiPcQv9Lv0G3z3eW547cjPN*)
(*1nj6+loYP1FtPH2+tmrj6fOnqo2nryNT7f4IeRvzDsbNjPsYt9Dv0m/w3eO9*)
(*5bkjNx8PrfsjGz9R7f7I5murdn9k86eq3R/ZejLVnh8h72XexryDcTPjPsYt*)
(*9Lv0G3z3eG957sjN14fW86M3tedHNl9btedHNn+q2vMjW0+m2v37m/OyjsA8*)
(*mHkc8xDG0YwDGcfQD9OP8B3kPeY5JEe27t9tvrZq9+82f6ra/butJ1NtPFl3*)
(*Yd2AeS/zNuYdjJsZ9zFuod+l3+C7x3vLc0duptkaT9PG0+dPVRtPX0+m2uMl*)
(*1K1Yd2HdgHkv8zbmHYybGfcxbqHfpd/gu8d7y3NHbj4fWo+XbP5UtcdLtp5M*)
(*tfFk3Y91K9ZdWDdg3su8jXkH42bGfYxb6HfpN/ju8d7y3JGbabbG07Tx9PVk*)
(*qj3+RN2UdT/WrVh3Yd2AeS/zNuYdjJsZ9zFuod+l3+C7x3vLc0duPj9ajz9t*)
(*PZlq48m6M+umrPuxbsW6C+sGzHuZtzHvYNzMuI9xC/0u/QbfPd5bnjtyM83W*)
(*eJr2eB51e9adWTdl3Y91K9ZdWDdg3su8jXkH42bGfYxb6HfpN/ju8d7y3JGb*)
(*rwet8fS4/m3+D8I6PuvQrKOyDsg6FuswrCMwD2YexzyEcTTjQMYx9MP0I3wH*)
(*eY95Dt/C8f67hj8zcUWvlq7e9YtjFo7VXvzdrB3zBoZrp26/aePLs8drx9x1*)
(*zq6JmXW3X3f1gy9MOXPM7W/sq6p/cvLLG877VVmXtt+bvf/yk/ZeN9qoXf3n*)
(*vVN+s6LUZt959PD12a5rXL/nzj3v+NrMuPbAKTfNe9f6Ye8/46od9yy6qNr/*)
(*uZGTbx/6eVLbcOzUg/d+qvy92aPNH91x0a4yrtlz+MCj+168vnZg6czX46Mj*)
(*799/4Iljpp9d2q3/9jumffn4I7PayN/ibyydM1yx234LvoGL7D/wMF73Dl0Z*)
(*Hbqq1LduPOKwy8+o8hM9WB3PePxy5dqNu9f1lGewG5/lvV9fuP3csdpt9VML*)
(*Pma3/U7Z+uRjM9eW/TtX/33+bUvBK/S33y+Z3jn4xJqe8g129jc+i5Y9+82H*)
(*zyr5ve+V+kS6uqf8Qn+zF/z2Y79h/8JvfqkvuO/Q0S1fAa9wz8lPdF4dX3gu*)
(*GVeewW58Zp/5xO1X1HvKM9iF5+Ky//1Dq79zwVXgE/oLz6Fx5Rns7G+8+m99*)
(*6Q9Pr+opz4+PK8/QX3jeM6H7zcHzVfCcV+VFvhxP+B06ofxy8Fs4rvxy8Dtk*)
(*QvktAI8c/PomlF9e7S/85o8rv9fALy/ttl/h80qVh+x3ckL3exD7nSzXW+zv*)
(*daw32NmfdtnPq9X1iu4b1vc6aFl/X/m+7rn5TzOSxZHuJ9jlvQ3a1n/SP761*)
(*fu2cqGK399j0aUtnveX9rev56Svf0+J9XVXX7xHs3I/9/gOP3jJ81s8a6s8+*)
(*V4d/KvX3PrxgYLQf+w9204W/2Vr3/V9598ee3Xsx9l+rw3/V3b7vxqFXD55e*)
(*8vnE8VOX9y8Gj9Bf/VPd7S/uvHbXD0+q8jI964OdH2/uj3S8EKewv/HbW9u2*)
(*/LLjSn6L99171rEPNeC/6m4veO4ccZ7/+WfvyRl/aSjPyYbyXFHHfWi4Ls7T*)
(*Kw3leUNdeU6W9oLfRvAJdutf8NxQr+zf+hf8GnXlEezSP8RxtAuPoI1HwW9l*)
(*HferoefvmWuU13Mjymt3qQv7tMj1eUccNe23OxvKL/QXfketcz7FfdvXUH6h*)
(*v9inrHN7Ed/saSjP0F/sh6xze3G+HqvyEvtrI26/duW24fMfwfnbDfvLJe9C*)
(*z4gq/Y1/cT4PjOj3CHbjv/b7j8++Y1dDv8fuEf0eU5v6PQabeP/A/5kRvIeR*)
(*8r+0ifcwUt5Lm3j/IuV7WlP590XK85Qm3suoooXfoqbyC3bhd2SE9zNSfvtH*)
(*8J5Gym9urPyWxcpvoKn8pkbKL9iF34ZY+Q00ld+qWPkNNCvaeBU8r4iV34pY*)
(*eQ00K1r4XRIrv2AXfguaiKdaqkN/4Tk9Up4D5fkr2uNamk8NteCfYuU5twn/*)
(*FLsu8qdzWvA/cUUbvyJfOr0F/1XyK/KlU1vwRyXPad37Lty+pAX/VfLbdufj*)
(*8287uQX/EyvPi2K8rwn8T6w85zWVZy1WnlsT5flgojwHW8rz3Bj5QEt5PpYg*)
(*3m9VtPB8KFGegy3l+dcE8XxLee5MlOdgS3n+MXFd5KOLcf6WjVbOp/D7dKz8*)
(*BlvK74xRjb8mE81HF7bgz5OK1ngXPCax/0nsdxL725FUzoetv8gfF7XgfxPd*)
(*z8Nt3U/gI/vZjvUHO7XsJ2jZT9Cyn6BlP0HL+Q9a1v/7RNe/bFTXv7Kj5/ni*)
(*UcQPbd3Pcqw/2OU8r8Z+gl3qJ1/E/oLddHF+L8d+g910cX4vw/6D3XRxfj8L*)
(*HsEu3/tSnN9gpxZ+l4zC37eV30vXK79/tZXfmo7ye6qt/IJd+L3WVn7BLvwO*)
(*tJVfsAu/59vKL9iF3zNt5Rfspov6y7625nvBbrrg9zR4BTu18Pt3G/4+Vb2m*)
(*ozw7XeV5TQfxU6o813cQP6XKc1MH8VOqPDd2ED+lyrPVQfyUKs+vdhAvpcqz*)
(*2VGewS48N4BfsEv9Kuoor163wlP4fShTfjd0nVehD0uVZ6+rPL/ddX6Ffneq*)
(*fHtd5fvTrtZX+1Pl3esq71u66s+OTJV/r6v8f9BV//b+VL9Hr6vfY2qq/u7m*)
(*rn6fXle/z5TyexT6u139Xr2ufq/3lt+n0Dd19fv1uvr9Dk/1PtzYrXxP+X4/*)
(*2qTf7/gM8W+m3+u4DPFvpt/nlAzxb6bfY0GGeDdT/idmynsgU95zM8S7mfKd*)
(*kynPgUx5zs4Q32bK74QM8W1VG6/1E3POfvTukt/XNy88Yv9C/L9gyybXF0cv*)
(*vHTzEOrfwW56bHDG/iUfwf8Lgt30U+PzP/nACfh/QLCbbj/yfF9tLv4fEOym*)
(*C04njim/YDddcJqHeniwmy44zcf/C4LddMFpwZjyCnZq48X6KetP9C+sLzLf*)
(*5n1hPYj1YcbTrJf9F4S0NVs=*)
(*"], {{{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}}, {{}, {RGBColor[0, 0, 1], Line[{488, 526, 509, 508, 489, 487, 468, 467, 447, 835, 836, 815, 816, 788, 790, 789, 768, 767, 747, 746, 727, 726, 714, 713, 701, 700, 682, 681, 661, 660, 640, 639, 620, 619, 596, 595, 576, 575, 555, 554, 538}]}, {RGBColor[0, 0, 1], Line[{525, 507, 506, 486, 485, 466, 465, 445, 446, 833, 834, 813, 814, 785, 787, 786, 766, 765, 745, 744, 725, 724, 712, 679, 699, 658, 680, 637, 659, 617, 638, 594, 618, 592, 593, 573, 574, 552, 553, 443, 537}]}, {RGBColor[0, 0, 1], Line[{510, 505, 490, 484, 469, 464, 448, 442, 463, 832, 851, 812, 831, 784, 811, 764, 783, 743, 763, 723, 742, 711, 722, 698, 710, 678, 697, 657, 677, 636, 656, 616, 635, 591, 615, 572, 590, 551, 546, 444, 550}]}, {RGBColor[0, 0, 1], Line[{536, 535, 524, 522, 504, 502, 483, 481, 461, 849, 850, 829, 830, 810, 782, 809, 762, 781, 760, 761, 740, 741, 720, 721, 708, 709, 695, 696, 675, 676, 654, 655, 633, 634, 613, 614, 588, 589, 571, 569, 549}]}, {RGBColor[0, 0, 1], Line[{534, 523, 521, 503, 501, 482, 480, 460, 458, 847, 848, 827, 828, 807, 808, 806, 780, 779, 759, 758, 739, 738, 694, 707, 674, 693, 653, 673, 672, 652, 651, 632, 631, 612, 611, 570, 587, 548, 568, 462, 547}]}, {RGBColor[0, 0, 1], Line[{533, 531, 520, 517, 500, 497, 479, 476, 457, 845, 846, 825, 826, 804, 805, 803, 778, 777, 757, 756, 737, 736, 719, 692, 706, 671, 691, 650, 670, 630, 649, 610, 629, 609, 586, 607, 567, 584, 565, 564, 545}]}, {RGBColor[0, 0, 1], Line[{532, 529, 518, 514, 498, 494, 477, 473, 455, 843, 844, 823, 824, 801, 802, 800, 776, 775, 755, 754, 735, 734, 718, 690, 705, 669, 689, 647, 668, 627, 648, 566, 628, 606, 608, 604, 585, 582, 563, 561, 544}]}, {RGBColor[0, 0, 1], Line[{530, 519, 515, 499, 495, 478, 474, 456, 452, 841, 842, 821, 822, 797, 799, 798, 774, 773, 753, 752, 733, 732, 717, 688, 704, 667, 687, 646, 666, 625, 645, 459, 626, 603, 605, 601, 583, 580, 562, 560, 542}]}, {RGBColor[0, 0, 1], Line[{528, 516, 513, 496, 493, 475, 472, 454, 451, 839, 840, 819, 820, 794, 796, 795, 772, 771, 751, 750, 731, 730, 716, 686, 703, 665, 685, 643, 664, 623, 644, 543, 624, 600, 602, 598, 581, 578, 559, 557, 541}]}, {RGBColor[0, 0, 1], Line[{527, 512, 511, 492, 491, 471, 470, 450, 449, 837, 838, 817, 818, 791, 793, 792, 770, 769, 749, 748, 729, 728, 715, 683, 702, 662, 684, 641, 663, 621, 642, 540, 622, 597, 599, 577, 579, 556, 558, 453, 539}]}, {}, {}}, {Inset[Style[300, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {1153.7192628891046`, 296.2807371108955}], Inset[Style[400, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {202.77819022111646`, 397.22180977888354`}], Inset[Style[500, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {702.2187481980794, 497.7812518019206}], Inset[Style[600, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {1151.8473315131948`, 598.152668486805}], Inset[Style[700, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {351.58262037263887`, 698.4173796273611}], Inset[Style[800, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {801.3843476769431, 798.6156523230569}], Inset[Style[900, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {201.2302664467199, 898.7697335532802}], Inset[Style[1000, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {1198.8929230230142`, 998.8929230230143}], Inset[Style[1100, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {601.0063224467882, 1098.9936775532117`}], Inset[Style[1200, LineColor -> RGBColor[0, 0, 1], FrontFaceColor -> RGBColor[0, 0, 1], $CellContext`BackFaceColor -> RGBColor[0, 0, 1], GraphicsColor -> RGBColor[0, 0, 1], FontColor -> RGBColor[0, 0, 1]], {200.9223786408156, 1199.0776213591844`}]}}]}, AspectRatio -> 1, AxesOrigin -> {Automatic, Automatic}, BaseStyle -> {GrayLevel[0], FontFamily -> "Times New Roman", FontSize -> 15}, DisplayFunction -> Identity, Frame -> True, FrameLabel -> {{"ML(soft)", None}, {"M2(soft)", None}}, FrameStyle -> Automatic, FrameTicks -> {{Automatic, Automatic}, {Automatic, Automatic}}, GridLines -> {Automatic, Automatic}, GridLinesStyle -> Directive[GrayLevel[0.4, 0.5], AbsoluteThickness[1], AbsoluteDashing[{1, 2}]], ImageSize -> {Automatic, 250}, LabelStyle -> GrayLevel[0], Method -> {"DefaultBoundaryStyle" -> Automatic, "DefaultGraphicsInteraction" -> {"Version" -> 1.2, "TrackMousePosition" -> {True, False}, "Effects" -> {"Highlight" -> {"ratio" -> 2}, "HighlightPoint" -> {"ratio" -> 2}, "Droplines" -> {"freeformCursorMode" -> True, "placement" -> {"x" -> "All", "y" -> "None"}}}}, "DefaultMeshStyle" -> AbsolutePointSize[6], "PointSizeFunction" -> "SmallPointSize", "GridLinesInFront" -> True}, PlotRange -> {{200., 1200.}, {200., 1200.}}, PlotRangeClipping -> True, PlotRangePadding -> {{Scaled[0.02], Scaled[0.02]}, {Scaled[0.02], Scaled[0.02]}}, Ticks -> {Automatic, Automatic}]*)


plot3b=ListContourPlot[{#["mass"][1000024], #["mass"][1000013], #["SPHENOLOWENERGY"][21]*10^10} &/@ Values[slhas], ContourStyle->Black, ContourLabels->True, FrameLabel->{"MC1", "MSMU1"}]
plot4b=ListContourPlot[{#["mass"][1000024], #["mass"][1000013], #["GM2MASSINSERTION"][1]*10^10} &/@ Values[slhas], ContourStyle->Dotted, ContourLabels->True]
plot5=ListContourPlot[{#["mass"][1000024], #["mass"][1000013], (#["mass"][1000013] - #["mass"][1000022]) / (#["mass"][1000024] - #["mass"][1000022])} &/@ Values[slhas], ContourStyle->Dotted, ContourLabels->True]
Show[{plot3b, plot4b, plot5}]




