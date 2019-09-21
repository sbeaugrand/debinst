% ---------------------------------------------------------------------------- %
%% \file enveloppe.cls
%% \author Sebastien Beaugrand
%% \sa http://beaugrand.chez.com/
%% \copyright CeCILL 2.1 Free Software license
% ---------------------------------------------------------------------------- %
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{enveloppe}
\DeclareOption{C5}{\def\e@w{229mm}\def\e@h{162mm}}
\DeclareOption{C6}{\def\e@w{162mm}\def\e@h{114mm}}
\DeclareOption{DL}{\def\e@w{220mm}\def\e@h{110mm}}
\DeclareOption{normal}{\def\e@c{white}}
\DeclareOption{test}  {\def\e@c{black}}
\DeclareOption{centre}{\def\e@a{center}}
\DeclareOption{droite}{\def\e@a{flushright}}
\ExecuteOptions{DL,normal,centre}
\ProcessOptions

% ---------------------------------------------------------------------------- %
% Mise en page
% ---------------------------------------------------------------------------- %
\RequirePackage{vmargin}
\setmarginsrb{0mm}{0mm}{0mm}{0mm}{0mm}{0mm}{0mm}{0mm}
\renewcommand\normalsize{\@setfontsize\normalsize{14pt}{22pt}}

% ---------------------------------------------------------------------------- %
% Langue
% ---------------------------------------------------------------------------- %
\RequirePackage[francais]{babel}
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}

% ---------------------------------------------------------------------------- %
% Init
% ---------------------------------------------------------------------------- %
\RequirePackage{graphics}
\RequirePackage{xcolor}
\newlength\longueur@texte
\setlength\longueur@texte{100mm}
\newlength\marge@basse
\setlength\marge@basse{20mm}
\newlength\marge@droite
\setlength\marge@droite{\e@w}
\advance\marge@droite-\longueur@texte

% ---------------------------------------------------------------------------- %
% Destinataire
% ---------------------------------------------------------------------------- %
\newcommand\destinataire[1]{%
  \begin{\e@a}
    \fcolorbox{\e@c}{white}{
      \begin{minipage}{\e@h}
        \hfill
        \rotatebox{90}{
          \begin{minipage}{  \marge@droite} ~\end{minipage}
          \begin{minipage}{\longueur@texte}#1\end{minipage}
        }
        \hspace{\marge@basse}
      \end{minipage}
    }
  \end{\e@a}
}

% ---------------------------------------------------------------------------- %
% Expediteur
% ---------------------------------------------------------------------------- %
\newcommand\expediteur[1]{%
  \begin{\e@a}
    \fcolorbox{\e@c}{white}{
      \begin{minipage}{\e@h}
        \hspace{3mm}
        \rotatebox{90}{
          \begin{minipage}{\e@w}
            \begin{center}
              \@setfontsize\normalsize\@xpt\@xiipt #1
            \end{center}
          \end{minipage}
        }
      \end{minipage}
    }
  \end{\e@a}
}

\endinput
