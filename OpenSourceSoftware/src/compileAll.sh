#! /bin/bash
# script to compile ALL
# created by Edoardo Patelli
# edoardo.patelli@liverpool.ac.uk
# 
#   % =====================================================================
#    % This file is part of openCOSSAN.  The open general purpose matlab
#    % toolbox for numerical analysis, risk and uncertainty quantification.
#    %
#    % openCOSSAN is free software: you can redistribute it and/or modify
#    % it under the terms of the GNU General Public License as published by
#    % the Free Software Foundation, either version 3 of the License.
#    %
#    % openCOSSAN is distributed in the hope that it will be useful,
#    % but WITHOUT ANY WARRANTY; without even the implied warranty of
#    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    % GNU General Public License for more details.
#    %
#    %  You should have received a copy of the GNU General Public License
#    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
#    % =====================================================================

# define tmp folder
export TMPDIR=/var/tmp/COSSAN;
export CURRENTPATH=`pwd`;
mkdir $TMPDIR

# mcc path should be in the path
# MCC=/usr/software/MATLAB/R2014a/bin/mcc

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

echo "Detected distribution: " $DISTRIBUTION "("$RELEASE")";
echo "Detected architecture: "$PROC;

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

export DESTDIR=$CURRENTPATH/../dist/$DISTRIBUTION/$RELEASE/$ARCH;

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
