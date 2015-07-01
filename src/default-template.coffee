module.exports = '''
<% if (contributors) contributors.forEach(function(contributor) {
     var item = contributor.name
     if (contributor.github)
       item = "[" + item +"](https://github.com/" + contributor.github + ")"
     print(" * " + item + "\\n")
   })
%>
'''