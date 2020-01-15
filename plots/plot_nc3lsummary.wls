#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";


files[x:"005"|"050"|"095"] := <|
   "1gut"->FileNames["../spectrum/x"<>x<>"/tab1_*.slha"],
   "2gut"->FileNames["../spectrum/x"<>x<>"/tab2_*.slha"],
   "1m100"->FileNames["../spectrum/m100x"<>x<>"/tab1_*.slha"],
   "2m100"->FileNames["../spectrum/m100x"<>x<>"/tab2_*.slha"]
|>;
slhas005 = ReadSLHAFiles[#, "Label"->(#["mass"][1000024]&)] &/@ files["005"];
slhas050 = ReadSLHAFiles[#, "Label"->(#["mass"][1000024]&)] &/@ files["005"];
slhas095 = ReadSLHAFiles[#, "Label"->(#["mass"][1000024]&)] &/@ files["095"];


ATL1803UL050 = \[Sigma]UL2D["ATL1803UL", ATLASUpperLimit["../lhc/atlas1803/HEPData-ins1658902-v1-Table_80.csv", "SkipLines"->11]];
CMS1709UL050 = \[Sigma]UL2D["cms-NC-3L-0.5", CMSUpperLimit["cms-NC-3L-0.5"]];
CMS1709UL005 = \[Sigma]UL2D["cms-NC-3L-0.05", CMSUpperLimit["cms-NC-3L-0.05"]];
CMS1709UL095 = \[Sigma]UL2D["cms-NC-3L-0.95", CMSUpperLimit["cms-NC-3L-0.95"]];
N2C1$3L = ReadSLHA[LHCSLHA["N2C1_3L.decay"]];
M2[slha_] := GeometricMean[{Abs[slha["mass"][1000023]], Abs[slha["mass"][1000024]]}]
M1[slha_] := Abs[slha["mass"][1000022]];

excPlotNC3L[key_, pos_] := Module[{
    style = {color[0], {color[2], Dotted}, color[2], {color[2], Dashed}, color[3], {color[2], Dotted, Thickness[0.003]}, {color[2], Thickness[0.003]}, {color[2], Dashed, Thickness[0.003]}, {color[3], Thickness[0.003]}},
    legends = MaTeX[{"\\sigma_X",
              "\\sigma_{\\text{UL}}(x=0.05, \\text{CMS})",
              "\\sigma_{\\text{UL}}(x=0.5, \\text{CMS})",
              "\\sigma_{\\text{UL}}(x=0.95, \\text{CMS})",
               "\\sigma_{\\text{UL}}(x=0.5, \\text{ATLAS})"}, Magnification->0.9]
  },
  ListLogPlot[{
    {xLabel[#], calc\[Sigma]EWKino[#,2,1]}&/@Values[slhas050[key]],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1709UL005[M2[#],M1[#]], K\[CapitalGamma]["CMS1709a", N2C1$3L, #]}&/@Values[slhas005[key]], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1709UL050[M2[#],M1[#]], K\[CapitalGamma]["CMS1709a", N2C1$3L, #]}&/@Values[slhas050[key]], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1709UL095[M2[#],M1[#]], K\[CapitalGamma]["CMS1709a", N2C1$3L, #]}&/@Values[slhas095[key]], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], ATL1803UL050[M2[#],M1[#]], K\[CapitalGamma]["CMS1709a", N2C1$3L, #]}&/@Values[slhas050[key]], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1709UL005[M2[#],M1[#]], A["CMS1709aNoTau"][#] / A["CMS1709a"][N2C1$3L]}&/@Values[slhas005[key]], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1709UL050[M2[#],M1[#]], A["CMS1709aNoTau"][#] / A["CMS1709a"][N2C1$3L]}&/@Values[slhas050[key]], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], CMS1709UL095[M2[#],M1[#]], A["CMS1709aNoTau"][#] / A["CMS1709a"][N2C1$3L]}&/@Values[slhas095[key]], FreeQ[#, Indeterminate] && #[[3]]>0&],
    {#[[1]], #[[2]]/#[[3]]} &/@ Select[{xLabel[#], ATL1803UL050[M2[#],M1[#]], A["CMS1709aNoTau"][#] / A["CMS1709a"][N2C1$3L]}&/@Values[slhas050[key]], FreeQ[#, Indeterminate] && #[[3]]>0&]
  }, PlotStyle->style, Joined->True, PlotRange->{{200, 1100}, {0.5, 4000}},
  FrameLabel->{MaTeX["m(\\tilde\\chi^\\pm_1)\\text{ [GeV]}"], MaTeX["\\text{cross section [fb]}"]},
  Epilog->{Inset[
          LineLegend[
            style,
            legends, LegendMarkers->None, LegendMarkerSize -> {30, 15}, LegendMargins -> 0, Spacings -> {0.3,0.3}],
          Scaled[pos], {Right, Top}]
       }]];


excPlotNC3L[#, {0.99, 0.78}] &/@ <|"1gut"->"1gut"|>
excPlotNC3L[#, {0.99, 0.99}] &/@ <|"2gut"->"2gut", "1m100"->"1m100", "2m100"->"2m100"|>
KeyValueMap[outputPDF[#2,"summary_"<>#1]&][Join[%,%%]]


(* working space for FindRoot *)
tmp1={#[[1]], Log[#[[2]]/#[[3]]]} &/@ Select[{xLabel[#], CMS1709UL095[M2[#],M1[#]]/calc\[Sigma]EWKino[#,2,1], A["CMS1709a"][#]      / A["CMS1709a"][N2C1$3L]}&/@Values[slhas095[#]], FreeQ[#, Indeterminate] && #[[3]]>0&] &/@ <|"1gut"->"1gut","2gut"->"2gut", "1m100"->"1m100", "2m100"->"2m100"|>;
tmp2={#[[1]], Log[#[[2]]/#[[3]]]} &/@ Select[{xLabel[#], CMS1709UL095[M2[#],M1[#]]/calc\[Sigma]EWKino[#,2,1], A["CMS1709aNoTau"][#] / A["CMS1709a"][N2C1$3L]}&/@Values[slhas095[#]], FreeQ[#, Indeterminate] && #[[3]]>0&] &/@ <|"1gut"->"1gut","2gut"->"2gut", "1m100"->"1m100", "2m100"->"2m100"|>;
s1=Interpolation[#,InterpolationOrder->1,"ExtrapolationHandler" -> {Function[Indeterminate], "WarningMessage" -> False}]&/@ tmp1;
s2=Interpolation[#,InterpolationOrder->1,"ExtrapolationHandler" -> {Function[Indeterminate], "WarningMessage" -> False}]&/@ tmp2;


{FindRoot[s1["1gut"][x]==0,{x,#}], FindRoot[s2["1gut"][x]==0,{x,#}]} &/@ {880}//Flatten[#,1]&
ListPlot[{tmp1["1gut"], tmp2["1gut"]}, PlotRange->{{200,1100}, {-0.3,0.3}}, Joined->True, GridLines->{x/.%, {0}}]
Show[%, PlotRange->{{850, 950}, {-0.3,0.3}}]


{FindRoot[s1["2gut"][x]==0,{x,#}], FindRoot[s2["2gut"][x]==0,{x,#}]} &/@ {470}//Flatten[#,1]&
ListPlot[{tmp1["2gut"], tmp2["2gut"]}, PlotRange->{{200, 1100}, {-0.3,0.3}}, Joined->True, GridLines->{x/.%, {0}}]
Show[%, PlotRange->{{300, 500}, {-0.05,0.05}}]


{FindRoot[s1["1m100"][x]==0,{x,#}], FindRoot[s2["1m100"][x]==0,{x,#}]} &/@ {770}//Flatten[#,1]&
ListPlot[{tmp1["1m100"], tmp2["1m100"]}, PlotRange->{{200,1100}, Automatic}, Joined->True, GridLines->{x/.%, {0}}]
Show[%, PlotRange->{{800, 1000}, {-0.3,0.3}}]


{FindRoot[s1["2m100"][x]==0,{x,#}], FindRoot[s2["2m100"][x]==0,{x,#}]} &/@ {200}//Flatten[#,1]&
ListPlot[{tmp1["2m100"], tmp2["2m100"]}, PlotRange->{{200, 1100}, Automatic}, Joined->True, GridLines->{x/.%, {0}}]
Show[%, PlotRange->{{200, 230}, {-0.3,0.3}}]






