; ------------------------------------------------------------------------------
;; \file .emacs
;; \author Sebastien Beaugrand
;; \sa http://beaugrand.chez.com/
;; \copyright CeCILL 2.1 Free Software license
; ------------------------------------------------------------------------------
; Recharger la configuration : eval-buffer
; Accents sur un clavier qwerty : C-\
; aspell: apt install aspell-fr
; indent: apt install indent
; astyle: apt install astyle
; w3m   : apt install w3m-el
; emacs-x11 (--with-x-toolkit=lucid): vi /usr/share/applications/emacs.desktop

; Parametres
(setq nb-cols 80)

; Deplacements
(global-set-key [S-right]  'other-window)
(global-set-key [S-left]   #'(lambda () (interactive) (other-window -1)))
(global-set-key [S-up]     #'(lambda () (interactive) (scroll-down   1)))
(global-set-key [S-down]   #'(lambda () (interactive) (scroll-up     1)))
(global-set-key [M-right]  #'(lambda () (interactive) (forward-char  1)
                                                      (scroll-left   1)))
(global-set-key [M-left]   #'(lambda () (interactive) (backward-char 1)
                                                      (scroll-right  1)))
(global-set-key [\home]    'beginning-of-line)
(global-set-key [\end]     'end-of-line)
(global-set-key [(meta g)] 'goto-line)
(mouse-wheel-mode t)
(column-number-mode t)
(show-paren-mode t)
(setq delete-key-deletes-forward t)

; Desactiver secondary-selection
(global-set-key [M-drag-mouse-1] 'mouse-set-region)

; Apparence
(tool-bar-mode 0)
(defun frame-setup ()
  ; Résolution
  (setq x-width  (string-to-number (shell-command-to-string
    "xrdb -symbols | grep DWIDTH  | cut -d '=' -f 2")))
  (setq x-height (string-to-number (shell-command-to-string
    "xrdb -symbols | grep DHEIGHT | cut -d '=' -f 2")))

  ; Font (-font 6x13 pour du <1920)
  (if (< x-width 1920)
    (progn (set-face-font 'default "6x13") (setq x-font 6) (setq y-font 13))
    (if (< x-width 3840)
      (progn (set-face-font 'default "9x15") (setq x-font 9) (setq y-font 15))
      (progn
        (set-face-font 'default "Monospace 6")
        (setq x-font 14) (setq y-font 31)
      )
    )
  )

  ; Couleurs
  (set-background-color "black")
  (set-foreground-color "white")
  (set-cursor-color     "white")
  (set-face-foreground 'menu "wheat")
  (set-face-background 'menu "DarkSlateGray")
  (set-face-background 'scroll-bar "DarkSlateGray")
  (set-face-background 'region "DarkSlateGray")
  (add-hook 'sh-mode-hook #'(lambda ()
    (set-face-foreground 'sh-heredoc "wheat")))
)
(frame-setup)

; Encodage des caracteres
(set-language-environment 'UTF-8)

; Accents avec un clavier qwerty. Activation et desactivation par C-\
(setq default-input-method "french-postfix")

; Supplements
(if (file-exists-p "~/.emacs-plus") (load "~/.emacs-plus"))

; Taille et position de la fenetre (-geometry 255x73+54+0 pour du 1680x1050)
(setq win-num  1)
(setq win-edge 6)
(setq win-ypos 0)
(setq win-num (truncate (/ x-width (* x-font nb-cols))))
(if ( = x-width 1024) (progn (set-scroll-bar-mode nil) (setq win-edge 3)))
(if ( = x-width 1920) (setq win-edge 4))
(if (>  x-width 1920) (setq win-edge 4))
(if (>  x-width 1920) (setq win-ypos 64))
(if (> win-num 1) (progn
  (setq win-width (+ (* nb-cols win-num) (* win-edge (- win-num 1))))
  (setq win-height (/ (- x-height 75) y-font))
  (setq win-xpos (- x-width (* (+ win-width (+ win-edge 1)) x-font)))
  (random t)
  (setq win-xpos (random win-xpos))
  (setq initial-frame-alist (list
    (cons 'top win-ypos)
    (cons 'left win-xpos)
    (cons 'width win-width)
    (cons 'height win-height)))
))

; Titre de la fenetre
(setq frame-title-format "Emacs")

; Curseur non clignotant
(blink-cursor-mode 0)

; Cloche silencieuse
(setq visible-bell t)

; Remplacement des tabulations par des espaces
(defun indent-setup (num)
  (setq c-default-style "linux")
  (if (and (boundp 'c-buffer-is-cc-mode) c-buffer-is-cc-mode)
    (c-set-style "linux"))
  (setq c-basic-offset num)
  (setq indent-tabs-mode nil)
  (setq tab-width num)
)
(defun indent2 ()
  (interactive)
  (indent-setup 2)
)
(defun indent4 ()
  (interactive)
  (indent-setup 4)
)
(defun tabwidth4 ()
  (interactive)
  (setq tab-width 4)
)
(add-hook      'makefile-mode-hook 'tabwidth4)
(add-hook           'c++-mode-hook 'indent4)
(add-hook             'c-mode-hook 'indent4)
(add-hook            'sh-mode-hook 'indent4)
(add-hook           'php-mode-hook 'indent4)
(add-hook            'js-mode-hook 'indent2)
(add-hook    'javascript-mode-hook 'indent2)
(add-hook 'nxhtml-mumamo-mode-hook 'indent4)
(add-hook         'cmake-mode-hook 'indent4)
(add-hook          'html-mode-hook 'indent2)
(add-hook          'scad-mode-hook 'indent2)
(add-hook           'awk-mode-hook 'indent4)
(setq cmake-tab-width 4)
(setq js-indent-level 2)

; Suppression des espaces en fin de ligne a l'enregistrement
(add-hook 'c++-mode-hook #'(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook   'c-mode-hook #'(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook  'sh-mode-hook #'(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))
(add-hook  'js-mode-hook #'(lambda ()
  (add-hook 'write-contents-hooks 'delete-trailing-whitespace nil t)))

; HTML / PHP / JavaScript
(autoload 'php-mode "php-mode" nil t)
(autoload 'javascript-mode "javascript" nil t)
(autoload 'nxhtml-mumamo-mode "nxhtml/autostart.el" nil t)
(add-hook 'nxhtml-mumamo-mode-hook #'(lambda ()
  (setq mumamo-background-colors nil)
  (font-lock-mode 0)
  (font-lock-mode 1)))

; Modes
(add-to-list 'auto-mode-alist '( ".php$"    . php-mode))
(add-to-list 'auto-mode-alist '(".wsdl$"    . sgml-mode))
(add-to-list 'auto-mode-alist '( ".xsd$"    . sgml-mode))
(add-to-list 'auto-mode-alist '( ".pro$"    . makefile-mode))
(add-to-list 'auto-mode-alist '( ".pri$"    . makefile-mode))
(add-to-list 'auto-mode-alist '( "Makefile" . makefile-mode))

; Indent
(defun indent (pmin pmax)
  (interactive "r")
  (shell-command-on-region pmin pmax
    "indent -orig -l80 -npsl -cdw -nut -c0 -cd0"
    (current-buffer) t (get-buffer-create "*Indent Errors*") t))

; Artistic Style
(defun astyle (pmin pmax)
  (interactive "r")
  (shell-command-on-region pmin pmax "astyle -apUc"
    (current-buffer) t (get-buffer-create "*Astyle Errors*") t))

; Uncrustify
(defun uncrustify (pmin pmax)
  (interactive "r")
  (shell-command-on-region pmin pmax "uncrustify -q -l CPP -c ~/.uncrustify.cfg"
    (current-buffer) t (get-buffer-create "*Uncrustify Errors*") t))

; Commandes shell
(autoload 'dired-run-shell-command "dired-aux" nil t)
(defun purge () (interactive) (dired-run-shell-command "rm -fv *~"))
(defun make  () (interactive) (dired-run-shell-command "make &"))

; Web
(provide 'w3m-e23)
(autoload 'w3m "w3m-load" nil t)
(autoload 'w3m-find-coding-system "w3m-e21" nil t)
(setq w3m-use-cookies t)

; Une, deux, ou trois fenetres
(defun after-make-frame (frame)
  (select-frame frame)
  (frame-setup)
  (setq win-width (+ (* nb-cols num) (* win-edge (- num 1))))
  (set-frame-position frame win-xpos win-ypos)
  (set-frame-size frame win-width win-height)
  (if (> num 2)
      (split-window (selected-window) (* (+ nb-cols win-edge) 2) t nil))
  (if (> num 1)
      (split-window (selected-window)    (+ nb-cols win-edge)    t nil))
  (delete-frame (previous-frame))
)
(global-set-key [f1] #'(lambda () (interactive)
  (setq after-make-frame-functions 'after-make-frame)
  (setq num 1) (if (< win-num num) (setq num win-num))
  (make-frame)
))
(global-set-key [f2] #'(lambda () (interactive)
  (setq after-make-frame-functions 'after-make-frame)
  (setq num 2) (if (< win-num num) (setq num win-num))
  (make-frame)
))
(global-set-key [f3] #'(lambda () (interactive)
  (setq after-make-frame-functions 'after-make-frame)
  (setq num 3) (if (< win-num num) (setq num win-num))
  (make-frame)
))

; Sauvegarde des positions dans les fichiers utilises
(require 'saveplace)
(save-place-mode t)

; Sauvegarde des derniers noms de fichiers utilises
(defun save-prev-buffer-file-name ()
  (other-window -1)
  (if buffer-file-name (progn
    (setq list-buffers (cons (list buffer-file-name) list-buffers))
    (kill-this-buffer)
  ))
)
(add-hook 'kill-emacs-hook #'(lambda ()
  (select-window (window-at 0 0))
  (setq list-buffers nil)
  (if (> win-num 2) (save-prev-buffer-file-name))
  (if (> win-num 1) (save-prev-buffer-file-name))
  (save-prev-buffer-file-name)
  (set-buffer (get-buffer-create "*Saved Last*"))
  (delete-region (point-min) (point-max))
  (print list-buffers (current-buffer))
  (write-region (point-min) (point-max) "~/.emacs-last")
))

; Chargement des derniers fichiers utilises
(global-set-key [f4] #'(lambda () (interactive)
  (if (file-readable-p "~/.emacs-last") (progn
    (delete-other-windows)
    (find-file "~/.emacs-last")
    (setq last-buffers
      (car (read-from-string (buffer-substring (point-min) (point-max)))))
    (kill-buffer ".emacs-last")
    (if (> win-num 2)
      (progn
        (if (caar (cddr last-buffers)) (find-file (caar (cddr last-buffers))))
        (split-window (selected-window) (* (+ nb-cols win-edge) 2) 1)
      )
    )
    (if (> win-num 1)
      (progn
        (if (car  (cadr last-buffers)) (find-file (car  (cadr last-buffers))))
        (split-window (selected-window) (+ nb-cols win-edge) 1)
      )
    )
    (if (caar last-buffers) (find-file (caar last-buffers)))
  ))
))

; Buffer precedent
(setq last-prev-buffer nil)
(global-set-key [f5] #'(lambda () (interactive)
  (setq last-prev-buffer (current-buffer))
  (switch-to-buffer (other-buffer))
))
(global-set-key [f6] #'(lambda () (interactive)
  (switch-to-buffer (other-buffer last-prev-buffer))
))

; Ajustements des fenetres
(global-set-key [f7]  'shrink-window-horizontally)
(global-set-key [f8] 'enlarge-window-horizontally)

; Justification
(defun justify-buffer ()
  (if mark-active
    (progn (setq min (mark))
           (setq max (point)))
  )
  (fill-region min max)
)
(global-set-key [f10] #'(lambda () (interactive)
  (justify-buffer)
))

; Largeur du texte
(add-hook  'tex-mode-hook #'(lambda ()
			      (setq fill-column nb-cols) (auto-fill-mode 1)))
(add-hook 'text-mode-hook #'(lambda ()
			      (setq fill-column nb-cols) (auto-fill-mode 1)))

; Orthographe
(setq flyspell-mode nil)
(setq ispell-program-name "aspell")
(setq ispell-dictionary "francais")
(setq flyspell-large-region 10000)

(global-set-key [f11] #'(lambda () (interactive)
  (if flyspell-mode
    (flyspell-mode 0)
    (progn
      (flyspell-mode 1)
      (if mark-active
        (flyspell-region (mark) (point))
        (flyspell-buffer)
      )
    )
  )
))

; Clean
(defun clean () (interactive)
  (shell-command "rm -f ~/.bash_history~ ~/.viminfo ~/.vim/.netrwhist")
  (shell-command "rm -f ~/.w3m/history ~/.w3m/bufinfo ~/.w3m/cookie"))

; Aide sur les touches
(defun key-bindings-help ()
  (set-buffer (get-buffer-create "*Key Bindings Help*"))
  (delete-region (point-min) (point-max))
  (insert "F1         Une fenetre de 80 colonnes\n")
  (insert "F2         Deux fenetres de 80 colonnes\n")
  (insert "F3         Trois fenetres de 80 colonnes\n")
  (insert "F4         Charger les derniers fichiers utilises\n")
  (insert "F5         Buffer precedent\n")
  (insert "F6         Buffer precedent 2\n")
  (insert "F7         Retrecir la fenetre\n")
  (insert "F8         Agrandir la fenetre\n")
  (insert "F10        Justifier\n")
  (insert "F11        Orthographe\n")
  (insert "F12        Aide sur les touches\n")
  (insert "<S-right>  Fenetre de droite\n")
  (insert "<S-left>   Fenetre de gauche\n")
  (insert "<S-up>     Defiler vers le haut\n")
  (insert "<S-down>   Defiler vers le bas\n")
  (insert "<M-right>  Defiler vers la droite\n")
  (insert "<M-left>   Defiler vers la gauche\n")
  (insert "<home>     Debut de ligne\n")
  (insert "<end>      Fin de ligne\n")
  (insert "<M-g>      Aller a une ligne\n")
  (insert "astyle     Indenter\n")
  (insert "indent     Indenter\n")
  (insert "make       Compiler\n")
  (insert "purge      Supprimer les fichiers temporaires\n\n")
  (insert "C-x C-f    find-file\n")
  (insert "C-x C-s    save-buffer\n")
  (insert "C-x C-c    save-buffers-kill-terminal\n")
  (insert "C-SPC      set-mark-command\n")
  (insert "M-w        kill-ring-save\n")
  (insert "C-w        kill-region\n")
  (insert "C-y        yank\n")
  (insert "C-s        isearch-forward\n")
  (insert "C-r        isearch-backward\n")
  (insert "C-s C-w    forward word search\n")
  (insert "M-%        query-replace\n")
  (insert "<C-down>   forward-paragraph\n")
  (insert "<C-end>    end-of-buffer\n")
  (insert "<C-home>   beginning-of-buffer\n")
  (insert "<C-left>   backward-word\n")
  (insert "<C-next>   scroll-left\n")
  (insert "<C-prior>  scroll-right\n")
  (insert "<C-right>  forward-word\n")
  (insert "<C-up>     backward-paragraph\n")
  (insert "C-x h      mark-whole-buffer\n")
  (insert "M-x        execute-extended-command\n")
  (insert "C-g        keyboard-quit\n")
  (insert "C-_        undo\n")
  (insert "C-g C-_    undo undo\n")
  (insert "TAB        indent-for-tab-command\n")
  (insert "M-^        join-line\n")
  (insert "C-M-f      forward-sexp\n")
  (insert "C-M-b      backward-sexp\n")
  (insert "C-x r t    string-rectangle\n")
  (insert "C-x r k    kill-rectangle\n")
  (insert "C-x r y    yank-rectangle\n")
  (insert "C-h f      describe-function\n")
  (insert "C-h v      describe-variable\n")
  (goto-char 0)
  (switch-to-buffer (current-buffer))
)
(global-set-key [f12] #'(lambda () (interactive) (key-bindings-help)))

; Gtk notify_startup_complete
(shell-command "~/.local/bin/notify_startup_complete.py")
