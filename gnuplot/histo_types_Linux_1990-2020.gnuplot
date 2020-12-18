#!/bin/gnuplot

set style data histogram 
set style fill solid 
set boxwidth 1.0
set title 'Nombre de références dans la base '
set ylabel 'Nombre de références'
set yrange [0:47]

plot 'gnuplot/types_Linux_1990-2020.dat' using 2:xtic(1) title 'Nombre de références'
