#!/bin/bash
#./stat.sh -t        => retourne toutes les valeurs uniques du param
#./stat.sh -t -n   => compte toutes les occurences de chaque val du param
#./stat.sh -t -n -g=> comme avant + affichage en graphique
#./stat.sh -t -n -g -r => comme avant mais sur une plage temporelle précise.
#./stat.sh -a        => retourne tous les auteurs uniques.

counter='OFF'
graph='OFF'

while getopts tangr: OPT
do
    case $OPT in
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
    ls bases | while read base
    do 
        echo "pour la base $base"

        if [ -z $timeRange ] && [ $counter = 'OFF' ]
        then
            grep -Eo "@.*\{" bases/$base | cut -d@ -f2 | cut -d{ -f1 | sort -u

        elif [ -z $timeRange ] && [ $counter = 'ON' ]
        then
            grep -Eo "@.*\{" bases/$base | cut -d@ -f2 | cut -d{ -f1 | sort -u | while read typeRef
            do
                echo "$typeRef:" 
                grep -E "@$typeRef" bases/$base | wc -l
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