#! /bin/bash
# This script compiles all the libraries for OpenCossan in lib/mex/scr/*
#
# created by Edoardo Patelli
# edoardo.patelli@liverpool.ac.uk
# 
#   % =====================================================================
#    % This file is part of OpenCossan.  The open general purpose matlab
#    % toolbox for numerical analysis, risk and uncertainty quantification.
#    %
#    % OpenCossan is free software: you can redistribute it and/or modify
#    % it under the terms of the GNU General Public License as published by
#    % the Free Software Foundation, either version 3 of the License.
#    %
#    % OpenCossan is distributed in the hope that it will be useful,
#    % but WITHOUT ANY WARRANTY; without even the implied warranty of
#    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    % GNU General Public License for more details.
#    %
#    %  You should have received a copy of the GNU General Public License
#    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
#    % =====================================================================

echo "Compiling All the libraries OPENCOSSANPATHin lib/scr/* "
OPENCOSSANPATH=$1;

if [[ -z ${OPENCOSSANPATH//} ]]; then
    echo "* OpenCossan path required. Provide the path as first argument of this script"
else
    echo "* OpenCossan path: " $OPENCOSSANPATH
fi

# define tmp folder
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "** Tmp directory folder: " $DIR

# the temp directory used, within $DIR
TMPDIR=$(mktemp -d -p $DIR)

echo "** Tmp directort:"$TMPDIR

# check if tmp dir was created
if [[ ! "$TMPDIR" || ! -d "$TMPDIR" ]]; then
  echo "Could not create temp dir" $TMPDIR
  exit 1
fi

# Export variables

export TMPDIR;
export CURRENTPATH=`pwd`;
export OPENCOSSANPATH;


# get release, distribution and architecture
KERNEL=`uname`;
case "$KERNEL" in
"Darwin")
RELEASE=`sw_vers -productVersion`; 
DISTRIBUTION=Mac_OS_X;
#DISTRIBUTION=`sw_vers -productName`; # this command return name with spaces
;;
*)
RELEASE=`lsb_release -r | awk '{print $2}'`;
DISTRIBUTION=`lsb_release -i | awk '{print $3}'`;
;;
esac

PROC=`uname -p`;

echo "** Detected distribution: "$DISTRIBUTION "("$RELEASE")";
echo "** Detected architecture: "$PROC;

case "$PROC" in
"i686")
ARCH=glnx86;
;;
"x86_64")
ARCH=glnxa64;
;;
"i386")
ARCH=maci64;
;;
*)
ARCH=glnx86;
;;
esac

export RELEASE
export DISTRIBUTION
export ARCH
export DESTDIR=$OPENCOSSANPATH/lib/dist/$DISTRIBUTION/$RELEASE/$ARCH;
export OPENCOSSANPATH

echo "Destination folder: " $DESTDIR;

echo " Compiling FANN (1/3) "
./makeFann.sh nochecks > log.txt

echo " Compiling SparceMatrixConverter (2/3) "

./makeSparceMatrixConverter.sh nochecks >> log.txt

echo " Compiling COSSAN-X Connector Wrapper (3/3) "

./makeConnectorWrapper.sh nochecks >> log.txt

# Clean up the mess

rm -rf $TMPDIR
export TMPDIR=
export DESTDIR=
export RELEASE=
export DISTRIBUTION=
export ARCH=

# deletes the temp directory
function cleanup {      
  rm -rf "$TMPDIR"
  echo "Deleted temp working directory $TMPDIR"
}

# register the cleanup function to be called on the EXIT signal
trap cleanup EXIT
