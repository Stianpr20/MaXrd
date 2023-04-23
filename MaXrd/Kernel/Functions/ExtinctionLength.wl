Options @ ExtinctionLength = {"Polarisation" -> "\[Pi]", "Units" -> True
    };

SyntaxInformation @ ExtinctionLength = {"ArgumentsPattern" -> {_, _, 
    _., _., OptionsPattern[]}};

Begin["`Private`"];

ExtinctionLength[crystal_, lambda : _ ? (NumericQ[#] || QuantityQ[#]&
    ) : -1, hklInput_List, \[Gamma]o : _?NumericQ : 1, \[Gamma]h : _?NumericQ
     : 1, OptionsPattern[]] :=
    Block[
        {sg, hkl, L, \[Lambda], V, \[Theta], R, \[CapitalChi], structureFactorBar,
             g, \[CapitalLambda]o, temp}
        ,
        (* Check input *)
        InputCheck["CrystalQ", crystal];
        sg = $CrystalData[crystal, "SpaceGroup"];
        hkl = InputCheck[hklInput, "Integer", "WrapSingle"];
        L = Length @ hkl;
        (* Wavelength *)
        \[Lambda] = InputCheck["ProcessWavelength", crystal, lambda];
            
        (* Unit cell volume *)
        V = Sqrt @ Det @ GetCrystalMetric[crystal];
        (* Classical electron radius *)
        R =
            If[OptionValue["Units"],
                QuantityMagnitude @ UnitConvert[Quantity["ClassicalElectronRadius"
                    ], "Angstroms"]
                ,
                2.81794032 * Power[10, -5]
            (* \[ARing]ngstr\[ODoubleDot]ms *)];
        (* Bragg angle and polarisation *)
        \[Theta] = BraggAngle[crystal, \[Lambda], hkl, "Units" -> False
            ] * Degree;
        \[CapitalChi] = Flatten[{InputCheck["Polarisation", OptionValue[
            "Polarisation"], 2 \[Theta]]}];
        (* Structure factors *)
        temp = StructureFactor[crystal, #, \[Lambda], "Units" -> False
            ]& /@ {hkl, -hkl};
        temp = Cases[temp, {F_?NumericQ, \[Phi]_?NumericQ} :> F, 3];
        structureFactorBar = Times @@ ArrayReshape[temp, {2, L}];
        (* Extinction (Pendell\[ODoubleDot]sung) distance *)
        If[\[Gamma]o === \[Gamma]h === 1,
            g = 1
            ,
            g = \[Pi] * Sqrt[\[Gamma]o * Abs[\[Gamma]h]]
        ]; (* geometrical factor *)
        \[CapitalLambda]o = Reap[
                Do[
                    Quiet @
                        Sow[
                            (V * g) / (R * \[Lambda] * \[CapitalChi][[
                                i]] * Sqrt @ structureFactorBar[[i]]) *
                                (
                                    1(* \[Mu]m *)/ (10^4)(* \[CapitalARing] 
                                        
                                        
                                        
            *) )
                        ]
                    ,
                    {i, L}
                ]
            ][[2, 1]];
        \[CapitalLambda]o = \[CapitalLambda]o /. ComplexInfinity -> Undefined
            ;
        (* Option: Units *)
        If[OptionValue["Units"],
            \[CapitalLambda]o = \[CapitalLambda]o /. x_?NumericQ :> Quantity[
                x, "Micrometers"]
        ];
        If[L === 1,
            First @ \[CapitalLambda]o
            ,
            \[CapitalLambda]o
        ]
    ]

End[];
