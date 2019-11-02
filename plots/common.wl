(* ::Package:: *)

$ProjectRoot = NestWhile[ParentDirectory, Directory[], (Not[FileExistsQ[FileNameJoin[{#2, ".git"}]]] && UnsameQ[#1, #2]) &, 2];
AppendTo[$Path, FileNameJoin[{$ProjectRoot, "spectrum"}]]
AppendTo[$Path, "lib"];
Get["gm2grid.wl"];
Needs["PlotTools`"];
Needs["Acceptance`"];
Needs["CrossSection`"];
Needs["MaTeX`"];


PidN[i:1|2|3|4] := {1000022, 1000023, 1000025, 1000035}[[i]]
PidC[j:1|2]     := {1000024, 1000037}[[j]]


Needs["NDSolve`FEM`"];
DelaunayToElementMesh[dmesh_] := ToElementMesh[
  "Coordinates" -> MeshCoordinates[dmesh],
  "MeshElements" -> {TriangleElement @ Pick[
    First @ Thread[MeshCells[dmesh, 2], Polygon],
    Unitize[Chop @ Flatten@ PropertyValue[{dmesh, 2}, MeshCellMeasure]],
    1]
  }
];


ReadSLHAFiles[files_, OptionsPattern[{"Label"->None}]] := Module[{label = OptionValue["Label"], slhas},
  slhas = {#, If[FileExistsQ[#],
      ReadSLHA[#],
      Print["Not a file: " <> TextString[#]]; Abort[]
    ]} &/@ files;
  slhas = (If[label === None, #[[1]], label[#[[2]]]] -> #[[2]]) &/@ slhas;
  Association @@ Sort[slhas]
];


xLabel[slha_] := slha["mass"][1000024]
LHCSLHA[name_] := FileNameJoin[{$ProjectRoot, "lhc", "simplified_decays", name}]
K\[CapitalGamma][analysis_, originalSLHA_, actualSLHA_] := A[analysis][actualSLHA] / A[analysis][originalSLHA];


massPlot[slhas_] := ListPlot[TemporalData[
    {#["mass"][1000022], #["mass"][1000023], #["mass"][1000025], #["mass"][1000035], #["mass"][1000024], #["mass"][1000037], #["mass"][1000013], #["mass"][1000014], #["mass"][2000013]} &/@ Values[slhas]// Abs,
    {xLabel /@ Values[slhas]}],
  PlotMarkers->{"\[Dash]", "\[Dash]", "\[Dash]", "\[Dash]", "\[Cross]", "\[Cross]", "\[EmptySmallCircle]", "\[EmptySmallCircle]", "\[EmptyUpTriangle]"},
  PlotStyle->{Default, Default, Default, Default, Red, Red, Blue, Blue, Blue},
  PlotLegends->PointLegend[{Black,Red,Blue,Blue},MaTeXRaw[{"\\tilde\\chi^0_i","\\tilde\\chi^\\pm_i","\\tilde\\mu_{\\mathrm L}, \\tilde\\nu_\\mu", "\\tilde\\mu_{\\mathrm R}"}],LegendMarkers->{"\[Dash]", "\[Cross]", "\[EmptySmallCircle]", "\[EmptyUpTriangle]"}],
  PlotRange->{All, {0, 1300}},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], "mass [GeV]"}
];


cFactorsPlot[slhas_, i:1|2|3|4:2, j:1|2:1] := Module[{
  },
  ListPlot[TemporalData[cFactors[#, i, j] &/@ Values[slhas], {xLabel /@ Values[slhas]}],
    PlotStyle->{color[1], color[3], color[4], color[1], color[3], color[1], color[3], Black},
    PlotMarkers->{"\[Bullet]", "\[Bullet]", "\[Bullet]", "\[EmptySmallCircle]", "\[EmptySmallCircle]", "\[Cross]", "\[Cross]", "\[FilledSmallCircle]"},
    PlotLegends->Join[MaTeXRaw[{"c_{\\mathrm{LL}}", "c_{\\mathrm{LR}}", "c_{\\mathrm{RR}}"}], {"n2\[Rule]lep", "n2\[Rule]tau", "c1\[Rule]lep", "c1\[Rule]tau", MaTeXRaw["K_\\gamma"]}],
    FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], None},
    PlotRange->{All, Automatic}
  ]
]
cFactorsMeanPlot[slhas_] := Module[{
  },
  ListPlot[TemporalData[
    {
      Mean[cFactors[#, 2, 1]], Mean[cFactors[#, 3, 1]], Mean[cFactors[#, 4, 1]],
      Mean[cFactors[#, 2, 2]], Mean[cFactors[#, 3, 2]], Mean[cFactors[#, 4, 2]]
    } &/@ Values[slhas],
    {xLabel /@ Values[slhas]}],
    PlotStyle->{color[1], color[3], color[4], color[1], color[3], color[4]},
    PlotMarkers->{"+", "+", "+", "\[Cross]", "\[Cross]", "\[Cross]"},
    PlotLegends->(MaTeX["\\overline{c}("<>#<>")"] &/@ {"21", "31", "41", "22", "32", "42"}),
    FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], None},
    PlotRange->{All, Automatic}
  ]
]

CMSUpperLimit[name_] := Module[{rows},
  rows = RunProcess[{"python", "../lhc/cms_xs_parse.py", name, "all"}]["StandardOutput"] // ImportString;
  (* force to target/GeV, LSP/GeV, UL/fb *)
  {#[[1]], #[[2]], #[[3]]*1000} & /@ Select[rows, MatchQ[#, {_?NumericQ, _?NumericQ, _?NumericQ}] &]]

ATLASUpperLimit[path_, importOptions__] := Module[{rows},
  rows = Import[path, "CSV", "IgnoreEmptyLines" -> True, importOptions];
  (* force to target/GeV, LSP/GeV, UL/fb *)
  {#[[2]], #[[1]], #[[3]]} & /@ Select[rows, MatchQ[#, {_?NumericQ, _?NumericQ, _?NumericQ}] &]]
