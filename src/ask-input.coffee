inquirer      = require('inquirer')

module.exports = (users, fields, done)->
  asks = []
  users.forEach (user, index)->
    fields.forEach (field)->
      if not user[field]?
        asks.push
          name: index + '?' + field
          type: 'input'
          message: "#{user.email}'s #{field}:"

  if asks.length
    inquirer.prompt asks, (answers)->
      for k,v of answers
        if v
          [index, field] = k.split('?')
          u = users[index]
          u[field] = v
          u.id = v + '@github' if field is 'github' and not u.id?
      done(null, users)
  else
    done(null, users)
  return
        
  