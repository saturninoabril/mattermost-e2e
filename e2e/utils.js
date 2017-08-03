import _ from 'lodash';

const NIGHTWATCH_METHODS = ['tags', 'before', 'after', 'afterEach', 'beforeEach'];
const addTestNamePrefixes = (config) => {
  const prefix = config.tags.join(',');

  return _.mapKeys(config, (value, key) => {
    if (_.includes(NIGHTWATCH_METHODS, key)) {
      return key;
    }

    return `[${prefix}] ${key}`;
  });
};

export { addTestNamePrefixes };

const utils = {
  // Method to determine whether to use COMMAND or CONTROL key
  // Based on the operating system. The unicode values are taken from the W3 Webdriver spec:
  // https://www.w3.org/TR/webdriver/#character-types
  cmdOrCtrl() {
    if (process.platform === 'darwin') {
      return '\uE03D';
    }

    return '\uE009';
  },

  testBaseUrl() {
    return 'https://localhost:8065';
  },

  getTestFileLocation() {
    return require('path').resolve(`${__dirname}/../../simplefilename.testfile`);
  }
};

export default utils;