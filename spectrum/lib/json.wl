BeginPackage["JSON`"];

GetJSON::Usage = "TBW";

Begin["Private`"];

GetJSON[args__] := Module[{fileName, JSONObject},
  fileName = {args}[[1]];
  JSONObject[] = Import[args] //. {List[elements__] :> Association[elements] /; AllTrue[{elements}, Head[#] === Rule &]};
  JSONObject[key_] := JSONObject[][key]["value"];
  Return[JSONObject]
];

End[];

EndPackage[];
