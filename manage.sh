#!/bin/zsh

if [ ! -f cache ]
then
    echo "cache inexistant, reconstruction"
    touch cache
    echo "Linux.bib" >> cache
    echo "BASE" >> cache
fi

base=`sed -n '1p' cache`
mod=`sed -n '2p' cache`

function usage()
{
    echo "-b => action sur les bases"
    echo "-r => action sur les références"
    echo "./manage.sh [-b| -r| -a| -c| -l| -d| -u| -n]"
    echo "-a <base|reference> => ajouter base/ref"
    echo "-d <nom de la référence> => supprimer une référence contenue dans la base"
}

function createBase()
{
    readonly baseName=$1
    touch "bases/$baseName.bib"
    echo "base $baseName.bib crée dans bases/"
}    

function addReference()
{
    reference=$1
    if [ -f $reference ]
    then 
        refID=`grep -E "@" $reference | cut -d{ -f2 | cut -d, -f1`
        testDoublon=`grep -E "$refID" cache`

        if [ $testDoublon = '' ]
        then
            size=`wc -l $reference | tr -d "[:alpha:]" | tr -d "[:space:]"`
            echo "ref-$refID-$size-$base" >> cache
            echo "référence enregistrée dans le cache"

            cat $reference >> bases/$base
            echo '\n' >> bases/$base
            echo "a écrit le contenu de $reference dans $base"
        else 
            echo "Erreur, la référence existe déjà."
        fi
    else
        refID=`echo $reference | grep -E "@" | cut -d{ -f2 | cut -d, -f1`
        testDoublon=`grep -E "$refID" cache`

        if [ $testDoublon = '' ]
        then
            size=`wc -l $reference | tr -d "[:alpha:]" | tr -d "[:space:]"`
            echo "ref-$refID-$size-$base" >> cache
            echo "référence enregistrée dans le cache"

            cat $reference >> bases/$base
            echo '\n' >> bases/$base
            echo "a écrit le contenu de $reference dans $base"
        else 
            echo "Erreur, la référence existe déjà."
        fi
        echo $reference >> $base
        echo "a ajouté la référence dans $base"
    fi
    
}

function removeReference()
{
    refID=$1
    refBase=` grep -E "$refID" cache | awk -F"-" '{print $4}'`
    refSize=` grep -E "$refID" cache | awk -F"-" '{print $3}'`
    let "refSize = $refSize + 1"

    if [ $base = $refBase ]
    then
        refStart=`grep -n "$refID" bases/$base | cut -d: -f1`
        sed -i "$refStart,$refSize d" bases/$base
        
        refCacheIndex=`grep -n "$refID" cache | cut -d: -f1`
        sed -i "$refCacheIndex d" cache

        echo "référence supprimée de la base."
    else 
        echo "Erreur, référence non présente dans la base"
        exit 1
    fi
}

function changeBase()
{
    newBase=$1
    sed -i "1 c\\$newBase" cache
}

function listBases()
{
    ls bases
}

function listReferences()
{
    grep -E "ref" cache | while read -r ligne 
    do
        echo `echo $ligne | cut -d- -f2`
    done
}

function findReference()
{
    if [ -f $base ]
    then 
        refToFind=$1
        echo "start"
        grep -E "$refToFind" $base
    fi
}

function clean()
{
    rm cache
    touch cache
    echo $base >> cache
    echo $mod >> cache

    ls bases | while read base
    do
        grep -E "@" bases/$base | while read ref
        do
            refID=`echo $ref | cut -d{ -f2 | cut -d, -f1`
            testDoublon=`grep -E "$refID" cache`

            if [ -z "$testDoublon" ]
            then  
                completeRef=`grep -Poz "(?s)$refID(.|\n)+?\}\n" bases/$base`
                size=`echo $completeRef | wc -l`
                echo "ref-$refID-$size-$base" >> cache
                echo "référence enregistrée dans le cache"
            fi
        done
    done
}


while getopts hbra:c:ld:un OPT
do
    case $OPT in
        h)
            usage
            exit 0
            ;;
        b) 
            sed -i "2c\BASE" cache
            echo "gestion de la base $base"
            ;;
        r)
            sed -i "2c\REF" cache
            echo "gestion des références de la base $base"
            ;;
        a)
            if [ $mod = 'BASE' ]
            then
                createBase $OPTARG
            elif [ $mod = 'REF' ]
            then 
                addReference $OPTARG
            else
                echo "Erreur, mode de gestion non sélectionné"
                usage
                exit 1
            fi
            ;;
        d)
            removeReference $OPTARG
            ;;
        c)
            changeBase $OPTARG
            ;;
        l)
            if [ $mod = "BASE" ]
            then 
                listBases
            elif [ $mod = 'REF' ]
            then
                listReferences
            else 
                echo "Erreur, mode de gestion non sélectionné"
                exit 1
            fi
            ;;
        n)
            clean
            ;;
    esac
done
