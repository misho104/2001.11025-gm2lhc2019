(* ::Package:: *)
(* Time-Stamp: <2020-01-06 17:06:49> *)

BeginPackage["PlotTools`"];


Needs["MaTeX`"];
Global`thisFile := If[$FrontEnd === Null, $Input, NotebookFileName[]];

outputPDF::usage = "Export object to PDF file.";

colors::usage = "Return arranged colors.";
color::usage = "Return an arranged color.";
markers::usage = "Return arranged markers.";
marker::usage = "Return an arranged marker.";

MaTeXRaw::usage = "MaTeX call with escaping the string.";
TeXParamAligned::usage = "MaTeX call for aligned parameters.";
TeXParamRow::usage = "MaTeX call for a parameter row.";
MyChartingScaledTicks::usage = "special ticks for my log axis.";


Begin["`Private`"];


SetAttributes[outputPDF, HoldFirst];
outputPDF[obj_, title_String:None] := Module[{t, prefix, filename},
  t = If[StringQ[title], title, TextString[HoldForm[obj]]];
  prefix = FileBaseName[Global`thisFile];
  filename = If[StringQ[prefix], prefix, "unknown"] <> "_" <> t <> ".pdf";
  Export[filename, Magnify[obj, 1]]];


(* Color Scheme good for color-blind and monochromatic; cf. https://github.com/misho104/scicolpick ; colordistance 29.67 *)
colors = RGBColor /@ {"#001b95", "#6e501f", "#d2454f", "#639bf3", "#00e47b"};
color[i_Integer] /; 1<=i<=9 := colors[[i]];
color[i_Integer] /; i>9 := (Print["Color undefined"]; Abort[];)
color[0] := RGBColor["#000000"];


(* Mathematica's font-based markers have alignment issue; use graphic-based markers
  https://mathematica.stackexchange.com/questions/84857/
  https://github.com/AlexeyPopkov/PolygonPlotMarkers/ *)

Options[fm] = {PointSize -> 5};
Options[em] = {PointSize -> 5, Thickness -> 1, FaceForm -> Transparent};

fm[name_, OptionsPattern[]] := Graphics[{
    EdgeForm[], ResourceFunction["PolygonMarker"][name, Offset[OptionValue[PointSize]]]
  },
  AlignmentPoint -> {0, 0}];
em[name_, OptionsPattern[]] := Graphics[{
    Dynamic@EdgeForm@Directive[CurrentValue["Color"], JoinForm["Round"], AbsoluteThickness[OptionValue[Thickness]], Opacity[1]],
    FaceForm[OptionValue[FaceForm]],
    ResourceFunction["PolygonMarker"][name, Offset[OptionValue[PointSize]]]
  },
  AlignmentPoint -> {0, 0}];
marker[name_String, options___] := If[
  StringMatchQ[name, "Empty" ~~ __],
  em[StringTake[name, {6, -1}], options],
  fm[name, options]
];
markerNames = {"Circle", "Square", "Diamond", "Triangle", "DownTriangle", "EmptyCircle", "EmptySquare", "EmptyDiamond", "EmptyTriangle", "EmptyDownTriangle"};
markers = marker /@ markerNames;
marker[i_Integer, options___] := marker[markerNames[[Mod[i-1, Length[markerNames]]+1]], options];

Themes`AddThemeRules["MishoStyle", Join[
  Charting`ResolvePlotTheme["Detailed", "ListLogPlot"] /.  {
    List[Directive[__],___] -> Thread@Directive[colors, AbsoluteThickness[1.6`]]
  },
  {LabelStyle->Black,
    BaseStyle -> {Black, FontFamily->"Times New Roman", FontSize->15}
  }]];
SetOptions[#,
  PlotTheme -> "MishoStyle",
  ImageSize -> {Automatic, 250}
] &/@ {Plot, LogPlot, LogLogPlot, LogLinearPlot, ListPlot, ListLogPlot, ListLogLogPlot, ListLogLinearPlot, ListContourPlot};

SetOptions[MaTeX, FontSize->16, "BasePreamble"->{"\\usepackage{exscale,amsmath,amssymb,color,newtxtext,newtxmath}"}, ContentPadding->False];

(* Revert Mathematica's alphabetical escape sequences *)
RawString[s_String] := StringReplace[s, {"\b" -> "\\b", "\f" -> "\\f", "\n" -> "\\n", "\r" -> "\\r", "\t" -> "\\t"}]
MaTeXRaw[a_String] := MaTeXRaw[{a}][[1]]
MaTeXRaw[a_List] := Module[{tmp, tmpraw, matexed},
  tmp = Select[a, StringQ] // DeleteDuplicates;
  tmpraw = RawString /@ tmp;
  matexed = MaTeX[tmpraw];
  a /. (Rule[#[[1]], #[[2]]] &/@ Transpose[{tmp, matexed}])]


TeXParamAligned[params_List] := "\\begin{aligned}" <> StringRiffle[#[[1]] <> "&=" <> If[Head[#[[2]]]===String,#[[2]],MyTextString[#[[2]]]] &/@ params, "\\\\"] <> "\\end{aligned}"
TeXParamRow[params_List] := StringRiffle[#[[1]] <> "=" <> If[Head[#[[2]]]===String,#[[2]],MyTextString[#[[2]]]] &/@ params, ",\\ \\ "]

Options[MyChartingScaledTicks] := {"RawRange" -> {0.1, 10}, "Separator" -> "\[CenterDot]"};
MyChartingScaledTicks[arg_, OptionsPattern[]] := MapAt[Module[{form},
    form[n_] := If[Between[n, OptionValue["RawRange"]], TextString[n],
      Module[{e = Floor[Log10[n]], r},
        r = TextString[n/10^e] // StringReplace["." ~~ EndOfString -> ""];
        If[r == "1", Superscript[10, e], Row[{r, Superscript[10, e]}, OptionValue["Separator"]]]]];
    Replace[#, {
      n_?NumericQ | NumberForm[n_, _] :> form[n],
      Superscript[a_, b_] :> form[a^b],
      Row[{a_, Superscript[b_, c_]}, _] :> form[a*b^c]
    }]] &, Charting`ScaledTicks[arg][##], {All, 2}] &


End[];
EndPackage[];
