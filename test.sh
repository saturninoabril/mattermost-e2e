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
}

function ci_setup {
    selenium_install

    selenium_start
}

function ci_tests {
    MESSAGE=$(git log --pretty=format:%s -n 1 "$CIRCLE_SHA1")
    yarn run lint

    if [[ "$MESSAGE" == *\[e2e-skip\]* ]] || [ $CIRCLE_BRANCH = 'master' ]; then
        message "[WARN] Skipping E2E tests !!!"
    else
        ci_setup

        ci_cleanup
    fi
}

function local_cleanup {
    message "Closing selenium server..."
    pkill -f selenium-standalone

    message "Done"
}

function local_setup {
    selenium_install

    message "Starting Selenium in background..."
    trap local_cleanup EXIT
    selenium_start
    sleep 5
}

function local_tests {
    local_setup
    message "Checking with eslint..."
    yarn run lint

    if [ -n "$1" ]; then
        message "Tag: ${1} local E2E starts..."
        yarn run e2e-tag $1
    else
        message "Full local E2E starts..."
        yarn run e2e-local
    fi
}

if [ "$CI" = true ] && [ $CI != 'local' ]; then
    ci_tests
else
    local_tests $@
fi