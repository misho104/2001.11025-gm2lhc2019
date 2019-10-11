#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";


(* SR3L; 0.5-kinematics *)
CMS1709lep050 = {\[Sigma]UL2D["cms-NC-3L-0.5", CMSUpperLimit["cms-NC-3L-0.5"]],         A["CMS1709a"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_3L.decay"]]}
CMS1709llt050 = {\[Sigma]UL2D["cms-NC-LLT-0.5-3L", CMSUpperLimit["cms-NC-LLT-0.5-3L"]], A["CMS1709c1"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_LLT.decay"]]}

CMS1709lep005 = {\[Sigma]UL2D["cms-NC-3L-0.05-3L", CMSUpperLimit["cms-NC-3L-0.05-3L"]],   A["CMS1709b2"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_3L.decay"]]}
CMS1709llt005 = {\[Sigma]UL2D["cms-NC-LLT-0.05-3L", CMSUpperLimit["cms-NC-LLT-0.05-3L"]], A["CMS1709c1"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_LLT.decay"]]}

CMS1709lep095 = {\[Sigma]UL2D["cms-NC-3L-0.95-3L", CMSUpperLimit["cms-NC-3L-0.95-3L"]],   A["CMS1709b2"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_3L.decay"]]}
CMS1709llt095 = {\[Sigma]UL2D["cms-NC-LLT-0.95-3L", CMSUpperLimit["cms-NC-LLT-0.95-3L"]], A["CMS1709c1"][SLHA`ReadSLHA["../lhc/simplified_decays/N2C1_LLT.decay"]]}

files005 = FileNames["../spectrum/x005/tab1_*.slha"];
files050 = FileNames["../spectrum/x050/tab1_*.slha"];
files095 = FileNames["../spectrum/x095/tab1_*.slha"];
xLabel[slha_] := slha["mass"][1000024];
slhas005 = Association @@ Sort[xLabel[#]->#& /@ (If[FileExistsQ[#], SLHA`ReadSLHA[#], Print["Not a file: " <> TextString[#]]; Abort[]] &/@ files005) ]
slhas050 = Association @@ Sort[xLabel[#]->#& /@ (If[FileExistsQ[#], SLHA`ReadSLHA[#], Print["Not a file: " <> TextString[#]]; Abort[]] &/@ files050) ]
slhas095 = Association @@ Sort[xLabel[#]->#& /@ (If[FileExistsQ[#], SLHA`ReadSLHA[#], Print["Not a file: " <> TextString[#]]; Abort[]] &/@ files095) ]

M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];


ListLogPlot[{
    Function[slha, {xLabel[slha], #[[1]][M2[slha], M1[slha]] * #[[2]] &@ CMS1709lep050}] /@ Values[slhas050],
    Function[slha, {xLabel[slha], #[[1]][M2[slha], M1[slha]] * #[[2]] &@ CMS1709llt050}] /@ Values[slhas050]
  },
  Joined->True,
  PlotStyle->color/@{1,3,4},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["(A\\sigma)_{\\mathrm{UL}}\\text{~[fb]}"]},
  PlotRange->{All, Automatic},
  PlotLabel->"3L SR validation (x=0.5)",
  PlotLegends->{"Fig. 14", "Aux. Fig. 5"}
]
outputPDF[%, "SRA_tab1_050"]


ListLogPlot[{
    Function[slha, {xLabel[slha], #[[1]][M2[slha], M1[slha]] * #[[2]] &@ CMS1709lep005}] /@ Values[slhas005],
    Function[slha, {xLabel[slha], #[[1]][M2[slha], M1[slha]] * #[[2]] &@ CMS1709llt005}] /@ Values[slhas005]
  },
  Joined->True,
  PlotStyle->color/@{1,3,4},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["(A\\sigma)_{\\mathrm{UL}}\\text{~[fb]}"]},
  PlotRange->{All, {0.1,1000}},
  PlotLabel->"3L SR validation (x=0.05)",
  PlotLegends->{"Fig. 15a", "Aux. Fig. 7"}
]
outputPDF[%, "SRA_tab1_005"]


ListLogPlot[{
    Function[slha, {xLabel[slha], #[[1]][M2[slha], M1[slha]] * #[[2]] &@ CMS1709lep095}] /@ Values[slhas095],
    Function[slha, {xLabel[slha], #[[1]][M2[slha], M1[slha]] * #[[2]] &@ CMS1709llt095}] /@ Values[slhas095]
  },
  Joined->True,
  PlotStyle->color/@{1,3,4},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["(A\\sigma)_{\\mathrm{UL}}\\text{~[fb]}"]},
  PlotRange->{All, {0.1,1000}},
  PlotLabel->"3L SR validation (x=0.95)",
  PlotLegends->{"Fig. 15b", "Aux. Fig. 9"}
]
outputPDF[%, "SRA_tab1_095"]



