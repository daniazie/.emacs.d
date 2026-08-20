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

(provide 'lazemacs-prelude)
