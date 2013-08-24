# running hirveserv on ubuntu

## requirements

* tested on Ubuntu 12.04 32bit
* clone and checkout ubuntu branch: `git checkout ubuntu-i386`
* apt has some of the dependencies: `apt-get install lua5.1 liblua5.1-socket2 sqlite3`
* other dependencies are bundled in `lib/`, compiled on Ubuntu 12.04 32bit

Execute `./run` to start hirveserv

## configuration

The first time hirveserv successfully boots, you will see something like this:

        $ ./run
    setting undefined variable: enforce
    setting undefined variable: sqlite3
    setting undefined variable: sqlite
    setting undefined variable: Client
    Use the password 2y05iH.7srs9qzKQJYeo8y06zO to create admin account
    setting undefined variable: socket

Great. Use Ctrl-C twice to turn it off.

### config file

1. `cp config_default.lua config.lua`
2. edit `config.lua`:
3. set `name = "<your server name>"` 
4. set `auth = true`

### admin account

1. run hirveserv with `./run`, copy the admin password printed to stdout
2. connect to the server with your mud client, in mudmaster this might be `/call 192.168.1.123`
3. `/chat <server> <the admin password printed to stdout when you ./run>`

e.g. 

1. `./run` outputs *Use the password 2y05iH.7srs9qzKQJYeo8y06zO to create admin account*
2. `/chat <server> 2y05iH.7srs9qzKQJYeo8y06z`

### Ready...3 2 1

* setup done!
* `/chat <server> help`
* create user accounts
* see the wiki section

# built-in wiki command

## how the wiki works

* hirveserv looks in `wiki/` for wiki articles
* the `wiki/` directory tree must be formatted correctly or hirveserv may crash and/or the wiki will not function
* when connected to hirveserv, `/chat <server> wiki`
* after making a change to the wiki/ directory tree, `/chat <server> rebuildwiki`

## wiki file structure

    wiki/zones/           # the wiki category "zones"
    wiki/zones/zones.txt  # zones category index
    wiki/zones/alps.txt   # wiki page "alps" in category "zones"
    wiki/zones/df.txt     # wiki page "df" in category "zones"
    wiki/zones/tomb/tomb.txt # multipage index
    wiki/zones/tomb/day1.txt # part of the tomb multipage
    wiki/zones/tomb/bronze.txt # part of the tomb multipage
    wiki/zones/tomb/silver.txt # part of the tomb multipage
    wiki/zones/tomb/gold.txt # part of the tomb multipage

Filenames may not contain whitespace.

## wiki uniqueness of names

Wiki categories, pages, and multipages names must be unique.  No names may be duplicated (even across categories/pages/multipages). In practical terms, this means "foo.txt" must not appear twice.

## wiki category index format

* file name: `wiki/<category>/<category>.txt`
* 1st line of file: description of category
* file must have only 1 line

e.g.

    $cat wiki/zones/zones.txt
    zone walkthroughs

## wiki page format

* file name: `wiki/<category>/name.txt` or `wiki/<category>/<multipage>/name.txt`
* 1st line of file: description of article
* rest of file: body of article
* file must have at least 2 lines

e.g. page in a category

    $cat wiki/zones/df.txt
    Demonforge
    <walkthrough, any number of lines>

e.g. page in a multipage

    $cat wiki/zones/tomb/bronze.txt
    day 2 bronze
    <walkthrough, any number of lines>

## wiki multipage format

* file name: `wiki/<category>/<multipage>/<multipage>.txt`
* 1st line of file: description of multipage
* rest of file: filenames (without .txt extension) of pages in the multipage, one per line
* the multipage should contain at least one page

e.g.

    $cat wiki/zones/tomb/tomb.txt
    tomb of oblivion
    bronze
    silver
    gold
