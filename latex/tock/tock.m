#!/usr/bin/octave -q
# ---------------------------------------------------------------------------- #
## \file tock.m
## \author Sebastien Beaugrand
## \sa http://beaugrand.chez.com/
## \copyright CeCILL 2.1 Free Software license
# ---------------------------------------------------------------------------- #
global l = 19;
global n = str2num(argv(){1});

function y = f(x)
  global l;
  global n;
  h = (1 + 0.5/cos(pi/n))*l*tan(pi/n/2) + x*tan(pi/n);
  r = sqrt(h*h + x*x);
  y = r*sin(pi/2*(31/17 - 28/17/n) + 3/17*asin(x/r)) - (l/2+x)*tan(pi/n);
endfunction

[ecart, fval, info] = fzero(@f, [-5;10]);
printf("\\ecart=%.6fcm\n", ecart);

h = (1 + 0.5/cos(pi/n))*l*tan(pi/n/2) + ecart*tan(pi/n);
rayon = sqrt(h*h + ecart*ecart);
printf("\\rayon=%.6fcm\n", rayon);

ainit = pi/n + asin(ecart/rayon);
printf("\\def\\ainit{%.6f}\n", ainit*180/pi);

aincr = (pi - 2*ainit)/17;
printf("\\def\\aincr{%.6f}\n", aincr*180/pi);

hinit = (l/2 + ecart)/cos(pi/n) - l/2/cos(pi/n/2);
printf("\\hinit=%.6fcm\n", hinit);

hincr = rayon*tan(aincr);
printf("\\hincr=%.6fcm\n", hincr);

quinze = l/2*sin(pi/n/4);
printf("\\quinze=%.6fcm\n", quinze);

yorig = -(l/2+ecart)/cos(pi/n);
printf("\\yorig=%.6fcm\n", yorig);
