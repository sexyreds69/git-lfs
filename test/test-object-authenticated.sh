#!/usr/bin/env bash

. "test/testlib.sh"

# these tests rely on GIT_TERMINAL_PROMPT to test properly
ensure_git_version_isnt $VERSION_LOWER "2.3.0"

# if there is a system cred helper we can't run this test
# can't disable without changing state outside test & probably don't have permission
# this is common on OS X with certain versions of Git installed, default cred helper
if [[ -n "$(git config --system credential.helper)" ]]; then
  echo "skip: $0 (system cred helper we can't disable)"
  exit
fi

begin_test "download authenticated object"
(
  set -e
  reponame="$(basename "$0" ".sh")"
  setup_remote_repo "$reponame"
  clone_repo "$reponame" without-creds

  git lfs track "*.dat"
  printf "object-authenticated" > hi.dat
  git add hi.dat
  git add .gitattributes
  git commit -m "initial commit"

  GIT_CURL_VERBOSE=1 GIT_TERMINAL_PROMPT=0 git lfs push origin master
)
end_test
