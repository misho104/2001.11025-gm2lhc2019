(* ::Package:: *)

BeginPackage["CrossSection`"];


Needs["SLHA`"];
cFactors::usage = "Return the multiplication factor applicable for pure-wino cross section.";
calc\[Sigma]Wino::usage = "Call susy-xs program to return the pure-wino cross section.";
calc\[Sigma]EL::usage = "Call susy-xs program to return left-handed slepton pair-production cross section.";
calc\[Sigma]EWKino::usage = "Return the approximated cross section of ewkino.";

\[Sigma]UL2D::usage = "Interpolate a 3-column table with cache to give cross section upper limit."
ClearCaches::usage = "Clear cache.";

Begin["`Private`"];


PidN[i:1|2|3|4] := {1000022, 1000023, 1000025, 1000035}[[i]]
PidC[j:1|2]     := {1000024, 1000037}[[j]]

cFactors[slha_, i:1|2|3|4, j:1|2] := Module[{
    nmixI = Table[slha["nmix"][i, a], {a,4}],
    uJ = Table[slha["umix"][j, a], {a,2}],
    vJ = Table[slha["vmix"][j, a], {a,2}],
    nPhase, nI, gLog2, gRog2, cLL, cLR, cRR
  },
  nPhase = If[slha["mass"][PidN[i]] > 0, 1, I];
  nI = nPhase * nmixI;
  gRog2 = -vJ[[1]]Conjugate[nI[[2]]]+vJ[[2]]Conjugate[nI[[4]]]/Sqrt[2];
  gLog2 = -nI[[2]]Conjugate[uJ[[1]]]-nI[[3]]Conjugate[uJ[[2]]]/Sqrt[2];
  cLL = Abs[gLog2]^2;
  cLR = Re[Conjugate[gLog2]gRog2];
  cRR = Abs[gRog2]^2;
  {cLL, cLR, cRR}
]

calc\[Sigma]WinoCache = Association[];
calc\[Sigma]Wino[mass_] := Lookup[calc\[Sigma]WinoCache, mass,
  Module[{result},
    Run["susy-xs get 13TeV.n2x1+.wino " <> TextString[mass] <> " -0 > tmp"];
    result = Import["tmp", "List"];
    If[Length[result]=!=1, Print["susy-xs launch failed."]; Abort[]];
    calc\[Sigma]WinoCache[mass] = result[[1]];
    result[[1]]
  ]
]

calc\[Sigma]ELCache = Association[];
calc\[Sigma]EL[mass_] /; NumberQ[mass] := Lookup[calc\[Sigma]ELCache, mass,
  Module[{result},
    Run["susy-xs get 13TeV.slepslep.ll " <> TextString[mass] <> " -0 > tmp"];
    result = Import["tmp", "List"];
    If[Length[result]=!=1, Print["susy-xs launch failed."]; Abort[]];
    calc\[Sigma]ELCache[mass] = result[[1]];
    result[[1]]
  ]
]

calc\[Sigma]EWKino[slha_, i:1|2|3|4, j:1|2] := Module[{
    mass = GeometricMean[{
      slha["mass"][PidN[i]] // Abs,
      slha["mass"][PidC[j]]
    }],
    c = Mean[cFactors[slha, i, j]]
  },
  c * calc\[Sigma]Wino[mass]
]

\[Sigma]UL2DCacheInterpolations = Association[];
\[Sigma]UL2DCacheFunctions = Association[];
SetAttributes[\[Sigma]UL2D, HoldRest];
\[Sigma]UL2D[name_, tableHold_:None] := Lookup[\[Sigma]UL2DCacheFunctions, name,
  Module[{table = ReleaseHold[tableHold], rows, f, perturbation},
    If[table === None, Return[Function[{a, b}, None]]];
    rows = Select[table, MatchQ[#, {_?NumericQ, _?NumericQ, _?NumericQ}] && #[[3]]>0 &];
    perturbation[] := RandomReal[10^-10*{-1, 1}]; (* to avoid ElementMesh::femimq; See mathematica manual *)
    (* points with "0" are not analyzed; to avoid extrapolation, we set 10^6 for such points. *)
    \[Sigma]UL2DCacheInterpolations[name] = Interpolation[{{#[[1]], #[[2]]+perturbation[]}, Log[#[[3]]]} &/@ rows, InterpolationOrder->1, "ExtrapolationHandler" -> {Function[Indeterminate], "WarningMessage" -> False}];
    \[Sigma]UL2DCacheFunctions[name] = Function[{a, b}, Exp[\[Sigma]UL2DCacheInterpolations[name][a,b]]];
    Return[\[Sigma]UL2DCacheFunctions[name]]]];

ClearCaches[] := Module[{},
  calc\[Sigma]WinoCache = Association[];
  calc\[Sigma]ELCache = Association[];
  \[Sigma]UL2DCacheInterpolations = Association[];
  \[Sigma]UL2DCacheFunctions = Association[];
]

End[];
EndPackage[];
