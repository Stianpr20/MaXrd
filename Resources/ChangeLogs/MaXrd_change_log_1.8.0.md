# Change log

## Version 1.8.0

Release date: 2019-10-15

### New content

- Created the function `ConstructDomains`.
- Created the function `DomainPlot`.
- `InputCheck` updated with a `"DomainRotation"` and a `"GetCrystalFamilyMetric"` label.

### Improvements to `EmbedStructure`

- If conditional placement is used with `EmbedStructure` and a given coordinate tuple falls through without any match, nothing is inserted here (used to insert last entry in `guestUnits`).
- Fixed a bug with `EmbedStructure` where using `"Rotations"` did not assume numbers in degrees.
- Message is no longer given if conditions or random selections are such that nothing is embedded (`EmbedStructure::OnlyVoid`).
- A host structure is now considered to be placed in positive coordinates as long as no coordinates are below `-1.0` in any direction.
- `EmbedStructure` now updates the `"StructureSize"` of the resulting structure.

### Miscellaneous

- `SynthesiseStructure` now also supports the `"RotationMap"` and `"RotationPoint"` options akin to `DomainPlot`. Documentation page updated.
- Second argument of `ExpandCrystal` changed to `structureSize_List: {1, 1, 1}`.
- `ExportCrystalData`: Change third argument `format_String` to `format_String: "DISCUS"` (default value).
