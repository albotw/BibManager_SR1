#!/bin/bash

if [ ! -d bases/ ]
then
    mkdir bases
    touch bases/default.bib
fi

if [ ! -f cache ]
then
    echo "cache inexistant, reconstruction"
    touch cache
    echo "default.bib" >> cache
    echo "BASE" >> cache
fi

if [ ! -d gnuplot/ ]
then
    mkdir gnuplot
    echo "#!/bin/gnuplot
set terminal wxt size 800,600
set style data histogram 
set style fill solid 
set boxwidth 1.0
set title 'Nombre de références dans la base '
set ylabel 'Nombre de références'
set xtics rotate by -60 left
set yrange [0:100]

plot '' using 2:xtic(1) title 'Nombre de références' " >> gnuplot/histo_author_base.gnuplot

    echo  "#!/bin/gnuplot

set style data histogram 
set style fill solid 
set boxwidth 1.0
set title 'Nombre de références dans la base '
set ylabel 'Nombre de références'
set xtics rotate by 60 right
set yrange [0:100]

plot '' using 2:xtic(1) title 'Nombre de références' " >> gnuplot/histo_type_base.gnuplot

fi