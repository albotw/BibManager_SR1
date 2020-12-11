#!/bin/bash

mod = "null"

while getopt hbra:c:ld:un OPT
do
    case $OPT in
        h)
            usage()
            exit 0
            ;;
        b)
            $mod = "BASE"
            ;;
        r)
            $mod = "REF"
            ;;
        a)
            if [ $mod == "BASE"]
            then
                readonly baseName = $OPTARG
                createBase()
            elif [ $mod == "REF" ]
            then 
                readonly ref = $OPTARG
                addReference()
            else
                echo "Erreur, option < -b | -r > manquante"
                usage();
                exit 1
            fi
            ;;
        d)
            readonly refToDelete = $OPTARG
            removeReference()
            ;;
        u)
            detectDoublon()
            ;;
        c)
            readonly baseToOpen = $OPTARG
            changeBase()
            ;;
        l)
            listBases()
            ;;
        n)
            clean()
            ;;
        *)
            echo "Erreur, paramètre(s) invalide(s), arrêt"
            usage()
            exit 1
            ;;
    esac
done

usage()
{

}

createBase()
{

}    

addReference()
{

}

removeReference()
{

}

detectDoublon()
{
    
}

changeBase()
{

}

listBases()
{

}

clean()
{

}