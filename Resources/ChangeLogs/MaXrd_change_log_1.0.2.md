# Change log

## Version 1.0.2

Release date: 2019-01-07

- Fixed a bug where `ReflectionList` and `ReciprocalSpaceSimulation` would not work with crystals that stored wavelength as a `Quantity`.
- Minor updates and changes in the documentation (thanks to Bianca Eifert for pointing out some of them).
- Added some missing auto-complete suggestions for `$CrystalData` (for the second argument).
- Added the option `AngleThreshold` to `BraggAngle` and `ReflectionList` for more efficient filtering by Bragg angle.
