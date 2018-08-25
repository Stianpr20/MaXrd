(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* ::Input::Initialization:: *)
Begin["`Private`"];


(*---* Auto completion function *---*)
(* FileNameJoin[{$InstallationDirectory,"SystemFiles","FrontEnd","SystemResources","FunctionalFrequency","specialArgFunctions.tr"}] *)

(*
  https://mathematica.stackexchange.com/questions/56984/argument-completions-for-user-defined-functions#129910
*)
addCompletion:=FE`Evaluate[FEPrivate`AddSpecialArgCompletion[#]]&;


(*---* Data bases *---*)
(* $PointGroups *)
keysPG=Keys@$PointGroups;

(* $LaueClasses *)
keysLC=Keys@$LaueClasses;

(* $SpaceGroups *)
keysSG=Keys@$SpaceGroups;

(* $GroupSymbolRedirect (non-formatted) *)
keysRD=Select[Keys@$GroupSymbolRedirect,!StringContainsQ[#,{"\!"}]&];

(* $CrystalData *)
keysCD=Keys@$CrystalData;

(* $PeriodicTable *)
keysPT=Keys@$PeriodicTable;

(* $TransformationMatrices *)
keysTM=Keys@$TransformationMatrices;

(*-* Mix *-*)
keysRDCD=Join[keysRD,keysCD];


(*---* Enabling auto completion for symbols *---*)
Scan[addCompletion,

{
"AttenuationCoefficient"->{keysCD},
"BraggAngle"->{keysCD},
"CrystalDensity"->{keysCD},
"CrystalFormulaUnits"->{keysCD},
"DarwinWidth"->{keysCD},
"DeleteCrystalData"->{keysCD},
"ExtinctionLength"->{keysCD},
"GetAtomicScatteringFactor"->{keysCD},
"GetCrystalMetric"->{keysCD},
"GetElements"->{keysCD},
"GetLatticeParameters"->{keysCD},
"GetLaueClass"->{keysRDCD},
"GetScatteringCrossSection"->{keysCD},
"GetSymmetryData"->{keysRDCD,
{"Centring","CrystalSystem","GroupType","HallString",
"HermannMauguinFull","HermannMauguinShort","LaueClass",
"Lookup","MainEntryQ","PointGroupNumber","SpaceGroupNumber",
"Symbol"}
},
"GetSymmetryOperations"->{keysRDCD},
"ImportCrystalData"->{2},
"InputCheck"->{
0,
{"1hkl","1xyz","Integer","Multiple","StringSymbol","WrapSingle",
"CrystalQ",
"GetCentringVectors","GetCrystalFormulaUnits",
"GetCrystalSpaceGroup","GetCrystalWavelength","GetEnergyWavelength",
"GetPointSpaceGroupCrystal",
"InterpretElement","InterpretSpaceGroup",
"PointGroupQ","PointSpaceGroupQ",
"Polarisation",
"ProcessWavelength"}
},
"InterplanarSpacing"->{keysCD},
"MergeSymmetryEquivalentReflections"->{keysRDCD},
"ReciprocalSpaceSimulation"->{keysCD},
"ReflectionList"->{keysCD},
"RelatedFunctionsGraph"->{
Sort[First/@DeleteCases[Flatten@First@$MaXrdFunctions,""]]
},
"StructureFactor"->{keysCD},
"StructureFactorTable"->{keysCD},
"SymmetryEquivalentPositions"->{keysRDCD},
"SymmetryEquivalentReflections"->{keysRDCD},
"SymmetryEquivalentReflectionsQ"->{keysRDCD},
"SystematicAbsentQ"->{keysRDCD},
"ToStandardSetting"->{keysRDCD},
"UnitCellTransformation"->{keysCD},
"$CrystalData"->{
keysCD,
{"ChemicalFormula","SpaceGroup",
"LatticeParameters","AtomData","Notes"}
},
"$LaueClasses"->{keysLC},
"$PeriodicTable"->{keysPT},
"$PointGroups"->{keysPG},
"$SpaceGroups"->{keysSG},
"$TransformationMatrices"->{keysTM},
"$GroupSymbolRedirect"->{keysRD}
}]

End[];
