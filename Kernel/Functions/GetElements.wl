GetElements::InvalidFormula = "Invalid chemical formula.";

GetElements::InvalidElements = "Invalid elements detected: `1`.";

Options @ GetElements = {"IgnoreIonCharge" -> True, "Tally" -> False};

SetAttributes[GetElements, Listable];

SyntaxInformation @ GetElements = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

Begin["`Private`"];

GetElements[input_String, OptionsPattern[]] :=
    Block[
        {formula = input, patternX, groupX, tallyQ = TrueQ @ OptionValue["Tally"], elements, temp}
        ,
        (*---* Check input string *---*)
        (*--* A. Crystal name input *--*)
        If[MemberQ[Keys @ $CrystalData, input],
            (* a. Use chemical formula *)
            formula =
                Lookup[
                    $CrystalData @ input
                    ,
                    "ChemicalFormula"
                    ,
                    (* b. Return elements contained in 'AtomData' *)
                    elements = $CrystalData[[input, "AtomData", All, "Element"]];
                    If[tallyQ,
                        (* Return tally *)
                        Return @ Tally @ elements
                        ,
                        (* Return elements only *)
                        Return @ DeleteDuplicates @ elements
                    ]
                ]
        ];
        (*--* B. Chemical formula string *--*)
        If[StringContainsQ[ToString @ FullForm @ formula, "!"],
            (* a. Formatted string *)
            (* Considering the full form *)
            elements = ToString @ FullForm @ formula;
            (* Marking subscripts with '$' elements=StringReplace[elements,"\\), \\("\[Rule]"$"]; *)
            (* Cleaning the full form *)
            elements = StringDelete[elements, {"\\!\\(\\*SubscriptBox[\\(", "[\\(", "\\)]\\)", "\\), \\("}]
            ,
            (* b. Plain string *)
            elements = formula
        ];
        (*---* Useful local variables *---*)
        patternX = {_?UpperCaseQ ~~ _?LowerCaseQ, _?UpperCaseQ};
        groupX[string_] := StringCases[string, {x:patternX ~~ {n1 : DigitCharacter.. ~~ "." ~~ n2 : DigitCharacter..} :> {x, ToExpression[n1 <> "." <> n2]}, x:patternX ~~ n : DigitCharacter.. ~~ pm : {"+", "-"} :> {x, n ~~ pm}, x:patternX ~~ pm : {"+", "-"} ~~ n : DigitCharacter... :> {x, n ~~ pm}, x:patternX ~~ n : DigitCharacter... :> {x, ToExpression @ n}}] /. {"" -> "1", Null -> 1};
        (*---* Extracting symbols and numbers *---*)
        (* Distribute parenthesis subscripts *)
        elements = StringReplace[elements, "(" ~~ p__ ~~ ")" ~~ s : DigitCharacter.. :> StringJoin[ToString /@ Flatten @ MapAt[# * ToExpression[s]&, groupX @ p, {All, 2}]]];
        (* Group elements and corresponding subscripts *)
        elements = groupX @ elements;
        (* Check *)
        If[elements === {},
            Message[GetElements::InvalidFormula];
            Abort[]
        ];
        temp = elements[[All, 1]];
        temp = InputCheck["InterpretElement", temp];
        temp = DeleteDuplicates @ temp;
        temp = Complement[temp, Keys @ $PeriodicTable];
        If[temp =!= {},
            Message[GetElements::InvalidElements, ToString @ temp];
            Abort[]
        ];
        (* Merge equal elements *)
        If[!DuplicateFreeQ[First /@ elements],
            elements = MapAt[ToExpression, elements, {All, 2}];
            elements = GatherBy[elements, First];
            elements = elements /. x_ /; Depth[x] === 3 :> {x[[1, 1]], Total @ x[[All, 2]]}
        ];
        (* Checking for ions *)
        elements = elements /. x_List /; Depth[x] == 2 && StringContainsQ[ToString @ x[[2]], {"+", "-"}] :> {StringJoin @@ x, "1"};
        (* Optional: Remove charge of ions *)
        If[OptionValue["IgnoreIonCharge"],
            elements = MapAt[StringDelete[#, {DigitCharacter, "+", "-"}]&, elements, {All, 1}]
        ];
        (* Confirm that tally numbers are expressions *)
        elements = MapAt[ToExpression, elements, {All, 2}];
        (* Optional: Keep tally of the various atoms *)
        If[!tallyQ,
            elements = DeleteDuplicates[First /@ elements]
        ];
        elements
    ]

End[];
