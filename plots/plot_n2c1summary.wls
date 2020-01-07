#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";


fileSets = <|
  "1gut"  -> (FileNames["../spectrum/grid/tab1_*_1200.slha"] // Select[#, StringMatchQ[#, RegularExpression[".*_*_.*"]]&]&),
  "1m100" -> (FileNames["../spectrum/m100grid/tab1_*_1200.slha"] // Select[#, StringMatchQ[#, RegularExpression[".*_*_.*"]]&]&),
  "2gut"  -> (FileNames["../spectrum/grid/tab2_*_1200.slha"] // Select[#, StringMatchQ[#, RegularExpression[".*_*_.*"]]&]&),
  "2m100" -> (FileNames["../spectrum/m100grid/tab2_*_1200.slha"] // Select[#, StringMatchQ[#, RegularExpression[".*_*_.*"]]&]&)
|>;
slhas = ReadSLHAFiles[#, "Label"->(#["mass"][1000024]&)]& /@ fileSets;


cFactorsMeanPlot[slhas_] := Module[{
    style = {color[1], color[2], color[3], {color[1], Dashed}, {color[2], Dashed}, {color[3], Dashed}},
    markers = {marker[1,PointSize->6], marker[4,PointSize->6], marker[2,PointSize->6], marker[6], marker[9], marker[7]}
  },
  Show[{
    ListPlot[{
      TemporalData[{xLabel[#], Mean[cFactors[#, 2, 1]]} & /@ Take[Values[slhas], {1, -1, 6}]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 3, 1]]} & /@ Take[Values[slhas], {2, -1, 6}]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 4, 1]]} & /@ Take[Values[slhas], {4, -1, 6}]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 2, 2]]} & /@ Take[Values[slhas], {6, -1, 6}]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 3, 2]]} & /@ Take[Values[slhas], {3, -1, 6}]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 4, 2]]} & /@ Take[Values[slhas], {6, -1, 6}]]
    } ,
      PlotStyle -> style,
      FrameLabel -> {MaTeX["m(\\tilde\\chi^\\pm_1)\\text{ [GeV]}"], None},
      PlotMarkers -> markers,
      PlotRange -> {{200, 550}, {0, 1}},
      AspectRatio->GoldenRatio, ImageSize->{Automatic, 350}, FrameTicks->{Automatic, {{200,300,400,500},None}}, GridLines->{{300,400,500},Automatic},
      Epilog -> {
        Inset[
          LineLegend[
            style,
            (MaTeX["R^{NC}_{" <> # <> "}", Magnification -> 0.9] & /@ {"21", "31", "41", "22", "32", "42"}),
            LegendLayout -> {"Column", 2},
            LegendMarkers -> markers, LegendMarkerSize -> {45, 20}, LegendMargins -> 0, Spacings -> {0,0.3,0.5,0}],
          Scaled[{0.98, 0.92}], {Right, Top}]
       }
     ],
    ListPlot[{
      TemporalData[{xLabel[#], Mean[cFactors[#, 2, 1]]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 3, 1]]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 4, 1]]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 2, 2]]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 3, 2]]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], Mean[cFactors[#, 4, 2]]} & /@ Values[slhas]]
    },
      PlotStyle -> style, Joined -> True, PlotRange->{All, All}
    ]}
]];
cFactorsMeanPlot/@slhas
KeyValueMap[outputPDF[#2,"cmean_"<>#1]&][%]


cFactorsPlot[slhas_, i:1|2|3|4:2, j:1|2:1, yrange_:{0.4,0.6}] := Module[{
  },
  ListPlot[TemporalData[cFactors[#, i, j] &/@ Values[slhas], {xLabel /@ Values[slhas]}],
    PlotMarkers->marker/@{1,2,3},
    PlotStyle->{color[1], color[2], color[3]},
    FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], None},
    Joined->True,
    AspectRatio->GoldenRatio, ImageSize->{Automatic, 350}, FrameTicks->{Automatic, {{200,300,400,500},None}}, GridLines->{{300,400,500},Automatic},
    PlotRange->{{200,550}, yrange},
    Epilog->{Inset[
       LineLegend[color/@{1,2,3}, MaTeX[{"c_{\\mathrm{LL}}", "c_{\\mathrm{LR}}", "c_{\\mathrm{RR}}"}],
       LegendMarkers -> markers, LegendMarkerSize -> {45, 20}, LegendMargins -> 0, Spacings -> {0,0.3,0.5,0}], Scaled[{0.7, 0.8}]]}]
]
cFactorsPlot[#,2,1, {0.5,0.6}]&/@slhas[[{1,2}]]
KeyValueMap[outputPDF[#2,"c21_"<>#1]&][%[[{1}]]]
cFactorsPlot[#,2,1, {0.9, 1}]&/@slhas[[{3,4}]]


            
            
            


massPlot[slhas_] := Module[{
  style = (color/@{1,1,1,1,2,2}),
  markers = marker/@{6,6,6,6,10,10}
},
  ListPlot[{
      TemporalData[{xLabel[#], #["mass"][1000022]//Abs} & /@ Take[Values[slhas], {1, -1, 2}]],
      TemporalData[{xLabel[#], #["mass"][1000023]//Abs} & /@ Take[Values[slhas], {1, -1, 2}]],
      TemporalData[{xLabel[#], #["mass"][1000025]//Abs} & /@ Take[Values[slhas], {1, -1, 2}]],
      TemporalData[{xLabel[#], #["mass"][1000035]//Abs} & /@ Take[Values[slhas], {1, -1, 2}]],
      TemporalData[{xLabel[#], #["mass"][1000024]//Abs} & /@ Take[Values[slhas], {2, -1, 2}]],
      TemporalData[{xLabel[#], #["mass"][1000037]//Abs} & /@ Take[Values[slhas], {2, -1, 2}]]},
  PlotMarkers->markers,
  PlotStyle->({#,Opacity[0.5]}&/@style),
  PlotRange->{{200,550}, {0, 1000}},
      AspectRatio->GoldenRatio, ImageSize->{Automatic, 350}, FrameTicks->{Automatic, {{200,300,400,500},None}}, GridLines->{{300,400,500},Automatic},
  Joined->True,
  Epilog -> {
    Inset[
      LineLegend[
        style[[{1,5}]],
        MaTeX[{"\\tilde\\chi^0_i","\\tilde\\chi^\\pm_i"}],
        LegendMarkers -> markers[[{1,5}]], LegendMarkerSize -> {45, 20}, LegendMargins -> 0, Spacings -> {0,0.3,0.5,0}],
      Scaled[{0, 0.98}], {Left, Top}]
    },
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], "mass [GeV]"}]
]
massPlot/@slhas
KeyValueMap[outputPDF[#2,"mass_"<>#1]&][%]


DecayNPlot[slhas_, pos_:{0.75, 0.76}] := Module[{
    style = {color[1], {color[1], Dashed}, color[2], {color[2], Dashed}, color[3], {color[3], Dashed}},
    markers = {marker[1,PointSize->6], marker[6], marker[4,PointSize->6], marker[9], marker[2,PointSize->6], marker[7]}
  },
  Show[{
    ListPlot[{
      TemporalData[{xLabel[#], #["decay", 1000023][1000022,23]} & /@ Take[Values[slhas], {3, -1, 3}]],
      TemporalData[{xLabel[#], #["decay", 1000023][1000022,25]} & /@ Take[Values[slhas], {3, -1, 3}]],
      TemporalData[{xLabel[#], #["decay", 1000025][1000022,23]} & /@ Take[Values[slhas], {1, -1, 3}]],
      TemporalData[{xLabel[#], #["decay", 1000025][1000022,25]} & /@ Take[Values[slhas], {1, -1, 3}]],
      TemporalData[{xLabel[#], #["decay", 1000035][1000022,23]} & /@ Take[Values[slhas], {2, -1, 3}]],
      TemporalData[{xLabel[#], #["decay", 1000035][1000022,25]} & /@ Take[Values[slhas], {2, -1, 3}]]
    } ,
      PlotStyle -> style,
      FrameLabel -> {MaTeX["m(\\tilde\\chi^\\pm_1)\\text{ [GeV]}"], None},
      PlotMarkers -> markers,
      PlotRange -> {{200, 550}, {0, 1}},
      AspectRatio->GoldenRatio, ImageSize->{Automatic, 350}, FrameTicks->{Automatic, {{200,300,400,500},None}}, GridLines->{{300,400,500},Automatic},
      Epilog -> {
        Inset[
          LineLegend[
            style,
MaTeX[
Table["\\mathop{\\mathrm{Br}}(\\tilde\\chi^0_"<>TextString[i]<>"\\to\\tilde\\chi^0_1"<>k<>")", {i, {2,3,4}}, {k, {"Z", "h"}}]//Flatten
, Magnification -> 0.9],
        LegendMarkers -> markers, LegendMarkerSize -> {45, 20}, LegendMargins -> 0, Spacings -> {0,0,0.5,0}],
          Scaled[pos], {Right, Top}]
       }
     ],
    ListPlot[{
      TemporalData[{xLabel[#], #["decay", 1000023][1000022,23]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], #["decay", 1000023][1000022,25]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], #["decay", 1000025][1000022,23]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], #["decay", 1000025][1000022,25]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], #["decay", 1000035][1000022,23]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], #["decay", 1000035][1000022,25]} & /@ Values[slhas]]
    },
      PlotStyle -> style, Joined -> True, PlotRange->{All, All}
    ]}
]];
DecayNPlot[#,{0.98, 0.8}]&/@slhas[[{1,3}]]
DecayNPlot[#,{0.71, 0.71}]&/@slhas[[{2,4}]]
KeyValueMap[outputPDF[#2,"neutdecay_"<>#1]&][Join[%,%%]]


DecayCPlot[slhas_, pos_:{0.9, 0.76}] := Module[{
    style = {color[1], color[2]},
    markers = {marker[1,PointSize->6], marker[4,PointSize->6]}
  },
  ListPlot[{
      TemporalData[{xLabel[#], #["decay", 1000024][1000022,24]} & /@ Values[slhas]],
      TemporalData[{xLabel[#], #["decay", 1000037][1000022,24]} & /@ Values[slhas]]
    } ,
    PlotStyle -> style,
    FrameLabel -> {MaTeX["m(\\tilde\\chi^\\pm_1)\\text{ [GeV]}"], None},
    PlotMarkers -> markers,
    PlotRange -> {{200, 550}, {0, 1}},
    Joined->True,
    AspectRatio->GoldenRatio, ImageSize->{Automatic, 350}, FrameTicks->{Automatic, {{200,300,400,500},None}}, GridLines->{{300,400,500},Automatic},
      Epilog -> {
        Inset[
          LineLegend[
            style,
            MaTeX[Table["\\mathop{\\mathrm{Br}}(\\tilde\\chi^\\pm_"<>TextString[i]<>"\\to\\tilde\\chi^0_1W^\\pm)", {i, 2}], Magnification -> 0.9],
        LegendMarkers -> markers, LegendMarkerSize -> {45, 20}, LegendMargins -> 0, Spacings -> {0,0.3,0.5,0}],
          Scaled[pos], {Right, Top}]
       }
     ]
];
DecayCPlot/@slhas
KeyValueMap[outputPDF[#2,"chardecay_"<>#1]&][%]


pidN[i:1|2|3|4]:={1000022,1000023,1000025,1000035}[[i]]
pidC[i:1|2]:={1000024,1000037}[[i]]
BrH[slha_, i:1|2|3|4]:=slha["decay", pidN[i]][1000022,25]
BrZ[slha_, i:1|2|3|4]:=slha["decay", pidN[i]][1000022,23]
BrW[slha_, i:1|2]:=slha["decay", pidC[i]][1000022,24]

effPlot[slhas_,t:"Z"|"h",pos_] := Module[{
    style = {color[1], color[2], color[3], {color[1], Dashed}, {color[2], Dashed}, {color[3], Dashed}},
    markers = {marker[1,PointSize->6], marker[4,PointSize->6], marker[2,PointSize->6], marker[6], marker[9], marker[7]},
    data = Function[{s, i, j}, {xLabel[s], Mean[cFactors[s, i, j]]*If[t=="Z",BrZ[s,i],BrH[s,i]]*BrW[s,j]}]
  },
  Show[{
    ListPlot[{
      TemporalData[data[#,2,1] & /@ Take[Values[slhas], {2, -1, 3}]],
      TemporalData[data[#,3,1] & /@ Take[Values[slhas], {2, -1, 3}]],
      TemporalData[data[#,4,1] & /@ Take[Values[slhas], {2, -1, 3}]],
      TemporalData[data[#,2,2] & /@ Take[Values[slhas], {2, -1, 3}]],
      TemporalData[data[#,3,2] & /@ Take[Values[slhas], {2, -1, 3}]],
      TemporalData[data[#,4,2] & /@ Take[Values[slhas], {2, -1, 3}]]
    } ,
      PlotStyle -> style,
      FrameLabel -> {MaTeX["m(\\tilde\\chi^\\pm_1)\\text{ [GeV]}"], None},
      PlotMarkers -> markers,
      PlotRange -> {{200, 550}, {0,If[t=="Z",0.3,1]}},
      AspectRatio->GoldenRatio, ImageSize->{Automatic, 350}, FrameTicks->{Automatic, {{200,300,400,500},None}}, GridLines->{{300,400,500},Automatic},
      Epilog -> {
        Inset[
          LineLegend[
            style,
            (MaTeX["A^{NC;"<>t<>"W}_{" <> # <> "}", Magnification -> 0.9] & /@ {"21", "31", "41", "22", "32", "42"}), LegendLayout->{"Column",2},
            LegendMarkers -> markers, LegendMarkerSize -> {45, 20}, LegendMargins -> 0, Spacings -> {-0.3,0.3, 0.2,0}],
          Scaled[pos], {Center, Top}]
       }
     ],
    ListPlot[{
      TemporalData[data[#,2,1] & /@ Values[slhas]],
      TemporalData[data[#,3,1] & /@ Values[slhas]],
      TemporalData[data[#,4,1] & /@ Values[slhas]],
      TemporalData[data[#,2,2] & /@ Values[slhas]],
      TemporalData[data[#,3,2] & /@ Values[slhas]],
      TemporalData[data[#,4,2] & /@ Values[slhas]]
    },
      PlotStyle -> style, Joined -> True, PlotRange->{All, All}
    ]}
]];
{effPlot[#, "Z", {0.5, 0.95}] &/@ slhas[[{1,2,3}]],
effPlot[#, "Z", {0.5, 0.4}] &/@ slhas[[{4}]]}//Join
KeyValueMap[outputPDF[#2,"ZW_"<>#1]&]/@%
{effPlot[#, "h", {0.5, 0.95}] &/@ slhas[[{1,2}]],
effPlot[#, "h", {0.5, 0.4}] &/@ slhas[[{3,4}]]}//Join
KeyValueMap[outputPDF[#2,"HW_"<>#1]&]/@%


ATL1803WZ = \[Sigma]UL2D["ATL1803UL", ATLASUpperLimit["../lhc/atlas1803/HEPData-ins1658902-v1-Table_81.csv", "SkipLines"->12]]; (* 100/150-600 for gut/m100 *)
ATL1806WZ = \[Sigma]UL2D["ATL1806UL", ATLASUpperLimit["../lhc/atlas1806/HEPData-ins1676551-v1-Cross-section_UL_combined.csv", "SkipLines"->1]]; (* 200-600 for gut/m100 *)
ATL1909WH = \[Sigma]UL2D["ATL1909UL", {#[[1]], #[[2]], #[[3]]*1000} & /@ Select[Import["../lhc/atlas1909/HEPData-ins1755298-v1-Upper_limits_1Lbb.csv", "CSV", "IgnoreEmptyLines" -> True, "SkipLines"->11], MatchQ[#, {_?NumericQ, _?NumericQ, _?NumericQ}] &]];
  (* 300-800/250-1000 for gut/m100*)
ATL1912WZ = \[Sigma]UL2D["ATL1912UL", ATLASUpperLimit["../lhc/atlas1912/aux_tab1.csv", "SkipLines"->1]]; (*100/150-500 for gut/m100*)
CMS1709WZ = \[Sigma]UL2D["cms-NC-WZ-1709", CMSUpperLimit["cms-NC-WZ-1709"]]; (*100-700*)
CMS1709WH = \[Sigma]UL2D["cms-NC-WH-1709", CMSUpperLimit["cms-NC-WH-1709"]]; (*100-350*)
CMS1801WZ = \[Sigma]UL2D["cms-NC-WZ", CMSUpperLimit["cms-NC-WZ"]]; (*100-700*)
CMS1801WH = \[Sigma]UL2D["cms-NC-WH", CMSUpperLimit["cms-NC-WH"]]; (*100-750*)
M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];

excPlotNC21[slhas_, legend_:True, HW1803star_:False] := Module[{
  style = {
    color[0],
    {color[0], Dashed},
    color[2],
    {color[2], Dashed},
    {color[2], If[HW1803star, None, Dotted]},
    color[3],
    {color[3], Dashed},
    {color[3], Dotted},
    {color[3], DotDashed}
  },
  markers = {None, None, None, None, If[HW1803star, marker[3,PointSize->6], None], None, None, None, None},
  legends = MaTeX[{"\\sigma_X", "\\sigma_{\\mathrm{wino}}",
              "\\sigma_{\\text{UL; 1909.09226 (hW)}}",
              "\\sigma_{\\text{UL; 1709.05406 (hW)}}",
              "\\sigma_{\\text{UL; 1801.03957 (hW)}}",
              "\\sigma_{\\text{UL; 1801.03957 (ZW)}}",
              "\\sigma_{\\text{UL; 1803.02762 (ZW)}}",
              "\\sigma_{\\text{UL; 1806.02293 (ZW)}}",
              "\\sigma_{\\text{UL; 1912.08479 (ZW)}}"}, Magnification->0.9]
  },
  ListLogPlot[{
    {xLabel[#], calc\[Sigma]EWKino[#,2,1]}&/@Values[slhas],
    {xLabel[#], calc\[Sigma]Wino[M2[#]]}&/@Values[slhas],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], ATL1909WH[M2[#],M1[#]], A["CMS1709e"][#,2,1]}&/@Values[slhas], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1709WH[M2[#],M1[#]], A["CMS1709e"][#,2,1]}&/@Values[slhas], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1801WH[M2[#],M1[#]], A["CMS1709e"][#,2,1]}&/@Values[slhas], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1801WZ[M2[#],M1[#]], A["CMS1709d"][#,2,1]}&/@Values[slhas], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], ATL1803WZ[M2[#],M1[#]], A["CMS1709d"][#,2,1]}&/@Values[slhas], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], ATL1806WZ[M2[#],M1[#]], A["CMS1709d"][#,2,1]}&/@Values[slhas], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], ATL1912WZ[M2[#],M1[#]], A["CMS1709d"][#,2,1]}&/@Values[slhas], FreeQ[#, Indeterminate] && #[[3]]>0&]},
  Joined->True,
  PlotStyle-> style,
  PlotMarkers->markers,
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], MaTeX["\\text{cross section [fb]}"]},
      PlotLegends->If[legend, LineLegend[
          Table[If[i==5 && HW1803star, {style[[i]], Thickness[0.000001]}, style[[i]]], {i, 9}],
          legends,
          LegendMarkers -> markers, LegendMarkerSize -> {35,15}, Spacings -> {0.5,0.3}], None],
  PlotRange->{{200, 900}, {1, 1*^5}}
]]


Join[excPlotNC21[#, True, True] &/@ slhas[[{1}]],
excPlotNC21[#, True, False] &/@ slhas[[{2,3,4}]]]
KeyValueMap[outputPDF[#2,"summary_"<>#1]&][%]
Join[excPlotNC21[#, False, True] &/@ slhas[[{1}]],
excPlotNC21[#, False, False] &/@ slhas[[{2,3,4}]]]
KeyValueMap[outputPDF[#2,"summary_"<>#1<>"_nolegend"]&][%]
