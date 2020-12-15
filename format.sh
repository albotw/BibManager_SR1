#!/bin/bash

baseName = ""
baseFile = ""
format = ""
destination = ""
action = ""

function txt2bib()
{
    
}

function bib2txt()
{

}

function pdf2bib()
{

}

function bib2pdf()
{

}

function xml2bib()
{

}

function bib2xml()
{

}

while getopt hi:e:f:d: OPT
do
    case $OPT in
        h)
            usage()
            exit 0
            ;;
        i)
            baseFile = $OPTARG
            $action="IMPORT"
            ;;
        e)
            baseName = $OPTARG
            $action="EXPORT"
            ;;
        f)
            format = $OPTARG
            ;;
        d)
            destination = $OPTARG
            ;;
    esac
done


if [ ! -z $action ]
then
    echo "Erreur, action non définie."
    exit 1
fi

if [ $action = "IMPORT" ]
then
    if [ -z $baseFile ] || [ -z $format ]
    then
        echo "Erreur, paramètre(s) manquant(s)"
        exit 1
    fi
    
    case $format in
        txt)
            txt2bib $baseFile
            ;;
        pdf)
            pdf2bib $baseFile
            ;;
        xml)
            xml2bib $baseFile
            ;;
    esac
elif [ $action = "EXPORT" ]
then
    if [-z $baseName ] || [ -z $destination ] || [ -z $format ]
    then
        echo "Erreur, paramètre(s) manquant(s)"
        exit 1
    fi

    case $format in 
        txt)
            bib2txt $baseName $destination
            ;;
        pdf)
            bib2pdf $baseName $destination
            ;;
        txt)
            bib2txt $baseName $destination
            ;;
    esac
fi