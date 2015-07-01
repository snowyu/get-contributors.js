_               = require('lodash')
defaultTemplate = require('./default-template')


renderArrayTemplate = (aTemplate, options)->
  result = ''
  if aTemplate[0]
    render = _.template aTemplate[0]
    result += render options
  if aTemplate[1]
    render = _.template aTemplate[1]
    for name, contributor of options.contributors
      options.name = name
      options.contributor = contributor
      result += render options
    delete options.name
    delete options.contributor
  if aTemplate[2]
    render = _.template aTemplate[2]
    result += render options
  result 
  

# apply options.contributors to template.
module.exports = (options)->
  vTemplate = options.template
  vTemplate = defaultTemplate if _.isEmpty vTemplate
  if _.isArray vTemplate
    # [headTemplate, itemTemplate, tailTemplate]
    if vTemplate.length is 1
      vTemplate.push vTemplate[0]
      vTemplate[0] = null
    else if vTemplate.length is 2
      vTemplate.push null
    else
      throw new TypeError 'Empty template to render'
    result = renderArrayTemplate(vTemplate, options)
  else
    render = _.template vTemplate
    result = render options
  result
      
