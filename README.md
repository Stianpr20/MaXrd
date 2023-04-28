# MaXrd — Mathematica X-ray diffraction package

Symmetry data and utilities related to crystallography and X-ray scattering.

## Main functionality

- Contains essential symmetry information on the 32 point groups and 230 space groups (with alternative settings) from the [International Tables for Crystallography](https://it.iucr.org/A/), along with convenient API.
- Robust importation of data from CIF files and a simple three-dimensional visualizer function.
- Basic functions for calculating/extracting quantities such as: attenuation coefficients, metrics for direct and reciprocal space, symmetry equivalent positions/reflections, mass densities, inter-planar spacings, structure factors, formula units.
- Tools for constructing and manipulating crystal units—from atom level to domain level— specifically aimed for modelling inclusion compounds.
- Simple, auxiliary tools for analysing diffraction patterns (see `ReciprocalSpaceSimulation` and `ReciprocalImageCheck`).

**Import crystal data**

<img align="left" width="125" style="padding:10px" src="./Resources/Icons/icon1.png"/>

Core crystallographic information can be be read from `cif` files using `ImportCrystalData`.
Data will persist in the local `$UserBaseDirectory`, readily accessible with `$CrystalData`.
The simple but convenient function `CrystalPlot` can visualise the structure.
<br> <br> <br>

**Symmetry generation**

<img align="left" width="125" style="padding:10px" src="./Resources/Icons/icon2.png"/>

Symmetry-related functions can be used for basic operations on reflections and positions, and also to grow the asymmetric unit into an arbitrary large structure.
Essentials of the _International Tables, vol. A_ are stored in `$SpaceGroups`.
There is also `UnitCellTransformation` for changing between equivalent cell descriptions.
<br> <br>

**Structure customisation**

<img align="left" width="125" style="padding:10px" src="./Resources/Icons/icon3.png"/>

Written with inclusion compounds in mind, `EmbedStructure` is ideal for merging guest entities with a host structure at random, sequential or conditional positions.
Rotations and/or translations can be executed prior to placement with the same freedom.
The user can also specify a displacement field to shift everything by a relative amount with `DistortStructure`.
<br> <br>

**Synthesis and simulation**

<img align="left" width="125" style="padding:10px" src="./Resources/Icons/icon6.png"/>

Structural pieces can be sewn together automatically with `SynthesiseStructure`, which is particularly useful when working with multiple domains.
When the model is complete, `SimulateDiffractionPattern` can be applied to render images through [DISCUS](https://github.com/tproffen/DiffuseCode) or [DIFFUSE](http://scripts.iucr.org/cgi-bin/paper?S1600576717015023).
<br> <br> <br>

## Getting started

### Installation

Download the latest paclet file and install it, or install from the web directly.
From the [Wolfram Language Paclet Repository](https://resources.wolframcloud.com/PacletRepository/resources/StianRamsnes/MaXrd/):

```Mathematica
PacletInstall["StianRamsnes/MaXrd"]
```

From this GitHub repository:

```Mathematica
PacletInstall["https://github.com/Stianpr20/MaXrd/releases/download/4.0.0/MaXrd-4.0.0.paclet"]
```

### Usage

Load the package with:

```Mathematica
Needs["StianRamsnes`MaXrd`"]
```

It may be helpful to browse the documentation on the Paclet Repository page or check out [this post in the Wolfram Community](https://community.wolfram.com/groups/-/m/t/2825040) for an introductory overview.
(The notebook from the community post is also found [in this repository](https://github.com/Stianpr20/MaXrd/blob/master/Resources/MaXrd_demo_2023.nb).)

## Details

### Versions

The latest version of MaXrd is 4.0.0, which is compatible with Mathematica version 13.0.1 and above. Change logs are found in the Resources directory. Overview of which versions of Mathematica was used to build MaXrd:

| MaXrd       | Mathematica |
|-------------|-------------|
| 1.0.0–2.1.0 | 11.3.0+     |
| 2.2.0–2.5.0 | 12.1+       |
| 3.0.0+      | 13.0.1+     |

### Misc

In addition to data from the [International Tables for Crystallography](https://it.iucr.org/A/), the package comprises scattering factors from XOP and cross sections from [xraylib](https://github.com/tschoonj/xraylib), and atomic scattering factors (along with corrections) from miscellaneous sources (see `GetAtomicScatteringFactors`).

The documentation includes plentiful of examples, details and options. It may be a helpful supplement in research and teaching where crystallography and X-ray diffraction are essential.

### Publications

The article **Using _Mathematica_ as a platform for crystallographic computing** was published in the Journal of Applied Crystallography in February 2019 ([Ramsnes, S., Larsen, H. B. & Thorkildsen, G. (2019). J. Appl. Cryst. 52, 214–218](https://doi.org/10.1107/S1600576718018071)).
In 2020, an update article **_MaXrd_ updated with emphasis on model construction and reciprocal-space simulations** ([Ramsnes, S. P., Larsen, H. B. & Thorkildsen, G. (2020). J. Appl. Cryst. 53, 1620–1624](https://doi.org/10.1107/S160057672001328X)) was published in the same journal.

The author's PhD thesis from 2022, [**Direct- and reciprocal space structure modelling: Contributions to the advanced understanding of inclusion compounds**](https://hdl.handle.net/11250/2995486), describes much of the capabilities in great detail from a research perspective.

## Contact

Any comments or feedback are welcome. Submit an [issue](https://github.com/Stianpr20/MaXrd/issues) in the repository.
