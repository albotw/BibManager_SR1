#!/bin/gnuplot
set terminal wxt size 1000,1500
set style data histogram 
set style fill solid 
set boxwidth 1.0
set title 'Nombre de références dans la base '
set ylabel 'Nombre de références'
set xtics rotate by -60 left
set yrange [0:14]

plot 'gnuplot/author_HP.dat' using 2:xtic(1) title 'Nombre de références'
