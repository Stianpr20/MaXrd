GetLaueClass::missing = "No data found on \[LeftGuillemet]`1`\[RightGuillemet].";

SyntaxInformation @ GetLaueClass = {"ArgumentsPattern" -> {_}};

Begin["`Private`"];

GetLaueClass[symbol_String] :=
    Block[
        {g, extract}
        ,
        (* $CrystalData *)
        g = $CrystalData[symbol]["SpaceGroup"];
        If[StringQ @ g,
            Goto["End"]
        ];
        (* Special case: -3m *)
        Which[
            symbol == "\!\(\*OverscriptBox[\(3\), \(_\)]\)1m" || symbol == "-31m",
                Return["\!\(\*OverscriptBox[\(3\), \(_\)]\)1m"]
            ,
            symbol == "\!\(\*OverscriptBox[\(3\), \(_\)]\)m:r" || symbol == "-3m:r",
                Return["\!\(\*OverscriptBox[\(3\), \(_\)]\)m:r"]
            ,
            True,
                Null
        ];
        (* Point group or space group *)
        g = $GroupSymbolRedirect[symbol]["LaueClass"];
        If[StringQ @ g,
            Return @ g
        ];
        (* Point group or space group (alternative setting) *)
        extract = FullForm[Quiet @ Extract[$GroupSymbolRedirect, symbol, Inactivate]][[1, 1]];
        g = $GroupSymbolRedirect[extract]["LaueClass"];
        (* No match *)
        If[!StringQ @ g,
            Message[GetLaueClass::missing, symbol];
            Abort[]
            ,
            Return @ g
        ];
        (* End (for use with $CrystalData) *)
        Label["End"];
        GetLaueClass[g]
    ]

End[];
