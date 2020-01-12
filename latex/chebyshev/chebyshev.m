#!/usr/bin/env octave
# ------------------------------------------------ #
## \file chebyshev.m
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
## \note Source: https://
##     fr.wikipedia.org/wiki/Filtre_de_Tchebychev
## \note Source: Design of Microwave Filters,
##     Impedance-Matching Networks, and Coupling
##     Structures, by Matthaei et. p99 https://
##     www.microwaves101.com/uploads/MYJ-part-1.pdf
# ------------------------------------------------ #
s = str2num(argv(){1});  # 1=t 2=pi
n = str2num(argv(){2});
f = str2double(argv(){3});  # MHz
rp = str2double(argv(){4});  # dbV
r1 = 50;  # ohms

beta = log(coth(rp / (40 / log(10))));
gamma = sinh(beta / (2 * n));
a = sin((2 * [1:n] - 1) * pi / (2 * n));
b = gamma ^ 2 + (sin([1:n] * pi / n)) .^ 2;
g(1) = 2 * a(1) / gamma;
for k = 2:n
    g(k) = (4 * a(k-1) * a(k)) / (b(k-1) * g(k-1));
endfor
if (rem(n, 2) == 1)
    g(n+1) = 1;
else
    g(n+1) = coth(beta / 4) .^ 2;
endif
w = 2 * pi * f;
l = r1 * g(s:2:n) / w;
c = g(3-s:2:n) / (w * r1) * 1e6;
r2 = r1 * g(n+1);
n = 100 * sqrt(l / 49);
printf("R1 = %.0f ohms, R2 = %f ohms\n", r1, r2);
printf("C = ");
for k = 1:length(c)
    printf("%f ", c(k));
endfor
printf("pF\n");
printf("L = ");
for k = 1:length(l)
    printf("%f ", l(k));
endfor
printf("uH\n");
printf("n = ");
for k = 1:length(n)
    printf("%f ", n(k));
endfor
printf("tours\n");
