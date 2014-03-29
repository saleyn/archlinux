## Collection of Archlinux PKGBUILDs ##

The purpose of this repository is to allow building and installing
selected packages on ArchLinux using different toolchains: gcc, clang, intel

### Prerequisites ###

Install ``pacaur`` package manager wrapper around ``pacman``.
Below are the steps to install it:

```
mkdir /tmp/build
cd $_
mkdir cower
pushd $_
wget https://aur.archlinux.org/packages/co/cower/PKGBUILD
makepkg -i --noconfirm
popd
mkdir expac
pushd $_
wget -O PKGBUILD https://projects.archlinux.org/svntogit/packages.git/plain/trunk/PKGBUILD?h=packages/expac
makepkg -i --noconfirm
popd
mkdir pacaur
pushd $_
wget https://aur.archlinux.org/packages/pa/pacaur/PKGBUILD
makepkg -i -s
popd
rm -fr /tmp/build
```

### Binary Packages ###

This repository contains package specs for Archlinux.
For binary packages see: https://github.com/saleyn/archlinux-pkg

### Building / Installing a package ###

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

You can examine the content of manifest and installed packages by running:
```
$ ./install.sh -l
PackageAlias                   EnvDirName      ArchPkgName               InstalledVersion
============                   ==========      ===========               ================
usr/cfengine                                   cfengine                  3.6.0b1-1 
usr/tokyocabinet                               tokyocabinet              1.4.48-1 
aur/double-conversion                          double-conversion         2.0.1-1 
aur/google-gflags                              google-gflags             2.0-2 
aur/msgpack                                    msgpack                   0.5.8-1 
aur/libodb                                     libodb                    2.3.0-1 
aur/libcutl                                    libcutl                   1.8.0-1 
aur/libodb-mysql                               libodb-mysql              2.3.0-1 
mqt-boost                      Boost           mqt-boost-gcc             1.55.0-4 
mqt-thrift                     Thrift          mqt-thrift-gcc            0.9.1-1 
mqt-folly                      Folly           mqt-folly-gcc             657.d9c79af-1 
mqt-utxx                       utxx            mqt-utxx-gcc              1.1-1 
mqt-armadillo                  Armadillo       mqt-armadillo-gcc         4.100.2-1 
mqt-libodb-boost               ODB             mqt-libodb-boost-gcc      2.3.0-1 
mqt-zeromq                     ZeroMQ          mqt-zeromq-gcc            4.0.4-1 
usr/scribe                                     scribe-git-gcc            122.4452362-1 
```
The entries are listed in the installation order, and can be of the following naming
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

### FAQ ###

Q. Where are my packages being built?

A. The packages are built in the ``build/PackageName`` directory, which is not part
   of the git tree. After a package is installed, you can clear the content of that
   directory by running ``./install.sh -c PackageName``.

Q. Which toolchains are supported?

A. You can pass one of the following toolchains to the ``install.sh`` script via
   ``-t`` option: ``gcc, clang, intel``.

### License ###

This project is licensed under BSD Open Source license

### Author ###

Serge Aleynikov
