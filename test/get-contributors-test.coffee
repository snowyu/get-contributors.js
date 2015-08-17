chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
mockery         = require 'mockery'
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

describe 'get-contributors', ->

  after ->
    mockery.deregisterMock('git-commiters')
    mockery.disable()

  it 'should sort by percentage', (done)->
    fakeResults = [
      {
        commits: 33
        name: 'Riceball LEE'
        email: 'snowyu.lee@gmail.com'
        percent: 37.1 }
      {
        commits: 25
        name: 'zhuangbiaowei'
        email: 'zhuangbiaowei@gmail.com'
        percent: 28.1 }
      {
        commits: 16
        name: 'zhuangbiaowei'
        email: 'zhuangbiaowei@huawei.com'
        percent: 18 }
      {
        commits: 13
        name: '庄 表伟'
        email: 'zhuangbiaowei@gmail.com'
        percent: 14.6 }
      {
        commits: 3
        name: '庄表伟'
        email: 'zhuangbiaowei@gmail.com'
        percent: 3.4 }
    ]
    options =
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
    getContributors options
    .then (users)->
      users.should.be.deep.equal [
        {name: 'BiaoWei Zhuang'}
        {name: 'Riceball LEE'}
      ]
      users
    .nodeify(done)
