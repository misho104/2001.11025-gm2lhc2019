#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd =!= Null, SetDirectory[NotebookDirectory[]], Print["This is not for scripting; run from Frontend."]; Abort[]];
<<"common.wl";
SetOptions[#, ContourShading->None, PlotRangePadding->None] &/@ {ContourPlot, ListContourPlot};


(* Path to susy-xs installation *)
SUSYXSPATH = "/Users/misho/.ghq/github.com/misho104/susy_cross_section/susy_cross_section";


N2C1pmWino = Import[FileNameJoin[{SUSYXSPATH, "data", "lhc_susy_xs_wg", "13TeVn2x1wino_envelope_pm.csv"}], "CSV", "SkipLines"->1] // Interpolation[#[[All, 1;;2]]]&;
N2C1pmHino = Import[FileNameJoin[{SUSYXSPATH, "data", "lhc_susy_xs_wg", "13TeVn2x1hino_deg_mstw_pm.csv"}], "CSV", "SkipLines"->1] // Interpolation[#[[All, 1;;2]]]&;
C1pC1mWino = Import[FileNameJoin[{SUSYXSPATH, "data", "lhc_susy_xs_wg", "13TeVx1x1wino_envelope.csv"}], "CSV", "SkipLines"->1] // Interpolation[#[[All, 1;;2]]]&;
C1pC1mHino = Import[FileNameJoin[{SUSYXSPATH, "data", "lhc_susy_xs_wg", "13TeVx1x1hino_deg_mstw.csv"}], "CSV", "SkipLines"->1] // Interpolation[#[[All, 1;;2]]]&;


LogPlot[{
  N2C1pmWino[x], C1pC1mWino[x], N2C1pmHino[x],  C1pC1mHino[x]}, {x, 200, 1000},
  PlotStyle->{{color[1], Thickness[0.006]}, {color[1], Thickness[0.006], Dashing[0.02]}, color[2], {color[2], Dashed}},
  PlotLegends->Placed[LineLegend[{
    MaTeX["\\tilde W^0\\tilde W^\\pm"],
    MaTeX["\\tilde W^+\\tilde W^-"],
    MaTeX["\\tilde H^0_i\\tilde H^\\pm"],
    MaTeX["\\tilde H^+\\tilde H^-"]
    }, Spacings->0.4], {0.8,0.68}],
  PlotRangePadding->None, PlotRange->{{200,1000},{0.1,3000}},
  FrameLabel->{MaTeX["\\text{mass [GeV]}"], MaTeX["\\sigma_{\\text{13\\,TeV}}(pp\\to\\text{ewkino})\\text{ [fb]}"]}
]
outputPDF[%, "xs"]



