#!/bin/zsh

if [ ! -f cache ]
then
    echo "cache inexistant, reconstruction"
    touch cache
    echo "default.bib" >> cache
    echo "BASE" >> cache
fi

base=`gsed -n '1p' cache`
mod=`gsed -n '2p' cache`
echo "base: $base"
echo "mod: $mod"

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
        cat $reference >> bases/$base
        echo "a écrit le contenu de $reference dans $base"

        refID=`grep -E "@" $reference`
        size=`wc -l $reference | tr -d "[:alpha:]" | tr -d "[:space:]"`
        echo "ref::$refID::$size::$base" >> cache
        echo "référence enregistrée dans le cache"
    else
        echo $reference >> $base
        echo "a ajouté la référence dans $base"
    fi
    
}

function removeReference()
{
    refID=$1
    refSize=`awk 'BEGIN { fs="::" } $2 ~ ID{ print $3 }' cache ID=$refID`
    echo $refSize
}

function detectDoublon()
{
    echo "detectDoublon"
}

function changeBase()
{
    newBase=$1
    gsed -i "1 c\\$newBase" cache
}

function listBases()
{
    ls bases
}

function listReferences()
{
    echo "begin"
    grep -E "@" $base
    echo "end"
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
    echo "clean()"
}


while getopts hbra:c:ld:unf: OPT
do
    case $OPT in
        h)
            usage
            exit 0
            ;;
        b) 
            gsed -i "2c\BASE" cache
            echo "gestion de la base $base"
            ;;
        r)
            gsed -i "2c\REF" cache
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
        f)
            findReference $OPTARG
            ;;
        u)
            detectDoublon
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
