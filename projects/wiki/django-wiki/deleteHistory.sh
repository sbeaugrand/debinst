#!/bin/bash
# ---------------------------------------------------------------------------- #
## \file deleteHistory.sh
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
sqlite="sqlite3 db.sqlite3"

pages=`$sqlite "SELECT id FROM wakawaka_wikipage"`
for page in $pages; do
    count=`$sqlite "SELECT count(*) FROM wakawaka_revision WHERE page_id=$page"`
    ((count--))
    $sqlite "DELETE FROM wakawaka_revision WHERE page_id=$page LIMIT $count"
done
