# Change log

## Version 1.3.0

Release date: 2019-03-28

- Updated the example under *Scope* in the `UnitCellTransformation` documentation page to make use of `CrystalPlot`.
- Added `EmbedStructure` to the list in `AutoComplete.nb`.
- Added the option `"Space"` to `GetCrystalMetric` so lattice parameters can be used from either direct or reciprocal space.
- Fixed a bug in `ExportCrystalData[_, _, "DISCUS"]` where the structure size would not be included in the output file.
- Added the possibility to use `EmbedStructure` with list of conditions that dictate where to place embeddings.
- Updated `ExportCrystalData` with the option `"Flag"` which can be set to `"Simple"` (default) or `"Detailed"`.
- Added the Boolean option `"ExpandIntoNegative"` for `ExpandCrystal` which centres the origin at the middle of the new structure. Updated `EmbedStructure` to detect this change.
- Added the option `"TrimBoundary"` to `EmbedStructure` enabling a "trimming" of the structure after embedding.
- Created the option `"RandomDistortions"` for `EmbedCrystal` which can perform a random shift/distortion of units upon embedding.
- Removed `DeleteCrystalData`. Using `KeyDropFrom[$CrystalData, <label_to_delete>]` gives the same result.
- Created the option `"RandomRotations"` for `EmbedCrystal` analogous to `"RandomDistortions"`.
- Minor documentation updates.
- Changed all `Module`s with `Block` in the definitions for better performance.
