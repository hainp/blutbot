My own (cmpitg) notes.

## Requirements

* Gems: `gettext`

### For Tokyo Cabinet

* Libraries and headers: `libtokyocabinet-dev`, `zlib1g-dev`, `libbz2-dev` on Debian-based systems.

* Gems: `tokyocabinet`.

### For Berkeley DB

**Notes:** I failed to use Berkeley DB, implementation is complicated and buggy.

* Libraries and headers: `libdb-dev` (and `libdb++-dev`) on Debian-based systems.

* Gems: `bdb`, `rake-compiler`.

* `bdb` gem should be installed manually, since the remote version from the main gem repository is extremely outdated.  Newest version: `https://github.com/knu/ruby-bdb.git`:

    ```sh
    cd $YOUR_SOURCE_DIR
    git clone https://github.com/knu/ruby-bdb.git
    cd ruby-bdb
    rake compile
    sed -i.bak 's/spec\.files.*=.*$/spec.files         = `find . | grep -v "\.git" | grep -v "\.\/tmp\/"`.split($\/)/g' bdb.gemspec
    gem build bdb.gemspec
    gem install bdb*.gem
    ```
