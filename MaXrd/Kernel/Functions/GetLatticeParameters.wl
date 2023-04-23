SyntaxInformation @ GetLatticeParameters = {"ArgumentsPattern" -> {_,
      OptionsPattern @ GetCrystalMetric}};

Begin["`Private`"];

GetLatticeParameters[input_, options : OptionsPattern @ GetCrystalMetric
     ] :=
     GetCrystalMetric[input, "Category" -> "LatticeParameters", "Space"
           -> OptionValue["Space"], options]

End[];
