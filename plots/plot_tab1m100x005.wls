#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";


files = FileNames["../spectrum/m100x005/tab1_*.slha"];
slhas = ReadSLHAFiles[files, "Label"->(#["mass"][1000024]&)]


Select[slhas, #["LSP"] != 1000022&] (* pick up non-bino-LSP point *)
massPlot[slhas]
outputPDF[%, "mass"]
cFactorsPlot[slhas]
outputPDF[%, "cfactors"]

ListPlot[TemporalData[
  {#["mass"][1000011] - #["mass"][1000022],
   #["mass"][1000015] - #["mass"][1000022],
   #["mass"][1000016] - #["mass"][1000022]} &/@ Values[slhas],
  {Keys[slhas]}],
  PlotMarkers->{"\[EmptySmallCircle]", "\[EmptySmallCircle]", "\[Dash]"},
  PlotStyle->{Red, Blue, Black},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], "mass difference [GeV]"},
  PlotLegends->{
               MaTeX["\\tilde\\ell_{\\mathrm L}-\\tilde\\chi^0_1"],
               MaTeX["\\tilde\\tau_{\\mathrm L}-\\tilde\\chi^0_1"],
               MaTeX["\\tilde\\nu-\\tilde\\chi^0_1"]}]
outputPDF[%, "massdiff"]


ListPlot[TemporalData[
 ({"Nse", "Nstau", "NH", "NZ", "CseL"+"CseR", "Csnue", "CstauL"+"CstauR", "Csnutau", "CW"} //. DecayRateAliases[#,2,1]) &/@ Values[slhas],
  {Keys[slhas]}],
  PlotMarkers->{"\[SmallCircle]", "\[Cross]", "H", "Z", "\[SmallCircle]", "\[SmallCircle]", "\[Cross]", "\[Cross]", "W"},
  PlotStyle->{Black, Black, Black, Black, Red, Blue, Red, Blue, Red},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\text{Branching ratio of $\\tilde\\chi_2^0$ \\color{red}($\\tilde\\chi_1^\\pm$)}"]},
  PlotLegends->PointLegend[
    {None, None, None, None},
    {MaTeX["\\tilde e^\\pm"], MaTeX["\\tilde\\tau^\\pm"], MaTeX["\\tilde\\nu_e"], MaTeX["\\tilde\\nu_\\tau"]},
    LegendMarkers->{
      {Row[{"\[SmallCircle]", " ", Style["\[SmallCircle]", Red]}], 16},
      {Row[{"\[Cross]", " ", Style["\[Cross]", Red]}], 14},
      {Row[{Style["\[SmallCircle]", Blue]}], 16},
      {Row[{Style["\[Cross]", Blue]}], 16}
      },
    LegendMarkerSize->28
  ]
]
outputPDF[%, "br21"]


CMS1709UL = \[Sigma]UL2D["cms-NC-3L-0.05", CMSUpperLimit["cms-NC-3L-0.05"]];

slhasToAnalyse = Select[slhas, xLabel[#]>0&];
N2C1$3L = ReadSLHA[LHCSLHA["N2C1_3L.decay"]];

M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];
ListLogPlot[{
    {xLabel[#], calc\[Sigma]EWKino[#,2,1]}&/@Values[slhasToAnalyse],
    {xLabel[#], CMS1709UL[M2[#],M1[#]] / K\[CapitalGamma]["CMS1709a", N2C1$3L, #]}&/@Values[slhasToAnalyse]
  },
  Joined->True,
  PlotStyle->color/@{1,3,4},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\text{cross section [fb]}"]},
  PlotRange->{All, Automatic},
  PlotLegends->{"theory", "95% UL (CMS1709)"}
]
outputPDF[%, "limit"]






