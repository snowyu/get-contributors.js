## get-contributors [![npm](https://img.shields.io/npm/v/get-contributors.svg)](https://npmjs.org/package/get-contributors)

[![Build Status](https://img.shields.io/travis/snowyu/get-contributors.js/master.svg)](http://travis-ci.org/snowyu/get-contributors.js)
[![downloads](https://img.shields.io/npm/dm/get-contributors.svg)](https://npmjs.org/package/get-contributors)
[![license](https://img.shields.io/npm/l/get-contributors.svg)](https://npmjs.org/package/get-contributors)

Get contributors from git, and generate a JSON list of contributors or a list base on a user defined template.


* It could assign the github user name from the email address of the contributor.
* It could merge multi-email addresses into one contributor if you've set on your
  contributors file(.contributors). the ".contributors" file should be put into the
  current diretory if no specified position.

## Usage

```bash
Usage get-contributors {OPTIONS}

Get contributors from git, and generate 
a JSON list of contributors. or a list
base on a user defined template.


Options:
  -d, --dirname         The git project to get contributors. Default: $(pwd)
  -c, --config          The contrbutors configuration file. Default: ${pwd}/.contributors
  -g, --tryGithub       try to get the github user name from the email via Search the github.
                        Default: yes, --no-tryGithub to disable it.
  -w, --write           Write the contrbutors configuration file if it has new contrbutors comming.
                        Default: yes, --no-write to disable it.
  -e, --fields          The output fields name, separate via comma. Default: "name,github"
  -f, --format          The output format, template or markdown, Default: json
  -a, --ask             whether ask the user to input it if can not find the github user name, Default: yes
                        --no-ask to disable it.
  -t, --template        the template for the template format. Default:
                        <% _.forEach(contributors, function(contributor) {
                             var item = contributor.name
                             if (contributor.github)
                               item = "[" + item +"](https://github.com/" + contributor.github
                             print(" * " + item)
                           }
                        %>

```

The contrbutors configuration file(cson format):

```coffee

dirname: '.'
tryGithub: false
write: false
fields: 'name,github'

users:
  Jame:
    name: 'Jame Smith'
    email: 'jame@no.com'
    github: 'jame'
    twitter: 'jame'
  Mike:
    name: 'Mike Smith'
    email: ['mike@no.com', 'as@cc.com']
    github: 'mike'
    twitter: 'mike'

```




## License

MIT
