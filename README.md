# My API (JSON) Example
[![Code Climate](https://codeclimate.com/github/szymon33/api/badges/gpa.svg)](https://codeclimate.com/github/szymon33/api)
[![Test Coverage](https://codeclimate.com/github/szymon33/api/badges/coverage.svg)](https://codeclimate.com/github/szymon33/api)

This is just example web API (JSON) made in Ruby on Rails framework. Very basic functionality.


## Description

1. API is secured by basic auth (authenticate_basic_auth)
1. It has just 3 models: Post, Comment and User
1. It has one endpoint 'status' with no authentication.
1. User can have 3 roles: admin, user, guest (default and existing in database)
   * Admin has access to everything.
   * User can read all, create all, but update and deleted only his records.
   * Guest has only read access.
1. There is special action called 'like' for both comment and post. It just increase like counter of these models. I think that action out of typical CRUID is very common in real live.


## Requirements

* Ruby version 2.1 or higher.
* Rails version 3.2.
* [PostgreSQL](http://www.postgresql.org/) database.
* I prefer [Thin](https://github.com/macournoyer/thin/) then Webrick web server but you can comment it out in the [gemfile](Gemfile).


## Installation

Just basic stuff here after cloning the repo.

1. Create database and database.yml file.
1. Run
  ```
  bundle
  ```
1. There are sample data in [seeds](db/seeds.rb) file so run
  ```
  bundle exec rake db:setup
  ```
1. Start web server
  ```
  bundle exec rails s
  ```
1. API is in subdomain so add something like
```ruby
  127.0.0.1       api.example.com 
```

to your `/etc/hosts` file when testing.


## Checking with cURL

You could check application status like this
```console
curl http://api.example.com:3000
```

with the following result
```console
{"message":"OK"}
```

You might inspect how I play with [cURL](https://en.wikipedia.org/wiki/CURL) in the following [file](CURL.md).


## Automatic testing

I use [Rspec](http://rspec.info/) for tests. API was developed facing [TDD](https://en.wikipedia.org/wiki/Test-driven_development) approach. Installed gem [simplecov](https://github.com/colszowka/simplecov) shows 100% coverage. I have left some extra specs just to show how I do. You could see Code Climate status by a badge on very top of this file.

:bowtie:
