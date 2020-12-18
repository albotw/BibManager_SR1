#!/bin/bash
#./stat.sh -t        => retourne toutes les valeurs uniques du param
#./stat.sh -t -n   => compte toutes les occurences de chaque val du param
#./stat.sh -t -n -g=> comme avant + affichage en graphique
#./stat.sh -t -n -g -r => comme avant mais sur une plage temporelle précise.
#./stat.sh -a        => retourne tous les auteurs uniques.

counter='OFF'
graph='OFF'
base=bases/Linux.bib

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
        if [ $graph = "ON" ]
        then
            tmpFile=types_`basename $base | cut -d. -f1`.dat
            touch gnuplot/$tmpFile
            echo > gnuplot/$tmpFile
        fi

        grep -Eo "@.*\{" $base | cut -d@ -f2 | cut -d{ -f1 | sort -u | while read typeRef
        do
            echo "$typeRef:" 
            grep -E "@$typeRef" $base | wc -l
            if [ $graph = "ON" ]
            then
                echo $typeRef `grep -E "@$typeRef" $base | wc -l` >> gnuplot/$tmpFile  
            fi
        done
        if [ $graph = "ON" ]
        then
            nbRef=`grep -Eo "@" $base | wc -l`
            echo "nbRef: $nbRef"
            cp gnuplot/histo_base.gnuplot gnuplot/histo_types_`basename $base | cut -d. -f1`.gnuplot
            sed -i "8c\set yrange [0:$nbRef]" gnuplot/histo_types_`basename $base | cut -d. -f1`.gnuplot
            sed -i "10c\plot 'gnuplot/$tmpFile' using 2:xtic(1) title 'Nombre de références'" gnuplot/histo_types_`basename $base | cut -d. -f1`.gnuplot
            gnuplot -persist gnuplot/histo_types_`basename $base | cut -d. -f1`.gnuplot
        fi

    elif [ ! -z $timeRange ]
    then
        timeBegin=`echo $timeRange | cut -d- -f1`
        timeEnd=`echo $timeRange | cut -d- -f2`

        if [ $counter = "OFF" ]
        then
            for ((time=$timeBegin; time<=$timeEnd;time++))
            do
                grep -Paoz "(?s)@.*?:$time:(.|\n)+?\}\n" $base | grep -Ea "@.*\{" | cut -d@ -f2 | cut -d{ -f1 | sort -u
            done

        elif [ $counter = "ON" ]
        then
            if [ $graph = 'ON' ]
            then
                tmpFile=types_`basename $base | cut -d. -f1`_$timeRange.dat
                touch gnuplot/$tmpFile
                echo > gnuplot/$tmpFile
            fi

            grep -Paoz "(?s)@.*?(.|\n)+?\}\n" $base | grep -Ea "@.*\{" | cut -d@ -f2 | cut -d{ -f1 | sort -u | while read typeRef
            do
                counter=0
                for ((time=$timeBegin; time<=$timeEnd; time++))
                do
                    instances=`grep -E "@$typeRef.*?:$time:" $base | wc -l`
                    let "counter=counter+instances"
                done
                echo "$typeRef : $counter"
                if [ $graph = "ON" ]
                then
                    echo "$typeRef $counter" >> gnuplot/$tmpFile
                fi
            done

            if [ $graph = 'ON' ]
            then
                nbRef=`grep -Eo "@" $base | wc -l`
                cp gnuplot/histo_base.gnuplot gnuplot/histo_types_`basename $base | cut -d. -f1`_$timeRange.gnuplot
                sed -i "8c\set yrange [0:$nbRef]" gnuplot/histo_types_`basename $base | cut -d. -f1`_$timeRange.gnuplot
                sed -i "10c\plot 'gnuplot/$tmpFile' using 2:xtic(1) title 'Nombre de références'" gnuplot/histo_types_`basename $base | cut -d. -f1`_$timeRange.gnuplot
                gnuplot -persist gnuplot/histo_types_`basename $base | cut -d. -f1`_$timeRange.gnuplot      
            fi   
        fi
    fi
fi

if [ $searchType = 'AUTHOR' ]
then
    ls bases | while read base
    do 
        echo "pour la base $base"

        if [ -z $timeRange ] && [ $counter = 'OFF' ]
        then
            grep -Eo "author(.|\n)*?,\n" bases/$base //
        elif [ -z $timeRange ] && [ $counter = 'ON' ]
        then
            grep -Eo "@.*\{" bases/$base | cut -d@ -f2 | cut -d{ -f1 | sort -u | while read typeRef
            do
                echo "$typeRef:" 
                grep -E "@$typeRef" bases/$base | wc -l
                if [ $graph = "ON" ]
                then
                    echo $typeRef `grep -E "@$typeRef" bases/$base | wc -l` >> tmp.dat
                fi
            done
        
        elif [ ! -z $timeRange ]
        then
            timeBegin=`echo $timeRange | cut -d- -f1`
            timeEnd=`echo $timeRange | cut -d- -f2`

            if [ $counter = "OFF" ]
            then
                for ((time=$timeBegin; time<=$timeEnd;time++))
                do
                    grep -Paoz "(?s)@.*?:$time:(.|\n)+?\}\n" bases/$base | grep -Ea "@.*\{" | cut -d@ -f2 | cut -d{ -f1 | sort -u
                done
                
            elif [ $counter = "ON" ]
            then
                for ((time=$timeBegin; time<=$timeEnd;time++))
                do
                    grep -Paoz "(?s)@.*?:$time:(.|\n)+?\}\n" bases/$base | grep -Ea "@.*\{" | cut -d@ -f2 | cut -d{ -f1 | sort -u | while read typeRef
                    do
                        echo "$typeRef - $time :"
                        grep -E "@$typeRef.*?:$time:" bases/$base | wc -l
                    done
                done
            fi
        fi
    done
fi