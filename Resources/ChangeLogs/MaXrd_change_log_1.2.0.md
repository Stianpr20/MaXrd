# Change log

## Version 1.2.0

Release date: 2019-03-16

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
