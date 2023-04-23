FindPixelClusters::method = "The method \[LeftGuillemet]`1`\[RightGuillemet] was not recognised.";

FindPixelClusters::pixels = "Pixels in the binarised image: `1`.";

FindPixelClusters::dir = "Invalid directory.";

Options @ FindPixelClusters = {"ClusterRange" -> 3, "ClearStatus" -> 
    True, Method -> "Median", "PixelDataFile" -> FileNameJoin[{$TemporaryDirectory,
     "MaXrd", "PixelData.m"}], "RetrieveData" -> True, "ReturnBinaryImage"
     -> False, "UpdateDataFile" -> True};

Begin["`Private`"];

FPC$LoadPixelDataFile[dataFile_String] :=
    (
        If[!FileExistsQ @ dataFile,
            Quiet @ CreateDirectory[DirectoryName @ dataFile, CreateIntermediateDirectories
                 -> True];
            Check[Export[dataFile, <||>], Abort[]]
        ];
        Import @ dataFile
    )

FPC$MakeImageHash[image_Image] :=
    Hash[image, "Expression", "HexString"];

FPC$LookupPixelData[dataFile_String, image_Image] :=
    Block[{data, hash},
        data = FPC$LoadPixelDataFile @ dataFile;
        hash = FPC$MakeImageHash @ image;
        Lookup[data, hash]
    ]

FPC$UpdatePixelDataFile[dataFile_String, image_Image, newEntryData_List
    ] :=
    Block[{data, hash},
        data = FPC$LoadPixelDataFile @ dataFile;
        hash = FPC$MakeImageHash @ image;
        AppendTo[data, hash -> newEntryData];
        Export[dataFile, data];
        Length @ data
    ]

FPC$Process[image_Image, OptionsPattern @ FindPixelClusters] :=
    Module[
        {bin, data, dataLength, method, fraction, check, P, update, start,
             near, r, progress, status, total, p, i, j, neighbours, new, n, new2,
             clusters, k}
        ,
        (*---* Preparing image *---*)
        (* Otsu's cluster variance maximization method *)
        bin = Binarize @ image;
        data = PixelValuePositions[bin, 1];
        dataLength = Length @ data;
        (* Option: Choose method *)
        method = OptionValue[Method];
        If[!MemberQ[{"Median", "Mean", "Cluster", "BinariseOnly"}, method
            ],
            Message[FindPixelClusters::method, method];
            Abort[]
        ];
        If[method === "BinariseOnly",
            Goto["BinarisationDone"]
        ];
        (* Check if further refinement is necessary *)
        Which[
            dataLength <= 5000,
                Null
            ,
            dataLength <= 50000,
                bin = DeleteSmallComponents[bin, Method -> method]
            ,
            True,
                fraction = 1.00;
                (* Special procedure for very noisy images *)
                check = True;
                While[
                    check
                    ,
                    fraction = fraction - 0.005;
                    bin = Binarize[image, Method -> {"BlackFraction",
                         fraction}];
                    check = PixelValuePositions[bin, 1] == {}
                ];
                bin = DeleteSmallComponents[bin, Method -> "Mean"]
        ];
        data = PixelValuePositions[bin, 1];
(* Option: Return binary image and data length for inspection 
    *)
        Label["BinarisationDone"];
        If[OptionValue["ReturnBinaryImage"],
            Message[FindPixelClusters::pixels, ToString @ NumberForm[
                Length @ data, DigitBlock -> 3]];
            Return @ bin
        ];
        (*---* Cluster determination *---*)
        (* List of all pixels *)
        P = {};
        update = N @ data;
        start = First @ update;
        r = N @ OptionValue["ClusterRange"];
        near = N @ DeleteCases[Flatten[Table[{i, j}, {i, -r, r}, {j, 
            -r, r}], 1], {0, 0}];
        total = Length @ data;
        progress = total;
        (* Dynamic status *)
        status = PrintTemporary[Row[{Text[Style["Determining pixel clusters:",
             FontFamily -> "Avenir Next", 14]], Spacer[20], Dynamic @ ProgressIndicator[
            1 - progress / total]}, Alignment -> Center]];
        (* Single pixel *)
        P =
            Reap @
                While[
                    update != {}
                    ,
                    (* First iteration *)
                    p = {};
                    neighbours = start + #& /@ near;
                    new = Intersection[update, neighbours];
                    (* Avoid looping over the same single pixel *)
                    If[new == {},
                        update = Rest @ update
                    ];
                    p = Join[p, new];
                    update = Complement[update, p];
                    (* The next iterations *)
                    While[
                        new != {}
                        ,
                        (* Current and rest *)
                        n = First @ new;
                        new = Rest @ new;
                        neighbours = n + #& /@ near;
                        (* Actual new elements *)
                        new2 = Intersection[update, neighbours];
                        p = Join[p, new2];
                        update = Complement[update, p];
                        new = Join[new, new2];
                    ];
                    (* One pixel done *)
                    Sow[p];
                    progress = Length @ update;
                    If[update != {},
                        start = First @ update
                    ]
                ];
        If[TrueQ @ OptionValue["ClearStatus"],
            NotebookDelete @ status
        ];
        P = P[[2, 1]];
        clusters = DeleteCases[P, {}];
        (*---* Merge pixel clusters *---*)
        P =
            Reap @
                Do[
                    k = Round[{Total @ clusters[[i, All, 1]], Total @
                         clusters[[i, All, 2]]} / Length @ clusters[[i]]];
                    Sow[k]
                    ,
                    {i, Length @ clusters}
                ];
        P[[2, 1]]
    ]

FindPixelClusters[image_Image, options : OptionsPattern[]] :=
    Module[
        {dataFile = OptionValue["PixelDataFile"], imageClusterData}
        ,
        (* Driver routine -- Check if image has been processed *)
        imageClusterData = FPC$LookupPixelData[dataFile, image];
        If[!MissingQ @ imageClusterData && TrueQ @ OptionValue["RetrieveData"
            ] && !TrueQ @ OptionValue["ReturnBinaryImage"],
            (* a. Load data *)
            Return @ imageClusterData
            ,
            (* b. Find clusters *)
            imageClusterData = FPC$Process[image, options];
            If[TrueQ @ OptionValue["UpdateDataFile"],
                FPC$UpdatePixelDataFile[dataFile, image, imageClusterData
                    ]
            ];
            imageClusterData
        ]
    ]

FindPixelClusters[images_List, options : OptionsPattern[]] :=
    Module[
        {progress, dataLength, dataFile = OptionValue["PixelDataFile"
            ], tempDataFile, image, data, newData}
        ,
        (* Dynamic status *)
        progress = 0;
        dataLength = Length @ images;
        PrintTemporary[Row[{Text[Style["Progress:", FontFamily -> "Courier",
             16]], Spacer[20], Dynamic @ ProgressIndicator[progress / dataLength],
             Spacer[20], Dynamic[Text[Style["Images done: " <> ToString[progress]
             <> " of " <> ToString @ dataLength, FontFamily -> "Courier", 12]]]},
             Alignment -> Center]];
        (* Preparing output file *)
        tempDataFile = FileNameJoin[{$TemporaryDirectory, "MaXrd", "PixelData_InProgress.m"
            }];
        Quiet @ DeleteFile @ tempDataFile;
        (* Loop *)
        Do[
            image = images[[i]];
            If[FileExistsQ @ image,
                image = Import @ image
            ];
            If[!ImageQ @ image,
                progress++;
                Continue[]
            ];
            data = FPC$Process[images[[i]], options];
            FPC$UpdatePixelDataFile[tempDataFile, image, data];
            progress++
            ,
            {i, Length @ images}
        ];
        (* End *)
        newData = Join[FPC$LoadPixelDataFile @ dataFile, Import @ tempDataFile
            ];
        If[TrueQ @ OptionValue["UpdateDataFile"],
            Quiet @ CreateDirectory[DirectoryName @ dataFile, CreateIntermediateDirectories
                 -> True];
            Export[dataFile, newData]
            ,
            newData
        ]
    ]

End[];
