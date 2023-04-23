CrystalPlot::InvalidMethod = "\"AtomSizeMethod\" must either be \"RadiusTable\" or \"DisplacementParameters\".";

CrystalPlot::InvalidDisplay = "\"UnitCell\" must be either \"Box\", \"Axes\" or \"None\".";

CrystalPlot::InvalidOpacityMap = "Keys of \"OpacityMap\" must be \"Host\", \"Guest\" or a chemical element, which was not the case for: `1`.";

CrystalPlot::InvalidAtomRadiusType = "\[LeftGuillemet]`1`\[RightGuillemet] is not a valid setting for \"AtomRadiusType\".";

CrystalPlot::NoAtomData = "\[LeftGuillemet]`1`\[RightGuillemet] does not contain any atom data.";

CrystalPlot::ElementOnly = "Cannot plot a single atom without cell specifications.";

Options @ CrystalPlot =
    SortBy[
        Normal @
            Union[
                Association @ Options @ Graphics3D
                ,
                <|
                    "AtomRadius" -> 0
                    ,
                    "AtomRadiusType" -> "CovalentRadius"
                    ,
                    "AxisFunction" -> Line
                    ,
                    "BondRadius" -> 0.1
                    ,
                    "Bonds" -> Automatic
                    ,
                    "Ellipsoids" -> False
                    ,
                    "UnitVectorColors" -> <|"a" -> Red, "b" -> Green,
                         "c" -> Blue|>
                    ,
                    "UnitVectorLabelStyling" -> {Italic, FontSize -> 
                        20}
                    ,
                    "OpacityMap" -> <||>
                    ,
                    "RGBStyle" -> True
                    ,
                    "ShowUnitVectorLabels" -> False
                    ,
                    "StructureSize" -> {0, 0, 0}
                    ,
                    "UnitCellDisplay" -> "Box"
                    ,
                    "UnitVectorLabelPadding" -> 0.5
                    , (* \[ARing]ngstr\[ODoubleDot]ms *)
                    (* Graphics3D *)
                    Boxed -> False
                    ,
                    PlotRange -> All
                    ,
                    Lighting -> "Neutral"
                    ,
                    SphericalRegion -> True
                |>
            ]
        ,
        ToString[#[[1]]]&
    ];

SyntaxInformation @ CrystalPlot = {"ArgumentsPattern" -> {_, OptionsPattern[
    {CrystalPlot, Graphics3D}]}};

Begin["`Private`"];

CrystalPlot[crystalInput_String, OptionsPattern[{CrystalPlot, Graphics3D
    }]] :=
    Block[
        {crystal = crystalInput, opacityKeysCheck, useBondsQ, useEllipsoidsQ
             = TrueQ @ OptionValue["Ellipsoids"], crystalDataOriginal = $CrystalData,
             structureSize = OptionValue["StructureSize"], rgbStyle = TrueQ @ OptionValue[
            "RGBStyle"], latticeStyleList, unitVectorStyling, unitVectorColors, CreateBoxEdges,
             toCartesianMatrix, toCartesianMatrixTransposed, cartesianADPconverter,
             MakeRadiusFromElement, MakeSemiaxesFromADPs, shapeFunction, extentFunction,
             MakeAtomObject, FlattenSphereList, atomRadius = OptionValue["AtomRadius"
            ], useOneRadiusQ = False, atomRadiusType = OptionValue["AtomRadiusType"
            ], atomRadii, latticePlotFunction = OptionValue["AxisFunction"], atomData,
             atoms, basisArrowCoordinates, translations, coordinatePairs, unitCellPlotData,
             unitCellDisplay = OptionValue["UnitCellDisplay"], paddingAmountAngstroms,
             normalizedVectors, paddingVectors, unitVectorLabels, opacityMap = OptionValue[
            "OpacityMap"], connectedPairs, bondData, cylinders, plotContent, plotOptions
            }
        ,
        (* Checks *)
        InputCheck["CrystalQ", crystal];
        If[MemberQ[Keys @ $PeriodicTable, crystal] && !MemberQ[Keys @
             $CrystalData, crystal],
            Message[CrystalPlot::ElementOnly];
            Abort[]
        ];
        If[Lookup[$CrystalData[crystal], "AtomData", {}] === {},
            Message[CrystalPlot::NoAtomData, crystal];
            Abort[]
        ];
        opacityKeysCheck = Complement[Keys @ opacityMap, Join[Keys @ 
            $PeriodicTable, {"Host", "Guest"}]];
        If[opacityKeysCheck =!= {},
            Message[CrystalPlot::InvalidOpacityMap, StringDelete[ToString
                 @ opacityKeysCheck, {"{", "}"}]];
            Abort[]
        ];
        (* Optional: Expand crystal *)
        If[structureSize =!= {0, 0, 0},
            ExpandCrystal[crystalInput, structureSize, "StoreTemporarily"
                 -> True];
            crystal = First @ Keys @ StianRamsnes`MaXrd`Private`$TempCrystalData
                ;
            $CrystalData = StianRamsnes`MaXrd`Private`$TempCrystalData
                ;
        ];
        (* Optional: Add bonds *)
        useBondsQ = OptionValue["Bonds"];
        If[useBondsQ === Automatic,
            If[atomRadius > 0,
                useBondsQ = True
                ,
                useBondsQ = False
            ]
        ];
        (* Auxiliary *)
        If[TrueQ @ Positive @ atomRadius,
            (* a. Use a single radius for all atoms *)
            useOneRadiusQ = True
            ,
            (* b. Look up radii *)
            atomRadii = $AtomRadii @ atomRadiusType;
            If[MissingQ @ atomRadii,
                Message[CrystalPlot::InvalidAtomRadiusType, atomRadiusType
                    ];
                Abort[]
            ]
        ];
        unitVectorColors = OptionValue["UnitVectorColors"];
        latticeStyleList = ConstantArray[Black, 12];
        If[rgbStyle,
            latticeStyleList[[ ;; 3]] = Lookup[unitVectorColors, {"a",
                 "b", "c"}]
        ];
        CreateBoxEdges[{a_, b_, c_}, {t1_, t2_, t3_}] := {a, b, c, t2[
            a], t1[b], t1[c], t2[c], t1[t2[c]], t3[a], t3[b], t3[t2[a]], t3[t1[b]
            ]};
        toCartesianMatrix = GetCrystalMetric[crystal, "ToCartesian" ->
             True];
        toCartesianMatrixTransposed = Transpose @ toCartesianMatrix;
        cartesianADPconverter = TransformAtomicDisplacementParameters[
            crystal, "CartesianConverter"];
        If[useOneRadiusQ,
            MakeRadiusFromElement[element_] := atomRadius
            ,
            MakeRadiusFromElement[element_] := atomRadii @ element
        ];
        MakeSemiaxesFromADPs[ADPs_] :=
            If[ListQ @ ADPs,
                    2.36597 * #
                    ,
                    #
                ]& @ cartesianADPconverter @ ADPs;
        (* 2.36597 = InverseCDF[ChiSquareDistribution@3,0.5] *)
        (* X = 1.5382 * X; *)
        {shapeFunction, extentFunction} =
            If[useEllipsoidsQ,
                {Ellipsoid, MakeSemiaxesFromADPs}
                ,
                {Sphere, MakeRadiusFromElement}
            ];
        MakeAtomObject[{element_, xyz_, opacityTag_, ADPs_}, makeSpheresOnly_
            :False] :=
            {
                ColorData["Atoms"][element]
                ,
                Opacity @
                    If[KeyExistsQ[opacityMap, element],
                        opacityMap @ element
                        ,
                        Lookup[opacityMap, opacityTag, 1.0]
                    ]
                ,
                shapeFunction[
                    toCartesianMatrix . xyz
                    ,
                    extentFunction @
                        If[makeSpheresOnly,
                            element
                            ,
                            ADPs
                        ]
                ]
            };
        FlattenSphereList[spheres_List] :=
            Block[{allCoordinates, representant, radius},
                allCoordinates = spheres[[All, 3, 1]];
                representant = First @ spheres;
                radius = representant[[3, 2]];
                representant[[3]] = Sphere[allCoordinates, radius];
                representant
            ];
        (* Preparing atom spheres/ellipsoids *)
        atomData = Lookup[$CrystalData[crystal, "AtomData"], {"Element",
             "FractionalCoordinates", "Component", "DisplacementParameters"}];
        If[DeleteMissing /@ atomData === {{}},
            (* a. No atom content *)
            atoms = {}
            ,
            (* b. Regular procedure *)
            atomData[[All, 1]] = StringDelete[atomData[[All, 1]], {"+",
                 "-", DigitCharacter}];
            atoms = MakeAtomObject[#, !useEllipsoidsQ]& /@ atomData;
            If[!useEllipsoidsQ,
                atoms = GatherBy[atoms, {#[[{1, 2}]], #[[3, 2]]}&];
                atoms = FlattenSphereList /@ atoms
            ]
        ];
        (* Basis/lattice vectors and boxes *)
        basisArrowCoordinates = {{0, 0, 0}, #}& /@ toCartesianMatrixTransposed
            ;
        translations = TranslationTransform /@ toCartesianMatrixTransposed
            ;
        Which[
            unitCellDisplay === "Box",
                coordinatePairs = CreateBoxEdges[basisArrowCoordinates,
                     translations];
                unitCellPlotData =
                    Table[
                        {
                            latticeStyleList[[i]]
                            ,
                            If[i > 3,
                                    #
                                    ,
                                    Arrow @ #
                                ]& @ latticePlotFunction @ coordinatePairs
                                    [[i]]
                        }
                        ,
                        {i, Length @ coordinatePairs}
                    ]
            ,
            unitCellDisplay === "Axes",
                unitCellPlotData =
                    Transpose[
                        {
                            If[rgbStyle,
                                {Red, Green, Blue}
                                ,
                                ConstantArray[Black, 3]
                            ]
                            ,
                            Arrow[latticePlotFunction[{{0, 0, 0}, #}]
                                ]& /@ toCartesianMatrixTransposed
                        }
                    ]
            ,
            unitCellDisplay === "None",
                unitCellPlotData = {}
            ,
            True,
                Message[CrystalPlot::InvalidDisplay];
                Abort[]
        ];
        If[TrueQ @ OptionValue["ShowUnitVectorLabels"],
            paddingAmountAngstroms = OptionValue["UnitVectorLabelPadding"
                ];
            normalizedVectors = Normalize /@ toCartesianMatrixTransposed
                ;
            paddingVectors = AssociationThread[{"a", "b", "c"} -> paddingAmountAngstroms
                 * normalizedVectors];
            unitVectorLabels = MapThread[Text[#1, #2 + paddingVectors
                 @ #1, BaseStyle -> {Lookup[unitVectorColors, #1], Sequence @@ OptionValue[
                "UnitVectorLabelStyling"]}]&, {{"a", "b", "c"}, toCartesianMatrixTransposed
                }];
            unitCellPlotData = Join[unitCellPlotData, unitVectorLabels
                ];
        ];
(* If crystal was expanded, reset pointer to original $CrystalData 
    *)
        If[structureSize =!= {0, 0, 0},
            $CrystalData = crystalDataOriginal
        ];
        (* Atom bonds *)
        plotContent = Join[unitCellPlotData, atoms];
        If[TrueQ @ OptionValue["Bonds"] || atomRadius > 0,
            connectedPairs = Keys @ CP$FindAtomPairs @ crystal;
            If[connectedPairs =!= {},
                atomData = GetAtomCoordinates[crystal, "Cartesian" ->
                     True, "GatherElements" -> False, "IgnoreCharge" -> True];
                bondData = Transpose /@ (atomData[[#]]& /@ connectedPairs
                    );
                cylinders = CP$MakeBonds[bondData, OptionValue["BondRadius"
                    ]];
                plotContent = Join[plotContent, cylinders]
            ]
        ];
        (* Plot options *)
        plotOptions = Association @ FilterRules[# -> OptionValue[#]& 
            /@ (Keys @ Options @ CrystalPlot), Options @ Graphics3D];
        If[MemberQ[{"Trigonal", "Hexagonal"}, GetSymmetryData[crystal,
             "CrystalSystem"]] && OptionValue["ViewPoint"] === OptionValue[Graphics3D,
             ViewPoint],
            AssociateTo[plotOptions, ViewPoint -> {0, 0, \[Infinity]}
                ];
            If[12.1 <= $VersionNumber <= 12.2,
                AssociateTo[plotOptions, ViewAngle -> 90 \[Degree]]
            ]
        ];
        (* Plot *)
        Graphics3D[plotContent, Sequence @@ Normal @ plotOptions]
    ]

CP$FindAtomPairs[crystal_String] :=
    Block[{atomData, elements, coordinates, distances, elementPairs, 
        ranges, $ElementRanges = $AtomRadii["CovalentRadius"], connectedQ},
        atomData = GetAtomCoordinates[crystal, "Cartesian" -> True, "GatherElements"
             -> False, "IgnoreCharge" -> True];
        {elements, coordinates} = Transpose @ atomData;
        elements = Flatten @ StringCases[elements, RegularExpression[
            "[A-Z][a-z]?"]];
        distances = AssociationMap[EuclideanDistance @@ coordinates[[
            #]]&, Subsets[Range @ Length @ coordinates, {2}]];
        elementPairs = elements[[#]]& /@ Keys @ distances;
        ranges = Total /@ (Lookup[$ElementRanges, #, 0]& /@ elementPairs
            );
        connectedQ = Thread[ranges * 1.10 >= Values @ distances];
        (* 15% threshold *)
        Pick[distances, connectedQ]
    ]

CP$MakeBonds[bondDataInput_List, bondRadius_] :=
    Block[{SplitPoints, MakeCylinder, bondData = bondDataInput, colors,
         coordinates, colorMap},
        SplitPoints := {{#1, (#1 + #2) / 2}, {(#1 + #2) / 2, #2}}&;
        MakeCylinder := {#1, Cylinder[#2, bondRadius]}&;
        {colors, coordinates} = Transpose @ bondData;
        colorMap = ColorData["Atoms"];
        colors = Map[colorMap, colors, {2}];
        coordinates = SplitPoints @@@ coordinates;
        bondData = {colors, coordinates};
        bondData = Flatten[Transpose /@ Transpose @ bondData, 1];
        MakeCylinder @@@ bondData
    ]

$ElementRanges = <|"H" -> 0.682, "He" -> 0.616, "Li" -> 2.816, "Be" ->
     2.112, "B" -> 1.870, "C" -> 1.672, "N" -> 1.562, "O" -> 1.452, "F" ->
     1.254, "Ne" -> 1.276, "Na" -> 3.652, "Mg" -> 3.102, "Al" -> 2.662, "Si"
     -> 2.442, "P" -> 2.354, "S" -> 2.310, "Cl" -> 2.244, "Ar" -> 2.332, 
    "K" -> 4.466, "Ca" -> 3.872, "Sc" -> 3.740, "Ti" -> 3.520, "V" -> 3.366,
     "Cr" -> 3.058, "Mn" -> 3.058, "Fe" -> 2.904, "Co" -> 2.772, "Ni" -> 
    2.728, "Cu" -> 2.904, "Zn" -> 2.684, "Ga" -> 2.684, "Ge" -> 2.640, "As"
     -> 2.618, "Se" -> 2.640, "Br" -> 2.640, "Kr" -> 2.552, "Rb" -> 4.840,
     "Sr" -> 4.290, "Y" -> 4.180, "Zr" -> 3.850, "Nb" -> 3.608, "Mo" -> 3.388,
     "Tc" -> 3.234, "Ru" -> 3.212, "Rh" -> 3.124, "Pd" -> 3.058, "Ag" -> 
    3.190, "Cd" -> 3.168, "In" -> 3.124, "Sn" -> 3.058, "Sb" -> 3.058, "Te"
     -> 3.036, "I" -> 3.058, "Xe" -> 3.080, "Cs" -> 5.368, "Ba" -> 4.730,
     "La" -> 4.554, "Ce" -> 4.488, "Pr" -> 4.466, "Nd" -> 4.422, "Pm" -> 
    4.378, "Sm" -> 4.356, "Eu" -> 4.356, "Gd" -> 4.312, "Tb" -> 4.268, "Dy"
     -> 4.224, "Ho" -> 4.224, "Er" -> 4.158, "Tm" -> 4.180, "Yb" -> 4.114,
     "Lu" -> 4.114, "Hf" -> 3.850, "Ta" -> 3.740, "W" -> 3.564, "Re" -> 3.322,
     "Os" -> 3.168, "Ir" -> 3.102, "Pt" -> 2.992, "Au" -> 2.992, "Hg" -> 
    2.904, "Tl" -> 3.190, "Pb" -> 3.212, "Bi" -> 3.256, "Po" -> 3.080, "At"
     -> 3.300, "Rn" -> 3.300, "Fr" -> 5.720, "Ra" -> 4.862, "Ac" -> 4.730,
     "Th" -> 4.532, "Pa" -> 4.400, "U" -> 4.312, "Np" -> 4.180, "Pu" -> 4.114,
     "Am" -> 3.960, "Cm" -> 3.718, "Bk" -> 4.400, "Cf" -> 4.400, "Es" -> 
    4.400, "Fm" -> 4.400, "Md" -> 4.400, "No" -> 4.400, "Lr" -> 4.400, "Rf"
     -> 4.400, "Db" -> 4.400, "Sg" -> 4.400, "Bh" -> 4.400, "Hs" -> 4.400,
     "Mt" -> 4.400, "Ds" -> 4.400, "Rg" -> 4.400, "Cn" -> 4.400, "Nh" -> 
    4.400, "Fl" -> 4.400, "Mc" -> 4.400, "Lv" -> 4.400, "Ts" -> 4.400, "Og"
     -> 4.400|>;

$AtomRadii = <|"AtomicRadius" -> <|"H" -> 0.53`, "He" -> 0.31`, "Li" 
    -> 1.67`, "Be" -> 1.12`, "B" -> 0.87`, "C" -> 0.67`, "N" -> 0.56`, "O"
     -> 0.48`, "F" -> 0.42`, "Ne" -> 0.38`, "Na" -> 1.9`, "Mg" -> 1.45`, 
    "Al" -> 1.18`, "Si" -> 1.11`, "P" -> 0.98`, "S" -> 0.87`, "Cl" -> 0.79`,
     "Ar" -> 0.71`, "K" -> 2.43`, "Ca" -> 1.94`, "Sc" -> 1.84`, "Ti" -> 1.76`,
     "V" -> 1.71`, "Cr" -> 1.66`, "Mn" -> 1.61`, "Fe" -> 1.56`, "Co" -> 1.52`,
     "Ni" -> 1.49`, "Cu" -> 1.45`, "Zn" -> 1.42`, "Ga" -> 1.36`, "Ge" -> 
    1.25`, "As" -> 1.14`, "Se" -> 1.03`, "Br" -> 0.94`, "Kr" -> 0.87`, "Rb"
     -> 2.65`, "Sr" -> 2.19`, "Y" -> 2.12`, "Zr" -> 2.06`, "Nb" -> 1.98`,
     "Mo" -> 1.9`, "Tc" -> 1.83`, "Ru" -> 1.78`, "Rh" -> 1.73`, "Pd" -> 1.69`,
     "Ag" -> 1.65`, "Cd" -> 1.61`, "In" -> 1.56`, "Sn" -> 1.45`, "Sb" -> 
    1.33`, "Te" -> 1.23`, "I" -> 1.15`, "Xe" -> 1.08`, "Cs" -> 2.98`, "Ba"
     -> 2.53`, "La" -> 1.655`, "Ce" -> 1.655`, "Pr" -> 2.47`, "Nd" -> 2.06`,
     "Pm" -> 2.05`, "Sm" -> 2.38`, "Eu" -> 2.31`, "Gd" -> 2.33`, "Tb" -> 
    2.25`, "Dy" -> 2.28`, "Ho" -> 2.26`, "Er" -> 2.26`, "Tm" -> 2.22`, "Yb"
     -> 2.22`, "Lu" -> 2.17`, "Hf" -> 2.08`, "Ta" -> 2.`, "W" -> 1.93`, "Re"
     -> 1.88`, "Os" -> 1.85`, "Ir" -> 1.8`, "Pt" -> 1.77`, "Au" -> 1.74`,
     "Hg" -> 1.71`, "Tl" -> 1.56`, "Pb" -> 1.54`, "Bi" -> 1.43`, "Po" -> 
    1.35`, "At" -> 1.27`, "Rn" -> 1.2`, "Fr" -> 1.655`, "Ra" -> 1.655`, "Ac"
     -> 1.655`, "Th" -> 1.655`, "Pa" -> 1.655`, "U" -> 1.655`, "Np" -> 1.655`,
     "Pu" -> 1.655`, "Am" -> 1.655`, "Cm" -> 1.655`, "Bk" -> 1.655`, "Cf"
     -> 1.655`, "Es" -> 1.655`, "Fm" -> 1.655`, "Md" -> 1.655`, "No" -> 1.655`,
     "Lr" -> 1.655`, "Rf" -> 1.655`, "Db" -> 1.655`, "Sg" -> 1.655`, "Bh"
     -> 1.655`, "Hs" -> 1.655`, "Mt" -> 1.655`, "Ds" -> 1.655`, "Rg" -> 1.655`,
     "Cn" -> 1.655`, "Nh" -> 1.655`, "Fl" -> 1.655`, "Mc" -> 1.655`, "Lv"
     -> 1.655`, "Ts" -> 1.655`, "Og" -> 1.655`|>, "CovalentRadius" -> <|"H"
     -> 0.31`, "He" -> 0.28`, "Li" -> 1.28`, "Be" -> 0.96`, "B" -> 0.85`,
     "C" -> 0.76`, "N" -> 0.71`, "O" -> 0.66`, "F" -> 0.57`, "Ne" -> 0.58`,
     "Na" -> 1.66`, "Mg" -> 1.41`, "Al" -> 1.21`, "Si" -> 1.11`, "P" -> 1.07`,
     "S" -> 1.05`, "Cl" -> 1.02`, "Ar" -> 1.06`, "K" -> 2.03`, "Ca" -> 1.76`,
     "Sc" -> 1.7`, "Ti" -> 1.6`, "V" -> 1.53`, "Cr" -> 1.39`, "Mn" -> 1.39`,
     "Fe" -> 1.32`, "Co" -> 1.26`, "Ni" -> 1.24`, "Cu" -> 1.32`, "Zn" -> 
    1.22`, "Ga" -> 1.22`, "Ge" -> 1.2`, "As" -> 1.19`, "Se" -> 1.2`, "Br"
     -> 1.2`, "Kr" -> 1.16`, "Rb" -> 2.2`, "Sr" -> 1.95`, "Y" -> 1.9`, "Zr"
     -> 1.75`, "Nb" -> 1.64`, "Mo" -> 1.54`, "Tc" -> 1.47`, "Ru" -> 1.46`,
     "Rh" -> 1.42`, "Pd" -> 1.39`, "Ag" -> 1.45`, "Cd" -> 1.44`, "In" -> 
    1.42`, "Sn" -> 1.39`, "Sb" -> 1.39`, "Te" -> 1.38`, "I" -> 1.39`, "Xe"
     -> 1.4`, "Cs" -> 2.44`, "Ba" -> 2.15`, "La" -> 2.07`, "Ce" -> 2.04`,
     "Pr" -> 2.03`, "Nd" -> 2.01`, "Pm" -> 1.99`, "Sm" -> 1.98`, "Eu" -> 
    1.98`, "Gd" -> 1.96`, "Tb" -> 1.94`, "Dy" -> 1.92`, "Ho" -> 1.92`, "Er"
     -> 1.89`, "Tm" -> 1.9`, "Yb" -> 1.87`, "Lu" -> 1.87`, "Hf" -> 1.75`,
     "Ta" -> 1.7`, "W" -> 1.62`, "Re" -> 1.51`, "Os" -> 1.44`, "Ir" -> 1.41`,
     "Pt" -> 1.36`, "Au" -> 1.36`, "Hg" -> 1.32`, "Tl" -> 1.45`, "Pb" -> 
    1.46`, "Bi" -> 1.48`, "Po" -> 1.4`, "At" -> 1.5`, "Rn" -> 1.5`, "Fr" 
    -> 2.6`, "Ra" -> 2.21`, "Ac" -> 2.15`, "Th" -> 2.06`, "Pa" -> 2.`, "U"
     -> 1.96`, "Np" -> 1.9`, "Pu" -> 1.87`, "Am" -> 1.8`, "Cm" -> 1.69`, 
    "Bk" -> 1.46`, "Cf" -> 1.46`, "Es" -> 1.46`, "Fm" -> 1.46`, "Md" -> 1.46`,
     "No" -> 1.46`, "Lr" -> 1.46`, "Rf" -> 1.46`, "Db" -> 1.46`, "Sg" -> 
    1.46`, "Bh" -> 1.46`, "Hs" -> 1.46`, "Mt" -> 1.46`, "Ds" -> 1.46`, "Rg"
     -> 1.46`, "Cn" -> 1.46`, "Nh" -> 1.46`, "Fl" -> 1.46`, "Mc" -> 1.46`,
     "Lv" -> 1.46`, "Ts" -> 1.46`, "Og" -> 1.46`|>, "VanDerWaalsRadius" ->
     <|"H" -> 1.2`, "He" -> 1.4`, "Li" -> 1.82`, "Be" -> 1.8`, "B" -> 1.8`,
     "C" -> 1.7`, "N" -> 1.55`, "O" -> 1.52`, "F" -> 1.47`, "Ne" -> 1.54`,
     "Na" -> 2.27`, "Mg" -> 1.73`, "Al" -> 1.8`, "Si" -> 2.1`, "P" -> 1.8`,
     "S" -> 1.8`, "Cl" -> 1.75`, "Ar" -> 1.88`, "K" -> 2.75`, "Ca" -> 1.8`,
     "Sc" -> 1.8`, "Ti" -> 1.8`, "V" -> 1.8`, "Cr" -> 1.8`, "Mn" -> 1.8`,
     "Fe" -> 1.8`, "Co" -> 1.8`, "Ni" -> 1.63`, "Cu" -> 1.4`, "Zn" -> 1.39`,
     "Ga" -> 1.87`, "Ge" -> 1.8`, "As" -> 1.85`, "Se" -> 1.9`, "Br" -> 1.85`,
     "Kr" -> 2.02`, "Rb" -> 1.8`, "Sr" -> 1.8`, "Y" -> 1.8`, "Zr" -> 1.8`,
     "Nb" -> 1.8`, "Mo" -> 1.8`, "Tc" -> 1.8`, "Ru" -> 1.8`, "Rh" -> 1.8`,
     "Pd" -> 1.63`, "Ag" -> 1.72`, "Cd" -> 1.58`, "In" -> 1.93`, "Sn" -> 
    2.17`, "Sb" -> 1.8`, "Te" -> 2.06`, "I" -> 1.98`, "Xe" -> 2.16`, "Cs"
     -> 1.8`, "Ba" -> 1.8`, "La" -> 1.8`, "Ce" -> 1.8`, "Pr" -> 1.8`, "Nd"
     -> 1.8`, "Pm" -> 1.8`, "Sm" -> 1.8`, "Eu" -> 1.8`, "Gd" -> 1.8`, "Tb"
     -> 1.8`, "Dy" -> 1.8`, "Ho" -> 1.8`, "Er" -> 1.8`, "Tm" -> 1.8`, "Yb"
     -> 1.8`, "Lu" -> 1.8`, "Hf" -> 1.8`, "Ta" -> 1.8`, "W" -> 1.8`, "Re"
     -> 1.8`, "Os" -> 1.8`, "Ir" -> 1.8`, "Pt" -> 1.75`, "Au" -> 1.66`, "Hg"
     -> 1.55`, "Tl" -> 1.96`, "Pb" -> 2.02`, "Bi" -> 1.8`, "Po" -> 1.8`, 
    "At" -> 1.8`, "Rn" -> 1.8`, "Fr" -> 1.8`, "Ra" -> 1.8`, "Ac" -> 1.8`,
     "Th" -> 1.8`, "Pa" -> 1.8`, "U" -> 1.86`, "Np" -> 1.8`, "Pu" -> 1.8`,
     "Am" -> 1.8`, "Cm" -> 1.8`, "Bk" -> 1.8`, "Cf" -> 1.8`, "Es" -> 1.8`,
     "Fm" -> 1.8`, "Md" -> 1.8`, "No" -> 1.8`, "Lr" -> 1.8`, "Rf" -> 1.8`,
     "Db" -> 1.8`, "Sg" -> 1.8`, "Bh" -> 1.8`, "Hs" -> 1.8`, "Mt" -> 1.8`,
     "Ds" -> 1.8`, "Rg" -> 1.8`, "Cn" -> 1.8`, "Nh" -> 1.8`, "Fl" -> 1.8`,
     "Mc" -> 1.8`, "Lv" -> 1.8`, "Ts" -> 1.8`, "Og" -> 1.8`|>|>;

End[];
