(* ::Package:: *)

(* Time-Stamp: <2021-8-7 18:48:32> *)

(* Copyright 2021 Sho Iwamoto / Misho
   This file is licensed under the Apache License, Version 2.0.
   You may not use this file except in compliance with it. *)

SetDirectory[NotebookDirectory[]];
AppendTo[$Path, "../vendor"];
<<PlotTools`

Around[0,0];
Language`UncertaintyDump`$UDT = 100; (*Around Hack*)
Language`UncertaintyDump`$redThreshold = 10^20;
Language`UncertaintyDump`$large = 10^11;


(* ::Section:: *)
(*SM White Paper*)


CirclePlus[{a1_, e1_}, {a2_, e2_}] := {a1 + a2, Sqrt[e1^2 + e2^2]}
CirclePlus[a_, b_, c__] := CirclePlus[CirclePlus[a,b],c]
avg[{m1_, e1_}, {m2_, e2_}] := {(e2^2 m1 + e1^2 m2)/(e1^2+e2^2), e1 e2/Sqrt[e1^2+e2^2]}
avg[a_, b_, c__] := avg[avg[a,b],c]
errsum[a__] := Sqrt[Total[#^2&/@{a}]]


(* ::Subsubsection:: *)
(*Executive Summary*)


WP["QED"] = {116584718.931 - 116590000, 0.104};
WP["EW"] = {153.6, 1.0};
WP["HVP"] = {6845, 40};
WP["HLbL"] = {91.914, 18.066};
WP["total"] = WP["QED"] \[CirclePlus] WP["EW"] \[CirclePlus] WP["HVP"] \[CirclePlus] WP["HLbL"]


(* ::Subsubsection:: *)
(*HLbL*)


(* White Paper (4.92)-(4.93) *)
WP["HLbL:p/uds"] = ({93.8, 4.0} \[CirclePlus] {-16.4, 0.2} \[CirclePlus] {-8, 1}) \[CirclePlus] ({-1, 3} + {6, 6} + {15, 10})
WP["HLbL:p/c"]   = {3, 1}
WP["HLbL:p,LO"] = WP["HLbL:p/uds"] \[CirclePlus] WP["HLbL:p/c"]
WP["HLbL:p,NLO"] = {2, 1}


(* White Paper (5.49) *)
WP["HLbL:lattice,RBC"] = {78.7, errsum[30.6,17.7]}


(* White Paper (8.10)-(8.11) *)
WP["HLbL:LO"] = avg[WP["HLbL:p/uds"], WP["HLbL:lattice,RBC"]] \[CirclePlus] WP["HLbL:p/c"]
WP["HLbL:full"] = WP["HLbL:LO"] + WP["HLbL:p,NLO"]


(* ::Subsubsection:: *)
(*HVP*)


WP["HVP:LO,ee"] = {6931, 40};
WP["HVP:NLO,ee"] = {-98.3, 0.7};
WP["HVP:NNLO,ee"] = {12.4, 0.1};
(* note: Eq(2.37)-below says "their errors should be taken as fully (anti-)correlated" *)
WP["HVP:ee"] = WP["HVP:LO,ee"] + WP["HVP:NLO,ee"] + WP["HVP:NNLO,ee"]


WP["HVP:lattice,ud"] = {6502, 116};
WP["HVP:lattice,s"] = {532, 3};
WP["HVP:lattice,c"] = {146, 1};
WP["HVP:lattice,disc"] = {-137, 29};
WP["HVP:lattice,delta"] = {72, 34};
WP["HVP:lattice,a^2"] = WP["HVP:lattice,ud"] + WP["HVP:lattice,s"] + WP["HVP:lattice,c"] + WP["HVP:lattice,disc"]
WP["HVP:lattice,LO"] = WP["HVP:lattice,a^2"] + WP["HVP:lattice,delta"]


(* ::Section:: *)
(*WhitePaper + Mainz 2104.02632*)


Mainz["HLbL,uds"] = {106.8, 14.7}
Mainz["HLbL,LO"] = Mainz["HLbL,uds"] \[CirclePlus] WP["HLbL:p/c"]
Mainz["HLbL"] = Mainz["HLbL,LO"] + WP["HLbL:p,NLO"]
Mainz["total"] = WP["QED"] \[CirclePlus] WP["EW"] \[CirclePlus] WP["HVP"] \[CirclePlus] Mainz["HLbL"]


(* ::Subsubsection:: *)
(*RBC+2104.02632 averaged contribution*)


WPWithMainz["HLbL,uds"] = avg[WP["HLbL:p/uds"], WP["HLbL:lattice,RBC"], Mainz["HLbL,uds"]]
WPWithMainz["HLbL,LO"] = WPWithMainz["HLbL,uds"]  \[CirclePlus] WP["HLbL:p/c"]
WPWithMainz["HLbL"] = WPWithMainz["HLbL,LO"] + WP["HLbL:p,NLO"]
WPWithMainz["total"] = WP["QED"] \[CirclePlus] WP["EW"] \[CirclePlus] WP["HVP"] \[CirclePlus] WPWithMainz["HLbL"]


(* ::Section:: *)
(*WhitePaper+2104.02632AVG but HVP from BMWc*)


BMW["HVP:LO"] = {7075, 55};
BMW["HVP"] = BMW["HVP:LO"] + WP["HVP:NLO,ee"] + WP["HVP:NNLO,ee"];
BMW["total/WP"] = WP["QED"] \[CirclePlus] WP["EW"] \[CirclePlus] BMW["HVP"] \[CirclePlus] WP["HLbL"]
BMW["total/WP+Maintz"] = WP["QED"] \[CirclePlus] WP["EW"] \[CirclePlus] BMW["HVP"] \[CirclePlus] WPWithMainz["HLbL"]


WP["HVP:LO,ee"] \[CirclePlus] (-BMW["HVP:LO"])
%[[1]]/%[[2]]//N


(* ::Section:: *)
(*Plot*)


amu["FNAL"] = <|"value"->116592040*^-11, "unc"->Sqrt["syst"^2+"stat"^2], "syst"->"value"*Sqrt[157^2+25^2]*10^-9, "stat"->"value"*434*^-9, "y"->3.7, "color"->RGBColor["#ff0000"]|>;
amu["BNL"]  = <|"value"->116592089*^-11, "unc"->Sqrt["syst"^2+"stat"^2], "syst"->33*^-11, "stat"->54*^-11, "y"->4.3, "color"->RGBColor["#3636ff"]|>;
amu["AVG"]  = <|"value"->116592061*^-11, "unc"->41*^-11, "stat"->37*^-11(*Sho's average*), "y"->3.1, "color"->RGBColor["#000000"]|>;
amu["WP"]   = <|"value"->116591810*^-11, "unc"->43*^-11, "y"->2.3, "color"->RGBColor["#008800"]|>;
amu["WP+2104"] = <|"value"->116591821*^-11, "unc"->42*^-11, "y"->1.8, "color"->RGBColor["#008800"]|>;
amu["WP/BWC"] = <|"value"->116591954*^-11, "unc"->59*^-11, "y"->1.4, "color"->RGBColor["#008800"]|>;
amu["WP+2104/BWC"] = <|"value"->116591965*^-11, "unc"->57*^-11, "y"->2.7, "color"->RGBColor["#008800"]|>;
shift[v_]:=v*10^9-1165900
diff[a_, b_] := (({"value", "unc"} //. amu[a]) \[CirclePlus] ({-"value", "unc"} //. amu[b])) // #[[1]]/#[[2]]&


point[name_] := Module[{tick=0.1, result},
  result = {
    {"value", "y"}, (* main point *)
    {Around["value", "unc"], "y"} (* main bar *)
  }//.amu[name];
  If[Head["stat"//.amu[name]] =!= String,
    AppendTo[result, {"value"-"stat",Around["y",tick]}//.amu[name]];
    AppendTo[result, {"value"+"stat",Around["y",tick]}//.amu[name]];
  ];
  {#[[1]]//shift, #[[2]]} &/@ result
]
pointsToShow = point /@ {"FNAL", "BNL", "AVG", "WP", "WP/BWC"};
pointsStyle  = {amu[#]["color"], AbsoluteThickness[1.5Pixel]} &/@ {"FNAL", "BNL", "AVG", "WP", "WP+2104", "WP+2104/BWC"};
Show[
  ListPlot[pointsToShow[[All,2;;]], PlotMarkers->"", PlotStyle->pointsStyle, IntervalMarkers->"Bars", IntervalMarkersStyle->pointsStyle],
  ListPlot[pointsToShow[[All,{1}]], PlotMarkers->marker["Circle",PointSize->5], PlotStyle->pointsStyle], 
  PlotRange->{{17.5,21.65}, {0.7,5.3}},
  FrameLabel->LaTeX[{"a_\\mu\\times10^9-1165900"}],
  AspectRatio->0.6,
  ImageSize->{600,360},
  Prolog->{
        {FaceForm[{Opacity[0.1], RGBColor["#ff00ff"]}], Rectangle[{("value" - "unc") // shift,  0}, {("value" + "unc") // shift, 10}]} //. amu["AVG"],
        ({RGBColor["#ff00ff"], Dashed, Line[{{"value" // shift,  0}, {"value" // shift,  3.1}}]} //. amu["AVG"]),
        ({RGBColor["#ff00ff"], Thin, Line[{{"value" + "unc" // shift,  0}, {"value" + "unc" // shift,  10}}]} //. amu["AVG"]),
        ({RGBColor["#ff00ff"], Thin, Line[{{"value" - "unc" // shift,  0}, {"value" - "unc" // shift,  10}}]} //. amu["AVG"])

    (*,
    {Opacity[0.2], "color", Rectangle[{("value"-"unc")//shift,0},{("value"+"unc")//shift,10}]}//.amu["WP+2104"]*)
  },
  Epilog->{
      Inset[Style["\:5b9f\:9a13", 14, "color"], {"value"//shift, 5}]//.amu["AVG"],
      Inset[Style["BNL \!\(\*StyleBox[\"g\",\nFontSlant->\"Italic\"]\)\[Minus]2", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["BNL"],
      Inset[Style["FNAL \!\(\*StyleBox[\"g\",\nFontSlant->\"Italic\"]\)\[Minus]2", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["FNAL"],
      Inset[Style["Average", 14, "color"], {20.6, "y"+0.25}]//.amu["AVG"],
      Inset[Style["\:7406\:8ad6\:ff08\:6a19\:6e96\:6a21\:578b\:ff09", 14, "color"], {(("value"/.amu["WP"])+("value"/.amu["WP/BWC"]))/2//shift, 2.9}]//.amu["WP+2104"],
      Inset[Style["WhitePaper", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["WP"],
(*      Inset[Style["[2006.04822]", 12, "color"], {18.95, 1.2}]//.amu["WP"], *)
(*    Inset[Style["WP & Mainz-LbL", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["WP+2104"], *)
(*      Inset[Style["[2104.02532]", 12, "color"], {19.3, 0.4}]//.amu["WP"], *)
      Inset[Style["HVP by BMWc", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["WP/BWC"],
      {Gray, Arrowheads[{-.05,.05}],Arrow[{{"WPAVGmid"+1.1,"y"+0.2/.amu["WP"]},{"WPAVGmid"-0.8, "y"+0.2/.amu["WP"]}}]},
      Inset[Style["4.2\[Sigma]", 14, Gray], {"WPAVGmid"+0.15, "y"+0.05/.amu["WP"]}],
      {Gray, Arrowheads[{-.05,.05}],Arrow[{{"BWCAVGmid"+0.5,"y"-0.2/.amu["WP/BWC"]},{"BWCAVGmid"-0.5, "y"-0.2/.amu["WP/BWC"]}}]},
      Inset[Style["1.5\[Sigma]", 14, Gray], {"BWCAVGmid", "y"-0.35/.amu["WP/BWC"]}]
      
  }/.{"WPAVGmid"->shift[(amu["AVG"]["value"]+amu["WP"]["value"])/2], "BWCAVGmid"->shift[(amu["WP/BWC"]["value"]+amu["AVG"]["value"])/2]}
]//OverrideTicks[LinTicks[17.5,21.5,10],LinTicks[-2,-1]]
OutputPDF[%, "fig"]
ColorConvert[%%, "Grayscale"]
diff["AVG", "WP"]//N
diff["AVG", "WP/BWC"]//N











(* ::Section:: *)
(*Further details*)


(* ::Subsection:: *)
(*QED: mass-independent contribution (Section 6 of WP)*)


a4 = PolyLog[4, 1/2];
\[Alpha]EM0 = 1/Around[137.035999084`, 0.000000021`];
m\[Mu]Overme = Around[206.7682827, 0.0000047];   (* WP's decision *)
m\[Mu]Overm\[Tau] = Around[5.94635, 0.00040] * 10^-2; (* WP's decision *)
WP["QED-A1", 2] = 1/2
WP["QED-A1", 4] = 197/144 + (1/2 - 3Log[2])Zeta[2] + 3/4 Zeta[3] // N[#,40]&
WP["QED-A1", 6] = Total[{
  83/72 Pi^2 Zeta[3],
  -215/24 Zeta[5],
  100/3 PolyLog[4, 1/2],
  25/18 Log[2]^4,
  -25/18 Pi^2 Log[2]^2,
  -239/2160 Pi^4,
  139/18 Zeta[3],
  -298/9 Pi^2 Log[2],
  17101/810 Pi^2,
  28259/5184
  }] // N[#,20]&
WP["QED-A1", 8] = -1.912245764926445574 (* precise upto 1100 digits *)
WP["QED-A1", 10] = Around[6.737, 0.159]
WP["QED-A1"] := Sum[(\[Alpha]/Pi)^n WP["QED-A1", 2n], {n, 1, 5}]
WP["QED-A1"] /. \[Alpha]->\[Alpha]EM0


(* ::Subsection:: *)
(*QED: mass-dependent contribution (Section 6 of WP + Laporta-Remiddi PLB 1992)*)


WP["QED-A2", 4, xinv_] := With[{x=1/xinv}, Total[{
    -25/36,
    -Log[x]/3,
    x^2(4+3Log[x]),
    (x/2)(1-5x^2)(Pi^2/2 - Log[x]Log[(1-x)/(1+x)] - PolyLog[2, x] + PolyLog[2, -x]),
    x^4 (Pi^2/3 - 2Log[x] (Log[1/x - x]) - PolyLog[2, x^2])
  }]];
WP["QED-A2", 4, m\[Mu]Overme]
Assuming[{x>0}, Series[WP["QED-A2", 4, 1/x], {x, 0, 6}] ] // Simplify
Normal[%] /. x->(1/m\[Mu]Overme)
tmp = %;

WP["QED-A2", 4, m\[Mu]Overm\[Tau]]
Assuming[{x>0}, Series[WP["QED-A2", 4, 1/x], {x, \[Infinity], 6}] ] // Simplify
Normal[%] /. x->(1/m\[Mu]Overm\[Tau])
WP["QED-A2", 4] = % + tmp;
WP["QED-A2", 2] = 0;


(* WP only shows upto x^2 but they numerically uses an expansion upto x^4,
   which is found in Laporta-Remiddi. *)
a\[Gamma]\[Gamma]Eq2[emu_] := With[{mue = 1/emu}, Total[{
  2/3 Pi^2 Log[mue] + 59/270 Pi^4 - 3Zeta[3] - 10/3 Pi^2 + 2/3,
  emu (4/3 Pi^2 Log[mue] - 196/3 Pi^2 Log[2] + 424/9 Pi^2),
  emu^2 (-2/3 Log[mue]^3 + (Pi^2/9 - 20/3) Log[mue]^2 - (16Pi^4/135 + 4Zeta[3] -32/9 Pi^2 + 61/3)Log[mue] + 4/3 Zeta[3]Pi^2 - 61/270 Pi^4 + 3Zeta[3]+ 25/18 Pi^2 - 283/12),
  emu^3 (10/9 Pi^2 Log[mue] - 11/9 Pi^2),
  emu^4 (7/9 Log[mue]^3 + 41/18 Log[mue]^2 + 13/9 Pi^2 Log[mue] + 517/108 Log[mue] + 1/2 Zeta[3] + 191/216 Pi^2 + 13283/2592)
  }]]
aVPEq3[emu_] := With[{mue = 1/emu}, Total[{
  2/9 Log[mue]^2 + (Zeta[3]-2/3 Pi^2 Log[2] + Pi^2/9 + 31/27) Log[mue],
  11/216 Pi^4 - 2/9 Pi^2 Log[2]^2 - 8/3 a4 - 1/9 Log[2]^4 - 3Zeta[3] + 5/3 Pi^2 Log[2]- 25/18 Pi^2 +1075/216,
  emu(-13/18 Pi^3 - 16/9 Pi^2 Log[2] + 3199/1080 Pi^2),
  emu^2 (10/3 Log[mue]^2 - 11/9 Log[mue] - 14/3 Pi^2 Log[2] - 2Zeta[3] + 49/12 Pi^2 -131/54),
  emu^3 (4/3 Pi^2 Log[mue]+35/12 Pi^3 - 16/3 Pi^2 Log[2] - 5771/1080 Pi^2),
  emu^4 (-25/9 Log[mue]^3 - 1369/180 Log[mue]^2 + (-2Zeta[3]+4Pi^2Log[2]-269/144 Pi^2 - 7496/675) Log[mue]
    - 43/108 Pi^4 + 8/9 Pi^2 Log[2]^2 + 80/3 a4 + 10/9 Log[2]^4 + 411/32 Zeta[3] + 89/48 Pi^2Log[2] - 1061/864 Pi^2 - 274511/54000)}]]

a\[Gamma]\[Gamma]Eq4[mue_] := With[{emu = 1/mue}, Total[{
  emu^2(3/2 Zeta[3] - 19/16),
  emu^4(-161/810 Log[mue]^2 - 16189/48600 Log[mue] + 13/18 Zeta[3] - 161/9720 Pi^2 - 831931/972000)
  }]]
aVPEq5[mue_] := With[{emu = 1/mue}, Total[{
  emu^2(-23/135 Log[mue] -2/45 Pi^2 + 10117/24300),
  emu^4(19/2520 Log[mue]^2 - 14233/132300Log[mue]+49/768 Zeta[3] -11/945 Pi^2 + 2976691/296352000)
}]]

(*
WP["QED-A2", 6, xinv_] /; xinv["Value"] > 1 := With[{x=1/xinv}, Total[{
    2/9 Log[x]^2,
    -(Zeta[3] - 2/3 Pi^2 Log[2] + 7Pi^2/9 + 31/27)Log[x],
    97Pi^4/360,
    -2/9 Pi^2 Log[2]^2,
    -8/3 PolyLog[4, 1/2],
    -Log[2]^4/9,
    -6Zeta[3],
    5/3Pi^2 Log[2],
    -85Pi^2/18,
    1219/216,
    x(-4/3 Pi^2 Log[x] - 604/9 Pi^2 Log[2] + 54079Pi^2/1080 - 13Pi^3/18),
    x^2(2/3 Log[x]^3 + (Pi^2/9 - 10/3)Log[x]^2 + (16Pi^4/135 + 4Zeta[3] - 32Pi^2/9 + 194/9) Log[x]
      + 4/3Zeta[3] Pi^2 - 61Pi^4/270 + Zeta[3] + 197Pi^2/36 - 2809/108 - 14/3 Pi^2 Log[2])
  }]];
*)
WP["QED-A2", 6, xinv_] /; xinv["Value"] > 1 := a\[Gamma]\[Gamma]Eq2[1/xinv] + aVPEq3[1/xinv]


WP["QED-A2", 6, xinv_] /; xinv["Value"] < 1 := With[{x=1/xinv}, Total[{
    x^-2 (-23/135 Log[x] - 74957/97200 - 2Pi^2/45 + 3/2 Zeta[3]),
    x^-4(-4337/22680 Log[x]^2 - 209891/476280 Log[x] - 451205689/533433600 - 1919Pi^2/68040 + 1811/2304 Zeta[3])
  }]];



WP["QED-A2", 6, m\[Mu]Overme]
WP["QED-A2", 6, m\[Mu]Overm\[Tau]]
WP["QED-A2", 6] = %% + %;


WP["QED-A3", 6] = With[{x = 1/m\[Mu]Overme, y = 1/m\[Mu]Overm\[Tau]}, Total[{
    y^-2 ( -4/135 Log[x] - 1/135 + 2/15 x^2 - 4Pi^2/45 x^3),
    y^-4 (-229213/12348000 + Pi^2/630 - 37/11025 Log[y] - 1/105 Log[y]Log[y/x^2] - 3/4900 Log[x])
  }]]


WP["QED-A2", 8] = Total[{
   Around[123.78551, 0.00044],
   Around[8.8997, 0.0059],
   Around[0.0424941, 0.0000053]
 }]
WP["QED-A3", 8] = Around[0.062722, 0.000010];
WP["QED-A2", 10] = Around[742.32, 0.86] + Around[-0.0656, 0.0045];
WP["QED-A3", 10] = Around[2.011, 0.010];


WP["QED-A2", n_]/;n<4 := 0
WP["QED-A3", n_]/;n<6 := 0
WP["QED", i_]  := WP["QED-A1", i] + WP["QED-A2", i] + WP["QED-A3", i]


(* ::Text:: *)
(*Table 18*)


Table[{
  WP["QED-A1", 2i](\[Alpha]/Pi)^i * 10^10,
  WP["QED-A2", 2i](\[Alpha]/Pi)^i * 10^10,
  WP["QED-A3", 2i](\[Alpha]/Pi)^i * 10^10,
  WP["QED", 2i](\[Alpha]/Pi)^i * 10^10
  }, {i, 5}] /. \[Alpha]->1/Around[137.035999046,0.000000027] // TableForm[#,TableAlignments->Right]&(*\[Alpha]CS*) 
Total[%[[All,4]]]

Table[{
  WP["QED-A1", 2i](\[Alpha]/Pi)^i * 10^10,
  WP["QED-A2", 2i](\[Alpha]/Pi)^i * 10^10,
  WP["QED-A3", 2i](\[Alpha]/Pi)^i * 10^10,
  WP["QED", 2i](\[Alpha]/Pi)^i * 10^10
  }, {i, 5}]/. \[Alpha]->1/Around[137.0359991496,0.000000033055] // TableForm[#,TableAlignments->Right]&(*\[Alpha]ae*)
Total[%[[All,4]]]//NumberForm






