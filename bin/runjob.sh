#!/bin/sh

# trigger a job, watch it and hijack it after its done
#

# concourse "fly" binary
FLYBIN=~/Downloads/fly

function run {
    ${FLYBIN} --target ${TARGET} trigger-job -j ${PIPELINE}/${JOB}
    ${FLYBIN} --target ${TARGET} watch -j ${PIPELINE}/${JOB}
    ${FLYBIN} --target ${TARGET} hijack -j ${PIPELINE}/${JOB} sh
}

function show {
    echo "${FLYBIN} --target ${TARGET} trigger-job -j ${PIPELINE}/${JOB}"
    echo "${FLYBIN} --target ${TARGET} watch -j ${PIPELINE}/${JOB}"
    echo "${FLYBIN} --target ${TARGET} hijack -j ${PIPELINE}/${JOB} sh"
}

function usage {
    echo "Usage: `basename $0` [-s] [-h]";
    echo "-s ... show commands"
    echo "-r ... run commands"
    echo "-h ... this usage message"
    echo "only one (the first) option is recognised"
}

while getopts "srh" OPT; do
    TARGET=$2
    PIPELINE=$3
    JOB=$4

    case $OPT in
        s)
            show
        ;;
        h)
            usage
        ;;
        r)
            run
        ;;
    esac

    # only one of the options may be given
    exit 0
done
