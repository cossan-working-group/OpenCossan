#!/bin/sh
# This wrapper script is intended to be submitted to Slurm to support
# communicating jobs.
#
# This script uses the following environment variables set by the submit MATLAB code:
# MDCE_CMR            - the value of ClusterMatlabRoot (might be empty)
# MDCE_MATLAB_EXE     - the MATLAB executable to use
# MDCE_MATLAB_ARGS    - the MATLAB args to use
#
# The following environment variables are forwarded through mpiexec:
# MDCE_DECODE_FUNCTION     - the decode function to use
# MDCE_STORAGE_LOCATION    - used by decode function
# MDCE_STORAGE_CONSTRUCTOR - used by decode function
# MDCE_JOB_LOCATION        - used by decode function

# The following environment variables are set by Slurm
# SLURM_JOB_ID             - number of nodes allocated to Slurm job
# SLURM_JOB_NUM_NODES      - number of hosts allocated to Slurm job
# SLURM_JOB_NODELIST       - list of hostnames allocated to Slurm job
# SLURM_TASKS_PER_NODE     - list containing number of tasks allocated per host to Slurm job

# Copyright 2015-2018 The MathWorks, Inc.

# Users of Slurm older than v1.1.34 should uncomment the following code
# to enable mapping from old Slurm environment variables:

# SLURM_JOB_ID=${SLURM_JOBID}
# SLURM_JOB_NUM_NODES=${SLURM_NNODES}
# SLURM_JOB_NODELIST=${SLURM_NODELIST}

# Create full paths to mw_smpd/mw_mpiexec if needed
FULL_SMPD=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_smpd
FULL_MPIEXEC=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_mpiexec

#########################################################################################
# Work out where we need to launch SMPDs given our hosts file - defines SMPD_HOSTS
chooseSmpdHosts() {

    # SLURM_JOB_NODELIST is required: the following line either echoes the value, or aborts.
    echo Node file: ${SLURM_JOB_NODELIST:?"Node file undefined"}

    # SMPD_HOSTS is a single line comma separated list of hostnames:
    #   node136,node138,node140,node141,node142,node143,node157
    #
    # Our source of information is SLURM_JOB_NODELIST in the form:
    #   cnode[136,138],cnode[140-43],cnode157
    #
    # 'scontrol show hostname ${SLURM_JOB_NODELIST}' produces multi-line list of hostnames:
    #   node136
    #   node138
    #   node140
    #   ...
    #
    # Pipe through "tr" to convert newlines to spaces.

    SMPD_HOSTS=`scontrol show hostname ${SLURM_JOB_NODELIST} | tr '\n', ' '`
}

#########################################################################################
# Work out which port to use for SMPD
chooseSmpdPort() {

    # Extract the numeric part of SLURM_JOB_ID using sed to choose unique port for SMPD to run on.
    # Assumes SLURM_JOB_ID starts with a number, such as: 15.slurm-server-host.domain.com
    JOB_NUM=`echo ${SLURM_JOB_ID:?"SLURM_JOB_ID undefined"} | sed 's#^\([0-9][0-9]*\).*$#\1#'`
    # Base smpd_port on the numeric part of the above
    SMPD_PORT=`expr $JOB_NUM % 10000 + 20000`
}

#########################################################################################
# Work out how many processes to launch - set MACHINE_ARG
#
# Inputs:
#   SLURM_JOB_NUM_NODES       Slurm environment variable: Number of nodes allocated to Slurm job
#
#   SMPD_HOSTS                Comma separated list of hostnames of nodes set by chooseSmpdHosts
#
#   SLURM_TASKS_PER_NODE      Slurm environment variable: Number of tasks allocated per node.
#                             If two or more consecutive nodes have the same task count,
#                             that count is followed by "(x#)" where "#" is the repetition count.
# Output:
#   MACHINE_ARG               Arguments to pass to mpiexec in the form:
#                               -hosts <num_hosts> host1 tasks_on_host1 host2 tasks_on_host2
#
# Example
# -------
#   Inputs:
#     SLURM_JOB_NUM_NODES        7
#     SMPD_HOSTS                 node136,node138,node140,node141,node42,node143,node157
#     SLURM_TASKS_PER_NODE       12(x4),7,9(x2)
#   Output:
#     -hosts 7 node136 12 node138 12 node140 12 node141 12 node142 7 node143 9 node157 9
#
chooseMachineArg() {

    # Transform SLURM_TASKS_PER_NODE into TASKS_PER_NODE_LIST
    #
    # Examples:                                            SLURM_TASKS_PER_NODE -> TASKS_PER_NODE_LIST
    # -------                                              --------------------    -------------------
    # Single node has 12 tasks                             12                   -> 12
    # Three nodes have 12 tasks                            12(x3)               -> 12,12,12
    # First two nodes have 7 tasks, the third has 8 tasks  7(x2),8              -> 7,7,8

    TASKS_PER_NODE_LIST=''
    # Replace commas with spaces to create space delimited list to use with for loop
    LIST_FROM_SLURM=`echo ${SLURM_TASKS_PER_NODE} | sed 's/,/ /g'`
    for ITEM in ${LIST_FROM_SLURM}
    do
        if [ `echo ${ITEM} | grep -e '^[0-9][0-9]*$' -c` -eq 1 ] ; then
            # "NUM_TASKS" == "NUM_TASKS(x1)"
            NUM_NODES=1
            NUM_TASKS=${ITEM}
        else
            # "NUM_TASKS(xNUM_NODES)"
            NUM_NODES=`echo $ITEM | sed 's/^[0-9][0-9]*(x\([0-9][0-9]*\))$/\1/'`
            NUM_TASKS=`echo $ITEM | sed 's/^\([0-9][0-9]*\)(x[0-9][0-9]*)$/\1/'`
        fi

        # Repeat NUM_NODES iterations: append NUM_TASKS to TASKS_PER_NODE_LIST
        COUNT=0
        while [ ${COUNT} -lt ${NUM_NODES} ]
        do
          if [ -z "${TASKS_PER_NODE_LIST}" ] ; then
              # List empty, therefore adding first item to list - avoid adding comma
              TASKS_PER_NODE_LIST=${NUM_TASKS}
          else
              # Appending to list - add a comma to delimit entries
              TASKS_PER_NODE_LIST="${TASKS_PER_NODE_LIST},${NUM_TASKS}"
          fi
          COUNT=`expr ${COUNT} + 1`
        done
    done

    # Add -hosts argument at start of MACHINE_ARG
    MACHINE_ARG="-hosts ${SLURM_JOB_NUM_NODES}"

    # For each hostname in SMPD_HOSTS, append '<hostname> <tasks_per_node>' to MACHINE_ARG
    INDEX=0
    for HOSTNAME in ${SMPD_HOSTS}
    do
      INDEX=`expr ${INDEX} + 1`
      # Use cut to index the '${INDEX}th' item in TASKS_PER_NODE_LIST
      TASKS_PER_NODE=`echo ${TASKS_PER_NODE_LIST} | cut -f ${INDEX} -d,`
      MACHINE_ARG="${MACHINE_ARG} ${HOSTNAME} ${TASKS_PER_NODE}"
    done
    echo "Machine args: $MACHINE_ARG"
}

#########################################################################################
# Shut down SMPDs and exit with the exit code of the last command executed
cleanupAndExit() {
    EXIT_CODE=${?}

    echo "Stopping SMPD ..."

    STOP_SMPD_CMD="srun --ntasks-per-node=1 --ntasks=${SLURM_JOB_NUM_NODES} ${FULL_SMPD} -shutdown -phrase MATLAB -port ${SMPD_PORT}"
    echo $STOP_SMPD_CMD
    eval $STOP_SMPD_CMD

    echo "Exiting with code: ${EXIT_CODE}"
    exit ${EXIT_CODE}
}

#########################################################################################
# Use srun to launch the SMPD daemons on each processor
launchSmpds() {

    # Launch the SMPD processes on all hosts using srun
    echo "Starting SMPD on ${SMPD_HOSTS} ..."

    START_SMPD_CMD="srun --ntasks-per-node=1 --ntasks=${SLURM_JOB_NUM_NODES} ${FULL_SMPD} -phrase MATLAB -port ${SMPD_PORT} -debug 0 &"
    echo $START_SMPD_CMD
    eval $START_SMPD_CMD

    # Check that the SMPD processes are running on all hosts
    SUCCESS=0
    NUM_ATTEMPTS=60
    ATTEMPT=1
    while [ ${ATTEMPT} -le ${NUM_ATTEMPTS} ]
    do
        echo "Checking that SMPD processes are running (Attempt ${ATTEMPT} of ${NUM_ATTEMPTS})"
        SMPD_LAUNCHED_HOSTS=""
        NUM_HOSTS_FOUND=0
        for HOST in ${SMPD_HOSTS}
        do
            CHECK_SMPD_CMD="${FULL_SMPD} -phrase MATLAB -port ${SMPD_PORT} -status ${HOST} > /dev/null 2>&1"
            echo $CHECK_SMPD_CMD
            eval $CHECK_SMPD_CMD
            EXIT_CODE=${?}
            if [ $EXIT_CODE -ne 0 ]; then
                echo "No SMPD process running on ${HOST}"
            else
                echo "SMPD process found running on ${HOST}"
                NUM_HOSTS_FOUND=$((NUM_HOSTS_FOUND+1))

                # Append HOST to SMPD_LAUNCHED_HOSTS if it does not already contain it.
                case "${SMPD_LAUNCHED_HOSTS}" in
                    *$HOST* ) ;;
                    *       ) SMPD_LAUNCHED_HOSTS="${SMPD_LAUNCHED_HOSTS} ${HOST}" ;;
                esac
            fi
        done
        if [ ${SLURM_JOB_NUM_NODES} -eq ${NUM_HOSTS_FOUND} ] ; then
            SUCCESS=1
            break
        elif [ ${ATTEMPT} -ne ${NUM_ATTEMPTS} ] ; then
            sleep 1
        fi
        ATTEMPT=$((ATTEMPT+1))
    done
    if [ $SUCCESS -ne 1 ] ; then
        if [ $NUM_HOSTS_FOUND -eq 0 ] ; then
            echo "No SMPD processes were found running.  Aborting."
        else
            echo "Found SMPD processes running on only ${NUM_HOSTS_FOUND} of ${SLURM_JOB_NUM_NODES} nodes.  Aborting."
            echo "Hosts found: ${SMPD_LAUNCHED_HOSTS}"
        fi
        exit 1
    fi
    echo "All SMPDs launched"
}

#########################################################################################
runMpiexec() {

    CMD="\"${FULL_MPIEXEC}\" -smpd -phrase MATLAB -port ${SMPD_PORT} \
        -l ${MACHINE_ARG} -genvlist \
        MDCE_DECODE_FUNCTION,MDCE_STORAGE_LOCATION,MDCE_STORAGE_CONSTRUCTOR,MDCE_JOB_LOCATION,MDCE_DEBUG,MDCE_LICENSE_NUMBER,MLM_WEB_LICENSE,MLM_WEB_USER_CRED,MLM_WEB_ID \
        \"${MDCE_MATLAB_EXE}\" ${MDCE_MATLAB_ARGS}"

    # As a debug stage: echo the command ...
    echo $CMD

    # ... and then execute it.
    eval $CMD

    MPIEXEC_CODE=${?}
    if [ ${MPIEXEC_CODE} -ne 0 ] ; then
        exit ${MPIEXEC_CODE}
    fi
}

#########################################################################################
# Define the order in which we execute the stages defined above
MAIN() {
    # Install a trap to ensure that SMPDs are closed if something errors or the
    # job is cancelled.
    trap "cleanupAndExit" 0 1 2 15
    chooseSmpdHosts
    chooseSmpdPort
    launchSmpds
    chooseMachineArg
    runMpiexec
    exit 0 # Explicitly exit 0 to trigger cleanupAndExit
}

# Call the MAIN loop
MAIN
