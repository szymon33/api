My API Example
===============

[![Code Climate](https://codeclimate.com/github/szymon33/api/badges/gpa.svg)](https://codeclimate.com/github/szymon33/api)
[![Test Coverage](https://codeclimate.com/github/szymon33/api/badges/coverage.svg)](https://codeclimate.com/github/szymon33/api)

This is just example API (JSON) made in Ruby on Rails framework. Very basic functionality.

API Description
---------------
1. API is secured by basic auth (authenticate_basic_auth)
2. It has just 3 models: Post, Comment and User
3. It has one endpoint 'status' with no authentication.
4. User can have 3 roles: admin, user, guest (default)
4.1. Admin has access to everything.
4.2. User can read all, create all, but update and deleted only his records.
4.3. Guest has only read access.
5. Like action
I developed special action called 'like' for both comment and post. It just increase like counter of these models. I think that out of standard CRUID action is very common in real live.

Recruiments
---------------
Ruby version
Rails version 3
MySql database
API is in subdomain so don't forget to add api.example.com to /etc/hosts when testing.



Insallation
----------
Just basic stuff here.
Create database and database.yml file.
Run bundle command.
Run rake db:setup (there are sample data in seeds file)
Run rails s

Basic checking with curl
------------------------
Request: 'GET /status'
Returns simple 200 '{message: 200}'

Automatic tests
---------------
I have left some extra specs just to show how I do TDD.
