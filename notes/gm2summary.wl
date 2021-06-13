(* ::Package:: *)

(* Time-Stamp: <2021-6-13 16:30:47> *)

(* Copyright 2021 Sho Iwamoto / Misho
   This file is licensed under the Apache License, Version 2.0.
   You may not use this file except in compliance with it. *)

SetDirectory[NotebookDirectory[]];
AppendTo[$Path, "../vendor"];
<<PlotTools`


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


amu["FNAL"] = <|"value"->116592040*^-11, "unc"->Sqrt["syst"^2+"stat"^2], "syst"->"value"*Sqrt[157^2+25^2]*10^-9, "stat"->"value"*434*^-9, "y"->1.9, "color"->RGBColor["#ff0000"]|>;
amu["BNL"]  = <|"value"->116592089*^-11, "unc"->Sqrt["syst"^2+"stat"^2], "syst"->33*^-11, "stat"->54*^-11, "y"->4, "color"->RGBColor["#0000ff"]|>;
amu["AVG"]  = <|"value"->116592061*^-11, "unc"->41*^-11, "stat"->37*^-11(*Sho's average*), "y"->1, "color"->RGBColor["#800080"]|>;
amu["WP"]   = <|"value"->116591810*^-11, "unc"->43*^-11, "y"->3.5, "color"->RGBColor["#008000"]|>;
amu["WP+2104"] = <|"value"->116591821*^-11, "unc"->42*^-11, "y"->1, "color"->RGBColor["#008000"]|>;
amu["WP/BWC"] = <|"value"->116591954*^-11, "unc"->59*^-11, "y"->1.8, "color"->RGBColor["#007000"]|>;
amu["WP+2104/BWC"] = <|"value"->116591965*^-11, "unc"->57*^-11, "y"->2.7, "color"->RGBColor["#007000"]|>;
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
pointsToShow = point /@ {"FNAL", "BNL", "AVG", "WP", "WP+2104", "WP+2104/BWC"};
pointsStyle  = {amu[#]["color"], AbsoluteThickness[1.5Pixel]} &/@ {"FNAL", "BNL", "AVG", "WP", "WP+2104", "WP+2104/BWC"};
Show[
  ListPlot[pointsToShow[[All,2;;]], PlotMarkers->"", PlotStyle->pointsStyle, IntervalMarkers->"Bars", IntervalMarkersStyle->pointsStyle],
  ListPlot[pointsToShow[[All,{1}]], PlotMarkers->marker["Circle",PointSize->5], PlotStyle->pointsStyle], 
  PlotRange->{{17.5,21.65}, {0.7,5.3}},
  FrameLabel->LaTeX[{"a_\\mu\\times10^9-1165900"}],
  AspectRatio->0.6,
  ImageSize->{600,360},
  Prolog->{
    {Opacity[0.2], "color", Rectangle[{("value"-"unc")//shift,0},{("value"+"unc")//shift,10}]}//.amu["AVG"],
    {Opacity[0.2], "color", Rectangle[{("value"-"unc")//shift,0},{("value"+"unc")//shift,10}]}//.amu["WP+2104"]
  },
  Epilog->{
      Inset[Style["BNL \!\(\*StyleBox[\"g\",\nFontSlant->\"Italic\"]\)\[Minus]2", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["BNL"],
      Inset[Style["FNAL \!\(\*StyleBox[\"g\",\nFontSlant->\"Italic\"]\)\[Minus]2", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["FNAL"],
      Inset[Style["Experiment", 14, "color"], {"value"//shift, 5}]//.amu["AVG"],
      Inset[Style["Average", 14, "color"], {20.6, "y"+0.25}]//.amu["AVG"],
      Inset[Style["Standard Model", 14, "color"], {"value"//shift, 5}]//.amu["WP+2104"],
      Inset[Style["WhitePaper", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["WP"],
(*      Inset[Style["[2006.04822]", 12, "color"], {18.95, 1.2}]//.amu["WP"], *)
      Inset[Style["WP & Mainz-LbL", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["WP+2104"],
(*      Inset[Style["[2104.02532]", 12, "color"], {19.3, 0.4}]//.amu["WP"], *)
      Inset[Style["WP but BMWc-HVP", 14, "color"], {"value"//shift, "y"+0.25}]//.amu["WP+2104/BWC"]
  }
]//OverrideTicks[LinTicks[17.5,21.5,10],LinTicks[-2,-1]]
OutputPDF[%, "fig"]


diff["AVG", "WP+2104"]//N
diff["AVG", "WP+2104/BWC"]//N
diff["AVG", "WP/BWC"]//N



