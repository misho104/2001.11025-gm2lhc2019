#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd =!= Null, SetDirectory[NotebookDirectory[]]];
<<gm2grid`
<<MSSM`
Sin\[Theta]W[sm_] := sm["alpha_EW@m_Z"] \[Pi]/(Sqrt[2]sm["G_F"]*sm["m_Z"]^2) // 2#/(1+Sqrt[1-4#]) & // Sqrt
mW[sm_] := sm["m_Z"]*Cos[ArcSin[Sin\[Theta]W[sm]]]


GenPoint[tablespec_, m2_, ml_] := Module[{
    prefix = tablespec["prefix"],
    muoverm2 = tablespec["muoverm2"],
    point, filename, slha
  },
  If[Not[StringQ[prefix]], Print["Invalid name"]; Abort[]];
  If[Not[AllTrue[{muoverm2, m2, ml}, NumericQ]], Print["Invalid point"]; Abort[]];
  point = p[m2, muoverm2 * m2, ml, prefix];
  filename = "grid/" <> point["filestem"] <> ".in";
  slha = GenSLHA[point["params"]];
  slha["SPhenoLowEnergy", IfMissing->"create"][21] = CalcAmu[point["params"]][[1,2,1]];
  slha["writetofile", filename];
  Print[filename];
  Return[slha]
]


calcX[params__] := Module[{point = GenSLHA[p[params]["params"]], mn, mc, mm, matrix},
  matrix = NeutralinoMass[point["EXTPAR"][1], point["EXTPAR"][2], point["MINPAR"][3], point["EXTPAR"][23], sm["m_Z"], Sin\[Theta]W[sm]];
  mn = NeutralinoPositiveDiagonalize[matrix][[1]] // Diagonal;
  matrix = CharginoMass[point["EXTPAR"][2], point["MINPAR"][3], point["EXTPAR"][23], mW[sm]];
  mc = CharginoDiagonalize[matrix][[1]] // Diagonal;
  matrix = SLmassSQ[sm["m_mu"], point["EXTPAR"][32], point["EXTPAR"][35], point["EXTPAR"][23], 0, ArcTan[point["MINPAR"][3]], sm["m_Z"], Sin\[Theta]W[sm]];
  mm = SfermionDiagonalize[matrix][[1]] // Diagonal // Sqrt;
  (mm[[1]] - mn[[1]]) / (mc[[1]] - mn[[1]])]

GenPointWithX[tablespec_, m2_, x_] := Module[{
    prefix = tablespec["prefix"],
    muoverm2 = tablespec["muoverm2"],
    point, filename, slha, ml, tmp
  },
  If[Not[StringQ[prefix]], Print["Invalid name"]; Abort[]];
  If[Not[AllTrue[{muoverm2, m2, x}, NumericQ]], Print["Invalid point"]; Abort[]];
  ml = Round[tmp*10]/10 /. FindRoot[calcX[m2, muoverm2 * m2, tmp, "tmp"] == x, {tmp, m2/4 + Min[m2, muoverm2 * m2]/2}];
  point = p[m2, muoverm2 * m2, ml, prefix];
  filename = "grid/" <> point["filestem"] <> ".in";
  slha = GenSLHA[point["params"]];
  slha["SPhenoLowEnergy", IfMissing->"create"][21] = CalcAmu[point["params"]][[1,2,1]];
  slha["writetofile", filename];
  Print[filename];
  Return[slha]
]


GenGrid[tablespec_] := Do[
  GenPoint[tablespec, m2, ml]
  ,
  {m2, 500, 700, 50}, {ml, 500, 700, 50}
]


Tables = <|
  "tab1" -> <|"prefix" -> "tab1", "muoverm2" -> 1|>,
  "tab2" -> <|"prefix" -> "tab2", "muoverm2" -> 2|>,
  "tab3" -> <|"prefix" -> "tab3", "muoverm2" -> 3/4|>
|>;

Switch[Length[$ScriptCommandLine],
  0,
  Print["Nothing to do from Frontend"]
  ,
  2,
  tablespec = Tables[$ScriptCommandLine[[2]]];
  GenGrid[tablespec];
  ,
  4,
  tablespec = Tables[$ScriptCommandLine[[2]]];
  {m2, ml} = ToExpression /@ $ScriptCommandLine[[3;;4]];
  GenPoint[tablespec, m2, ml]
  ,
  _,
  Print["Usage: " <> $ScriptCommandLine[[1]] <> " table_name [M2] [ML or x]"]
];


(* ::Input:: *)
(*Do[*)
(*  GenPointWithX[Tables["tab3"], m2, x]*)
(*  ,*)
(*  {m2, 400, 1200, 50}, {x, {0.95}}*)
(*]*)



