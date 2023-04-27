ResizeStructure::InvalidSize = "The scaling description must be a list of three numbers.";

ResizeStructure::AutomaticScalingFailed = "Could not determine structure size which to rescale to.";

SyntaxInformation @ ResizeStructure = {"ArgumentsPattern" -> {_, _.}};

Begin["`Private`"];

ResizeStructure[crystalLabel_String, scalingInput_:Automatic] :=
    Block[
        {crystalData, scaling = scalingInput, latticeParameters, coordinates}
        ,
        (* Input checks *)
        crystalData = InputCheck["CrystalQ", crystalLabel, False];
        If[scaling === Automatic,
            scaling = crystalData["Notes", "StructureSize"];
            If[MissingQ @ scaling,
                Message[ResizeStructure::AutomaticScalingFailed];
                Abort[]
            ]
        ];
        If[!MatchQ[scaling, {#, #, #}&[_?NumericQ]],
            Message[ResizeStructure::InvalidSize];
            Abort[]
        ];
        (* Perform rescaling of unit cell dimensions *)
        latticeParameters = Lookup[crystalData["LatticeParameters"], {"a", "b", "c"}];
        crystalData[["LatticeParameters", {"a", "b", "c"}]] = latticeParameters * scaling;
        (* Rescale fractional coordinates *)
        coordinates = crystalData[["AtomData", All, "FractionalCoordinates"]];
        coordinates = # * (1 / scaling)& /@ coordinates;
        crystalData[["AtomData", All, "FractionalCoordinates"]] = coordinates;
        (* Update $CrystalData *)
        crystalData["Notes", "StructureSize"] *= (1 / scaling);
        AppendTo[$CrystalData, crystalLabel -> crystalData];
        crystalLabel
    ]

End[];
