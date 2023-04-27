SyntaxInformation @ MillerNotationToList = {"ArgumentsPattern" -> {_}};

Begin["`Private`"];

MillerNotationToList[input_String] :=
    Block[
        {L, R, temp, split}
        ,
        (* Removing over bars *)
        L = "\!\(\*OverscriptBox[\(";
        R = "\), \(_\)]\)";
        temp = StringReplace[input, L ~~ Shortest @ x__ ~~ R :> "|" <> "-" <> x <> "|"];
        (* Separating indices *)
        temp =
            StringReplace[
                temp
                ,
                (* Sign *)
                s : {"", "-", "|"} ~~
                        {
                            (* Letters are not joined with digits *)x:LetterCharacter
                            ,
                            (* Digits could be joined *)
                            d:DigitCharacter ~~ y : Shortest[{"|", DigitCharacter.. ~~ {",", "|", ")"}}]
                        } :> "|" <> s <> x <> d <> y <> "|"
            ];
        temp = StringReplace[temp, "|" -> ","];
        temp = StringSplit[temp, ","];
        (* Special case: Positive single digits/letters only *)
        If[Length @ temp < 3,
            temp = StringCases[temp, x:WordCharacter :> x];
            temp = Flatten @ DeleteCases[temp, {}]
        ];
        (* Trimming *)
        temp = StringDelete[temp, {"(", ")"}];
        temp = DeleteCases[temp, x_ /; MemberQ[{"", Null, "{}"}, x]];
        (* If not three entires, split digits *)
        split[x_] := Flatten @ StringCases[x, {p : {"", "-"} ~~ n:DigitCharacter :> p ~~ n, n1:DigitCharacter ~~ n2:DigitCharacter :> {n1, n2}}];
        temp = temp /. x_List /; Length[x] < 3 :> split[x];
        (* Setting numbers as expressions *)
        temp /. x_String /; StringContainsQ[x, DigitCharacter] :> ToExpression[x]
    ]

End[];
