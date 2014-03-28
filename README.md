## Collection of Archlinux PKGBUILDs ##

### Binary Packages ###

See: https://github.com/saleyn/archlinux-pkg

### Building ###

In order to build a package ``mqt-boost-gcc``, run the following command:

```
$ ./install.sh -p mqt-boost-gcc
```

In order to build and install it, run:
```
$ ./install.sh -i -p mqt-boost-gcc
```

### Creating a new package spec ###

There are two types of packages maintained here:

1. Those packages that are installed in /usr/lib
   (Maintained under ``pkg/usr/*.PKGBUILD``)

2. Those packages that are installed in /opt/pkg
   (Maintained under ``pkg/mqt-*-gcc.PKGBUILD``)

Creating a package requires to:

* Create a package spec in the form ``[mqt-]PackageName-ToolChain.PKGBUILD``
* For custom post-installation create a script
  ``[mqt-]PackageName-ToolChain.install``
  This script can be created by running:
  ``$ ./gen-install.sh [mqt-]PackageName-ToolChain``
  Once created, it can be referenced in the PKGBUILD script by
  ``install=[mqt-]PackageName-ToolChain.install`` assignment
* Add the package name to the ``Manifest``. The manifest lists packages
   in the order of installation

### License ###

This project is licensed under BSD Open Source license

### Author ###

Serge Aleynikov


