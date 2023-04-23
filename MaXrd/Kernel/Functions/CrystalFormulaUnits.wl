CrystalFormulaUnits::mismatch = "Element mismatch detected.";

Options @ CrystalFormulaUnits = {"IgnoreHydrogen" -> True};

SyntaxInformation @ CrystalFormulaUnits = {"ArgumentsPattern" -> {_, 
    OptionsPattern[]}};

Begin["`Private`"];

CrystalFormulaUnits[crystal_String, OptionsPattern[]] :=
    Block[
        {data, \[Rho], f, fWithoutH, m, V, NA, X, nonHydrogenElement,
             o, xyz, M, Z, temp}
        ,
        (*---* Input check *---*)
        InputCheck["CrystalQ", crystal];
        data = $CrystalData[crystal];
        (* Return Z if contained in '$CrystalData' *)
        temp = data["FormulaUnits"];
        If[!MissingQ[temp],
            Return @ temp
        ];
        (* Lookup density *)
        \[Rho] = Lookup[data, "MassDensity", -1];
        (*---* Calculations *---*)
        (* Chemical formula *)
        f = Sort @ GetElements[crystal, "Tally" -> True];
        (* Atomic mass of one unit *)
        m = MapAt[$PeriodicTable[#, "StandardAtomicWeight"]&, f, {All,
             1}];
        m = Total[Times @@ #& /@ m];
        (* Volume [cubic centimeters] and Avogadro's constant *)
        V = Sqrt @ Det @ GetCrystalMetric[crystal] * Power[10, -24];
        NA = 6.022140857*^23;
        If[Positive @ \[Rho],
            (*--* A. Calculate Z from mass density *--*)
            (* Calculate formula units from density *)
            If[QuantityQ @ \[Rho],
                \[Rho] = QuantityMagnitude @ UnitConvert[\[Rho], "Grams"
                     / "Centimeters"^3]
            ];
            (* Calculate formula units from density *)
            Return[\[Rho] * V * NA / m]
            ,
(*--* B. Calculate Z by counting symmetry-generated atoms *--
    *)
            (* Elements, occupation factors and coordinates *)
            {X, o, xyz} = Transpose @ Values @ data[["AtomData", All,
                 {"Element", "OccupationFactor", "FractionalCoordinates"}]];
            X = StringDelete[X, {DigitCharacter, "+", "-"}];
            nonHydrogenElement = DeleteCases[X, "H"];
            o = o /. _Missing -> 1.;
            fWithoutH = Sort @ DeleteCases[f[[All, 1]], "H"];
            (* Check: Compare formula and atom data *)
            If[!TrueQ @ OptionValue["IgnoreHydrogen"],
                fWithoutH = f;
                nonHydrogenElement = X
            ];
            If[Sort @ DeleteDuplicates @ nonHydrogenElement =!= fWithoutH,
                
                Message[CrystalFormulaUnits::mismatch];
                Abort[]
            ];
            (* Site multiplicities *)
            M = o * (Length /@ (SymmetryEquivalentPositions[data["SpaceGroup"
                ], #]& /@ xyz));
            (* Counting *)
            temp = Transpose /@ GatherBy[Transpose[{X, M}], First];
            temp = Sort[temp /. {x_List, m_List} /; Depth[x] === 2 :>
                 {First @ x, Round @ Total @ m}];
            (* Check if hydrogen is ignored *)
            If[MemberQ[f, {"H", _}] && (!MemberQ[temp, {"H", _}]),
                f = DeleteCases[f, {"H", _}];
                temp = DeleteCases[temp, {"H", _}]
            ];
            (* Check agreement of 'Z' *)
            Z = temp[[All, 2]] / f[[All, 2]];
            (* a. Common integer factor *)
            If[MatchQ[DeleteDuplicates @ Z, {_Integer}],
                Return @ First @ Z
                ,
                (* b. Calculate density, then find Z *)
                \[Rho] = CrystalDensity[crystal, "Units" -> False];
                Z = (\[Rho] * V * NA) / (m);
                Return @ Z
            ]
        ]
    ]

End[];
