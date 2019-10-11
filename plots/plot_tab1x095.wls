#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";


files = FileNames["../spectrum/x095/tab1_*.slha"];
slhas = ReadSLHAFiles[files, "Label"->(#["mass"][1000024]&)]


Select[slhas, #["LSP"] != 1000022&] (* pick up non-bino-LSP point *)
massPlot[slhas]
outputPDF[%, "mass"]
cFactorsPlot[slhas]
outputPDF[%, "cfactors"]

ListPlot[TemporalData[
  {#["mass"][1000011] - #["mass"][1000024],
   #["mass"][1000015] - #["mass"][1000024],
   #["mass"][1000016] - #["mass"][1000024],
   #["mass"][1000023] - #["mass"][1000024]
   } &/@ Values[slhas],
  {Keys[slhas]}],
  PlotMarkers->{"\[EmptySmallCircle]", "\[EmptySmallCircle]", "\[Dash]", "\[Cross]"},
  PlotStyle->{Red, Blue, Black},
  PlotLegends->{
               MaTeX["\\tilde\\ell_{\\mathrm L}-\\tilde\\chi^\\pm_1"],
               MaTeX["\\tilde\\tau_{\\mathrm L}-\\tilde\\chi^\\pm_1"],
               MaTeX["\\tilde\\nu-\\tilde\\chi^\\pm_1"],
               MaTeX["\\tilde\\chi^0_2-\\tilde\\chi^\\pm_1"]
               }]
outputPDF[%, "massdiff"]


ListPlot[TemporalData[
 ({"Nse" + "Nsmu", "Nstau", "NH", "NZ", "Csl1"+"Csl2", "Csl3", "CW"} //. DecayRateAliases[#,2,1]) &/@ Values[slhas],
  {Keys[slhas]}],
  PlotMarkers->{"\[SmallCircle]", "\[Cross]", "H", "Z", "\[SmallCircle]", "\[Cross]", "W"},
  PlotStyle->{Black, Black, Black, Black, Red, Red, Red},
  PlotRange->{All, All},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\text{Branching ratio of $\\tilde\\chi_1^0$ \\color{red}($\\tilde\\chi_1^\\pm$)}"]},
  PlotLegends->{MaTeX["\\tilde\\ell^\\pm"], MaTeX["\\tilde\\tau^\\pm"], None, None, MaTeX["\\tilde\\ell^\\pm,\\tilde\\nu_\\ell"], MaTeX["\\tilde\\tau^\\pm,\\tilde\\nu_\\tau"]}
]
outputPDF[%, "br21"]


CMS1709ULa = \[Sigma]UL2D["cms-NC-3L-0.95", CMSUpperLimit["cms-NC-3L-0.95"]];
CMS1709ULe = \[Sigma]UL2D["cms-NC-WH", CMSUpperLimit["cms-NC-WH"]];


slhasToAnalyse = Select[slhas, xLabel[#]>0&];
N2C1$3L = ReadSLHA[LHCSLHA["N2C1_3L.decay"]];
N2C1$WH = ReadSLHA[LHCSLHA["N2C1_WH.decay"]];

M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];
ListLogPlot[{
    {xLabel[#], calc\[Sigma]EWKino[#,2,1]}&/@Values[slhasToAnalyse],
    {xLabel[#], CMS1709ULa[M2[#],M1[#]] / K\[CapitalGamma]["CMS1709a", N2C1$3L, #]}&/@Values[slhasToAnalyse],
    {xLabel[#], CMS1709ULa[M2[#],M1[#]] / K\[CapitalGamma]["CMS1709e", N2C1$WH, #]}&/@Values[slhasToAnalyse]
  },
  Joined->True,
  PlotStyle->color/@{1,3,4},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\text{cross section [fb]}"]},
  PlotRange->{All, Automatic},
  PlotLegends->{"theory", "95% UL (CMS1709)"}
]
outputPDF[%, "limit"]






