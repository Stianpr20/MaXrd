SyntaxInformation @ SymmetryEquivalentReflectionsQ = {"ArgumentsPattern" -> {_, _}};

Begin["`Private`"];

SymmetryEquivalentReflectionsQ[group_String, hkl_List] :=
    Block[
        {equiv}
        ,
        (* Check input *)
        Check[InputCheck[hkl, "Multiple"], Abort[]];
        (* Listing all symmetry-equivalents of the first reflection *)
        equiv = SymmetryEquivalentReflections[group, First @ hkl];
        (* Checking if all given reflections are symmetry equivalent *)
        AllTrue[hkl, MemberQ[equiv, #]&]
    ]

End[];
