#!/usr/bin/env wolframscript
(* ::Package:: *)

If[$FrontEnd =!= Null, SetDirectory[NotebookDirectory[]]];
<<gm2grid`
<<MSSM`
Sin\[Theta]W[sm_] := sm["alpha_EW@m_Z"] \[Pi]/(Sqrt[2]sm["G_F"]*sm["m_Z"]^2) // 2#/(1+Sqrt[1-4#]) & // Sqrt
mW[sm_] := sm["m_Z"]*Cos[ArcSin[Sin\[Theta]W[sm]]]


(* Mass-insertion formulae for g-2 *)
N1[x_] /; Abs[x-1] < 2*^-2 :=  (1/2) + (1-x)/5 + (1-x)^2/10
N2[x_] /; Abs[x-1] < 2*^-2 :=  (1/3) + (1-x)/6 + (1-x)^2/10
C1[x_] /; Abs[x-1] < 2*^-2 :=  (1/2) + (1-x)*(3/10) + (1-x)^2/5
C2[x_] /; Abs[x-1] < 2*^-2 := -(2/3) - (1-x)/2 - (1-x)^2 * (2/5)
dN2[x_] /; Abs[x-1] < 2*^-2 := -(1/6) - (1-x)/5 - (1-x)^2/5
dC2[x_] /; Abs[x-1] < 2*^-2 := (1/2) + (1-x)*(4/5) + (1-x)^2
ddN2[x_] /; Abs[x-1] < 2*^-2 := 1/5 - 2/5 (-1 + x) + 4/7 (-1 + x)^2
ddC2[x_] /; Abs[x-1] < 2*^-2 := -(4/5) + 2 (-1 + x) - 24/7 (-1 + x)^2

N1[x_]  := (1-6x+3x^2+2x^3-6x^2 Log[x])/(1-x)^4
N2[x_]  := (1-x^2+2x Log[x])/(1-x)^3
C1[x_]  := (2+3x-6x^2+x^3+6x Log[x])/(1-x)^4
C2[x_]  := (3-4x+x^2+2Log[x])/(1-x)^3
dN2[x_] := (5 - 4 x - x^2 + 2 Log[x] + 4 x Log[x]) / (1-x)^4
dC2[x_] := (2 + 3 x - 6 x^2 + x^3 + 6 x Log[x]) / (x (1 - x)^4)
ddN2[x_] := (2 (-1 - 9 x + 9 x^2 + x^3 - 6 x Log[x] - 6 x^2 Log[x]))/((-1 + x)^5 x)
ddC2[x_] := -((2 (-1 + 8 x - 8 x^3 + x^4 + 12 x^2 Log[x]))/((-1 + x)^5 x^2))

Fa[x_, y_] /; Abs[x-y] < 5*^-3 := dC2[x]/2    + ddC2[x] (y-x) / 4
Fb[x_, y_] /; Abs[x-y] < 5*^-3 := dN2[x]/(-2) + ddN2[x] (y-x) / (-4)
Fa[x_,y_] := (C2[x]-C2[y])/(2(x-y))
Fb[x_,y_] := -(N2[x]-N2[y])/(2(x-y))
values = {gW -> Sqrt[4 \[Pi] sm["alpha_EW@m_Z"]] / Sin\[Theta]W[sm], gY -> Sqrt[4 \[Pi] sm["alpha_EW@m_Z"]] / Sqrt[1-Sin\[Theta]W[sm]^2], m\[Mu]->sm["m_mu"]};
FWHL1[M1_,M2_,tb_,\[Mu]_,smuL_,smuR_,snumu_]:=  gW^2/( 8\[Pi]^2) (m\[Mu]^2 M2 \[Mu] tb)/snumu^4 Fa[  M2^2/snumu^2,    \[Mu]^2/snumu^2]//.values
FWHL2[M1_,M2_,tb_,\[Mu]_,smuL_,smuR_,snumu_]:= -gW^2/(16\[Pi]^2) (m\[Mu]^2 M2 \[Mu] tb)/smuL^4  Fb[  M2^2/ smuL^2,    \[Mu]^2/ smuL^2]//.values
FWHL[p__] := FWHL1[p] + FWHL2[p]
FBLR[M1_,M2_,tb_,\[Mu]_,smuL_,smuR_,snumu_]:=  gY^2/( 8\[Pi]^2) (m\[Mu]^2    \[Mu] tb)/M1^3    Fb[smuL^2/   M1^2, smuR^2/   M1^2]//.values
FBHR[M1_,M2_,tb_,\[Mu]_,smuL_,smuR_,snumu_]:= -gY^2/( 8\[Pi]^2) (m\[Mu]^2 M1 \[Mu] tb)/smuR^4  Fb[  M1^2/ smuR^2,    \[Mu]^2/ smuR^2]//.values
FBHL[M1_,M2_,tb_,\[Mu]_,smuL_,smuR_,snumu_]:=  gY^2/(16\[Pi]^2) (m\[Mu]^2 M1 \[Mu] tb)/smuL^4  Fb[  M1^2/ smuL^2,    \[Mu]^2/ smuL^2]//.values


GenPoint[tablespec_, m2_, ml_] := Module[{
    prefix = tablespec["prefix"],
    muoverm2 = tablespec["muoverm2"],
    point, filename, slha, matrix, smuL, smuR, snumu, gm2params
  },
  If[Not[StringQ[prefix]], Print["Invalid name"]; Abort[]];
  If[Not[AllTrue[{muoverm2, m2, ml}, NumericQ]], Print["Invalid point"]; Abort[]];
  point = p[m2, muoverm2 * m2, ml, prefix];
  filename = "grid/" <> point["filestem"] <> ".in";
  slha = GenSLHA[point["params"]];
  (* smuon mass *)
  matrix = SLmassSQ[sm["m_mu"], slha["EXTPAR"][32], slha["EXTPAR"][35], slha["EXTPAR"][23], 0, ArcTan[slha["MINPAR"][3]], sm["m_Z"], Sin\[Theta]W[sm]];
  {smuL, smuR} = SfermionDiagonalize[matrix][[1]] // Diagonal // Sqrt;
  snumu = SNmassSQ[slha["EXTPAR"][32], ArcTan[slha["MINPAR"][3]], sm["m_Z"], Sin\[Theta]W[sm]] // Sqrt;
  If[Or[slha["EXTPAR"][32] > slha["EXTPAR"][35]/2, smuL > smuR], Print["This code assumes mL << mR."]; Abort[]];
  gm2params = {slha["EXTPAR"][1],slha["EXTPAR"][2], slha["MINPAR"][3], slha["EXTPAR"][23], smuL, smuR, snumu};
  (* g-2 full and mass insertion *)
  slha["SPhenoLowEnergy", IfMissing->"create"][21] = CalcAmu[point["params"]][[1,2,1]];
  slha["GM2MassInsertion", IfMissing->"create"][1] = FWHL@@gm2params;
  slha["GM2MassInsertion", IfMissing->"create"][2] = FBLR@@gm2params;
  slha["GM2MassInsertion", IfMissing->"create"][3] = FBHR@@gm2params;
  slha["GM2MassInsertion", IfMissing->"create"][4] = FBHL@@gm2params;
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
    ml, tmp
  },
  If[Not[StringQ[prefix]], Print["Invalid name"]; Abort[]];
  If[Not[AllTrue[{muoverm2, m2, x}, NumericQ]], Print["Invalid point"]; Abort[]];
  ml = Round[tmp*10]/10 /. FindRoot[calcX[m2, muoverm2 * m2, tmp, "tmp"] == x, {tmp, m2/4 + Min[m2, muoverm2 * m2]/2}];
  Return[GenPoint[tablespec, m2, ml]]
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
