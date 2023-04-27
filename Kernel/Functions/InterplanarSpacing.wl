Options @ InterplanarSpacing = {"Units" -> True};

SyntaxInformation @ InterplanarSpacing = {"ArgumentsPattern" -> {_, _, OptionsPattern[]}};

Begin["`Private`"];

InterplanarSpacing[input_, reflections_List, OptionsPattern[]] :=
    Block[
        {hkl, H, d, h}
        ,
        (* Check reflection *)
        hkl = InputCheck[reflections, "Integer", "WrapSingle"];
        (* Reciprocal metric *)
        H = GetCrystalMetric[input, "Space" -> "Reciprocal"];
        (* Interplanar distance *)
        d = Reap[
                Do[
                    h = hkl[[i]];
                    Sow[1 / Sqrt[h . H . h]]
                    ,
                    {i, Length @ hkl}
                ]
            ][[2, 1]];
        (* Option: Units *)
        If[OptionValue["Units"],
            d = Quantity[d, "Angstroms"]
        ];
        (* If only one reflection, return content *)
        If[Length @ d == 1,
            First @ d
            ,
            d
        ]
    ]

End[];
