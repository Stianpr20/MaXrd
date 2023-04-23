
# Change log

## Version 0.7.9

- Updated `$SpaceGroups`: Space group entries now have a `Name` sub-key that extends support for more alternative settings.
- Created the function `UnitCellTransformation` for transforming entries in `$CrystalData` to different cell settings.
- Fixed minor formatting bugs in `$SpaceGroups`.
- Added *HermannMauguinFullAlt* entries to rhombohedral space groups (R3, R-3, R32, R3m, R3c, R-3m, R-3c) that include *:h* or *:r*.
- Also added *SymbolAlt*, *HermannMauguinShortAlt* and *HermannMauguinFullAlt* to space group entries with multiple cell origins.
- Fixed *I 41/a* (no. 88) entry in `$SpaceGroups`.
- `$XrayRedirect` updated to comply with changes of `$SpaceGroup`.
- Fixed a bug in `AddCompoundToDataset`; no *DisplacementParameters* were written if the cif-file were missing such data.
- Added the functionality to find “best fitting” space group formatting with `ToStandardSetting`.
- Fixed a bug in `AddCompoundToDataset` when a *label* was not explicitly given by the user.
- Added support for chemical formulas with decimals in `AddCompoundToDataset`.
- Updated `GetElements` with an option to ignore the charge of ions.
- Updated documentation on `UBtransformation`.
- Added support for string input in the `ToMiller` and `FromMiller` functions.
- Changed names of *SymmetryOperationsNotationA* to *SymmetryOperationsITA* and *SymmetryOperationsNotationB* to *SymmetryOperationsSeitz* in `$PointGroups`.
- Improved `MergeSymmetryEquivalent`.
- Minor fixes and updates in documentation.
- Created documentation on `RoundSignificants` and `ErrorPropagation`.
- Fixed a bug in `RoundSignificants` where output would not have a zero as second significant figure when expected.
- Created `SymmetryData`.
- Added the option `UseCentring` to `SymmetryEquivalentPositions`.
- Updated a bug in `InputCheck` where reflections containing negatives would not pass the function tests.
- Merged `ReflectionSetInspection` and `PeakTableHelper` to `PeakTableInspection`.
- Update documentation on `ReflectionConditionCheck`.
- Fixed bugs in `AddCompoundToDataset`: Procedure for finding the ADPs is now more robust.
- Updated `SymmetryData` with the option *UnambiguousSymbol*.
- Changed the name from `ReflectionConditionCheck` to `ReciprocalImageCheck`.
- Changed the name from `SimulateReciprocalSpace` to `ReciprocalSpaceSimulation`.
- Created the functions `BraggAngle` and `InterplanarSpacing`.
- Created the functions `ExtinctionDistance` and `DarwinWidth`.
- `$XrayRedirect` now supports concatenated versions of short Hermann--Mauguin symbols.
- Added the *HoldIndex* option in `ReflectionList`. Included this option in `ReciprocalSpaceSimulation`.
- Fixed a bug in `ReflectionList` where the incorrect resolution, based on the wavelength, was found.
- Added *CrystallographyToCartesian* to `$TransformationMatrices`.
- Updated `GetElements` with a *Tally* option.
- Created `$PeriodicTable`.
