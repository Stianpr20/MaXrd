StructureFactorTable::invalidCustomReflections = "Invalid setting for the \[LeftGuillemet]CustomReflections\[RightGuillemet] option.";

StructureFactorTable::sort = "Invalid \[LeftGuillemet]Sort\[RightGuillemet] option.";

Options[StructureFactorTable] =
    {
        (* DarwinWidth and ExtinctionLength options *)"Polarisation" -> "\[Pi]"
        ,
        (* StructureFactor options *)
        "Threshold" -> Power[10., -6]
        ,
        (* ReflectionList options *)
        "SplitEquivalent" -> False
        ,
        "CustomReflections" -> False
        ,
        "ReflectionListKeep" -> 50
        ,
        (* StructureFactorTable options *)
        "Keep" -> All
        ,
        "Sort" -> -2
        ,
        "TitleStyle" -> {FontFamily -> "Baskerville", FontSize -> 15}
        ,
        "SubtitleStyle" -> {FontFamily -> "Times New Roman", FontSize -> 13, Gray}
        ,
        "NumberStyle" -> FontFamily -> "Courier"
        ,
        Background -> {{None}, {None, {None, LightGray}}}
        ,
        Dividers -> {{None, {True}, None}, {None, None, True}}
    };

SyntaxInformation @ StructureFactorTable = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

Begin["`Private`"];

StructureFactorTable[crystal_String, lambda : _ ? (NumericQ[#] || QuantityQ[#]&) : -1, condition___Condition, OptionsPattern[]] :=
    Block[
        {\[Lambda], hkl, H, sl, bragg, column1, column2, column3, column4, column5, column6, V, zeros, R, \[Theta], Fh, FhBar, \[CapitalLambda]o, \[Delta]os, temp, temp1, temp2, temp3, temp4, temp5, temp6, sort, keep, polarisation, threshold}
        ,
        (*---* Preparations *---*)
        (* Checking wavelength *)
        \[Lambda] = InputCheck["ProcessWavelength", crystal, lambda];
        (* Preparing list of reflections *)
        hkl = Check[ReflectionList[crystal, \[Lambda], condition, "SplitEquivalent" -> OptionValue["SplitEquivalent"], "CustomReflections" -> OptionValue["CustomReflections"], "Keep" -> OptionValue["ReflectionListKeep"]], Abort[]];
        (* Useful variables *)
        H = Chop @ N @ Inverse @ GetCrystalMetric[crystal];
        (* Using inner product and Bragg's law *)
        sl[h_] := N[Sqrt[h . H . h] / 2];
        bragg[h_] := N[ArcSin[sl[h] * QuantityMagnitude @ \[Lambda]]];
        (* Miscellaneous options *)
        polarisation = OptionValue["Polarisation"];
        threshold = OptionValue["Threshold"];
        (*---* Calculations *---*)
        (* Miller indices *)
        column1 = MillerNotationToString /@ hkl;
        (* Structure factors *)
        temp = Check[StructureFactor[crystal, hkl, \[Lambda], "Threshold" -> threshold], Abort[]];
        column2 = Chop[temp[[All, 1]], OptionValue["Threshold"]];
        (* Structure factor zero positions *)
        zeros = Position[column2, 0];
        (* Phase *)
        column3 = QuantityMagnitude @ temp[[All, 2]];
        column3 = ReplacePart[column3, zeros -> "\[Dash]"];
        (* Bragg angles *)
        column4 = (bragg /@ hkl) / Degree;
        (* Unit cell volume *)
        V = Sqrt @ Det @ GetCrystalMetric[crystal];
        (* Extinction length (Pendell\[ODoubleDot]sung distance) *)
        R = QuantityMagnitude @ UnitConvert[Quantity["ClassicalElectronRadius"], "Angstroms"];
        \[Theta] = column4 * Degree;
        Fh = column2;
        FhBar = (StructureFactor[crystal, -hkl, \[Lambda]])[[All, 1]];
        \[CapitalLambda]o = Quiet @ ExtinctionLength[crystal, \[Lambda], hkl, "Units" -> False, "Polarisation" -> polarisation];
        \[CapitalLambda]o = ReplacePart[\[CapitalLambda]o, zeros -> "\[Dash]"];
        (* Darwin width *)
        \[Delta]os = Quiet @ DarwinWidth[crystal, \[Lambda], hkl, "Units" -> False, "Polarisation" -> polarisation];
        \[Delta]os = ReplacePart[\[Delta]os, zeros -> "\[Dash]"];
        {column5, column6} = {\[CapitalLambda]o, \[Delta]os};
        (*---* Preparing output *---*)
        temp1 = {column1, column2, column3, column4, column5, column6};
        (* Optional: Sorting option *)
        sort = OptionValue["Sort"];
        (* Check sort setting *)
        If[!MemberQ[Range[6], Abs @ sort],
            Message[StructureFactorTable::sort];
            Abort[]
        ];
        (* Sorting by a specific column *)
        temp2 = Sort[Transpose @ temp1, #1[[Abs @ sort]] < #2[[Abs @ sort]]&];
        (* Reversing if negative *)
        If[sort < 0,
            temp2 = Reverse @ temp2
        ];
        (* Optional: Truncate the list of reflections *)
        keep = OptionValue["Keep"];
        If[keep == All,
            keep = Length @ hkl
        ];
        If[!IntegerQ[keep] || !Positive[keep],
            Message[StructureFactorTable::invkeep];
            Abort[]
        ];
        temp2 = Take[temp2, Min[keep, Length @ hkl]];
        (* Rounding off numbers *)
        temp3 = NumberForm[#, {5, 3}, DigitBlock -> 3, NumberSeparator -> ","]& /@ (Flatten @ temp2);
        temp4 = Partition[temp3, Last @ Dimensions @ temp2];
        (*---* Table construction *---*)
        temp5 = PrependTo[temp4, {"(hkl)", "|\!\(\*SubscriptBox[\(F\), \(hkl\)]\)|", "\!\(\*SubscriptBox[\(\[Phi]\), \(hkl\)]\) [\[Degree]]", "\!\(\*SubscriptBox[\(\[Theta]\), \(B\)]\) [\[Degree]]", "\!\(\*SubscriptBox[\(\[CapitalLambda]\), \(0\)]\) [\[Micro]m]", "2\!\(\*SubscriptBox[\(\[Delta]\), \(os\)]\) [\[Micro]rad]"}];
        temp6 = PrependTo[temp5, {Null, "Structure factor", "Phase", "Bragg angle", "Extinction length", "Darwin width"}];
        Grid[temp6, Dividers -> OptionValue[Dividers], Background -> OptionValue[Background], Alignment -> {Center, Center}, Spacings -> {Automatic, 2 -> 0.5}, ItemStyle -> {Automatic, Automatic, {{{1, 1}, {1, First @ Dimensions @ temp1}} -> OptionValue["TitleStyle"], {{2, 2}, {1, First @ Dimensions @ temp1}} -> OptionValue["SubtitleStyle"], {{3, First @ Dimensions @ temp2 + 2}, {1, First @ Dimensions @ temp1}} -> OptionValue["NumberStyle"]}}]
    ]

End[];
