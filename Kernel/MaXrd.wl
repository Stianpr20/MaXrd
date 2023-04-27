BeginPackage["StianRamsnes`MaXrd`"];

$MaXrdVersion = PacletObject["StianRamsnes/MaXrd"]["Version"];

$MaXrdPath = PacletObject["StianRamsnes/MaXrd"]["Location"];

(* Load usage messages (also to get the function names/symbols of the package) *)

Import[FileNameJoin[{$MaXrdPath, "Kernel", "Data", "UsageMessages.m"}
	], "Package"];

(* Symmetry data *)

Begin["`Private`"];

pointGroupsSourceDir = FileNameJoin[{$MaXrdPath, "Kernel", "Data", "PointGroups"
	}];

pointGroupFiles = FileNames["PointGroup*.wl", pointGroupsSourceDir];

pointGroupData = Import /@ pointGroupFiles;

$PointGroups = Association @ pointGroupData;

spaceGroupsSourceDir = FileNameJoin[{$MaXrdPath, "Kernel", "Data", "SpaceGroups"
	}];

spaceGroupFiles = FileNames["SpaceGroup*.wl", spaceGroupsSourceDir];

spaceGroupData = Import /@ spaceGroupFiles;

$SpaceGroups = Association @ spaceGroupData;

End[];

$LaueClasses = $PointGroups[[{"-1", "2/m", "mmm", "4/m", "4/mmm", "-3",
	 "-3m", "6/m", "6/mmm", "m-3", "m-3m"}]];

$TransformationMatrices = Import @ FileNameJoin[{$MaXrdPath, "Kernel",
	 "Data", "TransformationMatrices.m"}];

(* Miscellaneous data *)

$GroupSymbolRedirect = Import @ FileNameJoin[{$MaXrdPath, "Kernel", "Data",
	 "GroupSymbolRedirect.m"}];

$PeriodicTable = Import @ FileNameJoin[{$MaXrdPath, "Kernel", "Data",
	 "PeriodicTable.m"}];

$CrystalData = Import @ FileNameJoin[{$MaXrdPath, "Kernel", "Data", "UserData",
	 "CrystalData.m"}];

Begin["`Private`"];

(* Loading function definitions from separate files in 'Kernel/Functions' directory: *)

functionDir = FileNameJoin[{$MaXrdPath, "Kernel", "Functions"}];

functionFiles = FileNames["*.wl", functionDir];

Scan[Import, functionFiles];

(* Run auto completion setup: *)

Import @ FileNameJoin[{$MaXrdPath, "Kernel", "AutoCompletion.wl"}];

End[];

EndPackage[];
