#!/bin/bash
#./stat.sh -t        => retourne toutes les valeurs uniques du param
#./stat.sh -t -n   => compte toutes les occurences de chaque val du param
#./stat.sh -t -n -g=> comme avant + affichage en graphique
#./stat.sh -t -n -g -r => comme avant mais sur une plage temporelle précise.
#./stat.sh -a        => retourne tous les auteurs uniques.

counter='OFF'
graph='OFF'
base=bases/HP.bib

while getopts tangr:b: OPT
do
    case $OPT in
        b)
            base=bases/$OPTARG.bib
            ;;
        t)
            searchType='TYPE'
            ;;
        a)
            searchType='AUTHOR'
            ;;
        n)
            counter='ON'
            ;;
        g)
            graph='ON'
            ;;
        r)
            timeRange=$OPTARG
            ;;
    esac
done

function genGraphFile()
{
    if [ $graph = "ON" ]
    then
        if [ $searchType = "TYPE" ]
        then
            if [ -z $timeRange]
            then
                tmpFile=types_`basename $base | cut -d. -f1`.dat
            else
                tmpFile=types_`basename $base | cut -d. -f1`_$timeRange.dat
            fi
        elif [ $searchType = "AUTHOR" ]
        then
            if [ -z $timeRange ]
            then
                tmpFile=author_`basename $base | cut -d. -f1`.dat
            else
                tmpFile=author_`basename $base | cut -d. -f1`_$timeRange.dat
            fi
        fi

        touch gnuplot/$tmpFile
        echo > gnuplot/$tmpFile
    fi
}

function addDataToGraphFile()
{
    field=${1}
    count=$2
    if [ $graph = "ON" ]
    then
        echo \""${field}"\" $count >> gnuplot/$tmpFile
    fi
}

function showGraph()
{
    if [ $graph = "ON" ]
    then
        if [ $searchType = 'TYPE' ]
        then
            if [ -z $timeRange]
            then
                gnuplotFile=gnuplot/histo_types_`basename $base | cut -d. -f1`.gnuplot
            else
                gnuplotFile=gnuplot/histo_types_`basename $base | cut -d. -f1`_$timeRange.gnuplot
            fi
            max=`grep -Eo "@" $base | wc -l`
            cp gnuplot/histo_type_base.gnuplot $gnuplotFile
        elif [ $searchType = "AUTHOR" ]
        then
            if [ -z $timeRange ]
            then
                 gnuplotFile=gnuplot/histo_author_`basename $base | cut -d. -f1`.gnuplot
            else
                gnuplotFile=gnuplot/histo_author_`basename $base | cut -d. -f1`_$timeRange.gnuplot
            fi
            max=`grep -E "author = " $base | wc -l`
            cp gnuplot/histo_author_base.gnuplot $gnuplotFile
        fi

        sed -i "9c\set yrange [0:$max]" $gnuplotFile
        sed -i "11c\plot 'gnuplot/$tmpFile' using 2:xtic(1) title 'Nombre de références'" $gnuplotFile
        gnuplot -persist $gnuplotFile
    fi
}

if [ -z $searchType ]
then
    echo "Erreur, type de recherche non défini"
    exit 1
fi

if [ $searchType = 'TYPE' ]
then
    echo "pour la base $base"

    if [ -z $timeRange ] && [ $counter = 'OFF' ]
    then
        grep -Eo "@.*\{" $base | cut -d@ -f2 | cut -d{ -f1 | sort -u

    elif [ -z $timeRange ] && [ $counter = 'ON' ]
    then
        genGraphFile

        grep -Eo "@.*\{" $base | cut -d@ -f2 | cut -d{ -f1 | sort -u | while read typeRef
        do
            nbRef=`grep -E "@$typeRef" $base | wc -l`
            echo "${typeRef} : $nbRef" 
            addDataToGraphFile "$typeRef" $nbRef
        done
        showGraph

    elif [ ! -z $timeRange ]
    then
        timeBegin=`echo $timeRange | cut -d- -f1`
        timeEnd=`echo $timeRange | cut -d- -f2`
        genGraphFile

        grep -Paoz "(?s)@.*?(.|\n)+?\}\n" $base | grep -Ea "@.*\{" | cut -d@ -f2 | cut -d{ -f1 | sort -u | while read typeRef
        do
            nbRef=0
            for ((time=$timeBegin; time<=$timeEnd; time++))
            do
                #instances=`grep -E "@$typeRef.*?:$time:" $base | wc -l`
                instances=`awk -v type="$typeRef" -v year="$time" '
                BEGIN{n=0; RS="@"; FS="\n";}
                $1 ~ type && $4 ~ year {n++;}
                END{print n;}' $base`
                let "nbRef=nbRef+instances"
            done
            if [ $counter = "ON" ]
            then
                echo "$typeRef : $nbRef"
                addDataToGraphFile $typeRef $nbRef
            elif [ $counter = "OFF" ]
            then
                echo "$typeRef"
            fi
        done

        showGraph  
    fi
elif [ $searchType = 'AUTHOR' ]
then
    echo "pour la base $base"

    if [ -z $timeRange ] && [ $counter = 'OFF' ]
    then
        grep -Paoz "author = (.|\n)+?,\n" $base | cut -d= -f2 | tr -s " " | tr -d "\"," | sort -u
    elif [ -z $timeRange ] && [ $counter = 'ON' ]
    then
        genGraphFile
        grep -Poz "author = (.|\n)+?,\n" $base | cut -d= -f2 | tr -s " " | tr -d "\"," | sort -u | while read author
        do
            if [ ! -z "$author" ]
            then
                nbRef=`grep -E "$author" $base | wc -l`
                echo "auteur(s): ${author} $nbRef" 
                addDataToGraphFile "${author}" $nbRef
            fi
        done
        showGraph
    elif [ ! -z $timeRange ]
    then
        timeBegin=`echo $timeRange | cut -d- -f1`
        timeEnd=`echo $timeRange | cut -d- -f2`

        genGraphFile
        grep -Paoz "(?s)author = (.|\n)+?,\n" $base | cut -d= -f2 | tr -s " " | tr -d "\"," | sort -u | while read author
        do
            if [ ! -z "$author" ]
            then
                nbRef=0
                for ((time=$timeBegin;time<=$timeEnd;time++))
                do
                    instances=`awk -v author="$author" -v year="$time" '
                    BEGIN{n=0; RS="@"; FS="\n";} 
                    $2 ~ author && $4 ~ year { n++;}
                    END{print n;}' $base`
                    let "nbRef=nbRef+$instances"
                done
                if [ $counter = "ON" ] && [ $nbRef -gt 0 ]
                then
                    echo "$author : $nbRef"
                    addDataToGraphFile "${author}" $nbRef
                elif [ $counter = "OFF" ] && [ $nbRef -gt 0 ]
                then
                    echo $author
                fi
            fi
        done
        showGraph
    fi
fi