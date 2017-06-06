#!/bin/sh

# trigger a job, watch it and hijack it after its done
#

# concourse "fly" binary
FLYBIN=
TARGET=$1
PIPELINE=$2
JOB=$3

${FLYBIN} --target ${TARGET} trigger-job -j ${PIPELINE}/${JOB}
${FLYBIN} --target ${TARGET} watch -j ${PIPELINE}/${JOB}
${FLYBIN} --target ${TARGET} hijack -j ${PIPELINE}/${JOB}
