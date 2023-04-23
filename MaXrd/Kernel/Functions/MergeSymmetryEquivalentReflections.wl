Options @ MergeSymmetryEquivalentReflections = {"ToStandardSetting" ->
     True};

SyntaxInformation @ MergeSymmetryEquivalentReflections = {"ArgumentsPattern"
     -> {_, _, OptionsPattern[]}};

Begin["`Private`"];

MergeSymmetryEquivalentReflections[group_String, hkl_List, OptionsPattern[
    ]] :=
    Block[
        {input, sg, merged}
        ,
        (* Check input *)
        input = InputCheck[hkl, "Integer", "WrapSingle"];
        sg = InputCheck["GetPointSpaceGroupCrystal", group];
(* Consider duplicate if they generate same symmetry equivalents 
    *)
        merged = DeleteDuplicatesBy[input, Sort @ SymmetryEquivalentReflections[
            sg, #]&];
        (* Optional: Use standard setting on indices *)
        If[OptionValue["ToStandardSetting"],
            ToStandardSetting[sg, #]& /@ merged
            ,
            merged
        ]
    ]

End[];
