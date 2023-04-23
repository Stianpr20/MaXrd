GetScatteringCrossSections::invalidSource = "Invalid source.";

GetScatteringCrossSections::invalidElement = "Invalid element.";

GetScatteringCrossSections::invalidProcess = "The scattering process type \[LeftGuillemet]`1`\[RightGuillemet] is not recognised.";

GetScatteringCrossSections::invalidWavelengthRange = "The wavelength, `1` \[CapitalARing], must be within (0.001 \[LessEqual] \[Lambda] \[LessEqual] 3.000) \[CapitalARing] when using cross sections.";

Options @ GetScatteringCrossSections = {"PhysicalProcess" -> "", "Source"
     -> "xraylib", "Units" -> True};

SyntaxInformation @ GetScatteringCrossSections = {"ArgumentsPattern" 
    -> {_, _, OptionsPattern[]}};

Begin["`Private`"];

GetScatteringCrossSections[input_, wavelength : _ ? (NumericQ[#] || QuantityQ[
    #]&) : -1, OptionsPattern[]] :=
    Block[
        {src, unitsQ, elements, \[Lambda] = wavelength, pp = OptionValue[
            "PhysicalProcess"], column, streamPosition, \[Sigma], file, read, \[Sigma]i
            }
        ,
        (*---* Checks *---*)
        (* Chemical element(s) *)
        elements = Flatten @ GetElements[input];
        (* Data source *)
        src = FileNameJoin[{$MaXrdPath, "Kernel", "Data", "CrossSections",
             OptionValue["Source"]}];
        If[!DirectoryQ @ src,
            Message[GetScatteringCrossSections::invalidSource];
            Abort[]
        ];
        unitsQ = OptionValue["Units"];
        (* Wavelength and its range *)
        If[!(0.001 <= \[Lambda] <= 3.000),
            Message[GetScatteringCrossSections::invalidWavelengthRange,
                 ToString @ \[Lambda]];
            Abort[]
        ];
        \[Lambda] = InputCheck["ProcessWavelength", "", wavelength];
        (* Column to read from (cross section type) *)
        column =
            Which[
                pp === "",
                    5
                ,
                MemberQ[{"Photoelectric", "Photoionisation"}, pp],
                    2
                ,
                MemberQ[{"Coherent", "Rayleigh", "Thompson", "Classical",
                     "Elastic"}, pp],
                    3
                ,
                MemberQ[{"Incoherent", "Compton", "Inelastic"}, pp],
                    4
                ,
                pp === "Total",
                    5
                ,
                True,
                    Message[GetScatteringCrossSections::invalidProcess,
                         pp];
                    Abort[]
            ];
        (*---* Read from file *---*)
        streamPosition =
            If[$OperatingSystem === "Windows",
                    65
                    ,
                    66
                ] * (Round[1000 * \[Lambda]] - 1);
(* Extract cross sections; \[Sigma] = \[Sigma](element, wavelength) 
    *)
        \[Sigma] = {};
        Do[
            file = OpenRead @ FileNameJoin[{src, X <> ".dat"}];
            SetStreamPosition[file, streamPosition];
            read = Read[file, Record];
            \[Sigma]i = ToExpression @ StringReplace[StringSplit[read
                ][[column]], m__ ~~ "E" ~~ s : {"+", "-"} ~~ e : DigitCharacter.. :> 
                m <> "*10^(" <> s <> e <> ")"];
            If[unitsQ,
                \[Sigma]i = Quantity[\[Sigma]i, "Barns"]
            ];
            Close[file];
            AppendTo[\[Sigma], X -> \[Sigma]i]
            ,
            {X, elements}
        ];
        (*---* Output *---*)
        Association @ \[Sigma]
    ]

End[];
