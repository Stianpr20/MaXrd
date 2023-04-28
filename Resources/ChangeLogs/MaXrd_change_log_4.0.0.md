# Change log

## Version 4.0.0

Release date: 2023-04-29

### Structural changes

- Point- and space group data have been distributed to single files for each group.
- Fractions that are added/subtracted with placeholder string symbols in `$SpaceGroups` are now operated on explicitly with the `Plus`/`Subtract` functions instead of the `+`/`-` operator in order to clear associated suggestion from the Wolfram linting, e.g., `1/2 + "x"` is replaced by `Plus[1/2, "x"]`.
- Placeholder symbols in `$SpaceGroups` and `$TransformationMatrices`(`a`, `b`, `c`, `h`, `k`, `l`) are now stored as strings to avoid explicitly setting the context to ``Global` ``.
- Now using a `MaXrd.wl` file in stead of `Definitions.nb` master notebook, and each function is defined in its designated file.
- Converted paclet context with publisher ID to conform to Paclet Repository structure.

### Miscellaneous

- For `FindPixelClusters`, changed the default setting of `"PixelDataFile"` to `FileNameJoin[{$MaXrdPath, "Kernel", "Data", "UserData", "PixelData.m"}]`.
- Changed structure of optional second argument of `SymmetryEquivalentPositions` and `ExpandCrystal`.
- For `ImportCrystalData`, renamed option `"ExtractSubdata"` to `"ExtractSubData"`.
- Fixed a string concatenation bug in `UnitCellTransformation`.
- Changed some local variable names to avoid confusion.
- Renamed various error message names and local variables to longer, more understandable names.
- Minor bug fixes and typo corrections.
