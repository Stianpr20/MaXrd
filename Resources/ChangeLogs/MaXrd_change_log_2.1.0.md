# Change log

## Version 2.1.0

Release date: 2020-01-12

### New content

- Added the option `"IncludeStructureSizeInfo"` to `ExportCrystalData`.
- Added the option `"ScalingFactor"` to `SimulateDiffractionPattern`.

### Improvements and fixes

- Fixed a bug in `SimulateDiffractionPattern` where the use of *DISCUS* would not work correctly.
- Created a `UserData` directory in the package root and moved `CrystalData.m` here. `$CrystalData` and `ResetCrystalData` updated to conform with this change.
- `ImportCrystalData` now returns instead of aborting if user cancels import.
- Improved the package unit test.
- `$MaXrdPath` updated with support for *Windows*.
- Minor documentation updates.
