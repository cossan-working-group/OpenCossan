#! /bin/bash
# script to run all the tutorials
# created by EP

rm ReportTutorial.txt;

CURRENTPATH=`pwd`;

RELEASE=`lsb_release -r | awk '{print $2}'`;

DISTIBRUTION=`lsb_release -i | awk '{print $3}'`;

PROC=`uname -p`;

# echo $ARCH;

# echo $PROC;

case "$PROC" in
"i686")
ARCH=glnx86;
;;
"x86_64")
ARCH=glnxa64;
;;
*)
ARCH=glnx86;
;;
esac

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CURRENTPATH/../../../OpenSourceSoftware/dist/$DISTIBRUTION/$RELEASE/$ARCH/lib;
export LD_LIBRARY_PATH;

/usr/site/matlab/R2010b/bin/matlab -nosplash < runAllTutorials.m 
./sendmail.sh Mechanik@uibk.ac.at Barbara.Goller@uibk.ac.at uibk.ac.at localhost ReportTutorials.txt "COSSAN-X: Report Tutorials"
./sendmail.sh Mechanik@uibk.ac.at Murat.Panayirci@uibk.ac.at uibk.ac.at localhost ReportTutorials.txt "COSSAN-X: Report Tutorials"
./sendmail.sh Mechanik@uibk.ac.at Matteo.Broggi@uibk.ac.at uibk.ac.at localhost ReportTutorials.txt "COSSAN-X: Report Tutorials"
./sendmail.sh Mechanik@uibk.ac.at Pierre.Beaurepaire@uibk.ac.at uibk.ac.at localhost ReportTutorials.txt "COSSAN-X: Report Tutorials"
./sendmail.sh Mechanik@uibk.ac.at Edoardo.Patelli@uibk.ac.at uibk.ac.at localhost ReportTutorials.txt "COSSAN-X: Report Tutorials"
