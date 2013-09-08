
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
* the multipage directory is accessable with `/chat <server> wiki <multipage>`
* each page in the multipage is accessible with `/chat <server> wiki <multipage> <page number>`

In the example below,
* `/chat <server> wiki tomb` will show the tomb multipage directory
* `/chat <server> wiki tomb 1` will access the bronze page
* `/chat <server> wiki tomb 3` will access the gold page.

e.g.

    $cat wiki/zones/tomb/tomb.txt
    tomb of oblivion
    bronze
    silver
    gold
