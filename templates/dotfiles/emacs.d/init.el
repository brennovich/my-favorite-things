changequote(`[', `]')
;;;;
;; Packages
;;;;

;; Define package repositories
(require 'package)

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives
             '("gnu" . "http://elpa.gnu.org/packages/"))

;; Load and activate emacs packages. Do this first so that the
;; packages are loaded before you start trying to modify them.
;; This also sets the load path.
(package-initialize)

;; The packages you want installed. You can also install these
;; manually with M-x package-install
;; Add in your own as you wish:
(defvar my-packages
'(
  base16-theme
  ensime
  ido-vertical-mode
  magit
  markdown-mode
  org
  projectile
  ))

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;;;;
;; Appearance
;;;;

;; increase font size for better readability
(set-face-attribute 'default nil :font "Tamzen 20")

;; Color theme
(load-theme 'base16-grayscale-dark t)
 
;; Set some padding to emacs window
(set-frame-parameter nil 'internal-border-width 12)
(custom-theme-set-faces
 'base16-grayscale-dark
 `(fringe ((t (:background, (plist-get base16-grayscale-dark-colors :base00))))))

;; Turn off the menu bar and tool bar at the top of each frame because it's distracting
(menu-bar-mode -1)
(tool-bar-mode -1)

;; Don't show native OS scroll bars for buffers because they're redundant
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; Display line number in statusbar
(setq column-number-mode t)

;; Go straight to scratch buffer on startup
(setq inhibit-startup-message t)

;; no bell
(setq ring-bell-function 'ignore)

;; These settings relate to how emacs interacts with your operating system
(setq ;; makes killing/yanking interact with the clipboard
      x-select-enable-clipboard t

      ;; I'm actually not sure what this does but it's recommended?
      x-select-enable-primary t

      ;; Save clipboard strings into kill ring before replacing them.
      ;; When one selects something in another program to paste it into Emacs,
      ;; but kills something in Emacs before actually pasting it,
      ;; this selection is gone unless this variable is non-nil
      save-interprogram-paste-before-kill t

      ;; Shows all options when running apropos. For more info,
      ;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Apropos.html
      apropos-do-all t

      ;; Mouse yank commands yank at point instead of at click.
      mouse-yank-at-point t)

;;;;
;; Editing
;;;;

;; Highlights matching parenthesis
(show-paren-mode 1)

;; Highlight current line
(global-hl-line-mode 1)

;; Always reload the file if it changed on disk
(global-auto-revert-mode 1)

;;;;
;; Modes
;;;;

;;; Org
(setq org-src-fontify-natively t)

;;; IDO
(require 'ido-vertical-mode)

(setq ido-enable-flex-matching t)
(setq ido-everywhere t)

(ido-mode 1)
(ido-vertical-mode 1)

;;; Projectile
(projectile-global-mode)

changequote([`], ['])
