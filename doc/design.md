# Ruby Scrobbler Design Document

## Overview

Ruby Scrobbler is a simple to code, simple to use,
 light-weight utility to monitor the Music application,
 observe played tracks, store the plays in a local database,
 and submit them to the Lastfm service.

The only configuration elements necessary are the
 Lastfm credentials and and a local password.
 The Lastfm API key, API secret, username, and session key
  are all stored in the database, with secrets encrypted.
 The local password (entered or re-entered at run-time)
 is used only to encrypt and decrypt the Lastfm secrets.

## Components

* SQLite database
* Lastfm authenticator
* Music app monitor
* Database manager
* Scrobbler

## Data Model

* user
* track
* error
