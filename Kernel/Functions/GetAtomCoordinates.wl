GetAtomCoordinates::InvalidCrystalObject = "Invalid crystal object.";

GetAtomCoordinates::PlotObjectInsufficient = "Crystal plot object has insufficient lattice information.";

Options @ GetAtomCoordinates = {"Cartesian" -> False, "GatherElements" -> True, "IgnoreCharge" -> True};

SyntaxInformation @ GetAtomCoordinates = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

Begin["`Private`"];

GetAtomCoordinates[crystalObject_, options : OptionsPattern[]] :=
    Block[{atomData, plotData, toCartesianQ = TrueQ @ OptionValue["Cartesian"], gatherElementsQ = TrueQ @ OptionValue["GatherElements"], ignoreChargeQ = TrueQ @ OptionValue["IgnoreCharge"], transformationMatrix},
        Switch[crystalObject,
            _String,
                InputCheck["CrystalQ", crystalObject];
                atomData = Lookup[InputCheck["GetAtomData", crystalObject], {"Element", "FractionalCoordinates"}];
                If[gatherElementsQ,
                    atomData = Merge[MapThread[Rule, Transpose @ atomData], Identity]
                ];
                If[toCartesianQ,
                    transformationMatrix = GetCrystalMetric[crystalObject, "ToCartesian" -> True];
                    atomData = GAC$TransformCoordinates[transformationMatrix, atomData]
                ]
            ,
            _Graphics3D,
                plotData = Cases[First @ crystalObject, x_ /; Head @ x[[2]] === Opacity];
                plotData = DeleteCases[plotData, _Opacity, 2];
                plotData = MapAt[First, plotData, {All, 2}];
                plotData = MapThread[Rule, Transpose @ plotData];
                plotData = Merge[plotData, Identity];
                plotData = KeyMap[GAC$ColorToElementMap, plotData];
                atomData = Flatten[#, Depth @ # - 3]& /@ plotData;
                If[!gatherElementsQ,
                    atomData = List @@@ Flatten @ KeyValueMap[Thread[#1 -> #2]&, atomData]
                ];
                If[!toCartesianQ,
                    transformationMatrix = Inverse @ GAC$GetMetricFromPlotVectors @ crystalObject;
                    atomData = GAC$TransformCoordinates[transformationMatrix, atomData]
                ]
            ,
            _,
                Message[GetAtomCoordinates::InvalidCrystalObject];
                Abort[]
        ];
        If[ignoreChargeQ,
            atomData = atomData /. x_String :> StringReplace[x, RegularExpression["([A-Z][a-z]?).*"] -> "$1"]
        ];
        atomData
    ]

GAC$ColorToElementMap :=
    Association[ColorData["Atoms"][#] -> #& /@ Keys @ $PeriodicTable];

GAC$GetMetricFromPlotVectors[plotObject_Graphics3D] :=
    Block[{metric},
        metric = Cases[First @ plotObject, x_ /; Head @ x[[2]] === Arrow];
        If[metric === {},
            Message[GetAtomCoordinates::PlotObjectInsufficient];
            Abort[]
        ];
        metric = Transpose @ metric[[All, 2, 1, 1, 2]]
    ]

GAC$TransformCoordinates[transformationMatrix_, coordinates_Association] :=
    Map[transformationMatrix . #&, coordinates, {2}]

GAC$TransformCoordinates[transformationMatrix_, coordinates_List] :=
    MapAt[transformationMatrix . #&, coordinates, {All, 2}]

End[];
