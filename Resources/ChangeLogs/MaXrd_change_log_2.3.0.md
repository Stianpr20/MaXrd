# Change log

## Version 2.3.0

Release date: 2020-08-04

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
