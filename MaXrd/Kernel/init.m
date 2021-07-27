(* Mathematica Init File *)


(*---* Load definitions *---*)
Get["MaXrd`Core`Definitions`"]

(*---* Check version *---*)
If[$Notebooks && $VersionNumber < 11.3,
Print["MaXrd " <> $MaXrdVersion <> " requires Mathematica version 11.3 or higher."]]
