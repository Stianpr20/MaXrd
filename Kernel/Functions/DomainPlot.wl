DomainPlot::InputMismatch = "Input size does not match size of domain list.";

DomainPlot::InvalidDomainIndex = "Domain identifiers must be non-negative integers";

Options @ DomainPlot = {"Colours" -> {Red, Green, Blue, Yellow, Purple}, "CrystalFamily" -> "Cubic", "GraphicFunction" -> Automatic, Opacity -> 1.0, "RotationAnchorReference" -> "DomainCentroid", "RotationAnchorShift" -> {0, 0, 0}, "RotationMap" -> <||>};

SyntaxInformation @ DomainPlot = {"ArgumentsPattern" -> {{{_, _, _}, _}, OptionsPattern[]}};

Begin["`Private`"];

DomainPlot[{{sizeA_Integer, sizeB_Integer, sizeC_Integer}, allDomains_List}, OptionsPattern[]] :=
    Block[
        {domains = allDomains, seriesQ, twoDimensionalQ, crystalFamily = OptionValue["CrystalFamily"], graphicFunction = OptionValue["GraphicFunction"], coordinates, coordinateDomainMap, M, makePolytope, rotationMap = OptionValue["RotationMap"], rotationQ, R, anchorShift = OptionValue["RotationAnchorShift"], anchorReference = OptionValue["RotationAnchorReference"], numberOfDomains, preferredColours = OptionValue["Colours"], coloursToUse, colourTable, makeRotatedPolytope, MakePlot, polytopes, graphicList}
        ,
        (* Preparations in case of domain series *)
        seriesQ = MatchQ[Dimensions @ domains, {_, sizeA * sizeB * sizeC}];
        If[seriesQ,
            domains = First @ domains
        (* Check first list only *)];
        (* Check input *)
        twoDimensionalQ = sizeC === 1;
        If[(sizeA * sizeB * sizeC) != Length @ domains,
            Message[DomainPlot::InputMismatch];
            Abort[]
        ];
        If[AnyTrue[domains, NonNegative[#] \[Nand] IntegerQ[#]&],
            Message[DomainPlot::InvalidDomainIndex];
            Abort[]
        ];
        (* Preparations *)
        numberOfDomains = Max @ domains;
        coordinates = InputCheck["GenerateTargetPositions", {sizeA, sizeB, sizeC}];
        If[twoDimensionalQ,
            coordinates = coordinates[[All, {1, 2}]]
        ];
        coordinateDomainMap = Association @ Thread[coordinates -> domains];
        coloursToUse = Join[preferredColours, ColorData[96, #]& /@ Range[numberOfDomains - Length @ preferredColours]];
        colourTable = Join[<|0 -> Transparent|>, Association @ Thread[Range @ numberOfDomains -> coloursToUse[[ ;; numberOfDomains]]]];
        (* Fitting to given crystal system *)
        M =
            InputCheck[
                "GetCrystalFamilyMetric"
                ,
                crystalFamily
                ,
                If[twoDimensionalQ,
                    "2D"
                    ,
                    "3D"
                ]
            ];
        coordinateDomainMap = Association @ KeyValueMap[M . #1 -> #2&, coordinateDomainMap];
        If[graphicFunction =!= Automatic,
            makePolytope = graphicFunction
            ,
            makePolytope[origin_] := Parallelepiped[origin, Transpose @ M]
        ];
        (* Checking any rotations of domains *)
        rotationQ = rotationMap =!= <||>;
        If[rotationQ,
            R = InputCheck["RotationTransformation", {{sizeA, sizeB, sizeC}, domains}, {anchorShift, anchorReference, rotationMap}];
            makeRotatedPolytope[xyz_, d_] :=
                If[anchorReference === "Host" || (twoDimensionalQ && anchorReference =!= "Unit"),
                    GeometricTransformation[makePolytope[xyz], R[d]]
                    ,
                    GeometricTransformation[makePolytope[xyz], R[d, xyz]]
                ]
        ];
        (* Preparing graphics *)
        MakePlot[domainMap_] :=
            (
                polytopes =
                    If[rotationQ,
                        KeyValueMap[{colourTable @ #2, makeRotatedPolytope[#1, #2]}&, domainMap]
                        ,
                        KeyValueMap[{colourTable @ #2, makePolytope @ #1}&, domainMap]
                    ];
                graphicList = {Opacity @ OptionValue[Opacity], polytopes};
                If[twoDimensionalQ,
                    Graphics[graphicList, Frame -> False]
                    ,
                    Graphics3D[graphicList, Boxed -> False]
                ]
            );
        If[seriesQ,
            coordinates = Keys @ coordinateDomainMap;
            Table[MakePlot @ AssociationThread[coordinates -> allDomains[[i]]], {i, Length @ allDomains}]
            ,
            MakePlot @ coordinateDomainMap
        ]
    ]

End[];
