#!/usr/bin/env node

//const insertTable = require('mdast-contributors')
//const mdast       = require('mdast')
const CSON            = require('CSON')
const minimist        = require('minimist')
const path            = require('path')
const getContributors = require('./lib/')
const fs              = require('fs')
const _               = require('lodash')
const renderTemplate  = require('./lib/render-template')
const cwd         = process.cwd()

const optsfileName = path.join(cwd, '.contributors')
const defaultOptions = {
  ask: true,
  config: optsfileName,
  dirname: cwd,
  fields: 'name,github',
  weight: {commit:0.618,deletion:0.2},
  format: 'json',
  tryGithub: true,
  write: true
}
const aliasOptions = {
    h: 'help',
    a: 'ask',
    b: 'branch',
    c: 'config',
    d: 'dirname',
    e: 'fields',
    f: 'format',
    g: 'tryGithub',
    i: 'info',
    p: 'weight',
    t: 'template',
    w: 'write'
}
var options = defaultOptions
try {
  options = _.defaultsDeep(CSON.requireFile(optsfileName), options)
} catch(e){}

var argv = minimist(process.argv.slice(2), {
  alias: aliasOptions,
  'default': options
})

//console.log('argv0', argv)
if (argv.config !== options.config) try {
  //the user specify the conf file
  //console.log('load', argv.config)
  var opts = CSON.requireFile(argv.config)
  _.defaultsDeep(opts, options)
  argv = minimist(process.argv.slice(2), {
    alias: aliasOptions,
    'default': opts
  })
} catch(e){}

if (_.isString(argv.fields)) {
  argv.fields = argv.fields.split(',')
}

if (_.isString(argv.weight)) {
  try {
    argv.weight = CSON.parseCSONString(argv.weight)
  } catch(e) {
    argv.weight = defaultOptions.weight
  }
}

if (argv.info) {
  console.error(argv)
}

if (argv.help) {
  var pkg = CSON.requireFile(path.join(__dirname, 'package.json'))
  var file = require('read-file')
  var usage = file.readFileSync(path.join(__dirname, 'usage.txt'))
  console.log('Version:', pkg.version)
  console.log(usage)
} else {
  getContributors(argv, function (err, contributors) {
    if (err) throw err
    switch (argv.format) {
      case 'template':
        argv.contributors = contributors
        console.log(renderTemplate(argv))
        break
      case 'cson':
        console.log(CSON.stringify(contributors, null, '  '))
        break
      default:
        console.log(JSON.stringify(contributors, null, 1))
        break
    }
  })
}
