# projet_SR1_2020_2021

dépot du projet de systèmes et réseau. (Licence 3 année 2020/2021)

En shell (ou en C)
Les références vont être stockées dans des fichiers bib dand le dossier /bases
Au besoin, les informations utiles au programmes sont stockées dans le fichier data
Ce fichier contient les index des références pour simplifier la gestion:

*(contenu dans quelle base)
*position
*nombre de lignes
*identifiant

On va avoir trois fichiers éxécutables:

*Gestion des bases : manage.sh
*changement de format : format.sh
*stats : stat.sh

Le script pour la gestion des bases va avoir les commandes et fonctionnalités suivantes:

*usage et help: ./manage.sh --usage
*format des commandes: ./manage.sh < -b | -r > <...>
*Création de base: manage.sh -b -a [nom]
*Changement de base: manage.sh -b -c [nom]
*Lister toutes les bases: manage.sh -b -l
*Ajout de référence ./manage.sh -r -a [fichier | texte]
*suppression de référence: ./manage.sh -r -d [identifiant]
*détéction de doublon: ./manage.sh -r -d
*nettoyage: ./manage.sh -n

Le script pour le changement de format d'une base va avoir les commandes et fonctionnalités suivantes:

*usage et help: ./manage.sh --usage
*format des commandes ./format.sh [ -i | -e ] [nom de la base] [destination si -e | format si -i]
*importation au format txt (txt -> bib): ./format.sh -i fichier txt
*exportation au format txt (bib -> txt): ./format.sh -e base1 ~/home/documents
*importation au format pdf (pdf -> bib): ./format.sh -i fichier pdf
*exportation au format pdf (bib -> pdf): ./format.sh -e base2 /

Le script pour les statistiques  va avoir les commandes et fonctionnalités suivantes:

*usage et help: ./stat.sh --usage
*format des commandes: ./stat.sh [base] [donnée à analyser] [type de sortie]
*type des références: ./stat.sh base1 -t -g
*nombre de références par auteur: ./stat.sh base1 -r t

./stat.sh -t        => retourne toutes les valeurs uniques du param
./stat.sh -t -n   => compte toutes les occurences de chaque val du param
./stat.sh -t -n -g=> comme avant + affichage en graphique
./stat.sh -t -n -g -r => comme avant mais sur une plage temporelle précise.
./stat.sh -a        => retourne tous les auteurs uniques.

Le script de statistiques va principalement reposer sur awk mais peut aussi utiliser grep, head, tail, tr et toutes les commandes qui concernent du texte.
Le script de gestion des bases va aussi utiliser des commandes liées au texte.
On peut donc unifier les commandes de modification de fichiers via un fichier shell contenant ces fonctions.

La structure de chaque script aura une structure similaire à celle ci:

```Shell
while getopt operateur1:operateur2 OPT
do
case "$OPT" in
    operateur1)
        fonction1()
        exit 0
        ;;
    operateur2)
        fonction2()
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
done

fonction(){...}
fonction2(){...}
```

