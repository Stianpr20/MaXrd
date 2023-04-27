SystematicAbsentQ::InvalidSpaceGroup = "Invalid space group: \[LeftGuillemet]`1`\[RightGuillemet].";

SyntaxInformation @ SystematicAbsentQ = {"ArgumentsPattern" -> {_, _}, "UseCentring" -> False};

Begin["`Private`"];

DetermineWyckoffLetters[specialPositionData_, coordinatesInput_, centering_ : {{0, 0, 0}}] :=
    Block[{length = Length @ specialPositionData, coordinates = coordinatesInput, letters, i, j, xyz, listedCoordinates, substituted},
        coordinates = InputCheck["RecognizeFractions", coordinates];
        letters = {};
        Do[
            i = 1;
            While[
                i <= Length @ specialPositionData
                ,
                listedCoordinates = specialPositionData[[-i, "Coordinates"]];
                substituted = listedCoordinates /. {"x" -> #1, "y" -> #2, "z" -> #3}& @@ xyz;
                If[TrueQ @ OptionValue["UseCentring"],
                    substituted = Flatten[FractionalPart @ Table[substituted[[m]] + centering[[n]], {m, Length @ substituted}, {n, Length @ centering}], 1]
                ];
                If[Or @@ (xyz == #& /@ substituted),
                    AppendTo[letters, FromLetterNumber @ i];
                    Break[]
                ];
                i++;
                If[i === length,
                    (* No need to check if position is general *)
                    AppendTo[letters, FromLetterNumber @ i];
                    Break[]
                ]
            ]
            ,
            {xyz, coordinates}
        ];
        letters
    ]

MakeReflectionValidator[symmetryEntity_] :=
    Module[{crystalQ, coordinates, centeringVectors, spaceGroup = symmetryEntity, validateReflectionFactory, specialPositionData, wyckoffLetters = {}, dataSection, reflectionConditions, conditionForms, matchingFormFiltered},
        crystalQ = InputCheck["CrystalQ", symmetryEntity, True] =!= <||>;
        If[crystalQ,
            spaceGroup = InputCheck["CrystalQ", symmetryEntity]["SpaceGroup"]
        ];
        spaceGroup = InputCheck["InterpretSpaceGroup", spaceGroup];
        specialPositionData = $GroupSymbolRedirect[spaceGroup]["SpecialPositions"];
        If[MissingQ @ specialPositionData,
            specialPositionData = GetSymmetryData[spaceGroup, "UseMainEntry" -> True]["SpecialPositions"]
        ];
        If[crystalQ,
            coordinates = $CrystalData[[symmetryEntity, "AtomData", All, "FractionalCoordinates"]];
            centeringVectors = InputCheck["GetCentringVectors", spaceGroup];
            wyckoffLetters = DetermineWyckoffLetters[specialPositionData, coordinates, centeringVectors]
        ];
        AppendTo[
            wyckoffLetters
            , (* Always include general conditions *)
            FromLetterNumber @ Length @ specialPositionData
        ];
        wyckoffLetters = DeleteDuplicates @ wyckoffLetters;
        dataSection = Select[specialPositionData, (Or @@ Thread[#WyckoffLetter == wyckoffLetters])&];
        reflectionConditions = ToExpression /@ Flatten[Lookup[dataSection, "ReflectionConditions", {}]];
        If[reflectionConditions === {},
            validateReflectionFactory[hkl_] := True;
            Return @ validateReflectionFactory
        ];
        conditionForms = reflectionConditions[[All, 1]];
        validateReflectionFactory[hkl_] :=
            (
                matchingFormFiltered = Pick[reflectionConditions, MatchQ[hkl, #]& /@ conditionForms];
                And @@ (MatchQ[hkl, #]& /@ matchingFormFiltered)
            );
        (* Return factory method *)
        validateReflectionFactory
    ]

SystematicAbsentQ[symmetryEntity_, reflectionInput_List] :=
    Block[{reflections, Validator, absentQ},
        InputCheck[reflectionInput, "Integer"];
        reflections = InputCheck[reflectionInput, "WrapSingle"];
        Validator = MakeReflectionValidator @ symmetryEntity;
        absentQ = Not /@ Validator /@ reflections;
        If[MatchQ[reflectionInput, {_Integer, _Integer, _Integer}],
            absentQ = absentQ[[1]]
        ];
        absentQ
    ]

End[];
