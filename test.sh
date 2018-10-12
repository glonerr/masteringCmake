#!/bin/sh
Sourcesystem="ABC"

if [ "$Sourcesystem" -eq 'XYZ' ]; then 
    echo "Sourcesystem Matched" 
else
    echo "Sourcesystem is NOT Matched $Sourcesystem"  
fi;