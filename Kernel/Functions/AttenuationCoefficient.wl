AttenuationCoefficient::invalidSource = "The source \[LeftGuillemet]`1`\[RightGuillemet] is invalid.";

AttenuationCoefficient::invalidCoefficient = "The \[LeftGuillemet]`1`\[RightGuillemet] coefficient is not recognised.";

AttenuationCoefficient::peOnly = "Only the photoelectric cross section is related to \!\(\*
StyleBox[FormBox[SuperscriptBox[\"f\", \"\[Prime]\[Prime]\",\nMultilineFunction->None],
TraditionalForm], \"TI\"]\).";

AttenuationCoefficient::asfLambda = "The wavelength, `1` \[CapitalARing], must be smaller than 2.5 \[CapitalARing] when using \!\(\*
StyleBox[FormBox[SuperscriptBox[\"f\", \"\[Prime]\[Prime]\",\nMultilineFunction->None],
TraditionalForm], \"TI\"]\).";

Options @ AttenuationCoefficient =
    {
        "Coefficient" -> "LinearAttenuation"
        ,
        "MassCoefficientMethod" -> "DivideByDensity"
        ,
        (* GetScatteringCrossSections *)
        "PhysicalProcess" -> ""
        ,
        "Source" -> "xraylib"
        ,
        "Units" -> True
    };

SyntaxInformation @ AttenuationCoefficient = {"ArgumentsPattern" -> {_, _., OptionsPattern[]}};

Begin["`Private`"];

AttenuationCoefficient[crystal_String, lambda : _ ? (NumericQ[#] || QuantityQ[#]&) : -1, OptionsPattern[]] :=
    Block[
        {\[Lambda], unitsQ = TrueQ @ OptionValue["Units"], coefficient = OptionValue["Coefficient"], mcMethod = OptionValue["MassCoefficientMethod"], source = OptionValue["Source"], pp = OptionValue["PhysicalProcess"], csDir, asfFile, V, \[Sigma], \[CapitalSigma], column, atomData, r, siteM, fpp, re, \[Mu], \[Rho]}
        ,
        (*---* Checking input *---*)
        InputCheck["CrystalQ", crystal];
        \[Lambda] = InputCheck["ProcessWavelength", crystal, lambda];
        csDir = FileNameJoin[{$MaXrdPath, "Kernel", "Data", "CrossSections", source}];
        asfFile = FileNameJoin[{$MaXrdPath, "Kernel", "Data", "AtomicScatteringFactor", "AnomalousCorrections", source <> ".m"}];
        If[DirectoryQ[csDir] \[Nor] FileExistsQ[asfFile],
            Message[AttenuationCoefficient::invalidSource, source];
            Abort[]
        ];
        (* Processing cross section type *)
        If[(* a. Select 'PhysicalProcess' manually *)pp =!= "",
            column =
                Which[
                    MemberQ[{"Photoelectric", "Photoionisation"}, pp],
                        2
                    ,
                    MemberQ[{"Coherent", "Rayleigh", "Thompson", "Classical", "Elastic"}, pp],
                        3
                    ,
                    MemberQ[{"Incoherent", "Compton", "Inelastic"}, pp],
                        4
                    ,
                    pp === "Total",
                        5
                    ,
                    True,
                        Message[AttenuationCoefficient::invalidProcess, pp];
                        Abort[]
                ]
            ,
            (* b. Select automatically based on coefficient type *)
            column =
                Which[
                    MemberQ[{"LinearAttenuation", "MassAbsorption"}, coefficient],
                        5
                    ,(* Total = ph.el. + Ray. + Comp. *)True,
                        Message[AttenuationCoefficient::invalidCoefficient, coefficient];
                        Abort[]
                ]
        ];
        (*---* Calculations *---*)
        (* Auxiliary variables *)
        V = Sqrt @ Det @ GetCrystalMetric @ crystal;
        (* Calculation method *)
        If[DirectoryQ @ csDir,
            (* a. Using cross sections *)
            \[Sigma] = Normal @ GetScatteringCrossSections[crystal, \[Lambda], "PhysicalProcess" -> pp, "Source" -> source, "Units" -> False];
            (* Multiplying atoms with corresponding cross sections *)
            atomData = Values @ $CrystalData[[crystal, "AtomData", All, {"Element", "FractionalCoordinates", "OccupationFactor"}]];
            atomData[[All, 1]] = StringDelete[atomData[[All, 1]], {"+", "-", DigitCharacter}];
            atomData = atomData /. Join[\[Sigma], {Missing["KeyAbsent", "OccupationFactor"] -> 1}];
            r = atomData[[All, 2]];
            siteM = Table[Length @ SymmetryEquivalentPositions[crystal, r[[a]], "UseCentring" -> True], {a, Length @ r}];
            atomData[[All, 2]] = siteM;
            \[CapitalSigma] = Total[Times @@@ atomData];
            \[Mu] = \[CapitalSigma] / V
            ,
            (* b. Using f-double-prime *)
            (* Check wavelength *)
            If[\[Lambda] > 2.5,
                Message[AttenuationCoefficient::asfLambda, ToString @ \[Lambda]];
                Abort[]
            ];
            column = 3; (* Force p.e. cross section only *)
            re = 2.81794032*^-15;
            fpp = Im @ StructureFactor[crystal, {0, 0, 0}, \[Lambda], "AbsoluteValue" -> False, "f1f2Source" -> source];
            (* (See formula in documentation page details) *)
            \[Mu] = 2 * re * \[Lambda] / V * Abs[fpp] * Power[10, 18]
        ];
        (* Normalise by mass density? *)
        If[coefficient === "MassAbsorption" && mcMethod === "DivideByDensity",
            \[Rho] = CrystalDensity[crystal, "Units" -> False];
            If[unitsQ,
                Return @ Quantity[\[Mu] / \[Rho], "Centimeters"^2 / "Grams"]
                ,
                Return[\[Mu] / \[Rho]]
            ]
        ];
        (* Output linear coefficient *)
        If[unitsQ,
            Quantity[\[Mu], "Centimeters" ^ (-1)]
            ,
            \[Mu]
        ]
    ]

End[];
