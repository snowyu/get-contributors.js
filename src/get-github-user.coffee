Promise       = require('bluebird')
github        = require('octonode').client()
ghsearch      = github.search()
ghSearchUser  = Promise.promisify ghsearch.users, ghsearch


# try to Get Github User via email
exports = module.exports = (users, done)->
  vUsers = (user for user in users when not user.github?)
  Promise.map vUsers, (user)->
    ghSearchUser q: user.email+'+in:email'
    .then (data)->
      if data and data[0].total_count
        login = data[0].items[0].login
        user.github = login
        user.id = login + '@github' unless user.id?
      else
        throw new TypeError 'not found such email,maybe private email'
      return user
    .caught (err)->
      console.error "can not find user #{user.email} on github\n#{err.message}"
      #throw err
  .then (results)->
    #results = results.filter Boolean
    users
    #done(null, results)
  .nodeify(done)
  #.caught (err)->done(err)
exports.searchUser = ghSearchUser