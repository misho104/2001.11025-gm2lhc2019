#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd =!= Null,
  (* called as a notebook *)
  SetDirectory[NotebookDirectory[]];
  files = FileNames["../spectrum/x050/tab1_*.slha"];
  ,
  (* called as a script *)
  If[Length[$ScriptCommandLine] <= 1, Print["Usage: " $ScriptCommandLine[[1]] <> " files"]; Abort[]];
  files = $ScriptCommandLine[[2;;]];
];
<<"common.wl";


Acceptance`A["ATLAS1803c"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_3L.decay"]]
Acceptance`A["CMS1709a"] [SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_3L.decay"]]
Acceptance`A["CMS1709b2"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_3L.decay"]]
Acceptance`A["CMS1709c1"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_LLT.decay"]]
Acceptance`A["CMS1709c2"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_LLT.decay"]]


xLabel[slha_] := slha["mass"][1000024];
M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];

slhas = Association @@ Sort[xLabel[#]->#& /@ (If[FileExistsQ[#], SLHA`ReadSLHA[#], Print["Not a file: " <> TextString[#]]; Abort[]] &/@ files) ]
massPlot[slhas]
cFactorsPlot[slhas]

slhasToAnalyse = Select[slhas, xLabel[#]>280&];
N2C1$3L = ReadSLHA[LHCSLHA["N2C1_3L.decay"]];

ATL1803UL = \[Sigma]UL2D["ATL1803UL", ATLASUpperLimit["../lhc/atlas1803/HEPData-ins1658902-v1-Table_80.csv", "SkipLines"->11]];
CMS1709UL = \[Sigma]UL2D["cms-slep-0.5", CMSUpperLimit["cms-slep-0.5"]];
ListLogPlot[{
    {xLabel[#], calc\[Sigma]EWKino[#,2,1]}&/@Values[slhasToAnalyse] // Sort,
    {xLabel[#], ATL1803UL[M2[#],M1[#]] / K\[CapitalGamma]["ATLAS1803c", N2C1$3L, #]}&/@Values[slhasToAnalyse] // Sort,
    {xLabel[#], CMS1709UL[M2[#],M1[#]] / K\[CapitalGamma]["ATLAS1803c", N2C1$3L, #]}&/@Values[slhasToAnalyse] // Sort
  },
  Joined->True,
  PlotStyle->color/@{1,3,4},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\text{cross section [fb]}"]},
  PlotRange->{All, Automatic},
  PlotLegends->{"theory", "95% UL (ATL1803)", "95% UL (CMS1709)"}
]



