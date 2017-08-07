// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import {Constants} from '../utils';

const loginCommands = {
    navigateToPage() {
        return this.waitForElementVisible('@loginInput', 3000);
    },
    login(email, pass) {
        return this
            .waitForElementVisible('@loginInput', 3000)
            .setValue('@loginInput', email)
            .setValue('@passwordInput', pass)
            .waitForElementVisible('@signinButton')
            .click('@signinButton');
    }
};

module.exports = {
    url: `${Constants.TEST_BASE_URL}/login`,
    commands: [loginCommands],
    elements: {
        loginInput: {
            selector: 'input[name=loginId]'
        },
        passwordInput: {
            selector: 'input[name=password]'
        },
        signinButton: {
            selector: 'button[type=submit]'
        }
    }
};