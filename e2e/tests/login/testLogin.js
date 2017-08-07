// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See License.txt for license information.

import {Constants} from '../../utils';

module.exports = {
    '@tags': ['login'],
    after: (client) => client.getChromeLogs().end(),
    'Test login page': (client) => {
        const loginPage = client.page.loginPage();

        loginPage.navigate()
            .navigateToPage()
            .assert.title('Mattermost')
            .assert.visible('@loginInput')
            .assert.visible('@passwordInput')
            .assert.visible('@signinButton');

        // client.end();
    },
    'Test login action with test user': (client) => {
        const testUser = Constants.USERS.test;
        const loginPage = client.page.loginPage();

        loginPage.navigate()
            .login(testUser.email, testUser.password);

        // client.end();
    }
};