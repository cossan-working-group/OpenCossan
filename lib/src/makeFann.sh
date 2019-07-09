#! /bin/bash
# script to compile FANN
# created by Edoardo Patelli
# updated by Matteo Broggi - FANN 2.2.0
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
#
# Temporary directory from compileAll.sh ($TMPDIR)

echo "*** MakeFann.sh " 
echo "**** OpenCossan path:  " $OPENCOSSANPATH

# check if cmake is installed and available
command -v cmake >/dev/null 2>&1 || { echo "cmake is required to compile FANN 2.2.0. Aborting compilation. Bye!" >&2; exit 1; }
NOCHECKS=$1;

if [ "$NOCHECKS" != "nochecks" ]; then

        echo "FANN will be installed in the folder :" $DESTDIR;

        echo "Is it corrected? [Y/N]"

        read -e CHECK

        if [ $CHECK != "Y" ]; then 
                echo "bye !"
                exit     
        fi
fi

# move to tmp
        
unzip $OPENCOSSANPATH/lib/src/FANN-2.2.0-Source.zip -d $TMPDIR

# go to fann-2.2.0
cd $TMPDIR/FANN-2.2.0-Source
#cmake always uses the variable DESTDIR by default and appends CMAKE_INSTALL_PREFIX to it. By default it is set to /usr/local
cmake . -DCMAKE_INSTALL_PREFIX= 

make

make install

# return to the root
cd ..

rm $TMPDIR/FANN-2.2.0-Source -R

# return to the previous folder  
cd  $CURRENTPATH

echo "FANN installed on:" $DESTDIR;
echo "bye bye!"
