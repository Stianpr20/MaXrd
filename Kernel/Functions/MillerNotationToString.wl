MillerNotationToString::inv = "Invalid index input \[LeftGuillemet]`1`\[RightGuillemet].";

SyntaxInformation @ MillerNotationToString = {"ArgumentsPattern" -> {{_, _, _}}};

Begin["`Private`"];

MillerNotationToString[inputRaw_List] :=
    Block[
        {L, R, quit, i, H, index, input = inputRaw, presentation, output}
        ,
        (* Input check *)
        Check[InputCheck @ inputRaw, Goto["End"]];
        (* Shortcuts *)
        L = "\!\(\*OverscriptBox[\(";
        R = "\), \(_\)]\)";
        quit[index_] :=
            (
                Message[MillerNotationToString::inv, index];
                Goto["End"]
            );
        (* Pre-processing input *)
        input = input /. x_String /; StringContainsQ[x, "-"] :> -StringDelete[x, "-"];
        (* Converting to string with over bar if negative *)
        H = {};
        Do[
            index = input[[i]];
            Which[
                IntegerQ @ index,
                    If[index < 0,
                        AppendTo[H, L <> ToString[-index] <> R]
                        ,
                        AppendTo[H, ToString @ index]
                    ]
                ,
                StringQ @ index,
                    If[StringLength @ index != 1,
                        quit[index]
                        ,
                        AppendTo[H, index]
                    ]
                ,
                Head[index] === Real,
                    AppendTo[H, ToString @ index]
                ,
                Head[index] === Times,
                    If[(index[[1]] === -1) && (StringQ @ index[[2]]),
                        If[StringLength @ index[[2]] != 1,
                            quit[index]
                            ,
                            AppendTo[H, L <> index[[2]] <> R]
                        ]
                        ,
                        quit[index]
                    ]
                ,
                True,
                    quit[index]
            ]
            ,
            {i, 3}
        ];
        (* Presentation *)
        presentation = StringJoin["(" <> H[[1]] <> "|" <> H[[2]] <> "|" <> H[[3]] <> ")"];
        (* Only remove commas for single digit integers *)
        If[AllTrue[Select[input, NumericQ], (Abs[#] <= 9) && IntegerQ[#]&],
            output = StringDelete[presentation, "|"]
            ,
            output = StringReplace[presentation, "|" -> ","]
        ];
        Return @ output;
        Label["End"];
        input
    ]

MillerNotationToString[input_String] :=
    MillerNotationToString @ MillerNotationToList @ input

End[];
