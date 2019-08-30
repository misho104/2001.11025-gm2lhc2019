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
AppendTo[$Path, "../spectrum"];
<<gm2grid.wl;
<<"plot_tools.wl"


\[Sigma]ULgridRaw = Import["../lhc/atlas1803/HEPData-ins1658902-v1-Table_80.csv", "CSV", "SkipLines"->11, "IgnoreEmptyLines"->True];
\[Sigma]ULinterpFunc = Interpolation[({{#[[2]],#[[1]]},Log[#[[3]]]}) &/@ Select[\[Sigma]ULgridRaw, MatchQ[#, {_?NumericQ, _?NumericQ, _?NumericQ}]&], InterpolationOrder->1]
\[Sigma]UL[mn2_, mn1_] := Exp[\[Sigma]ULinterpFunc[mn2, mn1]]

\[Sigma]Wino[mass_] := Module[{},
  Run["susy-xs get 13TeV.n2x1+.wino " <> TextString[mass] <> " -0 > tmp"];
  Import["tmp", "List"][[1]]
]

(* cache *)
(*
\[Sigma]winos = \[Sigma]Wino /@ Association[Rule["tab1_1000_719.6",943.846184`],Rule["tab1_1050_757.2",993.763702`],Rule["tab1_1100_794.7",1043.6889`],Rule["tab1_1150_832.3",1093.620755`],Rule["tab1_1200_869.8",1143.558415`],Rule["tab1_200_111.4",151.525982`],Rule["tab1_250_151.4",199.4766995`],Rule["tab1_300_190.4",248.15261950000001`],Rule["tab1_350_228.8",297.23132350000003`],Rule["tab1_400_267",346.554491`],Rule["tab1_450_305",396.03659500000003`],Rule["tab1_500_342.9",445.6276705`],Rule["tab1_550_380.7",495.296655`],Rule["tab1_600_418.5",545.0232435`],Rule["tab1_650_456.2",594.7936159999999`],Rule["tab1_700_493.9",644.598041`],Rule["tab1_750_531.6",694.4294695`],Rule["tab1_800_569.2",744.282672`],Rule["tab1_850_606.8",794.1536874999999`],Rule["tab1_900_644.4",844.039459`],Rule["tab1_950_682",893.937592`]]
*)
\[Sigma]winos = <|"tab1_1000_719.6"->1.4176750088995378`,"tab1_1050_757.2"->1.0537102284411206`,"tab1_1100_794.7"->0.7864200757288272`,"tab1_1150_832.3"->0.580081747453097`,"tab1_1200_869.8"->0.4363979683682724`,"tab1_200_111.4"->3158.237506269439`,"tab1_250_151.4"->1181.3845122199443`,"tab1_300_190.4"->531.6702023406344`,"tab1_350_228.8"->269.7034662616427`,"tab1_400_267"->148.8169718610023`,"tab1_450_305"->87.36752654223433`,"tab1_500_342.9"->53.747815010304535`,"tab1_550_380.7"->34.28494741827375`,"tab1_600_418.5"->22.540233384235172`,"tab1_650_456.2"->15.176246848842265`,"tab1_700_493.9"->10.423629884957666`,"tab1_750_531.6"->7.270578996337499`,"tab1_800_569.2"->5.148983205234401`,"tab1_850_606.8"->3.6803811726812277`,"tab1_900_644.4"->2.658381824513673`,"tab1_950_682"->1.9433079714489214`|>;

MaTeXRaw[{"\\tilde\\chi^0_i","\\tilde\\chi^\\pm_i","\\tilde\\mu_{\\mathrm L}, \\tilde\\nu_\\mu", "\\tilde\\mu_{\\mathrm R}"}];
Join[MaTeXRaw[{"c_{\\mathrm{LL}}", "c_{\\mathrm{LR}}", "c_{\\mathrm{RR}}"}], {"n2\[Rule]lep", "n2\[Rule]tau", "c1\[Rule]lep", "c1\[Rule]tau", MaTeXRaw["K_\\gamma"]}];
MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"];


NiCjRatio[slha_, i:1|2|3|4, j:1|2] := Module[{
    nmixI = Table[slha["nmix"][i, a], {a,4}],
    uJ = Table[slha["umix"][j, a], {a,2}],
    vJ = Table[slha["vmix"][j, a], {a,2}],
    nPhase, nI, pidN, pidJ, gLog2, gRog2, cLL, cLR, cRR
  },
  pidN = {1000022, 1000023, 1000025, 1000035}[[i]];
  nPhase = If[slha["mass"][pidN] > 0, 1, I];
  nI = nPhase * nmixI;
  gLog2 = -vJ[[1]]Conjugate[nI[[2]]]+vJ[[2]]Conjugate[nI[[4]]]/Sqrt[2];
  gRog2 = -nI[[2]]Conjugate[uJ[[1]]]-nI[[3]]Conjugate[uJ[[2]]]/Sqrt[2];
  cLL = Abs[gLog2]^2;
  cLR = Re[Conjugate[gLog2]gRog2];
  cRR = Abs[gRog2]^2;
  {cLL, cLR, cRR}
]
DecayFactors[slha_,i:1|2|3|4,j:1|2] := Module[{
    n = slha["decay", {1000022,1000023,1000025,1000035}[[i]]],
    c = slha["decay", {1000024,1000037}[[j]]],
    ntolep, ntotau, ctolep, ctotau,
    tautolep = 0.352
  },
  ntolep = Total[{n[-1000013,13], n[-1000011,11], n[1000011,-11], n[1000013,-13]}];
  ntotau = Total[{n[-1000015,15], n[1000015,-15]}];
  ctolep = Total[{c[-1000013,14], c[-1000011,12], c[1000012,-11], c[1000014,-13]}];
  ctotau = Total[{c[-1000015,16], c[1000016,-15]}];
  {ntolep, ntotau, ctolep, ctotau, (ntolep + ntotau*tautolep)(ctolep + ctotau*tautolep) / 0.307}]


slhas = Association[FileBaseName[#]->(If[FileExistsQ[#], ReadSLHA[#], Print["Not a file: " <> TextString[#]]; Abort[]]) &/@ files]
n2c1 = NiCjRatio[#,2,1]&/@slhas;
df = DecayFactors[#,2,1]&/@slhas;


masses = ListPlot[TemporalData[
    {#["mass"][1000022], #["mass"][1000023], #["mass"][1000025], #["mass"][1000035], #["mass"][1000024], #["mass"][1000037], #["mass"][1000013], #["mass"][1000014], #["mass"][2000013]} &/@ Values[slhas]// Abs,
    {#["mass"][1000024] &/@ Values[slhas]}], 
  PlotMarkers->{"\[Dash]", "\[Dash]", "\[Dash]", "\[Dash]", "\[Cross]", "\[Cross]", "\[EmptySmallCircle]", "\[EmptySmallCircle]", "\[EmptyUpTriangle]"},
  PlotStyle->{Default, Default, Default, Default, Red, Red, Blue, Blue, Blue},
  PlotLegends->PointLegend[{Black,Red,Blue,Blue},MaTeXRaw[{"\\tilde\\chi^0_i","\\tilde\\chi^\\pm_i","\\tilde\\mu_{\\mathrm L}, \\tilde\\nu_\\mu", "\\tilde\\mu_{\\mathrm R}"}],LegendMarkers->{"\[Dash]", "\[Cross]", "\[EmptySmallCircle]", "\[EmptyUpTriangle]"}],
  PlotRange->{All, {0, 1300}},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], "mass [GeV]"}
]
outputPDF["masses", masses]


cfactors = ListPlot[TemporalData[Flatten[{n2c1[#], df[#]}]&/@Keys[slhas], {#["mass"][1000024] &/@ Values[slhas]}],
  PlotStyle->{color[1], color[3], color[4], color[1], color[3], color[1], color[3], Black},
  PlotMarkers->{"\[Bullet]", "\[Bullet]", "\[Bullet]", "\[EmptySmallCircle]", "\[EmptySmallCircle]", "\[Cross]", "\[Cross]", "\[FilledSmallCircle]"},
  PlotLegends->Join[MaTeXRaw[{"c_{\\mathrm{LL}}", "c_{\\mathrm{LR}}", "c_{\\mathrm{RR}}"}], {"n2\[Rule]lep", "n2\[Rule]tau", "c1\[Rule]lep", "c1\[Rule]tau", MaTeXRaw["K_\\gamma"]}],
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], None},
  PlotRange->{All, Automatic}
]
outputPDF["cfactors", cfactors]


funcN1mass = Interpolation[{#["mass"][1000024], #["mass"][1000022]} &/@ Values[slhas]];
LogPlot[{\[Sigma]UL[x, funcN1mass[x]]}, {x, 300, 1100},
  FrameLabel->{MaTeX["\\text{mass of }\\tilde\\chi^\\pm_1\\text{ [GeV]}"], "cross section [fb]"},
  PlotRange->{All, Automatic},
  PlotLegends->LineLegend[{"\[Sigma]UL"}]
];
ListLogPlot[TemporalData[\[Sigma]winos[#] * Mean[n2c1[#]] * df[#][[5]] &/@ Keys[slhas], {#["mass"][1000024] &/@ Values[slhas]}]];
Show[{%%,%}]
outputPDF["atlas1803", %]



