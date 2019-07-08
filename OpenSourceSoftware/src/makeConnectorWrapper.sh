#! /bin/bash
# script to compile ConnectorWrapper
# original script makeFann.sh created by EP
# modified to compile ConnectorWrapper by MB

NOCHECKS=$1;

# get the path of the OpenSourceSoftware directory

COSSANPATH=$CURRENTPATH/../../COSSANXengine;
SRCDIR=$CURRENTPATH/ConnectorWrapper

if [ "$NOCHECKS" != "nochecks" ]; then
        echo "ConnectorWrapper will be compiled into the folder :" $DESTDIR"/bin";

        echo "Is it corrected? [Y/N]"

        read -e CHECK

        if [ $CHECK != "Y" ]; then 
                echo "bye !"
                exit     
        fi
fi

mcc -o ConnectorWrapper -W main:ConnectorWrapper -T link:exe -d $DESTDIR/bin -N -w enable:specified_file_mismatch -w enable:repeated_file -w enable:switch_ignored -w enable:missing_lib_sentinel -w enable:demo_license -R nojvm -v $SRCDIR/ConnectorWrapper.m -a $COSSANPATH/src/connectors -a $COSSANPATH/src/common -a $COSSANPATH/src/connectors/ascii -a $COSSANPATH/src/Inputs -a $COSSANPATH/src/outputs

# ensures that the main execution script is executable
chmod +x $SRCDIR/run_Connector.sh
