Options @ CrystalDensity = {"Units" -> True};

SyntaxInformation @ CrystalDensity = {"ArgumentsPattern" -> {_, OptionsPattern[
    ]}};

Begin["`Private`"];

CrystalDensity[crystal_String, OptionsPattern[]] :=
    Block[
        {data, unitsQ, Z, f, m, V, NA, element, o, xyz, M, mass, temp
            }
        ,
        (*---* Input check *---*)
        InputCheck["CrystalQ", crystal];
        data = $CrystalData[crystal];
        unitsQ = OptionValue["Units"];
        (* Return density if contained in '$CrystalData' *)
        temp = data["MassDensity"];
        If[!MissingQ[temp],
            Return @ temp
        ];
        (* Lookup formula units *)
        Z = Lookup[data, "FormulaUnits", -1];
        (*---* Calculations *---*)
        (*--* Common variables *--*)
        (* Volume, converted to cm^3 *)
        V = Sqrt @ Det @ GetCrystalMetric @ crystal;
        If[unitsQ,
            V = Quantity[V * 10 ^ (-24), "Centimeters"^3]
            ,
            V = V * 10 ^ (-24)
        ];
        (* Chemical formula *)
        f = Sort @ GetElements[crystal, "Tally" -> True];
        If[Positive @ Z,
            (*--* A. Calculate \[Rho] from Z *--*)
            (* Atomic mass of one unit *)
            m = MapAt[$PeriodicTable[#, "StandardAtomicWeight"]&, f, 
                {All, 1}];
            m = Total[Times @@ #& /@ m];
            If[unitsQ,
                m = Quantity[m, "Grams" / "Moles"]
            ];
            (* Avogadro's constant *)
            If[unitsQ,
                NA = UnitConvert[Quantity["AvogadroConstant"], "Moles"
                     ^ (-1)]
                ,
                NA = 6.022140857*^23
            ];
            (* Calculating \[Rho] *)
            Return[(Z * m) / (V * NA)]
            ,
(*--* B. Calculate \[Rho] from atom data, symmetry and occupation *--
    
    
    
    *)
            (* Elements, occupation factors and coordinates *)
            {element, o, xyz} = Transpose @ Values @ data[["AtomData",
                 All, {"Element", "OccupationFactor", "FractionalCoordinates"}]];
            element = StringDelete[element, {DigitCharacter, "+", "-"
                }];
            o = o /. _Missing -> 1.;
            (* Site multiplicities *)
            M = o * (Length /@ (SymmetryEquivalentPositions[data["SpaceGroup"
                ], xyz]));
            (* Counting *)
            temp = Transpose /@ GatherBy[Transpose[{element, M}], First
                ];
            temp = Sort[temp /. {x_List, m_List} /; Depth[x] === 2 :>
                 {First @ x, Total @ m}];
            (* Total atom mass *)
            mass = Total[temp /. {element_String, f_?NumericQ} :> f *
                 $PeriodicTable[element, "StandardAtomicWeight"]];
            If[unitsQ,
                mass = UnitConvert[Quantity[mass, "AtomicMassUnit"], 
                    "Grams"]
                ,
                mass = mass * (1.6605390*^-24)
            ];
            (* Calculated density *)
            Return[mass / V]
        ]
    ]

End[];
