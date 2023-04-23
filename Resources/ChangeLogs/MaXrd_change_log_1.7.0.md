# Change log

## Version 1.7.0

Release date: 2019-08-08

### New content

- Created the function `SynthesiseStructure`.
- Added the snippet `"Update$CrystalDataAutoCompletion"` to `InputCheck` and factorised functions that update `$CrystalData` to use this (`DistortStructure`, `EmbedStructure`, `ExpandCrystal` and `ImportCrystalData`).

### Improvements to `EmbedStructure`

- Option `"ShowProgress"` added to `EmbedStructure`.
- `EmbedStructure` is now capable of dealing with overlapping atoms (new options: `"OverlapPrecedence"` and `"OverlapRadius"`).
- `EmbedStructure` parameter identifiers *source* and *target* were renamed to *guest* and *host*, respectively, to avoid confusion.
- `EmbedStructure` now mutates the *hostCrystal* by default (and uses a new option `"NewLabel"` to create new crystal objects) to be more aligned with the usage of similar functions.

### Miscellaneous

- `$MaXrdChangelog` updated to handle headings/subsections in this changelog.
- `$MaXrdPath` updated to prioritise the standard location of packages in *Mathematica* (`.../Mathematica/Applications/`), as it can find the developing directory as well.
- Minor documentation updates.
