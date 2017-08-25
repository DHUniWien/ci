#!/bin/sh

# trigger a job, watch it and hijack it after its done
#
# make a handy alias: `alias runjob.sh=<checkout of ci>/ci/bin/runjob.sh`
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
    echo "Usage: `basename $0` [-s|-r] [-h] <target> <pipeline> <job>";
    echo "-s ... show commands"
    echo "-r ... run commands"
    echo "-h ... this usage message"
    echo "one of (-r, -s) is required"
}

MODE="usage"

while getopts ":srh" OPT; do
    TARGET=$2
    PIPELINE=$3
    JOB=$4

    case $OPT in
        s)
            MODE="show"
        ;;
        r)
            MODE="run"
        ;;
        *)
            usage
            exit 0
        ;;
    esac
done

${MODE}
