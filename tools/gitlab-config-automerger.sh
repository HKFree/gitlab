#!/bin/sh

set -ex

SOURCE_URL_TEMPLATE='https://gitlab.com/gitlab-org/omnibus-gitlab/raw/${REF}/files/gitlab-config-template/gitlab.rb.template'
OMNIBUS_GITLAB_REPO='https://gitlab.com/gitlab-org/omnibus-gitlab'
TARGET_BRANCH=${TARGET_BRANCH:-next-auto}
CONFIG_PATH=roles/gitlab/templates/gitlab.rb.j2

if [ -z "$CI_BUILD_ID" ]; then
    # local testing values
    export CI_SERVER_HOST=gitlab.hkfree.org
    export CI_PROJECT_PATH=sig-gitlab/gitlab
    NO_PUSH=${NO_PUSH:-1}
fi

if ssh-add -l | grep 'no identities'; then
  # used to test in no-protected branch with no ssh key available
  NO_PUSH=1
fi

rm -rf omnibus
git clone --bare $OMNIBUS_GITLAB_REPO omnibus

CUR_VERSION=$(yq r roles/gitlab/defaults/main.yml gitlab_version | tr - +)

# this var is overridable for testing purposes
NEXT_VERSION=${NEXT_VERSION:-$(cd omnibus && git tag | sort -V | egrep '^[0-9]+\.[0-9]+\.[0-9]+\+ce\.[0-9]+$' | tail -1)}

# todo: use checked out omnubus repo as we've already cloned it
wget -O current_gitlab.rb.template $(echo $SOURCE_URL_TEMPLATE | REF=$CUR_VERSION envsubst)
wget -O next_gitlab.rb.template $(echo $SOURCE_URL_TEMPLATE | REF=$NEXT_VERSION envsubst)

diff -u current_gitlab.rb.template next_gitlab.rb.template > patch || EC=$?

if [ -z "$EC" ]; then
    set +x
    echo "No change in the config file"
elif [ $EC -eq 1 ]; then
    cat ./patch

    # patch the config file
    patch -u $CONFIG_PATH -i ./patch

    # set new version in ansible gitlab role
    yq w -i roles/gitlab/defaults/main.yml gitlab_version $NEXT_VERSION

    # force-push the cloned repo as a new autoupgraded branch
    git remote remove rw || echo "No remote to delete"
    git remote add rw git@${CI_SERVER_HOST}:${CI_PROJECT_PATH}.git
    git branch -D ${TARGET_BRANCH} || echo "No branch to delete"
    git checkout -b ${TARGET_BRANCH}
    git commit -m "automerge config changes from ${NEXT_VERSION}" $CONFIG_PATH
    if [ "$NO_PUSH" != "1" ]; then
        git push rw ${TARGET_BRANCH} -f
    else
        set +x
        echo "Not pushing (not on protected brench?)"
    fi
else
    set +x
    echo "Failed to compare config file versions!"
    exit $EC
fi
