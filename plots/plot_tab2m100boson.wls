#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";


grid = FileNames["../spectrum/grid/tab2_*.slha"] // ReadSLHAFiles[#, "Label"->({#["mass"][1000024], #["mass"][1000013]}&)]&;
{ListContourPlot[#["decay", 1000023][1000022, 23] * #["decay", 1000024][1000022, 24] &/@ grid, Contours->Range[10]/10],
ListContourPlot[#["decay", 1000023][1000022, 25] * #["decay", 1000024][1000022, 24] &/@ grid, Contours->Range[10]/10]}
{ListContourPlot[#["decay", 1000025][1000022, 23] * #["decay", 1000024][1000022, 24] &/@ grid, Contours->Range[10]/10],
ListContourPlot[#["decay", 1000025][1000022, 25] * #["decay", 1000024][1000022, 24] &/@ grid, Contours->Range[10]/10]}


files = FileNames["../spectrum/m100grid/tab2_*_1200.slha"] // Select[#, StringMatchQ[#, RegularExpression[".*_..._.*"]]&]&;
slhas = ReadSLHAFiles[files, "Label"->(#["mass"][1000024]&)];
massPlot[slhas]
outputPDF[%, "mass"]
cFactorsPlot[slhas]
outputPDF[%, "cfactors"]


ListPlot[{
    #["decay", 1000023][1000022,23]&/@ slhas,
    #["decay", 1000023][1000022,25]&/@ slhas,
    #["decay", 1000025][1000022,23]&/@ slhas,
    #["decay", 1000025][1000022,25]&/@ slhas,
    #["decay", 1000035][1000022,23]&/@ slhas,
    #["decay", 1000035][1000022,25]&/@ slhas,
    #["decay", 1000024][1000022,24]&/@ slhas,
    #["decay", 1000037][1000022,24]&/@ slhas
  },
  PlotStyle->{Blue, Blue, Black, Black, Red, Red, Green, Magenta},
  PlotMarkers->{"Z", "h", "Z", "h", "Z", "h", "W", "W"},
  PlotLegends->Placed[PointLegend[
    {None, None, None, None},
    {
      MaTeX["\\mathop{\\mathrm{Br}}(\\tilde\\chi^0_{2,3,4}\\to\\tilde\\chi^0_1 Z)"],
      MaTeX["\\mathop{\\mathrm{Br}}(\\tilde\\chi^0_{2,3,4}\\to\\tilde\\chi^0_1 h)"],
      MaTeX["\\mathop{\\mathrm{Br}}(\\tilde\\chi^\\pm_{1,2}\\to\\tilde\\chi^0_1 W^\\pm)"]
    },
    LegendMarkers->{
      Row[{Style["Z", {Italic, Blue, FontFamily->"Times New Roman", FontSize->12}], " ",
            Style["Z", {Italic, Black, FontFamily->"Times New Roman", FontSize->12}], " ",
            Style["Z", {Italic, Red, FontFamily->"Times New Roman", FontSize->12}]}],
      Row[{Style["h", {Italic, Blue, FontFamily->"Times New Roman", FontSize->12}], " ",
            Style["h", {Italic, Black, FontFamily->"Times New Roman", FontSize->12}], " ",
            Style["h", {Italic, Red, FontFamily->"Times New Roman", FontSize->12}]}],
      Row[{Style["W", {Italic, Green, FontFamily->"Times New Roman", FontSize->12}], " ",
            Style["W", {Italic, Magenta, FontFamily->"Times New Roman", FontSize->12}]}]
            },
    LegendMarkerSize->28], {0.6, 0.5}],
  PlotRange->{Automatic, {0,Automatic}},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"]}]
outputPDF[%, "br"]


ListPlot[
  TemporalData[
    Table[Mean[cFactors[#, i, j]] #["decay", PidN[i]][1000022,23] #["decay", PidC[j]][1000022,24]&/@ Values[slhas], {j, 2}, {i, {2,3,4}}] // Flatten[#,1 ]&,
    {xLabel/@Values[slhas]}
  ],
  PlotStyle->{color[1], color[3], color[4], color[1], color[3], color[4]},
  PlotMarkers->{"+", "+", "+", "\[Cross]", "\[Cross]", "\[Cross]"},
  PlotLegends->(Table[TextString[i*10+j], {j, 2}, {i, {2,3,4}}]//Flatten),
  PlotLabel->MaTeX["K_\\sigma K_\\Gamma\\text{ for }WZ"],
  PlotRange->{All, All},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"]}]
outputPDF[%, "WZ"]

ListPlot[
  TemporalData[
    Table[Mean[cFactors[#, i, j]] #["decay", PidN[i]][1000022,25] #["decay", PidC[j]][1000022,24]&/@ Values[slhas], {j, 2}, {i, {2,3,4}}] // Flatten[#,1 ]&,
    {xLabel/@Values[slhas]}
  ],
  PlotStyle->{color[1], color[3], color[4], color[1], color[3], color[4]},
  PlotMarkers->{"+", "+", "+", "\[Cross]", "\[Cross]", "\[Cross]"},
  PlotLegends->(Table[TextString[i*10+j], {j, 2}, {i, {2,3,4}}]//Flatten),
  PlotLabel->MaTeX["K_\\sigma K_\\Gamma\\text{ for }Wh"],
  PlotRange->{All, All},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"]}]
outputPDF[%, "WH"]


ATL1803WZ = \[Sigma]UL2D["ATL1803UL", ATLASUpperLimit["../lhc/atlas1803/HEPData-ins1658902-v1-Table_81.csv", "SkipLines"->12]];
ATL1806WZ = \[Sigma]UL2D["ATL1806UL", ATLASUpperLimit["../lhc/atlas1806/HEPData-ins1676551-v1-Cross-section_UL_combined.csv", "SkipLines"->1]];
ATL1909WH = \[Sigma]UL2D["ATL1909UL", {#[[1]], #[[2]], #[[3]]*1000} & /@ Select[Import["../lhc/atlas1909/HEPData-ins1755298-v1-Upper_limits_1Lbb.csv", "CSV", "IgnoreEmptyLines" -> True, "SkipLines"->11], MatchQ[#, {_?NumericQ, _?NumericQ, _?NumericQ}] &]];
ATL1912WZ = \[Sigma]UL2D["ATL1912UL", ATLASUpperLimit["../lhc/atlas1912/aux_tab1.csv", "SkipLines"->1]];
ATL2004WH = \[Sigma]UL2D["ATL2004UL", {#[[1]], #[[2]], #[[3]]*1000} & /@ Select[Import["../lhc/atlas2004/HEPData-ins1792399-v1-Table_07.csv.formatted", "CSV", "IgnoreEmptyLines" -> True, "SkipLines"->9], MatchQ[#, {_?NumericQ, _?NumericQ, _?NumericQ, _?NumericQ}] &]];
CMS1709WZ = \[Sigma]UL2D["cms-NC-WZ-1709", CMSUpperLimit["cms-NC-WZ-1709"]];
CMS1709WH = \[Sigma]UL2D["cms-NC-WH-1709", CMSUpperLimit["cms-NC-WH-1709"]];
CMS1801WZ = \[Sigma]UL2D["cms-NC-WZ", CMSUpperLimit["cms-NC-WZ"]];
CMS1801WH = \[Sigma]UL2D["cms-NC-WH", CMSUpperLimit["cms-NC-WH"]];
CMS2012WZ = \[Sigma]UL2D["cms-NC-WZ-2012", CMSUpperLimit["cms-NC-WZ-2012"]];

(* Note: although ATL2004UL data file says "fb", it must be a typo of "pb";
         see http://atlas.web.cern.ch/Atlas/GROUPS/PHYSICS/PAPERS/SUSY-2018-23/tabaux_07.png *)

M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];

ListLogPlot[{
    {xLabel[#], calc\[Sigma]EWKino[#,2,1]}&/@Values[slhas],
    {xLabel[#], CMS1709WZ[M2[#],M1[#]] / A["CMS1709d"][#,2,1] }&/@Select[Values[slhas], 200<xLabel[#]<710&],
    {xLabel[#], CMS1801WZ[M2[#],M1[#]] / A["CMS1709d"][#,2,1] }&/@Select[Values[slhas], 200<xLabel[#]<710&],
    {xLabel[#], CMS2012WZ[M2[#],M1[#]] / A["CMS1709d"][#,2,1] }&/@Select[Values[slhas], 200<xLabel[#]<930&],
    {xLabel[#], ATL1803WZ[M2[#],M1[#]] / A["CMS1709d"][#,2,1] }&/@Select[Values[slhas], 200<xLabel[#]<650&],
    {xLabel[#], ATL1806WZ[M2[#],M1[#]] / A["CMS1709d"][#,2,1] }&/@Select[Values[slhas], 200<xLabel[#]<710&],
    {xLabel[#], ATL1912WZ[M2[#],M1[#]] / A["CMS1709d"][#,2,1] }&/@Select[Values[slhas], 200<xLabel[#]<510&],
    {xLabel[#], CMS1709WH[M2[#],M1[#]] / A["CMS1709e"][#,2,1] }&/@Select[Values[slhas], 220<xLabel[#]<350&],
    {xLabel[#], CMS1801WH[M2[#],M1[#]] / A["CMS1709e"][#,2,1] }&/@Select[Values[slhas], 220<xLabel[#]<710&],
    {xLabel[#], ATL1909WH[M2[#],M1[#]] / A["CMS1709e"][#,2,1] }&/@Select[Values[slhas], 220<xLabel[#]<9999&],
    {xLabel[#], ATL2004WH[M2[#],M1[#]] / A["CMS1709e"][#,2,1] }&/@Select[Values[slhas], 220<xLabel[#]<410&]
  },
  Joined->True,
  PlotStyle->{
    color[1],
    {color[1], Dashed, Thickness[0.008]},
    {color[3], Dashed, Thickness[0.008]},
    {color[4], Dashed, Thickness[0.008]},
    {color[1], Dashed, Thickness[0.005]},
    {color[1], Dashed, Thickness[0.003]},
    {color[4], Dashed, Thickness[0.003]},
    {color[1], Dotted},
    {color[3], Dotted, Thickness[0.008]},
    {color[1], Dotted, Thickness[0.008]},
    {color[4], Dotted, Thickness[0.008]}
  },
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\text{cross section [fb]}"]},
  PlotRange->{{Automatic, 800}, Automatic},
  PlotLegends->{
    "theory (N2C1)",
    "UL (N2C1,CMS1709-WZ)",
    "UL (N2C1,CMS1801-WZ)",
    "UL (N2C1,CMS2012-WZ)",
    "UL (N2C1,ATL1803-WZ)",
    "UL (N2C1,ATL1806-WZ)",
    "UL (N2C1,ATL1912-WZ)",
    "UL (N2C1,CMS1709-WH)",
    "UL (N2C1,CMS1801-WH)",
    "UL (N2C1,ATL1909-WH)",
    "UL (N2C1,ATL2004-WH)"
  }
]
outputPDF[%, "limit"]


ListContourPlot[{#[[1]],#[[2]],Log10[#[[3]]]} &/@ ATLASUpperLimit["../lhc/atlas1912/aux_tab1.csv", "SkipLines"->1], PlotRange->{All,{99,101}}, Contours->{1,2,3,4,5}]
ListContourPlot[{#[[1]],#[[2]],Log10[#[[3]]]} &/@ ATLASUpperLimit["../lhc/atlas1806/HEPData-ins1676551-v1-Cross-section_UL_combined.csv", "SkipLines"->1],PlotRange->{All,{99,101}},Contours->{1,2,3,4,5}]






