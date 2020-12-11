#!/bin/bash

baseName = ""
baseFile = ""
format = ""
destination = ""

while getopt hi:e:f:d: OPT
do
    case $OPT in
        h)
            usage()
            exit 0
            ;;
        i)
            $baseFile = $OPTARG
            ;;
        e)
            $baseName = $OPTARG
            ;;
        f)
            $format = $OPTARG
            ;;
        d)
            $destination = $OPTARG
            ;;
        *)
            echo "Erreur, paramètre(s) invalide(s), arrêt"
            usage()
            exit 1
            ;;
    esac
done

