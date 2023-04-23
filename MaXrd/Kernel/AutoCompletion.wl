(* See file:
    FileNameJoin[{
        $InstallationDirectory, "SystemFiles", "FrontEnd", "SystemResources",
        "FunctionalFrequency","specialArgFunctions.tr"
    }]

    And URL:
        https://mathematica.stackexchange.com/questions/56984/ argument-completions-for-user-defined-functions#129910

    Argument codes:
        Normal argument   0
        AbsoluteFilename  2
        RelativeFilename  3
        Color             4
        PackageName       7
        DirectoryName     8
        InterpreterType   9
*)

If[$Notebooks,
    addCompletion := FE`Evaluate[FEPrivate`AddSpecialArgCompletion[#]
        ]&;
    (*---* Data bases *---*)
    (* $PointGroups *)
    keysPG = Keys @ $PointGroups;
    (* $LaueClasses *)
    keysLC = Keys @ $LaueClasses;
    (* $SpaceGroups *)
    keysSG = Keys @ $SpaceGroups;
    (* $GroupSymbolRedirect (non-formatted) *)
    keysRD = Select[Keys @ $GroupSymbolRedirect, !StringContainsQ[#, 
        {"\!"}]&];
    (* $CrystalData *)
    keysCD = Keys @ $CrystalData;
    (* $PeriodicTable *)
    keysPT = Keys @ $PeriodicTable;
    (* $TransformationMatrices *)
    keysTM = Keys @ $TransformationMatrices;
    (*-* Mix *-*)
    keysRDCD = Join[keysRD, keysCD];
    (*---* Enabling auto completion for symbols *---*)
    Scan[addCompletion, {"AttenuationCoefficient" -> {keysCD}, "BraggAngle"
         -> {keysCD}, "CrystalDensity" -> {keysCD}, "CrystalFormulaUnits" -> 
        {keysCD}, "CrystalPlot" -> {keysCD}, "DarwinWidth" -> {keysCD}, "DistortStructure"
         -> {keysCD, 0, 0}, "EmbedStructure" -> {keysCD, 0, keysCD, 0}, "ExpandCrystal"
         -> {keysCD}, "ExportCrystalData" -> {{"DIFFUSE", "DISCUS"}, keysCD, 
        2}, "ExtinctionLength" -> {keysCD}, "GetAtomicScatteringFactor" -> {keysCD
        }, "GetCrystalMetric" -> {keysCD}, "GetElements" -> {keysCD}, "GetLatticeParameters"
         -> {keysCD}, "GetLaueClass" -> {keysRDCD}, "GetScatteringCrossSection"
         -> {keysCD}, "GetSymmetryData" -> {keysRDCD, {"Centring", "CrystalSystem",
         "GroupType", "HallString", "HermannMauguinFull", "HermannMauguinShort",
         "LaueClass", "Lookup", "MainEntryQ", "PointGroupNumber", "SpaceGroupNumber",
         "Symbol"}}, "GetSymmetryOperations" -> {keysRDCD}, "ImportCrystalData"
         -> {2}, "InputCheck" -> {0, {"1hkl", "1xyz", "Integer", "Multiple", 
        "StringSymbol", "WrapSingle", "CrystalEntityQ", "CrystalQ", "FilterSpecialLabels",
         "GenerateTargetPositions", "GetCartesianTransformation", "GetCentringVectors",
         "GetCrystalFamilyMetric", "GetCrystalFormulaUnits", "GetCrystalSpaceGroup",
         "GetCrystalWavelength", "GetEnergyWavelength", "GetPointSpaceGroupCrystal",
         "GetReciprocalImageOrientation", "HandleSpecialLabels", "InterpretElement",
         "InterpretSpaceGroup", "PadDomain", "PointGroupQ", "PointSpaceGroupQ",
         "Polarisation", "ProcessWavelength", "RotationTransformation", "ShallowDisplayCrystal",
         "Update$CrystalDataAutoCompletion", "Update$CrystalDataFile"}}, "InterplanarSpacing"
         -> {keysCD}, "MergeSymmetryEquivalentReflections" -> {keysRDCD}, "ReciprocalSpaceSimulation"
         -> {keysCD}, "ReflectionList" -> {keysCD}, "RelatedFunctionsGraph" ->
         Names["StianRamsnes`MaXrd`*"], "ResizeStructure" -> {keysCD, 0}, "SimulateDiffractionPattern"
         -> {{"DIFFUSE", "DISCUS"}, keysCD, 0}, "StructureFactor" -> {keysCD},
         "StructureFactorTable" -> {keysCD}, "SymmetryEquivalentPositions" ->
         {keysRDCD}, "SymmetryEquivalentReflections" -> {keysRDCD}, "SymmetryEquivalentReflectionsQ"
         -> {keysRDCD}, "SynthesiseStructure" -> {keysCD, 0, 0}, "SystematicAbsentQ"
         -> {keysRDCD}, "ToStandardSetting" -> {keysRDCD}, "TransformAtomicDisplacementParameters"
         -> {keysCD}, "UnitCellTransformation" -> {keysCD, {"CartesianConverter",
         "EquivalentIsotropic"}}, "$CrystalData" -> {keysCD, {"AtomData", "ChemicalFormula",
         "FormulaUnits", "LatticeParameters", "Notes", "SpaceGroup", "Wavelength"
        }}, "$LaueClasses" -> {keysLC}, "$PeriodicTable" -> {keysPT}, "$PointGroups"
         -> {keysPG}, "$SpaceGroups" -> {keysSG}, "$TransformationMatrices" ->
         {keysTM}, "$GroupSymbolRedirect" -> {keysRD}}];
];
