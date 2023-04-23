# Change log

## Version 2.2.0

Release date: 2020-07-02

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
