#!/bin/bash

for f in $(ls); do

test -d $f && {
    test -f "$f"/readMe.md || {
        echo ""$f" missing readMe"
    }

    test -f "$f"/control && {
        grep -q "Tag: ipadkid::true" "$f"/control || {
            echo ""$f" missing ipad_kid tag"
        }
    }

    test -f "$f"/layout/DEBIAN/control && {
        grep -q "Tag: ipadkid::true" "$f"/layout/DEBIAN/control || {
            echo ""$f" missing ipad_kid tag"
        }   
    }   

}

done
