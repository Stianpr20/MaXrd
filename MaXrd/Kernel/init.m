(* Mathematica Init File *)

(*---* Load definitions *---*)
Get@FileNameJoin[{$UserBaseDirectory, "Applications", "MaXrd", "Core", 
  "Definitions.m"}];

(*---* Auto completion *---*)
If[$VersionNumber >= 11.3,
Get@FileNameJoin[{$UserBaseDirectory, "Applications", "MaXrd", "Core", 
  "AutoComplete.m"}];
];