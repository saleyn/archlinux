#!/bin/bash -e
# vim:ts=4:sw=4:et

if [ $# -ne 2 ]; then
    echo "This script creates 'package.PKGBUILD.install' post-install script"
    echo "Usage: ${0##*/} PackageName EnvPackageDirName"
    echo
    echo "Example: ${0##*/} mqt-boost-gcc Boost"
    exit 1
fi

TEMPLATE="template.install"

[ ! -f "$TEMPLATE" ] && echo "File '$TEMPLATE' not found!" && exit 1

P=$1
P=${P#mqt-}
P=${P%-*}

PACKAGE=$(echo $P | tr '[:lower:]' '[:upper:]')
package=$(echo $P | tr '[:upper:]' '[:lower:]')
ENV_PACKAGE_DIR=$2

sed -e "s/@PACKAGE@/$PACKAGE/g" \
    -e "s/@package@/$package/g" \
    -e "s/@ENV_PACKAGE_DIR@/$ENV_PACKAGE_DIR/g" \
    $TEMPLATE > pkg/$1.PKGBUILD.install

echo "Created pkg/$1.PKGBUILD.install"
