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
  statFields = ['commits', 'deletions', 'insertions']
  # merge the user of the same email address
  t = users
  users = []
  t.forEach (user, index)->
    for u in users
      if user.email is u.email
        for k in statFields
          u[k] += user[k] if u[k]?
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
        for k in statFields
          u[k] += user[k] if u[k]?
        return
    users.push(user)
  users

# get contributors to an object
module.exports = (options, done)->
  options = options || {}
  dirname = options.dirname
  usersCache = options.users || {}
  fields  = options.fields
  weight  = options.weight
  weight = commit:weight if _.isNumber weight
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
  vOptions = cwd: path.resolve(dirname)
  vOptions.revisionRange = options.branch if options.branch
  vOptions.path = options.path if options.path
  gitListContributors vOptions
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
  .then (users)-> # write to .contributor file if new committer found.
    if options.write and needUpdateCache
      for user in users
        continue unless user.id?
        id = ixEmails[user.email]
        if not id?
          u = usersCache[user.id] = {}
        else
          u = usersCache[id]
        for k,v of user
          if v? and not (k in ['id', 'commits', 'percent', 'deletions', 'insertions'])
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
  .then (users)-> # calc percentage contribution
    total = 0
    users.forEach (user)->
      vContribution = user.insertions
      if weight
        vContribution += user.commits * weight.commit if _.isNumber weight.commit
        vContribution += user.deletions * weight.deletion if _.isNumber weight.deletion
      total += vContribution
      user.contribution = vContribution
      return
    users.forEach (user)->
      user.percent = (user.contribution * 1.0 / total * 100.0).toFixed(1)
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
