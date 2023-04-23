# Change log

## Version 2.1.1

Release date: 2020-01-17

- Added more examples to the `SimulateDiffractionPattern` documentation page.
- When specifying a probability distribution of entities with `EmbedStructure`, the procedure now more closely fulfils that distribution instead of using `RandomChoice`.
- Updated `ImportCrystalData` to use the data file in the `UserData` directory by default (changed the `"DataFile"` option).
- Added `"DataFile"` option to `EmbedStructure` and `ExpandCrystal`.
- Factorised data file operations for `ImportCrystalData`, `EmbedStructure` and `ExpandCrystal` into a `InputCheck` snippet with label `"Update$CrystalDataFile"`.
- Minor updates in the documentation (`SimulateDiffractionPattern`, `EmbedStructure`) and in the package unit test.
