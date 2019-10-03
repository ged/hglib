# Release History for hglib

---

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

