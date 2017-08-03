#!/bin/bash
set -e

function message {
    echo ""
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    echo "#"  "$@"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    echo ""
}

function selenium_install {
    SELENIUM_DIR="./node_modules/selenium-standalone/.selenium/"

    if [ ! -d "$SELENIUM_DIR" ]; then

      if [ "$CI" != true ]; then
      message "Installing selenium..."
      fi

      yarn run selenium-install
      mkdir -p reports/
    fi
}

function selenium_start {
    # Use defult config for selenium-standalone lib
    nohup yarn run selenium-start > ./reports/selenium.log 2>&1&
}

function ci_cleanup {
    rm -rf ./dist_e2e
    # babel-node ./test/setup/files/removeCertificate.js
    rm simplefilename.testfile
}

function ci_setup {
    selenium_install

    # babel-node ./test/setup/createTestInstances.js
    touch simplefilename.testfile

    selenium_start
}

function ci_tests {
    MESSAGE=$(git log --pretty=format:%s -n 1 "$CIRCLE_SHA1")

    if [[ "$MESSAGE" == *\[e2e-skip\]* ]] || [ $CIRCLE_BRANCH = 'master' ]; then
        message "[WARN] Skipping E2E tests !!!"
    else
        ci_setup

        if [ $CIRCLE_BRANCH = 'devel' ]; then
            message "Starting devel test flow..."
            yarn run e2e-master-devel
        else
            message "Starting branch test flow..."
            yarn run e2e-branch
        fi

        ci_cleanup
    fi
}

function local_cleanup {
    message "Closing selenium server..."
    pkill -f selenium-standalone

    message "Cleaning account from test instances..."
    # babel-node ./test/setup/deleteTestInstances.js

    message "Done"
}

function local_setup {
    selenium_install

    message "Creating temporary instances for tests..."
    # babel-node ./test/setup/createTestInstances.js
    touch simplefilename.testfile

    message "Starting Selenium in background..."
    trap local_cleanup EXIT
    selenium_start
    sleep 5
}


function local_tests {
    local_setup
    message "Checking tests with lint..."

    if [ -n "$1" ]; then
        message "Tag: ${1} local tests starts..."
        yarn run e2e-tag $1
    else
        if [[ $CI == 'local' ]]; then
          message "[INFO] Running internal full tests, be sure to export all variables"
          yarn run e2e-branch
        else
          message "Full local tests starts..."
          yarn run e2e-local
        fi
    fi
}

if [ "$CI" = true ] && [ $CI != 'local' ]; then
    message "start with ci_tests" # debug purpose
    ci_tests
else
    message "start with local_tests" # debug purpose
    local_tests $@
fi