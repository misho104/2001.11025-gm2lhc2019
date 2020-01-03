#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";
SUSYXSPATH = "/Users/misho/.ghq/github.com/misho104/susy_cross_section/susy_cross_section";


forbidExtrapolation = ("ExtrapolationHandler" -> {Function[Indeterminate], "WarningMessage" -> False});
xsTheoryLO = {#[[1]], #[[2]]*1000} &/@ Import["../xs/c1c1/tab1_xs.csv", "CSV", "SkipLines"->7]
xsWinoNLO = {#[[1]], #[[2]]} &/@ Import[FileNameJoin[{SUSYXSPATH, "data", "lhc_susy_xs_wg", "13TeVx1x1wino_envelope.csv"}], "CSV", "SkipLines"->1][[All, 1;;2]]
xsHinoNLO = {#[[1]], #[[2]]} &/@ Import[FileNameJoin[{SUSYXSPATH, "data", "lhc_susy_xs_wg", "13TeVx1x1hino_deg_envelope.csv"}], "CSV", "SkipLines"->1][[All, 1;;2]]
xsWinoLO = {#[[1]], #[[2]]*1000} &/@ Import["../xs/pure_ino/result_wino_xx.txt", "TSV"]


xsWinoNLOinterp = xsWinoNLO//Interpolation;
kWino = {#[[1]], xsWinoNLOinterp[#[[1]]] / #[[2]]} &/@ xsWinoLO // Interpolation[#, forbidExtrapolation]&;
xsTheoryNLO = {#[[1]], #[[2]] * kWino[#[[1]]]} &/@ xsTheoryLO;
xsTheoryNLOinterp = Interpolation[xsTheoryNLO, forbidExtrapolation];
ListLogPlot[{xsTheoryLO, xsTheoryNLO, xsWinoNLO, xsWinoLO},
  PlotStyle->{{Black, Dotted}, Black, Red, {Red, Dotted}}, PlotRange->{{200, 600}, {1, 1000}}, Joined->True, PlotLegends->{"theory/LO", "theory*K", "Wino/LO", "Wino/NLONLL"}]


atlasLimit = Import["../lhc/atlas1908/HEPData-ins1750597-v1-xsec_upper_limits_1.csv", "CSV", "SkipLines"->11]
atlasLimitInterp2D = Interpolation[{#[[1]],#[[2]],Log[#[[3]]]}&/@%, InterpolationOrder->1, forbidExtrapolation];
Select[atlasLimit, 99<#[[2]]<101&]
atlasLimitInterp1D = Interpolation[{#[[1]], Log[#[[3]]]} &/@ %, forbidExtrapolation];
LogPlot[{Exp[atlasLimitInterp2D[x,100]], Exp[atlasLimitInterp1D[x]]},{x,100,500}]


files = FileNames["../spectrum/m100grid/tab1_*_1000.slha"];
slhas = ReadSLHAFiles[files, "Label"->(#["mass"][1000024]&)]


ListLogPlot[{
    {#["mass"][1000024], xsTheoryNLOinterp[#["mass"][1000024]]}&/@Values[slhas],
    {#["mass"][1000024], xsTheoryNLOinterp[#["mass"][1000024]] * #["decay", 1000024][1000022, 24]^2}&/@Values[slhas]
  }, Joined->True, PlotMarkers->Automatic, PlotRange->{{200, 520},Automatic}];
LogPlot[{Exp[atlasLimitInterp2D[x,100]], Exp[atlasLimitInterp1D[x]]},{x,200,500}];
Show[{%%, %}]


xsTheoryWW = {#["mass"][1000024], xsTheoryNLOinterp[#["mass"][1000024]] * #["decay", 1000024][1000022, 24]^2}&/@Values[slhas] // Interpolation;
Plot[{xsTheoryWW[x] / Exp[atlasLimitInterp2D[x, 100]]}, {x, 250, 300}]
FindRoot[xsTheoryWW[x] / Exp[atlasLimitInterp2D[x, 100]]==1, {x, 270}]
FindRoot[xsTheoryWW[x] / Exp[atlasLimitInterp2D[x, 100]]==1, {x, 300}]
Select[atlasLimit, #[[2]]==100.&]
xsTheoryWW[275]


style = {{Black}, {GrayLevel[0.5], Dashing[{0.022}]}, {Black, Dotted}, color[2]};
Show[{
  ListLogPlot[
    {xsTheoryNLO, xsTheoryLO, xsWinoNLO, xsHinoNLO},
    Joined->True,
    PlotRange->{{200, 520}, {5,3000}},
    PlotStyle->style[[{1,2,3,3}]],
    FrameLabel->{MaTeX["m(\\tilde\\chi^\\pm_1)\\text{ [GeV]}"], "cross section [fb]"},
    GridLines->Automatic
  ],
  LogPlot[Exp[atlasLimitInterp2D[x,100]],
     {x, 200, 800},
     PlotStyle->style[[4]],
     PlotRange->{{200,550}, Automatic}],
  ListLogPlot[#[[{1,3}]] &/@ Select[atlasLimit, 99<#[[2]]<101&], PlotStyle->color[2],PlotMarkers->{marker[1]}]
},
  Epilog -> {
    Inset[
      LineLegend[
        style,
        MaTeX[{"\\sigma_X", "\\sigma_{X} \\text{(tree-level)}", "\\sigma_{\\mathrm{wino}}, \\sigma_{\\mathrm{higgsino}}", "\\sigma_{\\text{UL; $X$}}\\,(=\\sigma_{\\text{UL; original}})"}, Magnification->0.9]
        , LegendMarkerSize->{35,15}, Spacings->{0.5, 0.3}],
        Scaled[{1,1}], {Right, Top}
      ]
  }
]
outputPDF[%, "summary"]



