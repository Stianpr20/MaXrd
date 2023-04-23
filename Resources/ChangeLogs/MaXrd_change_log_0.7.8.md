
# Change log

## Version 0.7.8

- Minor bug fixes and updated in the documentation.
- It is now possible to set values for the cutoff intensity and group width in `ReflectionSetInspection`.
- Updated `ToMiller` to return output with commas if any index is not an integer.
- New function added to the `Statistics` context: `NonlinearLeastSquares`.
- Fixed an error with `StructureFactor` causing it to not accept wavelength input.
- `AddCompoundToDataset` now adds the site symmetry order for each atom to `$CrystalData`.
- Updates on `StructureFactor` (handles occupation factor and site symmetry differently).
- Updated some functions to also use `InputCheck` for crystal names.
