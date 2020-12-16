#!/bin/bash

function txt2bib()
{
    importName=`basename $baseFile`
    touch "bases/$importName.bib"
    cat $baseFile > bases/$importName.bib
}

function bib2txt()
{
    touch "$destination/$baseName.txt"
    cat bases/$baseName.bib > $destination/$baseName.txt
}

function pdf2bib()
{
    echo "bib2txt"
}

function bib2pdf()
{
    cp bases/$baseName.bib $destination/
    chmod a+wx $destination/$baseName.bib
    touch $destination/$baseName.tex
    echo "\documentclass{report}" >> $destination/$baseName.tex
    echo "\usepackage[utf8]{inputenc}" >> $destination/$baseName.tex
    echo "\usepackage{cite}" >> $destination/$baseName.tex
    echo "\begin{document}" >> $destination/$baseName.tex
    
    grep -E "@" bases/$baseName.bib | while read ref
    do
        refID=`echo $ref | cut -d{ -f2 | cut -d, -f1`
        echo "\cite{$refID}" >> $destination/$baseName.tex
    done

    echo "\bibliographystyle{alpha}" >> $destination/$baseName.tex
    echo "\bibliography{$destination/$baseName}" >> $destination/$baseName.tex
    echo "\end{document}" >> $destination/$baseName.tex

    pdflatex -output-directory=$destination $destination/$baseName
    bibtex $destination/$baseName
    pdflatex -output-directory=$destination $destination/$baseName
    pdflatex -output-directory=$destination $destination/$baseName
}

function xml2bib()
{
echo "bib2txt"
}

function bib2xml()
{
echo "bib2txt"
}

while getopts hi:e:f:d: OPT
do
    case $OPT in
        h)
            usage
            exit 0
            ;;
        i)
            baseFile=$OPTARG
            action='IMPORT'
            ;;
        e)
            baseName=$OPTARG
            action='EXPORT'
            ;;
        f)
            format=$OPTARG
            ;;
        d)
            destination=$OPTARG
            ;;
    esac
done


if [ -z $action ]
then
    echo "Erreur, action non définie."
    exit 1
fi

if [ $action = 'IMPORT' ]
then
    if [ -z $baseFile ] || [ -z $format ]
    then
        echo "Erreur, paramètre(s) manquant(s)"
        exit 1
    fi
    
    case $format in
        txt)
            txt2bib
            ;;
        pdf)
            pdf2bib $baseFile
            ;;
        xml)
            xml2bib $baseFile
            ;;
    esac
elif [ $action = 'EXPORT' ]
then
    if [ -z $baseName ] || [ -z $destination ] || [ -z $format ]
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