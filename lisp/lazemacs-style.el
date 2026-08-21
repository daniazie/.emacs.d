;;; lazemacs-style.el --- on aesthetics -*- lexical-binding: t; no-byte-compile: t; -*-

(use-package doom-themes
  :ensure t
  :defer t
  :hook
  (elpaca-after-init . (lambda ()
                         (load-theme 'doom-gruvbox t))))

(use-package doom-modeline
  :ensure t
  :defer t
  :custom
  (doom-modeline-irc nil)
  (doom-modeline-github t)
  (doom-modeline-project-name t)
  (doom-modeline-battery nil)
  :hook
  (elpaca-after-init . doom-modeline-mode))

(use-package nerd-icons
  :ensure t
  :demand t)

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-ibuffer
  :ensure t
  :hook
  (ibuffer-mode . nerd-icons-ibuffer-mode))

(provide 'lazemacs-style)
