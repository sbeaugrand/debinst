% ---------------------------------------------------------------------------- %
%% \file section.cls
%% \author Sebastien Beaugrand
%% \sa http://beaugrand.chez.com/
%% \copyright CeCILL 2.1 Free Software license
% ---------------------------------------------------------------------------- %
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{section}
\LoadClass{livret}

\def\section#1{%
 \vspace*{7cm}
 \Huge
 \begin{center}#1\end{center}
 \normalsize
 \newpage
}
