
var project = require('../project');
var grunt   = require('grunt');

module.exports = function(config) {
  var conf = {
    basePath      : '../'
  , frameworks    : ['jasmine']
  , reporters     : ['dots', 'growl']
  , browsers      : ['PhantomJS']
  , autoWatch     : true

    // these are default values anyway
  , singleRun     : false
  , colors        : true
  , preprocessors : {}
  };

  // setup all files that should have coverage
  grunt.file.expand(project.files.test.coverage).map(function(file) {
    conf.preprocessors[file] = 'coverage';
  });

  if(Object.keys(conf.preprocessors).length)
    conf.reporters.push('coverage');

  // types: cobertura, html, json, lcov, lcovonly, none, teamcity, text, text-summary

  conf.coverageReporter = {
    type: 'html'
  , dir : 'test/coverage/'
  };

  config.set(conf);
};
