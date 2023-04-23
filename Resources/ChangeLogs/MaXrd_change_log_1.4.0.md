# Change log

## Version 1.4.0

Release date: 2019-04-02

- Renamed the options `"RandomDistortions"` and `"RandomRotations"` to `"Distortions"` and `"Rotations"`, respectively, in `EmbedStructure` and made them more general by enabling the choice between set values or ranges.
- Added the option `"DistortionType"` which enables the function to interpret the given distortions either as ångströms in a `"Cartesian"` system or as fractions of the host unit cell in a `"Crystallographic"` setting.
- Added the option `"RotationOrder"` which lets the user specify the order of axes to rotate.
