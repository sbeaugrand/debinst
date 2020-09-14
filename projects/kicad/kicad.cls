% ---------------------------------------------------------------------------- %
%% \file kicad.cls
%% \author Sebastien Beaugrand
%% \sa http://beaugrand.chez.com/
%% \copyright CeCILL 2.1 Free Software license
% ---------------------------------------------------------------------------- %
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{kicad}
\LoadClass[a5paper]{article}
\RequirePackage{times}
\RequirePackage{graphics}
\RequirePackage{siunitx}

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
\pagestyle{empty}
\parindent0cm
\setlength{\unitlength}{2.54mm}

% ---------------------------------------------------------------------------- %
% Titre
% ---------------------------------------------------------------------------- %
\newcommand{\titre}[1]{%
 \Large
 #1\\
 \normalsize
}

% ---------------------------------------------------------------------------- %
% Schema
% ---------------------------------------------------------------------------- %
\newcommand{\schema}[1]{%
 \includegraphics{../kicad/#1Schema}
}

% ---------------------------------------------------------------------------- %
% Planche
% ---------------------------------------------------------------------------- %
\newcommand{\planche}[3]{%
 \rotatebox{270}{%
  \begin{picture}(#3,0)
  \leavevmode\makebox(0,0){\put(0,0){\includegraphics{../kicad/#1-B_Cu}}}%
  \leavevmode\makebox(0,0){\put(0,0){\includegraphics{../kicad/#1-F_SilkS}}}%
  \leavevmode\makebox(0,0){%
   \multiput(1,0)(1,0){#3}{\multiput(0,0)(0,1){#2}{\line(0,0){0.06}}}}
  \end{picture}
 }
}
