# Change log

## Version 2.4.0

Release date: 2020-09-03

### Improvements to `SynthesiseStructure`

- Creating single element (or void) unit cells now possible with `SynthesiseStructure[<chemical symbol>, _, _]`.
- Added `"Shuffled"` as a possible setting to the `"SelectionMethod"` option in `SynthesiseStructure`.
- Added Boolean option `"Padding"` to `SynthesiseStructure` which utilises the `InputCheck["PadDomain", _, _]` snippet.
- Refactored `SynthesiseStructure`; when inputting a list of entities, an appropriate domain representation will be created and relayed to the function expecting a domain signature.
- `"UsePlacementBuffer"` option of `SynthesiseStructure` deprecated; `"Padding"` will now be used instead.
- If a domain is not covered in the mapping from integers to entities in `SynthesiseStructure`, empty cells will now be used instead of throwing an error.

### Improvements to `EmbedStructure`

- Enabled the possibility to embed in void (message `EmbedStructure::VoidHost` removed).

### Improvements to space group database

- Removed entries such as `HermannMauguinFullAlt` in space groups with multiple origins.
- For rhombohedral space groups, the note specifying obverse setting was moved to the alternative settings section.
- Regenerated `$GroupSymbolRedirect`.
- Minor error corrections.

### New `InputCheck` snippets

- Added snippet `InputCheck["GenerateTargetPositions", _]` (currently used in `ConstructDomains`, `DomainPlot`, `EmbedStructure`, `ExpandCrystal` and `SynthesiseStructure`).
- Added snippet `InputCheck["PadDomain", _, _]`.
- Added snippets `InputCheck["ShallowDisplayCrystal", _]` (employed in: `ImportCrystalData`, `UnitCellTransformation`).
- Added snippets `InputCheck["FilterSpecialLabels", _]` and `InputCheck["HandleSpecialLabels", _]` for processing chemical element symbols and `"Void"`.
- Added snippet `InputCheck["CrystalEntityQ", _]`.

### Miscellaneous

- Added the option `ImageDimensions` to `SimulateDiffractionPattern` for specifying the width and height of the produced image (`ExportCrystalData` and `InputCheck["GetReciprocalImageOrientation", __]` also updated to comply with this change).
- Appended a missing `_alt` to the CIF definition `_space_group_name_H-M` in the list of space group search keys in `ImportCrystalData`.
- Fixed errors in the `$GroupSymbolRedirect` data file (thanks to Tobias Hadamek for finding this).
- `ImportCrystalData` now takes away tildes (`~`) if they are present in the chemical formulas.
- Fixed a bug where `GetScatteringCrossSections` would not work on Windows due to different line break implementations (thanks to Tobias Hadamek for discovering this).
- An error is now given when attempting to use a chemical symbol or `"Void"` for the name a crystal to be imported from a `cif` file through `ImportCrystalData`.
- `CrystalPlot` will now plot empty structures without errors.
- Demo file `DemoBlocksAB.m` removed (these structures will now be generated on demand).
- Updated code part B.2 in `InputCheck["InterpretSpaceGroup", __]` to find origin choice automatically.
