#!/bin/sh

# concourse "fly" binary
FLYBIN=~/Downloads/fly

function run {
    ${FLYBIN} \
        set-pipeline \
        --target ${TARGET} \
        --pipeline ${PIPELINE} \
        --config ./pipeline.yml \
        --load-vars-from ./pipeline-config.yml \
        --load-vars-from ~/.ssh/pipeline-config-ssh-key.yml
}

function show {
    CMD="${FLYBIN} \
        set-pipeline \
        --target ${TARGET} \
        --pipeline ${PIPELINE} \
        --config ./pipeline.yml \
        --load-vars-from ./pipeline-config.yml \
        --load-vars-from ~/.ssh/pipeline-config-ssh-key.yml"

    echo $CMD
}


function usage {
    PGM=`basename $0`

    echo "Usage: ${PGM} [-s|-r] [-h] <target> <pipeline>";
    echo "${PGM} expects to find the following three files: "
    echo "  ./pipeline.yml"
    echo "  ./pipeline-config.yml"
    echo "  ~/.ssh/pipeline-config-ssh-key.yml"
    echo "-s ... show commands"
    echo "-r ... run commands"
    echo "-h ... this usage message"
    echo "one of (-r, -s) is required"
}

MODE="usage"

while getopts ":srh" OPT; do
    TARGET=$2
    PIPELINE=$3

    if [[ ! ${TARGET} ]]; then
        echo ERROR: target missing
        usage
        exit -2
    fi
    if [[ ! ${PIPELINE} ]]; then
        echo ERROR: pipeline missing
        usage
        exit -3
    fi

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
