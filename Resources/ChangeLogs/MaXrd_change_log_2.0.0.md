# Change log

## Version 2.0.0

Release date: 2020-01-05

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
