#!/bin/gnuplot

set style data histogram 
set style fill solid 
set boxwidth 1.0
set title 'Nombre de références dans la base '
set ylabel 'Nombre de références'
set xtics rotate by 60 right
set yrange [0:100]

plot '' using 2:xtic(1) title 'Nombre de références'