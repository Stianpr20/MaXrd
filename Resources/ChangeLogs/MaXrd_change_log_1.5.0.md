# Change log

## Version 1.5.0

Release date: 2019-04-23

- Created the function `DISCUSPlot` which executes diffraction simulation in *DISCUS* automatically and plots the result.
- Fixed `GetCrystalMetric` so that the `"Space"` and `"ToCartesian"` options work when input is a list of lattice parameters.
- Updated `InterplanarSpacing` to use the `"Space"` option of `GetCrystalMetric`.
- Fixed a bug in `MillerNotationToList`. Numerical entries are now outputted as integers instead of strings.
- Fixed a bug where settings of `"Rotations"` in `EmbedStructure` would not work as expected.
- Very small numbers are no longer written in scientific notation in `ExportCrystalData`.
- Any ion charges are not carried through in the output of `ExportCrystalData`.
- Updated `RelatedFunctionsGraph` to comply with new option names in *Mathematica* version 12.
- Minor documentation updates.
