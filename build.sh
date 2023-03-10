#! /bin/bash
# shellcheck disable=SC2034

#NOOP='true'
#DO_PUSH='true'
##[ -z "${DO_PUSH+set}" ] && NO_PUSH='true'
#NO_BUILD='true'

DOCKER_REPO="${DOCKER_REPO:-moonbuggy2000/s6-overlay}"

all_tags='latest tarballs prebuilt'
default_tag='latest prebuilt'

. "hooks/.build.sh"
