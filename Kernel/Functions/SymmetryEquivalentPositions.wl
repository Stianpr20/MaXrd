SymmetryEquivalentPositions::threshold = "Tolerance specification must be a non-negative number.";

Options @ SymmetryEquivalentPositions = {"Coordinates" -> {"x", "y", "z"}, "RationaliseThreshold" -> 0.001, "UseCentring" -> True};

SyntaxInformation @ SymmetryEquivalentPositions = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

Begin["`Private`"];

SymmetryEquivalentPositions[input_String, OptionsPattern[]] :=
    Block[
        {xyzInput = OptionValue["Coordinates"], group, \[Delta] = OptionValue["RationaliseThreshold"], useCenteringQ = TrueQ @ OptionValue["UseCentring"], xyz, centeringVectors, s, mod, t, sym}
        ,
        (* Checks *)
        If[!NumericQ @ \[Delta] || Negative @ \[Delta],
            Message @ SymmetryEquivalentPositions::threshold
        ];
        group = InputCheck["GetPointSpaceGroupCrystal", input];
        xyz = InputCheck[xyzInput, "WrapSingle"];
        (* Auxiliary *)
        mod[coordinate_] :=
            Switch[coordinate,
                _?NumericQ,
                    Mod[coordinate, 1]
                ,
                _Plus,
                    t = Select[coordinate, NumericQ];
                    sym = coordinate - t;
                    Mod[t, 1] + sym
                ,
                _,
                    coordinate
            ];
        (* Generate equivalent positions *)
        s = GetSymmetryOperations[group, "AugmentedMatrix" -> True, "UseCentring" -> useCenteringQ];
        xyz = InputCheck["RecognizeFractions", xyz, \[Delta]];
        xyz = Transpose[# @ xyz& /@ s];
        If[!useCenteringQ,
            xyz =
                DeleteDuplicatesBy[
                        #
                        ,
                        centeringVectors = InputCheck["GetCentringVectors", group];
                        Sort @ Map[mod, (centeringVectors\[Transpose] + #)\[Transpose], {2}]&
                    ]& /@ xyz
        ];
        xyz = Map[mod, xyz, {3}];
        xyz = xyz /. x_Real :> Round[x, 10. ^ (-6)];
        xyz = DeleteDuplicates /@ xyz;
        If[MatchQ[xyzInput, {x_, y_, z_} /; !AnyTrue[{x, y, z}, ListQ]],
            First @ xyz
            ,
            xyz
        ]
    ];

SymmetryEquivalentPositions[input_String, coordinates_List, options : OptionsPattern[]] :=
    SymmetryEquivalentPositions[input, Options[{"Coordinates" -> coordinates, options}]]

End[];
