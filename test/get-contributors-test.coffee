fs              = require 'fs'
cson            = require 'cson'
chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
mockery         = require 'mockery'
_               = require 'lodash'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

mockery.registerMock 'git-commiters', (options, callback)->
  options = options || {}
  if fakeError?
    callback(fakeError)
  else
    callback(null, fakeResults)
  return
mockery.enable warnOnUnregistered: false

fakeResults = []
fakeError = null

getContributors = require '../src/'

readFile = (aFile)->
  fs.readFileSync(aFile, encoding:'utf8')

describe 'get-contributors', ->
  fakeMergeUser = readFile __dirname+'/fixture/merge-user.cson'
  gOptions =
    dirname: '.'
    users:
      zhuangbiaowei:
        name: "BiaoWei Zhuang"
        email: [
          "zhuangbiaowei@gmail.com"
          "zhuangbiaowei@huawei.com"
        ]
      riceball:
        name: "Riceball LEE"
        email: "snowyu.lee@gmail.com"
    fields: [
      'name'
    ]

  before ->
  after ->
    mockery.deregisterMock('git-commiters')
    mockery.disable()
  beforeEach -> fakeResults = cson.parseCSONString fakeMergeUser

  it 'should calc percentage', (done)->
    options = _.extend {}, gOptions,
      fields: ['name', 'percent', 'commits', 'insertions', 'deletions']
      weight: commit:0.6, deletion:0.2
    getContributors options
    .then (users)->
      users.should.be.deep.equal [
        {
          name: 'BiaoWei Zhuang'
          insertions: 63
          commits: 57
          deletions: 4
          percent: '63.2'
        }
        {
          name: 'Riceball LEE'
          insertions: 37
          commits: 33
          deletions: 1
          percent: '36.8'
        }
      ]
      users
    .nodeify(done)

  it 'should merge user and sort by percentage', (done)->
    gOptions.fields = ['name']
    getContributors gOptions
    .then (users)->
      users.should.be.deep.equal [
        {name: 'BiaoWei Zhuang'}
        {name: 'Riceball LEE'}
      ]
      users
    .nodeify(done)
