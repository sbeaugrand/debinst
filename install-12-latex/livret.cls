% ---------------------------------------------------------------------------- %
%% \file livret.cls
%% \author Sebastien Beaugrand
%% \sa http://beaugrand.chez.com/
%% \copyright CeCILL 2.1 Free Software license
% ---------------------------------------------------------------------------- %
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cls/livret}
\LoadClass[a5paper,twoside]{article}
\RequirePackage{times}

% ---------------------------------------------------------------------------- %
% Langue
% ---------------------------------------------------------------------------- %
\RequirePackage[french]{babel}
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}

% ---------------------------------------------------------------------------- %
% Mise en page
% ---------------------------------------------------------------------------- %
\RequirePackage{vmargin}
\setpapersize{custom}{148mm}{210mm}
\setmarginsrb{10mm}{10mm}{10mm}{5mm}{0mm}{0mm}{0mm}{5mm}
\renewcommand{\@evenfoot} {\ifnum\thepage>1{\thepage\hfil}\fi}
\renewcommand{\@oddfoot}  {\ifnum\thepage>1{\hfil\thepage}\fi}
\parindent0cm

% ---------------------------------------------------------------------------- %
% Paquets
% ---------------------------------------------------------------------------- %
\RequirePackage{verbatim}
