EmbedStructure::InvalidGuestInput = "Invalid guest unit input.";

EmbedStructure::InvalidTargetPositions = "Invalid position input.";

EmbedStructure::InvalidProbabilities = "The probabilities must be numbers between 0 and 1.";

EmbedStructure::InvalidTrimming = "Invalid setting for \"TrimBoundary\".";

EmbedStructure::InvalidPermutation = "Invalid input for \"Distortions\" or \"Rotations\".";

EmbedStructure::InvalidDistortionType = "\"DistortionType\" must be set to either \"Crystallographic\" or \"Cartesian\".";

EmbedStructure::InvalidOverlapRadius = "\"OverlapRadius\" must be numeric.";

EmbedStructure::InvalidAnchorReference = "Anchor reference type \[LeftGuillemet]`1`\[RightGuillemet] is invalid. Use either \"Host\" or \"Unit\".";

Options @ EmbedStructure = {"DataFile" -> FileNameJoin[{$MaXrdPath, "Kernel",
     "Data", "UserData", "CrystalData.m"}], "DistortHost" -> None, "DistortionType"
     -> "Cartesian", "Distortions" -> {0, 0, 0}, "MatchHostSize" -> True,
     "NewLabel" -> "", "OverlapPrecedence" -> "", "OverlapRadius" -> 1.0,
     "RotationAnchorReference" -> "Unit", "RotationAnchorShift" -> {0, 0,
     0}, "RotationAxes" -> IdentityMatrix[3], "Rotations" -> {0, 0, 0}, "ShowProgress"
     -> False, "TrimBoundary" -> "None"};

SyntaxInformation @ EmbedStructure = {"ArgumentsPattern" -> {_, _, _,
     OptionsPattern[]}};

Begin["`Private`"];

EmbedStructure[guestUnitsInput_, targetPositionsInput_List, hostCrystal_String,
     options : OptionsPattern[{EmbedStructure, DistortStructure}]] :=
    Block[
        {newStructureLabel = OptionValue["NewLabel"], invAbort, conditionFilterQ
             = False, crystalDataOriginal = $CrystalData, dataFile = OptionValue[
            "DataFile"], hostStructureSize, newSize, probabilities, units, distributionList,
             i, guestUnits, guestCopies, crystalLabels, specialCrystalLabels, nonVoidRange,
             matchHostSizeQ = TrueQ @ OptionValue["MatchHostSize"], anchorShift =
             OptionValue["RotationAnchorShift"], anchorReference = OptionValue["RotationAnchorReference"
            ], R, rotationAxes = OptionValue["RotationAxes"], targetPositions = targetPositionsInput,
             embedLength, latticeTargetPositions, hostCoordinates, mid, latticeParameters,
             latticeParametersABC, hostMetric, hostMetricInverse, targetPositionsCartesian,
             embeddingData, completed, M, T, p, P, CheckAndMakeRuleList, distortions,
             rotations, performShift, performTwist, conditions, list, shift, twist,
             MakeAlteration, PrepareAlterationList, conditionedDistortionsQ = False,
             conditionedRotationsQ = False, coordinatesCrystal, coordinatesCartesian,
             coordinatesCrystalEmbedded, coordinatesCrystalEmbeddedTranslated, newCoordinates,
             newCoordinatesCartesian, atomDataHost, atomDataGuest, joinedAtomData,
             boundary, hostCopy, newUnitCellAtomCount, optionsDS, hostDistorter, 
            findOverlap, intervals, checks, atomData1, atomData2, xyz1, xyz2, nearestList,
             overlappingCoordinates, overlapPrecedence = OptionValue["OverlapPrecedence"
            ], overlapRadius = OptionValue["OverlapRadius"], tmp}
        ,
        (*--- Input checks ---*)
        boundary = OptionValue["TrimBoundary"];
        If[!MemberQ[{"Box", "None", "OuterEdges"}, boundary],
            Message[EmbedStructure::InvalidTrimming];
            Abort[]
        ];
        If[!NumericQ @ overlapRadius,
            Message[EmbedStructure::InvalidOverlapRadius];
            Abort[]
        ];
        invAbort[] :=
            (
                Message[EmbedStructure::InvalidGuestInput];
                Abort[]
            );
        Which[
            ListQ @ guestUnitsInput,
                (* A. 'guestUnits' as list of crystals or elements *)
                    If[guestUnitsInput === {},
                    invAbort[]
                ];
                Which[(* A.a. Regular crystal entries *)
                    AllTrue[guestUnitsInput, StringQ] && (Depth @ guestUnitsInput
                         === 2),
                        Null(* Check complete *) ,
                    (* A.b. Conditional rules *)AllTrue[guestUnitsInput,
                         Head[#] === Rule&] && AllTrue[guestUnitsInput[[All, 1]], Head[#] ===
                         Condition&],
                        conditionFilterQ = True
                    ,
                    True,
                        invAbort[]
                ]
            ,
            Head @ guestUnitsInput === Rule,
(* B. 'guestUnits' as list paired with probabilities 
    *)If[Length @ guestUnitsInput[[1]] != Length @ guestUnitsInput[[2
    ]],
                    invAbort[]
                ];
                If[!AllTrue[guestUnitsInput[[1]], 0.0 <= # <= 1.0&],
                    Message[EmbedStructure::InvalidProbabilities];
                    Abort[]
                ]
            ,
            True,
                (* Invalid input *)invAbort[]
        ];
        If[!MatchQ[Dimensions @ targetPositions, {_, 3}],
            Message[EmbedStructure::InvalidTargetPositions];
            Abort[]
        ];
        If[!MemberQ[{"Host", "Unit"}, anchorReference],
            Message[EmbedStructure::InvalidAnchorReference, anchorReference
                ];
            Abort[]
        ];
        (*--- Checking and preparing embeddings ---*)
        crystalLabels = DeleteDuplicates @ Cases[Flatten[{hostCrystal,
             guestUnitsInput}], _String, 3];
        Scan[InputCheck["CrystalEntityQ", #]&, crystalLabels];
        specialCrystalLabels = InputCheck["HandleSpecialLabels", crystalLabels
            ];
        overlapRadius = overlapRadius / GetLatticeParameters[hostCrystal,
             "Units" -> False][[{1, 2, 3}]];
        hostCopy = Lookup[$CrystalData, hostCrystal];
        atomDataHost = hostCopy["AtomData"];
        hostCoordinates = atomDataHost[[All, "FractionalCoordinates"]]
            ;
        (* Optional: Distort host structure *)
        If[OptionValue["DistortHost"] =!= None,
            optionsDS = FilterRules[{options}, Options @ DistortStructure
                ];
            optionsDS = Normal @ Append[Association @ optionsDS, {"DistortionType"
                 -> OptionValue["DistortionType"], "ReturnConverter" -> True}];
            hostDistorter = DistortStructure[hostCrystal, OptionValue[
                "DistortHost"], optionsDS];
            hostCoordinates = hostDistorter @ hostCoordinates;
            atomDataHost[[All, "FractionalCoordinates"]] = hostCoordinates
                ;
            hostCopy["AtomData"] = atomDataHost;
        ];
        hostStructureSize = hostCopy["Notes"]["StructureSize"];
        If[!ListQ @ hostStructureSize,
            hostStructureSize = {0, 0, 0}
        ];
        (*--- Preparing target positions ---*)
        If[matchHostSizeQ && hostStructureSize =!= {0, 0, 0},
            latticeTargetPositions = InputCheck["GenerateTargetPositions",
                 hostStructureSize];
            targetPositions = Flatten[Outer[Plus, latticeTargetPositions,
                 targetPositions, 1], 1];
            targetPositions = DeleteCases[targetPositions, {x_, y_, z_
                } /; Or @@ MapThread[Greater, {{x, y, z}, hostStructureSize}]];
(* If any negative coordinates, assume host is centred around origin 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    *)
            If[AnyTrue[Flatten @ hostCoordinates, # < -1.&],
                mid = \[LeftFloor]hostStructureSize / 2.\[RightFloor]
                    ;
                targetPositions = # - mid& /@ targetPositions
            ]
        ];
        If[OptionValue["DistortHost"] =!= None,
            targetPositions = hostDistorter @ targetPositions
        ];
        embedLength = Length @ targetPositions;
        (* Preparing list to be used *)
        guestUnits =
            Which[
                conditionFilterQ,
                    targetPositions /. Append[guestUnitsInput, {x_, y_,
                         z_} /; True -> "Void"]
                ,
                Head @ guestUnitsInput === Rule,
                    {probabilities, units} = {Keys @ #, Values @ #}& 
                        @ guestUnitsInput;
                    distributionList = Round[probabilities * embedLength
                        ];
                    Which[
                        Total @ distributionList < embedLength,
                            While[
                                Total @ distributionList < embedLength
                                    
                                ,
                                i = RandomInteger[{1, Length @ distributionList
                                    }];
                                distributionList[[i]] += 1
                            ]
                        ,
                        Total @ distributionList > embedLength,
                            While[
                                Total @ distributionList > embedLength
                                    
                                ,
                                i = RandomInteger[{1, Length @ distributionList
                                    }];
                                distributionList[[i]] -= 1
                            ]
                    ];
                    RandomSample @ Flatten @ MapThread[ConstantArray,
                         {units, distributionList}]
                ,
                True,
                    PadRight[#, embedLength, #]& @ guestUnitsInput
            ];
        guestCopies = $CrystalData /@ guestUnits;
        nonVoidRange = Complement[Range @ embedLength, Flatten @ Position[
            guestUnits, "Void"]];
        If[nonVoidRange === {},
            Goto["End"]
        ];
        latticeParameters = GetLatticeParameters[hostCrystal, "Units"
             -> False];
        latticeParametersABC = latticeParameters[[ ;; 3]];
        hostMetric = GetCrystalMetric[hostCrystal, "ToCartesian" -> True
            ];
        hostMetricInverse = Inverse @ hostMetric;
        targetPositionsCartesian = hostMetric . #& /@ targetPositions
            ;
(*--- Distortions and rotations -- Checks and preparations ---
    *)
        embeddingData = <|"GuestUnits" -> guestUnits, "TargetPositions"
             -> targetPositions|>;
        distortions = OptionValue["Distortions"];
        performShift = distortions =!= {0, 0, 0};
        If[performShift,
            distortions = ES$InterpretPermutations[distortions, embeddingData
                ]
        ];
        Which[
            OptionValue["DistortionType"] === "Crystallographic",
                Null
            ,
            OptionValue["DistortionType"] === "Cartesian",
                distortions = hostMetricInverse . #& /@ distortions
            ,
            True,
                Message[EmbedStructure::InvalidDistortionType];
                Abort[]
        ];
        rotations = OptionValue["Rotations"];
        performTwist = rotations =!= {0, 0, 0};
        If[performTwist,
            rotations = ES$InterpretPermutations[rotations, embeddingData
                ]
        ];
(*--- Actual transformation -- Loop through each guest unit ---
    *)
        R =
            If[performTwist,
                InputCheck["RotationTransformation", {{0, 0, 0}, {}},
                     {anchorShift, anchorReference, {}, rotationAxes}]
            ];
        completed = 0;
        If[TrueQ @ OptionValue["ShowProgress"],
            PrintTemporary[ProgressIndicator @ Dynamic[completed / embedLength
                ]]
        ];
        Do[
            M = GetCrystalMetric[guestUnits[[i]], "ToCartesian" -> True
                ];
            T = TranslationTransform[targetPositions[[i]]];
            coordinatesCrystal = guestCopies[[i, "AtomData", All, "FractionalCoordinates"
                ]];
            coordinatesCartesian = M . #& /@ coordinatesCrystal;
            coordinatesCrystalEmbedded = hostMetricInverse . #& /@ coordinatesCartesian
                ;
            coordinatesCrystalEmbeddedTranslated = T /@ coordinatesCrystalEmbedded
                ;
            newCoordinates = coordinatesCrystalEmbeddedTranslated;
            (* Optional: Perform shifts, twists or transformations *)
                
            If[performShift || performTwist,
                (* Optional: Rotations *)
                If[performTwist,
                    twist = R[rotations[[i]], targetPositionsCartesian
                        [[i]]];
                    newCoordinatesCartesian = hostMetric . #& /@ newCoordinates
                        ;
                    newCoordinatesCartesian = twist @ newCoordinatesCartesian
                        ;
                    newCoordinates = hostMetricInverse . #& /@ newCoordinatesCartesian
                        
                ];
                (* Optional: Distortions *)
                If[performShift,
                    shift = distortions[[i]];
                    newCoordinates = # + shift& /@ newCoordinates
                ]
            ];
            guestCopies[[i, "AtomData", All, "FractionalCoordinates"]]
                 = newCoordinates;
            completed++
            ,
            {i, nonVoidRange}
        ];
        (*--- Merge guest units with target crystal ---*)
        If[atomDataHost === {<||>},
            atomDataHost = {}
            ,
            atomDataHost = Append[#, "Component" -> "Host"]& /@ atomDataHost
                
        ];
        atomDataGuest = Flatten @ guestCopies[[nonVoidRange, "AtomData"
            ]];
        atomDataGuest = Append[#, "Component" -> "Guest"]& /@ atomDataGuest
            ;
        (* Optional: Remove overlapping target positions *)
        joinedAtomData =
            If[!MemberQ[{"Host", "Guest"}, overlapPrecedence],
                (* A. No measure taken against overlapping *)
                Join[atomDataHost, atomDataGuest]
                ,
                (* B. Remove superpositioned atoms *)
                findOverlap[point_, region_List] :=
                    (
                        If[region === {},
                            Return @ Nothing
                        ];
                        intervals = MapThread[Interval[{#1 - #2, #1 +
                             #2}]&, {point, overlapRadius}];
                        checks = MapThread[IntervalMemberQ[#1, #2]&, 
                            {intervals, Transpose @ region}];
                        checks = Position[And @@@ Transpose @ checks,
                             True];
                        If[checks =!= {},
                            Part[region, Flatten @ checks]
                            ,
                            Nothing
                        ]
                    );
                {atomData1, atomData2} =
                    If[overlapPrecedence === "Host",
                            #
                            ,
                            Reverse @ #
                        ]& @ {atomDataHost, atomDataGuest};
                {xyz1, xyz2} = Part[#, All, "FractionalCoordinates"]&
                     /@ {atomData1, atomData2};
                nearestList = Nearest[xyz2, #, 5]& /@ xyz1;
                overlappingCoordinates = Flatten[MapThread[findOverlap,
                     {xyz1, nearestList}], 1];
                atomData2 = DeleteCases[atomData2, x_ /; MemberQ[overlappingCoordinates,
                     x["FractionalCoordinates"]]];
                Join[atomData1, atomData2]
            ];
        (* Optional: Trim the outer boundary *)
        If[boundary =!= "None",
            Which[
                boundary === "Box",
                    joinedAtomData = DeleteCases[joinedAtomData, {x_,
                         y_, z_} /; Nand @@ MapThread[0 <= #1 < #2&, {{x, y, z}, hostStructureSize
                        }], {2}]
                ,
                boundary === "OuterEdges",
                    joinedAtomData = DeleteCases[joinedAtomData, {x_,
                         y_, z_} /; Nand @@ MapThread[0 <= #1 < #2&, {{x, y}, hostStructureSize
                        [[{1, 2}]]}], {2}]
            ];
            joinedAtomData = Select[joinedAtomData, KeyExistsQ[#, "FractionalCoordinates"
                ]&]
        ];
        joinedAtomData = MapAt[N @ Chop[#, 10. ^ -6]&, joinedAtomData,
             {All, "FractionalCoordinates"}];
        hostCopy["AtomData"] = joinedAtomData;
        (* Overwrite host or create new crystal object *)
        Label["End"];
        Which[
            newStructureLabel === "Void",
                newStructureLabel = "CustomStructure"
            ,
            hostCrystal === "Void" && newStructureLabel === "",
                newStructureLabel = "CustomStructure"
            ,
            newStructureLabel === "",
                newStructureLabel = hostCrystal
        ];
        $CrystalData = crystalDataOriginal;
        newSize = hostCopy["Notes", "StructureSize"] /. _Missing -> {
            1, 1, 1};
        newUnitCellAtomCount = \[LeftCeiling]Length @ joinedAtomData 
            / Times @@ newSize\[RightCeiling];
        If[!KeyExistsQ[hostCopy, "Notes"],
            AppendTo[hostCopy, "Notes" -> <||>]
        ];
        AppendTo[hostCopy["Notes"], "UnitCellAtomsCount" -> newUnitCellAtomCount
            ];
        AppendTo[hostCopy["Notes"], "AsymmetricUnitAtomsCount" -> Null
            ];
        AppendTo[hostCopy["Notes"], "StructureSize" -> newSize];
        InputCheck["Update$CrystalDataFile", dataFile, newStructureLabel,
             hostCopy];
        newStructureLabel
    ]

ES$InterpretPermutations[command_List, embeddingData_Association] :=
    Block[{UnfoldAmplitudes, guestUnits, targetPositions, length, amplitudes,
         rules},
        {guestUnits, targetPositions} = Lookup[embeddingData, {"GuestUnits",
             "TargetPositions"}];
        length = Length @ guestUnits;
        UnfoldAmplitudes[input_] :=
            Switch[Depth @ N @ input,
                1,
                    input
                ,
                2,
                    Hold @ RandomReal @ input
                ,
                3,
                    Hold @ RandomChoice @ Flatten @ input
            ];
        amplitudes =
            If[MemberQ[Head /@ command, Rule],
                If[Head @ command[[1, 1]] === String,
                    (* a. Label-based rules *)
                    rules = Append[command, _String -> {0., 0., 0.}];
                        
                    Map[UnfoldAmplitudes, guestUnits /. rules, {2}]
                    ,
                    (* b. Condition-based rules *)
                    rules = Append[command, {x_, y_, z_} /; True -> {
                        0., 0., 0.}];
                    rules = MapAt[UnfoldAmplitudes, rules, {All, 2, All
                        }];
                    targetPositions /. rules
                ]
                ,
                (* c. Single, non-conditional based input *)
                ConstantArray[UnfoldAmplitudes /@ command, length]
            ];
        amplitudes = N @ ReleaseHold @ amplitudes;
        If[MatchQ[Dimensions @ amplitudes, {length, 3}] \[Nand] ContainsOnly[
            Depth /@ amplitudes, {2}],
            Message[EmbedStructure::InvalidPermutation];
            Abort[]
        ];
        amplitudes
    ]

End[];
