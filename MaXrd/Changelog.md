# *MaXrd*: Mathematica X-ray diffraction package – change log

## Version 2.1.1
- Added more examples to the `SimulateDiffractionPattern` documentation page.
- When specifying a probability distribution of entities with `EmbedStructure`, the procedure now more closely fulfills that distribution instead of using `RandomChoice`.
- Updated `ImportCrystalData` to use the data file in the `UserData` directory by default (changed the `"DataFile"` option).
- Added `"DataFile"` option to `EmbedStructure` and `ExpandCrystal`.
- Factorised data file operations for `ImportCrystalData`, `EmbedStructure` and `ExpandCrystal` into a `InputCheck` snippet with label `"Update$CrystalDataFile"`.
- Minor updates in the documentation (`SimulateDiffractionPattern`, `EmbedStructure`) and in the package unit test.


## Version 2.1.0
### New content
- Added the option `"IncludeStructureSizeInfo"` to `ExportCrystalData`.
- Added the option `"ScalingFactor"` to `SimulateDiffractionPattern`.

### Improvements and fixes
- Fixed a bug in `SimulateDiffractionPattern` where the use of *DISCUS* would not work correctly.
- Created a `UserData` directory in the package root and moved `CrystalData.m` here. `$CrystalData` and `ResetCrystalData` updated to conform with this change.
- `ImportCrystalData` now returns instead of aborting if user cancels import.
- Improved the package unit test.
- `$MaXrdPath` updated with support for *Windows*.
- Minor documentation updates.


## Version 2.0.0
### Changes
- `InputCheck["DomainRotation"]` has been replaced with `InputCheck["RotationTransformation"]`, which is more versatile (now used in `DomainPlot`, `EmbedStructure` and `SynthesiseStructure`) and uses different rotation options (`"RotationAnchorReference"`, `"RotationAnchorShift"`, `"RotationAxes"`).
- Angular input parameters in `BraggAngle`, `DomainPlot`, `EmbedStructure`, `ReflectionList` and `SynthesiseStructure` are now expected to be in radians. This seems to be more universally adopted and makes it clearer when input is in degrees.
- `"DISCUSPlot"` changed name to `SimulateDiffractionPattern"`, as both `"DISCUS"` and `"DIFFUSE"` can now be used to generate simulations.
- Edited `init.m` to print message in case of insufficient *Mathematica* version.
- `InputCheck` declarations reorganised so snippet labels are always the first parameter (affected: `"CrystalQ"`, `"GetCentringVectors"`, `"GetCrystalFormulaUnits"`, `"GetCrystalSpaceGroup"`, `"GetCrystalWavelength"`, `"GetEnergyWavelength"`, `"GetPointSpaceGroupCrystal"`, `"InterpretElement"`, `"InterpretSpaceGroup"`, `"PointGroupQ"`, `"PointSpaceGroupQ"`, `"Polarisation"`).

### New content
- Added functionality to `ConstructDomains` that simplifies creation of sector domains/regions.
- `SynthesiseStructure` now has a designated routine for domains.
- `"OpacityMap"` option added to `CrystalPlot`.
- Created the tutorial *Using the rotation options* aimed at the usage of `DomainPlot`, `EmbedStructure` and `SynthesiseStructure`.
- `ExportCrystalData` now supports a new format: `"DIFFUSE"`.
- Implemented `"DIFFUSE"` as an alternative method of producing simulated diffraction patterns (through Darren Goossens' *ZMC* program).
- New snippet `"GetReciprocalImageOrientation"` added to `InputCheck`.
- Created the function `ResetCrystalData`.

### Miscellaneous
- `DistortStructure` now checks the dimensions of input.
- Fixed a bug where `GetCrystalMetric` had problems with lattice parameters expressed as quantities.
- Interstitial defect example added to `DistortStructure`.
- Minor documentation updates.
- Corrected misspelling of *AsymmetricUnitCellCount* in `ExpandCrystal`.
- Option `"Flag"` in `ExportCrystalData` changed to `"Detailed"` (now a Boolean type).
- `EmbedStructure` now calculates the (mean) number of atoms per unit cell for the new structure.
- Fixed a bug in `GetSymmetryData` where the label `"Setting"` would not work as expected.
- Renamed error message `GetElements::formula` to `GetElements::InvalidFormula` and `::invalid` to `::InvalidElement`.
- Error messages of `InputCheck` updated.
- A unit test for the package has been written.
- Reorganised internal layout of the package.
- Documentation pages updated.


## Version 1.8.0
### New content
- Created the function `ConstructDomains`.
- Created the function `DomainPlot`.
- `InputCheck` updated with a `"DomainRotation"` and a `"GetCrystalFamilyMetric"` label.

### Improvements to `EmbedStructure`
- If conditional placement is used with `EmbedStructure` and a given coordinate tuple falls through without any match, nothing is inserted here (used to insert last entry in `guestUnits`).
- Fixed a bug with `EmbedStructure` where using `"Rotations"` did not assume numbers in degrees.
- Message is no longer given if conditions or random selections are such that nothing is embedded (`EmbedStructure::OnlyVoid`).
- A host structure is now considered to be placed in positive coordinates as long as no coordinates are below `-1.0` in any direction.
- `EmbedStructure` now updates the `"StructureSize"` of the resulting structure.

### Miscellaneous
- `SynthesiseStructure` now also supports the `"RotationMap"` and `"RotationPoint"` options akin to `DomainPlot`. Documentation page updated.
- Second argument of `ExpandCrystal` changed to `structureSize_List: {1, 1, 1}`.
- `ExportCrystalData`: Change third argument ` format_String` to `format_String: "DISCUS"` (default value).


## Version 1.7.0
### New content
- Created the function `SynthesiseStructure`.
- Added the snippet `"Update$CrystalDataAutoCompletion"` to `InputCheck` and factorised functions that update `$CrystalData` to use this (`DistortStructure`, `EmbedStructure`, `ExpandCrystal` and `ImportCrystalData`).

### Improvements to `EmbedStructure`
- Option `"ShowProgress"` added to `EmbedStructure`.
- `EmbedStructure` is now capable of dealing with overlapping atoms (new options: `"OverlapPrecedence"` and `"OverlapRadius"`).
- `EmbedStructure` parameter identifiers _source_ and _target_ were renamed to _guest_ and _host_, respectively, to avoid confusion.
- `EmbedStructure` now mutates the _hostCrystal_ by default (and uses a new option `"NewLabel"` to create new crystal objects) to be more aligned with the usage of similar functions.

### Miscellaneous
- `$MaXrdChangelog` updated to handle headings/subsections in this changelog.
- `$MaXrdPath` updated to prioritise the standard location of packages in _Mathematica_ (`.../Mathematica/Applications/`), as it can find the developing directory as well.
- Minor documentation updates.


## Version 1.6.0
- `DISCUSPlot` now prints error messages from _DISCUS_ if there are any (new option: `DISCUSPrint`).
- Improved structure size recognition for `DISCUSPlot`.
- `EmbedStructure` now recognises symbols of the chemical elements; single atoms of the given type will be used.
- Entries (keys) in `$CrystalData` are now sorted alphabetically after using `EmbedStructure` and `ExpandCrystal`.
- Fixed a bug where `ImportCrystalData` would not save manually created crystal entries.
- `ExportCrystalData` updated to use ADP value of zero if no such data is available.
- Created the function `DistortStructure`.
- Minor documentation updates.


## Version 1.5.2
- Removed duplicate entries in the _Mathematica code_ sections in the documentation pages.
- Added information on `UnitCellTransformation` option `"CustomP"` in the documentation.
- `DISCUSPLot` now recognises `"Void"` to be used as a vacancy/absence of embedding.
- `MillerNotationToString` now supports string input and supports negative indices written both as negative characters (`Times[-1, "a"]`) and strings where the character is preceded by a dash (`"-a"`).
- Minor documentation updates.


## Version 1.5.1
- `DISCUSPlot` now works on _Windows_ and checks whether _DISCUS_ is installed.
- Minor documentation updates.


## Version 1.5.0
- Created the function `DISCUSPlot` which executes diffraction simulation in _DISCUS_ automatically and plots the result.
- Fixed `GetCrystalMetric` so that the `"Space"` and `"ToCartesian"` options work when input is a list of lattice parameters.
- Updated `InterplanarSpacing` to use the `"Space"` option of `GetCrystalMetric`.
- Fixed a bug in `MillerNotationToList`. Numerical entries are now outputted as integers instead of strings.
- Fixed a bug where settings of `"Rotations"` in `EmbedStructure` would not work as expected.
- Very small numbers are no longer written in scientific notation in `ExportCrystalData`.
- Any ion charges are not carried through in the output of `ExportCrystalData`.
- Updated `RelatedFunctionsGraph` to comply with new option names in _Mathematica_ version 12.
- Minor documentation updates.


## Version 1.4.0
- Renamed the options `"RandomDistortions"` and `"RandomRotations"` to `"Distortions"` and `"Rotations"`, respectively, in `EmbedStructure` and made them more general by enabling the choice between set values or ranges.
- Added the option `"DistortionType"` which enables the function to interpret the given distortions either as ångströms in a `"Cartesian"` system or as fractions of the host unit cell in a `"Crystallographic"` setting.
- Added the option `"RotationOrder"` which lets the user specify the order of axes to rotate.


## Version 1.3.0
- Updated the example under _Scope_ in the `UnitCellTransformation` documentation page to make use of `CrystalPlot`.
- Added `EmbedStructure` to the list in `AutoComplete.nb`.
- Added the option `"Space"` to `GetCrystalMetric` so lattice parameters can be used from either direct or reciprocal space.
- Fixed a bug in `ExportCrystalData[_, _, "DISCUS"]` where the structure size would not be included in the output file.
- Added the possibility to use `EmbedStructure` with list of conditions that dictate where to place embeddings.
- Updated `ExportCrystalData` with the option `"Flag"` which can be set to `"Simple"` (default) or `"Detailed"`.
- Added the Boolean option `"ExpandIntoNegative"` for `ExpandCrystal` which centres the origin at the middle of the new structure. Updated `EmbedStructure` to detect this change.
- Added the option `"TrimBoundary"` to `EmbedStructure` enabling a "trimming" of the structure after embedding.
- Created the option `"RandomDistortions"` for `EmbedCrystal` which can perform a random shift/distortion of units upon embedding.
- Removed `DeleteCrystalData`. Using `KeyDropFrom[$CrystalData, <label_to_delete>]` gives the same result.
- Created the option `"RandomRotations"` for `EmbedCrystal` analogous to `"RandomDistortions"`.
- Minor documentation updates.
- Changed all `Module`s with `Block` in the definitions for better performance.


## Version 1.2.0
- Replaced `Part` brackets with `\[LeftDoubleBracket]` and `\[RightDoubleBracket]` in definition code for better readability.
- Prepended `` Global` `` to the lattice parameter symbols in `TransformationMatrices.m` to avoid _Mathematica_ treating these as `` Global`Private` ``.
- Added an example (with ferrocene) to the `$TransformationMatrices` documentation page.
- Added the option `"Space"` to `GetLatticeParameters` so lattice parameters can be obtained for both direct and reciprocal space.
- Fixed the `SyntaxInformation` for `SymmetryEquivalentPositions`.
- Minor documentation updates.
- Added the option `"ToCartesian"` to `GetCrystalMetric` that utilises the appropriate transformation matrix automatically.
- Functions that have options now simply have `OptionsPattern[]` instead of `OptionsPattern@<function_name>` in the definitions.
- Changed the space group of _CalciumFluoride_ in `$CrystalData` from `Fd-3m` (# 227) to `Fm-3m` (# 225).
- Created the function `EquivalentIsotropicADP`.
- Created the function `CrystalPlot`. 
- Created the function `ExportCrystalData`.
- Created the function `ExpandCrystal`.
- Created the function `EmbedStructure`.
- Updated `InputCheck[_, "GetPointSpaceGroupCrystal"]` to handle crystal instances in a temporary `$CrystalData` construct.
- Updated `PacletInfo.m`.
- Removed `Installation.nb` and updated installation instructions in `README.md`.


## Version 1.1.0
- `SyntaxInformation` added for relevant functions. 
- Minor changes to the guide page (main documentation page) and title of this change log.
- Updated documentation page for `SymmetryEquivalentReflections` (function can be called with one argument).
- Corrected option table for `StructureFactor`.


## Version 1.0.2
- Fixed a bug where `ReflectionList` and `ReciprocalSpaceSimulation` would not work with crystals that stored wavelength as a `Quantity`.
- Minor updates and changes in the documentation (thanks to Bianca Eifert for pointing out some of them).
- Added some missing auto-complete suggestions for `$CrystalData` (for the second argument).
- Added the option `AngleThreshold` to `BraggAngle` and `ReflectionList` for more efficient filtering by Bragg angle.


## Version 1.0.1
- `Changelog.txt` changed extension to `Changelog.md`.
- Updated `$MaXrdChangelog`.
- The `MaXrd/Kernel/init.m` file was edited to allow for a more general package placement and correct auto-complete version requirement (thanks to Szabolcs Horvát).
- Minor revisions in the `README.md` file.
- Corrected version requirement from `10.0+` to `10.3+`.
- Changed the definition of `$MaXrdPath` to comply with a more general package placement.
- Fixed some hyperlink bugs in the main tutorial page.
- Corrected spelling errors in the documentation.
- Corrected a bug where `MillerNotationToString` did not work as expected with negative indices.



## Version 1.0.0
- Package renamed from **Xray** to **MaXrd**!
- Renamed `$XrayFunctions` to `$MaXrdFunctions`, `$XrayChangelog` to `$MaXrdChangelog`, `$XrayPath` to `$MaXrdPath`, `$XrayRedirect` to `$GroupSymbolRedirect` and `$XrayVersion` to `$MaXrdVersion`.
- `GetAtomicScatteringFactor` and `GetScatteringCrossSection` renamed to `GetAtomicScatteringFactors` and `GetScatteringCrossSections`, respectively.


## Version 0.9
- Refactored some code in `ImportCrystalData`; updated documentation.
- `GetAtomicScatteringFactor` restructured so to better handle crystal label with reflections input and element(s) with _sinlam_ input.
- `InputCheck` procedures with _ProcessWavelength_, _GetCrystalWavelength_ and _GetEnergyWavelength_ were updated to let _-1_ pass through without aborting evaluation.
- `ImportCrystalData` returns a message (but does not abort) if _neutron_ radiation type is detected in .cif file.
- `InputCheck` with label _InterpretElement_ now replaces _D_ (deuterium) with _H_.
- Added the Hall symbol _-B 2ydav_ to the space group _B 21/d_.
- Adding crystal data manually in dialogue windows is now possible with `ImportCrystalData`.
- Completed tutorials.
- Added the option _IgnoreHydrogen_ to `CrystalFormulaUnits`.
- `$XrayChangelog` file is now formatted in Markdown language.
- `ImportCrystalData` now also counts the number of _atom_site_fract__ to verify subdata length.
- Detailed information on how _f0_ and _f1f2_ data files were restructured for this package is now available in the tutorial page _Applying crystal data_.
- `GetAtomicScatteringFactor` now checks for source specific _sin(theta)/lambda_ limits.


## Version 0.8
- Merged the separate package-sections into one notebook, and made a _Core_ directory for the core elements of the package. The folder _ExampleFiles_ could in theory be deleted without affecting the package.
- `$XrayPath` created, which is a path to the main directory of the package. All other paths should be set relative to this.
- Removed `$XrayExamples`. Easy enough to use `$XrayPath`.
- Miscellaneous updates of the documentation.
- Updated `$PointGroups`: The association is now using non-formatted keys, some keys have been adjusted and more symbol variations have been added. Schoenflies symbols and class names information has also been added.
- Miscellanous updates to `$SpaceGroups`.
- The `XrayChangelog` function was updated. The log is now presented in a new window/notebook.
- Created `ExportCrystalData`.
- Renamed `AddCompoundToDataset` and `RemoveCompoundFromDataset` to `ImportCrystalData` and `DeleteCrystalData`, respectively.
- Updated the default data in `$CrystalData`.
- Addded the option "Threshold" to `StructureFactor`.
- Added the option "IgnoreSystematicAbsence" to `StructureFactor`.
- Updated `ReflectionList` to use Tuples. Table will be used if "HoldIndex" option is applied.
- `ScatteringFactor` and `StructureFactor` are now effectively Listable in regards to reflections.
- Added subgroup data to `$PointGroups`.
- Fixed a bug in `SymmetryEquivalentPositions` where the non-centring sub-routine was not working properly.
- Renamed `ScatteringFactor` to `AtomicScatteringFactor`.
- Deleted `$ScatteringFactors`; its functionality has been incorporated with `AtomicScatteringFactor`.
- Fixed a bug in `SymmetryEquivalentPositions` where too many equivalent positions were generated when not taking centring into account.
- Fixed a bug in `StructureFactor`; the multiplicity reduction was incorrect.
- Length- and energy quantities may now be input in `StructureFactor`.
- `$PhysicalConstants` discontinued.
- Created _CromerLiberman.m_ from all the anomalous correction dat-files. This is now the default source for calculating corrections to the scattering factor in `AtomScatteringFactor`.
- Information on Wyckoff position and site symmetry has been implemented in `$SpaceGroups`.
- Added _InternationalTablesC(3rd)_ as a source for coefficients used for calculating the atomic scattering factor.
- Expanded _WaasmaierKirfel.m_ with ions.
- Added tabulated data for calculating atomic scattering factors from the _DABAX_ directory found at http://ftp.esrf.eu/scisoft/DabaxFiles/.
- `AtomicScatteringFactor` now extracts elements from the atom data and not the chemical formula, and elements from the periodic table may be input directly.
- Auto-complete is now updated for `ImportCrystalData` and `DeleteCrystalData` after each successful execution.
- Added more unconventional space group settings for the monoclinic, tetragonal and trigonal crystal systems.
- Added scattering cross section data from _xraylib_, which is applied in `AttenuationCoefficient`.
- Added anomalous scattering factors (correction terms) from _xraylib_.
- Added the option _RationaliseThreshold -> 0.001_ in `SymmetryEquivalentPositions`.
- Updated local variables in `StructureFactor` to coincide with notation used in coreCIF.
- `ImportCrystalData` can now store both _SiteSymmetryOrder_ and _SiteSymmetryMultiplicity_.
- Better handling of chemical formulas in `ImportCrystalData`.
- Added sub routines to `InputCheck` for retrieving formula untis stored in `$CrystalData` and converting energy or wavelength input to angstroms. 
- Separated the "development code" from the _Definitions.nb_ notebook.
- Changed name of _ExtinctionDistance_ to `ExtinctionLength`.
- Separated out the geometrical factor of the normal procedure for `ExtinctionLength` and `DarwinWidth` (the experimental angles can also be put in).
- Removed `AlignUB`, `ErrorPropagation`, `ExportReflectionFile`, `ImgScript`, `ImportReflectionFile`, `IntensityTable`, `MergeLogs`, `MonitorIni`, `LeastSquaresFit`, `PeakTableInspection`, `RefinedValues`, `RoundSignificants`, `UnwarpLayerList` and `WeightedMean` from the package (not considered core functions to X-ray or diffraction topics).
- `ExtinctionLength` and `DarwinWidth` are now practically listable in terms of reflections.
- All data sources used in `AtomicScatteringFactor` have been truncated at lambda = 2.5 angstroms.
- The space groups of the crystals _Copper_ and _Aluminium_ were changed from _Fd-3m_ to _Fm-3m_.
- Corrected a couple of Hall strings (`C 4 -2a` and `F -4 -2`).
- _OldHallString_ and _OldSymbolAlt_ added for space groups 39, 41, 64, 67 and 68.
- Added label _GetCentringVectors_ to `InputCheck`.
- Added option _UseCentring_ to `SymmetryOperations`.
- The tag _SpaceGroupQ_ in `InputCheck` has been replaced with a more thorough _InterpretSpaceGroup_, which will return the interpreted space group symbol and abort with messages if not successful.
- Created `CrystalFormulaUnits`. Some functionality was transferred from `CrystalDensity`.
- `SymmetryEquivalentPositions` is now practically listable in terms of coordinates.
- Crystal names can now be input to `GetElements` in order to return a list of elements in its _ChemicalFormula_ or _AtomData_.
- Created `GetScatteringCrossSection`.
- Extended `InputCheck` with the label _InterpretElement_.
- Added "IgnoreIonCharge" option to `ImportCrystalData`.
- Several functions now have the name _Get-_ prepended to them: `GetAtomicScatteringFactor`, `GetCrystalMetric`, `GetLatticeParameters`, `GetLaueClass`, `GetScatteringCrossSection`, `GetSymmetryData`, `GetSymmetryOperations`.


## Version 0.7.9
- Updated `$SpaceGroups`: Space group entries now have a `Name` sub-key that extends support for more alternative settings.
- Created the function `UnitCellTransformation` for transforming entries in `$CrystalData` to different cell settings.
- Fixed minor formatting bugs in `$SpaceGroups`.
- Added _HermannMauguinFullAlt_ entries to rhombohedral space groups (R3, R-3, R32, R3m, R3c, R-3m, R-3c) that include _:h_ or _:r_.
- Also added _SymbolAlt_, _HermannMauguinShortAlt_ and _HermannMauguinFullAlt_ to space group entries with multiple cell origins.
- Fixed _I 41/a_ (no. 88) entry in `$SpaceGroups`.
- `$XrayRedirect` updated to comply with changes of `$SpaceGroup`.
- Fixed a bug in `AddCompoundToDataset`; no _DisplacementParameters_ were written if the cif-file were missing such data.
- Added the functionality to find “best fitting” space group formatting with `ToStandardSetting`.
- Fixed a bug in `AddCompoundToDataset` when a _label_ was not explicitly given by the user.
- Added support for chemical formulas with decimals in `AddCompoundToDataset`.
- Updated `GetElements` with an option to ignore the charge of ions.
- Updated documentation on `UBtransformation`.
- Added support for string input in the `ToMiller` and `FromMiller` functions.
- Changed names of _SymmetryOperationsNotationA_ to _SymmetryOperationsITA_ and _SymmetryOperationsNotationB_ to _SymmetryOperationsSeitz_ in `$PointGroups`.
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
- Updated `SymmetryData` with the option _UnambiguousSymbol_.
- Changed the name from `ReflectionConditionCheck` to `ReciprocalImageCheck`.
- Changed the name from `SimulateReciprocalSpace` to `ReciprocalSpaceSimulation`.
- Created the functions `BraggAngle` and `InterplanarSpacing`.
- Created the functions `ExtinctionDistance` and `DarwinWidth`.
- `$XrayRedirect` now supports concatenated versions of short Hermann--Mauguin symbols.
- Added the _HoldIndex_ option in `ReflectionList`. Included this option in `ReciprocalSpaceSimulation`.
- Fixed a bug in `ReflectionList` where the incorrect resolution, based on the wavelength, was found.
- Added _CrystallographyToCartesian_ to `$TransformationMatrices`.
- Updated `GetElements` with a _Tally_ option.
- Created `$PeriodicTable`.


## Version 0.7.8
- Minor bug fixes and updated in the documentation.
- It is now possible to set values for the cutoff intensity and group width in `ReflectionSetInspection`.
- Updated `ToMiller` to return output with commas if any index is not an integer.
- New function added to the `Statistics` context: `NonlinearLeastSquares`.
- Fixed an error with `StructureFactor` causing it to not accept wavelength input.
- `AddCompoundToDataset` now adds the site symmetry order for each atom to `$CrystalData`.
- Updates on `StructureFactor` (handles occupation factor and site symmetry differently).
- Updated some functions to also use `InputCheck` for crystal names.


## Version 0.7.7
- Updated documentation on `CrystalMetric` and fixed a link in the `Xray` guide.
- Updated documentation on `StructureFactor`.
- Minor fixes in the code.
- Added `P21/n` and `P21/a` to `$XrayRedirect`.
- Contact e-mail added to main guide page.
- Updated documentation on `$ScatteringFactors`. References are now included.
- `Installation.nb` will no longer ask user to save changes.
- If structure factor equals zero, corresponding phases are now displayed as `--` in `StructureFactorTable`.
- `StructureFactor` now has an option for disabling units (the phase). Documentation updated.
- `$PointGroups` and `$SpaceGroups` now have the formatted symbol prepended to each entry.
- Minor bug fixes in `AddCompoundToDataset`. Updated the way output is presented. Changed the way ADP type information is stored in `$CrystalData` -- now the various atoms can be of different types.
- `CrystalMetric` updated to support input of lattice parameters directly.
- Introduced a `Limit` and a `Progress` option to `ReflectionList`.


## Version 0.7.6
- `$XrayVersion` and `$XrayChangelog` added.
- Minor fixes in documentation.
- Fixed some bugs in `AddCompoundToDataset`.
- Fixed a bug with `StructureFactorTable` that could give unit cell volumes to be imaginary.
- Updated `RefinedValues`. New tag available: `Wavelenght`.
- Updated `MergeLogs`.


## Version 0.7.5
- Changelog started.
- Documentation on `SystematicAbsentQ` fixed.
- Several functions belonging to the context `Crystallography` have been ascribed the new context `Physics`.
- `$PhysicalConstants` created.
- Wrong coefficients in `$ScatteringFactors` were corrected (At, Be, C, Ho, Ni, Tm, Zn).
- The space groups of `Silicon`, `Germanium` and `Diamond` are now set to use the alternative origin in `$CrystalData`.
- Added new alternative space group entries to `$SpaceGroups` (B1, C1, F1, I1, P1, A-1, B-1, C-1, F-1, I-1). `$XrayRedirect` was also updated.
- `SymmetryOperations` in `$SpaceGroups` have been flattened to a plain list structure.
- The following new functions were created: `InputCheck`, `LaueClass`.
- `StructureFactorTable` now sorts by decreasing structure factor by default.
- `ReflectionList` now sorts reflections from least to highest digit sum (ignoring sign), and has been extended with a `Keep` option.
- Added the option `ReflectionListKeep` to `StructureFactorTable`.
- Updated the documentation on `StructureFactor` and `StructureFactorTable`.
- Minor bug fixes.

