#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";
SUSYXSPATH = "/Users/misho/.ghq/github.com/misho104/susy_cross_section/susy_cross_section";


xsTheoryLO = {#[[1]], #[[2]]*1000} &/@ Import["../xs/c1c1/tab2_xs.csv", "CSV", "SkipLines"->7]
xsWinoNLO = {#[[1]], #[[2]]} &/@ Import[FileNameJoin[{SUSYXSPATH, "data", "lhc_susy_xs_wg", "13TeVx1x1wino_envelope.csv"}], "CSV", "SkipLines"->1][[All, 1;;2]]
xsWinoLO = {#[[1]], #[[2]]*1000} &/@ Import["../xs/pure_ino/result_wino_xx.txt", "TSV"]


xsWinoNLOinterp = xsWinoNLO//Interpolation;
kWino = {#[[1]], xsWinoNLOinterp[#[[1]]] / #[[2]]} &/@ xsWinoLO // Interpolation;
xsTheoryNLO = {#[[1]], #[[2]] * kWino[#[[1]]]} &/@ xsTheoryLO;
xsTheoryNLOinterp = Interpolation[xsTheoryNLO];
ListLogPlot[{xsTheoryLO, xsTheoryNLO, xsWinoNLO, xsWinoLO},
  PlotStyle->{{Black, Dotted}, Black, Red, {Red, Dotted}}, PlotRange->{{200, 500}, {10, 1000}}, Joined->True, PlotLegends->{"theory/LO", "theory*K", "Wino/LO", "Wino/NLONLL"}]


atlasLimit = Import["../lhc/atlas1908/HEPData-ins1750597-v1-xsec_upper_limits_1.csv", "CSV", "SkipLines"->11]
atlasLimitInterp2D = Interpolation[{#[[1]],#[[2]],Log[#[[3]]]}&/@%];
atlasLimitInterp1D = Interpolation[{#[[1]], Log[#[[3]]]} &/@ Select[atlasLimit, 99<#[[2]]<101&]];
LogPlot[{Exp[atlasLimitInterp2D[x,100]], Exp[atlasLimitInterp1D[x]]},{x,200,500}]


files = FileNames["../spectrum/m100grid/tab2_*_1000.slha"];
slhas = ReadSLHAFiles[files, "Label"->(#["mass"][1000024]&)] // Select[#, #["mass"][1000024] < 600&]&;


ListLogPlot[{
    {#["mass"][1000024], xsTheoryNLOinterp[#["mass"][1000024]]}&/@Values[slhas],
    {#["mass"][1000024], xsTheoryNLOinterp[#["mass"][1000024]] * #["decay", 1000024][1000022, 24]^2}&/@Values[slhas]
  }, Joined->True, PlotMarkers->Automatic];
LogPlot[{Exp[atlasLimitInterp2D[x,100]], Exp[atlasLimitInterp1D[x]]},{x,200,500}];
Show[{%%, %}]


xsTheoryWW = {#["mass"][1000024], xsTheoryNLOinterp[#["mass"][1000024]] * #["decay", 1000024][1000022, 24]^2}&/@Values[slhas] // Interpolation;
Plot[{xsTheoryWW[x] / Exp[atlasLimitInterp2D[x, 100]]}, {x, 200, 450}]
FindRoot[xsTheoryWW[x] / Exp[atlasLimitInterp2D[x, 100]]==1, {x, 225}]
FindRoot[xsTheoryWW[x] / Exp[atlasLimitInterp2D[x, 100]]==1, {x, 450}]



