# Change log

## Version 2.5.0

Release date: 2021-07-27

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
