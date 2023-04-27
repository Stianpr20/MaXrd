GetAtomicScatteringFactors::source = "Invalid data source option.";

GetAtomicScatteringFactors::missing = "\[LeftGuillemet]`1`\[RightGuillemet] is missing in data source for the `2`.";

GetAtomicScatteringFactors::slRequired = "Crystal name or Sin[\[Theta]]/\[Lambda] values required.";

GetAtomicScatteringFactors::slRange = "The value `1` \!\(\*SuperscriptBox[\(\[CapitalARing]\), \(-1\)]\) is out of range for the f0 source `2`.";

Options @ GetAtomicScatteringFactors = {"DispersionCorrections" -> True, "f0Source" -> "WaasmaierKirfel", "f1f2Source" -> "CromerLiberman", "IgnoreIonCharge" -> True, "SeparateCorrections" -> False};

SyntaxInformation @ GetAtomicScatteringFactors = {"ArgumentsPattern" -> {_, _, _., OptionsPattern[]}};

Begin["`Private`"];

GetAtomicScatteringFactors[crystal_String, hklInput_List, input\[Lambda] : _ ? (NumericQ[#] || QuantityQ[#]&) : -1, OptionsPattern[]] :=
    Block[
        {\[Lambda] = input\[Lambda], hkl, elements, H, sl, options}
        ,
        (*---* Basic *---*)
        (* Crystal and wavelength/energy *)
        \[Lambda] = InputCheck["ProcessWavelength", crystal, \[Lambda], False];
        (* Reflection(s) *)
        hkl = InputCheck[hklInput, "WrapSingle", "Integer"];
        (* Processing elements *)
        elements = GetElements[crystal, "Tally" -> False];
        (* Optional: Remove charge of ions *)
        If[OptionValue["IgnoreIonCharge"],
            elements = DeleteDuplicates @ StringDelete[elements, {DigitCharacter, "+", "-"}]
        ];
        (* Sin[\[Theta]]/\[Lambda] *)
        H = Chop @ N @ Inverse @ GetCrystalMetric[crystal];
        sl = Sqrt[# . H . #] / 2.& /@ hkl;
        (*---* Relaying data to main function *---*)
        options = # -> OptionValue[#]& /@ Keys @ Options @ GetAtomicScatteringFactors;
        GetAtomicScatteringFactors[elements, sl, \[Lambda], Sequence @@ options]
    ]

GetAtomicScatteringFactors[inputElements_List, inputSL_List, input\[Lambda] : _ ? (NumericQ[#] || QuantityQ[#]&) : -1, OptionsPattern[]] :=
    Block[
        {\[Lambda] = input\[Lambda], elements = inputElements, sl = inputSL, f0Source, f1f2Source, $f0Local, $f1f2Local, upperLimit, ignore, addCorrectionsQ = TrueQ @ OptionValue["DispersionCorrections"], separateQ = TrueQ @ OptionValue["SeparateCorrections"], ipfQ, coefficients, aKeys, bKeys, a, b, c, f0, corrections, output, temp}
        ,
        (*---* Checking input *---*)
        (* Elements *)
        elements = InputCheck["InterpretElement", Flatten[{elements}]];
        (* Sin[\[Theta]]/\[Lambda] *)
        sl = Flatten[{sl}];
        If[!AllTrue[sl, TrueQ @ Not @ Negative[#]&],
            Message[GetAtomicScatteringFactors::slRequired];
            Abort[]
        ];
        (* Wavelength *)
        If[\[Lambda] != -1,
            \[Lambda] = QuantityMagnitude @ InputCheck["GetEnergyWavelength", \[Lambda]]
        ];
        (* Data sources *)
        f0Source = OptionValue["f0Source"];
        f1f2Source = OptionValue["f1f2Source"];
        ignore = {"H", "He"};
        (* Validating sources *)
        If[!MemberQ[FileBaseName /@ FileNames["*.m", FileNameJoin[{$MaXrdPath, "Kernel", "Data", "AtomicScatteringFactor"}]], f0Source] || !MemberQ[FileBaseName /@ FileNames["*.m", FileNameJoin[{$MaXrdPath, "Kernel", "Data", "AtomicScatteringFactor", "AnomalousCorrections"}]], f1f2Source],
            Message[GetAtomicScatteringFactors::source];
            Abort[]
        ];
        (*---* Useful variables *---*)
        (* Check specific range limits *)
        upperLimit =
            Which[
                f0Source === "CromerMann",
                    1.5
                ,
                f0Source === "InternationalTablesC(3rd)",
                    2.0
                ,
                f0Source === "WaasmaierKirfel",
                    6.0
                ,
                True,
                    2.5
            ];
        Do[
            temp = sl[[i]];
            If[temp > upperLimit,
                Message[GetAtomicScatteringFactors::slRange, ToString @ temp, f0Source];
                Abort[]
            ]
            ,
            {i, Length @ sl}
        ];
        (* Loading source for calculating f0 *)
        (* Setup accumulative variable for the session *)
        If[!AssociationQ @ $f0,
            $f0 = <||>
        ];
        If[(* a. Check if same source is imported already *)KeyExistsQ[$f0, f0Source],
            $f0Local = $f0[f0Source]
            ,
            (* b. Import specified data *)
            $f0Local = Import @ FileNameJoin[{$MaXrdPath, "Kernel", "Data", "AtomicScatteringFactor", f0Source <> ".m"}];
            (* Update the accumulative variable *)
            AppendTo[$f0, f0Source -> $f0Local]
        ];
        (* Check if atom types are found in $f0 source *)
        temp = Complement[elements, Keys @ $f0Local];
        If[temp =!= {},
            Message[GetAtomicScatteringFactors::missing, First @ temp, "non-dispersive part (\!\(\*FormBox[SubscriptBox[\(f\), \(0\)],
TraditionalForm]\))"];
            Abort[]
        ];
        (*---* Calculating form factor (f0) from tabulated data *---*)
        ipfQ = Head @ First @ $f0Local === InterpolatingFunction;
        Which[(* a. Interpolation data *)(* sin(\[Theta])/\[Lambda] *)
            ipfQ,
                (* Non-dispersive part of form factor *)f0 = Table[{element, $f0Local[element][s]}, {s, sl}, {element, elements}]
            ,
            (* b. Coefficients *)True,
                (* Stored with alternating 'a' and 'b' and 'c' last *)coefficients = $f0Local[[elements]];
                {aKeys, bKeys} = Flatten @ StringCases[Keys @ First @ coefficients, # ~~ DigitCharacter..]& /@ {"a", "b"};
                {a, b, c} = {Values /@ coefficients[[All, aKeys]], Values /@ coefficients[[All, bKeys]], Values @ coefficients[[All, "c"]]};
                (* Non-dispersive part of form factor *)
                f0 = Table[{Keys[coefficients][[i]], Total[a[[i]] * Exp[-b[[i]] * (sl[[j]]) ^ 2]] + c[[i]]}, {j, Length @ sl}, {i, Length @ elements}]
        ];
        (* Check: Correct normalisation by electrons *)
        If[Abs[
                If[ipfQ,
                        $f0Local["C"][0]
                        ,
                        Total @ Values @ $f0Local[["C", aKeys]] + $f0Local["C", "c"]
                    ] - 6(* Carbon: Z=6 *) ] > 0.5,
            f0 = f0 /. {element_String, f_?NumericQ} :> {element, f * $PeriodicTable[element, "AtomicNumber"]}
        ];
        (*---* Dispersion corrections (f1 + f2) *---*)
        (* Optional: No dispersion corrections *)
        If[\[Lambda] === -1,
            addCorrectionsQ = False
        ];
        If[!addCorrectionsQ,
            (* Prepare output *)
            output = Map[Association, MapThread[Rule, Transpose[#]]& /@ f0];
            Goto["End"]
        ];
        (* Loading source for calculating f' + f'' *)
        (* Setup global variable for the session *)
        If[!AssociationQ @ $f1f2,
            $f1f2 = <||>
        ];
        If[(* a. Check if same source is imported already *)KeyExistsQ[$f1f2, f1f2Source],
            $f1f2Local = $f1f2[f1f2Source]
            ,
            (* b. Import specified data *)
            $f1f2Local = Import @ FileNameJoin[{$MaXrdPath, "Kernel", "Data", "AtomicScatteringFactor", "AnomalousCorrections", f1f2Source <> ".m"}];
            (* Update the session's global variable *)
            AppendTo[$f1f2, f1f2Source -> $f1f2Local]
        ];
        (* Check if atom types are found in $f1f2 source *)
        temp = Complement[elements, Keys @ $f1f2Local];
        temp = temp /. Thread[ignore -> Nothing]; (* ignored elements 
            
            
            
            
            
            *)
        If[temp =!= {},
            Message[GetAtomicScatteringFactors::missing, First @ temp, "dispersion corrections (\!\(\*FormBox[\(\*SuperscriptBox[\"f\", \"\[Prime]\",\nMultilineFunction->None] + \*SuperscriptBox[\"f\", \"\[Prime]\[Prime]\",\nMultilineFunction->None]\),
TraditionalForm]\))"];
            Abort[]
        ];
        (* Procedure *)
        Do[
            If[MemberQ[ignore, elements[[j]]],
                Continue[]
            ];
            corrections = $f1f2Local[elements[[j]]][\[Lambda]];
            AppendTo[f0[[i, j]], corrections]
            ,
            {i, Length @ sl}
            ,
            {j, Length @ elements}
        ];
        (*---* Preparing and returning association *---*)
        If[separateQ,
            (* a. Return f0 and f1f2 separated *)
            f0 =
                f0 /.
                    {
                        (* Elements with corrections *){element_String, f0_?NumericQ, f1f2_?NumericQ} :> (element -> <|"f0" -> f0, "f1f2" -> f1f2|>)
                        ,
                        (* Without corrections (ignored elements) *)
                        {element_String, f0_?NumericQ} :> (element -> <|"f0" -> f0, "f1f2" -> 0.|>)
                    }
            ,
            (* b. Return f0 and f1f2 combined *)
            f0 =
                f0 /.
                    {
                        (* Elements with corrections *){element_String, f0_?NumericQ, f1f2_?NumericQ} :> (element -> f0 + f1f2)
                        ,
                        (* Without corrections (ignored elements) *)
                        {element_String, f0_?NumericQ} :> (element -> f0)
                    }
        ];
        output = Association /@ f0;
        Label["End"];
        If[Length @ output == 1,
            First @ output
            ,
            output
        ]
    ]

End[];
