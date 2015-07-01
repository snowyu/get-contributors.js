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
const defaults    = _.partialRight(_.assign, function(value, other) {
  if (value == null) return other
    if (_.isObject(value))
    value = _.assign(other, value)
  return value
})

const optsfileName = path.join(cwd, '.contributors')
const defaultOptions = {
  ask: true,
  config: optsfileName,
  dirname: cwd,
  fields: 'name,github',
  format: 'json',
  tryGithub: true,
  write: true
}
const aliasOptions = {
    h: 'help',
    a: 'ask',
    c: 'config',
    d: 'dirname',
    e: 'fields',
    f: 'format',
    g: 'tryGithub',
    i: 'info',
    t: 'template',
    w: 'write'
}
var options = defaultOptions
try {
  options = defaults(CSON.requireFile(optsfileName), options)
} catch(e){}

var argv = minimist(process.argv.slice(2), {
  alias: aliasOptions,
  default: options
})

//console.log('argv0', argv)
if (argv.config !== options.config) try {
  //the user specify the conf file
  //console.log('load', argv.config)
  var opts = CSON.requireFile(argv.config)
  defaults(opts, options)
  argv = minimist(process.argv.slice(2), {
    alias: aliasOptions,
    default: opts
  })
} catch(e){}

if (argv.fields) {
  argv.fields = argv.fields.split(',')
}

if (argv.info) {
  console.log(argv)
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
    argv.contributors = contributors
    switch (argv.format) {
      case 'template':
        console.log(renderTemplate(argv))
        break
      default:
        console.log(JSON.stringify(contributors, null, 1))
    }
  })
}
