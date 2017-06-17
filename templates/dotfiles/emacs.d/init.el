;;; init.el --- brennovich's Emacs settings

;;; Commentary:

;;   This tries to be simplier as possible.
;;
;; m4 template instruction: changequote(`[', `]')

;;; Code:

;; Define package repositories
(require 'package)

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("gnu" . "http://elpa.gnu.org/packages/"))

;; Install `use-package.el`
(package-initialize)
(if (not (package-installed-p 'use-package))
    (progn
      (package-refresh-contents)
      (package-install 'use-package)))

(require 'use-package)

(use-package base16-theme
  :ensure t
  :config (load-theme 'base16-grayscale-dark t))

(use-package ensime
  :ensure t)

(use-package flycheck
  :ensure t
  :config (global-flycheck-mode))

(use-package go-mode
  :ensure t
  :config (setenv "GOPATH" "/home/brennovich/code/go"))

(use-package ido-vertical-mode
  :ensure t
  :init
  (setq ido-enable-flex-matching t
        ido-everywhere t)
  (ido-mode 1)
  :config (ido-vertical-mode 1))

(use-package magit
  :ensure t
  :bind ("C-c C-g s" . magit-status))

(use-package markdown-mode
  :ensure t)

(use-package org
  :ensure t
  :init (setq org-src-fontify-natively t
              org-completion-use-ido t
              org-startup-indented t
              org-default-notes-file "~/Dropbox/orgs/my-life.org"))

(use-package projectile
  :ensure t
  :config (projectile-global-mode))

;;;;
;; Appearance
;;;;

;; Fonts
(set-face-attribute 'default nil :font "Tamzen 20")
;; (set-face-attribute 'default nil :font "Fira Code 12")

;; Set some padding to emacs window
(set-frame-parameter nil 'internal-border-width 12)
(custom-theme-set-faces
 'base16-grayscale-dark
 `(fringe ((t (:background, (plist-get 'base16-grayscale-dark-colors :base00))))))

;; Turn off the menu bar and tool bar at the top of each frame because it's distracting
(menu-bar-mode -1)
(tool-bar-mode -1)

;; Don't show native OS scroll bars for buffers because they're redundant
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; These settings relate to how emacs interacts with your operating system
(setq
 ;; Save clipboard strings into kill ring before replacing them.
 ;; When one selects something in another program to paste it into Emacs,
 ;; but kills something in Emacs before actually pasting it,
 ;; this selection is gone unless this variable is non-nil
 save-interprogram-paste-before-kill t

 ;; Mouse yank commands yank at point instead of at click.
 mouse-yank-at-point t

 ;; Display line number in statusbar
 column-number-mode t

 ;; Go straight to scratch buffer on startup
 inhibit-startup-message t

 ;; no bell
 ring-bell-function 'ignore)

;;;;
;; Editing
;;;;

;; Stop spreading backup files
(make-directory "~/.emacs.d/backup/" t)
(setq backup-directory-alist `(("." . "~/.emacs.d/backup"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; Highlights matching parenthesis
(show-paren-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; Always reload the file if it changed on disk
(global-auto-revert-mode 1)

;; hippie expand is dabbrev expand on steroids
(global-set-key (kbd "M-/") 'hippie-expand)
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                         try-expand-dabbrev-all-buffers
                                         try-expand-dabbrev-from-kill
                                         try-complete-file-name-partially
                                         try-complete-file-name
                                         try-expand-all-abbrevs
                                         try-expand-list
                                         try-expand-line
                                         try-complete-lisp-symbol-partially
                                         try-complete-lisp-symbol))

;; m4 template instruction: changequote([`], ['])

;;; init.el ends here
