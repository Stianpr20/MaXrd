SimulateDiffractionPattern::InvalidStructureInput = "Structural input must be a crystal label or the path to one or more structure files.";

SimulateDiffractionPattern::InvalidInputForDIFFUSE = "If not using a crystal label with DIFFUSE, input should be two structure files.";

SimulateDiffractionPattern::InvalidReciprocalPlane = "Invalid reciprocal plane input.";

SimulateDiffractionPattern::InvalidReciprocalSpaceLimit = "Invalid setting for \"IndicesLimit\".";

SimulateDiffractionPattern::ZeroIntensity = "No intensity found in data.";

SimulateDiffractionPattern::MissingOutputData = "Unable to import the expected output data.";

SimulateDiffractionPattern::MissingProgram = "`1` does not appear to be installed.";

SimulateDiffractionPattern::InvalidPrint = "Invalid print setting.";

SimulateDiffractionPattern::InvalidFormat = "Structure file seems to be invalid.";

SimulateDiffractionPattern::UnsupportedProgram = "The program \[LeftGuillemet]`1`\[RightGuillemet] is not supported.";

SimulateDiffractionPattern::InvalidSubtractionMode = "Invalid scattering subtraction mode.";

SimulateDiffractionPattern::InvalidScalingFactor = "The scaling factor must be a number.";

SimulateDiffractionPattern::InvalidImageDimensions = "Image dimension must be a pair of natural numbers.";

Options @ SimulateDiffractionPattern =
    SortBy[
        Normal @
            Union[
                Association @ Options @ ArrayPlot
                ,
                Association @ Options @ ListDensityPlot
                ,
                <|
                    "BraggScatteringSubtractionMode" -> None
                    ,
                    "ImageDimensions" -> {500, 500}
                    ,
                    "IndicesLimit" -> 5.5
                    ,
                    "LowerCutoff" -> 0
                    ,
                    "PrintOutput" -> "ErrorsOnly"
                    ,
                    "ProgramPaths" -> <|"MacOSX" -> <|"DISCUS" -> "/usr/local/bin/discus_suite", "DIFFUSE" -> "/usr/local/bin"|>, "Unix" -> <|"
                            DISCUS" -> "/usr/local/bin/discus_suite", "DIFFUSE" -> "/usr/local/bin"|>, "Windows" -> <|"DISCUS" -> "C:\\Program Files (x86)\\Discus\\bin\\discus_suite.exe", "DIFFUSE" -> "C:\\Program Files (x86)\\DIFFUSE"|>|>
                    ,
                    "ReturnData" -> False
                    ,
                    "ScalingFactor" -> 1
                    ,
                    "UseRawInput" -> False
                    ,
                    (* ArrayPlot *)
                    ColorFunction -> "Warm"
                    ,
                    Frame -> False
                    ,
                    FrameTicks -> All
                    ,
                    ImageSize -> Large
                    ,
                    PlotLegends -> None
                    ,
                    ScalingFunctions -> "Log"
                |>
            ]
        ,
        ToString[#[[1]]]&
    ];

SyntaxInformation @ SimulateDiffractionPattern = {"ArgumentsPattern" -> {_, _, OptionsPattern[{SimulateDiffractionPattern, ArrayPlot, ListDensityPlot}]}};

Begin["`Private`"];

SimulateDiffractionPattern[usingProgram_String, structureInput_, imagePlane_, OptionsPattern[]] :=
    Block[
        {imgPlane = imagePlane, programPaths, searchExpression, options, inputs}
        ,
        (*---* Common driver routine *---*)
        (* Common checks *)
        If[!MemberQ[{"DISCUS", "DIFFUSE"}, usingProgram],
            Message[SimulateDiffractionPattern::UnsupportedProgram, usingProgram];
            Abort[]
        ];
        If[!MemberQ[{"ErrorsOnly", All}, OptionValue["PrintOutput"]],
            Message[SimulateDiffractionPattern::InvalidPrint];
            Abort[]
        ];
        If[!MemberQ[{None, "Biso", "ExactAverage", "SmallAverage"}, OptionValue["BraggScatteringSubtractionMode"]],
            Message[SimulateDiffractionPattern::InvalidSubtractionMode];
            Abort[]
        ];
        If[!NumericQ @ OptionValue["ScalingFactor"],
            Message[SimulateDiffractionPattern::InvalidScalingFactor];
            Abort[]
        ];
        If[!MatchQ[OptionValue["ImageDimensions"], {#, #}&[_ ? (IntegerQ[#] && Positive[#]&)]],
            Message[SimulateDiffractionPattern::InvalidImageDimensions];
            Abort[]
        ];
        Which[
            usingProgram === "DISCUS",
                If[!StringQ @ structureInput,
                    Message[SimulateDiffractionPattern::InvalidStructureInput];
                    Abort[]
                ]
            ,
            usingProgram === "DIFFUSE",
                If[StringQ @ structureInput,
                    InputCheck["CrystalQ", structureInput]
                    ,
                    If[Length @ structureInput != 2 || AnyTrue[structureInput, !FileExistsQ[#]&],
                        Message[SimulateDiffractionPattern::InvalidInputForDIFFUSE];
                        Abort[]
                    ]
                ]
        ];
        If[StringQ @ imgPlane,
            imgPlane = MillerNotationToList @ imgPlane
        ];
        If[MatchQ[Sort @ imgPlane, {_Integer, #, #}]&["h" | "k" | "l"] \[Nand] DuplicateFreeQ @ imgPlane,
            Message[SimulateDiffractionPattern::InvalidReciprocalPlane];
            Abort[]
        ];
        If[!DirectoryQ @ #,
            CreateDirectory @ #
        ]&[FileNameJoin[{$TemporaryDirectory, "MaXrd"}]];
        programPaths = OptionValue["ProgramPaths"][$OperatingSystem][usingProgram];
        If[programPaths === "" || DirectoryQ @ programPaths,
            searchExpression =
                Which[
                    usingProgram === "DISCUS",
                        {"discus"}
                    ,
                    usingProgram === "DIFFUSE",
                        {"dzmc", "bin2gray"}
                ];
            If[$OperatingSystem === "Windows",
                searchExpression = # <> ".exe"& /@ searchExpression
            ];
            searchExpression = "(?i)" <> StringRiffle[searchExpression, "|"];
            programPaths = Sort @ FileNames[RegularExpression @ searchExpression, programPaths, IgnoreCase -> True]
        ];
        programPaths = Flatten @ List @ programPaths;
        If[!AllTrue[Flatten @ List @ programPaths, FileExistsQ] || programPaths === {},
            Message[SimulateDiffractionPattern::MissingProgram, usingProgram];
            Abort[]
        ];
        If[usingProgram === "DISCUS" && ListQ @ programPaths,
            programPaths = First @ programPaths
        ];
        (* Switch flow *)
        options = Thread[# -> OptionValue[#], String]& /@ Keys @ Options @ SimulateDiffractionPattern;
        inputs = {programPaths, structureInput, imgPlane, Association @ options};
        Which[
            usingProgram === "DISCUS",
                SDP$DISCUS @@ inputs
            ,
            usingProgram === "DIFFUSE",
                SDP$DIFFUSE @@ inputs
        ]
    ]

SDP$DISCUS[programPath_String, structureInput_, imagePlane_, givenOptions_] :=
    Block[
        {structureFile = structureInput, options = givenOptions, workDir, i, stream, line, streamData, ncell = "", allCoords, structureSize, latticeParameters, crystalM, hklMax, abscissaIndex, ordinateIndex, x, imageOrientation, commands, feedback = "", cutOffValue, data, dataLength, xDataSize, yDataSize, xMin, xMax, yMin, yMax, xStep, yStep, numbers, plotData, scaleMax, intensities, maxIntensity, useRawInputQ, imageBasis}
        ,
        (* Handle both crystal label and structure file input *)
        If[KeyExistsQ[$CrystalData, structureInput],
            structureFile = ExportCrystalData["DISCUS", structureFile, FileNameJoin[{$TemporaryDirectory, "MaXrd", "TemporaryStructureFile.stru"}]]
        ];
        If[!FileExistsQ @ structureFile,
            Message[SimulateDiffractionPattern::InvalidStructureInput];
            Abort[]
        ];
        structureFile = AbsoluteFileName @ structureFile;
        (* Determining structure size *)
        {i, stream} = {1, OpenRead @ structureFile};
        While[
            True
            ,
            line = Read[stream, String];
            If[StringTake[line,  ;; 4] === "cell",
                latticeParameters = line
            ];
            If[StringTake[line,  ;; 5] === "ncell",
                ncell = line;
                ReadLine @ stream;
                Break[]
            ];
            If[StringTake[line,  ;; 5] === "atoms",
                Break[]
            ];
            If[i > 10,
                Message[SimulateDiffractionPattern::InvalidFormat];
                Abort[]
            ];
            i++;
        ];
        streamData = ReadList[stream, String];
        Close @ stream;
        structureSize =
            If[ncell =!= "",
                (* a. Read size directly *)
                Max @ ToExpression[StringCases[ncell, DigitCharacter..][[ ;; 3]]]
                ,
                (* b. Determine size from coordinate data *)
                allCoords = ToExpression @ Part[StringSplit @ streamData, All, 2 ;; 4];
                Subtract @@ Reverse[Ceiling /@ MinMax @ allCoords]
            ];
        latticeParameters = ToExpression @ StringCases[latticeParameters, {DigitCharacter, "."}..];
        crystalM = GetCrystalMetric[latticeParameters, "Space" -> "Reciprocal", "ToCartesian" -> True];
        (* Preparing input for Fourier transform *)
        workDir = DirectoryName @ structureFile;
        hklMax = options["IndicesLimit"];
        If[NumericQ @ hklMax \[Nand] Positive @ hklMax,
            Message[SimulateDiffractionPattern::InvalidReciprocalSpaceLimit];
            Abort[]
        ];
        imageOrientation =
            InputCheck[
                "GetReciprocalImageOrientation"
                ,
                latticeParameters
                ,
                imagePlane
                ,
                hklMax
                ,
                {100, 100}(* Dummy width and height 
            *) ,
                False
            ];
        {abscissaIndex, ordinateIndex} = {#1, #2}& @@ Flatten[Position[imagePlane, #]& /@ {"h", "k", "l", _Integer}];
        commands =          "
################################################
# COMBINED BUILD MACRO FOR `SimulateDiffractionPattern`
################################################
cd " <> workDir <>                                                         "
discus
####### Load/build crystal #####################
variable int, sizeX
sizeX = " <> ToString @ structureSize <>                            "
#
read
  stru " <> FileNameTake @ structureFile <>          "
#
chem
  elem
exit
####### Fourier transform ######################
variable real, hklMax
variable int,  fourierWidth
variable int,  fourierPoints
#
hklMax = " <> ToString @ N @ hklMax <>     "
fourierWidth = 2 * hklMax
fourierPoints = fourierWidth * sizeX + 1
#
fourier
  xray
  wvle moa1
#
  ll   " <> imageOrientation[[1]] <>     "
  lr   " <> imageOrientation[[2]] <> "
  ul   " <> imageOrientation[[3]] <> "
  na   fourierPoints
  no   fourierPoints
  abs  " <> (abscissaIndex /. {1 -> "h", 2 -> "k", 3 -> "l"}) <>     "
  ord  " <> (ordinateIndex /. {1 -> "h", 2 -> "k", 3 -> "l"}) <>  "
#
  show
  run
exit
#
#
#---# Fourier data output #---#
output
  value intensity
  format standard
  outfile fourier_data.dat
  run
exit
################################################
exit
";
        (* Run DISCUS *)
        feedback = RunProcess[programPath, All, commands];
        SDP$EvaluateFeedbackPrint[commands, feedback, options["PrintOutput"]];
        (*-----* Plot preparations *-----*)
        (* Importing (x,y,intensity) data from file *)
        data =
            Check[
                Import[FileNameJoin[{workDir, "fourier_data.dat"}], "Table"]
                ,
                Message[SimulateDiffractionPattern::MissingOutputData];
                Abort[]
            ];
        dataLength = Length @ data;
        i = 1;
        While[data[[i, 1]] === ("#") && i <= dataLength, i++];
        Check[{xDataSize, yDataSize} = data[[i]], Abort[]];
        {xMin, xMax, yMin, yMax} = data[[i + 1]];
        xStep = (xMax - xMin) / (xDataSize - 1);
        yStep = (yMax - yMin) / (yDataSize - 1);
        numbers = Flatten[data[[i + 2 ;; ]]];
        numbers = Partition[numbers, xDataSize];
        plotData =
            Table[
                {
                    xMin + (x - 1) * xStep, yMin + (y - 1) * yStep, numbers[[y, x]](* Instead of transposing *)
                }
                ,
                {y, yDataSize}
                ,
                {x, xDataSize}
            ];
        plotData = Flatten[plotData, 1];
        (* Scaling intensities *)
        scaleMax = 100.;
        intensities = plotData[[All, 3]];
        maxIntensity = Max @ intensities;
        If[maxIntensity == 0,
            Message[SimulateDiffractionPattern::ZeroIntensity];
            Abort[]
        ];
        intensities *= scaleMax / maxIntensity;
        intensities = # * options["ScalingFactor"]& /@ intensities;
        intensities = intensities /. x_ /; x > scaleMax -> scaleMax;
        (* 16 bit max  *)
        plotData[[All, 3]] = intensities;
        (* Data treatment and preparation *)
        useRawInputQ = TrueQ @ options["UseRawInput"];
        If[useRawInputQ,
            (* a. Use data "as is" *)
            plotData = Partition[plotData[[All, 3]], Length @ numbers]
            ,
            (* b. Rescale intensity and use appropriate basis for image *)
            cutOffValue = Power[10., -3];
            plotData = plotData /. {x_, y_, i_} /; i < cutOffValue :> {x, y, cutOffValue};
            imageBasis = Normalize /@ crystalM[[{abscissaIndex, ordinateIndex}, {abscissaIndex, ordinateIndex}]];
            plotData[[All, {1, 2}]] = Map[imageBasis . #&, plotData[[All, {1, 2}]]]
        ];
        (* Prepare and deliver plot *)
        If[useRawInputQ,
            AssociateTo[options, DataRange -> {{xMin, xMax}, {yMin, yMax}}]
            ,
            AssociateTo[options, AspectRatio -> Divide @@ Total @ imageBasis]
        ];
        If[TrueQ @ options @ "ReturnData",
            Return @ plotData
        ];
        ListDensityPlot[plotData, Sequence @@ FilterRules[Normal @ options, Options @ ListDensityPlot]]
    ]

SDP$DIFFUSE[programPaths_List, structureInput_, imagePlane_List, givenOptions_] :=
    Block[
        {structureFiles, workDir = FileNameJoin[{$TemporaryDirectory, "MaXrd"}], inputFileDZMC, subtractionMode, lowerCutoff, width, height, inputFile1 = "diffuse_input1_crystal.txt", inputFile2 = "diffuse_input2_setup.txt", commands, feedback, outputFile, imageData}
        ,
        (* Handle both crystal label and structure file input *)
        If[KeyExistsQ[$CrystalData, structureInput],
            subtractionMode = givenOptions["BraggScatteringSubtractionMode"];
            subtractionMode = subtractionMode /. {None -> "N", "Biso" -> "Y", "ExactAverage" -> "E", "SmallAverage" -> "e"};
            {width, height} = givenOptions["ImageDimensions"];
            structureFiles = ExportCrystalData["DIFFUSE", structureInput, workDir, imagePlane, givenOptions["IndicesLimit"], subtractionMode, {width, height}]
            ,
            CopyFile[#1, #2, OverwriteTarget -> True]& @@@ Transpose[{structureInput, FileNameJoin[{workDir, #}]& /@ {inputFile1, inputFile2}}]
        ];
        If[AnyTrue[structureFiles, !FileExistsQ[#]&],
            Message[SimulateDiffractionPattern::InvalidStructureInput];
            Abort[]
        ];
        structureFiles = AbsoluteFileName /@ structureFiles;
        Quiet @ DeleteFile @ FileNames["output*", workDir];
        inputFileDZMC = FileNameJoin[{workDir, "DZMC_inputs.txt"}];
        Put[OutputForm @ inputFile2, OutputForm["output.bin"], inputFileDZMC];
        commands = StringTemplate[                        "
cd `workDir`
\"`prog1`\" `inp1` < DZMC_inputs.txt
\"`prog2`\" --quiet=true output.bin
"] @ <|"workDir" -> workDir, "inp1" -> inputFile1, "prog1" -> programPaths[[2]], "prog2" -> programPaths[[1]]|>;
        (* Run DIFFUSE and then bin2gray *)
        feedback = RunProcess[$SystemShell, All, commands];
        SDP$EvaluateFeedbackPrint[commands, feedback, givenOptions["PrintOutput"]];
        outputFile = FileNameJoin[{workDir, "output.pgm"}];
        If[!FileExistsQ @ outputFile,
            Message[SimulateDiffractionPattern::MissingOutputData];
            Abort[]
        ];
        lowerCutoff = givenOptions["LowerCutoff"];
        If[TrueQ @ givenOptions["UseRawInput"],
            Import @ outputFile
            ,
            imageData = N @ Import[outputFile, "Data"];
            imageData = # * givenOptions["ScalingFactor"]& /@ imageData;
            imageData = imageData /. x_ /; x > 65535 -> 65535; (* 16 bit max *)
            imageData = imageData /. x_ /; x < lowerCutoff -> 0.;
            If[TrueQ @ givenOptions["ReturnData"],
                Return @ imageData
            ];
            ArrayPlot[imageData, Sequence @@ FilterRules[Normal @ givenOptions, Options @ ArrayPlot]]
        ]
    ]

SDP$EvaluateFeedbackPrint[commands_String, feedbackInput_Association, optionSetting_] :=
    Block[{feedback = feedbackInput, stderr},
        If[optionSetting === All,
            PrintTemporary @ Prepend[feedback, "Input" -> commands]
            ,
            (* Removing irrelevant errors *)
            stderr = StringTrim @ StringDelete[feedback["StandardError"], {"Remaining memory" ~~ __ ~~ WhitespaceCharacter, WhitespaceCharacter ~~ "More segments" ~~ __, "'\\\\" ~~ __ ~~ "UNC paths" ~~ __ ~~ "Defaulting to Windows directory."}];
            If[stderr =!= "" || feedback["ErrorCode"] == 2,
                PrintTemporary @ stderr
            ]
        ]
    ]

End[];
