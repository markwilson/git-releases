Git releases
============

Script to aid creating snapshots of tags/branches from a remote repository.

Usage
-
First time execution requires some options to be set:-
```
git-releases.sh -r <repo> <tag|branch>
```

```
git-releases.sh <tag|branch>
```

To-do list
-
* Provide checkout accessor methods such as list tags/branches
* Check if the current shared repo origin matches the config
* Create option for pre/post-install scripts, e.g. make && make install
* Add an option to create a "current" symlink to most recent tag
* Update .releases file creation to skip clone if no tag/branch provided
* Restructure or rewrite to allow more flexibility over CLI options
  * Should this be using BASH?
