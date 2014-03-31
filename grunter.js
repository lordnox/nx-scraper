#!/usr/bin/env node

// This file is an nodemon - grunt enabler
// run with:
// nodemon grunter.js task1 task2

// load grunt
var grunt = require('grunt');


// get the tasks from the command line
var tasks = Array.prototype.slice.call(process.argv, 2);

// load grunt-tasks and add the to the grunt tasks
require('./Gruntfile')(grunt);

// run the build task
grunt.tasks(tasks);
