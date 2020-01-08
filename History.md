# Release History for hglib

---
## v0.7.0 [2020-01-08] Michael Granger <ged@FaerieMUD.org>

Changes:

- Fix some stuff for Ruby 2.7 compatibility.


## v0.6.0 [2019-10-16] Michael Granger <ged@FaerieMUD.org>

Improvements:

- Add topic extension


## v0.5.0 [2019-10-14] Michael Granger <ged@FaerieMUD.org>

Improvements:

- Add a mechanism for defining methods that support Mercurial extensions
- Move the version methods into a mixin and expose them on both Hglib and
  Hglib::Repo instances.
- Add an extension for gpg


## v0.4.0 [2019-10-12] Michael Granger <ged@FaerieMUD.org>

Changes:

- Move the #version methods up into the base module

Improvements:

- Add Hglib.extension_enabled?


## v0.3.0 [2019-10-02] Michael Granger <ged@FaerieMUD.org>

Changes:

- Changed Repo#status to return Repo::StatusEntry objects
- Change Repo#id -> #identity with alias

Improvements:

- Handle multi-part errors
- Handle numeric option args
- Added implementations of:
  - config
  - log
  - tag
  - bookmark
  - diff
  - push
  - paths
  - version
  - sign


## v0.2.0 [2019-04-03] Michael Granger <ged@FaerieMUD.org>

Improvements:

- Added is_repo? and init methods to Hglib


## v0.1.0 [2019-04-03] Michael Granger <ged@FaerieMUD.org>

Initial release.

