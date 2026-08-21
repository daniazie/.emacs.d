;;; lazemacs-ide.el --- emacs-as-an-ide -*- lexical-binding: t; no-byte-compile: t; -*-

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

(use-package conda
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . conda-env-autoactivate-mode)
  (elpaca-after-init . (lambda () (conda-env-activate "base")))
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
  (treemacs-display-in-side-window nil) ;; I want to be able to split the window
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

(use-package demap
  :ensure (:autoloads t)
  :bind
  ("C-c d" . demap-toggle)
  :custom
  (demap-minimap-minimum-wdith 30)
  (demap-minimap-window-side 'right))

(defun my/demap-close (window)
  (unless (ht-equal-p
            (treemacs-current-workspace)
            (treemacs-find-workspace-from-path (buffer-file-path (window-buffer window)))))
      (demap-close))

(add-hook 'window-buffer-change-functions #'my/demap-close)

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

(provide 'lazemacs-ide)
