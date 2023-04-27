GetSymmetryData::InvalidLabel = "\[LeftGuillemet]`1`\[RightGuillemet] is not a recognised label.";

GetSymmetryData::Incompatible = "Incompatible group type and label.";

Options @ GetSymmetryData = {"UnambiguousSymbol" -> True, "UseMainEntry" -> False};

SyntaxInformation @ GetSymmetryData = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

Begin["`Private`"];

GetSymmetryData[input_String, label_String:"Lookup", OptionsPattern[]] :=
    Block[
        {group, validLabels, type, data, dataMain, temp}
        ,
        (* Extract point- or space group (also check $CrystalData) *)
        group = InputCheck["GetPointSpaceGroupCrystal", input];
        validLabels = {"Lookup", "Symbol", "HermannMauguinFull", "HermannMauguinShort", "HallString", "PointGroupNumber", "SpaceGroupNumber", "LaueClass", "CrystalSystem", "Centring", "MainEntryQ", "GroupType", "Setting"};
        If[!MemberQ[validLabels, label],
            Message[GetSymmetryData::InvalidLabel, label];
            Abort[]
        ];
        data = $GroupSymbolRedirect @ group;
        type =
            If[MemberQ[$PointGroups, data, Infinity],
                "PointGroup"
                ,
                "SpaceGroup"
            ];
        If[(type === "PointGroup" && label === "SpaceGroupNumber") || (type === "SpaceGroup" && label === "PointGroupNumber"),
            Message[GetSymmetryData::incompatible];
            Abort[]
        ];
        If[label === "GroupType",
            Return @ type
        ];
        (* Group designation *)
        group =
            If[type === "SpaceGroup",
                data["Name", "HermannMauguinFull"]
                ,
                data["Name", "Symbol"]
            ];
        If[label == "Centring",
            If[type == "PointGroup",
                Message[GetSymmetryData::Incompatible];
                Abort[]
            ];
            Return @ StringTake[group, 1]
        ];
        (* Ascertain main entry *)
        dataMain =
            If[type === "SpaceGroup",
                temp = Position[$SpaceGroups, group];
                $SpaceGroups[temp[[1, 1, 1]]]
                ,
                temp = Position[$PointGroups, data];
                $PointGroups[temp[[1, 1, 1]]]
            ];
        (* Optional: Use main entry corresponding to input *)
        If[TrueQ @ OptionValue["UseMainEntry"],
            data = dataMain
        ];
        (* Executing commands *)
        If[label === "Lookup",
            Return @ data
        ];
        If[label === "MainEntryQ",
            Return @ KeyExistsQ[data, type <> "Number"]
        ];
        If[MemberQ[{"Symbol", "HermannMauguinFull", "HermannMauguinShort", "HallString"}, label],
            (* Optional: Let output be unambiguous *)
            If[TrueQ @ OptionValue["UnambiguousSymbol"] && label === "Symbol",
                Return @ ToStandardSetting @ data["Name", "HermannMauguinFull"]
                ,
                Return @ data["Name", label]
            ]
        ];
        If[label === "Setting",
            Return @ data @ label
        ];
        If[MemberQ[{"PointGroupNumber", "SpaceGroupNumber", "LaueClass", "CrystalSystem"}, label],
            Return @ dataMain @ label
        ]
    ]

End[];
