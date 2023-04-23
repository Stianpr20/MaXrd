# Change log

## Version 4.0.0

Release date: 2023-XX-YY

- Converted paclet context with publisher ID to conform to Paclet Repository structure.
- Changed structure of optional second argument of `SymmetryEquivalentPositions` and `ExpandCrystal`.
- Fixed a string concatenation bug in `UnitCellTransformation`.
- Changed some local variable names to avoid confusion.
- Renamed various error message names and local variables to longer, more understandable names.
- Now using a `MaXrd.wl` file in stead of `Definitions.nb` master notebook, and each function is defined in its designated file.
- Renamed option `"ExtractSubdata"` to `"ExtractSubData"` of `ImportCrystalData`.
- Minor bug fixes.
