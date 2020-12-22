#!/bin/gnuplot
set terminal wxt size 800,600
set style data histogram 
set style fill solid 
set boxwidth 1.0
set title 'Nombre de références dans la base '
set ylabel 'Nombre de références'
set xtics rotate by -60 left
set yrange [0:18]

plot 'gnuplot/author_Linux.dat' using 2:xtic(1) title 'Nombre de références'
