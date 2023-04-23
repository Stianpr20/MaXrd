ReciprocalSpaceSimulation::invalid = "Invalid input form.";

ReciprocalSpaceSimulation::dep = "The layer vectors are not linearly independent.";

Options @ ReciprocalSpaceSimulation =
    SortBy[
        Normal @
            Union[
                Association @ Options @ Graphics
                ,
                <|
                    "IgnoreStructureFactors" -> False
                    ,
                    "IntensityScaling" -> 0.0025
                    ,
                    "ReturnData" -> False
                    ,
                    "StructureFactorThreshold" -> 1
                    ,
                    (* Graphics *)
                    ColorOutput -> "SolarColors"
                |>
            ]
        ,
        ToString @ #[[1]]&
    ];

SyntaxInformation @ ReciprocalSpaceSimulation = {"ArgumentsPattern" ->
     {_, _., _, {_, _, _}, _, OptionsPattern[{ReciprocalSpaceSimulation, 
    Graphics}]}};

Begin["`Private`"];

ReciprocalSpaceSimulation[crystal_, lambda : _ ? (NumericQ[#] || QuantityQ[
    #]&) : -1, {latticeVector1_List, latticeVector2_List}, originInput_List,
     res_ ? (NumericQ[#] && Positive[#]&), options : OptionsPattern[{ReciprocalSpaceSimulation,
     Graphics}]] :=
    Block[
        {\[Lambda], check, crystalMetric, crystalMetricInverse, B, CrystalDot,
             CrystalCross, Hx, Hy, Hz, HCx, HCy, HCz, U, UB, origin, ref, referenceZ,
             flip, condition, planeIndex, structureFactors, hkl2sf, \[Delta] = OptionValue[
            "StructureFactorThreshold"], hkl, xy, pair, data, \[Chi]}
        ,
        (** Input check **)
        \[Lambda] = InputCheck["ProcessWavelength", crystal, lambda];
            
        check = Flatten[{latticeVector1, latticeVector2, originInput}
            ];
        If[Length @ check != 9 || !AllTrue[check, NumericQ],
            Message[ReciprocalSpaceSimulation::invalid];
            Abort[]
        ];
        (* Check if vectors are linearly independent *)
        If[Det[{{latticeVector1 . latticeVector1, latticeVector1 . latticeVector2
            }, {latticeVector2 . latticeVector1, latticeVector2 . latticeVector2}
            }] == 0,
            Message[ReciprocalSpaceSimulation::dep];
            Abort[]
        ];
        (** Auxiliary **)
        (** Metric information **)
        crystalMetric = GetCrystalMetric[crystal];
        crystalMetricInverse = Inverse @ crystalMetric;
        B = CholeskyDecomposition @ Inverse @ crystalMetric;
        (** Dot- and cross products in reciprocal space **)
        CrystalDot[u_, v_] := Return[Sum[Sum[crystalMetricInverse[[i,
             j]] * u[[i]] * v[[j]], {j, 3}], {i, 3}]];
        CrystalCross[u_, v_] := Return[Sqrt @ Det @ crystalMetricInverse
             * Table[Sum[Sum[Sum[Signature[{i, j, k}] * crystalMetric[[i, t]] * u
            [[j]] * v[[k]], {k, 3}], {j, 3}], {i, 3}], {t, 3}]];
        (** Plane of projection **)
        (* Projection plane in reciprocal space *)
        Hx = latticeVector1;
        Hy = latticeVector2 - Hx * CrystalDot[Hx, latticeVector2] / CrystalDot[
            Hx, Hx];
        Hz = CrystalCross[Hx, Hy];
        (* Components in Cartesian frame *)
        {HCx, HCy, HCz} = Normalize[B . #]& /@ {Hx, Hy, Hz};
        (* U and UB matrices for generation of coordinates *)
        U = IdentityMatrix[3] . Inverse @ Transpose[{HCx, HCy, HCz}];
            
        UB = Chop[U . B];
        (* Reference position in projection *)
        origin = originInput;
        ref = UB . origin;
        referenceZ = ref[[3]];
        If[Chop[originInput] == {0, 0, 0},
            origin = latticeVector1 + latticeVector2;
            flip = True
            ,
            flip = False
        ];
        condition = {{h_, k_, l_} /; h == #1, {h_, k_, l_} /; k == #2,
             {h_, k_, l_} /; l == #3}& @@ origin;
        condition =
            DeleteCases[
                condition
                ,
                c_ /;
                    If[flip,
                        !Equal[c[[2, 2]], 0]
                        ,
                        Equal[c[[2, 2]], 0]
                    ]
            ];
        (* Constant plane index *)
        planeIndex = condition[[1, 2]];
        planeIndex = ToString @ planeIndex[[1]] -> planeIndex[[2]];
        If[Length @ condition > 1,
            condition = condition[[All, 2]];
            condition = {h_, k_, l_} /; #&[And @@ condition]
            ,
            condition = First @ condition
        ];
        (** Building **)
        Label["Building"];
        (* Generating reflection *)
        hkl = ReflectionList[crystal, \[Lambda], condition, "HoldIndex"
             -> planeIndex, "SplitEquivalent" -> True, "ShowProgress" -> False];
        (* Filter reflection outside resolution *)
        hkl = Select[hkl, Sqrt[CrystalDot[#, #]] < 1 / (1.01 * res)&]
            ;
        (* Structure factors *)
        structureFactors =
            If[TrueQ @ OptionValue["IgnoreStructureFactors"],
                ConstantArray[100.0, Length @ hkl]
                ,
                Quiet[StructureFactor[crystal, hkl, \[Lambda]][[All, 
                    1]], {StructureFactor::ElementMismatch}]
            ];
        hkl2sf = AssociationThread[hkl -> structureFactors];
        hkl2sf = Select[hkl2sf, # > \[Delta]&];(* Optional *)
        hkl = Keys @ hkl2sf;
        (* Generating coordinates *)
        xy = (UB . # - {0, 0, referenceZ}& /@ hkl)[[All, {1, 2}]];
        pair = Transpose[{N @ Chop @ xy, hkl}];
        data = <|"Coordinates" -> N @ Chop @ xy, "MillerIndices" -> hkl,
             "StructureFactor" -> Lookup[hkl2sf, hkl]|>;
        If[TrueQ @ OptionValue["ReturnData"],
            Return @ data
        ]; (* Optional *)
        RenderReciprocalSpaceSimulation[data, options]
    ]

RenderReciprocalSpaceSimulation[dataInput_, options : OptionsPattern[
    {ReciprocalSpaceSimulation, Graphics}]] :=
    Block[{data = dataInput, MakeRadius, r, \[Zeta] = OptionValue["IntensityScaling"
        ], MakeDisk, \[Chi]},
        Switch[Head @ dataInput,
            Association,
                data = dataInput
            ,
            List,
                data = Map[Flatten[#, 1]&, Merge[dataInput, Identity]
                    ]
            ,
            _,
                Message[ReciprocalSpaceSimulation::invalid];
                Abort[]
        ];
        MakeRadius[sf_] :=
            (
                r = \[Zeta] * Log2[sf^2];
                If[r < 0,
                    r = 0.005
                ];
                r
            );
        \[Chi] = Max @ Lookup[data, "StructureFactor"];
        MakeDisk[xy_, hkl_, sf_] := Tooltip[{ColorData[OptionValue @ 
            ColorOutput][sf / \[Chi]], Disk[xy, MakeRadius @ sf]}, MillerNotationToString
             @ hkl];
        Graphics[{MakeDisk @@@ Transpose @ Values @ data}, FilterRules[
            {options}, Options @ Graphics]]
    ]

End[];
