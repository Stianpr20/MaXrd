# Change log

## Version 3.0.0

Release date: 2022-05-17

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
