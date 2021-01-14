#!/bin/bash

if [ ! -f cache ]
then
    echo "cache inexistant, reconstruction"
    touch cache
    echo "default.bib" >> cache
    echo "BASE" >> cache
fi