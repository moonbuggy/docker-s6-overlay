#! /bin/bash
# shellcheck disable=SC2034,SC2154

DOCKER_REPO="${DOCKER_REPO:-moonbuggy2000/s6-overlay}"

TARGET_VERSION_TYPE="custom"

all_tags='latest tarballs prebuilt'
default_tag='latest prebuilt'

custom_versions () {
  echo "${REPO_TAGS}" | xargs -n1 | grep -oP '(^\d+)' | sort -uV
}

custom_source_latest () {
  echo "$(git_repo_tags ${SOURCE_PACKAGES[S6_OVERLAY]} | \
        grep -Po "(${ver}[\.\d]*|$)" | sort -uV | tail -n1)"
}

custom_updateable_tags () {
  for ver in ${*%% }; do
    printf "${ver} ${ver}-prebuilt ${ver}-tarballs"
  done
  echo
}

. "hooks/.build.sh"
