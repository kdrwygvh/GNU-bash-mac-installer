#!/bin/bash

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

pkgname="GNU-bash"
version="5.0"
identifier="org.gnu.bash"
install_location="/usr/local"

projectdir=$(dirname "$0")

# remove '.' from the path
projectdir=$(python -c "import os; print(os.path.realpath('${projectdir}'))")

builddir="$projectdir/build"

if [[ ! -d "$builddir" ]]; then
    mkdir -p "$builddir"
fi

bashname="bash-${version}"
archivename="${bashname}.tar.gz"
archivepath="${builddir}/${archivename}"
url="ftp://ftp.gnu.org/gnu/bash/${archivename}"

# download the archive
echo "downloading $bashname"

if [[ ! -f "${archivepath}" ]]; then
    curl "$url" -o "${archivepath}"

    if [[ $? -ne 0 ]]; then
        echo "could not download ${url}"
        exit 1
    fi
fi

# unwrap the archive
echo "extracting ${archivepath}"
tar -xzvf "${archivepath}" -C "${builddir}"

if [[ $? -ne 0 ]]; then
    echo "could not untar ${archivename}"
    exit 1
fi

sourcedir="${builddir}/$bashname"

if [[ ! -d "$sourcedir" ]]; then
    echo "couldn't find $sourcedir"
    exit 1
fi

payloaddir="${builddir}/payload"
mkdir -p "$payloaddir"

# configure
cd "$sourcedir"
"$sourcedir/configure" --srcdir="$sourcedir" --prefix="$payloaddir"

# build
make install

# rename the bash binary to bash4 or bash5
majorversion="${version:0:1}"
mv "${payloaddir}/bin/bash" "${payloaddir}/bin/bash${majorversion}"

# build the pkg
pkgpath="${projectdir}/${pkgname}-${version}.pkg"

pkgbuild --root "${payloaddir}" \
         --identifier "${identifier}" \
         --version "${version}" \
         --scripts "${projectdir}/scripts" \
         --install-location "${install_location}" \
         "${pkgpath}"