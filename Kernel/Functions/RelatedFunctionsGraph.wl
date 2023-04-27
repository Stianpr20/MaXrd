Options @ RelatedFunctionsGraph = {"Limit" -> 10, "DirectOnly" -> False, "ShowDependent" -> False};

SetAttributes[RelatedFunctionsGraph, HoldFirst];

SyntaxInformation @ RelatedFunctionsGraph = {"ArgumentsPattern" -> {_, OptionsPattern[]}};

Begin["`Private`"];

RelatedFunctionsGraph[function_, OptionsPattern[]] :=
    Block[
        {f, allFunctions = Names["StianRamsnes`MaXrd`*"], definitionFile, import, findDependentFunctions, data, d, main, g, done, new, x, X, c, part}
        ,
        (* Loading data *)
        f = ToString @ HoldForm @ function;
        definitionFile = FileNameJoin[{$MaXrdPath, "Kernel", "Definitions.m"}];
        import = StringJoin @ Check[Import[definitionFile, "Text"], Abort[]];
        (* Optional: Show all functions dependent on 'f' *)
        If[OptionValue["ShowDependent"],
            data = StringCases[import, Shortest[c : (allFunctions) ~~ {"[", ":="} ~~ d__ ~~ "End[];"] :> {c, d}];
            x =
                Reap @
                    Do[
                        c = data[[i, 1]];
                        d = Sort @ DeleteDuplicates @ StringCases[data[[i, 2]], allFunctions];
                        d = DeleteCases[d, c];
                        Sow[c -> d]
                        ,
                        {i, Length @ data}
                    ];
            x = x[[2, 1]];
            part = First /@ Position[x, f];
            g = First /@ x[[part]];
            g = DeleteCases[g, f];
            (* If none, return empty list *)
            If[g == {},
                Return[{}]
            ];
            g = f -> #& /@ g;
            Goto["GraphDataGenerated"]
        ];
        (* Function for finding related functions *)
        findDependentFunctions[func_] :=
            (
                data = StringCases[import, Shortest["Begin[\"`Private`\"];" ~~ Whitespace ~~ "\n" ~~ func ~~ {"[", ":="} ~~ d__ ~~ "End[];"] :> d];
                (* Check if anything is found *)
                If[data == {},
                    Return[{}]
                ];
                d = DeleteDuplicates @ Flatten @ Sort @ StringCases[First @ data, {"\"" ~~ allFunctions ~~ "\"", allFunctions ~~ "::", allFunctions}];
                d = DeleteCases[d, func];
                d = DeleteCases[d, x_ /; StringContainsQ[x, {"\"", "::"}]]
            );
        (* Seed *)
        main = findDependentFunctions @ f;
        If[main == {},
            Return[{}]
        ];
        (* Loop *)
        g = {};
        done = {};
        new = {f};
        While[
            new != {}
            ,
            x = First @ new;
            X = findDependentFunctions @ x;
            g = DeleteDuplicates @ Join[g, # -> x& /@ X];
            AppendTo[done, x];
            new = Join[new, X];
            new = Complement[new, done]
        ];
        Label["GraphDataGenerated"];
        g = DeleteDuplicatesBy[g, Sort];
        (* Optional: Only directly connected *)
        If[OptionValue["DirectOnly"],
            g = DeleteCases[g, (a_ -> b_) /; (a != f && b != f)]
        ];
        (* Optional: Limiting graph *)
        g = Take[g, UpTo @ OptionValue["Limit"]];
        (* Plot *)
        GraphPlot[g, DirectedEdges -> True, VertexLabels -> None, ImageSize -> Large, MultiedgeStyle -> False, DirectedEdges -> True, EdgeShapeFunction -> ({Arrowheads[{{Automatic, 0.5}}], Arrow[#1]}&), SelfLoopStyle -> None, VertexShapeFunction -> ({White, EdgeForm[], Rectangle[# - {0.02 * StringLength @ #2, 0.05}, # + {0.02 * StringLength @ #2, 0.05}], Black, Text[Style[Hyperlink[#2, "paclet:MaXrd/ref/" <> #2], 11, "Program"], #1]}&), Method -> "RadialDrawing"]
    ];

End[];
