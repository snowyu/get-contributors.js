contributors  = require('git-commiters')
CSON          = require('cson')
Promise       = require('bluebird')
inquirer      = require('inquirer')
_             = require('lodash')
#userhome      = require('userhome')
path          = require('path')
fs            = require('fs')
getGithubUser = require('./get-github-user')
askInput      = Promise.promisify require('./ask-input')
github        = require('octonode').client()
ghsearch      = github.search()

Promise.promisifyAll(fs);

ghSearchUser = Promise.promisify ghsearch.users, ghsearch
gitListContributors = Promise.promisify contributors

genEmailIndex = (users)->
  result = {}
  for id,user of users
    if user.email
      if _.isArray(user.email)
        user.email.forEach (e)->result[e] = id
      else
        result[user.email] = id
  result
deduplicateUser = (users, emails)->
  # merge the user of the same email address
  t = users
  users = []
  t.forEach (user, index)->
    for u in users
      if user.email is u.email
        u.percent += user.percent
        u.commits += user.commits
        return
    vUserId = emails[user.email]
    user.id = vUserId if vUserId
    users.push(user)

  # merge the user of the same user id
  t = users
  users = []
  t.forEach (user, index)->
    for u in users
      if user.id and user.id is u.id
        u.percent += user.percent
        u.commits += user.commits
        return
    users.push(user)
  users

# get contributors to an object
module.exports = (options, done)->
  options = options || {}
  dirname = options.dirname
  usersCache = options.users || {}
  fields  = options.fields
  ixEmails = genEmailIndex usersCache
  needUpdateCache = false
  addFieldsToContributors = (contributors, fields)->
    contributors.forEach (user)->
      if user.id
        u = usersCache[user.id]
        fields.forEach (field)->
          user[field] = u[field] if u.hasOwnProperty field
      else unless needUpdateCache
        needUpdateCache = true
    return
  gitListContributors {cwd: path.resolve(dirname)}
  .then (users)->
    users = deduplicateUser users, ixEmails
    addFieldsToContributors(users, fields)
    users
  .then (users)->
    if options.tryGithub
      getGithubUser(users)
    else
      users
  .then (users)->
    if options.ask
      askInput users, fields
    else
      users
  .then (users)->
    if options.write and needUpdateCache
      for user in users
        continue unless user.id?
        id = ixEmails[user.email]
        if not id?
          u = usersCache[user.id] = {}
        else
          u = usersCache[id]
        for k,v of user
          if v? and not (k in ['id', 'commits', 'percent'])
            if k is 'email' and _.isArray(u[k])
              u[k].push v unless v in u[k]
              continue
            u[k] = v
      try opts = CSON.requireFile(options.config)
      opts = {} unless opts?
      opts.users = usersCache
      fs.writeFileAsync(options.config, CSON.stringify opts, null, '  ')
      .then ->users
    else
      users
  .then (users)-> # sort by percent
    _.sortBy users, (committer)->
      return -committer.percent
  .then (users)-> # filter fields:
    if _.isArray(fields)
      users.forEach (user)->
        for k,v of user
          delete user[k] if not (k in fields)
    users
  .nodeify(done)
