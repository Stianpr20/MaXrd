SyntaxInformation @ SymmetryEquivalentReflections = {"ArgumentsPattern" -> {_, _.}};

Begin["`Private`"];

SymmetryEquivalentReflections[input_String, hkl_List : {"h", "k", "l"}] :=
    Block[{group, operations},
        group = InputCheck["GetPointSpaceGroupCrystal", input];
        InputCheck[hkl, "1hkl", "StringSymbol"];
        operations = GetSymmetryOperations[group, "IgnoreTranslations" -> True];
        operations = Map[Transpose, operations, {2}];
        DeleteDuplicates[# @ hkl& /@ operations]
    ]

End[];
