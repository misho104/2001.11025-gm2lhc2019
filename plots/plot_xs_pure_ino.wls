#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd === Null, Print["This is not for scripting; run from Frontend."]; Abort[];];

If[$FrontEnd =!= Null, SetDirectory[NotebookDirectory[]]];
$ProjectRoot = NestWhile[ParentDirectory, Directory[], (Not[ FileExistsQ[FileNameJoin[{#2, ".git"}]]] && UnsameQ[#1, #2]) &, 2];

<<"plot_tools.wl";

SetOptions[#, ContourShading->None, PlotRangePadding->None, ImageSize->400] &/@ {ContourPlot, ListContourPlot};


tupleToErrorList[a_List] := {a[[1]], Around[a[[2]], {a[[3]], a[[4]]}]}
data[name_String] := tupleToErrorList/@Import[FileNameJoin[{$ProjectRoot, "xs", "pure_ino", "result_"<>name<>".txt"}], "TSV"]


ListLogPlot[{
   data["wino_nxp"], data["wino_nxm"], data["wino_xx"],
   data["hino_nxp"], data["hino_nxm"], data["hino_xx"], data["hino_nn"]
}, PlotStyle->{color[1], color[3], color[4], {color[1], Dotted}, {color[3], Dotted}, {color[4], Dotted}, {color[5], Dotted}}, Joined->True,
  FrameLabel->{"mass [GeV]", "cross section [pb]"},
  PlotLegends->MaTeXRaw[{
    "\\tilde W^0\\tilde W^+", "\\tilde W^0\\tilde W^-", "\tilde W^+\tilde W^-",
    "\\sum\\tilde H^0_i\\tilde H^+", "\\sum\\tilde H^0_i\\tilde H^-", "\tilde H^+\tilde H^-", "\sum\tilde H^0_i \tilde H^0_j"
    }],
  PlotRange->{{200, 1200}, Automatic}
]
outputPDF["xs", %]


ListPlot[{
    {#[[1,1]], #[[1,2,1]]/#[[2,2,1]]}&/@Transpose[{data["wino_nxp"], data["hino_nxp"]}],
    {#[[1,1]], #[[1,2,1]]/#[[2,2,1]]}&/@Transpose[{data["wino_nxm"], data["hino_nxm"]}],
    {#[[1,1]], #[[1,2,1]]/#[[2,2,1]]}&/@Transpose[{data["wino_xx"], data["hino_xx"]}]
  }, PlotStyle->{{color[1], Dotted}, {color[3], Dotted}, {color[4], Dotted}}, Joined->True,
  FrameLabel->{"mass [GeV]", "ratio"},
  PlotLegends->MaTeXRaw[{
    "\\tilde W^0\\tilde W^+ / \\sum\\tilde H^0_i\\tilde H^+",
    "\\tilde W^0\\tilde W^- / \\sum\\tilde H^0_i\\tilde H^-",
    "\\tilde W^+\\tilde W^- / \\tilde H^+\\tilde H^-"
    }],
  PlotRange->{{200, 1200}, Automatic}
]
outputPDF["ratio", %]



