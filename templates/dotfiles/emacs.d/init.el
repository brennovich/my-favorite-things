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

(use-package go-eldoc
  :ensure t)

(use-package protobuf-mode
  :ensure t)

(defun go-mode-custom ()
  (go-eldoc-setup)
  (setq gofmt-command "goimports")
  (if (not (string-match "go" compile-command))
      (set (make-local-variable 'compile-command)
	   "go build -v && go test -v && go vet"))
  (add-hook 'before-save-hook 'gofmt-before-save)
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-,") 'pop-tag-mark))
(use-package go-mode
  :ensure t
  :init
  (setenv "GOPATH" "/home/brennovich/code/go")
  :config
  (add-hook 'go-mode-hook 'go-mode-custom))

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

(use-package yaml-mode
  :ensure t)

(use-package dtrt-indent
  :ensure t)

(use-package rust-mode
  :ensure t
  :config (setq rust-format-on-save t)
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode)))

;;;;
;; Appearance
;;;;

;; Fonts
(set-face-attribute 'default nil :font "Tamzen 12")
;; (set-face-attribute 'default nil :font "Fira Code 12")

;; Set some padding to emacs window
;; (set-frame-parameter nil 'internal-border-width 12)
;; (custom-theme-set-faces
;;  'base16-grayscale-dark
;;  `(fringe ((t (:background, (plist-get 'base16-grayscale-dark-colors :base00))))))

;; turn off the menu bar and tool bar at the top of each frame because it's distracting
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

;; Changes all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)


;; When you visit a file, point goes to the last place where it
;; was when you previously visited the same file.
;; http://www.emacswiki.org/emacs/SavePlace
(require 'saveplace)
(setq-default save-place t)
(setq save-place-file (concat user-emacs-directory "backup"))

;; Toggle comments
(defun toggle-comment ()
    "Comments or uncomments the region or the current line if there's no active region."
    (interactive)
    (let (beg end)
        (if (region-active-p)
            (setq beg (region-beginning) end (region-end))
            (setq beg (line-beginning-position) end (line-end-position)))
        (comment-or-uncomment-region beg end)
        (next-line)))
(global-set-key (kbd "C-;") 'toggle-comment)


;; Whitespace mode
(setq whitespace-line-column 120
      whitespace-style (quote (tabs newline tab-mark newline-mark))
      whitespace-display-mappings
      '((space-mark 32 [183] [46])
        (newline-mark 10 [172 10])
        (tab-mark 9 [9655 9] [92 9])))

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; m4 template instruction: changequote([`], ['])

;;; init.el ends here
