# GitTeamStats

Analyze commits and committers in mulitple git repos and output project-level statistics

## Installation

Add this line to your application's Gemfile:

    gem 'git_team_stats'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_team_stats


## Configure

Configuration uses ```.gitstatistics.json``` file.  To start, add your own ```.gitstatistics.json``` based off of ```.gitstatistics.json.example``` and edit according to your needs.  

```json
{
    "users" : [
        {
            "name" : "you",
            "aliases" : ["Your Alias #1", "yourotheralias"],
            "default" : true
        },
        {
            "name" : "collaborator",
            "aliases" : ["Their alias"]
        }
    ],
    "projects" : [
        {
            "name" : "project 1",
            "repos" : ["~/src/proj1", "~/src/dependencies/proj1-dep"],
            "ignored_directories" : ["Some/directory/you/forgot/to/gitignore/"],
            "default" : true,
            "start_date" : 1369253382,
            "end_date" : 1369356790
        },
        {
            "name" : "Other project",
            "repos" : ["~/src/OtherProject"],
            "ignored_directories" : []
        }
    ]
}
```

### Defaults

If ```projects``` is left empty, the program will default to running on the current working directory

## Usage

Basic usage is as follows

```
$ git_team_stats [global options] command [command options] [arguments...]
```

### Options

**cache_path**: ```--cache_path=path```
   - The path to your cache files (default: ./tmp)

**config_path**: ```--config_path=path```
   - The path to your config file (default: ./.git_team_stats.json)

**project**: ```--project=name```
   - The project name to run on (default: none).  Make sure you have projects set in your config file.

**help**: ```--help```
   - Show this message

**ignore_cache**: ```--ignore_cache```
   - A switch to turn off loading from cache

**no_cache**: ```--no_cache```
   - A switch to turn off writing to cache

### Commands

##### Count Commits

```
$ git_team_stats count_commits
```

Returns the total number of commits across all your repos in the given project


##### Inspect Commits

```
$ git_team_stats inspect_commits
```

Runs the full inspection on your project repos


##### Team Cumulative Commits

```
$ git_team_stats team_cumulative_stats
```

Gather cumulative statistics on the team.  Example output:

```
~~~ Cumulative Team Statistics ~~~~~~~~
commits : 1641
lines : 73630
edits : 196752
languages: 
   Objective-C
      edits : 127530
      lines : 47940
   Ruby
      edits : 2810
      lines : 2118
   Markdown
      edits : 3592
      lines : 112
   Shell
      edits : 427
      lines : 381
   YAML
      edits : 203
      lines : 165
   PHP
      edits : 16206
      lines : 10630
   SCSS
      edits : 4746
      lines : 3164
   JavaScript
      edits : 12926
      lines : 11672
   JSON
      edits : 7221
      lines : 7183
```


##### User Cumulative Commits

```
$ git_team_stats user_cumulative_stats [--user]
```

Gather cumulative statistics on a team member.  Note you should either have a default user in your config file or pass a user name in the CLI. Example output:

```
~~~ Cumulative User Statistics (Simon Holroyd) ~~~~~~~~
commits : 839
lines : 82525
edits : 110461
languages: 
   Objective-C
      edits : 97762
      lines : 75868
   Markdown
      edits : 1720
      lines : 1696
   PHP
      edits : 1636
      lines : 660
   SCSS
      edits : 1719
      lines : 977
   JavaScript
      edits : 173
      lines : 41
```


##### Team Most Productive Hour

Coming soon

##### User Most Productive Hour

Coming soon

##### Codebase over time

Coming soon

##### User contribution over time

Coming soon


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
