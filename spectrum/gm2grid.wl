(* ::Package:: *)

$ProjectRoot = NestWhile[ParentDirectory, Directory[], (Not[ FileExistsQ[FileNameJoin[{#2, ".git"}]]] && UnsameQ[#1, #2]) &, 2];
$GM2CalcPath = FileNameJoin[{$ProjectRoot, "vendor", "GM2Calc"}];
AppendTo[$Path, #] &/@ Select[FileNames[FileNameJoin[{$ProjectRoot, "vendor", "*"}]], DirectoryQ];

Install[FileNameJoin[{$GM2CalcPath, "bin", "gm2calc.mx"}]];
<<lib`json`
<<SLHA`


sm = GetJSON["sm.json"];
GM2CalcSetSMParameters[
    alphaMZ -> sm["alpha_EW@m_Z"],
    alpha0  -> sm["alpha_EW@0"],
    alphaS  -> sm["alpha_s@m_Z"],
    MW      -> sm["m_W"],
    MZ      -> sm["m_Z"],
    MT      -> sm["m_t"],
    mbmb    -> sm["m_b@m_b"],
    ML      -> sm["m_tau"],
    MM      -> sm["m_mu"]
];

CalcAmu[p___]:=Module[{gm2result, result},
  result = Reap[
    Do[
      GM2Calc`GM2CalcSetFlags[Sequence@@(flags[[2;;]])];
      gm2result = GM2Calc`GM2CalcAmuGM2CalcScheme[p];
      Sow[flags[[1]]->{GM2Calc`amu, GM2Calc`Damu}//.gm2result];
    , {flags,{
      {"1L", loopOrder->1, tanBetaResummation->False},
      {"1Lresum", loopOrder->1, tanBetaResummation->True},
      {"2Lresum", loopOrder->2, tanBetaResummation->True}
    }}]
  ];
  result[[2,1]]
]

GenSLHA[p___]:=Module[{assoc},
  assoc = Association[p];
  s = SLHA`Private`NewSLHA[];
  s[#, IfMissing -> "create"] &/@ {"MODSEL", "SMINPUTS", "MINPAR", "EXTPAR"};

  s["MODSEL"][1] = 1;
  s["SMINPUTS"][1] = 1 / sm["alpha_EW@m_Z"];
  s["SMINPUTS"][2] = sm["G_F"];
  s["SMINPUTS"][3] = sm["alpha_s@m_Z"];
  s["SMINPUTS"][4] = sm["m_Z"];
  s["SMINPUTS"][5] = sm["m_b@m_b"];
  s["SMINPUTS"][6] = sm["m_t"];
  s["SMINPUTS"][7] = sm["m_tau"];
  s["SMINPUTS"][11] = sm["m_e"];
  s["SMINPUTS"][13] = sm["m_mu"];
  s["SMINPUTS"][21] = sm["m_d@2GeV"];
  s["SMINPUTS"][22] = sm["m_u@2GeV"];
  s["SMINPUTS"][23] = sm["m_s@2GeV"];
  s["SMINPUTS"][24] = sm["m_c@m_c"];
  s["MINPAR"][3] = assoc[TB];
  s["EXTPAR"][0] = assoc[Q];
  s["EXTPAR"][1] = assoc[MassB];
  s["EXTPAR"][2] = assoc[MassWB];
  s["EXTPAR"][3] = assoc[MassG];
  s["EXTPAR"][11] = assoc[Au][[3,3]];
  s["EXTPAR"][12] = assoc[Ad][[3,3]];
  s["EXTPAR"][13] = assoc[Ae][[3,3]];
  s["EXTPAR"][23] = assoc[Mu];
  s["EXTPAR"][26] = assoc[MAh];
  s["EXTPAR"][31] = assoc[ml2][[1,1]] ^ 0.5;
  s["EXTPAR"][32] = assoc[ml2][[2,2]] ^ 0.5;
  s["EXTPAR"][33] = assoc[ml2][[3,3]] ^ 0.5;
  s["EXTPAR"][34] = assoc[me2][[1,1]] ^ 0.5;
  s["EXTPAR"][35] = assoc[me2][[2,2]] ^ 0.5;
  s["EXTPAR"][36] = assoc[me2][[3,3]] ^ 0.5;
  s["EXTPAR"][41] = assoc[mq2][[1,1]] ^ 0.5;
  s["EXTPAR"][42] = assoc[mq2][[2,2]] ^ 0.5;
  s["EXTPAR"][43] = assoc[mq2][[3,3]] ^ 0.5;
  s["EXTPAR"][44] = assoc[mu2][[1,1]] ^ 0.5;
  s["EXTPAR"][45] = assoc[mu2][[2,2]] ^ 0.5;
  s["EXTPAR"][46] = assoc[mu2][[3,3]] ^ 0.5;
  s["EXTPAR"][47] = assoc[md2][[1,1]] ^ 0.5;
  s["EXTPAR"][48] = assoc[md2][[2,2]] ^ 0.5;
  s["EXTPAR"][49] = assoc[md2][[3,3]] ^ 0.5;
  Return[s];
]


p[m2_, mu_, ml_, prefix_] := <|"params"->{
    MAh    -> 3000,                     (* 2L *)
    MassG  -> 3000,                     (* 2L *)
    mq2    -> 3000^2 IdentityMatrix[3], (* 2L *)
    mu2    -> 3000^2 IdentityMatrix[3], (* 2L *)
    md2    -> 3000^2 IdentityMatrix[3], (* 2L *)
    Au     -> 0. IdentityMatrix[3],     (* 2L *)
    Ad     -> 0. IdentityMatrix[3],     (* 2L *)
    Ae     -> 0. IdentityMatrix[3],     (* 1L *)
    MassB  -> m2 / 2,                   (* 1L *)
    MassWB -> m2,                       (* 1L *)
    TB     -> 40,                       (* 1L *)
    Mu     -> mu,                       (* 1L *)
    ml2    -> ml^2   IdentityMatrix[3], (* 1L *)
    me2    -> 3000^2 IdentityMatrix[3], (* 1L *)
    Q      -> 200
    } // N,
    "filestem" -> StringRiffle[TextString/@{prefix, m2, ml}, "_"]
|>;
