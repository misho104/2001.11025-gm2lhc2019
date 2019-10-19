#!/usr/bin/env wolframscript
(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<"common.wl";

Needs["NDSolve`FEM`"];
DelaunayToElementMesh[dmesh_] := ToElementMesh[
  "Coordinates" -> MeshCoordinates[dmesh],
  "MeshElements" ->
   {TriangleElement@
     Pick[
      First@ Thread[MeshCells[dmesh, 2], Polygon],
      Unitize[Chop@ Flatten@ PropertyValue[{dmesh, 2}, MeshCellMeasure]],
      1]}]


grid = FileNames["../spectrum/grid/tab1_*.slha"] // ReadSLHAFiles[#, "Label"->({#["mass"][1000024], #["mass"][1000013]}&)]& // Select[#, #["mass"][1000013]<600&]&;


ListContourPlot[#["decay", 1000013][1000022, 13] &/@ grid, Contours->Range[10]/10, PlotRange->{{200, 500}, {200, 500}}, Contours->Log[0.1+Range[10]/10], InterpolationOrder->3]


assoc = #["decay", 1000013][1000022, 13] &/@ grid;
emesh = DelaunayToElementMesh[TransformedRegion[DelaunayMesh[{#[[1]],#[[2]]-0.1*#[[1]]}&/@Keys[assoc]], {#[[1]], #[[2]]+0.1*#[[1]]}&]]
func = ElementMeshInterpolation[{emesh}, Values[assoc]]


calc\[Sigma]EL[300]


atlas = ATLASUpperLimit["../lhc/atlas1908/aux_fig_3c.csv", "SkipLines"->1];


ListPlot[{#[[2]],#[[1]]}&/@ATLASUpperLimit["../lhc/atlas1908/aux_fig_3c.csv", "SkipLines"->1]]


emesh = DelaunayToElementMesh[TransformedRegion[DelaunayMesh[{#[[1]],#[[2]]-0.1*#[[1]]}&/@atlas[[All,{2,1}]]], {#[[1]], #[[2]]+0.1*#[[1]]}&]]
func = ElementMeshInterpolation[{emesh}, atlas[[All,3]]]


{func[#["mass"][1000013], #["mass"][1000022]], #["decay", 1000013][1000022, 13]^2 * calc\[Sigma]EL[#["mass"][1000013]]*2} & /@ grid;
tmp=Select[%, FreeQ[#,"nan"]&];
Log[#[[2]]/#[[1]]+0.001] &/@ tmp
ListContourPlot[%, Contours->{Log[1.001]}, ContourShading->None]


Keys[Select[tmp,#[[1]]<#[[2]]&]]
ListPlot[%, PlotStyle->{Red, Large}, PlotMarkers->{"\[FilledSquare]"}]
ListPlot[Keys[grid]]
Show[{%,%%}]





Select[%108






