InputCheck::InvalidLabel = "\[LeftGuillemet]`1`\[RightGuillemet] is not a recognised check label.";

InputCheck::InvalidTuple = "Reflections (and coordinates) must be on a {\!\(\*
StyleBox[\"h\", \"TI\"]\), \!\(\*
StyleBox[\"k\", \"TI\"]\), \!\(\*
StyleBox[\"l\", \"TI\"]\)} (or {\!\(\*
StyleBox[\"x\", \"TI\"]\), \!\(\*
StyleBox[\"y\", \"TI\"]\), \!\(\*
StyleBox[\"z\", \"TI\"]\)}) form";

InputCheck::SingleTupleExpected = "Only one `1` expected.";

InputCheck::IntegerExpected = "One or more indices are not integers.";

InputCheck::InvalidInputType = "Head of indices must be either Integer, String or Symbol.";

InputCheck::MultipleTuplesExpected = "At least two reflections are required to make comparisons.";

InputCheck::EnergyUnitExpected = "Input does not have a unit compatible with energy or wavelength.";

InputCheck::InvalidEnergyInput = "Input must be an energy or wavelength compatible Quantity, or a number.";

InputCheck::EnergyMustBePositive = "The wavelength/energy must be positive.";

InputCheck::InvalidCrystalEntity = "\[LeftGuillemet]`1`\[RightGuillemet] is not a valid crystal entity.";

InputCheck::NotIn$CrystalData = "No data found on \[LeftGuillemet]`1`\[RightGuillemet].";

InputCheck::NoWavelengthIncluded = "No wavelength was found for crystal \[LeftGuillemet]`1`\[RightGuillemet].";

InputCheck::InvalidUserInput = "Invalid user input.";

InputCheck::InvalidPolarisationSetting = "Invalid polarisation setting.";

InputCheck::InvalidPointOrSpaceGroup = "Unable to interpret \[LeftGuillemet]`1`\[RightGuillemet] as a point- or space group.";

InputCheck::InvalidPointGroup = "Unable to interpret \[LeftGuillemet]`1`\[RightGuillemet] as a point group.";

InputCheck::InvalidSpaceGroup = "Unable to interpret \[LeftGuillemet]`1`\[RightGuillemet] as a space group.";

InputCheck::InvalidSpaceGroupNumber = "Valid space group numbers are between 1 and 230.";

InputCheck::InvalidSymmetryObject = "Unable to interpret \[LeftGuillemet]`1`\[RightGuillemet] as a point group, space group or a crystal.";

InputCheck::InvalidCentring = "Invalid space group centring.";

InputCheck::ElementNumber = "Element number `1` is out of range.";

InputCheck::ElementFailed = "Unable to interpret \[LeftGuillemet]`1`\[RightGuillemet] as a chemical element.";

InputCheck::ElementError = "The element \[LeftGuillemet]`1`\[RightGuillemet] cannot be interpreted.";

InputCheck::InvalidCrystalFamily = "\[LeftGuillemet]`1`\[RightGuillemet] is not a valid crystal family.";

InputCheck::InvalidDimension = "Dimension must be either \"2D\" or \"3D\".";

InputCheck::DomainSizeError = "Discrepancy between given domain size and length.";

InputCheck::InvalidRotationPoint = "Invalid rotation point.";

InputCheck::InvalidRotationReference = "Reference for rotation anchor must either be \"Host\", \"Domain\", \"DomainCentroid\" or \"Unit\".";

InputCheck::InvalidRotationMap = "Values of `1`D rotation maps must be `2`.";

SyntaxInformation @ InputCheck = {"ArgumentsPattern" -> {__}};

Begin["`Private`"];

InputCheck[input_List, labels___ ? (SubsetQ[{"1hkl", "1xyz", "Integer", "Multiple", "StringSymbol", "WrapSingle"}, {#}]&)] :=
    Block[
        {check, hkl, temp}
        ,
        (* Check labels *)
        check = {labels};
        Do[
            temp = check[[i]];
            If[!MemberQ[{"1hkl", "1xyz", "Integer", "Multiple", "StringSymbol", "WrapSingle"}, temp],
                Message[InputCheck::InvalidLabel, temp];
                Abort[]
            ]
            ,
            {i, Length @ check}
        ];
        (* Dimensions check (always required) *)
        Which[(* Single reflection/coordinate *)
            MatchQ[input, {x1_, x2_, x3_} /; !AnyTrue[{x1, x2, x3}, ListQ]],
                hkl = {input}
            ,
            (* Multiple reflections/coordinates *)AllTrue[input, MatchQ[#, {x1_, x2_, x3_} /; !AnyTrue[{x1, x2, x3}, ListQ]]&],
                hkl = input
            ,
            (* None of the above *)True,
                Message[InputCheck::InvalidTuple];
                Abort[]
        ];
        (* Single reflection/coordinates check *)
        If[MemberQ[check, "1hkl"],
            If[Length @ hkl != 1,
                Message[InputCheck::SingleTupleExpected, "reflection"];
                Abort[]
            ]
        ];
        If[MemberQ[check, "1xyz"],
            If[Length @ hkl != 1,
                Message[InputCheck::SingleTupleExpected, "coordinate"];
                Abort[]
            ]
        ];
        (* Multiple reflections check *)
        If[MemberQ[check, "Multiple"],
            If[Length @ hkl < 2,
                Message[InputCheck::MultipleTuplesExpected];
                Abort[]
            ]
        ];
        (* Integer check *)
        If[MemberQ[check, "Integer"],
            If[!AllTrue[Flatten @ hkl, IntegerQ],
                Message[InputCheck::IntegerExpected];
                Abort[]
            ]
        ];
        (* Check if Integer, String or Symbol *)
        If[MemberQ[check, "StringSymbol"],
            If[!ContainsAll[{Integer, String, Symbol, Times}, Head /@ Flatten @ hkl],
                Message[InputCheck::InvalidInputType];
                Abort[]
            ]
        ];
        (* Wrap single reflections *)
        If[MemberQ[check, "WrapSingle"],
            If[MatchQ[input, {_ ? (!ListQ[#]&), _ ? (!ListQ[#]&), _ ? (!ListQ[#]&)}],
                Return[{input}]
                ,
                Return[input]
            ]
        ]
    ]

InputCheck["CrystalEntityQ", input_] :=
    (
        If[input === "Void",
            Return[]
        ];
        If[MemberQ[Keys @ $PeriodicTable, input],
            Return[]
        ];
        If[MemberQ[Keys @ $CrystalData, input],
            Return[]
        ];
        Message[InputCheck::InvalidCrystalEntity, input];
    )

InputCheck["CrystalQ", input_, quietFailure_:True] :=
    Block[{dataRegular, dataTemp},
        dataRegular = $CrystalData @ input;
        dataTemp = StianRamsnes`MaXrd`Private`$TempCrystalData @ input;
        Which[
            AssociationQ @ dataRegular,
                Return @ dataRegular
            ,
            AssociationQ @ dataTemp,
                Return @ dataTemp
            ,
            True,
                If[TrueQ @ quietFailure,
                    Return @ Association[]
                    ,
                    Message[InputCheck::NotIn$CrystalData, input];
                    Abort[]
                ]
        ]
    ]

InputCheck["FilterSpecialLabels", input_List] :=
    Intersection[Join[{"Void"}, Keys @ $PeriodicTable], input]

InputCheck["GenerateTargetPositions", {x_, y_, z_}] :=
    Flatten[Table[{i, j, k}, {i, 0., N @ x - 1}, {j, 0., N @ y - 1}, {k, 0., N @ z - 1}], 2]

InputCheck["GetAtomData", label_String] :=
    Block[{data},
        InputCheck["CrystalQ", label];
        data = Lookup[$CrystalData, label];
        If[MissingQ @ data,
            data = Lookup[StianRamsnes`MaXrd`Private`$TempCrystalData, label]
        ];
        data["AtomData"]
    ]

InputCheck["GetCentringVectors", centring_String] :=
    Block[{group, letter, vectors},
        If[StringLength @ centring =!= 1,
            group = InputCheck["GetPointSpaceGroupCrystal", centring];
            letter = First @ StringCases[ToString[group, OutputForm], LetterCharacter];
            Return @ InputCheck["GetCentringVectors", letter]
        ];
        vectors =
            Switch[centring,
                "P",
                    {}
                ,
                "F",
                    {{1/2, 1/2, 0}, {0, 1/2, 1/2}, {1/2, 0, 1/2}}
                ,
                "I",
                    {{1/2, 1/2, 1/2}}
                ,
                "R",
                    {{2/3, 1/3, 1/3}, {1/3, 2/3, 2/3}}
                ,
                "r",
                    {{1/3, 2/3, 1/3}, {2/3, 1/3, 2/3}}
                ,
                "A",
                    {{0, 1/2, 1/2}}
                ,
                "B",
                    {{1/2, 0, 1/2}}
                ,
                "C",
                    {{1/2, 1/2, 0}}
                ,
                "H",
                    {{2/3, 1/3, 0}, {1/3, 2/3, 0}}
                ,
                _,
                    Message[InputCheck::InvalidCentring];
                    {}
            ];
        PrependTo[vectors, {0, 0, 0}]
    ]

InputCheck["GetCrystalFamilyMetric", family_, dimension_] :=
    Block[
        {M, a, b, c, \[Alpha], \[Beta], \[Gamma]}
        ,
        (* Input checks *)
        If[!MemberQ[{"Cubic", "Hexagonal", "Tetragonal", "Orthorhombic", "Monoclinic", "Triclinic"}, family],
            Message[InputCheck::InvalidCrystalFamily, family];
            Abort[]
        ];
        If[!MemberQ[{"2D", "3D"}, dimension],
            Message[InputCheck::InvalidDimension];
            Abort[]
        ];
        (* Metric *)
        M = {{1, b Cos[\[Gamma]], c Cos[\[Beta]]}, {0, b Sin[\[Gamma]], c (Cos[\[Alpha]] - Cos[\[Beta]] Cos[\[Gamma]]) Csc[\[Gamma]]}, {0, 0, c * Sqrt[1 - Cos[\[Beta]] ^ 2 - (Cos[\[Alpha]] - Cos[\[Beta]] Cos[\[Gamma]]) ^ 2 Csc[\[Gamma]] ^ 2]}};
        M =
            N[
                M /.
                    Switch[family,
                        "Cubic",
                            {a -> 1., b -> 1., c -> 1., \[Alpha] -> 90 * \[Degree], \[Beta] -> 90 \[Degree], \[Gamma] -> 90 \[Degree]}
                        ,
                        "Hexagonal",
                            {a -> 1., b -> 1., c -> 1., \[Alpha] -> 90 * \[Degree], \[Beta] -> 90 \[Degree], \[Gamma] -> 120 \[Degree]}
                        ,
                        "Tetragonal",
                            {a -> 1., b -> 1., c -> 1.61803, \[Alpha] -> 90 \[Degree], \[Beta] -> 90 \[Degree], \[Gamma] -> 90 \[Degree]}
                        ,
                        "Orthorhombic",
                            {a -> 1.7, b -> 1.2, c -> 0.85, \[Alpha] -> 90 \[Degree], \[Beta] -> 90 \[Degree], \[Gamma] -> 90 \[Degree]}
                        ,
                        "Monoclinic",
                            {a -> 1., b -> 0.7, c -> 1.2, \[Alpha] -> 90 \[Degree], \[Beta] -> 72. \[Degree], \[Gamma] -> 90 \[Degree]}
                        ,
                        "Triclinic",
                            {a -> 1.3, b -> 0.8, c -> 0.9, \[Alpha] -> 66. \[Degree], \[Beta] -> 77. \[Degree], \[Gamma] -> 88. \[Degree]}
                    ]
            ];
        If[dimension === "2D",
            M[[{1, 2}, {1, 2}]]
            ,
            M
        ]
    ]

InputCheck["GetCrystalFormulaUnits", input_String] :=
    Block[
        {output}
        ,
        (* Check if crystal entry exists *)
        InputCheck["CrystalQ", input];
        (* Return crystal wavelength if attached *)
        If[KeyExistsQ[$CrystalData[input], "FormulaUnits"],
            $CrystalData[input, "FormulaUnits"]
            ,
            (* If not, query user manually *)
            output = ToExpression @ InputString["Cannot determine the number of formula units " <> "for \[LeftGuillemet]" <> input <> "\[RightGuillemet]." <> "\n" <> "Please enter that number or the density below."]
        ];
        If[!NumericQ @ output,
            Message[InputCheck::InvalidUserInput];
            Abort[]
            ,
            output
        ]
    ]

InputCheck["GetCrystalSpaceGroup", input_String] :=
    Block[{sg = input},
        If[MemberQ[Keys @ $CrystalData, input],
            sg = $CrystalData[input, "SpaceGroup"]
        ];
        InputCheck["InterpretSpaceGroup", sg]
    ]

InputCheck["GetCrystalWavelength", input_String, abortQ_:True] :=
    (
        (* Check if crystal entry exists *)InputCheck["CrystalQ", input];
        (* Return crystal wavelength if attached *)
        If[KeyExistsQ[$CrystalData[input], "Wavelength"],
            Return @ $CrystalData[input, "Wavelength"]
            ,
            (* If not, abort OR return '-1' *)
            If[abortQ,
                Message[InputCheck::NoWavelengthIncluded, input];
                Abort[]
                ,
                Return[-1]
            ]
        ]
    )

(* Converts to wavelength [\[ARing]ngstr\[ODoubleDot]ms] *)

InputCheck["GetEnergyWavelength", input_, unitsQ_:True] :=
    Block[
        {hcKeV = 12.398420, \[Lambda]}
        ,
        (* Only exception *)
        If[input === -1,
            Return[-1]
        ];
        (* Check if positive *)
        If[!Positive @ input,
            Message[InputCheck::EnergyMustBePositive];
            Abort[]
        ];
        Which[(* A. Number input *)
            NumericQ @ input,
                Which[(* 1. Assume \[ARing]ngstr\[ODoubleDot]ms *)
                    input <= 5.0,
                        \[Lambda] = N @ input
                    ,
                    (* 2. Assume kilo electronvolt *)input <= 250.0,
                        \[Lambda] = hcKeV / input
                    ,
                    (* 3. Assume electronvolts *)True,
                        \[Lambda] = 1000 * hcKeV / input
                ]
            ,
            (* B. Quantity input *)QuantityQ[input],
                (* Convert wavelength or energy to \[ARing]ngstr\[ODoubleDot]ms *)Which[
                    UnitDimensions[input] === {{"LengthUnit", 1}},
                        \[Lambda] = UnitConvert[input, "Angstroms"];
                        If[unitsQ,
                            Return @ \[Lambda]
                            ,
                            Return @ QuantityMagnitude @ \[Lambda]
                        ]
                    ,
                    CompatibleUnitQ[input, "Joules"],
                        \[Lambda] = hcKeV / QuantityMagnitude @ UnitConvert[input, "Kiloelectronvols"]
                    ,
                    True,
                        Message[InputCheck::EnergyUnitExpected];
                        Abort[]
                ]
            ,
            (* C. None of the above *)True,
                Message[InputCheck::InvalidEnergyInput];
                Abort[]
        ];
        (* Set in Quantity if desired *)
        If[unitsQ,
            Quantity[\[Lambda], "Angstroms"]
            ,
            \[Lambda]
        ]
    ]

InputCheck["GetPointSpaceGroupCrystal", input_] :=
    Block[
        {$CrystalDataCombined, sg}
        ,
        (* Check if space group number is given *)
        If[(1 <= input <= 230) && IntegerQ @ input,
            Return @ $SpaceGroups[[input, "Name", "Symbol"]]
        ];
        (* If actual input is a point- or space group, return it *)
        If[KeyExistsQ[$GroupSymbolRedirect, input],
            Return @ input
        ];
        (* Check if crystal entry exists *)
        If[AssociationQ @ StianRamsnes`MaXrd`Private`$TempCrystalData,
            $CrystalDataCombined = Join[$CrystalData, StianRamsnes`MaXrd`Private`$TempCrystalData]
            ,
            $CrystalDataCombined = $CrystalData
        ];
        If[MissingQ @ $CrystalDataCombined[input],
            Message[InputCheck::InvalidSymmetryObject, input];
            Abort[]
        ];
        (* Check if space group of crystal exists *)
        sg = $CrystalDataCombined[input, "SpaceGroup"];
        If[!KeyExistsQ[$GroupSymbolRedirect, sg],
            Message[InputCheck::InvalidSpaceGroupInCrystal, input, sg];
            Abort[]
            ,
            Return @ sg
        ]
    ]

InputCheck["GetReciprocalImageOrientation", latticeInput_, hklPlane_, indexLimit_, {width_, height_}, directSpaceQ_] :=
    Block[{hkl = hklPlane, abscissaIndex, ordinateIndex, planeConstant, planeIndex, bottomLeft = {-1, -1}, bottomRight = {1, -1}, topRight = {1, 1}, topLeft = {-1, 1}, M, \[Xi], imageOrientation},
        If[StringQ @ hkl,
            hkl = MillerNotationToList @ hkl
        ];
        {abscissaIndex, ordinateIndex, planeConstant} = {#1, #2, hkl[[#3]]}& @@ Flatten[Position[hkl, #]& /@ {"h", "k", "l", _Integer}];
        planeIndex = First @ Complement[Range @ 3, {abscissaIndex, ordinateIndex}];
        If[TrueQ @ directSpaceQ,
            (* a. Direct space vectors (uvw) *)
            M = GetCrystalMetric[latticeInput, "ToCartesian" -> True];
            \[Xi] = 2 * indexLimit / Max @ M;
            M = M[[{abscissaIndex, ordinateIndex}, {abscissaIndex, ordinateIndex}]];
            imageOrientation = \[Xi] * {bottomRight, topLeft, topRight};
            imageOrientation = # . M& /@ imageOrientation;
            imageOrientation = Insert[#, N @ planeConstant, planeIndex]& /@ imageOrientation;
            imageOrientation = Append[#1, #2]& @@@ Transpose[{imageOrientation, {width, height, 1}}];
            PrependTo[imageOrientation, imageOrientation[[3, {1, 2, 3}]]]
            ,
            (* b. Corners in reciprocal space *)
            imageOrientation = indexLimit * {bottomLeft, bottomRight, topLeft};
            imageOrientation = N @ Insert[#, planeConstant, planeIndex]& /@ imageOrientation
        ];
        imageOrientation = MapAt[#, imageOrientation, {All, {abscissaIndex, ordinateIndex}}]&[DecimalForm[#, {7, 4}, NumberPadding -> {" ", "0"}]&];
        imageOrientation = Map[ToString, imageOrientation, {2}];
        imageOrientation = StringRiffle[#, ",  "]& /@ imageOrientation
    ]

InputCheck["HandleSpecialLabels", input_List] :=
    Block[{specialLabels},
        specialLabels = InputCheck["FilterSpecialLabels", input];
        SynthesiseStructure /@ specialLabels;
        specialLabels
    ]

InputCheck["InterpretElement", input_] :=
    Block[
        {elementsIn = input, periodicTable, elementsRead, elementsReadNeutral, temp}
        ,
        (*---* A. Input number *---*)
        (* A.1. Check whether number is a string *)
        If[StringQ @ elementsIn,
            If[StringMatchQ[elementsIn, NumberString],
                elementsIn = ToExpression @ elementsIn
            ]
        ];
        (* A.2. Check if valid integer (in the periodic table) *)
        If[NumericQ @ elementsIn,
            If[(1 <= elementsIn <= Length @ $PeriodicTable) && IntegerQ @ elementsIn,
                Return[(Keys @ $PeriodicTable)[[elementsIn]]]
                ,
                Message[InputCheck::ElementNumber, ToString @ elementsIn];
                Abort[]
            ]
        ];
        (*---* B. Process single string *---*)
        (* B.1. Wrap string *)
        If[StringQ @ elementsIn,
            elementsIn = {elementsIn}
        ];
        (*---* C. Process list of strings *---*)
        (* C.1. Check if input is a list of strings *)
        If[!ListQ @ elementsIn,
            Goto["Failed"]
        ];
        If[!AllTrue[elementsIn, StringQ],
            Goto["Failed"]
        ];
        (* C.2. Set of valid symbols from the periodic table *)
        periodicTable = Keys @ $PeriodicTable;
        (* C.3. Find (possible) matches, and establish order *)
        elementsRead =
            StringCases[
                elementsIn
                ,
                StartOfString ~~ a:LetterCharacter ~~ {"", b:LetterCharacter} ~~ {"", n1 : DigitCharacter... ~~ pm : {"+", "-"} ~~ n2 : DigitCharacter...} :>
                    ToUpperCase[a] <> ToLowerCase[b] <>
                        If[(n1 === "") && (n2 === ""),
                            "1"
                            ,
                            ""
                        ] <> n1 <> n2 <> pm
            ];
        (* Check for non-elements *)
        If[MemberQ[elementsRead, {}],
            Message[InputCheck::ElementError, Part[elementsIn, Position[elementsRead, {}][[1, 1]]]];
            Abort[]
        ];
        (* Separate element symbol and charge (if any) *)
        elementsRead =
            Flatten[
                StringCases[
                    Flatten @ elementsRead
                    ,
                    StartOfString ~~ a : LetterCharacter.. ~~ b___ :>
                        {
                            a
                            ,
                            If[b === "",
                                "&"
                                ,
                                b
                            ]
                        }
                ]
                ,
                1
            ] (* '&' should be deleted later *);
        elementsReadNeutral = elementsRead[[All, 1]];
        (* C.4. Remove second character if not applicable *)
        elementsReadNeutral = elementsReadNeutral /. s_String /; !MemberQ[periodicTable, s] :> StringTake[s, 1];
        (* Special case: deuterium *)
        elementsReadNeutral = elementsReadNeutral /. "D" -> "H";
        (* C.5. Final validity check *)
        temp = Complement[elementsReadNeutral, periodicTable];
        If[temp =!= {},
            Message[InputCheck::ElementError, Part[elementsIn, Position[elementsReadNeutral, First @ temp][[1, 1]]]];
            Abort[]
        ];
        (* C.6. Concatenate elements and charge *)
        elementsRead[[All, 1]] = elementsReadNeutral;
        elementsRead = elementsRead /. "1" -> "";
        elementsRead = StringDelete[StringJoin /@ elementsRead, "&"];
        Goto["Done"];
        (*---* D. Post process *---*)
        (* a. Unable to determine chemical element *)
        Label["Failed"];
        Message[InputCheck::"ElementFailed", ToString @ input];
        Abort[];
        (* b. Return string (or list of strings) *)
        Label["Done"];
        If[StringQ @ input,
            elementsRead[[1]]
            ,
            elementsRead
        ]
    ]

InputCheck["InterpretSpaceGroup", input_, abortQ_:True] :=
    Block[
        {sg = input, o, regex, temp}
        ,
        (*---* A. Input number *---*)
        (* A.1. Check whether number is a string *)
        If[StringQ @ sg,
            If[StringMatchQ[StringTrim @ sg, NumberString],
                sg = ToExpression @ sg
            ]
        ];
        (* A.2. Check if valid integer (a canonical space group number) *)
        If[NumericQ @ sg,
            If[(1 <= sg <= 230) && IntegerQ @ sg,
                Return @ $SpaceGroups[[sg, "Name", "Symbol"]]
                ,
                Message[InputCheck::InvalidSpaceGroupNumber];
                If[abortQ,
                    Abort[]
                    ,
                    Return @ Null
                ]
            ]
        ];
        (*---* B. Process string *---*)
        (* B.1. Check if string *)
        If[!StringQ @ sg,
            Goto["Failed"]
        ];
        sg = StringTrim @ sg;
        (* B.2 Process any annotations *)
        If[StringContainsQ[sg, "origin", IgnoreCase -> True],
            regex = RegularExpression[" \\(origin.+(\\d)\\)"];
            o = StringCases[sg, regex -> "$1"];
            If[o === {},
                (* Manual input required *)
                o = ChoiceDialog["Information on cell origin detected." <> "\n" <> "Please confirm the cell origin.", {1, 2}, WindowTitle -> "Cell origin"];
                sg = StringDelete[sg, Whitespace ~~ "(" ~~ __ ~~ ")"]
                ,
                (* Rebuild space group symbol *)
                o = First @ o;
                sg = StringReplace[sg, regex -> ":$1"]
            ]
        ];
        (* B.3 Tidy string *)
        sg =
            Fold[
                StringReplace[#1, #2]&
                ,
                sg
                ,
                {
                    (* B.4.1. Remove any _enclosing_ quotation marks *)(* Note: Some Hall symbols contain double quotation marks *)StartOfString ~~ {"'", "\""} ~~ main__ ~~ {"'", "\""} ~~ EndOfString :> main
                    ,
                    (* B.4.2 Uppercase centring 1 *)
                    StartOfString ~~ first : {"-" ~~ _, _} ~~ rest__ ~~ EndOfString :> ToUpperCase @ first ~~ ToLowerCase @ rest
                    ,
                    (* B.4.3. Fix boxes *)
                    {"overscriptbox" -> "OverscriptBox", "subscriptbox" -> "SubscriptBox"}
                    ,
                    (* B.4.4 Uppercase centring 2 *)
                    "Box[\(" ~~ c_ :> "Box[\(" <> ToUpperCase[c]
                    ,
                    (* B.4.5 Screw axes *)
                    a:DigitCharacter ~~ "(" ~~ b:DigitCharacter ~~ ")" :> a <> b
                    ,
                    (* B.4.6. Miscellaneous replacements *)
                    ";" -> " "
                }
            ];
        sg = StringTrim @ sg;
        (*---* C. Check symbol *---*)
        (* C.1. Check centring symbol *)
        If[!MemberQ[{"P", "I", "F", "R", "A", "B", "C", "H", "\!", "-"}, StringTake[sg, 1]],
            Goto["Failed"]
        ];
        (* C.2 Check if found by '$GroupSymbolRedirect' *)
        temp = $GroupSymbolRedirect[sg];
        If[!MissingQ @ temp,
            If[KeyExistsQ[temp, "PointGroupNumber"],
                Goto["Failed"]
            ];
            sg = temp[["Name", "Symbol"]];
            Goto["SpaceGroupFound"]
        ];
        (* Exception: Old symbols? *)
        If[sg === "Fm3m",
            sg = "Fm-3m";
            Goto["SpaceGroupFound"]
        ];
        If[sg === "Im3m",
            sg = "Im-3m";
            Goto["SpaceGroupFound"]
        ];
        (* C.3 Delete whitespace and check again *)
        temp = StringDelete[sg, Whitespace];
        temp = $GroupSymbolRedirect[temp];
        If[!MissingQ @ temp,
            sg = temp[["Name", "Symbol"]];
            Goto["SpaceGroupFound"]
        ];
        (*---* D. Post process *---*)
        (* a. Unable to determine space group *)
        Label["Failed"];
        Message[InputCheck::InvalidSpaceGroup, input];
        If[abortQ,
            Abort[]
            ,
            Return @ Null
        ];
        (* b. Return non-ambiguous output *)
        Label["SpaceGroupFound"];
        ToStandardSetting[sg]
    ]

InputCheck["PadDomain", {{sizeA_, sizeB_, sizeC_}, domain_List}, padding_Integer:1] :=
    Block[{newSize, contentPositions, contentMap, voidPositions, voidMap, joined},
        If[padding <= 0,
            Return[{{sizeA, sizeB, sizeC}, domain}]
        ];
        newSize = (padding + 1) {sizeA, sizeB, sizeC} - padding;
        contentPositions = Flatten[Table[{i, j, k}, {i, 0., (padding + 1) * sizeA - 1, padding + 1}, {j, 0., (padding + 1) * sizeB - 1, padding + 1}, {k, 0., (padding + 1) * sizeC - 1, padding + 1}], 2];
        contentMap = AssociationThread[contentPositions -> domain];
        voidPositions = Complement[InputCheck["GenerateTargetPositions", newSize], contentPositions];
        voidMap = AssociationThread[voidPositions -> 0];
        joined = Join[contentMap, voidMap];
        {newSize, Values @ KeySortBy[joined, {#[[1]]&, #[[2]]&, #[[3]]&}]}
    ];

InputCheck["PointGroupQ", input_String] :=
    (
        (* Check if valid point group string *)If[!MemberQ[$PointGroups, input, Infinity],
            Message[InputCheck::InvalidPointGroup, input];
            Abort[]
        ]
    )

InputCheck["PointSpaceGroupQ", input_String] :=
    (* Check if valid point- or space group string *)If[!KeyExistsQ[$GroupSymbolRedirect, input],
        Message[InputCheck::InvalidPointOrSpaceGroup, input];
        Abort[]
    ]

InputCheck["Polarisation", type_String, scatteringAngle_:0] :=
    Which[
        type === "sigma" || type === "\[Sigma]",
            1
        ,
        type === "pi" || type === "\[Pi]",
            Abs @ Cos[scatteringAngle]
        ,
        True,
            Message[InputCheck::InvalidPolarisationSetting];
            Abort[]
    ]

InputCheck["ProcessWavelength", crystal_String, wavelength_, abortQ_:True] :=
    Block[{\[Lambda]},
        \[Lambda] =
            If[N @ wavelength === -1.,
                InputCheck["GetCrystalWavelength", crystal, abortQ]
                ,
                wavelength
            ];
        InputCheck["GetEnergyWavelength", \[Lambda], False]
    ]

InputCheck["RecognizeFractions", coordinates_List, threshold_:0.001] :=
    Block[{recognizedFractions = {1/12, 1/8, 1/6, 1/4, 1/3, 3/8, 5/12, 1/2, 7/12, 5/8, 2/3, 3/4, 5/6, 7/8, 11/12}, rationalized, matchedQ, Replacer},
        rationalized = Map[Rationalize[#, threshold]&, coordinates, {-1}];
        matchedQ = Map[MemberQ[Prepend[recognizedFractions, 0], #]&, rationalized, {-1}];
        Replacer[x_, p_] :=
            If[Extract[matchedQ, p],
                Extract[rationalized, p]
                ,
                x
            ];
        MapIndexed[Replacer, coordinates, {-1}]
    ]

InputCheck["RotationTransformation", {{sizeA_Integer, sizeB_Integer, sizeC_Integer}, domains_List}, {anchorShiftInput_List, anchorReference_String, rotations_, rotationAxes_ : IdentityMatrix @ 3}, cellDimensionsInput_List : {1., 1., 1.}, force3DimensionalInterpretation_:False] :=
    Module[
        {twoDimensionalQ, coordinates, \[Zeta], rotationTransform, uniqueDomains, anchorShift = anchorShiftInput, anchors, cellDimensions = cellDimensionsInput, coordinatesGrouped, domainAnchors, zeroRotation, zeroAnchor}
        ,
        (* Preparations and checks *)
        If[Length @ domains != sizeA * sizeB * sizeC,
            Message[InputCheck::DomainSizeError];
            Abort[]
        ];
        uniqueDomains = DeleteDuplicates @ domains;
        twoDimensionalQ = (sizeC === 1);
        If[force3DimensionalInterpretation,
            twoDimensionalQ = False
        ];
        If[twoDimensionalQ,
            anchorShift = anchorShift[[{1, 2}]];
            cellDimensions = cellDimensions[[{1, 2}]]
        ];
        If[twoDimensionalQ,
            If[!MatchQ[anchorShift, {_?NumericQ, _?NumericQ}],
                Message[InputCheck::InvalidRotationPoint];
                Abort[]
            ]
            ,
            If[!MatchQ[anchorShift, {_?NumericQ, _?NumericQ, _?NumericQ}],
                Message[InputCheck::InvalidRotationPoint];
                Abort[]
            ]
        ];
        If[AssociationQ @ rotations,
            If[twoDimensionalQ,
                If[AnyTrue[Values @ rotations, !NumericQ[#]&],
                    Message[InputCheck::InvalidRotationMap, "2", "scalars"];
                    Abort[]
                ]
                ,
                If[AnyTrue[Values @ rotations, !MatchQ[#, ConstantArray[_?NumericQ, 3]]&],
                    Message[InputCheck::InvalidRotationMap, "3", "lists of three numbers"];
                    Abort[]
                ]
            ]
        ];
        If[!MemberQ[{"Host", "Domain", "DomainCentroid", "Unit"}, anchorReference],
            Message[InputCheck::InvalidRotationReference];
            Abort[]
        ];
        (* Rotation anchor and reference for domains *)
        If[anchorReference === "Domain" || anchorReference === "DomainCentroid",
            coordinates = Flatten[Table[{i, j, k}, {i, 0., sizeA - 1}, {j, 0., sizeB - 1}, {k, 0., sizeC - 1}], 2];
            If[twoDimensionalQ,
                coordinates = coordinates[[All, {1, 2}]]
            ];
            coordinatesGrouped = Pick[coordinates, domains, #]& /@ uniqueDomains;
            domainAnchors =
                <|
                        "Domain" -> Flatten[TakeSmallestBy[#, Norm, 1]& /@ coordinatesGrouped, 1]
                        ,
                        "DomainCentroid" ->
                            (
                                # +
                                        If[twoDimensionalQ,
                                            {0.5, 0.5}
                                            ,
                                            {0.5, 0.5, 0.5}
                                        ]& /@ Map[Mean, Transpose /@ coordinatesGrouped, {2}]
                            )
                    |> @ anchorReference;
            domainAnchors = # + anchorShift& /@ domainAnchors;
            anchors = N @ AssociationThread[uniqueDomains -> domainAnchors];
            anchors = # * cellDimensions& /@ anchors;
        ];
        (* Rotation transformation function *)
        {zeroRotation, zeroAnchor} =
            If[twoDimensionalQ,
                {0., {0., 0.}}
                ,
                {{0., 0., 0.}, {0., 0., 0.}}
            ];
        \[Zeta][d_] := N @ Lookup[rotations, d, zeroRotation];
        Which[
            anchorReference === "Host" && twoDimensionalQ,
                rotationTransform[d_] := Chop @ RotationTransform[\[Zeta] @ d, anchorShift]
            ,
            anchorReference === "Host",
                rotationTransform[d_] := Chop[Composition @@ MapThread[RotationTransform[#1, #2, anchorShift]&, {\[Zeta] @ d, rotationAxes}]];
                rotationTransform[d_, p_] :=
                    Chop[
                        Composition @@
                            MapThread[
                                RotationTransform[#1, #2, anchorShift]&
                                ,
                                {
                                    If[!AssociationQ @ rotations,
                                        d
                                        ,
                                        \[Zeta] @ d
                                    ]
                                    ,
                                    rotationAxes
                                }
                            ]
                    ]
            ,
            anchorReference === "Unit" && twoDimensionalQ,
                rotationTransform[d_, p_] := Chop @ RotationTransform[\[Zeta] @ d, p + anchorShift]
            ,
            anchorReference === "Unit",
                rotationTransform[d_, p_] :=
                    Chop[
                        Composition @@
                            MapThread[
                                RotationTransform[#1, #2, p + anchorShift]&
                                ,
                                {
                                    If[!AssociationQ @ rotations,
                                        d
                                        ,
                                        \[Zeta] @ d
                                    ]
                                    ,
                                    rotationAxes
                                }
                            ]
                    ]
            ,
            twoDimensionalQ,
                rotationTransform[d_] := Chop @ RotationTransform[\[Zeta] @ d, Lookup[anchors, d, zeroAnchor] + anchorShift]
            ,
            True,
                rotationTransform[d_, p_] := Chop[Composition @@ MapThread[RotationTransform[#1, #2, Lookup[anchors, d, zeroAnchor] + anchorShift]&, {\[Zeta] @ d, rotationAxes}]]
        ];
        rotationTransform
    ]

InputCheck["ShallowDisplayCrystal", crystal_String] :=
    KeyValueMap[
        If[#1 === "AtomData",
            "AtomData" -> Shallow[#2, 1]
            ,
            #1 -> #2
        ]&
        ,
        $CrystalData @ crystal
    ]

InputCheck["Update$CrystalDataAutoCompletion"] :=
    (
        FE`Evaluate[FEPrivate`AddSpecialArgCompletion[#]]&["$CrystalData" -> {Keys @ $CrystalData, {"AtomData", "ChemicalFormula", "FormulaUnits", "LatticeParameters", "Notes", "SpaceGroup", "Wavelength"}}];
        $CrystalData = KeySort @ $CrystalData;
        Keys @ $CrystalData
    )

InputCheck["Update$CrystalDataFile", dataFile_String, newStructureLabel_String, hostCopy_] :=
    (
        If[!FileExistsQ @ dataFile,
            $CrystalData = <||>
        ];
        AssociateTo[$CrystalData, newStructureLabel -> hostCopy];
        InputCheck["Update$CrystalDataAutoCompletion"];
        Export[dataFile, $CrystalData];
    );

End[];
