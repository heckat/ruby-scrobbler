# Ruby Scrobbler

A minimal ruby utility to monitor Music.app and submit plays to last.fm

## System Requirements

* Ruby 3 (tested on 3.3.4)

## Dependencies

* lastfm
* rb-scpt
* sqlite3

* minitest
* rake
* rubocop

## How to

### Install

```bash
% git clone https://github.com/heckat/ruby_scrobbler.git
% cd ruby_scrobbler
% bundle install
% gem build ruby_scrobbler.gemspec
% gem install ./ruby_scrobbler-0.0.1.gem
```

### Run for the first time

```ruby
% irb
> require 'ruby_scrobbler'
> rs = RubyScrobbler.new
> rs.lastfm.set_local_password
> rs.lastfm.api_auth
> rs.lastfm.user_auth
> rs.listen
```

### Run with previously saved credentials

```ruby
% irb
> require 'ruby_scrobbler'
> rs = RubyScrobbler.new
> rs.lastfm.set_local_password
> rs.lastfm.load_api_user
> rs.lastfm.load_user
> rs.listen
```

## Method reference

### `set_local_password`

Reads in a run-time only password used to encrypt and decrypt the last.fm credentials.
Use the same password each time to retrieve existing last.fm credentials from the database.

### `api_auth`

Reads in API key and API secret for last.fm.
API secret is encrypted with local password and stored in the database.

### `user_auth`

Reads in user name and password for last.fm.
Currently authenticates with password (not through OAuth).
Password is not stored.
Session key is encrypted with local password and stored in the database.

### `listen`

Monitors Music.app and submits plays to last.fm.

### `load_api_user`*

Loads previously entered API key and secret from the database.

### `load_user`*

Loads previously entered user name and session key from the database.

### Note

\* The last two methods (`load_api_user` and `load_user`) will only work
  if the API secret and session key stored in the database were encrypted
  with the current local password.
