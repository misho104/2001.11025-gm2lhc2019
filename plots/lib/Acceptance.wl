(* ::Package:: *)

BeginPackage["Acceptance`"];


Needs["SLHA`"];

A::usage = "Acceptance function for each analysis, where some decay frameworks may be assumed.";

Begin["`Private`"];


PidN[i:1|2|3|4] := {1000022, 1000023, 1000025, 1000035}[[i]]
PidC[j:1|2]     := {1000024, 1000037}[[j]]

DecayRateAliases[slha_, i:1|2|3|4, j:1|2] := Module[{n = PidN[i], c = PidC[j]}, <|
    "taulep"   -> 0.352,
    "tauhad"   -> 1 - 0.352,
    "NseL"    -> slha["decay", n][1000011, -11] + slha["decay", n][-1000011, 11],
    "NsmuL"   -> slha["decay", n][1000013, -13] + slha["decay", n][-1000013, 13],
    "NstauL"  -> slha["decay", n][1000015, -15] + slha["decay", n][-1000015, 15],
    "NseR"    -> slha["decay", n][2000011, -11] + slha["decay", n][-2000011, 11],
    "NsmuR"   -> slha["decay", n][2000013, -13] + slha["decay", n][-2000013, 13],
    "NstauR"  -> slha["decay", n][2000015, -15] + slha["decay", n][-2000015, 15],
    "Nsnue"   -> slha["decay", n][1000012, -12] + slha["decay", n][-1000012, 12],
    "Nsnumu"  -> slha["decay", n][1000014, -14] + slha["decay", n][-1000014, 14],
    "Nsnutau" -> slha["decay", n][1000016, -16] + slha["decay", n][-1000016, 16],
    "CseL"    -> slha["decay", c][-1000011, 12],
    "CsmuL"   -> slha["decay", c][-1000013, 14],
    "CstauL"  -> slha["decay", c][-1000015, 16],
    "CseR"    -> slha["decay", c][-2000011, 12],
    "CsmuR"   -> slha["decay", c][-2000013, 14],
    "CstauR"  -> slha["decay", c][-2000015, 16],
    "Csnue"   -> slha["decay", c][1000012, -11],
    "Csnumu"  -> slha["decay", c][1000014, -13],
    "Csnutau" -> slha["decay", c][1000016, -15],
    "Nse"   -> "NseL"   + "NseR",
    "Nsmu"  -> "NsmuL"  + "NsmuR",
    "Nstau" -> "NstauL" + "NstauR",
    "Csl1"  -> "CseL"   + "CseR"   + "Csnue",
    "Csl2"  -> "CsmuL"  + "CsmuR"  + "Csnumu",
    "Csl3"  -> "CstauL" + "CstauR" + "Csnutau",
    "Csl12" -> "Csl1"   + "Csl2"
|>];


A["ATLAS1803b"][slha_, i:1|2|3|4:2, j:1|2:1] := 1
A["ATLAS1803c"][slha_, i:1|2|3|4:2, j:1|2:1] := ("Csl12" + "taulep"*"Csl3") * ("Nse" + "Nsmu" + (3/4)"taulep"^2 "Nstau") //. DecayRateAliases[slha,i,j]
A["ATLAS1803d"][slha_, i:1|2|3|4:2, j:1|2:1] := slha["decay", PidN[i]][1000022, 23] * slha["decay", PidC[j]][1000022, 24]

A["CMS1709a"]  = A["ATLAS1803c"];
A["CMS1709b2"] = A["ATLAS1803c"];
A["CMS1709c1"] = A["ATLAS1803c"];
A["CMS1709d"]  = A["ATLAS1803d"];
A["CMS1709c2"][slha_, i:1|2|3|4:2, j:1|2:1] := Plus[
  ("tauhad" "taulep"^2 / 2) * "Csl3" * "Nstau",
  ("tauhad")                * "Csl3" * ("Nse" + "Nsmu"),
  ("tauhad" "taulep" / 2)  * "Csl12" * "Nstau"
] //. DecayRateAliases[slha,i,j];
A["CMS1709e"][slha_, i:1|2|3|4:2, j:1|2:1] := slha["decay", PidN[i]][1000022, 25] * slha["decay", PidC[j]][1000022, 24]


End[];
EndPackage[];
