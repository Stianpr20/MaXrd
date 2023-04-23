Options @ DarwinWidth =
    {
        "Units" -> True
        ,
        (* ExtinctionLength *)
        "Polarisation" -> "\[Pi]"
    };

SyntaxInformation @ DarwinWidth = {"ArgumentsPattern" -> {_, _, _., _.,
     OptionsPattern[]}};

Begin["`Private`"];

DarwinWidth[crystal_, lambda : _ ? (NumericQ[#] || QuantityQ[#]&) : -
    1, hklInput_List, \[Gamma]o : _?NumericQ : 1.0, \[Gamma]h : _?NumericQ
     : 1.0, OptionsPattern[]] :=
    Block[
        {hkl, L, \[Lambda], \[Theta], \[CapitalLambda]o, \[Delta]os}
        ,
        (* Check input *)
        InputCheck["CrystalQ", crystal];
        hkl = InputCheck[hklInput, "Integer", "WrapSingle"];
        L = Length @ hkl;
        \[Lambda] = InputCheck["ProcessWavelength", crystal, lambda];
            
        (* Miscellaneous preparations *)
        \[Theta] = BraggAngle[crystal, \[Lambda], hkl, "Units" -> False
            ] * Degree;
        \[CapitalLambda]o = ExtinctionLength[crystal, \[Lambda], hkl,
             \[Gamma]o, \[Gamma]h, "Polarisation" -> OptionValue["Polarisation"],
             "Units" -> False];
        (* Darwin width *)
        \[Delta]os =
            2 * \[Lambda] / \[CapitalLambda]o * \[Gamma]h / Sin[2 \[Theta]
                ] * (1(* \[Mu]m *)/ (10^4)(* \[CapitalARing] *)) *
                (
                    (10^6) (* \[Mu]rad 
            *)/ 1(* rad *) );
        \[Delta]os = Flatten[{Chop @ \[Delta]os}];
        (* Option: Units *)
        If[OptionValue["Units"],
            \[Delta]os = \[Delta]os /. x_?NumericQ :> Quantity[x, "Microradians"
                ]
        ];
        If[L === 1,
            First @ \[Delta]os
            ,
            \[Delta]os
        ]
    ]

End[];
