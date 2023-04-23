BraggAngle::invalidInput = "Input must either be the name of a crystal or a metric matrix.";

Options @ BraggAngle = {"AngleThreshold" -> 90. * Degree, "Units" -> 
    True};

SyntaxInformation @ BraggAngle = {"ArgumentsPattern" -> {_, _., _, OptionsPattern[
    ]}};

Begin["`Private`"];

BraggAngle[input_, lambda : _ ? (NumericQ[#] || QuantityQ[#]&) : -1, 
    reflections_List, OptionsPattern[]] :=
    Block[
        {hkl, G, H, \[Lambda] = N @ lambda, sl, bragg, angle, angleThreshold
            }
        ,
        (* Check crystal (or metric) and reflection(s) *)
        Which[
            StringQ @ input,
                InputCheck["CrystalQ", input];
                G = GetCrystalMetric @ input
            ,
            MatrixQ @ input,
                G = input
            ,
            True,
                Message[BraggAngle::invalidInput];
                Abort[]
        ];
        hkl = InputCheck[reflections, "Integer", "WrapSingle"];
        (* Reciprocal metric *)
        H = Chop @ N @ Inverse @ G;
        (* Process wavelength *)
        \[Lambda] =
            If[MatrixQ @ input,
                InputCheck["GetEnergyWavelength", \[Lambda], False]
                ,
                InputCheck["ProcessWavelength", input, \[Lambda]]
            ];
        (* Sin/lambda, from Bragg's law and inner product *)
        sl[h_] := Sqrt[h . H . h] / 2.;
        bragg[h_] := N[ArcSin[sl[h] * \[Lambda]]] /. x_Complex -> Undefined
            ;
        angle = bragg /@ hkl;
        (* Optional: Truncate at chosen angle threshold *)
        angleThreshold = OptionValue["AngleThreshold"];
        If[0 <= angleThreshold < \[Pi] / 2,
            angle = Select[angle, (# <= angleThreshold)&]
        ];
        angle = angle / Degree;
        (* Option: Units *)
        If[OptionValue["Units"],
            angle = Quantity[angle, "Degrees"];
            angle = angle /. Quantity[Undefined, "Degrees"] -> Undefined
                
        ];
        (* If only one reflection, return content *)
        If[Length @ angle == 1,
            First @ angle
            ,
            angle
        ]
    ]

End[];
