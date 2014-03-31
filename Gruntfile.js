var project = require('./project');

module.exports = function(grunt) {

  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  grunt.initConfig({
    project: project
  , watch: {
      dist: {
        files   : '<%= project.src %>/*'
      , tasks   : ['coffee:dist', 'simplemocha:backend']
      }
    , test: {
        files   : '<%= project.srcTest %>/specs/*'
      , tasks   : ['coffee:test', 'simplemocha:backend']
      }
    , app: {
        files   : ['<%= project.apppath %>/*.js', '<%= project.apppath %>/*.coffee']
      , tasks   : ['start']
      , options : {
          nospawn: true
        }
      }
    , simplemocha: {
        files   : ['<%= simplemocha.backend.src %>', '<%= watch.app.files %>']
      , tasks   : ['simplemocha']
      }
    }
  , nodemon: {
      app: {
        script: 'server.local.js'
      , options: {
          ext: 'js,coffee'
        , env: {
            OPENSHIFT_NODEJS_PORT: project.server.devPort
          , DEBUG: 'skat* nx-*'
          }
        }
      }
    }
  , simplemocha: {
      options: {
        globals: [
          'sinon'
        , 'chai'
        , 'should'
        , 'expect'
        , 'assert'
        , 'AssertionError'
        ]
      , timeout: 3000
      , ignoreLeaks: false
      , ui: 'bdd'
      , reporter: 'spec'
      }
    , backend: {
        src: [
          // add chai and sinon globally
          'test/support/globals.js'

          // tests
        , 'specs/{**,*}/*.js'
        , 'specs/{**,*}/*.coffee'
        ]
      }
    }
  });

  grunt.registerTask('default', 'nodemon');
  grunt.registerTask('test', ['simplemocha', 'watch:simplemocha']);
};
