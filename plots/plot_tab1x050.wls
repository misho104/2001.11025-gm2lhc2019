#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";


files = FileNames["../spectrum/x050/tab1_*.slha"];
slhas = ReadSLHAFiles[files, "Label"->(#["mass"][1000024]&)]


Select[slhas, #["LSP"] != 1000022&] (* pick up non-bino-LSP point *)
massPlot[slhas]
outputPDF[%, "mass"]
cFactorsPlot[slhas]
outputPDF[%, "cfactors"]


ATL1803UL = \[Sigma]UL2D["ATL1803UL", ATLASUpperLimit["../lhc/atlas1803/HEPData-ins1658902-v1-Table_80.csv", "SkipLines"->11]];
CMS1709UL = \[Sigma]UL2D["cms-NC-3L-0.5", CMSUpperLimit["cms-NC-3L-0.5"]];

slhasToAnalyse = Select[slhas, xLabel[#]>280&];
N2C1$3L = ReadSLHA[LHCSLHA["N2C1_3L.decay"]];

M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];
ListLogPlot[{
    {xLabel[#], A["ATLAS1803c"][#]       * calc\[Sigma]EWKino[#,2,1]}&/@Values[slhasToAnalyse] // Sort,
    {xLabel[#], A["ATLAS1803c"][N2C1$3L] * ATL1803UL[M2[#],M1[#]]}&/@Values[slhasToAnalyse] // Sort,
  (*{xLabel[#], A["CMS1709a"][#]       * calc\[Sigma]EWKino[#,2,1]}&/@Values[slhasToAnalyse] // Sort,*)
    {xLabel[#], A["CMS1709a"][N2C1$3L] * CMS1709UL[M2[#],M1[#]]}&/@Values[slhasToAnalyse] // Sort
  },
  Joined->True,
  PlotStyle->color/@{1,3,4},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\sigma A~\\text{[fb]}"]},
  PlotRange->{All, Automatic},
  PlotLegends->{"theory", "95% UL (ATL1803)", "95% UL (CMS1709)"}
]
outputPDF[%, "limit"]



