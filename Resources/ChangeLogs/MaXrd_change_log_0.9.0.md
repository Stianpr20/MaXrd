
# Change log

## Version 0.9

- Refactored some code in `ImportCrystalData`; updated documentation.
- `GetAtomicScatteringFactor` restructured so to better handle crystal label with reflections input and element(s) with *sinlam* input.
- `InputCheck` procedures with *ProcessWavelength*, *GetCrystalWavelength* and *GetEnergyWavelength* were updated to let *-1* pass through without aborting evaluation.
- `ImportCrystalData` returns a message (but does not abort) if *neutron* radiation type is detected in .cif file.
- `InputCheck` with label *InterpretElement* now replaces *D* (deuterium) with *H*.
- Added the Hall symbol *-B 2ydav* to the space group *B 21/d*.
- Adding crystal data manually in dialogue windows is now possible with `ImportCrystalData`.
- Completed tutorials.
- Added the option *IgnoreHydrogen* to `CrystalFormulaUnits`.
- `$XrayChangelog` file is now formatted in Markdown language.
- `ImportCrystalData` now also counts the number of *atom_site_fract*_ to verify subdata length.
- Detailed information on how *f0* and *f1f2* data files were restructured for this package is now available in the tutorial page *Applying crystal data*.
- `GetAtomicScatteringFactor` now checks for source specific *sin(theta)/lambda* limits.
