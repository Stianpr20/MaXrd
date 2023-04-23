GetCrystalMetric::InvalidCategory = "Category must be either \"LatticeParameters\" or \"MetricMatrix\".";

GetCrystalMetric::InvalidSpace = "\"Space\" must either be \"Direct\", \"Reciprocal\" or \"Both\".";

GetCrystalMetric::InvalidMatrix = "Input metric must be a 3\[Times]3 matrix.";

GetCrystalMetric::InvalidList = "Expected six numerical lattice parameters.";

GetCrystalMetric::InvalidAssociation = "Association expected to contain six lattice parameters with keys \"a\", \"b\", \"c\", \"\[Alpha]\", \"\[Beta]\" and \"\[Gamma]\".";

GetCrystalMetric::InvalidInput = "Unable to interpret \[LeftGuillemet]`1`\[RightGuillemet].";

Options @ GetCrystalMetric = {"Category" -> "MetricMatrix", "Radians"
     -> False, "RoundAnglesThreshold" -> 0.001, "Space" -> "Direct", "ToCartesian"
     -> False, "Units" -> False};

SyntaxInformation @ GetCrystalMetric = {"ArgumentsPattern" -> {_, OptionsPattern[
    ]}};

Begin["`Private`"];

GetCrystalMetric[userInput_, options : OptionsPattern[]] :=
    Block[{outputCategory = OptionValue["Category"], outputSpace = OptionValue[
        "Space"], reciprocalInputQ, latticeParameters, outputSettings},
        If[!MemberQ[{"LatticeParameters", "MetricMatrix"}, outputCategory
            ],
            Message[GetCrystalMetric::InvalidCategory];
            Abort[]
        ];
        If[!MemberQ[{"Direct", "Reciprocal", "Both"}, outputSpace],
            Message[GetCrystalMetric::InvalidSpace];
            Abort[]
        ];
        latticeParameters = GCM$ExtractLatticeParameters @ userInput;
            
        reciprocalInputQ = AnyTrue[latticeParameters, CompatibleUnitQ[
            #, Quantity[1 / "Angstroms"]]&];
        latticeParameters = GCM$StandardizeLatticeParameters[latticeParameters,
             reciprocalInputQ];
        outputSettings = <|"LatticeQ" -> outputCategory === "LatticeParameters",
             "Threshold" -> OptionValue["RoundAnglesThreshold"], "ReciprocalQ" ->
             outputSpace === "Reciprocal", "UnitsQ" -> TrueQ @ OptionValue["Units"
            ], "RadiansQ" -> TrueQ @ OptionValue["Radians"], "OrthogonalizeQ" -> 
            TrueQ @ OptionValue["ToCartesian"]|>;
        If[outputSpace === "Both",
            GCM$DeliverOutput[latticeParameters, ReplacePart[outputSettings,
                 "ReciprocalQ" -> #]]& /@ {False, True}
            ,
            GCM$DeliverOutput[latticeParameters, outputSettings]
        ]
    ]

GCM$DeliverOutput[latticeParameters_, settings_] :=
    (If[settings["LatticeQ"],
        GCM$DeliverLatticeParameterOutput
        ,
        GCM$DeliverMetricMatrixOutput
    ][latticeParameters, settings])

GCM$DeliverLatticeParameterOutput[latticeParameters_, settings_] :=
    Block[{output = latticeParameters, \[Delta], reciprocalQ, unitsQ,
         radiansQ},
        {\[Delta], reciprocalQ, unitsQ, radiansQ} = Lookup[settings, 
            {"Threshold", "ReciprocalQ", "UnitsQ", "RadiansQ"}];
        If[reciprocalQ,
            output = GCM$FlipLatticeParameters @ output
        ];
        output = GCM$RoundAngles[output, \[Delta]];
        If[unitsQ,
            output = GCM$ApplyUnitsList[output, reciprocalQ]
        ];
        If[radiansQ,
            output[[4 ;; 6]] *= \[Pi] / 180
        ];
        output
    ]

GCM$DeliverMetricMatrixOutput[latticeParameters_, settings_] :=
    Block[{output = latticeParameters, reciprocalQ, unitsQ, orthogonalizeQ
        },
        {reciprocalQ, unitsQ, orthogonalizeQ} = Lookup[settings, {"ReciprocalQ",
             "UnitsQ", "OrthogonalizeQ"}];
        output = GCM$MakeMetricFromLatticeParameters @ output;
        If[reciprocalQ,
            output = Inverse @ output
        ];
        If[unitsQ,
            output = GCM$ApplyUnitsMatrix[output, reciprocalQ]
        ];
        If[orthogonalizeQ,
            output = CholeskyDecomposition @ output
        ];
        output
    ]

GCM$ExtractLatticeParameters[userInput_] :=
    Block[{temp},
        Switch[userInput,
            _String,
                temp = InputCheck["CrystalQ", userInput, False];
                temp = temp["LatticeParameters"];
                GCM$ExtractLatticeParameters @ temp
            ,
            _?MatrixQ,
                If[!Dimensions[userInput] === {3, 3},
                    Message[GetCrystalMetric::InvalidMatrix];
                    Abort[]
                ];
                GCM$MakeLatticeParametersFromMetric @ userInput
            ,
            _Association,
                temp = Lookup[userInput, {"a", "b", "c", "\[Alpha]", 
                    "\[Beta]", "\[Gamma]"}];
                If[AnyTrue[temp, MissingQ],
                    Message[GetCrystalMetric::InvalidAssociation];
                    Abort[]
                ];
                temp
            ,
            _List,
                If[!AllTrue[userInput, NumericQ[#] || QuantityQ[#]&] 
                    || Length[userInput] != 6,
                    Message[GetCrystalMetric::InvalidList];
                    Abort[]
                ];
                userInput
            ,
            _,
                Message[GetCrystalMetric::InvalidInput, userInput];
                Abort[]
        ]
    ];

GCM$MakeMetricFromLatticeParameters[latticeParameters_] :=
    Block[{a, b, c, \[Alpha], \[Beta], \[Gamma]},
        {a, b, c, \[Alpha], \[Beta], \[Gamma]} = latticeParameters;
        {\[Alpha], \[Beta], \[Gamma]} *= \[Pi] / 180;
        N @ Chop[{{a^2, a * b * Cos[\[Gamma]], a * c * Cos[\[Beta]]},
             {a * b * Cos[\[Gamma]], b^2, b * c * Cos[\[Alpha]]}, {a * c * Cos[\[Beta]
            ], b * c * Cos[\[Alpha]], c^2}}]
    ]

GCM$MakeLatticeParametersFromMetric[matrix_] :=
    Block[{a, b, c, \[Alpha], \[Beta], \[Gamma]},
        {a, b, c} = Sqrt @ Diagonal @ matrix;
        \[Alpha] = ArcCos[matrix[[2, 3]] / (b * c)] / Degree;
        \[Beta] = ArcCos[matrix[[1, 3]] / (a * c)] / Degree;
        \[Gamma] = ArcCos[matrix[[1, 2]] / (a * b)] / Degree;
        {a, b, c, \[Alpha], \[Beta], \[Gamma]}
    ]

GCM$StandardizeLatticeParameters[latticeParameters_List, reciprocalQ_
    :False] :=
    Block[{cell = latticeParameters, lengths, angles},
        {lengths, angles} = Part[cell, #]& /@ {1 ;; 3, 4 ;; 6};
        lengths =
            lengths /.
                q_Quantity :>
                    UnitConvert[
                        q
                        ,
                        If[TrueQ @ reciprocalQ,
                            1 / "Angstroms"
                            ,
                            "Angstroms"
                        ]
                    ];
        angles = angles /. q_Quantity :> UnitConvert[q, "Degrees"];
        cell = N @ QuantityMagnitude[Join @@ {lengths, angles}];
        If[TrueQ @ reciprocalQ,
            cell = GCM$FlipLatticeParameters @ cell
        ];
        cell
    ]

GCM$RoundAngles[cell_List, threshold_] :=
    Block[{temp = cell, fr},
        Do[
            fr = FractionalPart @ temp[[i]];
            If[fr > 0.5,
                fr = 1 - fr
            ];
            If[fr <= threshold,
                temp[[i]] = Round @ temp[[i]]
            ]
            ,
            {i, 4, 6}
        ];
        temp
    ]

GCM$ApplyUnitsList[cell_, reciprocalQ_:False] :=
    Quantity[#1, #2]& @@@
        Transpose[
            {
                cell
                ,
                {#1, #1, #1, #2, #2, #2}& @@
                    {
                        If[TrueQ @ reciprocalQ,
                            1 / "Angstroms"
                            ,
                            "Angstroms"
                        ]
                        ,
                        "Degrees"
                    }
            }
        ]

GCM$ApplyUnitsMatrix[metric_, reciprocalQ_:False] :=
    Quantity[
        metric
        ,
        Evaluate @
            If[TrueQ @ reciprocalQ,
                1 / "Angstroms"^2
                ,
                "Angstroms"^2
            ]
    ]

GCM$FlipLatticeParameters[latticeParameters_List] :=
    Block[{metric},
        metric = GCM$MakeMetricFromLatticeParameters @ latticeParameters
            ;
        GCM$MakeLatticeParametersFromMetric @ Inverse @ metric
    ]

End[];
