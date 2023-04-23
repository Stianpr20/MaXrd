ReciprocalImageCheck::file = "Input file was not found.";

ReciprocalImageCheck::method = "The method \[LeftGuillemet]`1`\[RightGuillemet] was not recognised.";

ReciprocalImageCheck::system = "\[LeftGuillemet]`1`\[RightGuillemet] is not a valid lattice system.";

ReciprocalImageCheck::angles = "Invalid angle input for the given system.";

ReciprocalImageCheck::threshold = "`1` reflection`2` outside the threshold for integer determination.";

ReciprocalImageCheck::all = "All reflections were inside the threshold for integer determination.";

ReciprocalImageCheck::ambiguous = "Ambiguous image orientation. Use different correspondence points.";

ReciprocalImageCheck::data = "At least two data points are required.";

ReciprocalImageCheck::grid = "The option \[LeftGuillemet]ShowLattice\[RightGuillemet] must either be set to \[LeftGuillemet]True\[RightGuillemet] or a non-negative integer.";

ReciprocalImageCheck::InvalidLatticeOrigin = "Lattice origin must be a list of two integers or \"Center\".";

ReciprocalImageCheck::InvalidLatticeParameters = "The lattice must be a 2\[Times]2 matrix and the origin coordinates numeric.";

ReciprocalImageCheck::InvalidPlaneDescriptor = "The plane descriptor must be a vector with two miller indices (\"h\", \"k\", \"l\") and one constant; \[LeftGuillemet]`1`\[RightGuillemet] was provided.";

ReciprocalImageCheck::DuplicateReflections = "There are duplicate highlighted reflections.";

Options @ ReciprocalImageCheck =
    {
        (* FindPixelClusters options *)"ClearStatus" -> False
        ,
        (* Plot options *)
        Frame -> True
        ,
        ImageSize -> Large
        ,
        PlotRange -> Automatic
        ,
        PointSize -> Large
        ,
        (* ReciprocalImageCheck options *)
        "BackgroundImage" -> False
        ,
        "Colours" -> {ColorData[97, 2], ColorData[97, 1], LightGray}
        ,
        "CountNonInteger" -> False
        ,
        "GridThickness" -> Medium
        ,
        "HighlightReflections" -> None
        ,
        "HighlightSymmetry" -> "P1"
        ,
        "LatticeOrigin" -> "Center"
        ,
        "LatticeSize" -> None
        ,
        "ReturnCoordinateConverters" -> False
        ,
        "ReturnLatticeData" -> False
        ,
        "StoreDataTemporarily" -> False
        ,
        "Threshold" -> 0.15
        ,
        "TooltipStyle" -> {FontFamily -> "Courier New", FontSize -> 16,
             Bold}
    };

Begin["`Private`"];

ReciprocalImageCheck[image_Image, {a_, b_, c_, \[Alpha]_, \[Beta]_, \[Gamma]_
    }, data_List, Optional[pattern_Condition, {_, _, _} /; False], options
     : OptionsPattern[{ReciprocalImageCheck, FindPixelClusters, ListPlot}
    ]] :=
    Block[
        {latticeParameters = {a, b, c, \[Alpha], \[Beta], \[Gamma]}, 
            latticeOrigin = OptionValue["LatticeOrigin"], hkl, normalDirection, normalConstant,
             planeSelection, planeDescriptor, data2D, L, model, \[Lambda]1, \[Lambda]2,
             h1, h2, \[CapitalLambda], latticeData}
        ,
        (*--- Input check ---*)
        (* Check for sufficient data *)
        If[Length @ data < 2,
            Message[ReciprocalImageCheck::data];
            Abort[]
        ];
        (* Lattice origin shift *)
        If[latticeOrigin === "Center",
            latticeOrigin = ImageDimensions @ image / 2
        ];
        If[!MatchQ[latticeOrigin, {_?NumericQ, _?NumericQ}],
            Message[ReciprocalImageCheck::InvalidLatticeOrigin];
            Abort[]
        ];
(*--- Preparations for extracting two dimensions (image plane) ---
    *)
        (* Variables describing the plane *)
        hkl = data[[All, {3, 4, 5}]];
        normalDirection =
            Check[
                First @ Flatten @ Position[Length /@ DeleteDuplicates
                     /@ Transpose @ hkl, 1]
                ,
                Message[ReciprocalImageCheck::ambiguous];
                Abort[]
            ];
        normalConstant = data[[1, normalDirection + 2]];
        planeSelection = DeleteCases[{1, 2, 3}, normalDirection];
        planeDescriptor = planeSelection /. <|1 -> "h", 2 -> "k", 3 ->
             "l"|>;
        planeDescriptor = Insert[planeDescriptor, normalConstant, {normalDirection
            }];
        (*--- Setting up lattice ---*)
        data2D = Transpose @ Drop[Transpose @ data, {2 + normalDirection
            }];
        data2D = {#3, #4, N @ Norm[{#1, #2}]}& @@@ data2D;
        L = GetCrystalMetric[latticeParameters, "Space" -> "Reciprocal",
             "ToCartesian" -> True];
        L = L[[planeSelection, planeSelection]];
        model = Quiet @ NonlinearModelFit[data2D, Norm[Total[Transpose
             @ L * {\[Lambda]1, \[Lambda]2} * {h1, h2}] + latticeOrigin], {\[Lambda]1,
             \[Lambda]2}, {h1, h2}];
        {\[Lambda]1, \[Lambda]2} = model["ParameterTableEntries"][[All,
             1]];
        \[CapitalLambda] = Transpose[Transpose[L] * {\[Lambda]1, \[Lambda]2
            }];
        latticeData = {\[CapitalLambda], latticeOrigin, planeDescriptor
            };
        If[TrueQ @ OptionValue["ReturnLatticeData"],
            Return @ latticeData
        ];
        ReciprocalImageCheck[image, latticeData, pattern, options]
    ]

ReciprocalImageCheck[image_Image, {lattice_List, origin_List, planeDescriptor_List
    }, Optional[pattern_Condition, {_, _, _} /; False], options : OptionsPattern[
    {ReciprocalImageCheck, FindPixelClusters, ListPlot}]] :=
    Module[
        {thickness, planeSelection, \[Xi], \[Chi], \[CapitalXi], latticeSize,
             showGridQ, gridCreator, grid, pixelList, imageDimensions = ImageDimensions
             @ image, xy2hkl, off, hkl, count, matching, rest, makeTooltip, plotPoints,
             colorMatch, colorRest, colorOff, optionKeys, plotRange, plotOptions,
             plot, highlightQ, highlightOverlay}
        ,
        (*--- Input check ---*)
        (* Lattice check *)
        If[!MatchQ[lattice, {{#, #}, {#, #}}&[_?NumericQ]] || !Or @@ 
            NumericQ /@ origin,
            Message[ReciprocalImageCheck::InvalidLatticeParameters];
            Abort[]
        ];
        If[TrueQ @ OptionValue["ReturnLatticeData"],
            Return[{lattice, origin, planeDescriptor}]
        ];
        thickness = OptionValue["GridThickness"];
        planeSelection = DeleteCases[planeDescriptor, _?NumericQ] /. 
            <|"h" -> 1, "k" -> 2, "l" -> 3|>;
        (* Image check/treatment *)
        pixelList = FindPixelClusters[image, FilterRules[{options}, Options
             @ FindPixelClusters]];
        If[TrueQ @ OptionValue["ReturnBinaryImage"],
            Return @ pixelList
        ];
        {\[Xi], \[Chi]} = RIC$LatticeConversionFunctions[lattice, origin,
             OptionValue["Threshold"]];
        If[TrueQ @ OptionValue["ReturnCoordinateConverters"],
            Return[{\[Xi], \[Chi]}]
        ];
        \[CapitalXi] := RIC$Extended\[Xi][\[Xi], planeDescriptor];
        hkl = \[CapitalXi] /@ pixelList;
        (* Optional: Overlaying grid/lattice *)
        latticeSize = OptionValue["LatticeSize"];
        showGridQ = IntegerQ @ latticeSize && NonNegative @ latticeSize
            ;
        If[showGridQ,
            gridCreator = RIC$GraphicalLatticeFactory[{lattice, origin,
                 planeSelection}, thickness];
            grid =
                If[TrueQ @ OptionValue["StoreDataTemporarily"],
                    Table[gridCreator[s], {s, 0, 8}]
                    ,
                    gridCreator @ latticeSize
                ]
        ];
        (*--- Selecting nodes that match the pattern ---*)
        (* Consider reflections outside threshold to be wrong/off *)
        If[TrueQ @ OptionValue["CountNonInteger"],
            If[!FreeQ[hkl, _Real],
                Message[
                    ReciprocalImageCheck::threshold
                    ,
                    count = Count[FreeQ[#, _Real]& /@ hkl, False]
                    ,
                    If[count > 1,
                        "s were"
                        ,
                        " was"
                    ]
                ]
                ,
                Message[ReciprocalImageCheck::all]
            ]
        ];
        xy2hkl = AssociationThread[pixelList -> hkl];
        matching = Select[xy2hkl, MatchQ[#, pattern]&];
        off = KeySelect[xy2hkl, !AllTrue[#, IntegerQ]&];
        rest = Complement[xy2hkl, matching, off];
        plotPoints = {matching, rest, off};
        makeTooltip := KeyValueMap[Tooltip[##, TooltipStyle -> OptionValue[
            "TooltipStyle"]]&, MillerNotationToString /@ #]&;
        plotPoints = makeTooltip /@ plotPoints;
        (* Handling of certain default/automatic option values *)
        {colorMatch, colorRest, colorOff} = OptionValue["Colours"];
        optionKeys = Flatten[Keys /@ Options /@ {ReciprocalImageCheck,
             ListPlot}];
        plotOptions = Association[# -> OptionValue[#]& /@ optionKeys]
            ;
        If[plotOptions @ PlotRange === Automatic,
            plotOptions @ PlotRange = {{0, #1}, {0, #2}}& @@ imageDimensions
                
        ];
        plotRange = plotOptions @ PlotRange;
        If[plotOptions @ AspectRatio === 1 / GoldenRatio,
            plotOptions @ AspectRatio = plotRange / Divide @@ imageDimensions
                
        ];
        If[plotOptions @ PlotStyle === Automatic,
            plotOptions @ PlotStyle = {{PointSize -> OptionValue @ PointSize,
                 Automatic, colorMatch}, {PointSize -> OptionValue @ PointSize, Automatic,
                 colorRest}, {PointSize -> OptionValue @ PointSize, Automatic, colorOff
                }}
        ];
        plotOptions = FilterRules[Normal @ plotOptions, Options @ ListPlot
            ];
        (* Optional: Highlight certain reflections *)
        highlightQ = OptionValue["HighlightReflections"] =!= None;
        If[highlightQ,
            highlightOverlay = RIC$GenerateReflectionHighlightOverlay[
                \[Chi], OptionValue["HighlightReflections"], planeDescriptor, OptionValue[
                "HighlightSymmetry"]];
            highlightOverlay = MapAt[Tooltip[#, MillerNotationToString
                 @ \[CapitalXi] @ First @ #, TooltipStyle -> OptionValue["TooltipStyle"
                ]]&, highlightOverlay, {1, 2, 2 ;; -1 ;; 2, All}]
        ];
        If[TrueQ @ OptionValue["BackgroundImage"],
            (* a. Put invisible nodes on top of image *)
            plotOptions = Normal @ Join[Association @ plotOptions, <|
                PlotStyle -> {Transparent, PointSize -> Large}, Frame -> False, Axes 
                -> False|>];
            Return @
                Show[
                    ListPlot[{}, Sequence @@ plotOptions]
                    ,
                    If[showGridQ,
                        grid
                        ,
                        {}
                    ]
                    ,
                    If[highlightQ,
                        highlightOverlay
                        ,
                        {}
                    ]
                    ,
                    ListPlot[Flatten @ plotPoints, Sequence @@ plotOptions
                        ]
                    ,
                    Prolog -> Inset[image, {0, 0}, {0, 0}, imageDimensions
                        ]
                ]
            ,
            (* b. Regular ListPlot *)
            plot = ListPlot[plotPoints /. {} -> {Null, Null}, Sequence
                 @@ plotOptions]
        ];
        (*--- End ---*)
        (* Optional: Store data temporarily *)
        If[TrueQ @ OptionValue["StoreDataTemporarily"],
            Return[<|"Image" -> image, "ImageGrayscale" -> ColorConvert[
                image, "Grayscale"], "ImageNegative" -> ColorNegate[image], "ImageGrayscaleNegative"
                 -> ColorConvert[ColorNegate[image], "Grayscale"], "ImageBinarised" ->
                 Binarize[image], "Lattice" -> {lattice, origin, planeDescriptor}, "PlotData"
                 -> rest, "PlotDataMatch" -> matching, "PlotDataWrong" -> off, "Grids"
                 -> grid|>]
        ];
        Show[
            plot
            ,
            If[showGridQ,
                grid
                ,
                {}
            ]
            ,
            If[highlightQ,
                highlightOverlay
                ,
                {}
            ]
            ,
            plotOptions
        ]
    ]

RIC$LatticeConversionFunctions[lattice_, origin_, threshold_] :=
    Module[{\[CapitalLambda], \[CapitalGamma], tx, ty, \[Xi], \[Chi],
         convert, residue, result},
        \[CapitalLambda] = lattice;
        \[CapitalGamma] = Inverse @ \[CapitalLambda];
        {tx, ty} = origin;
        \[Xi][x_, y_] := \[CapitalGamma] . {x - tx, y - ty};
        \[Chi][h_, k_] := \[CapitalLambda] . {h, k} + {tx, ty};
        (* Pixel to node *)
        \[Xi][{x_, y_}] :=
            (
                (* Calculation and discrepancy check *)convert = \[CapitalGamma]
                     . {x - tx, y - ty};
                residue = Abs /@ FractionalPart /@ N[convert];
                (* Decide whether to round to integer *)
                result = {};
                Do[
                    Which[
                        residue[[i]] <= threshold,
                            AppendTo[result, Round @ convert[[i]]]
                        ,
                        1 - residue[[i]] <= threshold,
                            AppendTo[result, Round @ convert[[i]]]
                        ,
                        True,
                            AppendTo[result, N @ convert[[i]]]
                    ]
                    ,
                    {i, 2}
                ];
                result
            );
        (* Node to pixel *)
        \[Chi][h_] := Round[\[CapitalLambda] . h + {tx, ty}];
        {\[Xi], \[Chi]}
    ]

RIC$Extended\[Xi][pixelToNodeFunction_, planeDescriptor_] :=
    Module[
        {normalConstant, planeSelection, normalDirection}
        ,
        (* Variables describing the plane *)
        normalConstant =
            Check[
                First @ Select[planeDescriptor, NumericQ]
                ,
                Message[ReciprocalImageCheck::InvalidPlaneDescriptor,
                     planeDescriptor];
                Abort[]
            ];
        planeSelection = DeleteCases[planeDescriptor, _?NumericQ] /. 
            <|"h" -> 1, "k" -> 2, "l" -> 3|>;
        normalDirection = First @ Complement[{1, 2, 3}, planeSelection
            ];
        Insert[pixelToNodeFunction @ #, normalConstant, {normalDirection
            }]&
    ]

RIC$GraphicalLatticeFactory[{lattice_, origin_, planeSelection_}, thickness_
    ] :=
    Module[
        {axisColors, latticeVector1, latticeVector2, latticeSetup, t,
             tt, makeGrid, u, x1, x2, temp, temp2}
        ,
        (* Preparations *)
        axisColors = Lookup[<|1 -> Red, 2 -> Green, 3 -> Blue|>, planeSelection
            ];
        {latticeVector1, latticeVector2} = Transpose @ lattice;
        (* Lattice setup *)
        latticeSetup[x0_, y0_] :=
            (
                t = lattice . {x0, y0} + origin;
                tt = {t, t};
                If[x0 == y0 == 0,
                    {(* Origin arrows *){axisColors[[1]], Arrow[{origin,
                         origin + latticeVector1}]}, {axisColors[[2]], Arrow[{origin, origin 
                        + latticeVector2}]}}
                    ,
                    {(* Translated lines *){axisColors[[1]], Dashed, 
                        Line[{{0, 0}, latticeVector1} + tt]}, {axisColors[[2]], Dashed, Line[
                        {{0, 0}, latticeVector2} + tt]}}
                ]
            );
        makeGrid[s_] :=
            (
                temp = Table[latticeSetup[i, j], {i, -s, Max[1, s]}, 
                    {j, -s, Max[1, s]}];
                temp = Flatten[temp, 2];
                If[s == 0,
                    temp = Delete[temp, {{3}, {4}, {5}, {6}, {7}, {8}
                        }];
                    Goto["One"]
                ];
                temp2 = 4 s + 2;
                u = 2 * (2 s + 1) ^ 2;
                x1 = Table[i, {i, temp2, u, temp2}];
                x1 = Replace[x1, x_ :> {x}, {1}];
                x2 = Table[j, {j, u - (4 s + 1), u - 1, 2}];
                x2 = Replace[x2, x_ :> {x}, {1}];
                temp = Delete[temp, DeleteDuplicates @ Join[x1, x2]];
                    
                Label["One"];
                PrependTo[temp, Arrowheads @ Medium];
                Graphics[{Thickness @ thickness, temp, AspectRatio ->
                     1, Axes -> False}]
            );
        makeGrid
    ]

RIC$GenerateReflectionHighlightOverlay[nodeToPixelFunction_, reflections_,
     planeDescriptor_, symmetry_] :=
    Module[{planeSelection, normalDirection, normalConstant, preferredColors
         = {Green, Blue, Pink, Cyan, Orange}, colors, hkl, hkl2D, xy, disks, 
        radius = 14, opacity = 0.4},
        planeSelection = DeleteCases[planeDescriptor, _?NumericQ] /. 
            <|"h" -> 1, "k" -> 2, "l" -> 3|>;
        normalDirection = First @ Complement[{1, 2, 3}, planeSelection
            ];
        normalConstant = First @ Select[planeDescriptor, IntegerQ];
        hkl = InputCheck[reflections, "WrapSingle"];
        InputCheck[hkl, "Integer"];
        hkl = SymmetryEquivalentReflections[symmetry, #]& /@ hkl;
        hkl = Select[#, #[[normalDirection]] == normalConstant&]& /@ 
            hkl;
        If[!DuplicateFreeQ @ Flatten[hkl, 1],
            Message[ReciprocalImageCheck::DuplicateReflections]
        ];
        hkl2D = hkl[[All, All, planeSelection]];
        colors = Join[preferredColors, ColorData[96, #]& /@ Range[Length
             @ hkl - Length @ preferredColors]][[ ;; Length @ hkl]];
        xy = Map[nodeToPixelFunction, hkl2D, {2}];
        disks = Map[Disk[#, radius]&, xy, {2}];
        Graphics[{Opacity @ opacity, Riffle[colors, disks]}]
    ]

End[];
