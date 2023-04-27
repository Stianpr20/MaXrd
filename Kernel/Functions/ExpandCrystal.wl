ExpandCrystal::InvalidSize = "The structure size must be a list of three natural numbers.";

ExpandCrystal::DuplicateLabel = "The new label must be different from the input.";

ExpandCrystal::InvalidExpansionSetting = "Expansion setting \[LeftGuillemet]`1`\[RightGuillemet] not recognised.";

Options @ ExpandCrystal = {"DataFile" -> FileNameJoin[{$MaXrdPath, "Kernel", "Data", "UserData", "CrystalData.m"}], "ExpandIntoNegative" -> False, "FirstTransformTo" -> False, "IgnoreSymmetry" -> False, "IncludeBoundary" -> True, "NewLabel" -> "", "StoreTemporarily" -> False, "StructureSize" -> {1, 1, 1}};

SyntaxInformation @ ExpandCrystal = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

Begin["`Private`"];

ExpandCrystal[crystal_String, OptionsPattern[]] :=
    Block[
        {structureSize = OptionValue["StructureSize"], crystalDataOriginal = $CrystalData, dataFile = OptionValue["DataFile"], newLabel = OptionValue["NewLabel"], changeCell = OptionValue["FirstTransformTo"], storeTempQ = TrueQ @ OptionValue["StoreTemporarily"], ignoreSymmetryQ = TrueQ @ OptionValue["IgnoreSymmetry"], expansionSetting = OptionValue["ExpandIntoNegative"], crystalData, crystalCopy, atomData, coordinates, spaceGroup, generated, copyTranslations, mid, atomDataMapUnitCell, cutoffFunction, atomDataMapExpanded, lengths, newAtomData}
        ,
        (* Input check and data acquisition *)
        If[AllTrue[structureSize, Positive[#] && IntegerQ[#]&] \[Nand] Length[structureSize] === 3,
            Message[ExpandCrystal::InvalidSize];
            Abort[]
        ];
        InputCheck["CrystalQ", crystal];
        crystalData = crystalCopy = $CrystalData[crystal];
        If[crystal === newLabel,
            Message[ExpandCrystal::DuplicateLabel, newLabel];
            Abort[]
        ];
        If[newLabel === "",
            newLabel = crystal <> "_" <> (StringJoin @ Riffle[ToString /@ structureSize, "x"])
        ];
        (* Optional: Transform cell beforehand *)
        If[changeCell =!= False,
            InputCheck["InterpretSpaceGroup", changeCell];
            AssociateTo[$CrystalData, newLabel -> crystalCopy];
            UnitCellTransformation[newLabel, changeCell];
            crystalData = crystalCopy = $CrystalData[newLabel]
        ];
        (* Expand asymmetric unit to unit cell *)
        atomData = crystalData["AtomData"];
        coordinates = atomData[[All, "FractionalCoordinates"]];
        spaceGroup = crystalData["SpaceGroup"];
        (* Optional: Ignore symmetry and simply copy content as is *)
        generated =
            N @
                If[ignoreSymmetryQ,
                    Partition[coordinates, 1]
                    ,
                    SymmetryEquivalentPositions[spaceGroup, #]& /@ coordinates
                ];
        (* Generate full content of the unit cell *)
        atomDataMapUnitCell = Association @ Thread[Range @ Length @ atomData -> generated];
        (* Copy by translation *)
        copyTranslations = InputCheck["GenerateTargetPositions", structureSize + 1];
        atomDataMapExpanded = Flatten[Outer[Plus, copyTranslations, #, 1], 1]& /@ atomDataMapUnitCell;
        (* Optional: Complete the outer boundary *)
        cutoffFunction =
            If[TrueQ @ OptionValue["IncludeBoundary"],
                Greater
                ,
                GreaterEqual
            ];
        (* Delete atoms whose coordinates are outside *)
        atomDataMapExpanded = DeleteCases[atomDataMapExpanded, {x_, y_, z_} /; Or @@ MapThread[cutoffFunction, {{x, y, z}, structureSize}], {2}];
        (* Optional: Center translations around origin *)
        If[expansionSetting =!= False,
            mid =
                Switch[expansionSetting,
                    True,
                        \[LeftFloor]structureSize / 2.\[RightFloor]
                    ,
                    "PlanarOnly",
                        Join[\[LeftFloor]{#1, #2} / 2.\[RightFloor], {0}]& @@ structureSize
                    ,
                    _,
                        Message[ExpandCrystal::InvalidExpansionSetting, expansionSetting];
                        {}
                ];
            If[mid =!= {},
                atomDataMapExpanded = Map[# - mid&, atomDataMapExpanded, {2}]
            ]
        ];
        (* Create new atom data structure *)
        lengths = Values[Length /@ atomDataMapExpanded];
        newAtomData = Table[ConstantArray[atomData[[i]], lengths[[i]]], {i, Length @ atomData}];
        newAtomData[[All, All, "FractionalCoordinates"]] = Values @ atomDataMapExpanded;
        newAtomData = Flatten[newAtomData, 1];
        (* Create new crystal entry *)
        crystalCopy["AtomData"] = newAtomData;
        AssociateTo[crystalCopy, "Notes" -> <|"StructureSize" -> structureSize, "UnitCellAtomsCount" -> Total[Length /@ generated], "AsymmetricUnitAtomsCount" -> Length @ atomDataMapUnitCell|>];
        (* If temporary storage was used, reset pointer to original $CrystalData *)
        If[storeTempQ,
            StianRamsnes`MaXrd`Private`$TempCrystalData = <|newLabel -> crystalCopy|>;
            $CrystalData = crystalDataOriginal;
            InputCheck["Update$CrystalDataAutoCompletion"]
            ,
            InputCheck["Update$CrystalDataFile", dataFile, newLabel, crystalCopy]
        ];
        newLabel
    ]

ExpandCrystal[crystal_String, structureSize_List, options : OptionsPattern[]] :=
    ExpandCrystal[crystal, Options[{"StructureSize" -> structureSize, options}]]

End[];
