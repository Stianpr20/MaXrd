MergeDomains::InvalidForm = "Input item `1` has an invalid domain form.";

MergeDomains::InternalSizeMismatch = "Input item `1` has an internal size mismatch.";

MergeDomains::DifferentDimensions = "Domain sizes differ.";

SyntaxInformation @ MergeDomains = {"ArgumentsPattern" -> {_, _.}};

Begin["`Private`"];

MergeDomains[domains_List] :=
    Block[
        {i, size, newSize, newSequence}
        ,
        (* Checks and preparations *)
        i = 1;
        Do[
            If[!MatchQ[domains[[i]], {{_Integer, _Integer, _Integer},
                 {__Integer}}],
                Message[MergeDomains::InvalidForm, i];
                Abort[]
            ];
            If[Times @@ domains[[i, 1]] =!= Length @ domains[[i, 2]],
                
                Message[MergeDomains::InternalSizeMismatch, i];
                Abort[]
            ]
            ,
            {i, Length @ domains}
        ];
        If[!SameQ @@ domains[[All, 1]],
            Message[MergeDomains::DifferentDimensions];
            Abort[]
        ];
        size = domains[[1, 1]];
        (* Merging: Stack on top *)
        newSize = size;
        newSize[[3]] *= Length @ domains;
        newSequence = Fold[Partition, #, size[[{3, 2}]]]& /@ domains[[
            All, 2]];
        newSequence = Flatten @ Transpose[newSequence, {3, 1, 2, 4}];
            
        {newSize, newSequence}
    ]

MergeDomains[domain_List, repeat_Integer] :=
    MergeDomains @ ConstantArray[domain, repeat];

End[];
