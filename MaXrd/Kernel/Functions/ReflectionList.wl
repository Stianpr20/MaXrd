ReflectionList::form = "Some reflections are not on a {\!\(\*
StyleBox[\"h\", \"TI\"]\), \!\(\*
StyleBox[\"k\", \"TI\"]\), \!\(\*
StyleBox[\"l\", \"TI\"]\)} form.";

ReflectionList::integer = "Some reflection indices are not integers.";

ReflectionList::empty = "No reflections match the conditions.";

ReflectionList::keep = "Invalid setting for the \[LeftGuillemet]Keep\[RightGuillemet] option.";

ReflectionList::index = "Invalid index setting.";

ReflectionList::limit = "Limit must be a natural number.";

Options @ ReflectionList =
    {
        "AngleThreshold" -> 90. * Degree
        ,
        "CustomReflections" -> False
        ,
        "Keep" -> All
        ,
        "Limit" -> 30
        ,
        "ShowProgress" -> False
        ,
        "SplitEquivalent" -> False
        ,
        "HoldIndex" -> False
        ,
        (* 'ToStandardSetting' options *)
        "ToStandardSetting" -> True
    };

SyntaxInformation @ ReflectionList = {"ArgumentsPattern" -> {_, _., _.,
     OptionsPattern[]}};

Begin["`Private`"];

ReflectionList[n_ ? (IntegerQ[#] && Positive[#]&), condition___Condition,
     OptionsPattern[]] :=
    Block[
        {opt, i, v, h, k, l, hkl}
        ,
        (* Optional: Hold an index at same value *)
        opt = OptionValue["HoldIndex"];
        If[TrueQ[Head @ opt == Rule],
            {i, v} = Part[opt, #]& /@ {1, 2};
            i = StringTake[i, -1]
            ,
            i = "None"
        ];
        (* Check *)
        If[i != "None",
            If[!MemberQ[{"h", "k", "l"}, i] || !IntegerQ[v],
                Message[ReflectionList::index];
                Abort[]
            ]
        ];
        hkl =
            Which[
                i == "h",
                    Flatten[Table[{v, k, l}, {k, -n, n}, {l, -n, n}],
                         1]
                ,
                i == "k",
                    Flatten[Table[{h, v, l}, {h, -n, n}, {l, -n, n}],
                         1]
                ,
                i == "l",
                    Flatten[Table[{h, k, v}, {h, -n, n}, {k, -n, n}],
                         1]
                ,
                True,
                    Tuples[Range[-n, n], 3]
            ];
        (* Remove the '000' reflection *)
        hkl = DeleteCases[hkl, {0, 0, 0}];
        (* Sorting *)
        hkl = SortBy[hkl, {Total @ Abs[#]&, Negative}];
        (* Checking if extra conditions are present *)
        If[{condition} != {},
            (* Filtering reflections *)
            hkl = Cases[hkl, condition]
        ];
        Return @ hkl
    ]

ReflectionList[crystal_String, lambda : _ ? (NumericQ[#] || QuantityQ[
    #]&) : -1, condition___Condition, OptionsPattern[]] :=
    Block[
        {
            \[Lambda]
            ,
            limit
            ,
            H
            ,
            \[Theta]
            ,
            checkIfEmpty
            ,
            custom
            ,
            n
            ,
            list
            ,
            crystalMetric
            ,
            crystalMetricInverse
            ,
            CrystalDot
            ,
            res
            ,
            keep
            ,
            options
            ,
            angleThreshold
            ,
            (* Progress *)
            progress
            ,
            total
        }
        ,
        (* Dynamical progress *)
        progress = {0, "Initialisation"};
        total = 11;
        If[TrueQ @ OptionValue["ShowProgress"],
            PrintTemporary[Row[{ProgressIndicator @ Dynamic[progress[[
                1]] / total], Spacer[10], Dynamic @ progress[[2]]}]]
        ];
        (* Checking input *)
        progress = {0, "Checking input"};
        \[Lambda] = InputCheck["ProcessWavelength", crystal, lambda];
            
        limit = OptionValue["Limit"];
        If[!(Positive[limit] && IntegerQ[limit]),
            Message[ReflectionList::limit];
            Abort[]
        ];
        (* Useful variables *)
        progress = {2, "Defining variables"};
        crystalMetric = GetCrystalMetric[crystal];
        crystalMetricInverse = Inverse @ crystalMetric;
        H = N @ Chop @ crystalMetricInverse;
        \[Theta][hkl_] := N[ArcSin[\[Lambda] * Sqrt[hkl . H . hkl] / 
            2]];
        (* Empty list check *)
        checkIfEmpty :=
            If[list == {},
                Message[ReflectionList::empty];
                Goto["ReturnEmpty"]
            ];
        (* Option: Use custom reflections *)
        progress = {3, "Custom input"};
        If[ListQ @ OptionValue["CustomReflections"],
            custom = OptionValue["CustomReflections"];
            (* Check custom input *)
            If[Flatten @ custom == {},
                Message[InputCheck::hkl];
                Return[{}]
            ];
            Check[InputCheck[custom, "Integer", "WrapSingle"], Abort[
                ]];
            list = custom;
            Goto["ListDone"]
        ];
        (** Generating a reflection list **)
        progress = {4, "Generating a reflection list"};
        (* Dot product in reciprocal space *)
        CrystalDot[u_, v_] := Return[Sum[Sum[crystalMetricInverse[[i,
             j]] * u[[i]] * v[[j]], {j, 3}], {i, 3}]];
        (* Coarse decision on which 'hkl' values to generate *)
        progress = {5, "Deciding which 'hkl' values to generate"};
        options = # -> OptionValue[#]& /@ Keys @ Options @ ReflectionList
            ;
        n = 1;
        While[Im @ \[Theta][{n, n, n}] == 0, n++];
        n = Min[n, limit];
        list = ReflectionList[n, condition, options];
        checkIfEmpty;
        (* Filter away reflections with complex Bragg angle *)
        progress = {6, "Checking Bragg angles"};
        list = Select[list, Norm[#] <= 1 && Head[#] =!= Complex&[\[Theta][
            #]]&];
        (* Optional: Truncate at chosen angle threshold *)
        angleThreshold = OptionValue["AngleThreshold"];
        If[0 <= angleThreshold < \[Pi] / 2,
            list = Select[list, (\[Theta][#] <= angleThreshold)&]
        ];
        (* Resolution filtering *)
        progress = {7, "Resolution filtering"};
        res = \[Lambda] / 2;
        list = Select[list, Sqrt[CrystalDot[#, #]] < 1 / (1.01 * res)&
            ];
        checkIfEmpty;
        (* Filter away absent reflections *)
        Label["ListDone"];
        progress = {8, "Filtering away absent reflections"};
        list = Pick[list, SystematicAbsentQ[crystal, list], False];
        checkIfEmpty;
        (** Optional: Merge symmetry-equivalent reflections **)
        progress = {9, "Merging symmetry equivalent reflections"};
        If[OptionValue["SplitEquivalent"],
            (* Split *)Null
            ,
            (* Merge *) list = MergeSymmetryEquivalentReflections[crystal,
                 list, "ToStandardSetting" -> OptionValue["ToStandardSetting"]]
        ];
        (** Optional: Limit number of reflections **)
        progress = {10, "Limiting the number of reflections"};
        keep = OptionValue["Keep"];
        (* Check *)
        If[keep == All,
            keep = Length @ list
        ];
        If[!(IntegerQ[keep] && Positive[keep]),
            Message[ReflectionList::keep]
        ];
        progress = {11, "Reflection list done"};
        list = Take[list, Min[keep, Length @ list]];
        (*---* End *---*)
        Return @ list;
        Label["ReturnEmpty"];
        Return[{}]
    ]

End[];
