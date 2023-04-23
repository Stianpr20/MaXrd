
# Change log

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
