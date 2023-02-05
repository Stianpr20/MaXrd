# *MaXrd*: Mathematica X-ray diffraction package – change log

## Version 3.1.0

- Added option `"ShowUnitVectorLabels"` to `CrystalPlot`.
- Fixed a bug with the `"HighlightReflections"` option of `ReciprocalImageCheck` where it would not filter away symmetry equivalent reflections that were in a plane different form the viewing plane.
- Minor documentation corrections and edits.

## Version 3.0.0

### New content

- Created a `MergeDomains` function for conveniently stacking multiple domains.
- Created the function `ResizeStructure` which can normalise the unit cell to the new dimensions after an embedding is completed, split the unit cell into sections, or translate the unit cell relative to its content.
- Factorised new snippet `InputCheck["RecognizeFractions", _]` (updated `SymmetryEquivalentPositions`).

### Improvements to space group database

- Reflection conditions added to `$SpaceGroups`.
- `SystematicAbsentQ` updated to make use of `"ReflectionConditions"` now stored in `$SpaceGroups`.
- `"PermutableIndices"` added to the `"Property"` association of relevant space groups, which will have values `"Cyclically"` (numbers 195–206) or `True` (numbers 207–230).

### Improvements to `DistortStructure` and `EmbedStructure`

- Changed `DistortStructure` to require a three-dimensional functional input instead.
- New option `"ReturnConverter"` added to `DistortStructure`.
- Added new option `"DistortHost"` to `EmbedStructure`.
- Refactored the permutation options in `EmbedStructure` and enabled random sampling of discrete values.
- Expanded the permutation options of `EmbedStructure` to accept conditions based on entity name.

### Improvements to `ReciprocalImageCheck`

- New options `"HighlightReflections"` and `"HighlightSymmetry"` added to `ReciprocalImageCheck` which are used to generate overlay of coloured disks indicating where the given reflections would be.
- `"RoundPixels"` option of `ReciprocalImageCheck` deprecated (always `True`).
- Option `"ShowLattice"` of `ReciprocalImageCheck` renamed to `"LatticeSize"` with default value `None`.
- Option `"GridThickness"` added.

### Improvements to `ReciprocalSpaceSimulation`

- `ReciprocalSpaceSimulation` now includes the option `"StructureFactorThreshold"` to filter away weak reflections.
- `ReciprocalSpaceSimulation`: added scaling of node radii by structure factor; option: `"IntensityScaling"`.

### Structural changes

- Deprecated `$MaXrdFunctions` since the same list can be obtained with `` ?MaXrd`* `` or `` Names["MaXrd`*"] ``.
- *Mathematica code* sections in documentation pages have been removed; all definitions are accessible in the main definition notebook (`MaXrd > Kernel > Definitions.nb`).
- Loading `MaXrd` will initialize the symbols `a`, `b`, `c`, `h`, `k`, `l`, `\[Alpha]`, `\[Beta]`, and `\[Gamma]` on the `` Global` `` context in the Wolfram Language session.
- Removed the `Messages.m` file; usage messages now stored in `Definitions.nb`.
- Deprecated `$MaXrdChangelog` (viewing the `Changelog.md` file is simple enough).

### Miscellaneous

- Snippet `InputCheck["CrystalQ", _]` now has a third Boolean option to control abortion.
- Updated documentation pages for `SystematicAbsentQ`, `StructureFactorTable` and `DistortStructure`.
- Option `"Threshold"` of `SystematicAbsentQ` deprecated.
- Refactored code in `InputCheck` snippet `"GetCentringVectors"` and added «reverse» setting `"r"`.
- Added another possible setting for the `"ExpandIntoNegative"` option in `ExpandCrystal`: `"PlanarOnly"`, which will only use the negative directions of *a* and *b*.
- Minor documentation improvements (`SynthesiseStructure`).
- Fixed a bug in `SynthesiseStructure` by improving `InputCheck` snippet `"RotationTransformation"` (anchors are now scalable with unit cell dimensions).
- Attempts at plotting a single atom/element with `CrystalPlot` which are not present in `$CrystalData` now gives an error and aborts the process.
- `StructureFactor` now aborts if input crystal label is not recognized.
- Fixed a bug where `SystematicAbsentQ` would fail if special positions were not given for a non-conventional space group setting.

## Version 2.5.0

### New content

- Reintroduced `ReciprocalImageCheck` and `FindPixelClusters`; now more efficiently integrated with MaXrd and more general purposed.
- Created a `GetAtomCoordinates` function which works with crystal labels and crystal plots.
- Changed the name of `EquivalentIsotropicADP` to `TransformAtomicDisplacementParameters` and added a method for transforming atomic displacement parameters given a transformation matrix *P*.
- Added `"AugmentedMatrix"` option to `GetSymmetryOperations`; `StructureFactor`, `SystematicAbsentQ` and `ToStandardSetting` updated to comply with changes.
- Added Boolean option `"IgnoreTranslations"` to `GetSymmetryOperations` in order to simplify use with `SymmetryEquivalentReflections`.
- Added the Boolean option `"Radians"` to `GetLatticeParameters`.
- Added the Boolean option `"Bonds"` to `CrystalPlot` along with configuration option `"BondRadius"`.
- Added the option `"AtomRadius"` to `CrystalPlot` that can be used to set a fixed radius for all atoms. This takes precedence over `"AtomRadiusType"`, but is ignored when it is set to a non-positive number.
- Created `InputCheck["GetAtomData", _]` for querying atom data of crystals.
- Added possibility to plot ellipsoids in `CrystalPlot` using stored ADPs.

### Improvements and fixes

- Misspelling of *SchoenfliesSymbol* in `$SpaceGroup[[71]]` (thanks to **ungerade**).
- Fixed a formatting bug on the `SynthesiseStructure` documentation page.
- When using the signature of `SynthesiseStructure` expecting *domain* input, the *map* now recognises more general replacement commands (*e.g.* `_Integer -> "SomeEntity"`).
- Merged `GetLatticeParameters` with `GetCrystalMetric`, and refactored the latter.
- Refactored `InputCheck["GetCentringVectors", _]` to also accept crystal entries and space group representations.
- Refactored `SymmetryEquivalentPositions` and `SymmetryEquivalentReflections` to use augmented matrix representations of symmetry operations.
- Altered `InputCheck["GetCrystalSpaceGroup", _]` to accept space group entries and return them.
- Updated `InputCheck["CrystalQ", _]` to also check for temporary crystal data. It now returns the crystal data as well.

### Miscellaneous

- Minimised large documentation files by clearing large output cells.
- Removed `SynthesiseStructure::DomainPatternMismatch` error check; input blocks/supercells now replace a single domain cell, regardless of block size.
- Wavelength values assume angstrom by default in the functions `AttenuationCoefficient`, `BraggAngle`, `DarwinWidth`, `ExtinctionLength`, `GetAtomicScatteringFactors`, `GetScatteringCrossSections`, `ImportCrystalData`, `ReciprocalSpaceSimulation`, `ReflectionList`, `StructureFactor` and `StructureFactorTable`; this is now made clear in the documentation pages (thanks to **Sterling Baird (sgbaird)**).
- Changed the way essential data are initialised.

## Version 2.4.0

### Improvements to `SynthesiseStructure`

- Creating single element (or void) unit cells now possible with `SynthesiseStructure[<chemical symbol>, _, _]`.
- Added `"Shuffled"` as a possible setting to the `"SelectionMethod"` option in `SynthesiseStructure`.
- Added Boolean option `"Padding"` to `SynthesiseStructure` which utilises the `InputCheck["PadDomain", _, _]` snippet.
- Refactored `SynthesiseStructure`; when inputting a list of entities, an appropriate domain representation will be created and relayed to the function expecting a domain signature.
- `"UsePlacementBuffer"` option of `SynthesiseStructure` deprecated; `"Padding"` will now be used instead.
- If a domain is not covered in the mapping from integers to entities in `SynthesiseStructure`, empty cells will now be used instead of throwing an error.

### Improvements to `EmbedStructure`

- Enabled the possibility to embed in void (message `EmbedStructure::VoidHost` removed).

### Improvements to space group database

- Removed entries such as `HermannMauguinFullAlt` in space groups with multiple origins.
- For rhombohedral space groups, the note specifying obverse setting was moved to the alternative settings section.
- Regenerated `$GroupSymbolRedirect`.
- Minor error corrections.

### New `InputCheck` snippets

- Added snippet `InputCheck["GenerateTargetPositions", _]` (currently used in `ConstructDomains`, `DomainPlot`, `EmbedStructure`, `ExpandCrystal` and `SynthesiseStructure`).
- Added snippet `InputCheck["PadDomain", _, _]`.
- Added snippets `InputCheck["ShallowDisplayCrystal", _]` (employed in: `ImportCrystalData`, `UnitCellTransformation`).
- Added snippets `InputCheck["FilterSpecialLabels", _]` and `InputCheck["HandleSpecialLabels", _]` for processing chemical element symbols and `"Void"`.
- Added snippet `InputCheck["CrystalEntityQ", _]`.

### Miscellaneous

- Added the option `ImageDimensions` to `SimulateDiffractionPattern` for specifying the width and height of the produced image (`ExportCrystalData` and `InputCheck["GetReciprocalImageOrientation", __]` also updated to comply with this change).
- Appended a missing `_alt` to the CIF definition `_space_group_name_H-M` in the list of space group search keys in `ImportCrystalData`.
- Fixed errors in the `$GroupSymbolRedirect` data file (thanks to Tobias Hadamek for finding this).
- `ImportCrystalData` now takes away tildes (`~`) if they are present in the chemical formulas.
- Fixed a bug where `GetScatteringCrossSections` would not work on Windows due to different line break implementations (thanks to Tobias Hadamek for discovering this).
- An error is now given when attempting to use a chemical symbol or `"Void"` for the name a crystal to be imported from a `cif` file through `ImportCrystalData`.
- `CrystalPlot` will now plot empty structures without errors.
- Demo file `DemoBlocksAB.m` removed (these structures will now be generated on demand).
- Updated code part B.2 in `InputCheck["InterpretSpaceGroup", __]` to find origin choice automatically.

## Version 2.3.0

### New content

- Option `"ShowProgress"` added to `ConstructDomain`.
- Option `"AtomRadiusType"` added to `CrystalPlot`.
- Added the possibility to filter `"Host"` or `"Guest"` atoms only with the `"OpacityMap"` option of `CrystalPlot`.
- Added another example to the `"SectorRegions"` in `ConstructDomains`.
- Added a modulation example to the `DistortStructure` documentation.
- Added the possibility for `ConstructDomains` to store and return the a complete collection of the states in every cycle, and `DomainPlot` to present such a series.

### Improvements and fixes

- Fixed broken hyperlinks in the *See Also* section in the documentation of `ExpandCrystal` and `CrystalPlot`.
- Fixed a bug where `ConstructDomains` would finish each iteration after only three cell visits.
- Set a default Windows path for *DIFFUSE* in `SimulateDiffractionPackage`.
- Altered `SimulateDiffractionPattern` to use `discus` through `discus_suite`.
- Fixed a bug in `SimulateDiffractionPattern["DISCUS", _, _]` where the structure size would not be correctly assessed.
- Fixed a bug where `"UnitCellAtomsCount"` would not be correctly updated when using `SynthesiseStructure`.
- Default plot options for `CrystalPlot` in cases of trigonal or hexagonal systems have changed *ViewPoint* to `{0, 0, Infinity}` and *ViewAngle* to `90°` for more intuitive visual representations.
- The use of `EmbedStructure` with guest and host parameters will now store a `"Component"` key in the atom data.
- Default/suggested paths for Linux added to the  `"ProgramPaths"` option of `SimulateDiffractionPattern`.
- Fixed a bug in `SimulateDiffractionPattern["DISCUS", _, _]` where the procedure would not halt despite missing the *DISCUS* program.
- Fixed a bug with too long assembly list in `SynthesiseStructure`.
- `ConstructDomains` now exits early if a single domain reaches complete domination.
- Fixed an issue where `InputCheck["ProcessWavelength", _, _]` would not work as expected in combination with `BraggAngle`.
- `CrystalPlot` now exits more gracefully if the atom data list is empty.
- *AtomicMass* was renamed to *StandardAtomicWeight* in `$PeriodicTable` and affected functions updated to comply with this change.
- Minor documentation updates.

## Version 2.2.0

- Added the Boolean option `"IgnoreSymmetry"` to `ExpandCrystal`.
- Fixed a bug in `SynthesiseStructure` that would occur if the input units did not have a *Notes* key.
- Improved assembly performance of `SynthesiseStructure`.
- Fixed bug encountered when using `SynthesiseStructure` with blocks not having size 1x1x1.
- Swapped sections 1C and 1D in the internal code for `UnitCellTransformation` to avoid an error for crystals missing notes.
- Added the Boolean option `"ReturnData"` to `SimulateDiffractionPattern`.
- Fixed a bug in `"RelatedFunctionsGraph"`.
- Added twin example to the documentation pages of `ReciprocalSpaceSimulation`.
- Added coordinate transformation example to the documentation pages of `GetCrystalMetric`.
- `docbuild.xml` file updated to work with both macOS and Windows.
- Updated references (`./Misc/References.bib`)
- `README.md` file updated with a *Functionality* section.
- Minor documentation updates.

## Version 2.1.1

- Added more examples to the `SimulateDiffractionPattern` documentation page.
- When specifying a probability distribution of entities with `EmbedStructure`, the procedure now more closely fulfils that distribution instead of using `RandomChoice`.
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
- `ExportCrystalData`: Change third argument `format_String` to `format_String: "DISCUS"` (default value).

## Version 1.7.0

### New content

- Created the function `SynthesiseStructure`.
- Added the snippet `"Update$CrystalDataAutoCompletion"` to `InputCheck` and factorised functions that update `$CrystalData` to use this (`DistortStructure`, `EmbedStructure`, `ExpandCrystal` and `ImportCrystalData`).

### Improvements to `EmbedStructure`

- Option `"ShowProgress"` added to `EmbedStructure`.
- `EmbedStructure` is now capable of dealing with overlapping atoms (new options: `"OverlapPrecedence"` and `"OverlapRadius"`).
- `EmbedStructure` parameter identifiers *source* and *target* were renamed to *guest* and *host*, respectively, to avoid confusion.
- `EmbedStructure` now mutates the *hostCrystal* by default (and uses a new option `"NewLabel"` to create new crystal objects) to be more aligned with the usage of similar functions.

### Miscellaneous

- `$MaXrdChangelog` updated to handle headings/subsections in this changelog.
- `$MaXrdPath` updated to prioritise the standard location of packages in *Mathematica* (`.../Mathematica/Applications/`), as it can find the developing directory as well.
- Minor documentation updates.

## Version 1.6.0

- `DISCUSPlot` now prints error messages from *DISCUS* if there are any (new option: `DISCUSPrint`).
- Improved structure size recognition for `DISCUSPlot`.
- `EmbedStructure` now recognises symbols of the chemical elements; single atoms of the given type will be used.
- Entries (keys) in `$CrystalData` are now sorted alphabetically after using `EmbedStructure` and `ExpandCrystal`.
- Fixed a bug where `ImportCrystalData` would not save manually created crystal entries.
- `ExportCrystalData` updated to use ADP value of zero if no such data is available.
- Created the function `DistortStructure`.
- Minor documentation updates.

## Version 1.5.2

- Removed duplicate entries in the *Mathematica code* sections in the documentation pages.
- Added information on `UnitCellTransformation` option `"CustomP"` in the documentation.
- `DISCUSPLot` now recognises `"Void"` to be used as a vacancy/absence of embedding.
- `MillerNotationToString` now supports string input and supports negative indices written both as negative characters (`Times[-1, "a"]`) and strings where the character is preceded by a dash (`"-a"`).
- Minor documentation updates.

## Version 1.5.1

- `DISCUSPlot` now works on *Windows* and checks whether *DISCUS* is installed.
- Minor documentation updates.

## Version 1.5.0

- Created the function `DISCUSPlot` which executes diffraction simulation in *DISCUS* automatically and plots the result.
- Fixed `GetCrystalMetric` so that the `"Space"` and `"ToCartesian"` options work when input is a list of lattice parameters.
- Updated `InterplanarSpacing` to use the `"Space"` option of `GetCrystalMetric`.
- Fixed a bug in `MillerNotationToList`. Numerical entries are now outputted as integers instead of strings.
- Fixed a bug where settings of `"Rotations"` in `EmbedStructure` would not work as expected.
- Very small numbers are no longer written in scientific notation in `ExportCrystalData`.
- Any ion charges are not carried through in the output of `ExportCrystalData`.
- Updated `RelatedFunctionsGraph` to comply with new option names in *Mathematica* version 12.
- Minor documentation updates.

## Version 1.4.0

- Renamed the options `"RandomDistortions"` and `"RandomRotations"` to `"Distortions"` and `"Rotations"`, respectively, in `EmbedStructure` and made them more general by enabling the choice between set values or ranges.
- Added the option `"DistortionType"` which enables the function to interpret the given distortions either as ångströms in a `"Cartesian"` system or as fractions of the host unit cell in a `"Crystallographic"` setting.
- Added the option `"RotationOrder"` which lets the user specify the order of axes to rotate.

## Version 1.3.0

- Updated the example under *Scope* in the `UnitCellTransformation` documentation page to make use of `CrystalPlot`.
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
- Prepended `` Global` `` to the lattice parameter symbols in `TransformationMatrices.m` to avoid *Mathematica* treating these as `` Global`Private` ``.
- Added an example (with ferrocene) to the `$TransformationMatrices` documentation page.
- Added the option `"Space"` to `GetLatticeParameters` so lattice parameters can be obtained for both direct and reciprocal space.
- Fixed the `SyntaxInformation` for `SymmetryEquivalentPositions`.
- Minor documentation updates.
- Added the option `"ToCartesian"` to `GetCrystalMetric` that utilises the appropriate transformation matrix automatically.
- Functions that have options now simply have `OptionsPattern[]` instead of `OptionsPattern@<function_name>` in the definitions.
- Changed the space group of *CalciumFluoride* in `$CrystalData` from `Fd-3m` (# 227) to `Fm-3m` (# 225).
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
- `GetAtomicScatteringFactor` restructured so to better handle crystal label with reflections input and element(s) with *sinlam* input.
- `InputCheck` procedures with *ProcessWavelength*, *GetCrystalWavelength* and *GetEnergyWavelength* were updated to let *-1* pass through without aborting evaluation.
- `ImportCrystalData` returns a message (but does not abort) if *neutron* radiation type is detected in .cif file.
- `InputCheck` with label *InterpretElement* now replaces *D* (deuterium) with *H*.
- Added the Hall symbol *-B 2ydav* to the space group *B 21/d*.
- Adding crystal data manually in dialogue windows is now possible with `ImportCrystalData`.
- Completed tutorials.
- Added the option *IgnoreHydrogen* to `CrystalFormulaUnits`.
- `$XrayChangelog` file is now formatted in Markdown language.
- `ImportCrystalData` now also counts the number of *atom_site_fract*_ to verify subdata length.
- Detailed information on how *f0* and *f1f2* data files were restructured for this package is now available in the tutorial page *Applying crystal data*.
- `GetAtomicScatteringFactor` now checks for source specific *sin(theta)/lambda* limits.

## Version 0.8

- Merged the separate package-sections into one notebook, and made a *Core* directory for the core elements of the package. The folder *ExampleFiles* could in theory be deleted without affecting the package.
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
- Created *CromerLiberman.m* from all the anomalous correction dat-files. This is now the default source for calculating corrections to the scattering factor in `AtomScatteringFactor`.
- Information on Wyckoff position and site symmetry has been implemented in `$SpaceGroups`.
- Added *InternationalTablesC(3rd)* as a source for coefficients used for calculating the atomic scattering factor.
- Expanded *WaasmaierKirfel.m* with ions.
- Added tabulated data for calculating atomic scattering factors from the *DABAX* directory found at <http://ftp.esrf.eu/scisoft/DabaxFiles/>.
- `AtomicScatteringFactor` now extracts elements from the atom data and not the chemical formula, and elements from the periodic table may be input directly.
- Auto-complete is now updated for `ImportCrystalData` and `DeleteCrystalData` after each successful execution.
- Added more unconventional space group settings for the monoclinic, tetragonal and trigonal crystal systems.
- Added scattering cross section data from *xraylib*, which is applied in `AttenuationCoefficient`.
- Added anomalous scattering factors (correction terms) from *xraylib*.
- Added the option *RationaliseThreshold -> 0.001* in `SymmetryEquivalentPositions`.
- Updated local variables in `StructureFactor` to coincide with notation used in coreCIF.
- `ImportCrystalData` can now store both *SiteSymmetryOrder* and *SiteSymmetryMultiplicity*.
- Better handling of chemical formulas in `ImportCrystalData`.
- Added sub routines to `InputCheck` for retrieving formula untis stored in `$CrystalData` and converting energy or wavelength input to angstroms.
- Separated the "development code" from the *Definitions.nb* notebook.
- Changed name of *ExtinctionDistance* to `ExtinctionLength`.
- Separated out the geometrical factor of the normal procedure for `ExtinctionLength` and `DarwinWidth` (the experimental angles can also be put in).
- Removed `AlignUB`, `ErrorPropagation`, `ExportReflectionFile`, `ImgScript`, `ImportReflectionFile`, `IntensityTable`, `MergeLogs`, `MonitorIni`, `LeastSquaresFit`, `PeakTableInspection`, `RefinedValues`, `RoundSignificants`, `UnwarpLayerList` and `WeightedMean` from the package (not considered core functions to X-ray or diffraction topics).
- `ExtinctionLength` and `DarwinWidth` are now practically listable in terms of reflections.
- All data sources used in `AtomicScatteringFactor` have been truncated at lambda = 2.5 angstroms.
- The space groups of the crystals *Copper* and *Aluminium* were changed from *Fd-3m* to *Fm-3m*.
- Corrected a couple of Hall strings (`C 4 -2a` and `F -4 -2`).
- *OldHallString* and *OldSymbolAlt* added for space groups 39, 41, 64, 67 and 68.
- Added label *GetCentringVectors* to `InputCheck`.
- Added option *UseCentring* to `SymmetryOperations`.
- The tag *SpaceGroupQ* in `InputCheck` has been replaced with a more thorough *InterpretSpaceGroup*, which will return the interpreted space group symbol and abort with messages if not successful.
- Created `CrystalFormulaUnits`. Some functionality was transferred from `CrystalDensity`.
- `SymmetryEquivalentPositions` is now practically listable in terms of coordinates.
- Crystal names can now be input to `GetElements` in order to return a list of elements in its *ChemicalFormula* or *AtomData*.
- Created `GetScatteringCrossSection`.
- Extended `InputCheck` with the label *InterpretElement*.
- Added "IgnoreIonCharge" option to `ImportCrystalData`.
- Several functions now have the name *Get-* prepended to them: `GetAtomicScatteringFactor`, `GetCrystalMetric`, `GetLatticeParameters`, `GetLaueClass`, `GetScatteringCrossSection`, `GetSymmetryData`, `GetSymmetryOperations`.

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
