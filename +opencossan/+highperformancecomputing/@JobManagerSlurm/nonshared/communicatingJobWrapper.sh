#!/bin/sh
# This wrapper script is intended to be submitted to Slurm to support
# communicating jobs.
#
# This script uses the following environment variables set by the submit MATLAB code:
# MDCE_CMR            - the value of ClusterMatlabRoot (may be empty)
# MDCE_MATLAB_EXE     - the MATLAB executable to use
# MDCE_MATLAB_ARGS    - the MATLAB args to use
# PARALLEL_SERVER_DEBUG    - used to debug problems on the cluster
#
# The following environment variables are forwarded through mpiexec:
# MDCE_DECODE_FUNCTION     - the decode function to use
# MDCE_STORAGE_LOCATION    - used by decode function
# MDCE_STORAGE_CONSTRUCTOR - used by decode function
# MDCE_JOB_LOCATION        - used by decode function
#
# The following environment variables are set by Slurm:
# SLURM_NODELIST - list of hostnames allocated to this Slurm job

# Copyright 2015-2018 The MathWorks, Inc.
export PATH=/usr/bin:$PATH

# Echo the nodes that the scheduler has allocated to this job:
echo The scheduler has allocated the following nodes to this job: ${SLURM_NODELIST:?"Node list undefined"}

# Create full path to mw_mpiexec if needed.
FULL_MPIEXEC=${MDCE_CMR:+${MDCE_CMR}/bin/}mw_mpiexec

# Label stdout/stderr with the rank of the process
MPI_VERBOSE=-l

# Increase the verbosity of mpiexec if PARALLEL_SERVER_DEBUG or MDCE_DEBUG (for backwards compatibility) is true
#if [ "X${PARALLEL_SERVER_DEBUG}X" = "XtrueX" ] || [ "X${MDCE_DEBUG}X" = "XtrueX" ]; then
#MPI_VERBOSE="${MPI_VERBOSE} -v -print-all-exitcodes"
#fi

# Construct the command to run.
CMD="\"${FULL_MPIEXEC}\" ${MPI_VERBOSE} -n ${MDCE_TOTAL_TASKS} \"${MDCE_MATLAB_EXE}\" ${MDCE_MATLAB_ARGS}"

# Echo the command so that it is shown in the output log.
echo $CMD

# Execute the command.
eval $CMD

MPIEXEC_EXIT_CODE=${?}
if [ ${MPIEXEC_EXIT_CODE} -eq 42 ] ; then
    # Get here if user code errored out within MATLAB. Overwrite this to zero in
    # this case.
    echo "Overwriting MPIEXEC exit code from 42 to zero (42 indicates a user-code failure)"
    MPIEXEC_EXIT_CODE=0
fi
exit ${MPIEXEC_EXIT_CODE}
