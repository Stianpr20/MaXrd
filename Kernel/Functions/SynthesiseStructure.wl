SynthesiseStructure::SizeError = "Size discrepancy in domain input.";

SynthesiseStructure::DifferentBlockSizes = "The blocks must have the same size.";

SynthesiseStructure::InvalidOutputSize = "Output size must be a list of three positive integers.";

SynthesiseStructure::IncompatibleOutputSize = "Output size must be compatible with block sizes.";

SynthesiseStructure::InvalidSelectionMethod = "\[LeftGuillemet]`1`\[RightGuillemet] is not a valid selection method.";

SynthesiseStructure::ExpectedSpecialLabel = "Chemical element or \"Void\" expected; got \[LeftGuillemet]`1`\[RightGuillemet] instead.";

SynthesiseStructure::InvalidLatticeParameters = "Lattice parameters should be a list of six numbers.";

SynthesiseStructure::NothingToBuild = "No units in construction list.";

Options @ SynthesiseStructure = {"Padding" -> False, "RotationAnchorReference" -> "DomainCentroid", "RotationAnchorShift" -> {0, 0, 0}, "RotationAxes" -> IdentityMatrix[3], "RotationMap" -> <||>, "SelectionMethod" -> "Sequential"};

SyntaxInformation @ SynthesiseStructure = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

Begin["`Private`"];

SynthesiseStructure[blocks_List, {sizeA_Integer, sizeB_Integer, sizeC_Integer}, outputName_String, OptionsPattern[]] :=
    Block[
        {selectionMethod = OptionValue["SelectionMethod"], domains, mapping, options}
        ,
        (* Checking input *)
        Check[Scan[InputCheck["CrystalEntityQ", #]&, DeleteDuplicates @ blocks], Abort[]];
        (* Preparing domain representation *)
        domains =
            Which[
                    selectionMethod === "Random",
                        RandomChoice[blocks, sizeA * sizeB * sizeC]
                    ,
                    selectionMethod === "Sequential",
                        #
                    ,
                    selectionMethod === "Shuffled",
                        RandomSample @ #
                    ,
                    True,
                        Message[SynthesiseStructure::InvalidSelectionMethod, selectionMethod];
                        Abort[]
                ]& @ PadRight[{}, sizeA * sizeB * sizeC, blocks];
        mapping = AssociationThread[Range @ Length @ blocks -> blocks];
        (* Relaying data to separate procedure *)
        options = Thread[# -> OptionValue[#], String]& /@ (First /@ Options @ SynthesiseStructure);
        SynthesiseStructure[{{sizeA, sizeB, sizeC}, domains}, outputName, mapping, Sequence @@ options]
    ]

SynthesiseStructure[{{inputA_Integer, inputB_Integer, inputC_Integer}, inputDomains_List}, outputName_String, integerToLabelMap_Association : <||>, OptionsPattern[]] :=
    Block[
        {domains = inputDomains, sizeA = inputA, sizeB = inputB, sizeC = inputC, blocks, nonVoidRange, normalBlocks, blockSizes, outputSize, targetPositions, blockPositionsMap, blockCopy, blockCopies, representativeCellDimensions, coordinatesCrystal, coordinatesCartesian, coordinatesCrystalEmbedded, newCoordinates, hostMetric, hostMetricInverse, targetPositionsCartesian, M, T, anchorShift = OptionValue["RotationAnchorShift"], anchorReference = OptionValue["RotationAnchorReference"], rotationAxes = OptionValue["RotationAxes"], rotationMap = OptionValue["RotationMap"], R, twist}
        ,
        (* Checking input *)
        If[TrueQ @ OptionValue["Padding"],
            {{sizeA, sizeB, sizeC}, domains} = InputCheck["PadDomain", {{sizeA, sizeB, sizeC}, inputDomains}]
        ];
        blocks = domains /. Join[{0 -> "Void"}, Normal @ integerToLabelMap];
        blocks = blocks /. _Integer -> "Void";
        Check[Scan[InputCheck["CrystalEntityQ", #]&, DeleteDuplicates @ blocks], Abort[]];
        (* Handling special labels (chemical elements or void) *)
        InputCheck["HandleSpecialLabels", blocks];
        nonVoidRange = Complement[Range[sizeA * sizeB * sizeC], Flatten @ Position[blocks, "Void"]];
        normalBlocks = Part[blocks, nonVoidRange];
        If[normalBlocks === {},
            Message[SynthesiseStructure::NothingToBuild];
            Abort[]
        ];
        (* Checking if all blocks have same size *)
        blockSizes = ($CrystalData[#, "Notes", "StructureSize"] /. _Missing -> {1, 1, 1})& /@ blocks;
        If[!SameQ @@ blockSizes,
            Message[SynthesiseStructure::DifferentBlockSizes];
            Abort[]
        ];
        blockSizes = First @ blockSizes;
        (* Checking if output size is valid *)
        outputSize = {sizeA, sizeB, sizeC};
        If[sizeA * sizeB * sizeC != Length @ domains,
            Message[SynthesiseStructure::SizeError];
            Abort[]
        ];
        If[(Length @ outputSize != 3) || (AnyTrue[outputSize, Positive[#] \[Nand] IntegerQ[#]&]),
            Message[SynthesiseStructure::InvalidOutputSize];
            Abort[]
        ];
        If[Total @ MapThread[Mod, {outputSize, blockSizes}] =!= 0,
            Message[SynthesiseStructure::IncompatibleOutputSize];
            Abort[]
        ];
        (* Final preparations before synthesis *)
        targetPositions = InputCheck["GenerateTargetPositions", outputSize];
        blockPositionsMap = AssociationThread[targetPositions -> blocks];
        AppendTo[$CrystalData, outputName -> $CrystalData @ First @ normalBlocks];
        hostMetric = GetCrystalMetric[outputName, "ToCartesian" -> True];
        hostMetricInverse = Inverse @ hostMetric;
        targetPositionsCartesian = hostMetric . #& /@ targetPositions;
        representativeCellDimensions = GetLatticeParameters[First @ blocks][[ ;; 3]];
        If[rotationMap =!= <||>,
            R = InputCheck["RotationTransformation", {outputSize, domains}, {anchorShift, anchorReference, rotationMap, rotationAxes}, representativeCellDimensions, True]
        ];
        blockCopies = Reap[
                Do[
                    M = GetCrystalMetric[blocks[[i]], "ToCartesian" -> True];
                    T = TranslationTransform[targetPositions[[i]]];
                    blockCopy = $CrystalData[blocks[[i]]];
                    coordinatesCrystal = blockCopy[["AtomData", All, "FractionalCoordinates"]];
                    coordinatesCartesian = M . #& /@ coordinatesCrystal;
                    coordinatesCrystalEmbedded = hostMetricInverse . #& /@ coordinatesCartesian;
                    newCoordinates = T /@ coordinatesCrystalEmbedded;
                    If[rotationMap =!= <||>,
                        twist = R[domains[[i]], targetPositionsCartesian[[i]]];
                        coordinatesCartesian = hostMetric . #& /@ newCoordinates;
                        coordinatesCartesian = twist @ coordinatesCartesian;
                        newCoordinates = hostMetricInverse . #& /@ coordinatesCartesian
                    ];
                    blockCopy[["AtomData", All, "FractionalCoordinates"]] = newCoordinates;
                    Sow @ blockCopy
                    ,
                    {i, nonVoidRange}
                ]
            ][[2, 1]];
        $CrystalData[outputName, "AtomData"] = Flatten @ blockCopies[[All, "AtomData"]];
        If[!KeyExistsQ[$CrystalData[outputName], "Notes"],
            AppendTo[$CrystalData[outputName], "Notes" -> <||>]
        ];
        $CrystalData[outputName, "Notes", "StructureSize"] = outputSize;
        outputName
    ]

SynthesiseStructure[element_String, latticeParameters_List : {5., 5., 5., 90., 90., 90.}, spaceGroup_:"P1", inputLabel_String:""] :=
    Block[
        {label = inputLabel, sg, chemicalFormula, atomData}
        ,
        (* Checks *)
        If[InputCheck["FilterSpecialLabels", {element}] === {},
            Message[SynthesiseStructure::ExpectedSpecialLabel, element];
            Abort[]
        ];
        If[!MatchQ[latticeParameters, {#, #, #, #, #, #}&[_?NumericQ]],
            Message[SynthesiseStructure::InvalidLatticeParameters];
            Abort[]
        ];
        sg = InputCheck["InterpretSpaceGroup", spaceGroup];
        (* Prepare crystal data *)
        If[element === "Void",
            chemicalFormula = "";
            atomData = {}
            ,
            chemicalFormula = element;
            atomData = {<|"Element" -> element, "FractionalCoordinates" -> {0, 0, 0}|>}
        ];
        (* Add to crystal database *)
        If[label === "",
            label = element
        ];
        ImportCrystalData[{label, chemicalFormula, 0, spaceGroup, -1}, latticeParameters, atomData, "OverwriteWarning" -> False]
    ]

End[];
