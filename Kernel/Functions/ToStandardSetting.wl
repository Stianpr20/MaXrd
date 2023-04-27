ToStandardSetting::InvalidExtension = "Invalid extension \[LeftGuillemet]`1`\[RightGuillemet] for this space group.";

SyntaxInformation @ ToStandardSetting = {"ArgumentsPattern" -> {_, _.}};

Begin["`Private`"];

ToStandardSetting[group_String, hkl_List] :=
    Block[{equivalents, nonNegatives},
        InputCheck[hkl, "1hkl", "Integer"];
        InputCheck["PointSpaceGroupQ", group];
        equivalents = SymmetryEquivalentReflections[group, hkl];
        nonNegatives = Select[equivalents, AllTrue[#, NonNegative]&];
        If[nonNegatives =!= {},
            equivalents = nonNegatives
        ];
        Last @ SortBy[equivalents, {#[[3]]&, #[[2]]&, #[[1]]&}]
    ]

ToStandardSetting[input_String, extension_:1] :=
    Block[{sg, fullHM, SG, mainTargetQ, uniqueInSgQ, mainSetting, output = input, temp},
        InputCheck["PointSpaceGroupQ", input];
        sg = $GroupSymbolRedirect[input];
        fullHM = sg["Name", "HermannMauguinFull"];
        temp = Position[$SpaceGroups, fullHM];
        SG = $SpaceGroups[temp[[1, 1, 1]]];
        (* Is target space group main setting? *)
        mainTargetQ = Length @ First @ temp <= 3;
        (* Is target symbol unique among all space groups? *)
        temp = Position[$SpaceGroups, sg["Name", "Symbol"]];
        If[!Length @ DeleteDuplicates @ temp[[All, 1, 1]] === 1,
            Return @ fullHM
        ];
        (* Is target symbol unique in its space group? *)
        uniqueInSgQ = Length @ temp === 1;
        Which[(* With cell origin tag? *)
            extension =!= 1,
                output = sg["Name", "Symbol"] <> ":" <> ToString @ extension;
                If[!KeyExistsQ[$GroupSymbolRedirect, output],
                    Message[ToStandardSetting::InvalidExtension, extension];
                    Abort[]
                ]
            ,
            (* Is target "best candidate" for non-main symbol? *)!uniqueInSgQ && !mainTargetQ,
                mainSetting = First @ SG["Setting"];
                If[First @ sg["Setting"] === mainSetting,
                    output = sg["Name", "Symbol"]
                    ,
                    output = fullHM
                ]
            ,
            (* Uniquely formatted symbol OR "main symbol"? *)uniqueInSgQ || mainTargetQ,
                output = $GroupSymbolRedirect[output]["Name", "Symbol"]
            ,
            (* If ambiguous, use full Hermman--Mauguin *)True,
                output = fullHM
        ];
        Return @ output
    ]

End[];
