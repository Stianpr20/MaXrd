Options @ GetSymmetryOperations = {"AugmentedMatrix" -> True, "IgnoreTranslations"
     -> False, "UseCentring" -> False};

SyntaxInformation @ GetSymmetryOperations = {"ArgumentsPattern" -> {_,
     OptionsPattern[]}};

Begin["`Private`"];

GetSymmetryOperations[input_String, OptionsPattern[]] :=
    Block[{symData, operations, pointGroupQ = False, centeringVectors
        },
        symData = $GroupSymbolRedirect @ InputCheck["GetPointSpaceGroupCrystal",
             input];
        operations = Lookup[symData, "SymmetryOperations"];
        If[MissingQ @ operations || AssociationQ @ operations,
            pointGroupQ = True;
            operations =
                Lookup[
                    If[MissingQ @ operations,
                        symData
                        ,
                        operations
                    ]
                    ,
                    "MatrixOperations"
                ]
        ];
        If[!pointGroupQ,
            If[TrueQ @ OptionValue["IgnoreTranslations"],
                operations = operations[[All, 1]]
                ,
                If[TrueQ @ OptionValue["UseCentring"],
                    centeringVectors = Quiet @ InputCheck["GetCentringVectors",
                         input];
                    operations = Flatten[Table[{operations[[i, 1]], Mod[
                        operations[[i, 2]] + centeringVectors[[j]], 1]}, {j, Length @ centeringVectors
                        }, {i, Length @ operations}], 1]
                ]
            ]
        ];
        If[TrueQ @ OptionValue["AugmentedMatrix"],
            AffineTransform /@ operations
            ,
            operations
        ]
    ]

End[];
