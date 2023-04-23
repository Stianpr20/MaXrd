DistortStructure::InvalidDistortionType = "\"DistortionType\" must be set to either \"Crystallographic\" or \"Cartesian\".";

DistortStructure::InvalidFunction = "Function must be a valid \!\(\*SuperscriptBox[\(\[DoubleStruckCapitalR]\), \(3\)]\)\[RightTeeArrow]\[MediumSpace]\!\(\*SuperscriptBox[\(\[DoubleStruckCapitalR]\), \(3\)]\) mapping.";

Options @ DistortStructure = {"DistortionType" -> "Crystallographic",
     "NewLabel" -> "", "ReturnConverter" -> False};

SyntaxInformation @ DistortStructure = {"ArgumentsPattern" -> {_, _, 
    OptionsPattern[{CrystalPlot, VectorPlot3D}]}};

Begin["`Private`"];

DistortStructure[crystal_, function_, OptionsPattern[]] :=
    Module[
        {newLabel = OptionValue["NewLabel"], distortionType = OptionValue[
            "DistortionType"], coordinateConverter, distortions, crystalMetric, inverseM,
             coordinates, coordinatesCartesian, newCoordinates, crystalCopy}
        ,
        (* Input checks *)
        InputCheck["CrystalQ", crystal];
        If[!StringQ @ newLabel || newLabel === "",
            newLabel = crystal
        ];
        If[!MemberQ[{"Cartesian", "Crystallographic"}, distortionType
            ],
            Message[EmbedStructure::InvalidDistortionType];
            Abort[]
        ];
        If[!MatchQ[function @@ RandomReal[{0, 1}, 3], {#, #, #}& @ _?
            NumericQ],
            Message[DistortStructure::InvalidFunction];
            Abort[]
        ];
        (* Calculate individual distortions *)
        coordinateConverter[coordinates_] :=
            (
                distortions = function @@@ N @ coordinates;
                If[distortionType === "Cartesian",
                    crystalMetric = GetCrystalMetric[crystal, "ToCartesian"
                         -> True];
                    inverseM = Inverse @ crystalMetric;
                    coordinatesCartesian = crystalMetric . #& /@ coordinates
                        ;
                    newCoordinates = coordinatesCartesian + distortions
                        ;
                    newCoordinates = inverseM . #& /@ newCoordinates
                    ,
                    (* Shifts in a pure crystallographic frame *)
                    newCoordinates = coordinates + distortions
                ]
            );
        If[TrueQ @ OptionValue["ReturnConverter"],
            Return @ coordinateConverter
        ];
        coordinates = $CrystalData[[crystal, "AtomData", All, "FractionalCoordinates"
            ]];
        newCoordinates = coordinateConverter @ coordinates;
(* Create new entry in `$CrystalData` (which may be overwritten) 
    *)
        crystalCopy = $CrystalData[crystal];
        crystalCopy[["AtomData", All, "FractionalCoordinates"]] = newCoordinates
            ;
        AssociateTo[$CrystalData, newLabel -> crystalCopy];
        (* Update auto-completion *)
        InputCheck["Update$CrystalDataAutoCompletion"];
        newLabel
    ];

End[];
