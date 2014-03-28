## Collection of Archlinux PKGBUILDs ##

### Binary Packages ###

See: https://github.com/saleyn/archlinux-pkg

### Building ###

In order to build a package ``mqt-boost-gcc``, run the following command:

```
$ ./install.sh -p mqt-boost
```

In order to build and install it, run:
```
$ ./install.sh -i -p mqt-boost
```

If you need to build a package using a different toolchain
(e.g. intel or clang) provide corresponding package suffix:
```
$ ./install.sh -i -p mqt-boost-clang
```

### Creating a new package spec ###

There are two types of packages maintained here:

1. Those packages that are installed in /usr/lib
   (Maintained under ``pkg/usr/*.PKGBUILD``).
   Note that before adding a package spec here, make sure that PKGBUILD
   for this package doesn't already exist in https://aur.archlinux.org/packages
   We recommend installing ``pacaur`` package manager wrapper around
   ``pacman`` that's found here: https://aur.archlinux.org/packages.php?ID=49145.
   If it does exist in the AUR repository, then all you need is to add the
   package name in the form ``aur/PackageName`` to the Manifest file.

2. Those packages that are installed in /opt/pkg
   (Maintained under ``pkg/mqt-*.PKGBUILD``)

Creating a package requires to:

* Create a package spec in the form ``[mqt-]PackageName.PKGBUILD``
* Validate the package spec file by running:
  ``$ ./install.sh -s mqt-PackageName``
* By default post-installation involves running a script derived
  from ``util/template.install``. This script creates appropriate links
  in the ``/opt/env/prod`` directory. If the default behavior is not
  sufficient, for custom post-installation create a script
  ``pkg/mqt-PackageName.install`` by running:
  ``$ util/gen-install.sh [mqt-]PackageName EnvDirName``, where
  ``EnvDirName`` is the name used in ``/opt/env/prod/EnvDirName``.
  The name of this post-installation script is referenced in the PKGBUILD
  by the ``install=[mqt-]PackageName.install`` assignment.
* Add the package name to the ``Manifest``. The manifest lists packages
  in the order of installation.

### Manifest File ###

The ``Manifest`` file is used to provide the ``install.sh`` package build
manager with information about which packages are available for installation.

The entries are in the installation order, and can be of the following naming
convention:

1. ``aur/PackageName`` - package spec to be found in the AUR arch repository
                         (installed in the default system location ``/usr``).
2. ``usr/PackageName`` - package spec found in the ``pkg/usr/PackageName`` directory
                         (installed in the default system location ``/usr``).
3. ``mqt-PackageName`` - package spec found in the ``pkg/mqt-PackageName`` location
                         (installed in the custom location ``/opt/pkg/PackageName``).

The last category of packages is represented in the ``Manifest`` by two
fields:

* PackageName - name of the package
* EnvDirName  - subdirectory name under ``/opt/env/prod`` that will be used to
                link to the corresponding package installation location under
                ``/opt/pkg``.

### License ###

This project is licensed under BSD Open Source license

### Author ###

Serge Aleynikov
