#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd =!= Null, SetDirectory[NotebookDirectory[]], Print["This is not for scripting; run from Frontend."]; Abort[]];
<<"common.wl";
SetOptions[#, ContourShading->None, PlotRangePadding->None, ImageSize->400] &/@ {ContourPlot, ListContourPlot};


data[filename_] := Module[
  {sp = SLHA`ReadSLHA[filename], result},
  result = <|
    "m1"->sp["msoft"][1],
    "m2"->sp["msoft"][2],
    "mu"->sp["hmix"][1],
    "mL"->sp["msoft"][32],
    "msmuL"->sp["mass"][1000013],
    "msnumu"->sp["mass"][1000014],
    "mn1"->sp["mass"][1000022],
    "mn2"->sp["mass"][1000023],
    "mn3"->sp["mass"][1000025],
    "mn4"->sp["mass"][1000035],
    "mc1"->sp["mass"][1000024],
    "mc2"->sp["mass"][1000037],
    "amu"->sp["SphenoLowEnergy"][21],
    "amuMI"->sp["gm2massinsertion"][1]+sp["gm2massinsertion"][4],
    "x"->(sp["mass"][1000013]-sp["mass"][1000022])/(sp["mass"][1000024]-sp["mass"][1000022]),
    "LSP"->(DownValues[Evaluate[sp["MASS"]]] // Cases[# , (_[_[a_Integer]]:>b_):>{a,b}]& // Abs // Select[#, #[[1]]>1000000&]& // Sort[#, #1[[2]] < #2[[2]]&]&)[[1,1]]
  |>;
  Clear[sp];
  result]


ReadOrGenerate[filepath_String, data_] := If[FileExistsQ[filepath], Get[filepath], Module[{tmp = Evaluate[data]}, Put[tmp, filepath]; tmp]];
Attributes[ReadOrGenerate] = {HoldRest};


tab1data = ReadOrGenerate["tab1data.dat", Association[FileBaseName[#]->data[#] &/@ FileNames[$ProjectRoot<>"/spectrum/grid/tab1_*.slha"]]];
tab2data = ReadOrGenerate["tab2data.dat", Association[FileBaseName[#]->data[#] &/@ FileNames[$ProjectRoot<>"/spectrum/grid/tab2_*.slha"]]];
tab1m100data = ReadOrGenerate["tab1m100data.dat", Association[FileBaseName[#]->data[#] &/@ FileNames[$ProjectRoot<>"/spectrum/m100grid/tab1_*.slha"]]];
tab2m100data = ReadOrGenerate["tab2m100data.dat", Association[FileBaseName[#]->data[#] &/@ FileNames[$ProjectRoot<>"/spectrum/m100grid/tab2_*.slha"]]];


(* ::Section:: *)
(*mueqm2.pdf*)


gm2expmcontour = 27.82 + 7.37*{-2,-1,1,2};
{dataToPlot, name} = {tab1data, "mueqm2"};
(*
{dataToPlot, name} = {tab1data, "mueqm2"};
{dataToPlot, name} = {tab1m100data, "mueqm2m100"};
{dataToPlot, name} = {tab2data, "mueq2m2"};
{dataToPlot, name} = {tab2m100data, "mueq2m2m100"};
*)
SetOptions[ListContourPlot, {  PlotRange->{{200,1100}, {100, 1000}}}];
degenerateDegree = Interpolation[{#mc1, #msmuL, Min[{#mn2-#mn1-91.1876, #mc1-#mn1-80.385}]} &/@ Values[dataToPlot]];
Show[{
    (* x *)
    ListContourPlot[{#mc1, #msmuL, #x}             &/@ Values[dataToPlot], Contours->{0.05, 0.5, 0.95}, ContourStyle->{{Black, Thick, Dotted}}],
    ListContourPlot[{#mc1, #msmuL, #msmuL - Min[{#mn2, #mc1}]} &/@ Values[dataToPlot], Contours->{0}, ContourStyle->{Black, Thick}],
    (* sneutrino LSP region to exclude *)
    ListContourPlot[{#mc1, #msmuL, #msnumu - #mn1} &/@ Values[dataToPlot], Contours->{0}, ContourStyle->None, ContourShading->{Gray, None}],
    (* g-2 *)
    ListContourPlot[{#mc1, #msmuL, #amu*10^10}     &/@ Values[dataToPlot], ContourStyle->Black, ContourLabels->True, Contours->{5, 10, 15, 20, 25, 30, 35, 40, 45, 50},
      PlotLegends->LineLegend[{Black}, {MaTeXRaw["a_\mu^{\mathrm{MSSM}}\times10^{10}"]}], PlotRange->Full],
    ListContourPlot[{#mc1, #msmuL, #amu*10^10}     &/@ Values[dataToPlot], ContourStyle->Green, ContourLabels->True, Contours->gm2expmcontour,
      PlotLegends->LineLegend[{Black}, {MaTeXRaw["a_\mu^{\mathrm{MSSM}}\times10^{10}"]}], PlotRange->Full],
    (* degenerate region not under consideration *)
    ListContourPlot[{#mc1, #msmuL, Min[{#mn2-#mn1-91.1876, #mc1-#mn1-80.385}]} &/@ Values[dataToPlot], Contours->{0}, ContourStyle->{Blue, Thickness[.004]}],
    RegionPlot[degenerateDegree[x,y] < 0 , {x, 200, 1100}, {y, 100, 1000}, Mesh -> 50, MeshFunctions -> { #2 - #1 &}, BoundaryStyle -> None, MeshStyle -> {Blue, Thickness[.004]}, PlotStyle -> Transparent]
  },
  PlotRange->{{200,1100}, {100, 1000}}, FrameLabel->MaTeXRaw[{"m(\tilde\chi^\pm_1) \text{ [GeV]}", "m(\tilde\mu_{\mathrm L}) \text{ [GeV]}"}]
]
outputPDF[%, name];



