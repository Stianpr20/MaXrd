ImportCrystalData::subDataInteger = "\"\!\(\*
StyleBox[\"ExtractSubData\", \"Program\"]\)\" must be a positive integer.";

ImportCrystalData::subDataLength = "The \!\(\*
StyleBox[\".\", \"Program\"]\)\!\(\*
StyleBox[\"cif\", \"Program\"]\) file has a sub-data length of `1`.";

ImportCrystalData::latticeParameters = "No lattice parameters were located, or they have an invalid form.";

ImportCrystalData::atomData = "No atom data was located.";

ImportCrystalData::SG = "Could not determine space group. 'P1' will be used.";

ImportCrystalData::cell = "Could not work out the unit cell properly.";

ImportCrystalData::notMaXrd = "Data collected using `1` radiation. Errors may occur.";

ImportCrystalData::modulation = "Modulated structure detected. Errors may occur.";

ImportCrystalData::SpecialLabel = "\[LeftGuillemet]`1`\[RightGuillemet] is a reserved label and should not be used.";

Options @ ImportCrystalData = {"DataFile" -> FileNameJoin[{$MaXrdPath, "Kernel", "Data", "UserData", "CrystalData.m"}], "ExtractSubData" -> 1, "IgnoreIonCharge" -> False, "Notes" -> <||>, "RoundAnglesThreshold" -> 0.001, "Units" -> True, "OverwriteWarning" -> True};

SyntaxInformation @ ImportCrystalData = {"ArgumentsPattern" -> {___, OptionsPattern[]}};

Begin["`Private`"];

ImportCrystalData[{crystalName_String, chemicalFormula : _?StringQ : "", Z : _?IntegerQ : 0, spaceGroup_:1, wavelength : _?NumericQ : -1}, getLatticeParameters_List, atomData_List, OptionsPattern[]] :=
    Block[
        {choice, name, sg, cell, \[Delta], fr, latticeItem, \[Lambda], itemAtomData, item, dataFile = OptionValue["DataFile"], temp}
        ,
        (*---* Check if name already exists *---*)
        name =
            If[crystalName === "",
                "ImportedCrystal_" <> DateString["ISODate"]
                ,
                crystalName
            ];
        If[TrueQ @ OptionValue["OverwriteWarning"],
            If[KeyExistsQ[$CrystalData, name],
                choice = ChoiceDialog["\[LeftGuillemet]" <> name <> "\[RightGuillemet] already exists in $CrystalData.\nDo you want to overwrite this entry?"]
            ];
            If[!choice,
                Return[]
            ]
        ];
        (*--- Space Group *---*)
        sg = InputCheck["GetPointSpaceGroupCrystal", spaceGroup];
        sg = ToStandardSetting @ sg;
        (*---* Lattice parameters *---*)
        If[!AllTrue[getLatticeParameters, NumericQ[#]&] || Length @ getLatticeParameters != 6,
            Message[ImportCrystalData::latticeParameters]
        ];
        (* Optional: Round angles *)
        cell = getLatticeParameters;
        \[Delta] = OptionValue["RoundAnglesThreshold"];
        Do[
            fr = FractionalPart @ cell[[i]];
            If[fr > 0.5,
                fr = 1 - fr
            ];
            If[fr <= \[Delta],
                cell[[i]] = Round @ cell[[i]]
            ]
            ,
            {i, 4, 6}
        ];
        (* Optional: Use units *)
        If[OptionValue["Units"],
            Do[
                Which[
                    i <= 3,
                        cell[[i]] = Quantity[cell[[i]], "Angstroms"]
                    ,
                    i >= 4,
                        cell[[i]] = Quantity[cell[[i]], "Degrees"]
                ]
                ,
                {i, 6}
            ]
        ];
        (* Prepare association entry *)
        latticeItem = Association @ Thread[{"a", "b", "c", "\[Alpha]", "\[Beta]", "\[Gamma]"} -> cell];
        (*---* Wavelength *---*)
        (* Optional: Use units *)
        If[OptionValue["Units"],
            \[Lambda] = Quantity[wavelength, "Angstroms"]
            ,
            \[Lambda] = wavelength
        ];
        (*---* Atom data *---*)
        If[atomData === {},
            itemAtomData = {<||>}
            ,
            itemAtomData = Table[DeleteMissing @ Part[atomData[[i]], {"Element", "OccupationFactor", "SiteSymmetryMultiplicity", "SiteSymmetryOrder", "FractionalCoordinates", "DisplacementParameters", "Type"}], {i, Length @ atomData}];
            Do[
                If[KeyExistsQ[First @ itemAtomData, k],
                    itemAtomData = MapAt[ToExpression, itemAtomData, {All, Key[k]}]
                ]
                ,
                {k, {"OccupationFactor", "SiteSymmetryMultiplicity", "SiteSymmetryOrder", "DisplacementParameters"}}
            ];
            (* Checking strings in coordinates *)
            Do[itemAtomData[[i, "FractionalCoordinates"]] = itemAtomData[[i, "FractionalCoordinates"]] /. x_String :> ToExpression[x], {i, Length @ itemAtomData}]
        ];
        (*---* Preparing item *---*)
        item = <|"ChemicalFormula" -> chemicalFormula, "FormulaUnits" -> Z, "SpaceGroup" -> sg, "LatticeParameters" -> latticeItem, "Wavelength" -> \[Lambda], "AtomData" -> itemAtomData, "Notes" -> OptionValue["Notes"]|>;
        (* Delete certain keys *)
        If[item["ChemicalFormula"] === "",
            KeyDropFrom[item, "ChemicalFormula"]
        ];
        If[item["Notes"] === <||>,
            KeyDropFrom[item, "Notes"]
        ];
        If[!Positive @ item["Wavelength"],
            KeyDropFrom[item, "Wavelength"]
        ];
        If[Z === 0,
            KeyDropFrom[item, "FormulaUnits"]
        ];
        (* If all occupation factors = 1, delete column *)
        temp = item[["AtomData", All, "OccupationFactor"]];
        If[AllTrue[N @ temp, # == 1.&],
            item[["AtomData", All]] = KeyDrop[item[["AtomData", All]], "OccupationFactor"]
        ];
        (* If all displacement parameters = 0, delete column *)
        temp = item[["AtomData", All, "DisplacementParameters"]];
        If[AllTrue[N @ temp, # == 0.&],
            item[["AtomData", All]] = KeyDrop[item[["AtomData", All]], {"DisplacementParameters", "Type"}]
        ];
        InputCheck["Update$CrystalDataFile", dataFile, name, item];
        InputCheck["ShallowDisplayCrystal", name]
    ]

ImportCrystalData[cifFile_, inputName_String:"", OptionsPattern[]] :=
    Block[
        {
            (* A. Input check and setup *)name
            ,
            specialLabels = Join[{"Void"}, Keys @ $PeriodicTable]
            ,
            import
            ,
            sub
            ,
            endString
            ,
            enc
            ,
            left
            ,
            mid
            ,
            right
            ,
            modulationQ = False
            ,
            (* B. Lattice parameters *)cell
            ,
            x
            ,
            X
            ,
            multipleQ
            ,
            parts
            ,
            coordCount
            ,
            (* C. Atom data *)atomData
            ,
            atomTags
            ,
            c
            ,
            (* D. Anisotropic displacement parameters (ADPs) *)anisotropicData
            ,
            anisotropicOrder
            ,
            P
            ,
            atomOverview
            ,
            tags
            ,
            labels
            ,
            displacementParameters
            ,
            item
            ,
            (* E. Misc data labels (wavelength, formula units) *)\[Lambda]
            ,
            Z
            ,
            (* F. Chemical formula *)formula
            ,
            chemicalFormula
            ,
            L
            ,
            l
            ,
            r
            ,
            checkParentheses
            ,
            (* G. Space group *)sgTags
            ,
            sgData
            ,
            sg
            ,
            (* H. Adding item to dataset *)options
            ,
            (* Misc *)temp
        }
        ,
        (*---* A. Input check and setup *---*)
        If[inputName == "",
            name = FileBaseName[cifFile]
            ,
            name = inputName
        ];
        If[MemberQ[specialLabels, name],
            Message[ImportCrystalData::SpecialLabel, name];
            Abort[]
        ];
        (* A.1. Check file *)
        import = Check[Import[cifFile, "String"], Abort[]];
        sub = OptionValue["ExtractSubData"];
        If[!(IntegerQ[#] && Positive[#]& @ sub),
            Message[ImportCrystalData::subDataInteger];
            Abort[]
        ];
        (* A.2. Auxiliary variables *)
        endString = {"loop_", "\n\n", ";", "#", EndOfString};
        enc = {"'", "\""}; (* annotation/enclosing marks *)
        {left, mid, right} = {"\!\(\*SubscriptBox[\(", "\), \(", "\)]\)"};
        (* A.3. Check radiation type *)
        temp = StringCases[import, Shortest[{"_diffrn_radiation_type", "_diffrn_radiation_probe"} ~~ Whitespace ~~ {"", enc} ~~ t : LetterCharacter.. ~~ "\n"] :> t];
        If[MemberQ[temp, #],
                Message[ImportCrystalData::notMaXrd, #]
            ]& /@ {"neutron", "electron"};
        (* A.4. Check for modulation *)
        temp =
            If[StringContainsQ[import, "_space_group_ssg_name"],
                modulationQ = True;
                Message[ImportCrystalData::modulation]
            ];
        (*---* B. Lattice parameters *---*)
        (* B.1. Extracting lattice parameters *)
        cell = StringCases[import, Shortest[x : ("_cell_" ~~ {"length", "angle"} ~~ __ ~~ {DigitCharacter, "."}..) ~~ {"(", Whitespace}] :> ToLowerCase @ x, IgnoreCase -> True];
        (* Check *)
        If[cell == {},
            Message[ImportCrystalData::latticeParameters];
            Abort[]
        ];
        (* B.2. Check for multiple structures *)
        cell = StringSplit[cell, Whitespace];
        Which[
            Length @ cell > 6,
                multipleQ = True;
                parts = Length[cell] / 6
            ,
            Length @ cell == 6,
                multipleQ = False;
                parts = 1
            ,
            True,
                Message[ImportCrystalData::cell];
                Return @ cell
        ];
        (* Correct ordering *)
        cell = Partition[cell, Length @ cell / Quotient[Length @ cell, 6]];
        Do[
            X = cell[[i]];
            x = X[[All, 1]];
            P = FindPermutation[x, {"_cell_length_a", "_cell_length_b", "_cell_length_c", "_cell_angle_alpha", "_cell_angle_beta", "_cell_angle_gamma"}];
            cell[[i]] = Permute[X, P]
            ,
            {i, Length @ cell}
        ];
        cell = cell[[All, All, 2]];
        (* B.3. Check sub-data extraction *)
        (* Verify with fractional coordinates *)
        coordCount = StringCount[import, "_atom_site_fract_x"];
        If[coordCount === 0,
            Message[ImportCrystalData::atomData];
            Abort[]
        ];
        parts = Min[parts, coordCount];
        If[(multipleQ && sub > parts) || (!multipleQ && sub != 1),
            Message[ImportCrystalData::subDataLength, parts];
            Abort[]
        ];
        If[!IntegerQ[parts],
            Message[ImportCrystalData::subDataInteger];
            Return @ parts
        ];
        (* Extract sub-data *)
        cell = ToExpression @ cell[[sub]];
        (*---* C. Atom data *---*)
        Label["AtomData"];
        (* C.1. Extracting relevant data block *)
        (* Fractional coordinates *)
        (* Occupation factor *)
        (* Site symmetry multiplicity *)
        (* Extracting _atom_site loop *)
        atomData = StringCases[import, Shortest[labels : (Whitespace ~~ "_atom_site_" ~~ __ ~~ "\n") ~~ data : (StartOfLine ~~ Whitespace... ~~ LetterCharacter ~~ __ ~~ "\n") ~~ {endString, "_atom_site_aniso", "_" ~~ Except["a"]}] :> {labels, data}];
        (* No data? *)
        If[atomData == {},
            Message[ImportCrystalData::atomData];
            Abort[]
        ];
        (* Delete cases containing anisotropy data *)
        atomData = DeleteCases[atomData, x_ /; StringContainsQ[x[[1]], "aniso"]];
        (* Specify sub-data *)
        atomData = atomData[[sub]];
        (* C.2. Organising data *)
        atomTags = Flatten @ StringCases[atomData[[1]], "_atom_site_" ~~ {WordCharacter, "_"}..];
        atomData = StringDelete[atomData[[2]], "(" ~~ DigitCharacter.. ~~ ")"];
        atomData = Partition[StringSplit @ atomData, Length @ atomTags];
        atomData = DeleteCases[atomData, x_ /; Length[x] != Length[atomTags]];
        atomData = Association @ Thread[atomTags -> Transpose @ atomData];
        (* C.3 Fixing entries *)
        (* If 'site_type_symbol' is missing, copy 'site_label' *)
        If[!KeyExistsQ[atomData, "_atom_site_type_symbol"],
            AppendTo[atomData, "_atom_site_type_symbol" -> atomData["_atom_site_label"]]
        ];
        (* Process and check elements *)
        temp = atomData["_atom_site_type_symbol"];
        temp = InputCheck["InterpretElement", temp];
        (* Optional: Clear any ion charges *)
        If[OptionValue["IgnoreIonCharge"],
            temp = StringDelete[temp, {"+", "-", DigitCharacter}]
        ];
        (* Update 'atomData' with 'temp' *)
        atomData["_atom_site_type_symbol"] = temp;
        (*---* D. Anisotropic displacement parameters *---*)
        (* D.1. If missing, use default values for ADP *)
        L = Length @ First @ atomData;
        If[!KeyExistsQ[atomData, "_atom_site_adp_type"],
            AppendTo[atomData, "_atom_site_adp_type" -> ConstantArray["Uiso", L]]
        ];
        If[!KeyExistsQ[atomData, "_atom_site_U_iso_or_equiv"],
            AppendTo[atomData, "_atom_site_U_iso_or_equiv" -> ConstantArray[0, L]]
        ];
        (* D.2. Anisotropic displacement parameters *)
        anisotropicData = StringCases[import, Shortest["loop_" ~~ Whitespace ~~ x : ("_atom_site_aniso" ~~ __) ~~ endString] :> x];
        (* Check *)
        If[anisotropicData === {},
            Goto["OrganizeAtomData"]
            ,
            anisotropicData = anisotropicData[[sub]]
        ];
        (* D.3. Noting the order (permutation) *)
        anisotropicOrder = Flatten @ StringCases[anisotropicData, "U_" ~~ DigitCharacter..];
        P = FindPermutation[{"U_11", "U_22", "U_33", "U_12", "U_13", "U_23"}, anisotropicOrder];
        (* Nothing there to extract? *)
        temp = Flatten @ StringCases[anisotropicData, Shortest["_atom_site_aniso_" ~~ x__ ~~ Whitespace] :> x];
        c = Flatten @ Quiet @ Position[temp, x_ /; StringContainsQ[x, "U"]];
        (* D.4. Extracting relevant data and trimming *)
        anisotropicData =
            StringCases[
                anisotropicData
                ,
                Shortest["_atom_site_aniso" ~~ __ ~~ EndOfLine] ~~ Whitespace ~~
                                  (*
                            
Last line *)
                        x : (WordCharacter ~~ __) :> x(* Content *) ];
        (* Check if there is any actual data *)
        If[anisotropicData === {},
            Goto["OrganizeAtomData"]
        ];
        anisotropicData = StringSplit[First @ anisotropicData, Whitespace];
        anisotropicData = StringReplace[anisotropicData, x__ ~~ "(" ~~ __ ~~ ")" :> x];
        anisotropicData = Partition[anisotropicData, Length @ temp];
        (* Correcting parameter order *)
        anisotropicData[[All, c]] = Permute[#, P]& /@ anisotropicData[[All, c]];
        (* Associating each atom with values *)
        anisotropicData = Association[Table[anisotropicData[[i, 1]] -> anisotropicData[[i, c]], {i, Length @ anisotropicData}]];
        (* D.5. Organising the atom data *)
        Label["OrganizeAtomData"];
        atomOverview = {};
        tags = {"_atom_site_occupancy", "_atom_site_site_symmetry_multiplicity", "_atom_site_site_symmetry_order"};
        labels = {"OccupationFactor", "SiteSymmetryMultiplicity", "SiteSymmetryOrder"};
        Do[
            item = <||>;
            AppendTo[item, "Element" -> atomData[["_atom_site_type_symbol", i]]];
            Do[
                If[KeyExistsQ[atomData, tags[[j]]],
                    AppendTo[item, labels[[j]] -> atomData[[tags[[j]], i]]]
                ]
                ,
                {j, Length @ tags}
            ];
            AppendTo[item, "FractionalCoordinates" -> Evaluate[atomData[["_atom_site_fract_" <> #, i]]& /@ {"x", "y", "z"}]];
            If[StringTake[atomData[["_atom_site_adp_type", i]], -3] === "ani",
                displacementParameters = Part[anisotropicData, atomData[["_atom_site_label", i]]]
                ,
                displacementParameters = atomData[["_atom_site_U_iso_or_equiv", i]]
            ];
            AppendTo[item, "DisplacementParameters" -> displacementParameters];
            AppendTo[item, "Type" -> atomData[["_atom_site_adp_type", i]]];
            AppendTo[atomOverview, item]
            ,
            {i, Length @ First @ atomData}
        ];
        (*---* E. Misc data labels *---*)
        (* E.1. Wavelength *)
        \[Lambda] = StringCases[import, Shortest["_diffrn_radiation_wavelength" ~~ Whitespace ~~ x : {DigitCharacter, "."}.. ~~ Whitespace] :> x];
        If[\[Lambda] == {},
            \[Lambda] = -1
            ,
            If[Length @ \[Lambda] > 1,
                \[Lambda] = ToExpression @ \[Lambda][[sub]]
                ,
                \[Lambda] = ToExpression @ First @ \[Lambda]
            ]
        ];
        (* E.2. Forumla units (Z) *)
        Z = StringCases[import, Shortest["_cell_formula_units_Z" ~~ Whitespace ~~ z:DigitCharacter] :> z];
        If[Z === {},
            Z = 0
            ,
            Z = ToExpression @ First @ Z
        ];
        (*---* F. Chemical formula *---*)
        (* F.1. Extracting formula *)
        formula =
            StringCases[import, Shortest[# ~~ {Whitespace, "\n"}.. ~~ {"'", "\""} ~~ f__ ~~ {"'", "\""} ~~ {Whitespace, "\n"}..] :> f]& /@
                {
                    (* Prioritised order *)"_chemical_formula_iupac", "_chemical_formula_structural", "_chemical_formula_sum"
                };
        formula = Select[Flatten @ formula, !StringContainsQ[#, {",", "?"}]&];
        formula = StringDelete[formula, {"\r", "~"}];
        (* F.2. Check for simplest formula *)
        temp = Select[formula, !StringContainsQ[#, "("]&];
        If[temp =!= {},
            formula = {First @ temp}
        ];
        (* F.3. Misc treatment and possible sub-data selection *)
        If[formula === {} || formula === {""},
            chemicalFormula = "";
            Goto["SpaceGroup"]
        ];
        formula = {StringDelete[StringTrim @ First @ formula, {"'", "\""}]};
        If[formula === {""},
            chemicalFormula = "";
            Goto["SpaceGroup"]
            ,
            formula = StringSplit @ formula
        ];
        If[Length @ formula > 1,
            formula = formula[[sub]]
            ,
            formula = Flatten @ formula
        ];
        (* F.4. Loop for formatting the chemical formula *)
        Label["FormatFormula"];
        If[AnyTrue[formula, StringContainsQ[#, {"(", ")"}]&],
            {l, r} = Flatten @ Position[StringPosition[formula, {"(", ")"}], {{_, _}}];
            checkParentheses = True
        ];
        chemicalFormula = {};
        Do[
            temp = Flatten @ StringCases[formula[[i]], x : LetterCharacter.. ~~ y : ({DigitCharacter, "."}).. :> {x, y}];
            Which[
                temp == {},
                    AppendTo[chemicalFormula, formula[[i]]]
                ,
                temp[[2]] == "1",
                    AppendTo[chemicalFormula, temp[[1]]]
                ,
                True,
                    AppendTo[chemicalFormula, left <> temp[[1]] <> mid <> temp[[2]] <> right]
            ]
            ,
            {i, Length @ formula}
        ];
        chemicalFormula = StringDelete[chemicalFormula, {"(", ")"}];
        (* Adding back parentheses *)
        If[checkParentheses,
            chemicalFormula[[l]] = "(" <> chemicalFormula[[l]];
            chemicalFormula[[r]] = chemicalFormula[[r]] <> ")"
        ];
        chemicalFormula = StringJoin @ chemicalFormula;
        (*---* G. Space group *---*)
        Label["SpaceGroup"];
        (* G.1. Prioritised list of data labels *)
        sgTags = {"_space_group_name_Hall", "_space_group_name_H-M_alt", "_space_group_IT_number", "_symmetry_space_group_name_Hall", "_symmetry_space_group_name_H-M", "_symmetry_Int_Tables_number"};
        (* G.2. Extract space group sections from imported data *)
        sgData = StringCases[import, Shortest[sgTags ~~ __ ~~ "loop_"]];
        If[Length[sgData] > 0,
            sgData = sgData[[sub]]
        ];
        sgData = StringTrim @ StringDelete[sgData, "loop_"];
        (* G.3. Make association of tags and corresponding info *)
        sgData = StringCases[sgData, t:sgTags ~~ Whitespace ~~ sg : Shortest[Except[WhitespaceCharacter] ~~ __] ~~ {"\n", EndOfString} :> {t -> sg}];
        sgData = Association @ Flatten @ sgData;
        sgData = DeleteCases[sgData, "?"];
        (* G.4. Go through priority order and validate *)
        Do[
            sg = sgData[sgTags[[i]]];
            sg = Quiet @ InputCheck["InterpretSpaceGroup", sg, False];
            If[sg =!= Null,
                Break[]
            ]
            ,
            {i, Length @ sgTags}
        ];
        (* G.5. For modulated structures *)
        If[sg === Null && modulationQ,
            sg = StringCases[import, "_space_group_ssg_name" ~~ Whitespace ~~ {"'", "\""} ~~ sg__ ~~ {"'", "\""} ~~ "\n" :> sg];
            sg = StringCases[sg, Shortest[StartOfString ~~ ___ ~~ sg : (LetterCharacter ~~ __) ~~ "("] :> sg];
            If[sg =!= {},
                sg = Quiet @ InputCheck["InterpretSpaceGroup", First @ Flatten @ sg, False]
            ]
        ];
        (* G.6. If missing space group, display message and use 'P1' *)
        If[sg === Null,
            Message[ImportCrystalData::SG];
            sg = "P1"
        ];
        (*---* H. Adding item to dataset *---*)
        options = Thread[# -> OptionValue[#], String]& /@ (First /@ Options @ ImportCrystalData);
        ImportCrystalData[{name, chemicalFormula, Z, sg, \[Lambda]}, cell, atomOverview, options]
    ]

ImportCrystalData["RunDialogue"] :=
    DialogInput[
        DynamicModule[
            {
                name
                ,
                gridA
                ,
                gridB
                ,
                currentGrid
                ,
                updGrid
                ,
                sgKeys = Keys @ $SpaceGroups
                ,
                sgNumber = Null
                ,
                sgSymbol = Null
                ,
                crystalSystem
                ,
                systemParameterFields
                ,
                parameterFields
                ,
                a = Null
                ,
                b = Null
                ,
                c = Null
                ,
                \[Alpha] = Null
                ,
                \[Beta] = Null
                ,
                \[Gamma] = Null
                ,
                chemicalFormula = Null
                ,
                wavelength = Null
                ,
                massDensity = Null
                ,
                formulaUnits = Null
                ,
                atomData = {}
                ,
                atomDataSummary
                ,
                updAtomDataSummary
                ,
                createDeleteButtons
                ,
                deleteButtons
                ,
                createAtomDataPanel
                ,
                atomDataPanel = "(no entries)"
                ,
                updAtomDataPanel
                ,
                (* Adding entries *)
                element = Null
                ,
                elementListWithNumber
                ,
                coordinates
                ,
                coordX = Null
                ,
                coordY = Null
                ,
                coordZ = Null
                ,
                occupationFactor = Null
                ,
                adpType = "Isotropic"
                ,
                createAdpField
                ,
                adpField
                ,
                adpU11 = Null
                ,
                adpU22 = Null
                ,
                adpU33 = Null
                ,
                adpU12 = Null
                ,
                adpU13 = Null
                ,
                adpU23 = Null
                ,
                adpUiso = Null
                ,
                ADPs
                ,
                updRet
                ,
                toBeReturned
                ,
                validQ = False
            }
            ,
            (*---* Setup for grid B *---*)
            (* Logic *)
            elementListWithNumber = # <> " (" <> ToString @ $PeriodicTable[#, "AtomicNumber"] <> ")"& /@ Keys @ $PeriodicTable;
            elementListWithNumber = Thread[Keys @ $PeriodicTable -> elementListWithNumber];
            createAdpField[] :=
                Which[
                    adpType === "Isotropic",
                        adpField =
                            Column[
                                {
                                    InputField[
                                        Dynamic[
                                            adpUiso
                                            ,
                                            (
                                                adpUiso = #;
                                                updRet[]
                                            )&
                                        ]
                                        ,
                                        Number
                                        ,
                                        FieldSize -> {5., 1.}
                                        ,
                                        FieldHint -> "\!\(\*SubscriptBox[\(U\), \(iso\)]\)"
                                    ]
                                    ,
                                    Spacer[{165., 17.5}]
                                }
                            ]
                    ,
                    adpType === "Anisotropic",
                        adpField =
                            Column[
                                {
                                    Row[
                                        {
                                            InputField[
                                                Dynamic[
                                                    adpU11
                                                    ,
                                                    (
                                                        adpU11 = #;
                                                        updRet[]
                                                    )&
                                                ]
                                                ,
                                                Number
                                                ,
                                                FieldSize -> {5., 1.}
                                                ,
                                                FieldHint -> "\!\(\*SubscriptBox[\(U\), \(11\)]\)"
                                            ]
                                            ,
                                            Spacer[5]
                                            ,
                                            InputField[
                                                Dynamic[
                                                    adpU22
                                                    ,
                                                    (
                                                        adpU22 = #;
                                                        updRet[]
                                                    )&
                                                ]
                                                ,
                                                Number
                                                ,
                                                FieldSize -> {5., 1.}
                                                ,
                                                FieldHint -> "\!\(\*SubscriptBox[\(U\), \(22\)]\)"
                                            ]
                                            ,
                                            Spacer[5]
                                            ,
                                            InputField[
                                                Dynamic[
                                                    adpU33
                                                    ,
                                                    (
                                                        adpU33 = #;
                                                        updRet[]
                                                    )&
                                                ]
                                                ,
                                                Number
                                                ,
                                                FieldSize -> {5., 1.}
                                                ,
                                                FieldHint -> "\!\(\*SubscriptBox[\(U\), \(33\)]\)"
                                            ]
                                        }
                                    ]
                                    ,
                                    Row[
                                        {
                                            InputField[
                                                Dynamic[
                                                    adpU12
                                                    ,
                                                    (
                                                        adpU12 = #;
                                                        updRet[]
                                                    )&
                                                ]
                                                ,
                                                Number
                                                ,
                                                FieldSize -> {5., 1.}
                                                ,
                                                FieldHint -> "\!\(\*SubscriptBox[\(U\), \(12\)]\)"
                                            ]
                                            ,
                                            Spacer[5]
                                            ,
                                            InputField[
                                                Dynamic[
                                                    adpU13
                                                    ,
                                                    (
                                                        adpU13 = #;
                                                        updRet[]
                                                    )&
                                                ]
                                                ,
                                                Number
                                                ,
                                                FieldSize -> {5., 1.}
                                                ,
                                                FieldHint -> "\!\(\*SubscriptBox[\(U\), \(13\)]\)"
                                            ]
                                            ,
                                            Spacer[5]
                                            ,
                                            InputField[
                                                Dynamic[
                                                    adpU23
                                                    ,
                                                    (
                                                        adpU23 = #;
                                                        updRet[]
                                                    )&
                                                ]
                                                ,
                                                Number
                                                ,
                                                FieldSize -> {5., 1.}
                                                ,
                                                FieldHint -> "\!\(\*SubscriptBox[\(U\), \(23\)]\)"
                                            ]
                                        }
                                    ]
                                }
                            ]
                ];
            createAdpField[];
            (* Dynamic variable storing input data *)
            ADPs = Dynamic[{adpU11, adpU22, adpU33, adpU12, adpU13, adpU23}];
            coordinates = Dynamic[{coordX, coordY, coordZ}];
            updRet[] :=
                (
                    toBeReturned = Association[];
                    If[element =!= Null,
                        AssociateTo[toBeReturned, "Element" -> element]
                        ,
                        KeyDropFrom[toBeReturned, "Element"]
                    ];
                    If[occupationFactor =!= Null,
                        AssociateTo[toBeReturned, "OccupationFactor" -> occupationFactor]
                        ,
                        KeyDropFrom[toBeReturned, "OccupationFactor"]
                    ];
                    If[AllTrue[coordinates[[1]], NumericQ],
                        AssociateTo[toBeReturned, "FractionalCoordinates" -> coordinates]
                        ,
                        KeyDropFrom[toBeReturned, "FractionalCoordinates"]
                    ];
                    Which[
                        (adpType === "Anisotropic") && AllTrue[ADPs[[1]], NumericQ],
                            AssociateTo[toBeReturned, "DisplacementParameters" -> ADPs];
                            AssociateTo[toBeReturned, "Type" -> "Uani"]
                        ,
                        (adpType === "Isotropic") && NumericQ @ adpUiso,
                            AssociateTo[toBeReturned, "DisplacementParameters" -> adpUiso];
                            AssociateTo[toBeReturned, "Type" -> "Uiso"]
                        ,
                        True,
                            KeyDropFrom[toBeReturned, "DisplacementParameters"]
                    ];
                    If[(element =!= Null) && (AllTrue[coordinates[[1]], NumericQ]),
                        validQ = True
                        ,
                        validQ = False
                    ]
                );
            updRet[];
            (*---* // End of grid B setup // *---*)
            (* Logic *)
            systemParameterFields[system_String] :=
                Which[
                    system === "Triclinic",
                        Column[{Row[{InputField[Dynamic @ a, Number, FieldHint -> "a", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ b, Number, FieldHint -> "b", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ c, Number, FieldHint -> "c", FieldSize -> {5., 1.}, Enabled -> True]}], Row[{InputField[Dynamic @ \[Alpha], Number, FieldHint -> "\[Alpha]", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ \[Beta], Number, FieldHint -> "\[Beta]", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ \[Gamma], Number, FieldHint -> "\[Gamma]", FieldSize -> {5., 1.}, Enabled -> True]}]}]
                    ,
                    system === "Monoclinic",
                        Column[{Row[{InputField[Dynamic @ a, Number, FieldHint -> "a", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ b, Number, FieldHint -> "b", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ c, Number, FieldHint -> "c", FieldSize -> {5., 1.}, Enabled -> True]}], Row[{InputField[\[Alpha] = 90, Number, FieldHint -> "\[Alpha]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Beta] = 90, Number, FieldHint -> "\[Beta]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[Dynamic @ \[Gamma], Number, FieldHint -> "\[Gamma]", FieldSize -> {5., 1.}, Enabled -> True]}]}]
                    ,
                    system === "Orthorhombic",
                        Column[{Row[{InputField[Dynamic @ a, Number, FieldHint -> "a", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ b, Number, FieldHint -> "b", FieldSize -> {5., 1.}, Enabled -> True], Spacer[5], InputField[Dynamic @ c, Number, FieldHint -> "c", FieldSize -> {5., 1.}, Enabled -> True]}], Row[{InputField[\[Alpha] = 90, Number, FieldHint -> "\[Alpha]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Beta] = 90, Number, FieldHint -> "\[Beta]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Gamma] = 90, Number, FieldHint -> "\[Gamma]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]}]}]
                    ,
                    system === "Tetragonal",
                        Dynamic @
                            Column[
                                {
                                    Dynamic @
                                        Row[
                                            {
                                                InputField[
                                                    Dynamic[
                                                        a
                                                        ,
                                                        (
                                                            a = #;
                                                            b = #
                                                        )&
                                                    ]
                                                    ,
                                                    Number
                                                    ,
                                                    FieldHint -> "a"
                                                    ,
                                                    FieldSize -> {5., 1.}
                                                    ,
                                                    Enabled -> True
                                                ]
                                                ,
                                                Spacer[5]
                                                ,
                                                InputField[b = Dynamic @ a, Number, FieldHint -> "b", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]
                                                ,
                                                Spacer[5]
                                                ,
                                                InputField[Dynamic @ c, Number, FieldHint -> "c", FieldSize -> {5., 1.}, Enabled -> True]
                                            }
                                        ]
                                    ,
                                    Dynamic @ Row[{InputField[\[Alpha] = 90, Number, FieldHint -> "\[Alpha]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Beta] = 90, Number, FieldHint -> "\[Beta]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Gamma] = 90, Number, FieldHint -> "\[Gamma]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]}]
                                }
                            ]
                    ,
                    system === "Hexagonal" || system === "Trigonal",
                        Dynamic @
                            Column[
                                {
                                    Dynamic @
                                        Row[
                                            {
                                                InputField[
                                                    Dynamic[
                                                        a
                                                        ,
                                                        (
                                                            a = #;
                                                            b = #
                                                        )&
                                                    ]
                                                    ,
                                                    Number
                                                    ,
                                                    FieldHint -> "a"
                                                    ,
                                                    FieldSize -> {5., 1.}
                                                    ,
                                                    Enabled -> True
                                                ]
                                                ,
                                                Spacer[5]
                                                ,
                                                InputField[b = Dynamic @ a, Number, FieldHint -> "b", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]
                                                ,
                                                Spacer[5]
                                                ,
                                                InputField[Dynamic @ c, Number, FieldHint -> "c", FieldSize -> {5., 1.}, Enabled -> True]
                                            }
                                        ]
                                    ,
                                    Dynamic @ Row[{InputField[\[Alpha] = 90, Number, FieldHint -> "\[Alpha]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Beta] = 90, Number, FieldHint -> "\[Beta]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Gamma] = 120, Number, FieldHint -> "\[Gamma]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]}]
                                }
                            ]
                    ,
                    system === "Cubic",
                        Dynamic @
                            Column[
                                {
                                    Dynamic @
                                        Row[
                                            {
                                                InputField[
                                                    Dynamic[
                                                        a
                                                        ,
                                                        (
                                                            a = #;
                                                            b = #;
                                                            c = #
                                                        )&
                                                    ]
                                                    ,
                                                    Number
                                                    ,
                                                    FieldHint -> "a"
                                                    ,
                                                    FieldSize -> {5., 1.}
                                                    ,
                                                    Enabled -> True
                                                ]
                                                ,
                                                Spacer[5]
                                                ,
                                                InputField[b = Dynamic @ a, Number, FieldHint -> "b", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]
                                                ,
                                                Spacer[5]
                                                ,
                                                InputField[c = Dynamic @ a, Number, FieldHint -> "c", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]
                                            }
                                        ]
                                    ,
                                    Dynamic @ Row[{InputField[\[Alpha] = 90, Number, FieldHint -> "\[Alpha]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Beta] = 90, Number, FieldHint -> "\[Beta]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]], Spacer[5], InputField[\[Gamma] = 90, Number, FieldHint -> "\[Gamma]", FieldSize -> {5., 1.}, Enabled -> False, BaseStyle -> GrayLevel[0.65]]}]
                                }
                            ]
                ];
            (* Atom data *)
            updAtomDataSummary[] := atomDataSummary = atomData[[All, {"Element", "FractionalCoordinates"}]];
            createDeleteButtons[] :=
                deleteButtons =
                    Button[
                            "\[Times]"
                            ,
                            atomDataSummary = Delete[atomDataSummary, #];
                            createDeleteButtons[];
                            createAtomDataPanel[]
                            ,
                            Appearance -> "Frameless"
                        ]& /@ Range @ Length @ atomDataSummary;
            createAtomDataPanel[] :=
                If[deleteButtons === {},
                    atomDataPanel = "(no entries)"
                    ,
                    atomDataPanel = Row[{Pane[Grid[Transpose @ Join[Transpose @ Values @ atomDataSummary, {deleteButtons}], Alignment -> Left], Scrollbars -> False]}]
                ];
            updAtomDataPanel[] :=
                If[atomData === {},
                    atomDataPanel = "(no entries)"
                    ,
                    updAtomDataSummary[];
                    createDeleteButtons[];
                    createAtomDataPanel[]
                ];
            (* Initial settings *)
            parameterFields = systemParameterFields["Triclinic"];
            updAtomDataPanel[];
            (*---* Grids *---*)
            (* Grid switcher *)
            updGrid[label_String] :=
                currentGrid =
                    Which[
                        label === "A",
                            gridA
                        ,
                        label === "B",
                            gridB
                    ];
            updGrid["A"];
            (* Grid A *)
            gridA =
                Dynamic @
                    {
                        {"Crystal name", InputField[Dynamic @ name, String, FieldHint -> "Crystal name or label"]}
                        ,
                        {
                            "Space group"
                            ,
                            Dynamic @
                                Row[
                                    {
                                        PopupMenu[
                                            Dynamic[
                                                sgNumber
                                                ,
                                                (
                                                    sgNumber = #;
                                                    sgSymbol = sgKeys[[sgNumber]];
                                                    crystalSystem = $SpaceGroups[sgSymbol, "CrystalSystem"];
                                                    parameterFields = systemParameterFields[crystalSystem]
                                                )&
                                            ]
                                            ,
                                            Range @ 230
                                            ,
                                            "Number"
                                        ]
                                        ,
                                        PopupMenu[
                                            Dynamic[
                                                sgSymbol
                                                ,
                                                (
                                                    sgSymbol = #;
                                                    sgNumber = $SpaceGroups[sgSymbol, "SpaceGroupNumber"];
                                                    crystalSystem = $SpaceGroups[sgSymbol, "CrystalSystem"];
                                                    parameterFields = systemParameterFields[crystalSystem]
                                                )&
                                            ]
                                            ,
                                            Keys @ $SpaceGroups
                                            ,
                                            "Symbol"
                                        ]
                                    }
                                ]
                        }
                        ,
                        {Tooltip["Lattice parameters", Column[{"a  b  c", "\[Alpha]  \[Beta]  \[Gamma]", "\[ARing]ngstr\[ODoubleDot]m and degree"}], TooltipDelay -> 0.6], Dynamic @ parameterFields}
                        ,
                        {}
                        ,
                        {Tooltip["Chemical formula", "e.g. 'C13 H22 Fe N6 S3'", TooltipDelay -> 0.6], InputField[Dynamic @ chemicalFormula, String, FieldHint -> "e.g. 'C13 H22 Fe N6 S3'"]}
                        ,
                        {Tooltip["Wavelength", "\[ARing]ngstr\[ODoubleDot]m", TooltipDelay -> 0.6], Row[{InputField[Dynamic @ wavelength, Number, FieldSize -> {5., 1.}, FieldHint -> "\[Lambda]"], Spacer[5], PopupMenu[Dynamic @ wavelength, {1.54059 -> "Cu \!\(\*SubscriptBox[\(K\[Alpha]\), \(1\)]\)", 1.54443 -> "Cu \!\(\*SubscriptBox[\(K\[Alpha]\), \(2\)]\)", 1.39223 -> "Cu \!\(\*SubscriptBox[\(K\[Beta]\), \(1\)]\)", 0.70932 -> "Mo \!\(\*SubscriptBox[\(K\[Alpha]\), \(1\)]\)", 0.71361 -> "Mo \!\(\*SubscriptBox[\(K\[Alpha]\), \(2\)]\)", 0.63230 -> "Mo \!\(\*SubscriptBox[\(K\[Beta]\), \(1\)]\)"}, "(Predefined)"]}]}
                        ,
                        {Tooltip["Mass density", "g/\!\(\*SuperscriptBox[\(cm\), \(3\)]\)", TooltipDelay -> 0.6], Row[{InputField[Dynamic @ massDensity, Number, FieldSize -> {5., 1.}, FieldHint -> "\[Rho]"], Spacer[5], "formula units", Spacer[5], InputField[Dynamic @ formulaUnits, Number, FieldSize -> {5., 1.}, FieldHint -> "Z"]}]}
                        ,
                        {}
                        ,
                        {"Atom data", Column[{Button["Add new element", updGrid["B"]], Dynamic @ atomDataPanel}]}
                        ,
                        {}
                        ,
                        {
                            Null
                            ,
                            Row[
                                {
                                    CancelButton[]
                                    ,
                                    DefaultButton[
                                        DialogReturn[
                                            (* Final checks *)If[!StringQ @ name,
                                                name = "(no name)"
                                            ];
                                            If[chemicalFormula === Null,
                                                chemicalFormula = ""
                                            ];
                                            If[formulaUnits === Null,
                                                formulaUnits = 0
                                            ];
                                            If[sgSymbol === Null,
                                                sgSymbol = 1
                                            ];
                                            If[wavelength === Null,
                                                wavelength = -1
                                            ];
                                            (* Return *)
                                            StianRamsnes`MaXrd`Private`$temp = {{name, chemicalFormula, formulaUnits, sgSymbol, wavelength}, {a, b, c, \[Alpha], \[Beta], \[Gamma]}, atomData};
                                            StianRamsnes`MaXrd`Private`$temp = Replace[StianRamsnes`MaXrd`Private`$temp, x_Dynamic :> x[[1]], -1]
                                        ]
                                    ]
                                }
                            ]
                        }
                    };
            (* Grid B *)
            gridB =
                Dynamic @
                    {
                        {
                            "Element"
                            ,
                            PopupMenu[
                                Dynamic[
                                    element
                                    ,
                                    (
                                        element = #;
                                        updRet[]
                                    )&
                                ]
                                ,
                                elementListWithNumber
                                ,
                                "Element"
                            ]
                        }
                        ,
                        {
                            "Fractional coordinates"
                            ,
                            Row[
                                {
                                    InputField[
                                        Dynamic[
                                            coordX
                                            ,
                                            (
                                                coordX = #;
                                                updRet[]
                                            )&
                                        ]
                                        ,
                                        Number
                                        ,
                                        FieldSize -> {5., 1.}
                                        ,
                                        FieldHint -> "x"
                                    ]
                                    ,
                                    Spacer[5]
                                    ,
                                    InputField[
                                        Dynamic[
                                            coordY
                                            ,
                                            (
                                                coordY = #;
                                                updRet[]
                                            )&
                                        ]
                                        ,
                                        Number
                                        ,
                                        FieldSize -> {5., 1.}
                                        ,
                                        FieldHint -> "y"
                                    ]
                                    ,
                                    Spacer[5]
                                    ,
                                    InputField[
                                        Dynamic[
                                            coordZ
                                            ,
                                            (
                                                coordZ = #;
                                                updRet[]
                                            )&
                                        ]
                                        ,
                                        Number
                                        ,
                                        FieldSize -> {5., 1.}
                                        ,
                                        FieldHint -> "z"
                                    ]
                                }
                            ]
                        }
                        ,
                        {
                            "Occupation factor"
                            ,
                            InputField[
                                Dynamic[
                                    occupationFactor
                                    ,
                                    (
                                        occupationFactor = #;
                                        updRet[]
                                    )&
                                ]
                                ,
                                Number
                                ,
                                FieldSize -> {5., 1.}
                                ,
                                FieldHint -> "1"
                            ]
                        }
                        ,
                        {
                            Tooltip["ADP type", "Anisotropic displacement parameters", TooltipDelay -> 0.6]
                            ,
                            RadioButtonBar[
                                Dynamic[
                                    adpType
                                    ,
                                    (
                                        adpType = #;
                                        createAdpField[];
                                        updRet[]
                                    )&
                                ]
                                ,
                                {"Isotropic", "Anisotropic"}
                                ,
                                Method -> "Active"
                            ]
                        }
                        ,
                        {Null, Dynamic @ adpField}
                        ,
                        {}
                        ,
                        {}
                        ,
                        {}
                        ,
                        {}
                        ,
                        {}
                        ,
                        {}
                        ,
                        {}
                        ,
                        {}
                        ,
                        {
                            Null
                            ,
                            Row[
                                {
                                    CancelButton[updGrid["A"]]
                                    ,
                                    DefaultButton[
                                        "Add"
                                        ,
                                        AppendTo[atomData, Replace[toBeReturned, x_Dynamic :> x[[1]], -1]];
                                        updAtomDataPanel[];
                                        updGrid["A"]
                                        ,
                                        Enabled -> Dynamic @ validQ
                                    ]
                                }
                            ]
                        }
                    };
            (* Grid on display *)
            Dynamic @ Grid[currentGrid[[1]], Spacings -> {1, 0.5}, Alignment -> {Left, Center}]
        ]
        ,
        (* Dialogue settings *)
        WindowTitle -> "Add crystal to $CrystalData"
        ,
        Modal -> True
        ,
        WindowSize -> {310, All}
    ];

ImportCrystalData[] :=
    Block[{name},
        StianRamsnes`MaXrd`Private`$temp = Null;
        ImportCrystalData["RunDialogue"];
        If[StianRamsnes`MaXrd`Private`$temp === Null,
            Return[]
        ];
        name = StianRamsnes`MaXrd`Private`$temp[[1, 1]];
        (* Execute ImportCrystalData on input data *)
        If[ListQ @ StianRamsnes`MaXrd`Private`$temp,
            If[!AllTrue[StianRamsnes`MaXrd`Private`$temp[[2]] /. x_Dynamic :> x[[1]], NumericQ],
                Message[ImportCrystalData::latticeParameters];
                Abort[]
                ,
                ImportCrystalData @@ StianRamsnes`MaXrd`Private`$temp
            ]
        ];
        (* Reset temporary variable *)
        StianRamsnes`MaXrd`Private`$temp = Null;
        InputCheck["ShallowDisplayCrystal", name]
    ]

End[];
