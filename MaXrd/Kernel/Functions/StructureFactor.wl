StructureFactor::InvalidThreshold = "Invalid threshold setting: \[LeftGuillemet]`1`\[RightGuillemet].";

StructureFactor::ElementMismatch = "Element mismatch detected.";

Options @ StructureFactor = SortBy[Normal @ Union[Association @ Options
     @ GetAtomicScatteringFactors, Association @ Options @ GetElements, <|
    "AbsoluteValue" -> True, "IgnoreSystematicAbsence" -> False, "Threshold"
     -> Power[10., -6], "Units" -> True|>], ToString[#[[1]]]&];

SyntaxInformation @ StructureFactor = {"ArgumentsPattern" -> {_, _, _.,
     OptionsPattern[{StructureFactor, GetAtomicScatteringFactors, GetElements
    }]}};

Begin["`Private`"];

StructureFactor[crystal_String, hklInput_List, lambda : _ ? (NumericQ[
    #] || QuantityQ[#]&) : -1, options : OptionsPattern[{StructureFactor,
     GetAtomicScatteringFactors, GetElements}]] :=
    Block[
        {data, \[Lambda], abs = TrueQ @ OptionValue["AbsoluteValue"],
             ignoreExtinct = TrueQ @ OptionValue["IgnoreSystematicAbsence"], unitsQ
             = TrueQ @ OptionValue["Units"], \[Delta] = OptionValue["Threshold"],
             hkl, L0, L, zeroType, absence, l, hklPos, j, H, d, sl, f, atomData, 
            r, type, displacementParameters, U, R, T, centeringVectors, occ, elements,
             siteSymMxyz, siteSymO, sf, SF, F, \[Phi]}
        ,
        (*---* Checking input *---*)
        InputCheck["CrystalQ", crystal, False];
        \[Lambda] = InputCheck["ProcessWavelength", crystal, lambda];
            
        data = $CrystalData[crystal];
        If[!NumericQ @ \[Delta],
            Message[StructureFactor::InvalidThreshold, \[Delta]];
            Abort[]
        ];
        hkl = InputCheck[hklInput, "Integer", "WrapSingle"];
        L0 = Length @ hkl;
        (*---* Systematically absent reflections *---*)
        If[!ignoreExtinct,
            zeroType =
                If[abs,
                    If[unitsQ,
                        {0, Quantity[0, "Degrees"]}
                        ,
                        {0, 0}
                    ]
                    ,
                    0
                ];
            absence = SystematicAbsentQ[crystal, hkl];
            l = Length @ absence;
            hkl = Pick[hkl, absence, False];
            hklPos = Position[absence, False];
            (* Return if only extinct reflections *)
            If[AllTrue[Flatten @ absence, TrueQ],
                If[l === 1,
                    Return @ zeroType
                    ,
                    Return @ ConstantArray[zeroType, l]
                ]
            ]
        ];
        (*---* Auxiliary and preparations *---*)
        L = Length @ hkl;
        H = Chop @ N @ GetCrystalMetric[crystal, "Space" -> "Reciprocal"
            ];
        sl = N[Sqrt[# . H . #] / 2]& /@ hkl;
        atomData = data["AtomData"];
        r = atomData[[All, "FractionalCoordinates"]];
        {R, T} = Transpose @ GetSymmetryOperations[crystal, "AugmentedMatrix"
             -> False];
        occ = Lookup[atomData, "OccupationFactor", 1.];
        type = Lookup[atomData, "Type", "Uiso"];
        centeringVectors = Length @ Quiet @ InputCheck["GetCentringVectors",
             crystal];
        siteSymMxyz = centeringVectors * Length @ R;
        (* Site symmetry order: siteSymO = siteSymMxyz / siteSymM *)
        elements = atomData[[All, "Element"]];
        If[TrueQ @ OptionValue["IgnoreIonCharge"],
            elements = StringDelete[elements, {DigitCharacter, "+", "-"
                }]
        ];
        f = GetAtomicScatteringFactors[crystal, hkl, \[Lambda], "SeparateCorrections"
             -> False, FilterRules[{options}, Options @ GetAtomicScatteringFactors
            ]];
        If[AssociationQ @ f,
            f = {f}
        ];
        If[Sort @ Keys @ First @ f =!= Sort @ DeleteDuplicates @ elements,
            
            Message[StructureFactor::ElementMismatch]
        ];
        (* Atomic displacement parameters preparation *)
        d = Chop @ N @ Sqrt @ DiagonalMatrix @ Diagonal @ H;
        displacementParameters = Lookup[atomData, "DisplacementParameters",
             0.];
        U = {};
        Do[
            If[Length @ displacementParameters[[i]] == 6,
                AppendTo[U, Partition[Part[displacementParameters[[i]],
                     {1, 4, 5, 4, 2, 6, 5, 6, 3}], 3]]
                ,
                AppendTo[U, displacementParameters[[i]]]
            ]
            ,
            {i, Length @ displacementParameters}
        ];
        Which[(* a. Extract 'SiteSymmetryOrder' from $CrystalData *)
            KeyExistsQ[First @ atomData, "SiteSymmetryOrder"],
                siteSymO = atomData[[All, "SiteSymmetryOrder"]]
            ,
            (* b. Calculate order from 'SiteSymmetryMultiplicity' *)KeyExistsQ[
                First @ atomData, "SiteSymmetryMultiplicity"],
                siteSymO = siteSymMxyz / atomData[[All, "SiteSymmetryMultiplicity"
                    ]]
            ,
            (* c. Calculate site symmetry order *)True,
                siteSymO = siteSymMxyz / Table[Length @ SymmetryEquivalentPositions[
                    crystal, r[[a]]], {a, Length @ r}]
        ];
        (*---* Structure factor calculation *---*)
        (* Magnitude *)
        sf =
            Table[(* Table for each reflection *)Sum[
                    1 * occ[[j]](* Occupation factor *)* centeringVectors
                        
(* Centring vectors 


*)* 1.0 / siteSymO[[j]](* Symmetry reduction 
    
    
    *)* Part[f[[h]], elements[[j]]](* Atomic form factor *) *
                        Sum[
                            Which[(* Atomic displacement *)
                                    type[[j]] == "Uani",
                                        Exp[-2 Pi^2 * hkl[[h]] . d . 
                                            R[[s]] . U[[j]] . Transpose[R[[s]]] . d . hkl[[h]]]
                                    ,
                                    type[[j]] == "Uiso",
                                        Exp[-8 Pi^2 * displacementParameters
                                            [[j]] * (sl[[h]]) ^ 2]
                                    ,
                                    type[[j]] == "Bani",
                                        Exp[-1 / 4 * hkl[[h]] . d . R
                                            [[s]] . U[[j]] . Transpose[R[[s]]] . d . hkl[[h]]]
                                    ,
                                    type[[j]] == "Biso", (* Temperature factor 
                                        
                                        
                                        
                                        
                                        
                                        *)Exp[-displacementParameters
    [[j]] * (sl[[h]]) ^ 2]
                                    ,
                                    True,
                                        Message[$CrystalData::type, type
                                            ];
                                        Abort[]
                                ] * Exp[2 Pi * I (hkl[[h]] . R[[s]] .
                                     r[[j]] + hkl[[h]] . T[[s]])]
                            ,
                            {s, Length @ R}
                        ]
                    ,
                    {j, Length @ atomData}
                ]
                ,
                {h, L}
            ];
        (* Phase *)
        If[!abs,
            SF = sf;
            Goto["ComplexNumber"]
        ];
        SF = Reap[
                Do[
                    F = sf[[i]];
                    If[(* a. Check threshold *)Abs @ Re @ F < \[Delta],
                        
                        Sow[{0, 0}]
                        ,
                        (* b. Calculate *)
                        Which[
                            Re[F] == 0. && Im[F] >= 0,
                                F = 0;
                                \[Phi] = 90
                            ,
                            Re[F] == 0. && Im[F] < 0,
                                sf[[i]] = 0;
                                \[Phi] = -90
                            ,
                            Re[F] >= 0. && Im[F] == 0,
                                \[Phi] = 90
                            ,
                            Re[F] < 0. && Im[F] == 0,
                                \[Phi] = 180
                            ,
                            Re[F] > 0. && Im[F] > 0,
                                \[Phi] = N[ArcTan[Abs[Im[F] / Re[F]]]
                                     / Degree]
                            ,
                            Re[F] > 0. && Im[F] < 0,
                                \[Phi] = -N[ArcTan[Abs[Im[F] / Re[F]]
                                    ] / Degree]
                            ,
                            Re[F] < 0. && Im[F] > 0,
                                \[Phi] = N[(Pi - ArcTan[Abs[Im[F] / Re[
                                    F]]]) / Degree]
                            ,
                            Re[F] < 0. && Im[F] < 0,
                                \[Phi] = N[(ArcTan[Abs[Im[F] / Re[F]]
                                    ] - Pi) / Degree]
                        ];
                        Sow[{F, \[Phi]}]
                    ]
                    ,
                    {i, L}
                ]
            ][[2, 1]];
        (*---* Preparing output *---*)
        (* Processing units *)
        If[unitsQ,
            SF = MapAt[Quantity[#, "Degrees"]&, SF, {All, 2}]
        ];
        (* a. Return absolute value and phase *)
        SF = MapAt[Abs, SF, {All, 1}];
        (* b. Return complex number *)
        Label["ComplexNumber"];
        (* Putting back extinct reflections *)
        If[L0 > 1 && !ignoreExtinct,
            SF = ReplacePart[ConstantArray[zeroType, l], Thread[hklPos
                 -> SF]]
        ];
        If[L0 === 1,
            First @ SF
            ,
            SF
        ]
    ]

End[];
