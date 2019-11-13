#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";

grid = FileNames["../spectrum/m100grid/tab2_*.slha"] // ReadSLHAFiles[#, "Label"->({#["mass"][1000024], #["mass"][1000013]}&)]&;


ListContourPlot[
  #["decay", 1000013][1000022, 13] &/@ grid,
  Contours->Range[5]/5//N, 
  PlotRange->{{200, 800}, {200, 800}},
  ContourShading->None,
  ContourLabels->Function[{x, y, z}, 
     Text[z, {x/2, y/2}, BaseStyle->{FontSize->9}]],
  PlotRangePadding->None,
  PlotLabel->MaTeX["\\mathop{\\mathrm{Br}}(\\tilde\\mu\\to\\tilde\\chi_1^0\\mu)"],
  FrameLabel->MaTeXRaw[{"m(\\tilde\\chi^\\pm_1) \\text{ [GeV]}", "m(\\tilde\\mu_{\\mathrm L}) \\text{ [GeV]}"}]
];
ListContourPlot[#["mass"][1000013] - Min[#["mass"][1000024], #["mass"][1000023]] &/@ grid, Contours->{0}, ContourShading->{Gray, None}];
Show[{%%,%}, PlotRange->{{200, 800}, {200, 800}}]


(* upper limit: (mslep, mn1) \[Rule] UL/fb *)
atlasLimitAssoc = Association[{#[[2]], #[[1]]}->#[[3]] &/@ ATLASUpperLimit["../lhc/atlas1908/aux_fig_3c_fixed.csv", "SkipLines"->1]];
atlasLimitMesh = DelaunayToElementMesh[TransformedRegion[DelaunayMesh[{#[[1]],#[[2]]-0.1*#[[1]]}&/@Keys[atlasLimitAssoc]], {#[[1]], #[[2]]+0.1*#[[1]]}&]];
Graphics[atlasLimitMesh["Wireframe"][[1]], Axes->True]
atlasLimit = ElementMeshInterpolation[{atlasLimitMesh}, Values[atlasLimitAssoc],
  "ExtrapolationHandler" -> {Function[Indeterminate], 
  "WarningMessage" -> False}
];


criterion[slha_] := Module[{
    xs = calc\[Sigma]EL[slha["mass"][1000013]] * 2 * 1000 (* in fb *),
    ul = atlasLimit[slha["mass"][1000013], slha["mass"][1000022]],
    br = slha["decay", 1000013][1000022, 13]},
  xs * br^2 / ul]
result = criterion /@ Select[grid, #["mass"][1000013]<700&];
Show[{
  ListPlot[Keys[grid]],
  ListPlot[Keys[Select[result, #>1&]], PlotStyle->{Red, Large}, PlotMarkers->{"\[FilledSquare]"}]
},
  PlotRange->{{150, 1200}, {150, 700}},
  PlotRangePadding->None,
  PlotLabel->"slepton exclusion",
  FrameLabel->MaTeXRaw[{"m(\\tilde\\chi^\\pm_1) \\text{ [GeV]}", "m(\\tilde\\mu_{\\mathrm L}) \\text{ [GeV]}"}]
]
outputPDF[%, "limit"]


(* Figure for draft *)
{#["mass"][1000024], #["mass"][1000013], Log[criterion[#]]} &/@ Select[Values[grid], #["mass"][1000013]<700&];
interp = Interpolation[Select[%, FreeQ[Indeterminate]]];
RegionPlot[interp[x, y] > 0, {x, 200, 1100}, {y, 150, 1050}, PlotStyle->RGBColor[1, 0.6, 0.6], BoundaryStyle->Red, PlotPoints->100]
