# Mathematica X-ray Diffraction Package
A comprehensive _Mathematica_ package for crystallographic computations, `MaXrd`, has been developed. It comprises space group representations based on _International Tables for Crystallography_, volume A together with scattering factors from _XOP_ and cross sections from [_xraylib_](https://github.com/tschoonj/xraylib).
Featured functionalities include calculation of structure factors, linear absorption coefficients and crystallographic transformations. The crystal data used by `MaXrd` is normally generated from external _cif_ files.

The package comes with a dynamic documentation seamlessly integrated with the _Mathematica_ system, including code, examples, details and options. From the onset, minimal _Mathematica_ experience is required to make use of the package. It may be a helpful supplement in research and teaching where crystallography and X-ray diffraction are essential. Although _Mathematica_ is a proprietary software, all the code of this package is open source. It may easily be extended to cover user-specific applications.


## Documentation
To access the package documentation, open the _Wolfram Documentation_ in _Mathematica_ after installing it and search for «MaXrd» or any related content.


## Download and installation
Clone or download the repository if you want to develop on the package.

If you want to use the package, download the latest (or desired) [release](https://github.com/Stianpr20/MaXrd/releases) and unzip it.
Place _MaXrd_ in a relevant _Mathematica_ directory, I suggest `$UserBaseDirectory/Applications`.
This path is on the form:

> `~/Library/Mathematica/Applications` (macOS)

> `C:\Users\<Username>\AppData\Roaming\Mathematica\Applications` (Windows)

Restart _Mathematica_ and load the package with
> << MaXrd`

The copying may alternatively be done automatically using `Installation.nb` located in the package directory. Open the notebook in _Mathmatica_ and follow the instructions. 

## Contact
Any comments or feedback is welcome. E-mail stian.p.ramsnes@uis.no or submit an [issue](https://github.com/Stianpr20/MaXrd/issues) in the repository.