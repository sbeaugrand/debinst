% ---------------------------------------------------------------------------- %
%% \file kibot.cls
%% \author Sebastien Beaugrand
%% \sa http://beaugrand.chez.com/
%% \copyright CeCILL 2.1 Free Software license
% ---------------------------------------------------------------------------- %
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{kibot}
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
 \includegraphics{../#1Schema}
}

% ---------------------------------------------------------------------------- %
% Planche
% ---------------------------------------------------------------------------- %
\newcommand{\planche}[3]{%
 \rotatebox{270}{%
  \begin{picture}(#3,0)
  \leavevmode\makebox(0,0){\put(0,0){\includegraphics{../#1-B_Cu}}}%
  \leavevmode\makebox(0,0){\put(0,0){\includegraphics{../#1-F_SilkS}}}%
  \leavevmode\makebox(0,0){%
   \multiput(1,0)(1,0){#3}{\multiput(0,0)(0,1){#2}{\line(0,0){0.06}}}}
  \end{picture}
 }
}

\newcommand{\plancheEtendue}[5]{%
 \count0=#4
 \advance\count0 by 1
 \rotatebox{270}{%
  \begin{picture}(#3,0)
  \leavevmode\makebox(0,0){\put(0,#5){\includegraphics{../#1-B_Cu}}}%
  \leavevmode\makebox(0,0){\put(0,#5){\includegraphics{../#1-F_SilkS}}}%
  \leavevmode\makebox(0,0){%
   \multiput(\count0,0)(1,0){#3}{\multiput(0,0)(0,1){#2}{\line(0,0){0.06}}}}
  \end{picture}
 }
}

% ---------------------------------------------------------------------------- %
% Composants
% ---------------------------------------------------------------------------- %
\newcount\somme
\newcount\total

\newcommand\prix[1]{
  \count0=#1 \divide  \count0 by100 \count1=\count0
  \count2=#1 \multiply\count0 by100 \advance\count2 by-\count0
  \number\count1.\ifnum\count2<10 0\fi\number\count2
}
\newcommand\art[4]{
  \global\somme=#2
  \global\multiply\somme by#3
  \global\advance\total\somme
  #4&#1&\prix{#2}&\number#3&\prix{\somme}\\
}
\newenvironment{articles}{
  \global\total=0
  \begin{tabular}{|llrr@{}r|} \hline
    Article&Référence&Prix&Nb&Prix\\ \hline
}{
  \hline
  &&Total&&\prix{\total}\\ \hline
  \end{tabular}
}
