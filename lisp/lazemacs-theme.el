;;; -*- lexical-binding: t; -*-

(custom-set-variables
 '(org-agenda-files
   '("/home/dania/org/agentic-memory.org" "/home/dania/org/calendar.org"
     "/home/dania/org/daily.org" "/home/dania/org/meeting.org"
     "/home/dania/org/todo.org" "/home/dania/org/slack.org")))

(let (;; temporarily increase `gc-cons-threshold' when loading to speed up startup.
    (gc-cons-threshold most-positive-fixnum)
    ;; Empty to avoid analyzing files when loading remote files.
    (file-name-handler-alist nil))
  )

(setq custom-file (make-temp-file "emacs-custom-"))
(profiler-start 'cpu+mem)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'lazemacs-core)
(require 'lazemacs-comp)
(require 'lazemacs-prelude)
(require 'lazemacs-style)
(require 'lazemacs-buffers)
(require 'lazemacs-completion)
(require 'lazemacs-terminal)
(require 'lazemacs-keybinds)
(require 'lazemacs-help)
(require 'lazemacs-windows)
(require 'lazemacs-secrets)
(require 'lazemacs-projects)
(require 'lazemacs-ide)
(require 'lazemacs-org)
(require 'lazemacs-bib)
(require 'lazemacs-misc)
(require 'lazemacs-theme)

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

  (add-hook 'dired-mode #'dired-omit-mode) ;; I don't need to see all the .*~ files when I open up dired

  (add-to-list 'safe-local-variable-directories
               (file-truename "~/Documents/research/agentic-memory/"))
  
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

;; Enable Vertico.
(use-package vertico
  :ensure t
  :defer t
  :custom
  (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 20) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :hook
  (elpaca-after-init . vertico-mode)
  :config
  (defun my/vertico-insert ()
    (interactive)
    (let* ((mb (minibuffer-contents-no-properties))
           (lc (if (string= mb "") mb (substring mb -1))))
      (cond ((string-match-p "^[/~:]" lc) (self-insert-command 1 ?/))
            ((file-directory-p (vertico--candidate)) (vertico-insert))
            (t (self-insert-command 1 ?/)))))

  (setq vertico-multiform-commands
        '(("\\`execute-extended-command" unobtrusive
           (vertico-flat-annotate . t)
           (marginalia-annotators (command marginalia-annotate-binding)))))

  (defun down-from-outside ()
    "Move to next candidate in minibuffer, even when minibuffer isn't selected."
    (interactive)
    (with-selected-window (active-minibuffer-window)
      (execute-kbd-macro [down])))

  (defun up-from-outside ()
    "Move to previous candidate in minibuffer, even when minibuffer isn't selected."
    (interactive)
    (with-selected-window (active-minibuffer-window)
      (execute-kbd-macro [up])))

  (defun to-and-fro-minibuffer ()
    "Go back and forth between minibuffer and other window."
    (interactive)
    (if (window-minibuffer-p (selected-window))
        (select-window (minibuffer-selected-window))
      (select-window (active-minibuffer-window))))

  (defun +embark-live-vertico ()
    "Shrink Vertico minibuffer when `embark-live' is active."
    (when-let (win (and (string-prefix-p "*Embark Live" (buffer-name))
                        (active-minibuffer-window)))
      (with-selected-window win
        (when (and (bound-and-true-p vertico--input)
                   (fboundp 'vertico-multiform-unobtrusive))
          (vertico-multiform-unobtrusive)))))
  
  (add-hook 'embark-collect-mode-hook #'+embark-live-vertico)
  
  :bind
  (:map vertico-map
        ("/" . #'my/vertico-insert)))

(use-package vertico-buffer
  :ensure nil
  :after vertico)

(use-package vertico-grid
  :ensure nil
  :after vertico)

(use-package vertico-multiform
  :ensure nil
  :after vertico
  :init
  (defun vertico-multiform-buffer-grid ()
    "Toggle displaying Vertico as a grid in a large window (like a regular buffer)."
    (interactive)
    (if (equal '(vertico-buffer-mode vertico-grid-mode) (car vertico-multiform--stack))
        (vertico-multiform-vertical)
      (setcar vertico-multiform--stack '(vertico-buffer-mode vertico-grid-mode))
      (vertico-multiform--toggle 1)))
  
  :bind
  (:map vertico-multiform-map ("M-H" . vertico-multiform-buffer-grid)))

(use-package vertico-directory
  :ensure nil
  :after vertico
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET"   . vertico-directory-enter)
              ("DEL"   . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-posframe
  :ensure t
  :after (vertico posframe)
  :defer t
  :hook
  ((elpaca-after-init-hook vertico-mode) . vertico-multiform-mode)
  :custom
  (vertico-multiform-commands
   '((consult-line
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-frame-center)
      (vertico-posframe-border-width . 10)
      ;; NOTE: This is useful when emacs is used in both in X and
      ;; terminal, for posframe do not work well in terminal, so
      ;; vertico-buffer-mode will be used as fallback at the
      ;; moment.
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (consult-ripgrep
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-frame-center)
      (vertico-posframe-border-width . 10)
      ;; NOTE: This is useful when emacs is used in both in X and
      ;; terminal, for posframe do not work well in terminal, so
      ;; vertico-buffer-mode will be used as fallback at the
      ;; moment.
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (consult-locate
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-frame-center)
      (vertico-posframe-border-width . 10)
      ;; NOTE: This is useful when emacs is used in both in X and
      ;; terminal, for posframe do not work well in terminal, so
      ;; vertico-buffer-mode will be used as fallback at the
      ;; moment.
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (consult-find
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-point-bottom-center)
      (vertico-posframe-border-width . 10)
      ;; NOTE: This is useful when emacs is used in both in X and
      ;; terminal, for posframe do not work well in terminal, so
      ;; vertico-buffer-mode will be used as fallback at the
      ;; moment.
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (consult-grep
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-frame-center)
      (vertico-posframe-border-width . 10)
      ;; NOTE: This is useful when emacs is used in both in X and
      ;; terminal, for posframe do not work well in terminal, so
      ;; vertico-buffer-mode will be used as fallback at the
      ;; moment.
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (consult-git-grep
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-frame-center)
      (vertico-posframe-border-width . 10)
      ;; NOTE: This is useful when emacs is used in both in X and
      ;; terminal, for posframe do not work well in terminal, so
      ;; vertico-buffer-mode will be used as fallback at the
      ;; moment.
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (consult-line-multi
      posframe
      (vertico-posframe-poshandler . posframe-poshandler-frame-center)
      (vertico-posframe-border-width . 10)
      ;; NOTE: This is useful when emacs is used in both in X and
      ;; terminal, for posframe do not work well in terminal, so
      ;; vertico-buffer-mode will be used as fallback at the
      ;; moment.
      (vertico-posframe-fallback-mode . vertico-buffer-mode))
     (t posframe
        (vertico-posframe-poshandler . posframe-poshandler-frame-bottom-center)
        (vertico-posframe-fallback-mode . vertico-mode)))))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure nil
  :defer t
  :hook
  (elpaca-after-init . savehist-mode)
  :config
  (setq history-length 15))

(use-package orderless
  :ensure t
  :defer t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

(use-package marginalia
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . marginalia-mode))

(use-package nerd-icons-completion
  :ensure t :after (nerd-icons marginalia)
  :defer t
  ;; :after marginalia
  :hook
  (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config
  (nerd-icons-completion-mode))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :ensure t
  :defer t
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. 
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ("C-c & C-s" . consult-yasnippet)         ;; orig. yas-insert-snippet
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element
    ;; The :init configuration is always executed (Not lazy)
  :init
  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)
  
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  
  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config
  
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  (setq consult-narrow-key "C-+") ;; 

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)

(use-package embark
  :ensure t
  :defer t
  :bind
  (("C-." . embark-act)
   ("M-." . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :hook
  (eldoc-documentation-functions . embark-eldoc-first-target)
  :custom
  (eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect\\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))

  (defun +embark-live-vertico ()
    "Shrink Vertico minibuffer when `embark-live' is active."
    (when-let (win (and (string-prefix-p "*Embark Live" (buffer-name))
                        (active-minibuffer-window)))
      (with-selected-window win
        (when (and (bound-and-true-p vertico--input)
                   (fboundp 'vertico-multiform-unobtrusive))
          (vertico-multiform-unobtrusive)))))

  (add-hook 'embark-collect-mode-hook #'+embark-live-vertico))

(use-package embark-consult
  :ensure t
  :defer t
  :after (embark consult))

(use-package transient
  :defer t
  :ensure t)

(use-package context-transient
  :ensure t
  :after transient
  :defer t
  :bind
  ("C-c t SPC" . context-transient)) 

(use-package corfu
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . global-corfu-mode)
  (global-corfu-mode . corfu-history-mode)
  (global-corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-cycle t)
  (corfu-quit-at-boundary nil)
  (corfu-quit-no-match nil)
  (setq global-corfu-minibuffer
	(lambda ()
	  (not (or (bound-and-true-p mct--active)
		   (bound-and-true-p vertico--input)
		   (eq (current-local-map) read-passwd-map)))))
  (corfu-separator ?_)
  :hook
  (eshell-mode . (lambda ()
		   (setq-local corfu-auto nil)
		   (corfu-mode)))
  (corfu-mode . (lambda ()
		  ;; Settings only for Corfu
		  (setq-local completion-styles '(basic)
			      completion-category-overrides nil
			      completion-category-defaults nil)))
  :bind
  (:map corfu-map ("SPC" . corfu-insert-separator))
  :config
  (keymap-unset corfu-map "RET")
  (keymap-set corfu-map "RET" `( menu-item "" nil :filter
				 ,(lambda (&optional _)
				    (and (derived-mode-p 'eshell-mode 'comint-mode)
					 #'corfu-send)))))

(use-package corfu-candidate-overlay
  :ensure t
  :after corfu
  :defer t
  :hook
  (global-corfu-mode . corfu-candidate-overlay-mode)
  :config
  (keymap-global-set "C-<tab>" 'completion-at-point)
  (keymap-global-set "C-<iso-lefttab>" 'corfu-candidate-overlay-complete-at-point))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :defer t
  :custom
  ;; Optionally:
  (nerd-icons-corfu-mapping
   '((array :style "cod" :icon "symbol_array" :face font-lock-type-face)
     (boolean :style "cod" :icon "symbol_boolean" :face font-lock-builtin-face)
     ;; You can alternatively specify a function to perform the mapping,
     ;; use this when knowing the exact completion candidate is important.
     ;; Don't pass `:face' if the function already returns string with the
     ;; face property, though.
     (file :fn nerd-icons-icon-for-file :face font-lock-string-face)
     ;; ...
     (t :style "cod" :icon "code" :face font-lock-warning-face)))
  ;; If you add an entry for t, the library uses that as fallback.
  ;; The default fallback (when it's not specified) is the ? symbol.

  ;; The Custom interface is also supported for tuning the variable above.
  :config
  ;; add hook only after corfu has been loaded
  (add-hook 'global-corfu-mode (lambda () (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))))

(use-package corfu-terminal
  :ensure t
  :after corfu
  :defer t
  :if (or (featurep 'tty-child-frames) (display-graphic-p))
  :hook
  (global-corfu-mode . corfu-terminal-mode))

(use-package cape
  :ensure t
  :defer t
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c p ? to for help.
  :bind ("C-c p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  ;; Alternatively bind Cape commands individually.
  ;; :bind (("C-c p d" . cape-dabbrev)
  ;;        ("C-c p h" . cape-history)
  ;;        ("C-c p f" . cape-file)
  ;;        ...)
  :hook
  (completion-at-point-functions . cape-dabbrev)
  (completion-at-point-functions . cape-file)
  (completion-at-point-functions . cape-elisp-block)
  (completion-at-point-functions . cape-history))

(use-package prescient
  :defer t
  :ensure t)

(use-package corfu-prescient
  :ensure t
  :after (corfu prescient)
  :defer t
  :hook
  (global-corfu-mode . corfu-prescient-mode))

(use-package vertico-prescient
  :ensure t
  :after (vertico prescient)
  :defer t
  :hook
  (vertico-mode . vertico-prescient-mode))

(defun my/open-config-file ()
  (interactive)
  (get-buffer-create (find-file (expand-file-name "config.org" "~/.emacs.d/"))))

(keymap-global-set "C-c f p" #'my/open-config-file)

(defun my/split-window-left ()
  (interactive)
  (select-window (split-window-right)))

(defun my/split-window-below ()
  (interactive)
  (select-window (split-window-below)))

(keymap-global-set "C-x 2" #'my/split-window-below)
(keymap-global-set "C-x 3" #'my/split-window-left)

(use-package vertigo
  :ensure t
  :defer t
  :custom
  (vertigo-max-digits 3)
  (vertigo-cut-off 9) 
  :config
  (keymap-global-set "M-n" #'vertigo-jump-down) ;; based on C-n to go to the next line
  (keymap-global-set "M-p" #'vertigo-jump-up)) ;; based on C-p to go to the previous line

(defun my/meow-deactivate-input-method ()
  (interactive)
  (when meow-current-input-method
    (deactivate-input-method)))
  
(defun my/meow-reactivate-input-method ()
  (interactive)
  (when meow-current-input-method
    (activate-input-method meow-current-input-method)))

(use-package meow
  :ensure t
  :demand t
  :init
  (defvar meow-input-method nil)
  :hook
  (meow-insert-exit . my/meow-deactivate-input-method)
  (meow-insert-enter . my/meow-reactivate-input-method)
  :custom
  (meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  :config
  (defun my/meow-qwerty-setup ()
    (meow-motion-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet)
     '("." . embark-act)
     '("a" . beginning-of-line)
     '("e" . end-of-line)
     '("j" . vertigo-jump-down)
     '("k" . vertigo-jump-up)
     '("l" . recenter-top-bottom))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . delete-char)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)))
  (my/meow-qwerty-setup)
  (meow-global-mode 1))

(use-package conda
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . conda-env-autoactivate-mode)
  :config
  (conda-env-initialize-interactive-shells)
  (conda-env-initialize-eshell)
  (conda-mode-line-setup))

(use-package python
  :defer t
  :ensure (:wait t)
  :mode
  (("\\.py\\'" . python-ts-mode)
   ("\\.pyi\\'" . python-ts-mode)
   ("\\.pyw\\'" . python-ts-mode))
  :hook
  (conda-env-autoactivate-mode . (lambda ()
                                   (setq python-shell-exec-path conda-env-current-path)))
  (python-mode . lsp-deferred)
  (python-ts-mode . lsp-deferred)
  (python-mode . subword-mode)
  (python-ts-mode . subword-mode)
  (python-ts-mode . python-mode)
  :init
  (setq python-indent-offset 4)
  (setq PYTHONPATH (file-truename "~/miniforge3/bin/python"))
  (setenv "PYTHONPATH" PYTHONPATH)
  (setq python-shell-interpreter PYTHONPATH)
  (setq python-interpreter PYTHONPATH)
  
  (defun my/python-setup ()
    (define-derived-mode python-mode prog-mode "Python"
      ...
      (cond
       ;; Tree-sitter.
       ((treesit-ready-p 'python)
        (treesit-parser-create 'python)
        (setq-local treesit-font-lock-settings python--treesit-settings)
        (setq-local treesit-font-lock-feature-list
                    '((comment string function-name)
                      (class-name keyword builtin)
                      (string-interpolation decorator)))
        (treesit-major-mode-setup))
       (t
        ;; No tree-sitter, do nothing or fallback to another mode.
        ...))))

  (add-hook 'elpaca-after-init-hook #'my/python-setup))

(use-package anaconda-mode
  :ensure t
  :defer t
  :hook
  (python-mode . anaconda-mode)
  (python-ts-mode . anaconda-mode)
  (python-mode . anaconda-eldoc-mode)
  (python-ts-mode . anaconda-eldoc-mode))

(use-package code-cells
  :ensure t
  :after python
  :defer t
  :mode
  ("\\.ipynb\\'" . code-cells-mode)
  :hook
  (code-cells-mode . run-python)
  :bind
  (:map code-cells-mode-map
        ("C-c C-c" . code-cells-eval)
        ("M-p" . code-cells-backward-cell)
        ("M-n" . code-cells-forward-cell)
	("<remap> <jupyter-eval-line-or-region>" . code-cells-eval))
  :config
  (add-to-list 'code-cells-convert-ipynb-style '("jupytext" "--to" "py:percent"))
  (defun my/code-cells-new-cell ()
    (interactive)
    (newline 2)
    (code-cells-forward-cell)
    (insert "# %%")
    (newline))

  (defun my/code-cells-eval-and-step ()
    (interactive)
    (call-interactively #'code-cells-eval-and-step)
    (when (= (point) (point-max))
      (my/code-cells-new-cell)))
  
  (defun my/code-cells-write-ipynb (file)
    (when (string= (file-name-extension file) "ipynb")
        (code-cells-write-ipynb file)))
  
  (add-hook 'treemacs-create-file-functions #'my/code-cells-write-ipynb)
  
  (keymap-set code-cells-mode-map "C-c C-n" #'my/code-cells-new-cell)
  (keymap-set code-cells-mode-map "C-c C-s" #'my/code-cells-eval-and-step))

(use-package pinentry
  :ensure t
  :defer t
  :config
  (pinentry-start))

(use-package magit
  :ensure (:wait t)
  :defer t
  :bind
  (("C-x g" . magit-status)
   ("C-x M-g" . magit-dispatch)
   ("C-c M-g" . magit-file-dispatch))
  :config
  (remove-hook 'server-switch-hook 'magit-commit-diff)
  (remove-hook 'with-editor-filter-visit-hook 'magit-commit-diff))

(use-package magit-lfs
  :ensure t
  :after magit
  :defer t)

(use-package diff-hl
  :ensure t
  :defer t
  :hook
  (magit-post-refresh . diff-hl-magit-post-refresh)
  (magit-mode . diff-hl-mode)
  :config
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  (add-hook 'diff-hl-mode-on-hook
            (lambda ()
              (unless (display-graphic-p)
                (diff-hl-margin-local-mode)))))

(use-package consult-gh
  :ensure t
  :defer t
  :commands consult-gh)

(use-package consult-gh-embark
    :ensure t
    :defer t
    :after (consult-gh embark)
    :hook
    (magit-mode . consult-gh-embark-mode))

(use-package consult-gh-with-pr-review
  :ensure t
  :defer t
  :hook
  (consult-gh-pr-view-mode . consult-gh-with-pr-review-mode))

(use-package consult-gh-nerd-icons
  :defer t
  :ensure t)

(use-package treemacs-nerd-icons
  :ensure t
  :after nerd-icons
  :defer nil
  :if (display-graphic-p))

(use-package treemacs
  :ensure t
  :defer t
  :bind
  (("C-c t o" . treemacs-select-window)
   ("C-c t t" . treemacs)
   :map treemacs-mode-map
        ("x" . treemacs-mark-or-unmark-path-at-point)
        ("M" . treemacs-move-marked-files)
        ("D" . treemacs-delete-marked-files))
  :hook
  (treemacs-mode . treemacs-peek-mode)
  (treemacs-mode . (lambda () (dired-sidebar-hide-sidebar)))
  (treemacs-mode . (lambda () (golden-ratio-mode 0)))
  :custom
  (treemacs-display-in-side-window nil)
  :config
  (if (display-graphic-p)
      (treemacs-load-theme "nerd-icons"))

  (add-hook 'find-file-hook (lambda ()
			      (unless display-line-numbers-mode
				(display-line-numbers-mode 1)))))

(use-package treemacs-projectile
  :ensure t
  :defer t
  :hook
  (treemacs-mode . treemacs-projectile))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit)
  :defer t
  :hook
  (treemacs-mode . treemacs-magit-mode))

(use-package demap
  :ensure (:autoloads t)
  :bind
  ("C-c d" . demap-toggle)
  :custom
  (demap-minimap-minimum-wdith 30)
  (demap-minimap-window-side 'right))

(use-package treesit-auto
  :ensure t
  :defer t
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  :hook
  (elpaca-after-init . global-treesit-auto-mode))

(use-package tree-sitter
  :ensure t
  :after treesit-auto
  :defer t
  :hook
  (elpaca-after-init . global-tree-sitter-mode)
  (tree-sitter-after-on . tree-sitter-hl-mode)
  :config
  (setq treesit-extra-load-path (list (file-truename "~/.emacs.d/tree-sitter/")))
  (setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (dockerfile "https://github.com/camdencheek/tree-sitter-dockerfile")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml"))))

(use-package tree-sitter-langs
  :ensure t
  :defer t
  :config
  (puthash 'python-ts-mode 'python tree-sitter-major-mode-language-table)
  (puthash 'c++-ts-mode 'cpp tree-sitter-major-mode-language-table)
  (puthash 'rust-ts-mode 'rust tree-sitter-major-mode-language-table)
  (puthash 'js-ts-mode 'js tree-sitter-major-mode-language-table)
  (puthash 'typescript-ts-mode 'ts tree-sitter-major-mode-language-table)
  (puthash 'ruby-ts-mode 'ruby tree-sitter-major-mode-language-table))

(use-package dockerfile-ts-mode
  :ensure nil
  :defer t
  :mode
  (("Dockerfile\\'" . dockerfile-ts-mode)
   ("\\.dockerfile\\'" . dockerfile-ts-mode))
  :hook
  (dockerfile-ts-mode . lsp-deferred))

(use-package typescript-ts-mode
  :ensure nil
  :defer t
  :mode
  (("\\.ts\\'" . typescript-ts-mode)
   ("\\.mts\\'" . typescript-ts-mode)
   ("\\.cts\\'" . typescript-ts-mode))
  :hook
  (typescript-ts-mode . lsp-deferred)
  (typescript-ts-mode . subword-mode))

(use-package tsx-ts-mode
  :ensure nil
  :defer t
  :mode
  (("\\.tsx\\'" . tsx-ts-mode)
   ("\\.jsx\\'" . tsx-ts-mode))
  :hook
  (tsx-ts-mode . lsp-deferred)
  (tsx-ts-mode . subword-mode))

(use-package js-ts-mode
  :ensure nil
  :defer t
  :mode
  (("\\.js\\'" . js-ts-mode)
   ("\\.mjs\\'" . js-ts-mode)
   ("\\.cjs\\'" . js-ts-mode))
  :hook
  (js-ts-mode . lsp-deferred)
  (js-ts-mode . subword-mode))

(use-package json-ts-mode
  :ensure nil
  :defer t
  :mode
  (("\\.json\\'" . json-ts-mode)
   ("\\.jsonl\\'" . json-ts-mode))
  :hook
  (json-ts-mode . lsp-deferred)
  (json-ts-mode . subword-mode))

(use-package moldable-emacs
  :ensure (moldable-emacs :host github :repo "ag91/moldable-emacs")
  :defer t
  :bind (("C-c M m" . me-mold)
         ("C-c M f" . me-go-forward)
         ("C-c M b" . me-go-back)
         ("C-c M o" . me-open-at-point)
         ("C-c M d" . me-mold-docs)
         ("C-c M g" . me-goto-mold-source)
         ("C-c M e a" . me-mold-add-last-example)
         )
  :config
  (add-to-list
   'me-files-with-molds
   (concat
    (file-name-directory (symbol-file 'me-mold))
    "molds/experiments.el")) ;; TODO this is relevant only if you have private molds
  (me-setup-molds))

(use-package lsp-mode
  :ensure t
  :defer t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook
  (prog-mode . lsp-deferred)
  (sh-mode . lsp-deferred)
  (bash-ts-mode . lsp-deferred)
  (lsp-mode . lsp-enable-which-key-integration)
  (org-src-mode . lsp-deferred)
  :commands lsp)

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :defer t
  :commands
  lsp-ui-mode
  :hook
  (lsp-mode . lsp-ui-mode)
  :config
  (lsp-ui-doc-mode 1))

(use-package lsp-treemacs
  :ensure t
  :defer t
  :commands
  lsp-treemacs-errors-list
  :hook
  (lsp-mode . lsp-treemacs-sync-mode))

(use-package consult-lsp
  :ensure t
  :defer t
  :after (consult lsp-mode))

(use-package meow-tree-sitter
  :ensure t
  :defer t
  :after (meow tree-sitter)
  :init
  (meow-tree-sitter-register-defaults)
  :config
  (meow-normal-define-key
   '("o" . meow-tree-sitter-node)))

(use-package rainbow-delimiters
  :ensure t
  :hook
  (prog-mode . rainbow-delimiters-mode))

(use-package undo-tree
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . global-undo-tree-mode)
  :config
  (keymap-global-set "C-x u" #'my/undo-tree-visualize)

  (defun my/undo-tree-visualize ()
    (interactive)
    (if (and (buffer-file-name) (treemacs-get-local-window))
        (progn
          (let ((original-buffer (window-buffer (other-window-for-scrolling))))
            (unless undo-tree-mode
              (undo-tree-mode))
            (undo-tree-visualize)
            (switch-to-buffer (get-buffer original-buffer)))
          (treemacs-select-window)
          (my/split-window-below)
          (switch-to-buffer
           (get-buffer undo-tree-visualizer-buffer-name)))
      (undo-tree-visualize)))

  (defun my/undo-tree-visualizer-quit ()
    (interactive)
    (let* ((win-list (window-at-side-list)))
      (undo-tree-visualizer-quit)
      (dolist (win win-list)
        (when
            (string= (buffer-name (window-buffer win)) undo-tree-visualizer-buffer-name)
          (delete-window win)))))
  
  (defun my/refresh-undo-tree-visualizer (buffer)
    (my/undo-tree-visualizer-quit)
    (my/undo-tree-visualize)
    (get-buffer buffer)
    (other-window 1))
  
  (add-hook 'treemacs-after-visit-functions #'my/refresh-undo-tree-visualizer))

(use-package flycheck
  :ensure t
  :defer t
  :custom
  (flycheck-idle-change-delay 5)
  (flycheck-idle-buffer-switch-delay 5)
  (flycheck-check-syntax-automatically '(save idle-change mode-enabled))
  :hook
  (elpaca-after-init . global-flycheck-mode))

(use-package flycheck-posframe
  :ensure t
  :after flycheck
  :defer t
  :if (or (featurep 'tty-child-frames) (display-graphic-p))
  :init
  (flycheck-posframe-configure-pretty-defaults)
  :custom
  (flycheck-posframe-border-width 16)
  :hook
  (flycheck-mode . flycheck-posframe-mode))

(use-package consult-flycheck
  :ensure t
  :defer t
  :after (consult flycheck)
  :commands
  consult-flycheck)

(use-package flycheck-relint
  :ensure t
  :after flycheck
  :defer t)

(use-package eldoc-box
  :ensure t
  :defer t
  :if (or (featurep 'tty-child-frames) (display-graphic-p))
  :bind
  (("C-<prior>" . eldoc-box-scroll-down)
   ("C-<next>"  . eldoc-box-scroll-up))
  :hook (prog-mode . eldoc-box-hover-mode)
  :config
  (when (fboundp 'doom-color)
    (set-face-attribute 'eldoc-box-border nil
                        :background (doom-color 'yellow)))
  
  (defun my/eldoc-box--always-frame-top-right (width _height)
    (pcase-let ((`(,_left ,right ,top) eldoc-box-offset))
      (cons (- (frame-outer-width) width right)
            top)))
  (setq eldoc-box-position-function #'my/eldoc-box--always-frame-top-right))

(use-package codemetrics
  :defer t
  :ensure (codemetrics :host github :repo "jcs-elpa/codemetrics")
  :hook
  (tree-sitter-mode . codemetrics-mode))

(use-package combobulate
  :defer t
  :ensure (combobulate :host github :repo "mickeynp/combobulate")
  :custom
  (combobulate-key-prefix "C-c u")
  :hook
  (tree-sitter-mode . combobulate-mode))

(use-package dtrt-indent
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . dtrt-indent-global-mode))

(use-package indent-bars
  :ensure t
  :defer t
  :init
  (set-face-attribute 'default nil :stipple nil)
  :custom
  (indent-bars-treesit-support t)
  (indent-bars-no-descend-lists t)
  :hook
  (prog-mode . indent-bars-mode))

(use-package yasnippet
  :ensure t
  :defer t
  :custom
  (yas-snippet-dirs '("~/.emacs.d/snippets"))
  :hook
  (prog-mode . yas-minor-mode)
  (org-mode . yas-minor-mode)
  :hook
  (elpaca-after-init . yas-reload-all))

(use-package yasnippet-snippets
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . yasnippet-snippets-initialize))

(use-package consult-yasnippet
  :ensure t
  :after (consult yasnippet)
  :defer t
  :commands
  consult-yasnippet)

(use-package org
  :ensure (:wait t)
  :defer nil
  :custom
  (org-directory (file-truename "~/org/"))
  (org-startup-folded t) ;; a more compact display
  (org-agenda-start-on-weekday 0)
  (org-startup-indented t)
  (org-M-RET-may-split-line '((item . nil)))
  (org-support-shift-select t)
  (org-return-follows-link t)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-refile-targets '((org-agenda-files :maxlevel . 3)))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (emacs-lisp . t)
     (org . t)
     (latex . t)))
  
  (keymap-global-set "C-c c" #'org-capture)
  (keymap-global-set "C-c l" #'org-link-store-props)
  (keymap-global-set "C-c a" #'org-agenda)

  (defun my/org-mode-level-font-size ()
    (set-face-attribute 'org-level-4 nil :inherit 'outline-4 :height 1.0)      
    (set-face-attribute 'org-level-3 nil :inherit 'outline-3 :height 1.1)      
    (set-face-attribute 'org-level-2 nil :inherit 'outline-2 :height 1.2)      
    (set-face-attribute 'org-level-1 nil :inherit 'outline-1 :height 1.3)      
    (set-face-attribute 'org-document-title nil :inherit 'outline-1 :height 1.4 :underline nil))

  (my/org-mode-level-font-size)
  
  (unless (display-graphic-p)
    (keymap-unset org-mode-map "C-c ,")
    (keymap-set org-mode-map "C-c , p" #'org-priority)
    (keymap-set org-mode-map "C-c , i" #'org-insert-structure-template))

  (org-link-set-parameters "gh"
    			   :follow #'my/gh-open
    			   :export #'my/gh-export
    			   :store-link #'my/gh-store-link
    			   :insert-description #'my/gh-link-description)

  (org-link-set-parameters "hf"
    			   :follow #'hf-open
    			   :export #'hf-export
    			   :insert-description #'hf-description
    			   :store-link #'hf-store-link)


  (org-link-set-parameters "repo"
    			   :follow #'my/repo-open
    			   :export #'my/repo-export
    			   :store-link #'my/repo-store-link
    			   :insert-description #'my/repo-link-description)


  (org-link-set-parameters "ref"
   			   :follow #'my/ref-link--open-link
   			   :export #'my/ref-link--export-link
   			   :store-link #'my/ref-link--store-link
   			   :insert-description #'my/ref-link--insert-description))

;; org-ibullets for nice-looking bullets
(use-package org-ibullets
  :defer t
  :ensure (org-ibullets :host github :repo "jamescherti/org-ibullets.el" :build (:after org))
  :hook
  (org-mode . org-ibullets-mode))

;; org-modern-indent because org-modern doesn't work with org-indent-mode
(use-package org-modern-indent    
  :defer t
  :ensure (org-modern-indent :host github :repo "jdtsmith/org-modern-indent" :build (:after org))
  :hook
  (org-mode . org-modern-indent-mode))

;; org-modern
(use-package org-modern
  :ensure t
  :after org
  :defer t
  :hook
  (org-mode . global-org-modern-mode)
  :custom    
  (org-modern-hide-stars nil)
  (org-modern-star 'replace)
  (org-modern-block-fringe 2)
  (org-modern-todo nil)
  (org-modern-tag nil)
  (org-modern-block-name t)
  (org-modern-timestamp nil)
  (org-modern-progress nil)

  (org-auto-align-tags nil)
  (org-tags-column 0)
  (org-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)

  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-pretty-entities-include-sub-superscripts nil)
  (org-agenda-tags-column 0)
  (org-ellipsis "...")

  :config
  (modify-all-frames-parameters '((right-divider-width . 40)
                                  (internal-border-width . 30)))

  (dolist (face '(window-divider
                  window-divider-first-pixel
                  window-divider-last-pixel))
    (face-spec-reset-face face)
    (set-face-foreground face (face-attribute 'default :background)))
  (set-face-background 'fringe (face-attribute 'default :background)))

;; and then we use org-appear to unhide the emphasis markers when hovered over
(use-package org-appear
  :ensure t
  :hook
  (org-mode . org-appear-mode))

(defun my/gh-open (link _)
  (browse-url (my/gh-expand-link link)))

(defun my/gh-expand-link (link)
  (if (string-search "#" link)
      (progn (if (string-search ":#" link)
		 (apply #'format "https://github.com/%s/pull/%s"
			(my/gh-parse-link link))
	       (apply #'format "https://github.com/%s/issues/%s"
		      (my/gh-parse-link link))))
    (if (string-search ":" (string-remove-prefix "gh:" link))
	(apply #'format "https://github.com/%s/tree/%s" (my/gh-parse-link link))
      (format "https://github.com/%s" link))))

(defun my/gh-export (link description backend info)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path (my/gh-expand-link link)))))
	(funcall transcode-link link desc info))
    (concat "gh:" link)))

(defun my/get-sep (link)
  (if (string-search "#" link)
      (if (string-search ":#" link)
	  ":#" "#")
    ":"))

(defun my/gh-get-entry-type (link)
  (if (string= (my/get-sep link) ":#")
      "pr"
    "issue"))

(defun my/gh-parse-link (link) 
  (let ((parts
	 (string-split (string-remove-prefix "gh:" link)
		       (my/get-sep link) t)))
    parts))

(defun my/gh-link-description (link description)
  (or description
      (if (string-search "#" link)
	  (progn (let* ((repo (nth 0 (my/gh-parse-link link)))
			(id (nth 1 (my/gh-parse-link link)))
			(entry (my/gh-get-entry-type link)))
		   (format "%s: %s"
			   (string-replace ":#" "#"
					   (string-remove-prefix "gh:" link))
			   (my/gh-get-entry-title repo entry id))))
	(if (string-search ":" (string-remove-prefix "gh:" link))
	    (string-remove-prefix "gh:" link)
	  link))))

(defun my/gh-get-entry-title (repo entry id)
  (let ((cmd (format "gh %s view %s --repo %s --json title"
		     (shell-quote-argument entry)
		     (shell-quote-argument id)
		     (shell-quote-argument repo))))
    (alist-get 'title
	       (json-parse-string
		(shell-command-to-string cmd) :object-type 'alist))))

(defun my/gh-store-link (link &optional description)
  (org-link-store-props
   :type "gh"
   :link (my/gh-expand-link link)
   :description (my/gh-link-description link description)))

(defun hf-open (repo &optional repo-type)
  (interactive
   (list (completing-read "Choose repo type: " '("model" "dataset"))))
  (browse-url (hf-expand-link repo repo-type)))

(defun hf-expand-link (repo &optional repo-type)
  (if (string= repo-type "dataset")
      (format "https://huggingface.co/datasets/%s" repo)
    (format "https://huggingface/co/%s" repo)))

(defun hf-export (repo description backend info &optional repo-type)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path (hf-expand-link repo repo-type)))))
	(funcall transcode-link link desc info))
    (concat "hf:" link)))

(defun hf-description (repo &optional description)
  (or description repo))

(defun hf-store-link (repo &optional description repo-type)
  (org-link-store-props
   :type "hf"
   :link (hf-expand-link repo repo-type)
   :description description))


(defun my/repo-open (link _)
  (browse-url (my/repo-expand-link link)))

(setq repo-list '("codeberg.org"))

(defun my/repo-domain ()
  (interactive
   (let ((repo-type (completing-read "Repo domain: " repo-list)))
     (when (not (member repo-type repo-list))
       (add-to-list 'repo-list (list repo-type)))
     repo-type)))

(defun my/repo-expand-link (link)
  (interactive "r")
  (let ((domain (my/repo-domain)))
    (if (string-search ":" (string-remove-prefix "repo:" link))
	(apply #'format
	       (concat "https://" domain "/%s/tree/%s") (my/repo-parse-link link))
      (format "https://%s/%s" domain link))))
  
(defun my/repo-export (link description backend info)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path (my/repo-expand-link link)))))
	(funcall transcode-link link desc info))
    (concat "repo:" link)))

(defun my/get-sep (link)
  (if (string-search "#" link)
      (if (string-search ":#" link)
	  ":#" "#")
    ":"))

(defun my/get-entry-type (link)
  (if (string= (my/get-sep link) ":#")
      "pr"
    "issue"))

(defun my/repo-parse-link (link) 
  (let ((parts (string-split (string-remove-prefix "repo:" link) (my/get-sep link) t)))
    parts))

(defun my/repo-link-description (link description)
  (or description
      (if (string-search ":" (string-remove-prefix "repo:" link))
	  (string-remove-prefix "repo:" link)
	link)))

(defun my/repo-store-link (link &optional description)
  (org-link-store-props
   :type "repo"
   :link (my/repo-expand-link link)
   :description (my/repo-link-description link description)))


(defun my/ref-link--open-link (link _)
  (org-link-open-from-string link))

(defun my/ref-link--parse-id (link)
  (let* ((id (string-remove-suffix "/" link))
	 (id (car (last (split-string id "/"))))
	 (id (string-remove-suffix ".pdf" id)))
    id))

(defun my/ref-link--export-link (link description backend info)
  (if-let ((transcode-link (alist-get
			    'link (org-export-backend-transcoders
				   (org-export-get-backend backend)))))
      (let ((link (org-element-create
		   'link (list :type "https"
			       :path link))))
	(funcall transcode-link link desc info))
    (concat "ref:" (my/ref-link--parse-id link))))

(defun my/ref-link--insert-description (link description)
  (or description
      (let ((id (my/ref-link--parse-id link)))
	(format "ref:%s" id))))

(defun my/ref-link--store-link (link &optional description)
  (org-link-store-props
   :type "ref"
   :link link
   :description (my/ref-link--insert-description link description)))

(setq org-gcal-client-id
      (auth-source-pick-first-password :host "org-gcal"
                                       :user "dania.moriazi01@khu.ac.kr^id"))
(setq org-gcal-client-secret
      (auth-source-pick-first-password :host "org-gcal"
                                       :user "dania.moriazi01@khu.ac.kr^secret"))

(use-package org-gcal
  :ensure t
  :defer t
  :after org
  :commands org-gcal-sync
  :config
  (setq org-gcal-fetch-file-alist '(("dania.moriazi01@khu.ac.kr" . "/home/dania/org/calendar.org"))))

(defun do-org-confirm-babel-evaluations (lang body)
  (not (or (string= lang "python")
           (string= lang "calc"))))

(setq-local org-confirm-babel-evaluate 'do-org-confirm-babel-evaluations)

(use-package org-project-capture
  :ensure t
  :defer t
  :bind
  (("C-c n p" . org-project-capture-project-todo-completing-read)
   ("C-c n t" . org-project-capture-capture-for-current-project)
   ("C-c n a" . org-project-capture-agenda-for-current-project))
  :config
  (progn
    (setq org-project-capture-backend
          (make-instance 'org-project-capture-projectile-backend))
    (setq org-project-capture-projects-file (expand-file-name "projects.org" org-directory))
    (org-project-capture-single-file)))

(use-package org-projectile
  :defer t
  :ensure t
  :after projectile)

;; parse message metadata
(defun slack/parse-message-loc (title)
  (concat "#" (string-trim (nth 1 (split-string title "#")))))

(defun slack/parse-sender (message)
  (string-trim (car (split-string message ":"))))

(defun slack/parse-message (info)
  (let* ((title (plist-get info :title))
	 (message (plist-get info :message)))
    (string-trim (nth 1 (split-string message ":")))))

;; configure alert
(defun my/slack-notify (info)
  (let* ((channel (slack/parse-message-loc (plist-get info :title)))
    	 (user (slack/parse-sender (plist-get info :message)))
    	 (message (slack/parse-message info))
    	 (pos (org-find-exact-headline-in-buffer channel)))
    (unless (string-search "주간보고" message)
      (write-region
       (s-concat
  	"** UNREAD "
  	(format "<%s> %s : %s"
    		(format-time-string "%Y-%m-%d %H:%M")
    		channel
    		user)
  	"\n"
  	(format "%s" message)
  	"\n")
       nil
       (concat org-directory "slack.org")
       t))))

(defun my/save-slack ()
  (interactive)
  (save-excursion
    (dolist (buf '("slack.org_archive" "slack.org"))
      (set-buffer buf)
      (if (and (buffer-file-name) (buffer-modified-p))
          (basic-save-buffer)))))

(defun my/org-agenda-todo-archive()
  (interactive)
  (org-agenda-todo 'done)
  (org-agenda-archive)
  (my/save-slack))

(defun my/slack-setup ()
  (alert-define-style
   'my/slack-alert
   :title "org slack alerts"
   :notifier (lambda (info)
               (if (get-buffer "slack.org")
                   (with-current-buffer "slack.org"
                     (save-buffer))
                 (with-current-buffer
                     (get-buffer-create (find-file (concat org-directory "slack.org")))
                   (save-buffer)))
               (my/slack-notify info)))
  
  (add-to-list 'alert-user-configuration
               '(((:category . "slack")) my/slack-alert nil))
  (add-hook 'org-agenda-mode-hook . (lambda ()
				    (keymap-local-set "M" 'my/org-agenda-todo-archive))))

(add-hook 'slack-mode-hook #'my/slack-setup)

;; first we convert org-mode to mrkdwn (markdown flavour used by slack)
(defun my/org-to-slack-md ()
  (interactive)
  (goto-char (point))
  (save-window-excursion
    (get-buffer (org-md-export-as-markdown nil 'subtree))
    (let* ((slack-md (buffer-string))
	   (pyscript (file-truename "~/.emacs.d/utils/convert-org-to-slack.py"))
	   (cmd (format "python %s --md %s"
			(shell-quote-argument pyscript)
			(shell-quote-argument slack-md))))
      (kill-buffer)
      (shell-command-to-string cmd))))

;; then we send the message
 (defun my/slack-send-message ()
  (interactive)
  (let ((slack-msg (my/org-to-slack-md)))
    (save-window-excursion
      (call-interactively #'slack-select-rooms)
      (if (not (string-search "Traceback" slack-msg))
	  (slack-if-let* ((buffer slack-current-buffer))
	      (slack-buffer-send-message buffer slack-msg))
	(print slack-msg)))))

(keymap-global-set "C-c S p" #'my/slack-send-message)
(keymap-global-set "C-c S o" #'my/org-to-slack-md)

(defun my/convert-time (&optional DATE TIME ZONE)
  (encode-time
   (parse-time-string
    (format "%sT%s%s" (format-time-string "%Y-%m-%d" DATE) TIME ZONE))))

(defun my/check-time-is-new-day ()
  (let ((is_night (time-less-p nil (my/convert-time nil "10:00:00" "+09"))))
    (if (not (member (format-time-string "%A") '("Saturday" "Sunday")))
	(and (not is_night) (time-less-p nil (my/convert-time nil "15:00:00" "+09")))
      (not is_night))))

(defun my/goto-or-create-timestamp-header ()
  (interactive)
  (with-current-buffer
      (set-buffer (current-buffer))
    (when (my/check-time-is-new-day)
      (let* ((timestamp (format-time-string "[%Y-%m-%d %a]"))
	     (pos (org-find-exact-headline-in-buffer timestamp)))
	(if (not pos)
	    (progn (goto-char (buffer-size))
		   (org-insert-heading nil nil t)
		   (insert timestamp)
		   (goto-char (buffer-size))
		   (org-capture 0 "d"))
	  (goto-char pos))
	(save-buffer)))))

(defun my/open-org-daily ()
  (interactive)
  (set-buffer
   (get-buffer (find-file (concat org-directory "daily.org"))))
  (when (my/check-time-is-new-day)
    (let* ((timestamp (format-time-string "[%Y-%m-%d %a]"))
	   (pos (org-find-exact-headline-in-buffer timestamp)))
      (unless pos (progn
		    (goto-char (buffer-size))
		    (org-insert-heading nil nil t)
		    (insert timestamp)
		    (goto-char (buffer-size))
		    (org-capture 0 "d")))))
  (goto-char (buffer-size))
  (current-buffer))

(keymap-global-set "C-c f d" #'my/open-org-daily)

(defun my/open-org-agenda ()
  (interactive)
  (split-window-right)
  (org-agenda nil "n")
  (current-buffer))

(defun my/kill-agenda-window ()
  (let ((agenda-win (get-buffer-window org-agenda-buffer-name)))
    (when agenda-win
      (delete-window agenda-win))))

(defun my/window-setup ()
  (interactive)
  (if (and (fboundp 'server-running-p) 
           (not (server-running-p)))
      (server-start))
  (my/open-org-agenda)
  (dired-sidebar-toggle-sidebar org-directory)
  (select-window (get-buffer-window dashboard-buffer-name))
  (add-hook 'demap-minimap-set-window-hook #'my/kill-agenda-window)
  (current-buffer))

(use-package dashboard 
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . dashboard-setup-startup-hook)
  :config
  (add-hook 'dashboard-after-initialize-hook #'my/window-setup)
  :custom
  (dashboard-banner-logo-title "the dashboard")
  (dashboard-startup-banner (expand-file-name "banner.txt" user-emacs-directory))
  (dashboard-center-content t)
  (dashbaord-vertically-center-content t)
  (dashboard-items '((recents . 5)
                     (bookmarks . 5)
                     (projects . 5)))
  (dashboard-navigation-cycle t)
  (dashboard-display-icons-p t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t))

(provide 'lazemacs-theme)
