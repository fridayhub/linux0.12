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
#msed -O -O\ -fleading-underscore
#mgrep \-O\ \-fleading\-underscore

#for 64
#msed ld$ ld\ -m\ elf_i386
#mgrep elf_i386

#msed as$ as\ --32
msed -O -O\ -m32
