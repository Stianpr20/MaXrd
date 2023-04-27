ExportCrystalData::InvalidProgramOrFormat = "\[LeftGuillemet]`1`\[RightGuillemet] is not a valid program/format.";

ExportCrystalData::ParameterError = "Invalid input parameters.";

ExportCrystalData::DirectoryExpected = "An existing output directory was expected.";

ExportCrystalData::InvalidSubtractionMode = "\[LeftGuillemet]`1`\[RightGuillemet] is not a valid scattering subtraction mode.";

ExportCrystalData::InvalidImageDimensions = "Image dimensions must be two positive integers.";

Options @ ExportCrystalData = {"Detailed" -> False, "IncludeStructureSizeInfo" -> True};

SyntaxInformation @ ExportCrystalData = {"ArgumentsPattern" -> {_, _, _, _., _., OptionsPattern[]}};

Begin["`Private`"];

ExportCrystalData["DISCUS", crystal_String, outputFile_String, OptionsPattern[]] :=
    Block[
        {crystalData, atomData, size, unitCellAtomCount, latticeParameters, formatter, appendComma, simpleQ, preambleTitle, preambleSpaceGroup, preambleCell, preambleCount, preambleAtomsHeader, preamble, elements, coordinates, displacementParameters, items, spacesToUse, additional, makeSpace, atoms}
        ,
        (* Loading necessary data *)
        {crystalData, atomData, size, latticeParameters} = ECD$LoadNecessaries @ crystal;
        unitCellAtomCount = Lookup[crystalData["Notes"], "UnitCellAtomsCount", Round[Length[atomData] / Times @@ size]];
        (* Auxiliary *)
        formatter[x_] := ToString @ NumberForm[N @ Chop[x, Power[10., -5]], {9, 6}];
        appendComma[x_] := Map[StringInsert[#, ",", -1]&, x, {1}];
        simpleQ = !TrueQ @ OptionValue["Detailed"];
        latticeParameters =
            If[simpleQ,
                ToString /@ N @ latticeParameters
                ,
                Map[formatter, latticeParameters, {1}]
            ];
        (* Creating the preamble *)
        preambleTitle = {"title  ", crystal};
        preambleSpaceGroup = {"spcgr  ", StringDelete[$GroupSymbolRedirect[crystalData["SpaceGroup"]]["Name", "HermannMauguinShort"], " "]};
        preambleCell = {"cell   ", StringJoin @ Riffle[latticeParameters, "  "]};
        preambleCount = {"ncell  ", StringJoin @ Riffle[ToString /@ Join[size, {unitCellAtomCount}], ",  "]};
        preambleAtomsHeader =
            If[simpleQ,
                {"atoms\n"}
                ,
                {"atoms      x,              y,              z,             Biso,    Property,  MoleNo,  MoleAt,   Occ\n"}
            ];
        preamble =
            StringJoin @
                Riffle[
                    {
                        preambleTitle
                        ,
                        preambleSpaceGroup
                        ,
                        preambleCell
                        ,
                        If[TrueQ @ OptionValue["IncludeStructureSizeInfo"],
                            preambleCount
                            ,
                            Nothing
                        ]
                        ,
                        preambleAtomsHeader
                    }
                    ,
                    {"\n"}
                ];
        (* Extracting atom data *)
        elements = ToUpperCase @ Lookup[atomData, "Element"];
        elements = StringDelete[elements, {"+", "-", DigitCharacter}];
        coordinates = N @ Lookup[atomData, "FractionalCoordinates"];
        coordinates = Map[formatter, coordinates, {2}];
        If[!simpleQ,
            coordinates = appendComma @ coordinates
        ];
        displacementParameters = TransformAtomicDisplacementParameters[crystal, "EquivalentIsotropic"] /. _Missing -> 0.;
        displacementParameters = formatter /@ displacementParameters;
        If[!simpleQ,
            displacementParameters = appendComma @ displacementParameters
        ];
        items = {elements, Sequence @@ Transpose @ coordinates, displacementParameters};
        (* Determining spacing information *)
        spacesToUse = Transpose @ ConstantArray[{11, 16, 16, 15, 8}, Length @ atomData];
        additional = "1,       0,       0,   1.000000";
        Do[spacesToUse[[i]] = spacesToUse[[i]] - (StringLength /@ items[[i]]), {i, Length @ items - 1}];
        spacesToUse = Transpose @ spacesToUse;
        makeSpace[i_, j_] := ConstantArray[" ", spacesToUse[[i, j]]];
        (* Writing atom data *)
        atoms = Reap[
                Do[
                    Sow[
                        {
                            elements[[i]]
                            ,
                            makeSpace[i, 1]
                            ,
                            coordinates[[i, 1]]
                            ,
                            makeSpace[i, 2]
                            ,
                            coordinates[[i, 2]]
                            ,
                            makeSpace[i, 3]
                            ,
                            coordinates[[i, 3]]
                            ,
                            makeSpace[i, 4]
                            ,
                            displacementParameters[[i]]
                            ,
                            makeSpace[i, 5]
                            ,
                            If[simpleQ,
                                ""
                                ,
                                additional
                            ]
                            ,
                            "\n"
                        }
                    ]
                    ,
                    {i, Length @ atomData}
                ]
            ][[2, 1]];
        (* Prepare output and export *)
        Export[outputFile, StringJoin[preamble, atoms], "String"]
    ]

ExportCrystalData["DIFFUSE", crystal_String, outputDir_String, hklPlane_, indexLimit_, subtractionMode_String, {width_Integer, height_Integer}, OptionsPattern[]] :=
    Block[
        {reorganise, source, scatteringFactorTemplate, crystalData, atomData, allElements, size, latticeParameters, directionCosines, M, partA, X, Y, Z, unitCells, MakeSitesTable, table, sitesList, partB, maxPossibleSites, newAtomData, blockLengths, headerComments, headerData, padWidth, header, scatteringData}
        ,
        (* Checks *)
        InputCheck["CrystalQ", crystal];
        If[!DirectoryQ @ outputDir,
            Message[ExportCrystalData::DirectoryExpected];
            Abort[]
        ];
        If[!MemberQ[{"N", "Y", "E", "e"}, subtractionMode],
            Message[ExportCrystalData::InvalidSubtractionMode, subtractionMode];
            Abort[]
        ];
        If[!AllTrue[{width, height}, Positive],
            Message[ExportCrystalData::InvalidImageDimensions];
            Abort[]
        ];
        (* Auxiliary *)
        reorganise[data_Association] :=
            With[{xyz = data["FractionalCoordinates"]},
                {Min /@ Transpose[{IntegerPart @ xyz + 1, size}], StringJoin["   ", StringPadRight[ToString @ DecimalForm[#, {11, 5}]& /@ Mod[xyz, 1], 11], StringDelete[data["Element"], {DigitCharacter, "+", "-"}]]}
            ];
        MakeSitesTable[stop_Integer] :=
            (
                table =
                    Table[
                        {
                            i
                            ,
                            If[i > stop,
                                0
                                ,
                                i
                            ]
                        }
                        ,
                        {i, maxPossibleSites}
                    ];
                table = Map[ToString, table, {2}];
                table = StringPadLeft[#, 6]& /@ table;
                StringJoin /@ table
            );
        source = Import @ FileNameJoin[{$MaXrdPath, "Kernel", "Data", "AtomicScatteringFactor", "InternationalTablesC(3rd).m"}];
        scatteringFactorTemplate[element_] := StringTemplate["'`X`'
`a1`,`b1`,`a2`,`b2`
`a3`,`b3`,`a4`,`b4`,`c`
0.0,0.0"] @ Join[source[element], <|"X" -> element|>];
        (* Loading necessary data *)
        {crystalData, atomData, size, latticeParameters} = ECD$LoadNecessaries @ crystal;
        allElements = DeleteDuplicates @ atomData[[All, "Element"]];
        allElements = DeleteDuplicates[StringDelete[#, {DigitCharacter, "+", "-"}]& /@ allElements];
        directionCosines = ToString @ DecimalForm[Cos[# * Degree], {6, 5}]& /@ N @ latticeParameters[[4 ;; 6]];
        M = GetCrystalMetric[crystal, "ToCartesian" -> True];
        (* File 1: Crystal data in 'DIFFUSE' format *)
        (* Part B *)
        newAtomData = reorganise /@ atomData;
        newAtomData = DeleteDuplicates /@ GatherBy[newAtomData, #[[1]]&];
        blockLengths = Length /@ newAtomData;
        maxPossibleSites = Max @ blockLengths;
        partB = Flatten @ Riffle[StringTemplate[" `1` `2` `3`"] @@@ newAtomData[[All, 1, 1]], newAtomData[[All, All, 2]]];
        (* Part A *)
        sitesList = MakeSitesTable /@ blockLengths;
        {X, Y, Z} = size;
        unitCells = Flatten[Table[StringTemplate[" `1` `2` `3`"][x, y, z], {x, 1, X}, {y, 1, Y}, {z, 1, Z}], 2];
        partA = Flatten @ Transpose[{unitCells, sitesList}];
        PrependTo[partA, StringTemplate[" `X` `Y` `Z` `N1` `N1`"] @ <|"X" -> X, "Y" -> Y, "Z" -> Z, "N1" -> maxPossibleSites|>];
        (* File 2: Input/summary file *)
        headerComments = {"Header or structure label", "Random number seeds", "Cell coord's; angles are cos(ang)", "Size of crystal simulation (unit cells)", "Periodic Boundary?", "Origin of volume", "u-axis (bottom right) and image x-dimension", "v-axis (top left) and image y-dimension", "w-axis (top right) and image z-dimension", "sin(theta)/lambda maximum", "Lot size", "Number of lots", "Number of atom sites per cell", "Number of different atom types (list of sc.coef's below)", "Subtract average lattice? ('N', 'e', 'E' or 'Y')"};
        headerData = {crystal, "12645, 9676", StringTemplate["`1` `2` `3`  `4` `5` `6`"] @@ Join[latticeParameters[[1 ;; 3]], directionCosines], StringTemplate["`1` `2` `3`"] @@ size, "Y", Sequence @@ InputCheck["GetReciprocalImageOrientation", crystal, hklPlane, indexLimit, {width, height}, True], "3.0", StringTemplate["`1` `2` `3`"] @@ size, "1", ToString @ maxPossibleSites, ToString @ Length @ allElements, subtractionMode};
        padWidth = Max[StringLength /@ headerData] + 3;
        headerData = StringPadRight[headerData, padWidth];
        header = Transpose @ {headerData, "! " <> #& /@ headerComments};
        scatteringData = scatteringFactorTemplate /@ allElements;
        (* Prepare output and export *)
        {Export[FileNameJoin[{outputDir, "diffuse_input1_crystal.txt"}], Join[partA, partB, {"\n"}], "Table"], Export[FileNameJoin[{outputDir, "diffuse_input2_setup.txt"}], Join[header, scatteringData, {"\n"}], "Table"]}
    ]

ECD$LoadNecessaries[crystal_String] :=
    Block[{crystalData, atomData, crystalNotes, size, latticeParameters},
        InputCheck["CrystalQ", crystal];
        crystalData = $CrystalData[crystal];
        atomData = N @ crystalData["AtomData"];
        crystalNotes = Lookup[crystalData, "Notes", <||>];
        If[!AssociationQ @ crystalNotes,
            crystalNotes = <||>
        ];
        size = Lookup[crystalNotes, "StructureSize", Round /@ Max /@ Transpose @ atomData[[All, "FractionalCoordinates"]]] /. {0 -> 1};
        latticeParameters = GetLatticeParameters[crystal, "Units" -> False];
        {crystalData, atomData, size, latticeParameters}
    ]

ExportCrystalData[invalidProgram_String, rest___] :=
    (
        If[!MemberQ[{"DISCUS", "DIFFUSE"}, invalidProgram],
            Message[ExportCrystalData::InvalidProgramOrFormat, invalidProgram]
            ,
            Message[ExportCrystalData::ParameterError]
        ];
        Abort[]
    )

End[];
