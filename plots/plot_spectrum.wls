#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd === Null, Print["This is not for scripting; run from Frontend."]; Abort[];];

If[$FrontEnd =!= Null, SetDirectory[NotebookDirectory[]]];
<<"common.wl";
SetOptions[#, ContourShading->None, PlotRangePadding->None, ImageSize->400] &/@ {ContourPlot, ListContourPlot};


data[filename_] := Module[
  {sp = SLHA`ReadSLHA[filename], result},
  result = <|
    "m1"->sp["msoft"][1],
    "m2"->sp["msoft"][2],
    "mu"->sp["hmix"][1],
    "mL"->sp["msoft"][32],
    "msmuL"->sp["mass"][1000013],
    "msnumu"->sp["mass"][1000014],
    "mn1"->sp["mass"][1000022],
    "mn2"->sp["mass"][1000023],
    "mn3"->sp["mass"][1000025],
    "mn4"->sp["mass"][1000035],
    "mc1"->sp["mass"][1000024],
    "mc2"->sp["mass"][1000037],
    "amu"->sp["SphenoLowEnergy"][21],
    "amuMI"->sp["gm2massinsertion"][1]+sp["gm2massinsertion"][4],
    "x"->(sp["mass"][1000013]-sp["mass"][1000022])/(sp["mass"][1000024]-sp["mass"][1000022]),
    "LSP"->(DownValues[Evaluate[sp["MASS"]]] // Cases[# , (_[_[a_Integer]]:>b_):>{a,b}]& // Abs // Select[#, #[[1]]>1000000&]& // Sort[#, #1[[2]] < #2[[2]]&]&)[[1,1]]
  |>;
  Clear[sp];
  result]


ReadOrGenerate[filepath_String, data_] := If[FileExistsQ[filepath], Get[filepath], Module[{tmp = Evaluate[data]}, Put[tmp, filepath]; tmp]];
Attributes[ReadOrGenerate] = {HoldRest};


tab1data = ReadOrGenerate["tab1data.dat", Association[FileBaseName[#]->data[#] &/@ FileNames[$ProjectRoot<>"/spectrum/grid/tab1_*.slha"]]];
tab2data = ReadOrGenerate["tab2data.dat", Association[FileBaseName[#]->data[#] &/@ FileNames[$ProjectRoot<>"/spectrum/grid/tab2_*.slha"]]];
tab3data = ReadOrGenerate["tab3data.dat", Association[FileBaseName[#]->data[#] &/@ FileNames[$ProjectRoot<>"/spectrum/grid/tab3_*.slha"]]];


{dataToPlot, prefix} = {tab1data, "tab1"};

Off[Syntax::stresc];
{#m2, #mL, #mc1} &/@ Values[dataToPlot];
plot1 = ListContourPlot[%, ContourShading->None, ContourStyle->Red, ContourLabels->Function[{x, y, z}, Text[Style[z, Red], {x, y}]], PlotLegends->LineLegend[{Red},{MaTeXRaw["m(\tilde\chi^\pm_1)"]}]];
{#m2, #mL, #msmuL} &/@ Values[dataToPlot];
plot2 = ListContourPlot[%, ContourShading->None, ContourStyle->Blue, ContourLabels->Function[{x, y, z}, Text[Style[z, Blue], {x, y}]], PlotLegends->LineLegend[{Blue}, {MaTeXRaw["m(\tilde\mu_{\textrm L})"]}]];
massplot = Show[{plot1, plot2}, FrameLabel->MaTeXRaw[{"M_2 \text{ [GeV]}", "m_{\mathrm{L}}\text{ [GeV]}"}]]
{#mc1, #msmuL, #amu*10^10} &/@ Values[dataToPlot];
plot3 = ListContourPlot[%, ContourStyle->Black, ContourLabels->True, PlotLegends->LineLegend[{Black}, {MaTeXRaw["a_\mu^{\mathrm{MSSM}}\times10^{10}"]}]];
{#mc1, #msmuL, #amuMI*10^10} &/@ Values[dataToPlot];
plot4 = ListContourPlot[%, ContourStyle->Dashed, ContourLabels->False, PlotLegends->LineLegend[{Dashed}, {MaTeXRaw["a_\mu^{\mathrm{MI}}\times10^{10}"]}]];
{#mc1, #msmuL, #x} &/@ Values[dataToPlot];
plot5 = ListContourPlot[%, Contours->{0, 0.05, 0.5, 0.95, 1}, ContourStyle->Red, ContourLabels->Function[{x, y, z}, Text[Style[z, Red], {x, y}]], PlotLegends->LineLegend[{Red}, {MaTeXRaw["x"]}]];
{#mc1, #msmuL, #msnumu - #mn1} &/@ Values[dataToPlot];
plot6 = ListContourPlot[%, Contours->{0}, ContourStyle->Blue, PlotLegends->LineLegend[{Blue}, {MaTeXRaw["m(\tilde \nu_\mu)=m(\tilde\chi_1^0)"]}]];
physplot = Show[{plot3, plot4, plot5, plot6}, FrameLabel->MaTeXRaw[{"m(\tilde\chi^\pm_1) \text{ [GeV]}", "m(\tilde\mu_{\mathrm L}) \text{ [GeV]}"}]]
physplotmag = Show[{plot3, plot4, plot5, plot6}, FrameLabel->MaTeXRaw[{"m(\tilde\chi^\pm_1) \text{ [GeV]}", "m(\tilde\mu_{\mathrm L}) \text{ [GeV]}"}], PlotRange->{{300, 700}, {200, 400}}]

outputPDF[massplot, prefix<>"_massplot"];
outputPDF[physplot, prefix<>"_physplot"];
outputPDF[physplotmag, prefix<>"_physplot2"];



