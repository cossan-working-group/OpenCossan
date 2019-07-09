#!/bin/sh
# script for remote execution of Injector and Extractor
# Author: MB
#
# Sets up the MCR environment for the current $ARCH
# Copy the compiled Connector for the current $ARCH
# Executes the connector
#
CURRENTPATH=`pwd`;
PROC=`uname -p`;
OPENSOURCESOFTWARE="$1"
exe_name=$0
exe_dir=`dirname "$0"`
# get release, distribution and architecture
RELEASE=`lsb_release -r | awk '{print $2}'`;
DISTIBRUTION=`lsb_release -i | awk '{print $3}'`;
PROC=`uname -p`;
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

BINDIR=$OPENSOURCESOFTWARE/dist/$DISTIBRUTION/$RELEASE/$ARCH/bin

echo "------------------------------------------"
if [ "x$1" = "x" ]; then
  echo Usage:
  echo    $0 \<COSSANroot>\ \<deployedMCRroot\> 
else
  # check that the compiled ConnectorWrapper exists for the running machine
#  if [ ! -e $BINDIR/ConnectorWrapper ]
#  then
#    echo "Compiled ConnectorWrapper not available for the host."
#    echo "The ConnectorWrapper will be compiled"
#    cd $COSSANROOT/../OpenSourceSoftware/src
#    ./makeConnectorWrapper.sh nochecks
#    cd $CURRENTPATH
#  fi
  echo Setting up environment variables     
  MCRROOT="$2"
  case "$PROC" in
    "x86_64")
    echo ---
    LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64 ;
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;
	  MCRJRE=${MCRROOT}/sys/java/jre/glnxa64/jre/lib/amd64 ;
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/native_threads ; 
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/server ;
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/client ;
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE} ;  
    XAPPLRESDIR=${MCRROOT}/X11/app-defaults ;
    export LD_LIBRARY_PATH;
    export XAPPLRESDIR;
    echo LD_LIBRARY_PATH is ${LD_LIBRARY_PATH};
    echo Copying compiled Connector wrapper, 64-bit linux
    echo cp "$BINDIR"/ConnectorWrapper "${exe_dir}"
    cp "$BINDIR"/ConnectorWrapper "${exe_dir}"
  ;;
  "i686")
    echo ---
    LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnx86 ;
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnx86 ;
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnx86;
	  MCRJRE=${MCRROOT}/sys/java/jre/glnx86/jre/lib/i386 ;
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/native_threads ; 
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/server ;
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/client ;
	  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE} ;  
    XAPPLRESDIR=${MCRROOT}/X11/app-defaults ;
    export LD_LIBRARY_PATH;
    export XAPPLRESDIR;
    echo LD_LIBRARY_PATH is ${LD_LIBRARY_PATH};
    echo Copying compiled Connector wrapper, 32-bit linux
    echo cp "$BINDIR"/ConnectorWrapper "${exe_dir}"
    cp "$BINDIR"/ConnectorWrapper "${exe_dir}"
  ;;
  *)
  echo   Unknown architecture: "$PROC"
  ;;
  esac
  shift 1
  "${exe_dir}"/ConnectorWrapper 
fi
exit

