;;; lazemacs-core.el --- package management and initialisation -*- lexical-binding: t; no-byte-compile: t; -*-

(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process
                                 `("git" nil ,buffer t "clone"
                                   ,@(when-let* ((depth (plist-get order :depth)))
                                       (list (format "--depth=%d" depth)
                                             "--no-single-branch"))
                                   ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop
                    (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                  "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
    
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

(use-package emacs
  :ensure nil
  :demand t
  :init
  ;; I am a habitual delete-by-selection user
  (delete-selection-mode 1)
  ;; also, I like to have my delimiters matched automatically
  (electric-pair-mode t)
  ;; setting up fonts because
  ;; ;; 1. the theme I use for some reason fails to properly render certain icons
  ;; ;; 2. aesthetics
  (set-face-attribute 'default nil :font "D2KodingLigatureNerdFont" :height 110)
  (set-fontset-font t 'hangul "Hahmlet") ;; D2Koding is also actually a font for the Korean language but I like how Hahmlet looks more w.r.t. the Korean alphabet
  
  (global-display-line-numbers-mode 1) ;; I want my line numbers displayed too
  (context-menu-mode t)
  (setq treesit-auto-install-grammar 'ask)

  :config
  (keymap-global-set "C-c f s" #'scratch-buffer) ;; I want to be able to pull up the scratch buffer easily
  (keymap-global-set "C-x 4 s" #'window-swap-states) ;; I also want to be able to swap window states with a keybind
  (keymap-global-set "C-x 5 n" #'make-frame) ;; And I want to be able make a new frame with just the scratch buffer

  (add-hook 'dired-mode (lambda () (dired-omit-mode))) ;; I don't need to see all the .*~ files when I open up dired

  ;; (add-to-list 'safe-local-variable-directories
  ;;              (file-truename "~/Documents/research/agentic-memory/"))
  
  :custom
  (enable-recursive-minibuffers t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  ;; half the time, I can't be bothered to do M-<tab> every time, so I use 'complete
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil) ;; I use the British English spelling convention and I honestly can't be arsed to configure emacs for British English as well, so may as well just turn this off.

  (calendar-week-start-day 0) ;; I personally like my calendar week to start on Sundays

  (completion-cycling t) ;; when using completion-at-point, cycle through options
  (display-line-numbers-type 'relative) ;; I discovered relative line numbers and never looked back
  
  (global-visual-line-mode t) ;; word wrapping
  (if (not (server-running-p))
      (start-server)))

(use-package inhibit-mouse
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . inhibit-mouse-mode))

(use-package free-keys
  :ensure t
  :defer t
  :commands free-keys
  :bind
  ("M-F" . free-keys))

(keymap-global-unset "S-SPC")
(keymap-global-set "s-SPC" #'toggle-input-method)

(defvar meow-current-input-method current-input-method)
(defun my/toggle-korean-input-method ()
  (interactive)
  (toggle-korean-input-method)
  (setq meow-current-input-method current-input-method))
 
(keymap-global-set "<Hangul>" #'my/toggle-korean-input-method)

(use-package alert
  :ensure (:wait t)
  :defer t
  :init
  (setq alert-default-style 'message))

(use-package dired-subtree
  :ensure t
  :defer t
  :commands
  (dired-subtree-toggle dired-subtree-cycle)
  :custom
  (dired-subtree-line-prefix " ")
  (dired-subtree-use-backgrounds nil))

(use-package dired-sidebar
  :ensure t
  :defer t
  :bind
  (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :commands
  (dired-sidebar-toggle-sidebar)
  :hook
  (dired-sidebar-mode . dired-omit-mode)
  :custom
  (dired-sidebar-subtree-line-prefix "__")
  (dired-sidebar-theme 'nerd-icons)
  (dired-sidebar-use-term-integration t)
  (dired-sidebar-use-custom-font t)
  (dired-sidebar-no-delete-other-windows t))

(when (memq window-system '(mac ns x))
  (use-package exec-path-from-shell
    :ensure t
    :defer t
    :hook
    (elpaca-after-init . exec-path-from-shell-initialize)))

(provide 'lazemacs-core)
