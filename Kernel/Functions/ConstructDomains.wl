ConstructDomains::SectorRegionsInvalidNumberOfPairs = "The number of pairs must be a natural number.";

ConstructDomains::SectorRegionsInvalidWidth = "Angular width of the sectors must be a number";

ConstructDomains::CompleteDomination = "A domain has reached complete domination after `1` cycles.";

Options @ ConstructDomains = {"ReturnAllCycles" -> False, "ShowProgress"
     -> False, "TransitionProbabilities" -> <|0 -> 0.95, 1 -> 0.92, 2 -> 
    0.86, 3 -> 0.75, 4 -> 0.40, 5 -> 0.50, 6 -> 0.75, 7 -> 0.12, 8 -> 0.03
    |>};

SyntaxInformation @ ConstructDomains = {"ArgumentsPattern" -> {_, _, 
    _, OptionsPattern[]}};

Begin["`Private`"];

ConstructDomains[{sizeA_Integer, sizeB_Integer, sizeC_Integer}, numberOfDomains_Integer,
     numberOfCycles_Integer, OptionsPattern[]] :=
    Block[{structureSize = sizeA * sizeB * sizeC, insertionCoordinates,
         domainTable, cyclesPassed = 0, transitionProbabilities = OptionValue[
        "TransitionProbabilities"], visitOrderInCurrentCycle, currentCellIndex,
         currentCell, nearest, nearestFiltered, neighbourDomains, numberOfDomainsEqualToSelf,
         completeSeries, storeAllCyclesQ = TrueQ @ OptionValue["ReturnAllCycles"
        ]},
        insertionCoordinates = InputCheck["GenerateTargetPositions", 
            {sizeA, sizeB, sizeC}];
        domainTable = Association @ Thread[insertionCoordinates -> RandomSample[
            Flatten @ ConstantArray[Range @ numberOfDomains, \[LeftCeiling]structureSize
             / numberOfDomains\[RightCeiling]], structureSize]];
        If[TrueQ @ OptionValue["ShowProgress"],
            PrintTemporary[Row[{ProgressIndicator @ Dynamic[cyclesPassed
                 / numberOfCycles]}]]
        ];
        completeSeries =
            Reap @
                Catch @
                    Do[
                        visitOrderInCurrentCycle = RandomSample @ Range
                             @ structureSize;
                        Do[
                            currentCellIndex = visitOrderInCurrentCycle
                                [[i]];
                            currentCell = insertionCoordinates[[currentCellIndex
                                ]];
                            nearest = Nearest[insertionCoordinates, currentCell,
                                 26];
                            nearestFiltered = Select[Delete[nearest, 
                                1], SquaredEuclideanDistance[currentCell, #] <= 3.&];
                            neighbourDomains = Lookup[domainTable, nearestFiltered,
                                 0.];
                            numberOfDomainsEqualToSelf = Count[neighbourDomains,
                                 domainTable[currentCell]];
                            If[RandomReal[] < transitionProbabilities[
                                numberOfDomainsEqualToSelf],
                                domainTable[currentCell] = RandomChoice
                                     @ neighbourDomains
                            ]
                            ,
                            {i, structureSize}
                        ];
                        If[storeAllCyclesQ,
                            Sow @ Values @ domainTable
                        ];
                        If[AllTrue[Values @ domainTable, # === First 
                            @ domainTable&],
                            Message[ConstructDomains::CompleteDomination,
                                 cyclesPassed + 1];
                            Throw @ domainTable
                        ];
                        cyclesPassed++
                        ,
                        numberOfCycles
                    ];
        (* Express domain table as '{outputSize, {domains}}' *)
        If[storeAllCyclesQ,
            {{sizeA, sizeB, sizeC}, completeSeries[[2, 1]]}
            ,
            {{sizeA, sizeB, sizeC}, Values @ domainTable}
        ]
    ];

ConstructDomains["SectorRegions", {sizeA_Integer, sizeB_Integer, sizeC_Integer
    }, regionSettings_List, OptionsPattern[]] :=
    Block[
        {insertionCoordinates, identifiers, regions, MakeSectorRegion,
             angleStarts, oppositeStarts, allStarts, angleRanges, disks, FindMatch,
             n}
        ,
        (* Input checks *)
        If[!AllTrue[regionSettings[[All, 1]], IntegerQ[#] && Positive[
            #]&],
            Message[ConstructDomains::SectorRegionsInvalidNumberOfPairs
                ];
            Abort[]
        ];
        If[!AllTrue[regionSettings[[All, 2]], NumericQ],
            Message[ConstructDomains::SectorRegionsInvalidNumberOfPairs
                ];
            Abort[]
        ];
        (* Auxiliary functions *)
        MakeSectorRegion[numberOfPairs_Integer, width_?NumericQ, startAngle_
            :Null] :=
            (
                If[NumericQ @ startAngle,
                    angleStarts = Table[a, {a, startAngle, 2. * \[Pi],
                         2. * \[Pi] / (numberOfPairs * 2)}]
                    ,
                    angleStarts = RandomReal[{0., 2. * \[Pi]}, numberOfPairs
                        ]
                ];
                oppositeStarts = angleStarts + \[Pi];
                allStarts = Join[angleStarts, oppositeStarts];
                angleRanges = {#, # + width}& /@ allStarts;
                disks = Disk[{sizeA / 2, sizeB / 2}, sizeA, #]& /@ angleRanges
                    ;
                RegionUnion @@ disks
            );
        FindMatch[{x_, y_, z_}] :=
            (
                n =
                    Do[
                        If[RegionMember[regions[[i]], {x, y}],
                            Return @ i
                        ]
                        ,
                        {i, Length @ regions}
                    ];
                {x, y, z} -> n
            );
        (* Main procedure *)
        insertionCoordinates = Flatten[Table[{i, j, 0}, {i, 0, sizeA 
            - 1}, {j, 0, sizeB - 1}], 1];
        regions = MakeSectorRegion @@@ regionSettings;
        insertionCoordinates = (FindMatch /@ insertionCoordinates) /.
             {Null -> Length @ regions + 1};
        identifiers = Values @ insertionCoordinates;
        If[sizeC > 1,
            identifiers = Flatten @ Transpose @ ConstantArray[identifiers,
                 sizeC]
        ];
        (* Express domain table as '{outputSize, {domains}}' *)
        {{sizeA, sizeB, sizeC}, identifiers}
    ];

End[];
