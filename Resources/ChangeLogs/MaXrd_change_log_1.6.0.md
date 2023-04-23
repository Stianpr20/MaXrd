# Change log

## Version 1.6.0

Release date: 2019-06-14

- `DISCUSPlot` now prints error messages from *DISCUS* if there are any (new option: `DISCUSPrint`).
- Improved structure size recognition for `DISCUSPlot`.
- `EmbedStructure` now recognises symbols of the chemical elements; single atoms of the given type will be used.
- Entries (keys) in `$CrystalData` are now sorted alphabetically after using `EmbedStructure` and `ExpandCrystal`.
- Fixed a bug where `ImportCrystalData` would not save manually created crystal entries.
- `ExportCrystalData` updated to use ADP value of zero if no such data is available.
- Created the function `DistortStructure`.
- Minor documentation updates.
