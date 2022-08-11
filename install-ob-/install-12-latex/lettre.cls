% ---------------------------------------------------------------------------- %
%% \file lettre.cls
%% \author Sebastien Beaugrand
%% \sa http://beaugrand.chez.com/
%% \copyright CeCILL 2.1 Free Software license
% ---------------------------------------------------------------------------- %
% zypper install --no-recommends\
%  texlive-latex\
%  texlive-vmargin\
%  texlive-babel-french\
%  texlive-psnfss\
%  texlive-metafont-bin\
%  texlive-times\
%  texlive-dvips
%  texlive-lastpage
% ---------------------------------------------------------------------------- %
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{lettre}
\DeclareOption{avecpliage}{\def\pliage@longueur{1}}
\DeclareOption{sanspliage}{\def\pliage@longueur{0}}
\DeclareOption{avecpages}{\def\pages{\hfill\thepage/\pageref{LastPage}}}
\DeclareOption{sanspages}{\def\pages{}}
\DeclareOption{dateavantdest}{\def\date@avant{1}}
\DeclareOption{dateapresdest}{\def\date@avant{0}}
\ExecuteOptions{avecpliage}
\ExecuteOptions{avecpages}
\ExecuteOptions{dateavantdest}
\ProcessOptions
\LoadClass[a4paper,11pt]{article}
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
\setmarginsrb{25mm}{21mm}{25mm}{11mm}{0mm}{0mm}{0mm}{10mm}
\RequirePackage{lastpage}
\renewcommand{\@evenfoot}{\pages}
\renewcommand{\@oddfoot} {\pages}
\RequirePackage{zref-savepos}
\parindent0cm

% ---------------------------------------------------------------------------- %
% Lieu, date, et formule de politesse
% ---------------------------------------------------------------------------- %
\def\@lieu{Paris}
\def\@date{\today}
\def\@formule{Veuillez agréer, \titre, mes salutations distinguées.}
\def\lieu#1{\def\@lieu{#1}}
\def\date#1{\def\@date{#1}}
\def\formule#1{\def\@formule{#1}}

% ---------------------------------------------------------------------------- %
% Pliage
% ---------------------------------------------------------------------------- %
\newcommand{\pliage}{%
 \setlength\unitlength{1mm}
 \vbox to 0pt{\kern-\headsep \kern-\topmargin \kern-\headheight
  \kern-1in \kern-\voffset \kern-\abovedisplayskip \kern 99mm
  \hbox to 0pt{\kern-\@themargin \kern-1in \kern-\hoffset \kern 10mm
   \line(1,0){\pliage@longueur}}}
}

% ---------------------------------------------------------------------------- %
% Expéditeur
% ---------------------------------------------------------------------------- %
\newcommand{\expediteur}[2]{%
 \pliage
 \def\nom{#1}
 \begin{minipage}[t]{7cm}
 \nom\\
 #2
 \end{minipage}
 \ifnum\date@avant=1
  \hfill
  \begin{minipage}[t]{7cm}
   \mbox{\@lieu}, \mbox{le \@date}
  \end{minipage}
 \fi
 \vskip 1cm}

% ---------------------------------------------------------------------------- %
% Destinataire
% ---------------------------------------------------------------------------- %
\newcommand{\destinataire}[2]{%
 \phantom{coucou}
 \hfill
 \begin{minipage}[t]{7cm}
 #1\\
 #2\\
 \ifnum\date@avant=0
  \\
  \\
  \hfill \@lieu, le \@date
 \fi
 \end{minipage}
 \vskip 2cm}

% ---------------------------------------------------------------------------- %
% Avis de réception
% ---------------------------------------------------------------------------- %
\newcommand{\avis}[1]{%
 \textbf{\underline{Lettre recommandée AR \No #1}}
 \vskip 1cm}

% ---------------------------------------------------------------------------- %
% Référence
% ---------------------------------------------------------------------------- %
\newcommand{\reference}[1]{%
 Réf: #1
 \vskip 1cm}

% ---------------------------------------------------------------------------- %
% Objet
% ---------------------------------------------------------------------------- %
\newcommand{\objet}[1]{%
 Objet: #1
 \vskip 1cm}

% ---------------------------------------------------------------------------- %
% Corps de la lettre
% ---------------------------------------------------------------------------- %
\newenvironment{corps}[1]{%
 \zsavepos{corps}
 \newlength\yref
 \setlength\yref{197mm}
 \newlength\ypos
 \setlength\ypos{\zposy{corps}sp}
 \ifdim \ypos>\yref \addtolength\ypos{-\yref} \kern\ypos \fi
 \def\titre{#1}
 \titre,
 \vskip 1cm}
{~\\
 ~\\
 \@formule\\
 ~\\
 \hfill\nom
 \ifnum\arabic{page}=1 \thispagestyle{empty} \fi
}

\endinput
