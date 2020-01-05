# _MaXrd_: Mathematica X-ray diffraction package
A comprehensive _Mathematica_ package for crystallographic computations, `MaXrd`, has been developed. It comprises space group representations based on _International Tables for Crystallography_, volume A together with scattering factors from _XOP_ and cross sections from [_xraylib_](https://github.com/tschoonj/xraylib).
Featured functionalities include calculation of structure factors, linear absorption coefficients and crystallographic transformations. The crystal data used by `MaXrd` is normally generated from external _cif_ files.

The package comes with a dynamic documentation seamlessly integrated with the _Mathematica_ system, including code, examples, details and options. From the onset, minimal _Mathematica_ experience is required to make use of the package. It may be a helpful supplement in research and teaching where crystallography and X-ray diffraction are essential. Although _Mathematica_ is a proprietary software, all the code of this package is open source. It may easily be extended to cover user-specific applications.

The article **Using _Mathematica_ as a platform for crystallographic computing** was published in the Journal of Applied Crystallography in February 2019 ([Ramsnes, S., Larsen, H. B. & Thorkildsen, G. (2019). J. Appl. Cryst. 52, 214–218](https://doi.org/10.1107/S1600576718018071)).


## Getting started

### Download
Clone or download the repository if you want to develop on the package.

If you want to use the package, download the latest (or desired) [release](https://github.com/Stianpr20/MaXrd/releases) (`MaXrd_<version>.zip`).

The latest version of _MaXrd_ is 2.0.0 which is compatible with _Mathematica_ version 11.3 and above.

### Installation
In the file menu in _Mathematica_, select `File -> Install...`. In the pop-up window select _Application_ as the type of item to install and _From File ..._ as the source. Select the downloaded zip file and click on OK. Wait for the extraction of files to be completed and restart _Mathematica_.

### Using _MaXrd_
Load the package with:
> << MaXrd`

If you want _MaXrd_ to launch automatically on startup, first open the _Wolfram Language Documentation Center_. This can be done from the file menu: `Help -> Wolfram Documentation`. Scroll to the bottom and click on _Add-ons and Packages_. Click on the disclosure triangle next to _MaXrd_ to open the cell and then the same for _Manage_. Make sure the option _Startup_ is selected.

To access the package documentation, open the _Wolfram Documentation_ in _Mathematica_ after installing it and search for «MaXrd» or any related content.

## Contact
Any comments or feedback is welcome. E-mail stian.p.ramsnes@uis.no or submit an [issue](https://github.com/Stianpr20/MaXrd/issues) in the repository.