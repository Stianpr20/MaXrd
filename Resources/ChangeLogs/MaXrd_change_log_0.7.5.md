
# Change log

## Version 0.7.5

- Changelog started.
- Documentation on `SystematicAbsentQ` fixed.
- Several functions belonging to the context `Crystallography` have been ascribed the new context `Physics`.
- `$PhysicalConstants` created.
- Wrong coefficients in `$ScatteringFactors` were corrected (At, Be, C, Ho, Ni, Tm, Zn).
- The space groups of `Silicon`, `Germanium` and `Diamond` are now set to use the alternative origin in `$CrystalData`.
- Added new alternative space group entries to `$SpaceGroups` (B1, C1, F1, I1, P1, A-1, B-1, C-1, F-1, I-1). `$XrayRedirect` was also updated.
- `SymmetryOperations` in `$SpaceGroups` have been flattened to a plain list structure.
- The following new functions were created: `InputCheck`, `LaueClass`.
- `StructureFactorTable` now sorts by decreasing structure factor by default.
- `ReflectionList` now sorts reflections from least to highest digit sum (ignoring sign), and has been extended with a `Keep` option.
- Added the option `ReflectionListKeep` to `StructureFactorTable`.
- Updated the documentation on `StructureFactor` and `StructureFactorTable`.
- Minor bug fixes.
