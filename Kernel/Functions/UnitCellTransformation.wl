UnitCellTransformation::commandUnrecognized = "Transformation command \[LeftGuillemet]`1`\[RightGuillemet] not recognised.";

UnitCellTransformation::invalidSetting = "The setting \[LeftGuillemet]`1`\[RightGuillemet] is invalid.";

UnitCellTransformation::invalidSpaceGroup = "The setting \[LeftGuillemet]`1`\[RightGuillemet] is invalid for this particular space group.";

UnitCellTransformation::invalidForSystem = "Input not applicable for the `1` system.";

UnitCellTransformation::settingMismatch = "Setting mismatch between source, `1`, and target, `2`.";

UnitCellTransformation::spaceGroupFailed = "Could not interpret \[LeftGuillemet]`1`\[RightGuillemet] as a space group symbol.";

UnitCellTransformation::differentSpaceGroups = "The source space group, \[LeftGuillemet]`1`\[RightGuillemet] (no.`2`), and the target space group, \[LeftGuillemet]`3`\[RightGuillemet] (no. `4`), are not the same.";

UnitCellTransformation::unsupportedTransformation = "Transformation of the input is not supported.";

UnitCellTransformation::targetFailed = "Could not determine target space group.";

UnitCellTransformation::singleRepresentation = "This space group, \[LeftGuillemet]`1`\[RightGuillemet] (no. `2`), has no alternative representations.";

Options @ UnitCellTransformation = {"CustomP" -> False, "ReturnP" -> False, "MoveIfCellEmpty" -> True};

Begin["`Private`"];

UnitCellTransformation[crystal_String, userinput___] :=
    Block[
        {
            (*---* 1. Input check and preparation *---*)(* 1.A. Load crystal metric, space group and crystal system *)G
            ,
            G0
            ,
            sg
            ,
            sg0
            ,
            sourceSG
            ,
            fullHM
            ,
            posSG
            ,
            SG
            ,
            fullHMs
            ,
            sourceSGnumber
            ,
            system
            ,
            mainSourceQ
            ,
            P
            ,
            P1
            ,
            P2
            ,
            p
            ,
            centList
            ,
            axpList
            ,
            tetList
            ,
            hex3List
            ,
            hexList
            ,
            monoList
            ,
            sourceSetting
            ,
            targetSetting
            ,
            (* 1.B. Process input syntax and options *)
            inputRules
            ,
            inputString
            ,
            returnP
            ,
            customP
            ,
            moveNegativeQ
            ,
            (* 1.C Process source setting *)
            sourceCentring
            ,
            sourceCell
            ,
            notes
            ,
            relevantNotes
            ,
            sourceO
            ,
            (* 1.D. Interpret space group from input *)
            targetSG
            ,
            needtargetSG
            ,
            (* 1.E Process target setting *)
            allowed
            ,
            cmds
            ,
            na
            ,
            (* 1.F. Validating input values *)
            targetCentring
            ,
            targetAxis
            ,
            targetCC
            ,
            targetAP
            ,
            targetCell
            ,
            targetRS
            ,
            targetO
            ,
            (* 1.G. Check setting constraints on certain space groups *)
            (* 1.H. Determining new space group symbol *)
            targetSGnumber
            ,
            (* 1.I. Common transformation procedures *)
            procedureCellCentring
            ,
            procedureCellOrigin
            ,
            shift
            ,
            (*---* 2. Determining correct transformation matrices *--- *)
            (* 2.A. Triclinic *)
            (* 2.B. Monoclinic *)
            cmd
            ,
            Q
            ,
            (* 2.C. Orthorhombic *)
            (* 2.D. Tetragonal *)
            (* 2.E. Hexagonal crystal family *)
            sourceRS
            ,
            M
            ,
            (* 2.F. Cubic *)
            (*---* 3. Carrying out transformations *---*)
            (* 3.A. Preparations *)
            q
            ,
            newlattice
            ,
            (* 3.B. Transforming coordinates and ADPs *)
            xyz
            ,
            newxyz
            ,
            AnyInsideUnitCellQ
            ,
            adps
            ,
            U
            ,
            n0
            ,
            n
            ,
            newU
            ,
            u
            ,
            (*---* 4. Overwriting entry in $CrystalData *---*)
            targetFullHM
            ,
            (*---* 5. Display *---*)
            (* Dummy variables *)
            temp
            ,
            x
            ,
            y
            ,
            i
        }
        ,
        (*---* 1. Input check and preparation *---*)
        (* 1.A. Load crystal metric, space group and crystal system *)
        InputCheck["GetCrystalSpaceGroup", crystal];
        G = G0 = GetCrystalMetric @ crystal;
        sg = sg0 = $CrystalData[crystal, "SpaceGroup"];
        sg = $GroupSymbolRedirect[sg];
        sourceSG = fullHM = sg["Name", "HermannMauguinFull"];
        posSG = Position[$SpaceGroups, fullHM];
        SG = $SpaceGroups[posSG[[1, 1, 1]]];
        fullHMs = SG["Name", "HermannMauguinFull"];
        sourceSGnumber = SG["SpaceGroupNumber"];
        system = SG["CrystalSystem"];
        mainSourceQ = Length @ First @ posSG <= 3;
        (* Default transformation matrices and origin shift *)
        P = P1 = P2 = IdentityMatrix[3];
        p = {0, 0, 0};
        (* Frequently used lists *)
        centList = {"P", "A", "B", "C", "F", "I"};
        axpList = {"abc", "ba-c", "cab", "-cba", "bca", "a-cb"};
        tetList = {"P", "I", "C1", "F1", "C2", "F2"};
        hex3List = {"R1", "R2", "R3"};
        hexList = {"C1", "C2", "C3", "H1", "H2", "H3", "D1", "D2"};
        monoList = {"Cb1", "Cb2", "Cb3", "Ac1", "Ac2", "Ac3"};
        (* Miscellaneous *)
        sourceSetting = targetSetting = <||>;
        (* 1.B. Process input syntax and options *)
        inputRules = Association @ Cases[{userinput}, _Rule];
        inputString = Cases[{userinput}, _String];
        (* Check *)
        Which[
                # === 0,
                    Null
                ,
                # === 1,
                    inputString = First @ inputString
                ,
                True,
                    Message[UnitCellTransformation::invalidSetting, inputString];
                    Abort[]
            ]& @ Length @ inputString;
        (* Save option settings *)
        returnP = inputRules["ReturnP"];
        customP = Lookup[inputRules, "CustomP", {}];
        moveNegativeQ = Lookup[inputRules, "MoveIfCellEmpty", True];
        (* Remove options from other settings *)
        KeyDropFrom[inputRules, {"ReturnP", "CustomP", "CustomSymbol"}];
        (* 1.C Process source setting *)
        (* i. Load source setting from source space group *)
        sourceSetting = $GroupSymbolRedirect[sourceSG]["Setting"];
        (* ii. Check if space group has alternative settings *)
        If[sourceSetting === <||> &&
            (* Exception: Special multiple cells *)
            !MemberQ[{"Tetragonal", "Hexagonal"}, system],
            Message[UnitCellTransformation::singleRepresentation, GetSymmetryData[sourceSG, "Symbol"], sourceSGnumber];
            Abort[]
        ];
        (* iii. Check cell origin from symbol *)
        temp = StringTake[sg0, -2];
        Which[
            temp === ":2",
                AppendTo[sourceSetting, "CellOrigin" -> 2]
        ];
        (* iv. Checking 'Notes' for info on input setting *)
        notes = Lookup[$CrystalData @ crystal, "Notes", <||>];
        relevantNotes = notes[[{"RhombohedralSetting", "MultipleCell", "CellCentring", "CellOrigin"}]];
        {sourceRS, sourceCell, sourceCentring, sourceO} = Values @ relevantNotes;
        AppendTo[sourceSetting, DeleteMissing @ relevantNotes];
        (* 1.D. Interpret space group from input *)
        (* i. No input commands -- prompt dialogue/UI (TODO) *)
        (* ii. Custom transformation matrix *)
        If[customP =!= {},
            P1 = customP;
            If[!MatrixQ @ P1,(* Check *)
                Message[UnitCellTransformation::invalidSetting, P1];
                Abort[]
            ];
            targetSG = sourceSG (* Use same space group *);
            Goto["MetricTransformation"]
        ];
        (* iii. Interpret string as target space group *)
        If[inputString =!= {},
            (* Check if valid space group symbol *)
            If[MissingQ @ $GroupSymbolRedirect[inputString],
                Message[UnitCellTransformation::spaceGroupFailed, inputString];
                Abort[]
            ];
            targetSG = inputString
        ];
        (* iv. Parse input as setting commands *)
        If[inputRules =!= <||>,
            needtargetSG = True
            ,
            (* Check whether Hall symbol has been used *)
            temp = Position[$SpaceGroups, targetSG];
            If[temp != {},
                If[temp[[1, -1, 1]] === "HallString",
                    targetSG = First[$SpaceGroups @@@ Most @ First @ temp]["Name", "Symbol"]
                ]
            ]
        ];
        (* 1.E Process target setting *)
        If[inputRules =!= <||>,
            (* a. Setting commands given in association *)
            targetSetting = inputRules;
            (* Checking commands *)
            allowed = {"UniqueAxis", "CellChoice", "AxisPermutation", "CellCentring", "MultipleCell", "RhombohedralSetting", "CellOrigin"};
            cmds = Keys @ targetSetting;
            na = Complement[cmds, allowed];
            If[na != {},
                Message[UnitCellTransformation::commandUnrecognized, First @ na];
                Abort[]
            ];
            (* Checking usefullness of commands *)
            temp =
                Which[
                    system === "Triclinic",
                        {"CellCentring"}
                    ,
                    system === "Monoclinic",
                        {"UniqueAxis", "CellChoice"}
                    ,
                    system === "Orthorhombic",
                        {"AxisPermutation", "CellCentring", "CellOrigin"}
                    ,
                    system === "Tetragonal",
                        {"CellCentring", "MultipleCell", "CellOrigin"}
                    ,
                    system === "Trigonal",
                        {"MultipleCell", "RhombohedralSetting"}
                    ,
                    system === "Hexagonal",
                        {"MultipleCell"}
                    ,
                    system === "Cubic",
                        {"CellCentring", "CellOrigin"}
                ];
            targetSetting = DeleteMissing @ targetSetting[[temp]];
            If[targetSetting === <||>,
                Message[UnitCellTransformation::invalidForSystem, ToLowerCase @ system];
                Abort[]
            ]
            ,
            (* b. Setting extracted from target space group *)
            If[!ValueQ @ targetSG,
                targetSG = sourceSG
            ];
            targetSetting = $GroupSymbolRedirect[targetSG]["Setting"]
        ];
        (* Supply with current settings if unspecified in input *)
        targetSetting = Append[sourceSetting, targetSetting];
        (* Exception: No 'RhombohedralSetting' for 'R' cell *)
        If[targetSetting["MultipleCell"] === "R",
            KeyDropFrom[targetSetting, "RhombohedralSetting"]
        ];
        (* 1.F. Validating input values *)
        (* i. 'CellCentring' *)
        targetCentring = targetSetting["CellCentring"];
        If[!MissingQ @ targetCentring,
            If[!MemberQ[centList, targetCentring],
                Message[UnitCellTransformation::invalidSetting, targetCentring];
                Abort[]
            ]
        ];
        (* ii. 'UniqueAxis' *)
        targetAxis = targetSetting["UniqueAxis"];
        If[!MissingQ @ targetAxis,
            If[!MemberQ[{"a", "b", "c"}, targetAxis],
                Message[UnitCellTransformation::invalidSetting, targetAxis];
                Abort[]
            ];
            targetAxis = ToLowerCase @ targetAxis
        ];
        (* iii. 'CellChoice' *)
        targetCC = targetSetting["CellChoice"];
        If[!MissingQ @ targetCC,
            If[!MemberQ[{1, 2, 3}, targetCC],
                Message[UnitCellTransformation::invalidSetting, targetCC];
                Abort[]
            ]
        ];
        (* iv. 'AxisPermutation' *)
        targetAP = targetSetting["AxisPermutation"];
        If[!MissingQ @ targetAP,
            (* Check if string *)
            If[!StringQ @ targetAP,
                Message[UnitCellTransformation::invalidSetting, targetAP];
                Abort[]
            ];
            (* Support for various input forms *)
            targetAP = ToLowerCase @ StringReplace[targetAP, {"\!\(\*OverscriptBox[\(c\), \(_\)]\)" -> "-c", "\!\(\*OverscriptBox[\(C\), \(_\)]\)" -> "-C"}];
            (* Check setting value *)
            If[!MemberQ[axpList, targetAP],
                Message[UnitCellTransformation::invalidSetting, targetSetting["AxisPermutation"]];
                Abort[]
            ];
            (* Update 'targetSetting' *)
            targetSetting["AxisPermutation"] = targetAP
        ];
        (* v. 'MultipleCell' *)
        targetCell = targetSetting["MultipleCell"];
        If[!MissingQ @ targetCell,
            (* Depending on crystal system... *)
            temp =
                Which[
                    system === "Tetragonal",
                        tetList
                    ,
                    system === "Trigonal" || system === "Hexagonal",
                        Flatten @ Join[{"P", "R"}, hex3List, hexList, monoList]
                    ,
                    True,
                        Message[UnitCellTransformation::invalidForSystem, ToLowerCase @ system];
                        Abort[]
                ];
            (* Check setting value *)
            If[!MemberQ[temp, targetCell],
                Message[UnitCellTransformation::invalidSpaceGroup, targetCell];
                Abort[]
            ]
        ];
        (* vi. 'RhombohedralSetting' *)
        targetRS = inputRules["RhombohedralSetting"];
        If[!MissingQ @ targetRS,
            targetRS = ToLowerCase @ targetRS;
            (* Check setting value *)
            If[!MemberQ[{"obverse", "reverse"}, targetRS],
                Message[UnitCellTransformation::invalidSetting, targetSetting["RhombohedralSetting"]];
                Abort[]
            ];
            (* Update 'targetSetting' *)
            targetSetting["RhombohedralSetting"] = targetRS
        ];
        (* vii. 'CellOrigin' *)
        targetO = targetSetting["CellOrigin"];
        If[!MissingQ @ targetO,
            If[!MemberQ[{1, 2}, targetO],
                Message[UnitCellTransformation::invalidSetting, targetO];
                Abort[]
            ]
        ];
        (* 1.G. Check setting constraints on certain space groups *)
        (* i. Target setting must be a subset of space group settings *)
        If[!(
            SubsetQ @@
                Keys /@
                    {
                        SG["Setting"]
                        ,
                        Which[(* Exceptions: Cell centring and special multiple cells 
                            
                            
                            
                            
                            
                            
                            
                            
                            *)
                            MemberQ[{"Tetragonal", "Hexagonal"}, system],
                                KeyDrop[targetSetting, "MultipleCell"]
                            ,
                            MemberQ[{"Monoclinic", "Orthorhombic", "Tetragonal", "Cubic"}, system],
                                KeyDrop[targetSetting, "CellCentring"]
                            ,
                            True,
                                targetSetting
                        ]
                    }
        ),
            Message[UnitCellTransformation::settingMismatch, Keys @ sourceSetting, Keys @ targetSetting];
            Abort[]
        ];
        (* 1.H. Determining new space group symbol *)
        (* i. Determine the target space group from setting if needed *)
        If[needtargetSG,
            (* Main entry? *)
            If[Sort @ SG["Setting"] === Sort @ targetSetting,
                targetSG = SG["Name", "HermannMauguinFull"]
                ,
                (* Special multiple cell? *)
                If[MemberQ[Flatten @ Join[{tetList, {"R"}, hex3List, hexList, monoList}], targetCell],
                    targetSG = sourceSG;
                    targetSGnumber = sourceSGnumber;
                    Goto["CheckSGformat"]
                ];
                (* Check alternatives *)
                temp = SG[["AlternativeSettings"]];
                i = 1;
                While[
                    True
                    ,
                    If[i > Length @ temp,
                        Message[UnitCellTransformation::targetFailed];
                        Abort[]
                    ];
                    If[Sort @ temp[[i, "Setting"]] === Sort @ targetSetting,
                        targetSG = temp[[i, "Name", "HermannMauguinFull"]];
                        Break[]
                    ];
                    i++
                ]
            ]
        ];
        (* ii. Check if source and target are same space group *)
        targetSGnumber = GetSymmetryData[targetSG, "SpaceGroupNumber"];
        If[sourceSGnumber != targetSGnumber,
            Message[UnitCellTransformation::differentSpaceGroups, GetSymmetryData[sourceSG, "Symbol"], sourceSGnumber, GetSymmetryData[targetSG, "Symbol"], targetSGnumber];
            Abort[]
        ];
        (* iii. Check whether to use formatted symbol *)
        Label["CheckSGformat"];
        targetSG = ToStandardSetting @ targetSG;
        (* 1.I. Common transformation procedures *)
        (* 'CellCentring' *)
        procedureCellCentring :=
            (
                If[!MissingQ @ targetCentring,
                    If[MissingQ @ sourceCentring || !ValueQ @ sourceCentring,
                        sourceCentring = StringTake[fullHM, 1]
                    ];
                    Which[(* No change *)
                        sourceCentring === targetCentring,
                            Null
                        ,
                        (* Transformation from 'P' *)sourceCentring === "P",
                            P1 = Inverse @ $TransformationMatrices[targetCentring <> "_to_P"]
                        ,
                        (* Transformation to 'P' *)targetCentring === "P",
                            P1 = $TransformationMatrices[sourceCentring <> "_to_P"]
                        ,
                        (* Transformation via 'P' *)True,
                            P1 = $TransformationMatrices[sourceCentring <> "_to_P"];
                            P2 = Inverse @ $TransformationMatrices[targetCentring <> "_to_P"]
                    ]
                ]
            );
        (* 'CellOrigin' *)
        procedureCellOrigin :=
            (
                If[KeyExistsQ[targetSetting, "CellOrigin"],
                    temp = {sourceSetting["CellOrigin"], targetO};
                    shift = SG[["AlternativeSettings", 1, "OriginShift"]];
                    If[!MissingQ @ targetO,
                        (* Get space group origin shift (shift vector) *)
                        Which[
                            temp === {1, 1},
                                Null
                            ,
                            temp === {2, 2},
                                Null
                            ,
                            temp === {1, 2},
                                p = shift
                            ,
                            temp === {2, 1},
                                p = -shift
                        ]
                    ]
                ]
            );
        (*---* 2. Determining correct transformation matrices *---*)
        Goto[system];
        (*-- 2.A. Triclinic --*)
        Label["Triclinic"];
        (* i. 'CellCentring' *)
        procedureCellCentring;
        (* Preparations done *)
        Goto["MetricTransformation"];
        (*-- 2.B. Monoclinic --*)
        Label["Monoclinic"];
        (* Prepartations *)
        (* If target axis not given, use same axis as source *)
        If[MissingQ @ targetAxis || !ValueQ @ targetAxis,
            targetAxis = sourceSetting["UniqueAxis"]
        ];
        (* i. 'UniqueAxis' *)
        (* Target unique axis transformation *)
        allowed = {"UniqueAxisB_to_C", "UniqueAxisB_to_A", "UniqueAxisC_to_A"};
        temp = ToUpperCase /@ {sourceSetting["UniqueAxis"], targetAxis};
        (* Check whether P or Q (inverse) is needed *)
        cmd = "UniqueAxis" <> temp[[1]] <> "_to_" <> temp[[2]];
        If[MemberQ[allowed, cmd],
            Q = False
            ,
            Q = True;
            cmd = "UniqueAxis" <> temp[[2]] <> "_to_" <> temp[[1]]
        ];
        (* Target unique axis transformation *)
        If[!SameQ @@ temp,
            P1 = $TransformationMatrices[cmd];
            If[Q,
                P1 = Inverse @ P1
            ]
        ];
        (* ii. 'CellChoice' *)
        (* Check if cell choice is an available setting *)
        If[!KeyExistsQ[SG["Setting"], "CellChoice"] && KeyExistsQ[targetSetting, "CellChoice"],
            Message[UnitCellTransformation::commandUnrecognized, "CellChoice"];
            Abort[]
            ,
            If[!MissingQ @ targetCC,
                (* Matrix for checking transformation signature *)
                temp = {{0, 1, -1}, {-1, 0, 1}, {1, -1, 0}};
                temp = temp[[sg["Setting", "CellChoice"], targetCC]];
                (* Use regular, none, or inverse transformation *)
                Which[
                    temp === -1,
                        Q = True
                    ,
                    temp === 0,
                        Goto["MetricTransformation"]
                    ,
                    temp === 1,
                        Q = False
                ];
                cmd = "UniqueAxis" <> ToUpperCase @ targetAxis <> "_CellChoice+1";
                P2 = $TransformationMatrices[cmd];
                If[Q,
                    P2 = Inverse @ P2
                ];
            ]
        ];
        (* Preparations done *)
        Goto["MetricTransformation"];
        (*-- 2.C. Orthorhombic --*)
        Label["Orthorhombic"];
        (* i. 'AxisPermutation' *)
        If[!MissingQ @ targetAP,
            (* Check which matrices are needed *)
            temp = ToUpperCase /@ {sourceSetting["AxisPermutation"], targetAP};
            If[SameQ @@ temp,
                (* Same axis permutation -- no transform required *)
                Null
                ,
                If[!MemberQ[temp, "DEF"],
                    (* Chain through 'abc' *)
                    x = temp[[1]] <> "_to_DEF";
                    y = temp[[2]] <> "_to_DEF";
                    P1 = $TransformationMatrices[x];
                    P2 = Inverse @ $TransformationMatrices[y]
                    ,
                    (* OR use one of the six transformations *)
                    cmd = temp[[1]] <> "_to_" <> temp[[2]];
                    If[KeyExistsQ[$TransformationMatrices, cmd],
                        P1 = $TransformationMatrices[cmd]
                        ,
                        P1 = Inverse @ $TransformationMatrices[temp[[2]] <> "_to_" <> temp[[1]]]
                    ]
                ]
            ]
        ];
        (* ii. 'CellOrigin' *)
        procedureCellOrigin;
        (* Preparations done *)
        Goto["MetricTransformation"];
        (*-- 2.D. Tetragonal --*)
        Label["Tetragonal"];
        (* Checks and updates *)
        If[MissingQ @ sourceCentring || !ValueQ @ sourceCentring,
            sourceCentring = StringTake[sg["Name", "HermannMauguinShort"], 1]
        ];
        If[MissingQ @ targetCentring || !ValueQ @ targetCentring,
            targetCentring = StringTake[SG["Name", "HermannMauguinShort"], 1]
        ];
        (* i. 'CellCentring' *)
        procedureCellCentring;
        (* ii. 'MultipleCell' *)
        If[KeyExistsQ[targetSetting, "MultipleCell"],
            (* If already transformed, transform to 'P' or 'I' *)
            If[MemberQ[tetList, sourceCell],
                P1 = Inverse @ $TransformationMatrices["TetragonalProjection" <> StringTake[sourceCell, -1]]
            ];
            (* Transforming to target cell *)
            If[!MemberQ[{"P", "I"}, targetCell],
                P2 = $TransformationMatrices["TetragonalProjection" <> StringTake[targetCell, -1]]
            ]
        ];
        (* iii. 'CellOrigin' *)
        procedureCellOrigin;
        (* Preparations done *)
        Goto["MetricTransformation"];
        (*-- 2.E. Hexagonal crystal family --*)
        Label["Trigonal"];
        Label["Hexagonal"];
        (* Checks and updates *)
        (* Reinstate 'MultipleCell' label *)
        If[MissingQ @ sourceCell || !ValueQ @ sourceCell,
            sourceCell = sourceSetting["MultipleCell"]
        ];
        (* Check rhombohedral source setting *)
        If[MissingQ @ sourceRS || !ValueQ @ sourceRS,
            (* Assume main space group setting *)
            sourceRS = "obverse"
        ];
        (* Check rhombohedral target setting *)
        If[MissingQ @ targetRS && MemberQ[hex3List, targetCell],
            targetRS = "obverse"
        ];
        If[!MissingQ @ targetRS && targetCell === "R",
            targetCell = "R1"
        ];
        Which[(* A. Rhombohedral space group *)
            SubsetQ[{146, 148, 155, 160, 161, 166, 167}, {sourceSGnumber, targetSGnumber}],
                (* Check target command *)If[!MemberQ[Flatten @ Join[{{"R"}, hex3List, monoList}], targetCell],
                    Message[UnitCellTransformation::invalidSpaceGroup, targetCell];
                    Abort[]
                ];
                Which[(* a. Rhombohedral source *)
                    sourceCell === "R",
                        Which[(* a.1. Rhombohedral target *)
                            targetCell === "R" && MissingQ @ targetRS,
                                Goto["MatricesDone"]
                            ,
                            (* a.2. Triple hexagonal target *)MemberQ[hex3List, targetCell],
                                P1 = $TransformationMatrices["Rhombohedral_to_" <> targetCell <> "_" <> targetRS]
                            ,
                            (* a.3. Monoclinic target *)True,
                                P1 = $TransformationMatrices["Rhombohedral_to_Monoclinic_" <> targetCell]
                        ]
                    ,
                    (* b. Regular hexagonal (R1, R2, R3) source *)MemberQ[hex3List, sourceCell],
                        Which[(* b.1. Rhombohedral target *)
                            targetCell === "R",
                                P1 = Inverse @ $TransformationMatrices["Rhombohedral_to_" <> sourceCell <> "_" <> sourceRS]
                            ,
                            (* b.2. Triple hexagonal target *)MemberQ[hex3List, targetCell],
                                If[sourceCell === targetCell && sourceRS === targetRS,
                                    Goto["MatricesDone"]
                                ];
                                P1 = Inverse @ $TransformationMatrices["Rhombohedral_to_" <> sourceCell <> "_" <> sourceRS];
                                P2 = $TransformationMatrices["Rhombohedral_to_" <> targetCell <> "_" <> targetRS]
                            ,
                            (* b.3. Monoclinic target *)True,
                                If[sourceCell === "R1" && sourceRS === "obverse",
                                    P1 = $TransformationMatrices["TripleHexagonal_to_Monoclinic_" <> targetCell]
                                    ,
                                    P1 = Inverse @ $TransformationMatrices["Rhombohedral_to_" <> sourceCell <> "_" <> sourceRS];
                                    P2 = $TransformationMatrices["Rhombohedral_to_Monoclinic_" <> targetCell]
                                ]
                        ]
                    ,
                    (* c. Monoclinic source *)MemberQ[monoList, sourceCell],
                        Which[(* c.1. Rhombohedral target *)
                            targetCell === "R",
                                P1 = Inverse @ $TransformationMatrices["Rhombohedral_to_Monoclinic_" <> sourceCell]
                            ,
                            (* c.2. Regular hexagonal (R1, R2, R3)l target *)MemberQ[hex3List, targetCell],
                                P1 = Inverse @ $TransformationMatrices["Rhombohedral_to_Monoclinic_" <> sourceCell];
                                P2 = $TransformationMatrices["Rhombohedral_to_" <> targetCell <> "_" <> targetRS]
                            ,
                            (* c.3. Monoclinic target *)True,
                                If[sourceCell === targetCell,
                                    Goto["MatricesDone"]
                                ];
                                P1 = Inverse @ $TransformationMatrices["Rhombohedral_to_Monoclinic_" <> sourceCell];
                                P2 = $TransformationMatrices["Rhombohedral_to_Monoclinic_" <> targetCell]
                        ]
                ]
            ,
            (* B. Transformation of the hexagonal lattice *)True,
                (* Check if target is valid *)If[!MemberQ[Flatten @ Join[{{"P"}, hexList, monoList}], targetCell],
                    Message[UnitCellTransformation::invalidSpaceGroup, targetCell];
                    Abort[]
                ];
                M = Flatten @ DeleteCases[StringCases[Keys @ $TransformationMatrices, StartOfString ~~ "Hexagonal" ~~ __], {}];
                If[MissingQ @ sourceCell,
                    sourceCell = "P"
                ];
                Which[(* a. Primitive hexagonal source *)
                    sourceCell === "P",
                        Which[(* a.1. No change *)
                            targetCell === "P",
                                Goto["MatricesDone"]
                            ,
                            (* a.2. Special hexagonal target *)MemberQ[hexList, targetCell],
                                temp = Select[M, StringContainsQ[#, targetCell]&];
                                P1 = $TransformationMatrices @@ temp
                        ]
                    ,
                    (* b. Special hexagonal source *)MemberQ[hexList, sourceCell],
                        Which[(* b.1. To primitive hexagonal cell *)
                            targetCell === "P",
                                temp = Select[M, StringContainsQ[#, targetCell]&];
                                P1 = Inverse @ $TransformationMatrices @@ temp
                            ,
                            (* b.2. To special hexagonal target *)MemberQ[hexList, targetCell],
                                If[sourceCell === targetCell,
                                    Goto["MatricesDone"]
                                ];
                                temp = Select[M, StringContainsQ[#, sourceCell]&];
                                P1 = Inverse[$TransformationMatrices @@ temp];
                                temp = Select[M, StringContainsQ[#, targetCell]&];
                                P2 = $TransformationMatrices @@ temp
                        ]
                ]
        ];
        Label["MatricesDone"];
        (* Preparations done *)
        Goto["MetricTransformation"];
        (*-- 2.F. Cubic --*)
        Label["Cubic"];
        (* i. 'CellCentring' *)
        procedureCellCentring;
        (* ii. 'CellOrigin' *)
        procedureCellOrigin;
        (* Preparations done *)
        Goto["MetricTransformation"];
        (*---* 3. Carrying out transformations *---*)
        (* 3.A. Preparations *)
        Label["MetricTransformation"];
        P = P1 . P2;
        If[returnP === All,
            Return @ {P1, P2}
        ];
        If[returnP,
            Return @ P
        ];
        Q = Inverse @ P;
        q = -Q . p;
        G = Transpose[P] . G . P;
        newlattice = Association @ Thread[{"a", "b", "c", "\[Alpha]", "\[Beta]", "\[Gamma]"} -> GetLatticeParameters[G, "Units" -> True]];
        (* 3.B. Transforming coordinates and ADPs *)
        (* Fractional coordinates *)
        xyz = $CrystalData[[crystal, "AtomData", All, "FractionalCoordinates"]];
        newxyz = Chop[FractionalPart[Dot[Q, #] + q]& /@ xyz];
        (* Optional: Move content to unit cell if empty *)
        If[TrueQ @ moveNegativeQ,
            AnyInsideUnitCellQ[allCoordinates_] := Or @@ Map[AllTrue[#, 0 <= # <= 1&]&, allCoordinates];
            If[Length @ newxyz <= 100 && !AnyInsideUnitCellQ @ newxyz,
                newxyz = Transpose[Transpose @ newxyz - First @ Sort @ Floor @ newxyz]
            ]
        ];
        (* Atomic displacement parameters *) adps = Lookup[$CrystalData[crystal, "AtomData"], "DisplacementParameters", 0.];
        U = {{#1, #4, #5}, {#4, #2, #6}, {#5, #6, #3}}& @@ #& /@ adps;
        (* Preparing diagonal 'N' matrices *)
(* References:
    https://doi.org/10.1107/S0108767311018216
    https://doi.org/10.1107/S0021889802008580
*)
        n0 = DiagonalMatrix @ Sqrt @ Diagonal @ Inverse @ G0;
        n = Inverse @ DiagonalMatrix @ Sqrt @ Diagonal @ Inverse @ G;
        (* Transforming ADPs *)
        newU = {};
        Do[
            u = U[[i]];
            If[MatrixQ[u],
                temp = n0 . u . Transpose[n0];
                temp = Q . temp . Transpose[Q];
                temp = Chop[n . temp . Transpose[n]];
                temp = Part[temp, # /. List -> Sequence]& /@ {{1, 1}, {2, 2}, {3, 3}, {1, 2}, {1, 3}, {2, 3}}
                ,
                temp = u
            ];
            AppendTo[newU, temp]
            ,
            {i, Length @ adps}
        ];
        (*---* 4. Overwriting entry in $CrystalData *---*)
        (* Determine new space group symbol automatically *)
        (* Remove old cell tag *)
        If[StringTake[targetSG, {-2}] === ":",
            targetSG = StringTake[targetSG, {1, -3}]
        ];
        (* Update space group symbol *)
        If[(targetO === 2 || targetSetting["CellOrigin"] === 2) && !StringContainsQ[targetSG, ":2"],
            targetSG = targetSG <> ":2"
        ];
        (* Get full Hermann\[Dash]Mauguin symbol *)
        targetFullHM = GetSymmetryData[targetSG, "HermannMauguinFull"];
        (* Set new symbol *)
        $CrystalData[crystal, "SpaceGroup"] = targetSG;
        (* New lattice parameters *)
        AppendTo[$CrystalData[crystal, "LatticeParameters"], newlattice];
        (* New fractional coordinates *)
        $CrystalData[[crystal, "AtomData", All, "FractionalCoordinates"]] = newxyz;
        (* New ADPs *)
        If[!AllTrue[N @ newU, # == 0.&],
            $CrystalData[[crystal, "AtomData", All, "DisplacementParameters"]] = newU
        ];
        (* Updating 'Notes' and adding space group notes if needed *)
        If[(* a. Exception: default space group setting *)Sort @ Values @ SG["Setting"] === Sort @ DeleteMissing @ {targetCell, targetRS, targetCentring},
            KeyDropFrom[notes, {"MultipleCell", "RhombohedralSetting", "CellCentring"}]
            ,
            (* b. Write both multiple cell and rhombohedral setting *)
            If[KeyExistsQ[targetSetting, "MultipleCell"] && !MemberQ[{"P", "I"}, targetCell],
                AppendTo[notes, "MultipleCell" -> targetCell]
            ];
            If[MemberQ[hex3List, targetCell],
                AppendTo[notes, "RhombohedralSetting" -> targetRS]
                ,
                KeyDropFrom[notes, "RhombohedralSetting"]
            ];
            If[!MissingQ @ targetCentring && ValueQ @ targetCentring &&
                (* No need if centring is in space group symbol *)
                StringTake[targetFullHM, 1] != targetCentring,
                AppendTo[notes, "CellCentring" -> targetCentring]
            ]
        ];
        (* Writing over 'Notes' or removing if empty *)
        If[notes =!= <||>,
            $CrystalData[crystal, "Notes"] = Sort @ notes
            ,
            KeyDropFrom[$CrystalData[crystal], "Notes"]
        ];
        (*---* 5. Display *---*)
        Label["End"];
        InputCheck["ShallowDisplayCrystal", crystal]
    ]

End[];
