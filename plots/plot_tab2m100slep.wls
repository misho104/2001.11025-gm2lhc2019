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


cmsLimitAssoc = Association[{#[[1]], #[[2]]}->#[[3]] &/@ Select[CMSUpperLimit["cms-slep"], #[[3]] > 0 &]];
cmsLimitMesh = DelaunayToElementMesh[TransformedRegion[DelaunayMesh[{#[[1]],#[[2]]-0.1*#[[1]]}&/@Keys[cmsLimitAssoc]], {#[[1]], #[[2]]+0.1*#[[1]]}&]];
Graphics[cmsLimitMesh["Wireframe"][[1]], Axes->True]
cmsLimit = ElementMeshInterpolation[{cmsLimitMesh}, Values[cmsLimitAssoc],
  "ExtrapolationHandler" -> {Function[Indeterminate],
  "WarningMessage" -> False}
];


atlCriterion[slha_] := Module[{
    xs = calc\[Sigma]EL[slha["mass"][1000013]] * 2 * 1000 (* in fb *),
    ul = atlasLimit[slha["mass"][1000013], slha["mass"][1000022]],
    br = slha["decay", 1000013][1000022, 13]},
  xs * br^2 / ul]

cmsCriterion[slha_] := Module[{
    (* Sho believes that the CMS upper limit in CMS-SUS-20-001_Figure_014.root is \[Sigma](seL seL) + \[Sigma](seR seR), i.e., for single generation. See Addenbum in this file. *)
    xs = calc\[Sigma]EL[slha["mass"][1000013]] * 1 * 1000 (* in fb *),
    ul = cmsLimit[slha["mass"][1000013], slha["mass"][1000022]],
    br = slha["decay", 1000013][1000022, 13]},
  xs * br^2 / ul]

atlResult = atlCriterion /@ Select[grid, #["mass"][1000013]<750&];
cmsResult = cmsCriterion /@ Select[grid, #["mass"][1000013]<750&];
Show[{
  ListPlot[Keys[grid]],
  ListPlot[Keys[Select[atlResult, #>1&]], PlotStyle->{Blue, Opacity[0.3],  Large}, PlotMarkers->{"\[FilledSquare]"}],
  ListPlot[Keys[Select[cmsResult, #>1&]], PlotStyle->{Red, Opacity[0.3], Large}, PlotMarkers->{"\[FilledSquare]"}]
},
  PlotRange->{{150, 1200}, {150, 700}},
  PlotRangePadding->None,
  PlotLabel->"slepton exclusion",
  FrameLabel->MaTeXRaw[{"m(\\tilde\\chi^\\pm_1) \\text{ [GeV]}", "m(\\tilde\\mu_{\\mathrm L}) \\text{ [GeV]}"}]
]
outputPDF[%, "limit"]


(* Figure for draft *)
{#["mass"][1000024], #["mass"][1000013], Log[atlCriterion[#]]} &/@ Select[Values[grid], #["mass"][1000013]<700&];
atlInterp = Interpolation[Select[%, FreeQ[Indeterminate]]];
atlRegion = RegionPlot[atlInterp[x, y] > 0, {x, 200, 1100}, {y, 100, 1000}, PlotStyle->None, BoundaryStyle->Blue, PlotPoints->100, PlotRangePadding->None];

{#["mass"][1000024], #["mass"][1000013], Log[cmsCriterion[#]]} &/@ Select[Values[grid], #["mass"][1000013]<700&];
cmsInterp = Interpolation[Select[%, FreeQ[Indeterminate]]];
cmsRegion = RegionPlot[cmsInterp[x, y] > 0, {x, 200, 1100}, {y, 100, 1000}, PlotStyle->None, BoundaryStyle->Red, PlotPoints->100, PlotRangePadding->None];
Show[{cmsRegion, atlRegion}]


(* ::Section:: *)
(*Addendum: Verification of normalizations*)


verificationGrid = Table[{slep, bino}, {slep, 100, 800, 25}, {bino, 1, 801, 2}]//Flatten[#,1]&//Select[#, #[[1]]>#[[2]]&]&;


calc\[Sigma]SelSelAndSerSerCache = Association[];
calc\[Sigma]SelSelAndSerSer[mass_] /; NumberQ[mass] := Lookup[calc\[Sigma]SelSelAndSerSerCache, mass,
  Module[{result},
    Run["susy-xs get 13TeV.slepslep " <> TextString[mass] <> " -0 > tmp"];
    result = Import["tmp", "List"];
    If[Length[result]=!=1, Print["susy-xs launch failed."]; Abort[]];
    calc\[Sigma]SelSelAndSerSerCache[mass] = result[[1]];
    result[[1]]
  ]
]


(*
  These lines reproduce their official exclusion plot.
  One can verify how we should interpret the "limit" values in their data.
*)
atlVerifInterp = Interpolation[Select[{#[[1]], #[[2]], Log[calc\[Sigma]SelSelAndSerSer[#[[1]]]*2*1000 / atlasLimit[#[[1]], #[[2]]]]} &/@ verificationGrid, FreeQ[Indeterminate]]];
cmsVerifInterp = Interpolation[Select[{#[[1]], #[[2]], Log[calc\[Sigma]SelSelAndSerSer[#[[1]]]*1*1000 / cmsLimit  [#[[1]], #[[2]]]]} &/@ verificationGrid, FreeQ[Indeterminate]]];
RegionPlot[atlVerifInterp[x, y] > 0, {x, 100, 800}, {y, 0, 500}, PlotStyle->RGBColor[0.6, 0.6, 1, 0.3], BoundaryStyle->Blue, PlotPoints->100]
RegionPlot[cmsVerifInterp[x, y] > 0, {x, 100, 800}, {y, 0, 500}, PlotStyle->RGBColor[0.6, 0.6, 1, 0.3], BoundaryStyle->Red, PlotPoints->100]



