## get-contributors [![npm](https://img.shields.io/npm/v/get-contributors.svg)](https://npmjs.org/package/get-contributors)

[![Build Status](https://img.shields.io/travis/snowyu/get-contributors.js/master.svg)](http://travis-ci.org/snowyu/get-contributors.js)
[![downloads](https://img.shields.io/npm/dm/get-contributors.svg)](https://npmjs.org/package/get-contributors)
[![license](https://img.shields.io/npm/l/get-contributors.svg)](https://npmjs.org/package/get-contributors)

Get contributors from git, and generate a JSON list of contributors or a list base on a user defined template.

* The contributors is sorted by the contribution of the order.
* It could show the commits and the percentage contribution in the project.
* It could add customized fields to output
* It could use a customized template format to output
* It could search and assign the github user name from the email address of the contributor.
* It could ask the user the information of the unknown fields(github etc) at the command line
* It could write the new contributors to your contributors configuration file(.contributors)
* It could merge multi-email addresses into one contributor if you've set on your
  contributors file(".contributors"). the ".contributors" file should be put into the
  current diretory if no specified position.

## Changes

### v0.4

+ the percentage contribution in the project should use the changes mainly:
  * contributions = commits*weight.commit(0.618) + insertions + deletions * weight.deletion(0.1)
+ weight option
+ branch option: the git branch to get the contributors.
+ path option: get the contributors of the specified path in the git's working directory

## Usage

```bash
Usage get-contributors {OPTIONS}

Get contributors from git, and generate
a JSON list of contributors. or a list
base on a user defined template.


Options:
  -d, --dirname         The git project(git working dir) to get contributors. Default: $(pwd)
  -c, --config          The contrbutors configuration file. It uses the CSON format.
                        Default: ${pwd}/.contributors
  -b, --branch          get the contributors on the git branch.
                        Default: current branch(HEAD).
      --path            get the contributors on the specified path in the git's working directory.
                        Default: root dir(all).
  -g, --tryGithub       try to get the github user name from the email via Search the github.
                        Default: yes, --no-tryGithub to disable it.
  -p, --weight          the commits and deletion weight of contribution:
                        It means the weight of commits if it's a number.
                        Default: "commit:0.618,deletion:0.1".
  -w, --write           Write the contrbutors configuration file if it has new contrbutors comming.
                        Default: yes, --no-write to disable it.
  -e, --fields          The output fields name, separate via comma. Default: "name,github"
                        * name: the user name
                        * email: the user email address
                          the user can have many emails, see contributors configuration.
                        * github: the github user name(it could be used as a user id)
                        * commits: the commits count of this contributor
                        * percent: the percentage with the contribution
  -f, --format          The output format, the customized template, cson or json, Default: json
                        * template: the customized template via user
                        * json: the json format
                        * cson: the cson format
  -a, --ask             whether ask the user to input if it can not find the field(github,etc).
                        Default: yes, --no-ask to disable it.
  -t, --template        The template for the template format. It supports the simple template and
                        the complex template. the complex template has three parts, head template,
                        body template and tail template, the head and tail could be ignore. (you
                        should define this in the configuration file only)
                        Default:
                        <% _.forEach(contributors, function(contributor) {
                             var item = contributor.name
                             if (contributor.github)
                               item = "[" + item +"](https://github.com/" + contributor.github
                             print(" * " + item)
                           }
                        %>
                        Complex template(in the congfiguration file) example:
                        template: [
                        	'''
                        		| Contributor Name | Github |
                        		| ---------------  | ------ |

                        	'''
                        	'''
                        		| ${contributor.name} | ${contributor.github} |

                        	'''
                        ]
  -i, --info            Show configuration infomation.
  -h, --help            Show this help infomation.

```

The contributors configuration file(cson format):

```coffee

dirname: '.'
tryGithub: false
write: false
fields: 'name,github'
template: [
	'''
		| Contributor Name | Github |
		| ---------------  | ------ |

	'''
	'''
		| ${contributor.name} | ${contributor.github ? "[" + contributor.github + "](https://github.com/" + contributor.github + ")" : "-"} |

	'''
]
users:
  Jame:
    name: 'Jame Smith'
    email: 'jame@no.com'
    github: 'jame'
    twitter: 'jame'
    url: 'https://www.xxx.com'
  Mike:
    name: 'Mike Smith'
    email: ['mike@no.com', 'as@cc.com']
    github: 'mike'
    twitter: 'mike'

```




## License

MIT
