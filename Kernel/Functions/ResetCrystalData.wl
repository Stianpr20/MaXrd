ResetCrystalData::DemoDataNotFound = "Demo data not found.";

SyntaxInformation @ ResetCrystalData = {"ArgumentsPattern" -> {}};

Begin["`Private`"];

ResetCrystalData[] :=
    Block[{demoFile, newDataFile},
        demoFile = FileNameJoin[{$MaXrdPath, "Kernel", "Data", "CrystalDataDemo.m"}];
        If[!FileExistsQ @ demoFile,
            Message[ResetCrystalData::DemoDataNotFound];
            Return[]
        ];
        newDataFile = FileNameJoin[{$MaXrdPath, "Kernel", "Data", "UserData", "CrystalData.m"}];
        CopyFile[demoFile, newDataFile, OverwriteTarget -> True];
        $CrystalData = Import @ newDataFile;
        Keys @ $CrystalData
    ]

End[];
