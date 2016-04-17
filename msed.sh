#!/bin/bash

function msed(){
    find -name "Makefile" -exec sed -i "s/$1/$2/g" {} \;
}

function mgrep(){
    find -name "Makefile" | xargs grep $1 --color
}

#msed gas as
#mgrep as
#msed gld ld
#mgrep ld
#msed gar ar
#mgrep ar
msed -O -O\ -fleading-underscore
mgrep \-O\ \-fleading\-underscore
