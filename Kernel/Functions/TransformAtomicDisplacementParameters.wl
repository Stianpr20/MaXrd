TransformAtomicDisplacementParameters::InvalidTransformation = "The transformation input \[LeftGuillemet]`1`\[RightGuillemet] is invalid.";

SyntaxInformation @ TransformAtomicDisplacementParameters = {"ArgumentsPattern" -> {_, _.}};

Begin["`Private`"];

TransformAtomicDisplacementParameters[crystal_, transformation_:"EquivalentIsotropic"] :=
    Block[{ADPs, cartesianConverter, cartesianADPs},
        InputCheck["CrystalQ", crystal];
        If[!MemberQ[{"CartesianConverter", "EquivalentIsotropic"}, transformation],
            Message[TransformAtomicDisplacementParameters::InvalidTransformation, transformation];
            Abort[]
        ];
        cartesianConverter = $CartesianConverterMaker @ crystal;
        If[transformation === "CartesianConverter",
            (* a. Transform ADPs to Cartesian basis -- returns function *)
            Return @ cartesianConverter
        ];
        If[transformation === "EquivalentIsotropic",
            (* b. Calculate equivalent isotropic ADPs *)
            ADPs = Lookup[$CrystalData[crystal, "AtomData"], "DisplacementParameters", 0.];
            cartesianADPs = cartesianConverter /@ ADPs;
            Mean /@ Diagonal /@ cartesianADPs
        ]
    ]

$CartesianConverterMaker[crystal_] :=
    Module[
        {latticeReciprocal, toCartesian, n, u, dimensionlessU, cartesianConverterFactory}
        ,
        (* Reference: https://doi.org/10.1107/S0021889802008580 *)
        latticeReciprocal = GetCrystalMetric[crystal, "Category" -> "LatticeParameters", "Space" -> "Reciprocal", "Units" -> False];
        toCartesian = GetCrystalMetric[crystal, "ToCartesian" -> True];
        n = DiagonalMatrix @ latticeReciprocal[[1 ;; 3]];
        cartesianConverterFactory[adp_] :=
            (
                If[NumericQ @ adp,
                    Return @ DiagonalMatrix[{#, #, #}]& @ adp
                (* Alternatively: see '_cell.convert_Uiso_to_Uij' *)(* ADPs * {{1,#3,#2},{#3,1,#1},{#2,#1,1}} &@@ Cos @ latticeReciprocal\[LeftDoubleBracket]4;;6\[RightDoubleBracket] *)];
                u = {{#1, #4, #5}, {#4, #2, #6}, {#5, #6, #3}}& @@ adp;
                dimensionlessU = n . u . n;
                Return[toCartesian . dimensionlessU . Transpose @ toCartesian]
            );
        cartesianConverterFactory
    ]

End[];
