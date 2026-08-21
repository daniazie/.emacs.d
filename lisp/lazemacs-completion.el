;;; lazemacs-completion.el --- completions -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package posframe
  :ensure t
  :demand t)

(use-package which-key
  :ensure t t
  :defer t
  :hook
  (elpaca-after-init . which-key-mode)
  :custom
  (which-key-popup-type 'side-window)
  :config
  (which-key-setup-side-window-right-bottom))

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
  :ensure (:autoloads t)
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

(when (< (string-to-number emacs-version) 31.0)
  (use-package corfu-terminal
    :ensure t
    :after corfu
    :defer t
    :if (or (featurep 'tty-child-frames) (display-graphic-p))
    :hook
    (global-corfu-mode . corfu-terminal-mode)))

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

(provide 'lazemacs-completion)
